//
//  ViewController.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 07.02.2021..
//

import UIKit
import GoogleSignIn
import GTMSessionFetcher
import GoogleAPIClientForREST

class ViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheets, kGTLRAuthScopeSheetsDrive]
    private let driveScopes = [kGTLRAuthScopeSheetsDrive]
    private let service = GTLRSheetsService()
    private let driveService = GTLRDriveService()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance()?.signIn()

        // Do any additional setup after loading the view.
    }

    @IBAction func signInPressed(_ sender: UIButton) {
        
        print("Sign in pressed")
        
        if self.service.authorizer == nil{
        GIDSignIn.sharedInstance()?.signIn()
    
        print("signing in....")
        }

        if (self.service.authorizer != nil) {
            GIDSignIn.sharedInstance()?.signOut()
            self.service.authorizer = nil
            
            sender.setTitle("Sign in", for: UIControl.State.normal)
            print("signing out....")
        }
    }
    
}

extension ViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            self.service.authorizer = nil
            self.driveService.authorizer = nil
            print(error)
        } else {
            self.driveService.authorizer = user.authentication.fetcherAuthorizer()
            self.service.authorizer = user.authentication.fetcherAuthorizer()

            signInButton.setTitle("Sign out", for: UIControl.State.normal)
            signInButton.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: UIControl.State.normal)
            let userName = user.profile.givenName
            print("Hello \(String(describing: userName))!")

            }
        }
}

