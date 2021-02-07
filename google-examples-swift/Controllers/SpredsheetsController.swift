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
    let scopes = [kGTLRAuthScopeSheetsSpreadsheets, kGTLRAuthScopeSheetsDrive]
    let service = GTLRSheetsService()
    let driveService = GTLRDriveService()

    
    let sheetID = "1Nm9NvZ0TOa_ifFTo7YSn1EG3eVg1O32m7QrsVeorMQQ"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
extension SpredsheetsController: GIDSignInDelegate {
    //MARK: Spreadsheets methods
    func appendData(completionHandler: @escaping (String) -> Void) {
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance()?.signInSilently()
        
        let spreadsheetId = sheetID
        let range = "A1:Q"
        let rangeToAppend = GTLRSheets_ValueRange.init();
        let data = ["this", "is","a","test"]
        
        rangeToAppend.values = [data]
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: rangeToAppend, spreadsheetId: spreadsheetId, range: range)

            query.valueInputOption = "USER_ENTERED"

            service.executeQuery(query) { (ticket, result, error) in

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
            
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().scopes = scopes
            GIDSignIn.sharedInstance()?.signInSilently()
            
            let spreadsheetId = sheetID
            //Any range on the sheet.
            //for instance: A5:B6
            let currentRange = "A5:B5"
            let results = ["this is a test"]
            
            let rangeToAppend = GTLRSheets_ValueRange.init();
                rangeToAppend.values = [results]
            let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: rangeToAppend, spreadsheetId: spreadsheetId, range: currentRange)

                query.valueInputOption = "USER_ENTERED"

                service.executeQuery(query) { (ticket, result, error) in

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
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance()?.signInSilently()
        
        let spreadsheetId = sheetID
        let range = "A1:Q"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        
        service.executeQuery(query) { [self] (ticket, result, error) in
            
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
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance()?.signInSilently()
        
        
        let spreadsheetId = sheetID
        let query = GTLRSheetsQuery_SpreadsheetsGet.query(withSpreadsheetId: spreadsheetId)
        
        service.executeQuery(query) { (ticket, result, error) in
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
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                  withError error: Error!) {
            if let error = error {
                print("Error: \(error)")
                self.service.authorizer = nil
                self.driveService.authorizer = nil

            } else {
                self.service.authorizer = user.authentication.fetcherAuthorizer()
                self.driveService.authorizer = user.authentication.fetcherAuthorizer()
            }
        }
}
