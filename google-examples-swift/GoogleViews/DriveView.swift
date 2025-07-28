//
//  DriveView.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 27.07.2025..
//

import SwiftUI

struct DriveView: View {
    private let driveService = GoogleDriveService()
    
    @State private var presentAlert: Bool = false
    @State private var alertMessage: String = ""
        
    var body: some View {
        VStack (spacing: 15) {
            
            Button {
                driveService.createNewSpreadsheet { successMessage in
                    alertMessage = successMessage
                    presentAlert.toggle()
                }
            } label: {
                Text("Create new Spreadsheet")
            }
            
            Button {
                driveService.createNewSheet { successMessage in
                    alertMessage = successMessage
                    presentAlert.toggle()
                }
            } label: {
                Text("Create new Sheet in Spreadsheet")
            }
            
            Button {
                driveService.readFiles(search: "document") { successMessage in
                    alertMessage = successMessage
                    presentAlert.toggle()
                }
            } label: {
                Text("Get all Google Docs from Google Drive")
            }
            
            Button {
                driveService.readFiles(search: "spreadsheet") { successMessage in
                    alertMessage = successMessage
                    presentAlert.toggle()
                }
            } label: {
                Text("Get all Google Spreadsheets from Google Drive")
            }
            
            Button {
                Task {
                    do {
                        let url = try await driveService.performDownload()
                        alertMessage = "Downloaded the file to the Files folder! Exact URL: \(url.absoluteString)"
                        presentAlert.toggle()
                    } catch {
                        alertMessage = "Download failed: \(error.localizedDescription)"
                        presentAlert = true
                    }
                }
            } label: {
                Text("Download a file from Google Drive")
            }

        }
        .onAppear {
            driveService.fetchAuthorization()
        }
        .alert("Google Drive API result",
               isPresented: $presentAlert,
               actions: {},
               message: {
                    Text(alertMessage)
                })
    }
}

#Preview {
    DriveView()
}
