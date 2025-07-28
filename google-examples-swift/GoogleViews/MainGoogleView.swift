//
//  MainGoogleView.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 26.07.2025..
//

import SwiftUI

struct MainGoogleView: View {
    var body: some View {
        VStack(spacing: 20) {
            NavigationLink {
                SpreadsheetView()
            } label: {
                Text("Google Spreadsheets")
            }
            NavigationLink {
                DriveView()
            } label: {
                Text("Google Drive")
            }
            NavigationLink {
                CalendarView()
            } label: {
                Text("Google Calendar")
            }
            NavigationLink {
                YouTubeView()
            } label: {
                Text("YouTube Services")
            }
        }
    }
}

#Preview {
    MainGoogleView()
}
