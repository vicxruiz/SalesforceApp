//
//  Service.swift
//  SFSDKStarter
//
//  Created by Victor  on 1/2/20.
//  Copyright © 2020 Salesforce. All rights reserved.
//

import Foundation
import UIKit

class Service {
    //user alerts
    static let errorTitle = "Error fetching data"
    static let errorMsg = "Please check your connection and try again."
    static func showAlert(on: UIViewController, style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction] = [ UIAlertAction(title: "OK", style: .default, handler: nil)], completion: (() -> Swift.Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions {
            alert.addAction(action)
        }
        on.present(alert, animated: true, completion: completion)
    }
}
