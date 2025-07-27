//
//  GoogleSignInView.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 28.07.2025..
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInView: View {
    @State var isSignedIn: Bool = false
    @State var user: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                if !isSignedIn {
                    Text("Welcome to Google Examples Swift!\nTo sign in, tap the button below. Signing in will give you access to other Google services.")
                        .multilineTextAlignment(.center)
                    
                    // handle sign in and ask the user to additionally grant the scopes for
                    // other Google services, like the Drive, Sheets, YouTube, etc.
                    GoogleSignInButton(action: {
                        GoogleSignInService.handleSignInWithAdditionalScopes(getRootVC()!) { result, error in
                            // handle result and error here
                            if let error = error {
                                print("Error: \(error)")
                            } else if let result = result {
                                user = result.user.profile?.name ?? "Unknown"
                                isSignedIn.toggle()
                            }
                        }
                    })
                    .frame(width: 50, height: 50)
                    
                    // for doing the flow sign in + request additional scopes later
                    // check the GoogleSingInSetvice, method handleSignIn & requestAdditionalScopes
                    /**
                     GoogleSignInButton(action:  {
                         GoogleSignInService.handleSignIn(getRootVC()!) { result, error in
                             // handle result and error here
                             if let error = error {
                                 print("Error: \(error)")
                             } else if let result = result {
                                 user = result.user.profile?.name ?? "Unknown"
                                 isSignedIn.toggle()
                             }
                         }
                     })
                     .frame(width: 50, height: 50)
                     */
                }
                
                if isSignedIn {
                    Text("Hello \(user)! You've successfully signed in!\nFeel free to proceed to the examples")
                        .multilineTextAlignment(.center)
                    Text("")
                    NavigationLink {
                        MainGoogleView()
                    } label: {
                        Text("Proceed to Google Examples")
                    }
                    
                    Button {
                        GoogleSignInService.signOut()
                        isSignedIn.toggle()
                    } label: {
                        Text("Sign out")
                    }
                    .foregroundStyle(.red)
                }
            }
            .padding()
        }
    }
    
    private func getRootVC() -> UIViewController? {
        guard let rootVC = Utilities.getTopViewController() else {
            return nil
        }
        return rootVC
    }
}

#Preview {
    GoogleSignInView()
}
