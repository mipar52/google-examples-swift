//
//  GoogleDriveService.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 27.07.2025..
//

import Foundation
import GoogleAPIClientForREST_Drive
import GoogleAPIClientForREST_Sheets
import GoogleSignIn

// Test spreadsheet:
// https://docs.google.com/spreadsheets/d/1Nm9NvZ0TOa_ifFTo7YSn1EG3eVg1O32m7QrsVeorMQQ/edit?usp=sharing

struct GoogleDriveService {
    private let driveService = GTLRDriveService()
    private let sheetsService = GTLRSheetsService()
    
    func fetchAuthorization() {
        guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
            print("No current user")
            return
        }

        currentUser.refreshTokensIfNeeded { user, error in
            guard error == nil else { return }
            guard let user = user else { return }

            // Get the access token to attach it to a REST or gRPC request.
            let accessToken = user.accessToken.tokenString
            self.sheetsService.additionalHTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
            self.driveService.additionalHTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
            
            // Or, get an object that conforms to GTMFetcherAuthorizationProtocol for
            // use with GTMAppAuth and the Google APIs client library.
            let authorizer = user.fetcherAuthorizer
            self.sheetsService.authorizer = authorizer
            self.driveService.authorizer = authorizer
        }
    }
    
    func readFiles(search fileType: String, completionHandler: @escaping (String) -> Void) {
        
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "mimeType='application/vnd.google-apps.\(fileType)' and trashed=false"
        //mimeType='application/vnd.google-apps.spreadsheet'  mimeType='application/vnd.google-apps.folder'
        //List of all files you can get from Google Drive
        //        application/vnd.google-apps.audio
        //        application/vnd.google-apps.document     Google Docs
        //        application/vnd.google-apps.drive-sdk    3rd party shortcut
        //        application/vnd.google-apps.drawing      Google Drawing
        //        application/vnd.google-apps.file         Google Drive file
        //        application/vnd.google-apps.folder       Google Drive folder
        //        application/vnd.google-apps.form         Google Forms
        //        application/vnd.google-apps.fusiontable  Google Fusion Tables
        //        application/vnd.google-apps.map          Google My Maps
        //        application/vnd.google-apps.photo
        //        application/vnd.google-apps.presentation Google Slides
        //        application/vnd.google-apps.script       Google Apps Scripts
        //        application/vnd.google-apps.shortcut     Shortcut
        //        application/vnd.google-apps.site         Google Sites
        //        application/vnd.google-apps.spreadsheet  Google Sheets
        //        application/vnd.google-apps.unknown
        //        application/vnd.google-apps.video
        //More info here: https://developers.google.com/drive/api/v3/mime-types
        
        driveService.executeQuery(query, completionHandler: { ticket, files, error in
            if error == nil {
                let list = files as! GTLRDrive_FileList
                let listFiles = list.files
                var fileName = String()
                if let items = listFiles {
                    for item in items {
                        let name : String = item.name!
                      //  let id: String = item.identifier!
                        print("Found item: \(item)\n")
                        fileName += "Found a file: \(name)\n"
                        completionHandler("Found spreadsheets:\n\(fileName)")
                    }
                }
            } else {
                if let error = error {
                    print("Error: \(error)")
                    completionHandler("Error with reading files:\n\(error.localizedDescription)")
                }
            }
        })
    }
    
    func createNewSpreadsheet(completionHandler: @escaping (String) -> Void) {
        print("Creating New Sheet ...\n")
        
        let newSheet = GTLRSheets_Spreadsheet.init()
        let properties = GTLRSheets_SpreadsheetProperties.init()
        properties.title = "New testing spread"
        newSheet.properties = properties
        
        let query = GTLRSheetsQuery_SpreadsheetsCreate.query(withObject:newSheet)
        query.fields = "spreadsheetId"
        
        query.completionBlock = { (ticket, result, error) in
            // let sheet = result as? GTLRSheets_Spreadsheet
            if let error = error {
                completionHandler("Error:\n\(error.localizedDescription)")
                print("Error in creating the Sheet: \(error)")
                return
                
            }
            else {
                let response = result as! GTLRSheets_Spreadsheet
                let identifier = response.spreadsheetId
                print("Spreadsheet id: \(String(describing: identifier))")
                
                completionHandler("Success!\nCreated a new Spreadsheet with name: \(String(describing: properties.title)) and ID: \(String(describing: identifier))")
            }
        }
        sheetsService.executeQuery(query, completionHandler: nil)
    }
    
    func createNewSheet(completionHandler: @escaping (String) -> Void) {
        
        let batchUpdate = GTLRSheets_BatchUpdateSpreadsheetRequest.init()
        let request = GTLRSheets_Request.init()
        
        let properties = GTLRSheets_SheetProperties.init()
        properties.title = "New testing sheet"
        
        let sheetRequest = GTLRSheets_AddSheetRequest.init()
        sheetRequest.properties = properties
        
        request.addSheet = sheetRequest
        
        batchUpdate.requests = [request]
        
        let createQuery = GTLRSheetsQuery_SpreadsheetsBatchUpdate.query(withObject: batchUpdate, spreadsheetId: Constants.sheetID)
        
        sheetsService.executeQuery(createQuery) { (ticket, result, err) in
            if let error = err {
                print(error)
                completionHandler("Error with creating sheet:\(error.localizedDescription)")
            } else {
                completionHandler("Success! Added new sheet!")
                print("Sheet added!")
            }
        }
    }
    
    func downloadLargeFile(file: GTLRDrive_File, destinationURL: URL) async throws {
        guard let fileId = file.identifier else {
            print("Missing file ID.")
            return
        }
        print("fileID: \(fileId)")
        let exportMimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" // Excel
        let query = GTLRDriveQuery_FilesExport.queryForMedia(withFileId: fileId, mimeType: exportMimeType)

        // Get NSURLRequest from the query
        let downloadRequest = await driveService.request(for: query)

        // Create a fetcher using the GTLR service's fetcherService (which has the authorizer set)
        let fetcher = driveService.fetcherService.fetcher(with: downloadRequest as URLRequest)
        fetcher.comment = "Downloading \(file.name ?? "Unknown file")"
        fetcher.destinationFileURL = destinationURL

        try await fetcher.beginFetch()
      
        print("Download succeeded to \(destinationURL.path)")
    }
    
    // Support methods for downloading a file from Google Drive
    func getOneFile(search fileType: String) async throws -> GTLRDrive_File? {
        try await withCheckedThrowingContinuation { continuation in
            let query = GTLRDriveQuery_FilesList.query()
            query.q =
           """
            mimeType='application/vnd.google-apps.\(fileType)' and
            trashed=false and
            name='Test Sheet'
           """
            
            driveService.executeQuery(query) { ticket, files, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let list = files as? GTLRDrive_FileList {
                    
                    continuation.resume(returning: list.files?.first)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func performDownload() async throws -> URL {
        if let file = try await getOneFile(search: "spreadsheet") {
            let fileUrl =  try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            let destinationURL = fileUrl.appendingPathComponent("\(file.name!).\(file.fullFileExtension ?? "xlsx")")
            
            if FileManager().fileExists(atPath: destinationURL.path) {
                try FileManager().removeItem(at: destinationURL)
            }
            
            try await downloadLargeFile(file: file, destinationURL: destinationURL)

            if !FileManager.default.fileExists(atPath: destinationURL.path) {
                throw NSError(domain: "Download", code: 4, userInfo: [NSLocalizedDescriptionKey: "File not found"])
            }

            let fileSize = try destinationURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            if fileSize == 0 {
                throw NSError(domain: "Download", code: 3, userInfo: [NSLocalizedDescriptionKey: "Downloaded file is empty"])
            }

            return destinationURL
        } else {
            throw NSError(domain: "Download", code: 2, userInfo: [NSLocalizedDescriptionKey: "No file found in Drive"])
        }
    }

}
