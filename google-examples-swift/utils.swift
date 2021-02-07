//
//  utils.swift
//  google-examples-swift
//
//  Created by Milan Parađina on 07.02.2021..
//

import Foundation
import UIKit

class Utils {
    
    func showAlert(title : String, message: String, vc: UIViewController) {
         let alert = UIAlertController(
                 title: title,
                 message: message,
                 preferredStyle: UIAlertController.Style.alert
         )
         let ok = UIAlertAction(
                 title: "OK",
                 style: UIAlertAction.Style.default,
                 handler: nil
         )
         alert.addAction(ok)
        vc.present(alert, animated: true, completion: nil)
     }
}
