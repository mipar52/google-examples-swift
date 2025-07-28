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
    
    private let service = GTLRSheetsService()
    private let driveService = GTLRDriveService()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleSignIn { signInStatus in
            if signInStatus == true {
                self.signInButton.setTitle("Sign out", for: .normal)
                print("Signed in!")
            } else {
                self.signInButton.setTitle("Sign in", for: .normal)
                print("Issues with signing in...")
            }
        }
    }
    
    @IBAction func signInPressed(_ sender: UIButton) {
        
        print("Sign in pressed")
        
        let user = GIDSignIn.sharedInstance.currentUser
        if (user == nil) {
            googleSignIn() { success in
                if success == true {
                    sender.setTitle("Sign out", for: UIControl.State.normal)
                } else {
                    return
                }
            }
           } else {
               GIDSignIn.sharedInstance.signOut()
               self.service.authorizer = nil
               sender.setTitle("Sign in", for: UIControl.State.normal)
           }
        }
    }

extension ViewController {
    func googleSignIn(completionHandler: @escaping (Bool) -> Void) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error == nil {
                print("Managed to restore previous sign in!\nScopes: \(String(describing: user?.grantedScopes))")
                
                self.requestScopes(googleUser: user!) { success in
                    if success == true {
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                }
            } else {
                print("No previous user!\nThis is the error: \(String(describing: error?.localizedDescription))")
                let signInConfig = GIDConfiguration.init(clientID: K.clientID)
                GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { gUser, signInError in
                    if signInError == nil {
                        self.requestScopes(googleUser: gUser!) { signInSuccess in
                            if signInSuccess == true {
                                completionHandler(true)
                            } else {
                                completionHandler(false)
                            }
                        }
                    } else {
                        print("error with signing in: \(String(describing: signInError)) ")
                      self.service.authorizer = nil
                        completionHandler(false)
                    }
                }
            }
        }
    }
    
    func requestScopes(googleUser: GIDGoogleUser, completionHandler: @escaping (Bool) -> Void) {
        
        let grantedScopes = googleUser.grantedScopes
        if grantedScopes == nil || !grantedScopes!.contains(K.grantedScopes) {
            let additionalScopes = K.additionalScopes
            
            GIDSignIn.sharedInstance.addScopes(additionalScopes, presenting: self) { user, scopeError in
                if scopeError == nil {
                    user?.authentication.do { authentication, err in
                        if err == nil {
                            guard let authentication = authentication else { return }
                            // Get the access token to attach it to a REST or gRPC request.
                           // let accessToken = authentication.accessToken
                            let authorizer = authentication.fetcherAuthorizer()
                            self.service.authorizer = authorizer
                            completionHandler(true)
                        } else {
                            print("Error with auth: \(String(describing: err?.localizedDescription))")
                            completionHandler(false)
                        }
                    }
                } else {
                    completionHandler(false)
                    print("Error with adding scopes: \(String(describing: scopeError?.localizedDescription))")
                }
            }
        } else {
            print("Already contains the scopes!")
            completionHandler(true)
        }
    }
}
