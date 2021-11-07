//
//  SpredsheetsController.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 07.02.2021..
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class SpredsheetsController: UIViewController {
    
    //Test spreadsheet: https://docs.google.com/spreadsheets/d/1Nm9NvZ0TOa_ifFTo7YSn1EG3eVg1O32m7QrsVeorMQQ/edit?usp=sharing
    let utils = Utils()
    let sheetService = GTLRSheetsService()
    let driveService = GTLRDriveService()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        sheetService.apiKey = K.apiKey
        sheetService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
        
        driveService.apiKey = K.apiKey
        driveService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
    }

    @IBAction func appendDataPressed(_ sender: UIButton) {
        appendData { (string) in
            self.utils.showAlert(title: "", message: string, vc: self)
        }
    }
    
    @IBAction func specificCellPressed(_ sender: UIButton) {
        sendDataToCell { (string) in
            self.utils.showAlert(title: "", message: string, vc: self)
        }
    }
    
    @IBAction func readDataPressed(_ sender: UIButton) {
        readData { (string) in
            self.utils.showAlert(title: "", message: string, vc: self)
        }
    }
    
    @IBAction func readSheetsPressed(_ sender: Any) {
        readSheets { (string) in
            self.utils.showAlert(title: "", message: string, vc: self)
        }
    }
}

extension SpredsheetsController {
    //MARK: Spreadsheets methods
    func appendData(completionHandler: @escaping (String) -> Void) {

        let spreadsheetId = K.sheetID
        let range = "A1:Q"
        let rangeToAppend = GTLRSheets_ValueRange.init();
        let data = ["this", "is","a","test"]
        
        rangeToAppend.values = [data]
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: rangeToAppend, spreadsheetId: spreadsheetId, range: range)
            query.valueInputOption = "USER_ENTERED"
        
            sheetService.executeQuery(query) { (ticket, result, error) in
                if let error = error {
                    print("Error in appending data: \(error)")
                    completionHandler("Error in sending data:\n\(error.localizedDescription)")
                } else {
                    print("Data sent: \(data)")
                    completionHandler("Success!")
                }
            }
        }
    
    func sendDataToCell(completionHandler: @escaping (String) -> Void) {
            
            let spreadsheetId = K.sheetID
            let currentRange = "A5:B5" //Any range on the sheet, for instance: A5:B6
            let results = ["this is a test"]
            let rangeToAppend = GTLRSheets_ValueRange.init();
                rangeToAppend.values = [results]
        
            let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: rangeToAppend, spreadsheetId: spreadsheetId, range: currentRange)
                query.valueInputOption = "USER_ENTERED"
        
                sheetService.executeQuery(query) { (ticket, result, error) in
                    if let error = error {
                        print(error)
                        completionHandler("Error in sending data:\n\(error.localizedDescription)")
                    } else {
                        print("Sending: \(results)")
                        completionHandler("Sucess!")
                    }
                }
    }
    func readData(completionHandler: @escaping (String) -> Void) {
        print("Getting sheet data...")
        
        let spreadsheetId = K.sheetID
        let range = "A1:Q"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        
        sheetService.executeQuery(query) { (ticket, result, error) in
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
            completionHandler("Success!")
            print("Number of rows in sheet: \(rows.count)")
        }
    }
    
    func readSheets(completionHandler: @escaping (String) -> Void ) {
        print("func findSpreadNameAndSheets executing...")
        
        let spreadsheetId = K.sheetID
        let query = GTLRSheetsQuery_SpreadsheetsGet.query(withSpreadsheetId: spreadsheetId)
        
        sheetService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print(error)
                completionHandler("Error in loading sheets\n\(error.localizedDescription)")
            } else {
                let result = result as? GTLRSheets_Spreadsheet
                let sheets = result?.sheets
                if let sheetInfo = sheets {
                    for info in sheetInfo {
                            print("New sheet found: \(String(describing: info.properties?.title))")
                        }
                    }
                completionHandler("Success!")
            }
        }
    }
}
