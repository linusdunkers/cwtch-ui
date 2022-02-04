## Environments

Located in the `integration_test/env` folder and managed by the hooks in `integration_test/hooks/env.dart`. Specify the environment you want a feature to run in by tagging it.

* `[no tag] (env/default)`: default environment to load if none is specified
* `@env:aliceandbob1 (env/aliceandbob1)`: no-password Alice, Bob, and Carol profiles. Alice and Bob have already added each other, Carol has no contacts
* `@env:persist (env/persist)`: changes made to this profile persist between features and scenarios (but NOT between runs)
* `@env:clean`: runs the feature with no profile existing yet on disk

## Tests

[ ] 1. general
  [X] splash screen + clean load
  [X] setting save+load (TODO: dropdowns)
  [~] tor status+reset
  [~] shutdown cwtch
[ ] 2. global settings (verify functionality)
  [_] language # blocked by dropdown
  [_] theme+color theme # blocked by dropdown
  [ ] column mode -> background? so all tests check both modes?
  [X] block unknown
  [X] streamer mode
[ ] 3. experiments (
  [ ] group chat -> needs many
  [ ] server hosting -> also many
  [ ] file sharing -> a couple
    [ ] image previews
  [ ] clickable links (how much to test?)
[ ] 4. profile mgmt
  [X] create+delete
  [X] default+password load
  [X] name change
  [ ] password change
  [ ] known server mgmt
[ ] 5. p2p chat
  [ ] add, remove, block, archive
  [ ] invite accept+reject
  [X] send+receive
    [ ] acks
  [ ] try to send a long message
  [ ] malformed messages, replies
  [ ] overlays (invite, file/image)
    [ ] send
    [ ] receive
    [ ] functionality
[ ] 6. p2p settings
  [ ] name saving + transmission
  [ ] block (ui indicators, functionality) inc in groups
  [ ] history save+load
[ ] 7. groupchat
  [ ] add, leave, archive
  [ ] send+receive inc acks
  [ ] try to send a long message
  [ ] malformed messages, replies
  [ ] overlays (invite, file/image) inc from non-contacts
    [ ] send
    [ ] receive
    [ ] functionality
[ ] 8. group settings
  [ ] display name
