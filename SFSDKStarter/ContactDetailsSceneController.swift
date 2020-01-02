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
    var imagePickerCtrl: UIImagePickerController!
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
    
    //MARK: - Actions
    
    @IBAction func didTapPhotoButton(_ sender: Any){
       imagePickerCtrl = UIImagePickerController()
       imagePickerCtrl.delegate = self
       if UIImagePickerController.isSourceTypeAvailable(.camera) {
           imagePickerCtrl.sourceType = .camera
       } else {
           // Device camera is not available. Use photo album instead.
           imagePickerCtrl.sourceType = .savedPhotosAlbum
       }
       present(imagePickerCtrl, animated: true, completion: nil)
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

extension ContactDetailsSceneController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePickerCtrl.dismiss(animated: true, completion: nil)
        // make sure to leave this line in, it helps us score the challenge
        RestClient.shared.sendImagesSelectedInstrumentation()
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            guard let contactId = contactId else {
                Service.showAlert(on: self, style: .alert, title: Service.errorTitle, message: Service.errorMsg)
                return
            }
            let attachmentRequest = RestClient.shared.requestForCreatingImageAttachment(from: image.resized(toWidth: 250.0), relatingTo: contactId)
            RestClient.shared.send(request: attachmentRequest, onFailure: {(error, urlResponse) in
                let errorDescription: String
                if let error = error {
                    errorDescription = "\(error)"
                } else {
                    errorDescription = "An unknown error occurred."
                }
                SalesforceLogger.e(type(of: self), message: "Failed to successfully complete the REST request. \(errorDescription)")
                Service.showAlert(on: self, style: .alert, title: Service.errorTitle, message: errorDescription)
            }){ result, _ in
                let successMessage = "Completed upload of photo"
                SalesforceLogger.d(type(of: self), message: successMessage)
                Service.showAlert(on: self, style: .alert, title: "Success!", message: successMessage)
            }
        }
    }
    
}
