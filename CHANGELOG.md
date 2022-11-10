# Piano SDK for iOS

## v2.5.5
* [PianoOAuth] - Added function for update user info
* [PianoComposer] - Added tracking functions

## v2.5.4
* [PianoTemplate] - Fixed memory leak

## v2.5.3
* [PianoComposer] - Added request parameters (title, description, etc...)

## v2.5.2
* [PianoID] - Added getting user information
* [PianoTemplate] - Added custom form tracking

## v2.5.1
* [PianoComposer] - Added support accessToken for CDN
* [PianoComposer] - Added support forms
* [PianoComposer] - Added support recommendations
* [PianoTemplate] - Added support form template
* [PianoTemplate] - Added support recommendations template

## v2.5.0
* Added Swift Package Manager support
* [PianoCommon] Common functionality moved to a new component PianoCommon
* [PianoComposer] Added Apple TV support

## v2.4.2
* [PianoComposer] Fixed activity indicator
* [PianoOAuth] Fixed cancel handler

## v2.4.1
* [PianoComposer] Fixed calling composerExecutionCompleted method for PianoComposerDelegate
* [PianoComposer] Added support "Set response variable"
* [PianoC1X] Cxense SDK updated to v1.9.7

## v2.4.0
* [Piano Composer] Added support C1X
* [Piano ID] Removed deprecated functions

## v2.3.13
* [Piano ID] Added email confirmation flag
* [Piano ID] Fix problems with saved cookies

## v2.3.12

* Changed endpoint structure for PianoComposer
* Added static endpoints for PianoComposer (production, production-australia, production-asia-pacific, sandbox)
* Changed handlers in `PianoIDDelegate`
* Added `customEvent` handler to `PianoIDDelegate`
* Added `incremented` parameter for `PageViewMeterEventParams`
