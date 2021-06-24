# Specification

This document outlines the minimal functionality necessary for us to consider Flwtch the canonical
Cwtch UI implementation.

This functionality is implemented in libCwtch and so this work captures just the UI work
required - any new Cwtch work is beyond the scope of this initial spec.

# Functional Requirements
- [ ] Kill all processes / isolates on exit (Blocked - P1)
- [X] Android Service? (P1)

# Splash Screen
- [X] Android
    - [X] Investigate Lottie [example implementation blog](https://medium.com/swlh/native-splash-screen-in-flutter-using-lottie-121ce2b9b0a4)
- [ ] Desktop (P2)

# Custom Styled Widgets
- [X] Label Widget
    - [X] Initial
    - [X] With Accessibility / Zoom Integration (P1)
- [X] Text Field Widget
- [X] Password Widget
- [X] Text Button Widget (for Copy)

## Home Pane (formally Profile Pane)

- [X] Unlock a profile with a password
- [X] Create a new Profile
    - [X] With a password
    - [X] Without a password
- [X] Display all unlocked profiles
    - [X] Profile Picture
        - [X] default images
        - [ ] custom images (P3)
        - [X] coloured ring border (P2)
    - [X] Profile Name
    - [X] Edit Button
    - [X Unread messages badge (P2)
- [X] Navigate to a specific Profile Contacts Pane (when clicking on a Profile row)
- [X] Navigate to a specific Profile Management Pane (edit Button)
- [X] Navigate to the Settings Pane (Settings Button in Action bar)

## Settings Pane
- [X] Save/Load
- [X] Switch Dark / Light Theme
- [X] Switch Language
- [X] Enable/Disable Experiments
- [ ] Accessibility Settings (Zoom etc. - needs a deep dive into flutter) (P1)
- [X] Display Build & Version Info
- [X] Acknowledgements & Credits

## Profile Management Pane

- [X] Update Profile Name
- [X] Update Profile Password
- [X] Error Message When Attempting to Update Password with Wrong Old Password (P2)
- [ ] Easy Transition from Unencrypted Profile -> Encrypted Profile (P3)
- [X] Delete a Profile (P2)
    - [X] Dialog Acknowledgement (P2)
    - [X] Require Old Password Gate (P2)
    - [X] Async Checking of Password (P2)
- [X] Copy Profile Onion Address

## Profile Pane (formally Contacts Pane)

- [X] Display Profile-specific status
    - [X] Profile Name
    - [X] Online Status
    - [X] Add Contact Button Navigates to Add Contact Pane
- [ ] Search Bar (P2)
    - [ ] Search by name
    - [ ] Search by Onion
- [ ] Display all Peer Contacts
    - [X] Profile Picture
    - [X] Name
    - [X] Onion
    - [X] Online Status
    - [X] Unread Messages Badge (P1)
    - [X] In Order of Most Recent Message / Activity (P1)
    - [X] With Accept / Reject Heart/Trash Bin Option (P1)
    - [X] Separate list area for Blocked Contacts (P1)
- [X] Display all Group Contacts (if experiment is enabled)
- [X] Navigate to a specific Contact or Group Message Pane (Contact Row)
- [X] Pressing Back should go back to the home pane

## Add Contact Pane
- [X] Allowing Copying the Profile Onion Address for Sharing
- [X] Allowing Pasting a Peer Onion Address for adding to Contacts
    - [ ] (with optional name field)
- [X] Allowing Pasting a Group Invite / Server Address
    - [X] (if group experiment is enabled)

## Message Overlay

- [X] Display Messages from Contacts
- [X] Allowing copying the text of a specific message (on mobile) (P2)
- [X] Send a message to the specific Contact / Group
- [~] Display the Acknowledgement status of a message (P1)
- [X] Navigate to the specific Contact or Group Settings Pane ( Settings Button in Action bar)
- [ ] Emoji Support (P1)
    - [ ] Display in-message emoji text labels e.g. `:label:` as emoji. (P1)
    - [ ] Functional Emoji Drawer Widget for Selection (P2)
    - [ ] Mutant Standard? (P2)
- [X] Display a warning if Contact / Server is offline  (Broken Heart) (P1)
- [X] Display a warning for configuring peer history (P2)
- [X] Pressing Back should go back to the contacts pane

## List Overlay (P3)

- [ ] Add Item to List (P3)
- [ ] mark Item as Complete (P3)
- [ ] Delete Item from List (P3)
- [ ] Search List (P3)

## Bulletin Overlay (P4)

## Contact Settings Pane
- [X] Update local name of contact
- [X] Copy contact onion address
- [X] Block/Unblock a contact
- [X] Configure Peer History Saving
- [X] Pressing Back should go back to the message pane

## Group Settings Pane (experimental - P3)
- [X] Gated behind group experiment
- [X] Update local name of group
- [X] Get Group Invite
- [X] Leave Group
- [X] Pressing Back should go back to the message pane for the group



## Android Requirements Notes

What are our expectations here?

- Can we periodically check groups in the background to power notifications?
- Either way we need networking in the service not the main/UI thread.
- We probably don't want to and very likely can't persist tor connections to peers indefinitely.
- Neither google nor apple are very tolerant of apps that try to create their own push message infrastructure.

- "Aside": Retrieving a CallbackHandle for a method from PluginUtilities.getCallbackHandle has the side effect of populating a callback cache within the Flutter engine, as seen in the diagram above. This cache maps information required to retrieve callbacks to raw integer handles, which are simply hashes calculated based on the properties of the callback. This cache persists across launches, but be aware that callback lookups may fail if the callback is renamed or moved and PluginUtilities.getCallbackHandle is not called for the updated callback.
- The above seems to imply that there is a persistent cache somewhere that can affect code between launches...the ramifications of this are ?!?!
