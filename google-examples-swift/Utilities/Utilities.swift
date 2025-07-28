//
//  Utilities.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 26.07.2025..
//

import Foundation
import UIKit
import MobileCoreServices

/// Various utilites for making the API calling easier
struct Utilities {
    static func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared
            .connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .first as? UIWindowScene,
            
            let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }

        var topController = keyWindow.rootViewController

        while let presented = topController?.presentedViewController {
            topController = presented
        }

        return topController
    }
    
    //Helper method for getting the apps Bundle ID
    static func getBundleId() -> String {
            var bundleIdentifier = Bundle.main.bundleIdentifier
            bundleIdentifier = bundleIdentifier?.trimmingCharacters(in: .whitespaces)
            if let bundleIdentifier = bundleIdentifier {
                return bundleIdentifier
            } else {
                return ""
            }
        }
    
    static func mimeTypeForPath(fileUrl: URL) -> String {
        
        let pathExtension = fileUrl.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
}
