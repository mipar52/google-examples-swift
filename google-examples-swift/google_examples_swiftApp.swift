//
//  google_examples_swiftApp.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 26.07.2025..
//

import SwiftUI
import GoogleSignIn

@main
struct google_examples_swiftApp: App {
    var body: some Scene {
        WindowGroup {
            GoogleSignInView()
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        print("User: \(String(describing: user?.description))")
                        print("Restore error: \(error?.localizedDescription)")
                        // Check if `user` exists; otherwise, do something with `error`
                    }
                }
                .onOpenURL { url in
                  GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
