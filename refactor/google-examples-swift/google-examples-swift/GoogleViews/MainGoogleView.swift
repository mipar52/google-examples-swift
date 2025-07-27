//
//  MainGoogleView.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 26.07.2025..
//

import SwiftUI

struct MainGoogleView: View {
    var body: some View {
        NavigationLink {
            SpreadsheetView()
        } label: {
            Text("Google Spreadsheets")
        }

    }
}

#Preview {
    MainGoogleView()
}
