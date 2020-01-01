//
//  AccountSceneController.swift
//  SFSDKStarter
//
//  Created by Victor  on 12/31/19.
//  Copyright © 2019 Salesforce. All rights reserved.
//

import Foundation
import UIKit
import SalesforceSDKCore

class AccountSceneController: UITableViewController {
    
   var dataRows = [Dictionary<String, Any>]()
    
    // MARK: - View lifecycle
    override func loadView() {
       super.loadView()
       self.title = "Accounts"
       let request = RestClient.shared.request(forQuery: "SELECT Id, Name FROM Account LIMIT 10")
       RestClient.shared.send(request: request, onFailure: { (error, urlResponse) in
           SalesforceLogger.d(type(of:self), message:"Error invoking: \(request)")
       }) { [weak self] (response, urlResponse) in
           guard let strongSelf = self,
                 let jsonResponse = response as? Dictionary<String,Any>,
                 let result = jsonResponse ["records"] as? [Dictionary<String,Any>]  else {
                   return
                 }
           SalesforceLogger.d(type(of:strongSelf),message:"Invoked: \(request)")
           DispatchQueue.main.async {
               strongSelf.dataRows = result
               strongSelf.tableView.reloadData()
           }
       }
    }
    
}
