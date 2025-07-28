//
//  GoogleSheetsService.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 27.07.2025..
//

import GoogleAPIClientForREST_Sheets
import GoogleAPIClientForREST_Drive
import GoogleSignIn
import GTMAppAuth

struct GoogleSheetsService {
    private var sheetsService = GTLRSheetsService()
    
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
            
            // Or, get an object that conforms to GTMFetcherAuthorizationProtocol for
            // use with GTMAppAuth and the Google APIs client library.
            let authorizer = user.fetcherAuthorizer
            self.sheetsService.authorizer = authorizer
        }
    }
    
    func appendData(completionHandler: @escaping (String) -> Void) {

        let spreadsheetId = Constants.sheetID
        let range = "A1:Q"
        let rangeToAppend = GTLRSheets_ValueRange.init();
        let data = ["Hello", "From", "My", "App"]
        
        rangeToAppend.values = [data]
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: rangeToAppend, spreadsheetId: spreadsheetId, range: range)
            query.valueInputOption = "USER_ENTERED"
        
        sheetsService.executeQuery(query) { (ticket, result, error) in
                if let error = error {
                    print("Error in appending data: \(error)")
                    completionHandler("Error in sending data:\n\(error.localizedDescription)")
                } else {
                    print("Data sent: \(data)")
                    completionHandler("Success! Sent data: \(data)")
                }
            }
        }

    func sendDataToCell(completionHandler: @escaping (String) -> Void) {
            
            let spreadsheetId = Constants.sheetID
            let currentRange = "A5:B5" //Any range on the sheet, for instance: A5:B6
            let results = ["Hello, from the app!"]
            let rangeToAppend = GTLRSheets_ValueRange.init();
                rangeToAppend.values = [results]
        
            let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: rangeToAppend, spreadsheetId: spreadsheetId, range: currentRange)
                query.valueInputOption = "USER_ENTERED"
        
            sheetsService.executeQuery(query) { (ticket, result, error) in
                    if let error = error {
                        print(error)
                        completionHandler("Error in sending data:\n\(error.localizedDescription)")
                    } else {
                        print("Sending: \(results)")
                        completionHandler("Sucess! Sent: \(results)")
                    }
                }
    }
    
    func readData(completionHandler: @escaping (String) -> Void) {
        let spreadsheetId = Constants.sheetID
        let range = "A1:Q"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)

        sheetsService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print(error)
                completionHandler("Failed to read data:\(error.localizedDescription)")
                return
            }
            guard let result = result as? GTLRSheets_ValueRange else {
                return
            }
            
            let rows = result.values!
            var stringRows = rows as! [[String]]
            
            for row in stringRows {
                stringRows.append(row)
                print(row)
                }
            if rows.isEmpty {
                print("No data found.")
                return
            }
            completionHandler("Success! Found \(rows.count) rows\nData found: \(stringRows)")
            print("Number of rows in sheet: \(rows.count)")
        }
    }
    
    func readSheets(completionHandler: @escaping (String) -> Void ) {
        
        let spreadsheetId = Constants.sheetID
        let query = GTLRSheetsQuery_SpreadsheetsGet.query(withSpreadsheetId: spreadsheetId)
        
        sheetsService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print(error)
                completionHandler("Error in loading sheets\n\(error.localizedDescription)")
            } else {
                let result = result as? GTLRSheets_Spreadsheet
                let sheets = result?.sheets
                var titles = String()
                
                if let sheetInfo = sheets {
                    for info in sheetInfo {
                        if let sheetTitle = info.properties?.title {
                            titles += "\(sheetTitle)\n"
                            print("New sheet found: \(sheetTitle)")
                        }
                        }
                    }
                completionHandler("Success! Found sheets:\n\(titles)")
            }
        }
    }
}
