; USAGE: Run in ui/deploy, requires the output be in 'windows' directory

!include "MUI2.nsh"

; General settings ----------------------------
Name "Cwtch"
; !define MUI_BRANDINGTEXT "SIG Beta Ver. 1.0"

Unicode True

# define the name of the installer
Outfile "cwtch-installer.exe"

# For removing Start Menu shortcut in Windows 7
#RequestExecutionLevel user
RequestExecutionLevel admin ;Require admin rights on NT6+ (When UAC is turned on)

# define the directory to install to, the desktop in this case as specified
# by the predefined $DESKTOP variable
InstallDir "$PROGRAMFILES\Cwtch"

;Get installation folder from registry if available
InstallDirRegKey HKCU "Software\Cwtch" "installLocation"

; MUI Interface -----------------------------

!define MUI_INSTALLCOLORS "DFB9DE 281831"

; 128x128, 32bit
!define MUI_ICON "..\windows\cwtch.ico"

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "..\nsis\cwtch_title.bmp"

!define MUI_TEXTCOLOR "350052"

!define MUI_WELCOMEFINISHPAGE_BITMAP "..\nsis\brand_side.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP_STRETCH NoStretchNoCrop

!define MUI_INSTFILESPAGE_COLORS "DFB9DE 281831"
!define MUI_INSTFILESPAGE_PROGRESSBAR "colored"

!define MUI_FINISHPAGE_NOAUTOCLOSE


ShowInstDetails show

; Pages --------


!define MUI_WELCOMEPAGE_TITLE "Welcome to the Cwtch installer"
!define MUI_WELCOMEPAGE_TEXT "Cwtch (pronounced: kutch) is a Welsh word roughly meaning 'a hug that creates a safe space'$\n$\n\
                              Cwtch is a platform for building consentful, decentralized, untrusted infrastructure using metadata resistant group communication applications. Currently there is a selfnamed instant messaging prototype app that is driving development and testing. Many Further apps are planned as the platform matures."

!define MUI_FINISHPAGE_TITLE "Enjoy Cwtch"
!define MUI_FINISHPAGE_RUN $INSTDIR/ui.exe
!define MUI_FINISHPAGE_TEXT "You can keep up-to-date on Cwtch and report any issues you have at https://cwtch.im"
!define MUI_FINISHPAGE_LINK "https://cwtch.im"
!define MUI_FINISHPAGE_LINK_LOCATION "https://cwtch.im"
!define MUI_FINISHPAGE_LINK_COLOR "D01972"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "../LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Languages --------------------------------

!insertmacro MUI_LANGUAGE "English"

# default section
Section

    # define the output path for this file
    SetOutPath $INSTDIR

    # define what to install and place it in the output path
    # Filler for .sh to populate with contents of deploy/windows
    #FILESLISTSTART
        FILE /r "windows\"
    #FILESLISTEND


    # create a shortcut in the start menu programs directory
    CreateDirectory "$SMPROGRAMS\Cwtch"
    CreateShortcut "$SMPROGRAMS\Cwtch\Cwtch.lnk" "$INSTDIR\ui.exe" "" "$INSTDIR\cwtch.ico"

    ;Store installation folder
    WriteRegStr HKCU "Software\Cwtch" "installLocation" $INSTDIR

SectionEnd
