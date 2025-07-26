//
//  ContentView.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 26.07.2025..
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import SafariServices

struct ContentView: View {
    @State var isSignedIn: Bool = false
    var body: some View {
        VStack(spacing: 15) {
            Text("Welcome to Google Examples Swift!")
            
            if !isSignedIn {
                GoogleSignInButton(action: handleSignInButton)
                .frame(width: 50, height: 50)
            }
            
            if isSignedIn {
                Text("Signed in!")
                Button {
                    
                } label: {
                    Text("Proceed to Google Examples")
                }
                
                Button {
                    GIDSignIn.sharedInstance.signOut()
                    isSignedIn.toggle()
                } label: {
                    Text("Sign out")
                }
            }
        }
        .padding()
    }
    func handleSignInButton() {
        guard let rootViewController = Utilities.getTopViewController() else {
            return
        }
        
      GIDSignIn.sharedInstance.signIn(
        withPresenting: rootViewController) { signInResult, error in
          guard let result = signInResult else {
            return
          }
            
            print(result.user.profile?.email)
            isSignedIn.toggle()
        }
    }
}

#Preview {
    ContentView()
}
