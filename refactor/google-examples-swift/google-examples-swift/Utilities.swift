//
//  Utilities.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 26.07.2025..
//

import Foundation
import UIKit

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
}
