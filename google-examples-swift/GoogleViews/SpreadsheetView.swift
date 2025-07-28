//
//  SpreadsheetView.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 26.07.2025..
//

import SwiftUI

struct SpreadsheetView: View {
    private let sheetsService = GoogleSheetsService()
    @State private var presentAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        
        VStack(spacing: 20) {
            Button {
                sheetsService.readData { successString in
                    presentAlert.toggle()
                    alertMessage = successString
                }
            } label: {
                Text("Read data from Sheet")
            }
            Button {
                
                sheetsService.readSheets { successString in
                    presentAlert.toggle()
                    alertMessage = successString
                }
            } label: {
                Text("Get Sheets from Spreadsheet")
            }
            Button {
                
                sheetsService.appendData { successString in
                    presentAlert.toggle()
                    alertMessage = successString
                }
            } label: {
                Text("Append data to Sheet")
            }
            Button {
                
                sheetsService.sendDataToCell { successString in
                    presentAlert.toggle()
                    alertMessage = successString
                }
            } label: {
                Text("Send data to cell in Sheet")
            }
        }
        .onAppear {
            sheetsService.fetchAuthorization()
        }
        .alert("Google Sheets API result",
               isPresented: $presentAlert,
               actions: {},
               message: {
                    Text(alertMessage)
                })
    }
}

#Preview {
    SpreadsheetView()
}
