//
//  RestClient+attachment.swift
//  SFSDKStarter
//
//  Created by Victor  on 1/2/20.
//  Copyright © 2020 Salesforce. All rights reserved.
//

import Foundation
import SalesforceSDKCore
import UIKit

extension RestClient {
 func requestForCreatingImageAttachment(from image: UIImage, relatingTo: String, fileName: String? = nil) -> RestRequest {
     let imageData = UIImagePNGRepresentation(image)!
     let uploadFileName = fileName ?? UUID().uuidString + ".png"
     return self.requestForCreatingAttachment(from: imageData, withFileName: uploadFileName, relatingTo: relatingTo)
 }
 private func requestForCreatingAttachment(from data: Data, withFileName fileName: String, relatingTo: String) -> RestRequest {
     let record = ["VersionData": data.base64EncodedString(options: .lineLength64Characters), "Title": fileName, "PathOnClient": fileName, "FirstPublishLocationId": relatingTo]
     return self.requestForCreate(withObjectType: "ContentVersion", fields: record)
 }
}
