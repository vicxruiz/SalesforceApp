//
//  ContactDetailsSceneController.swift
//  SFSDKStarter
//
//  Created by Kevin Poorman on 10/16/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import Foundation
import UIKit
import SalesforceSDKCore

class ContactDetailsSceneController: UITableViewController {
    
    //MARK: - Properties
    
    var name: String?
    var contactId: String?
    var dataRows = [ObjectField]()
    typealias ObjectField = (label: String, value: String)
    
    
    //MARK: - View Lifecycle
    
    override func loadView() {
        super.loadView()
        updateViews()
        fetchContactDetailsFromAPI()
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
        let fieldList = "Id, Name, Email, Phone, MailingStreet, MailingCity, MailingState, MailingPostalCode"
        let request = RestClient.shared.requestForRetrieve(withObjectType: "Contact", objectId: contactId, fieldList: fieldList)
        
        RestClient.shared.send(request: request, onFailure: { (error, urlResponse) in
            SalesforceLogger.d(type(of:self), message:"Error invoking: \(request)")
            Service.showAlert(on: self, style: .alert, title: Service.errorTitle, message: error?.localizedDescription)
        }) { [weak self] (response, urlResponse) in
            var results = [ObjectField]()
            guard let strongSelf = self else { return }
            
            SalesforceLogger.d(type(of:strongSelf),message:"Invoked: \(request)")
            if let dictionaryResponse = response as? [String: Any] {
                results = strongSelf.fields(from: dictionaryResponse)
            }
            
            DispatchQueue.main.async {
                strongSelf.dataRows = results
                strongSelf.tableView.reloadData()
            }
        }
    }
    
    private func fields(from record: [String: Any]) -> [ObjectField] {
       let fieldExclusionList = ["attributes", "Id"]
       let filteredRecord = record.lazy.filter { key, value in !fieldExclusionList.contains(key) && value is String }
       return filteredRecord.map { key, value in (label: key, value: value as! String) }
    }
    
    
}

extension ContactDetailsSceneController {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return self.dataRows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ContactFieldIdentifier"
    
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier:cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        let obj = dataRows[indexPath.row]
        cell.textLabel?.text = obj.value
        cell.detailTextLabel?.text = obj.label
        
        return cell
    }
}
