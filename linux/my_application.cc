#include "my_application.h"

// Added to check for location of assets folder
#include <sys/types.h>
#include <sys/stat.h>

// To get the home dir of the user
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

// Redefining from flutter/engine::shell/platform/linux/fl_dart_project.cc
// struct def required here to enable compiler to allow access to variables
struct _FlDartProject {
  GObject parent_instance;

  gboolean enable_mirrors;
  gchar* aot_library_path;
  gchar* assets_path;
  gchar* icu_data_path;
  gchar** dart_entrypoint_args;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen *screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
     const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
     if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
       use_header_bar = FALSE;
     }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar *header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "cwtch");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  }
  else {
    gtk_window_set_title(window, "cwtch");
  }

  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();

  // Check if assets folder is relative to the executable or if we can use a system copy
  struct stat info;
  if (stat(fl_dart_project_get_assets_path(project), &info ) != 0 ) {
    if( stat("/usr/share/cwtch/data/flutter_assets", &info ) != 0 ) {
      struct passwd *pw = getpwuid(getuid());
      const char *homedir = pw->pw_dir;
      // /home/$USER/.local/share/cwtch/data/flutter_assets
      project->assets_path = g_build_filename(homedir, ".local", "share", "cwtch", "data", "flutter_assets", nullptr);
      // /home/$USER/.local/lib/cwtch/
      project->aot_library_path = g_build_filename(homedir, ".local", "lib", "cwtch", "libapp.so", nullptr);
      // /home/$USER/.local/share/cwtch/data
      project->icu_data_path = g_build_filename(homedir, ".local", "share", "cwtch", "data", "icudtl.dat", nullptr);
      gtk_window_set_icon_from_file(window,  g_build_filename(homedir, ".local", "share", "icons", "cwtch.png", nullptr), NULL);
    } else {
      // /usr/share/cwtch/data/flutter_assets
      project->assets_path = g_build_filename("/", "usr", "share", "cwtch", "data", "flutter_assets", nullptr);
      // /usr/lib/cwtch
      project->aot_library_path = g_build_filename("/", "usr", "lib", "cwtch", "libapp.so", nullptr);
      // /usr/share/cwtch/data
      project->icu_data_path = g_build_filename("/", "usr", "share", "cwtch", "data", "icudtl.dat", nullptr);
      gtk_window_set_icon_from_file(window, "/usr/share/icons/cwtch.png", NULL);
    }
  } else {
    gtk_window_set_icon_from_file(window, "./cwtch.png", NULL);
  }
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar ***arguments, int *exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GObject::dispose.
static void my_application_dispose(GObject *object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}
