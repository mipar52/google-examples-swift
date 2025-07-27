//
//  GoogleSignInService.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 27.07.2025..
//

import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInService {
    // handle GoogleSignIn and ask for scopes during the sign in
    static func handleSignInWithAdditionalScopes(
        _ rootVc: UIViewController,
        completion: @escaping (GIDSignInResult?, Error?) -> Void) {
        GIDSignIn.sharedInstance.signIn(
            withPresenting: rootVc,
            hint: "Some hint",
            additionalScopes: Constants.additionalScopes) { signInResult, googleSignInError in
            completion(signInResult, googleSignInError)
        }
    }
    // handle GoogleSignIn
    // if scopes are not neccessary at the moment (if you only need, for example, user's credentials)
    static func handleSignIn(
        _ rootVC: UIViewController,
        completion: @escaping (GIDSignInResult?, Error?) -> Void) {
        
      GIDSignIn.sharedInstance.signIn(
        withPresenting: rootVC) { signInResult, error in
          guard let result = signInResult else {
            return
          }
            // if you do not need the additional scopes, ignore this part
            // request additional scopes, based on the APIs you are planning to use
            // check the Constants file to see the scopes
            guard let grantedScopes = result.user.grantedScopes else {
                return
            }
            
            if !grantedScopes.contains(Constants.additionalScopes) {
                requestAdditionalScopes(result.user, rootVC) { additionalScopeResult, error in
                    completion(additionalScopeResult, error)
                }
            }
        }
    }
    
    // request additional scopes, based on the APIs you are planning to use
    // check the Constants file to see the scopes
    // this can be asked after the sign in process
    static func requestAdditionalScopes(
        _ user: GIDGoogleUser,
        _ rootVc: UIViewController,
        completion: @escaping (GIDSignInResult?, Error?) -> Void) {
        guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
            return ;  // -> not signed in
        }

        currentUser.addScopes(
            Constants.additionalScopes,
            presenting: rootVc) { signInResult, error in
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }
            
            print(signInResult.user.grantedScopes)
            // Check if the user granted access to the scopes you requested.
            completion(signInResult, error)
        }
    }
    
    static func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
}
