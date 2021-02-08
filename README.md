# Swift Client SDK Drop in Audio Chat

<img src="https://developer.nexmo.com/assets/images/Vonage_Nexmo.svg" height="48px" alt="Nexmo is now known as Vonage" />

This is a Swift project that uses the [Client SDK](https://developer.nexmo.com/client-sdk/overview) to allow for drop in audio chat rooms. Check out the accompanying [blog post](LINKCOMMING) for more information.

## Welcome to Vonage

If you're new to Vonage, you can [sign up for a Vonage API account](https://dashboard.nexmo.com/sign-up?utm_source=DEV_REL&utm_medium=github&utm_campaign=) and get some free credit to get you started.

## Running the project
The project uses a REST server, to use the [Conversation API](https://developer.nexmo.com/conversation/overview) to create users and conversations. See the accompanying [blog post](LINKCOMING) for more information.

Clone the project to your computer, using the terminal:

`git clone git@github.com:nexmo-community/swift-client-sdk-drop-in-audio.git`

Install the Client SDK with Cocoapods:

`pod install`

Open the project in xcode:

`xed .`

The project connects to 3 endpoints:

+ `/auth` (POST): 

This returns a JWT to log the Client SDK in.

+ `/rooms` (GET):

This returns a list of open chat rooms.

+ `/rooms` (POST):

This allows the app to create a new room.


## Getting Help

We love to hear from you so if you have questions, comments or find a bug in the project, let us know! You can either:

* Open an issue on this repository
* Tweet at us! We're [@VonageDev on Twitter](https://twitter.com/VonageDev)
* Or [join the Vonage Developer Community Slack](https://developer.nexmo.com/community/slack)

## Further Reading

* Check out the Developer Documentation at <https://developer.nexmo.com>
