# 📘 Google API Integration Examples in Swift

This project provides practical, fully working Swift examples demonstrating how to integrate several key **Google APIs** into an iOS application using **SwiftUI**, **Swift Concurrency (`async/await`)**, and traditional **completion handlers**.

### Included API Integrations

- **Google Sign-In** – OAuth authentication with secure token handling
- **Google Sheets API** – Read from and write to spreadsheet data
- **Google Drive API** – List, download, and upload files
- **Google Calendar API** – Read and create events programmatically
- **YouTube Data API** – Display videos, fetch comment threads, and manage comment replies

> ⚠️ I built this project because I found it difficult to find up-to-date examples for using Google APIs with Swift. Most of the official docs and code samples are still written in **Objective-C** and use **UIKit**, which isn't very helpful if you're working with **SwiftUI** or modern Swift.\
This repo is my attempt to make things easier — a collection of simple, real-world examples showing how to use Google Sign-In, Sheets, Drive, Calendar, and YouTube APIs using **Swift**, **SwiftUI**, a little bit of modern concurrency (**async/await**) and using the traditional completion handlers.
---

## Table of Contents

- [Google API Integration Examples in Swift](#-google-api-integration-examples-in-swift)
  - [Included API Integrations](#included-api-integrations)
- [🚀 Quickstart](#-quickstart)
  - [Requirements](#requirements)
  - [Running the Project](#running-the-project)
- [Legacy UIKit Version (CocoaPods)](#-legacy-uikit-version-cocoapods)
- [Important links for integration](#important-links-for-integration)
- [Integration](#integration)
- [Google Sign-In Integration](#-google-sign-in-integration)
- [Google Drive API](#google-drive-api)
- [Google Spreadsheets](#google-spreadsheets)
- [Google Calendar API](#google-calendar-api)
- [YouTube API](#youtube-api)
  - [Comments & Threads](#comments--threads)


## 🚀 Quickstart

This project uses **Swift Package Manager** and is written entirely in Swift + SwiftUI.

### Requirements

- Xcode 15+
- iOS 15+
- A Google Cloud project with the following APIs enabled:
  - Google Drive API
  - Google Sheets API
  - Google Calendar API
  - YouTube Data API v3
- OAuth Client ID (iOS) configured in Google Cloud Console

### Running the Project

1. Clone the repository:

   ```bash
   git clone https://github.com/your-org/google-examples-swift.git
   ```

2. Open the project:

   ```bash
   open google-examples-swift.xcodeproj
   ```

3. In **Google Cloud Console**, create an OAuth 2.0 Client ID for iOS and download the ClientID and the Reverse Client ID (check the project's `Info.plist`).

4. In `Constants.swift`, fill in your:

   - `sheetID`
   - `calendarId`
   - `youTubePlaylistId`
   - Required `Scopes`

**Note** - none the variables in the file need to be changed. Feel free to use them for testing.

5. Build and run the app on a real device or simulator.
---

## Legacy UIKit Version with CocoaPods

If you're using a UIKit-based codebase or prefer working with CocoaPods, check out the `uikit_cocoapods` project.

This version contains:

- Full integration of Google APIs using **UIKit**
- Dependencies managed with **CocoaPods**

- Instructions:

```bash
git clone https://github.com/your-org/google-examples-swift.git
pod install
open google-examples-uikit.xcworkspace
```

## Important links for integration

### Sign-in tutorial:
https://developers.google.com/identity/sign-in/ios

### Accessing Google APIs (granting scopes)
https://developers.google.com/identity/sign-in/ios/api-access

### Firebase:
https://console.firebase.google.com/

### Google developers console:
https://console.cloud.google.com/

## Integration
If using Swift Package Manager:
- Google Sign-In:
```bash
# use rule: "Up to next major version: 9.0.0"
https://github.com/google/GoogleSignIn-iOS
```
- Google's REST APIs:
```bash
# use rule: "Up to next major version: 5.0.0"
https://github.com/google/google-api-objectivec-client-for-rest.git
```

- Additionally, make sure you set the neccessary frameworks in the project (TARGETS > General > Frameworks):
<img width="1824" height="478" alt="Image" src="https://github.com/user-attachments/assets/10fc70bb-fca9-4808-97f0-f29127061f3a" />


## API usage

### Google Sing-in

This is important to connect the application with Google services and enable and pass the scopes previously defined in the Google developer console.

More information how to add Google Sign-in can be found here:\
https://developers.google.com/identity/sign-in/ios/start-integrating

Google Sign-in code integration:\
https://developers.google.com/identity/sign-in/ios/sign-in

Requesting and adding scopes (accessing different Google APIs):\
https://developers.google.com/identity/sign-in/ios/api-access

## 🔐 Google Sign-In Integration

This project includes a fully working implementation of **Google Sign-In** using Swift and SwiftUI.
- Google Sign in examples can be found [here](https://github.com/mipar52/google-examples-swift/blob/feature/refactor/refactor/google-examples-swift/google-examples-swift/GoogleServices/GoogleSignInService.swift).

The `GoogleSignInService` wraps the `GIDSignIn` SDK and provides a clean, Swift-native API for:

- Signing in users using `GIDSignIn`, with or without requesting additional OAuth scopes
- Requesting additional scopes after the initial sign-in (e.g. access to Google Sheets, Drive, Calendar, YouTube)
- Returning structured sign-in results using completion handlers
- Signing users out with a single call

All required scopes are defined and managed in a centralized `Constants` file.

### Core Methods

- `handleSignIn(...)`: Basic sign-in without requesting additional scopes
- `handleSignInWithAdditionalScopes(...)`: Sign-in with additional scopes at login
- `requestAdditionalScopes(...)`: Request more permissions after a user is already signed in
- `signOut()`: Ends the current session

---

### Sign-In Lifecycle Management

The sign-in flow is integrated into the SwiftUI app lifecycle:

```swift
@main
struct google_examples_swiftApp: App {
    var body: some Scene {
        WindowGroup {
            GoogleSignInView()
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        // Restore session if available
                    }
                }
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url) // Handle OAuth redirect
                }
        }
    }
}
```

## Google Drive API
- Google Drive examples can be found [here](https://github.com/mipar52/google-examples-swift/blob/feature/refactor/refactor/google-examples-swift/google-examples-swift/GoogleServices/GoogleDriveService.swift).

The `GoogleDriveService` provides a high-level interface for interacting with the **Google Drive** and **Google Sheets** APIs using modern Swift practices including `async/await` and completion handlers.  
It simplifies reading, creating, downloading, and managing files in Google Drive and Sheets directly from a SwiftUI iOS app.

---

### Authorization

Before performing any Drive or Sheets operations, the service authenticates using the currently signed-in user:

```swift
GIDSignIn.sharedInstance.currentUser?.fetcherAuthorizer
```

It sets the authorizer and `Authorization` headers on both the Drive and Sheets services. This ensures all subsequent API requests are properly authenticated with the user's access token.

---

### 📂 Methods that can be found

#### Read Files by MIME Type

```swift
readFiles(search fileType: String)
```

Fetches and prints a list of files from the user's Google Drive matching the given MIME type. Example MIME types include:

- `spreadsheet` for Google Sheets
- `folder` for Google Drive folders
- `document` for Google Docs

The method also supports displaying file names through a completion handler.

---

#### Create a New Google Spreadsheet

```swift
createNewSpreadsheet()
```

Creates a new, empty spreadsheet in the user’s Google Drive using the Google Sheets API. The spreadsheet’s name and ID are printed and returned via a completion handler.

---

#### Add a New Sheet to an Existing Spreadsheet

```swift
createNewSheet()
```

Adds a new tab (sheet) to an existing spreadsheet identified by a constant `Constants.sheetID`. This demonstrates how to send batch update requests to the Sheets API.

---

#### Download a Google Sheet as an Excel File

```swift
downloadLargeFile(file: GTLRDrive_File, destinationURL: URL)
```

Exports a Google Sheet to the `.xlsx` format and saves it to the local file system using a `destinationFileURL`. This uses `GTLRDriveQuery_FilesExport` for file export and `GTMSessionFetcher` for downloading.

---

#### Search and Download a Specific File by Name

```swift
getOneFile(search fileType: String)
performDownload() async throws -> URL
```

Combines search and download functionality:

- Searches for a file with a given name (e.g. `"Test Sheet"`) and type (e.g. `spreadsheet`)
- Downloads and saves it to the app’s local `Documents` directory as an `.xlsx` file
- Verifies file existence and size before completing

---

### Supported MIME Types

Here are some commonly used Google Drive MIME types you can query:

| File Type         | MIME Type                                  |
| ----------------- | ------------------------------------------ |
| Google Docs       | `application/vnd.google-apps.document`     |
| Google Sheets     | `application/vnd.google-apps.spreadsheet`  |
| Google Slides     | `application/vnd.google-apps.presentation` |
| Google Forms      | `application/vnd.google-apps.form`         |
| Google Drive File | `application/vnd.google-apps.file`         |
| Drive Folder      | `application/vnd.google-apps.folder`       |
| Google Drawing    | `application/vnd.google-apps.drawing`      |
| Video             | `application/vnd.google-apps.video`        |

Full list available in the [official Drive MIME Types documentation](https://developers.google.com/drive/api/v3/mime-types).

---

### Example Usage

```swift
let driveService = GoogleDriveService()

Task {
    do {
        let fileURL = try await driveService.performDownload()
        print("File downloaded to: \(fileURL.path)")
    } catch {
        print("Error downloading file: \(error.localizedDescription)")
    }
}
```

## Google Spreadsheets
- Google Spreadsheet examples can be found [here](https://github.com/mipar52/google-examples-swift/blob/feature/refactor/refactor/google-examples-swift/google-examples-swift/GoogleServices/GoogleDriveService.swift).
- The `GoogleSheetsService` provides a streamlined way to interact with the **Google Sheets API** from a SwiftUI-based iOS app. It uses modern Swift concurrency (`async/await`) and completion handlers to demonstrate how to append, write, read, and fetch spreadsheet data with ease.

---

### Authorization

Before performing any Sheets operations, the service retrieves the access token and authorizer from the signed-in Google user:

```swift
GIDSignIn.sharedInstance.currentUser?.fetcherAuthorizer
```

This ensures that all API requests are properly authenticated using OAuth 2.0.

---

### Methods that cen be found

#### Append Row to a Sheet

```swift
appendData(completionHandler: @escaping (String) -> Void)
```

Appends a new row of values to a specified range in a Google Sheet. Demonstrates how to send `GTLRSheetsQuery_SpreadsheetsValuesAppend` queries.

---

#### Send Data to a Specific Range

```swift
sendDataToCell(completionHandler: @escaping (String) -> Void)
```

Updates a specific range in the spreadsheet (e.g. `A5:B5`) with new values using the `GTLRSheetsQuery_SpreadsheetsValuesUpdate` query.

---

#### Read Cell Values from a Sheet

```swift
readData(completionHandler: @escaping (String) -> Void)
```

Reads cell values from a specified range (e.g. `A1:Q`) and prints the values row by row. Returns the row count and content through a completion handler.

---

#### Read All Sheets (Tabs) from a Spreadsheet

```swift
readSheets(completionHandler: @escaping (String) -> Void)
```

Fetches all the sheet titles (tabs) from a spreadsheet using the `GTLRSheetsQuery_SpreadsheetsGet` query. Useful for discovering available sheets programmatically.

---

### Example Usage

```swift
let sheetsService = GoogleSheetsService()

sheetsService.appendData { result in
    print(result)
}

sheetsService.readData { result in
    print(result)
}
```

---

## Google Calendar API
- Google Calendar examples can be found [here](https://github.com/mipar52/google-examples-swift/blob/feature/refactor/refactor/google-examples-swift/google-examples-swift/GoogleServices/GoogleDriveService.swift).

- The `GoogleCalendarService` simplifies working with the **Google Calendar API** in modern Swift/iOS apps using Swift concurrency and completion handlers. It enables users to authenticate, manage calendars, and handle events (create, list, update, delete) with clean and SwiftUI-compatible logic.

---

### Authorization

Before using any calendar functionality, this method sets up authenticated API access:

```swift
GIDSignIn.sharedInstance.currentUser?.fetcherAuthorizer
```

The access token and authorizer are set on the `GTLRCalendarService` instance, allowing authenticated requests on behalf of the user.

---

### Methods that can be found

#### Get Calendar Info

```swift
getPrimaryCalendarInfo()
```

Fetches metadata (name, time zone, etc.) for the primary Google Calendar defined in `Constants.calendarId`.

---

#### Get Subscribed Calendars

```swift
getSubscribedCalendars()
```

Retrieves a list of all calendars the signed-in user is subscribed to. Useful for listing multiple calendars the user has access to.

---

#### List Upcoming Events

```swift
listEvents()
```

Lists all events in the primary calendar from today until 24 hours later. Returns useful details including:

- Summary (title)
- Location
- Hangout/Meet link
- Attachments

---

#### Create a New Event

```swift
createEvent(userEmail:participantEmail:startDate:endDate:summary:recurrenceRule:completionHandler:)
```

Creates a new calendar event with:

- Custom start and end times
- Participants (attendees)
- Optional recurrence rule and location

Currently the event start and end are hardcoded to demonstrate the format; you can adjust this to match dynamic values.

---

#### Edit an Existing Event

```swift
editEvent(eventId:summary:completionHandler:)
```

Fetches the event by `eventId`, modifies its summary/title, and updates it in the user's calendar.

---

#### Delete an Event

```swift
deleteEvent(eventId:completionHandler:)
```

Deletes the specified event by ID from the user's calendar. Success is confirmed via a completion handler.

---

### Example Usage

```swift
let calendarService = GoogleCalendarService()

calendarService.getSubscribedCalendars { calendars in
    print(calendars ?? "No calendars found")
}

calendarService.listEvents { eventsInfo in
    print(eventsInfo ?? "No events found")
}
```

---

## YouTube API

- YouTube API examples can be found [here](https://github.com/mipar52/google-examples-swift/blob/feature/refactor/refactor/google-examples-swift/google-examples-swift/GoogleServices/GoogleDriveService.swift).

- The `YouTubeService` gives your SwiftUI app full access to interact with the **YouTube Data API v3**, including features such as video upload, metadata editing, comment handling, and playlist management.

Built with modern Swift and GoogleSignIn, this service demonstrates how to access and manipulate YouTube resources using authenticated REST API calls.

---

### Authorization

Before making API requests, authorize the user and attach their access token to the service:

```swift
GIDSignIn.sharedInstance.currentUser?.fetcherAuthorizer
```

This sets up `GTLRYouTubeService` for authenticated access.

---

### Methods that can be found

#### Search Videos
```swift
getSearchList(completionHandler: @escaping (String?) -> Void)
```
Executes a basic search query and prints out video/channel results.

---

#### List Playlist Videos
```swift
getPlaylistVideos(completionHandler: @escaping (String?) -> Void)
```
Retrieves videos from a playlist using `Constants.youTubePlaylistId`. Useful for building playlist viewers.

---

#### Get Channel Info/Videos
```swift
getChannelList(completionHandler: @escaping (String?) -> Void)
```
Fetches metadata like the channel title and liked playlists.

---

#### Upload a Video
```swift
uploadVideoFile(locationURL: URL, completionHandler: @escaping (String) -> Void)
```
Uploads a video file from a given local `URL`. Sets title, tags, category, and privacy options.

---

#### Update Existing Video Metadata
```swift
updateVideo(completionHandler: @escaping (String) -> Void)
```
Updates the title, description, and tags of an already uploaded video.

---

#### Delete a Video
```swift
deleteVideo(completionHandler: @escaping (String) -> Void)
```
Deletes a video by ID.

---

### Comments & Threads

#### Get Top-Level Comments (threads)
```swift
getAllCommentFromVideo(completionHandler: @escaping (String) -> Void)
```
Lists all top-level comments (threads) from a video. Useful for moderation tools or displaying discussion.

---

#### Get Replies to a Comment Thread
```swift
getAllCommentRepliesFromThread(completionHandler: @escaping (String) -> Void)
```
Given a top-level comment ID, fetches all replies (threaded comments).

---

#### Insert a Comment
```swift
insertComment(completionHandler: @escaping (String) -> Void)
```
Posts a new comment to a specified video. ⚠️ Real comment will appear on YouTube!

---

### Example Usage

```swift
let ytService = YouTubeService()

ytService.getSearchList { result in
    print(result ?? "No results")
}

ytService.uploadVideoFile(locationURL: someURL) { status in
    print(status)
}
```

---

### Run the project 

    1. Make sure you're you've registered your project on Firebase and Google developers console

    2. Add the wanted scopes regarding each REST API in the Google developer console

    3. Add the GoogleService-Info.plist to your Xcode project
    
    4. In the GoogleService-Info.plist file, copy the REVERSED_CLIENT_ID and go to project TARGETS > Info > URL Types and add the reversed ID in the URL Schemes
    
    5. Run command  `pod install` when positioned yourself in the project's directory in Terminal
