//
//  DriveController.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 07.02.2021..
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class DriveController: UIViewController {
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
    
    @IBAction func createNewSpreadPressed(_ sender: UIButton) {
        createNewSpread { (string) in
            self.utils.showAlert(title: "", message: string, vc: self)
        }
    }
    
    @IBAction func createNewSheetPressed(_ sender: UIButton) {
        createNewSheet { (string) in
            self.utils.showAlert(title: "", message: string, vc: self)
        }
        
    }
    
    @IBAction func readSpreadsPressed(_ sender: UIButton) {
        readSpreadsheet { (string) in
            self.utils.showAlert(title: "", message: string, vc: self)
        }
    }
}

extension DriveController {
    
    func readSpreadsheet (completionHandler: @escaping (String) -> Void) {
        
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "mimeType='application/vnd.google-apps.spreadsheet' and trashed=false"
        //mimeType='application/vnd.google-apps.spreadsheet'  mimeType='application/vnd.google-apps.folder'
//List of all files you can get from Google Drive (spreadsheets is currently selected)
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
                
                if let items = listFiles {
                    for item in items {
                        let name : String = item.name!
                        let id: String = item.identifier!
                        print(item)
                        print("Found a file: \(name), \(id)")
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
    
    func createNewSpread(completionHandler: @escaping (String) -> Void) {
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

                        completionHandler("Success!")
                      }
                  }
                sheetService.executeQuery(query, completionHandler: nil)
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

        let createQuery = GTLRSheetsQuery_SpreadsheetsBatchUpdate.query(withObject: batchUpdate, spreadsheetId: K.sheetID)

        sheetService.executeQuery(createQuery) { (ticket, result, err) in
            if let error = err {
                print(error)
                completionHandler("Error with creating sheet:\(error.localizedDescription)")
            } else {
                completionHandler("Success!")
                //newSheet.sheetId =
                print("Sheet added!")
            }
        }
    }
}
