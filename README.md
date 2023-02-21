A simple application demonstrating the usage of Google Sign-in, Google Sheets, Google Drive, Google Calendar, and YouTube Data REST APIs.

Sign in and all of the pre-requirements to enable the usage of Google REST APIs can be found here:

### Sign-in tutorial:
https://developers.google.com/identity/sign-in/ios

### Firebase:
https://console.firebase.google.com/

### Google developers console:
https://console.cloud.google.com/

In the application, there can be found methods for:

### Google Sing-in

This is important to connect the application with Google services and enable and pass the scopes previously defined in the Google developer console.

More information how to add Google Sign-in can be found here:\
https://developers.google.com/identity/sign-in/ios/start-integrating

Google Sign-in code integration:\
https://developers.google.com/identity/sign-in/ios/sign-in

Requesting and adding scopes (accessing different Google APIs):\
https://developers.google.com/identity/sign-in/ios/api-access

### Google Spreadsheets:

    1. Append values

    2. Send data to any cell

    3. Read information from a sheet

    4. Get all of the Sheets from a Spreadsheet

Examples can be found in the [SpredsheetsController](https://github.com/mipar52/google-examples-swift/blob/master/google-examples-swift/Controllers/SpredsheetsController.swift).

### Google Drive:

    1. Get information from files on your Google Drive

    2. Create a new Spreadsheet and place it into your Google Drive

    3. Create new Sheets in a selected Spreadsheet
    

Examples can be found in the [DriveController](https://github.com/mipar52/google-examples-swift/blob/master/google-examples-swift/Controllers/DriveController.swift).

### Google Calendar

    1. Get primary calendar info

    2. Get info regarding all subscribed calendars

    3. Get info on all attending events
    
    4. Create an event
    
    5. Edit an event
    
    6. Delete an event

Examples can be found in the [CalendarController](https://github.com/mipar52/google-examples-swift/blob/master/google-examples-swift/Controllers/CalendarController.swift).

### YouTube Data API

    1. Get search list

    2. Get playlist videos

    3. Upload video
    
    4. Delete video
    
    5. Update video
    
    6. Insert comment

Examples can be found in the [YouTubeController](https://github.com/mipar52/google-examples-swift/blob/master/google-examples-swift/Controllers/YouTubeController.swift).

### Run the project 

    1. Make sure you're you've registered your project on Firebase and Google developers console

    2. Add the wanted scopes regarding each REST API in the Google developer console

    3. Add the GoogleService-Info.plist to your Xcode project
    
    4. In the GoogleService-Info.plist file, copy the REVERSED_CLIENT_ID and go to project TARGETS > Info > URL Types and add the reversed ID in the URL Schemes
    
    5. Run command  `pod install` when positioned yourself in the project's directory in Terminal
