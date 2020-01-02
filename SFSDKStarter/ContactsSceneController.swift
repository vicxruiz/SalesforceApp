//
//  ContactsSceneController.swift
//  SFSDKStarter
//
//  Created by Kevin Poorman on 10/16/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import Foundation
import UIKit
import SalesforceSDKCore

class ContactsSceneController: UITableViewController {
    
    // MARK: - Properties
    
    var accountId: String?
    var name: String?
    
    var contactRows = [Dictionary<String, Any>]()
    
    // MARK: - View lifecycle
    override func loadView() {
        super.loadView()
        updateViews()
        fetchContactsFromAPI()
    }
    
    //MARK: - Helper Methods
    
    private func updateViews() {
        if let name = name {
            self.title = name + "'s Contacts"
        } else {
            self.title = "Contacts"
        }
        
    }
    
    private func fetchContactsFromAPI() {
        
        guard let accountId = accountId else {
            Service.showAlert(on: self, style: .alert, title: Service.errorTitle, message: Service.errorMsg)
            return
        }
        
        let request = RestClient.shared.request(forQuery: "SELECT Id, Name FROM Contact WHERE accountid = '\(accountId)'")
        RestClient.shared.send(request: request, onFailure: { (error, urlResponse) in
            SalesforceLogger.d(type(of:self), message:"Error invoking: \(request)")
            Service.showAlert(on: self, style: .alert, title: Service.errorTitle, message: error?.localizedDescription)
        }) { [weak self] (response, urlResponse) in
            guard let strongSelf = self,
                let jsonResponse = response as? Dictionary<String,Any>,
                let result = jsonResponse ["records"] as? [Dictionary<String,Any>]  else {
                    return
            }
            SalesforceLogger.d(type(of:strongSelf),message:"Invoked: \(request)")
            DispatchQueue.main.async {
                strongSelf.contactRows = result
                strongSelf.tableView.reloadData()
            }
        }
    }
}

extension ContactsSceneController {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return self.contactRows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ContactCell"
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier:cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        let contact = contactRows[indexPath.row]
        cell.textLabel?.text = contact["Name"] as? String
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toContactDetailSegue" {
            guard let destination = segue.destination as? ContactDetailsSceneController, let indexPath = self.tableView.indexPathForSelectedRow else {
                return
            }
            if let name = self.contactRows[indexPath.row]["Name"] as? String {
                destination.name = name
            }
            if let contactId = self.contactRows[indexPath.row]["Id"] as? String {
                destination.contactId = contactId
            }
        }
    }
}
