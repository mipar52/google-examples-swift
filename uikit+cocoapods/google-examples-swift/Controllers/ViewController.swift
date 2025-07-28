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
                GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, signInError in
                    if signInError == nil {
                        if let user = signInResult?.user {
                            self.requestScopes(googleUser: user) { signInSuccess in
                                if signInSuccess == true {
                                    completionHandler(true)
                                } else {
                                    completionHandler(false)
                                }
                            }
                        }
                    } else {
                        print("error with signing in: \(String(describing: signInError)) ")
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
            googleUser.addScopes(additionalScopes, presenting: self) { signInResult, signInError in
                guard signInError == nil else { completionHandler(false); return }
                guard let signInResult = signInResult else {completionHandler(false); return }
                print(signInResult.description)
                // Check if the user granted access to the scopes you requested.
                completionHandler(true)
            }
        } else {
            print("Already contains the scopes!")
            completionHandler(true)
        }
    }
}
