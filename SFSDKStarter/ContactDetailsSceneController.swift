//
//  ContactDetailsSceneController.swift
//  SFSDKStarter
//
//  Created by Kevin Poorman on 10/16/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import Foundation
import UIKit

class ContactDetailsSceneController: UITableViewController {
    
    //MARK: - Properties
    
    var name: String?
    var contactId: String?
    
    //MARK: - View Lifecycle
    
    override func loadView() {
        super.loadView()
        updateViews()
    }
    
    //MARK: - Helper Methods
    
    private func updateViews() {
        if let name = name {
            self.title = name
        }
    }
    
    private func fetchContactDetailsFromAPI() {
        guard let contactId = contactId else {
            Service.showAlert(on: self, style: .alert, title: Service.errorTitle, message: Service.errorMsg)
            return
        }
    }
}
