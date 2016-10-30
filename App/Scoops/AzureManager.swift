//
//  AzureManager.swift
//  Scoops
//
//  Created by Francisco Solano Gómez Pino on 29/10/2016.
//  Copyright © 2016 Francisco Solano Gómez Pino. All rights reserved.
//

import UIKit

class AzureManager: NSObject {
	
	//--------------------------------------
	// MARK: - Variables
	//--------------------------------------
	
	let client: MSClient = MSClient(applicationURL: URL(string: "https://scoops-boot3fsgpino.azurewebsites.net")!)
	
	let blobClient: AZSCloudBlobClient = (try! AZSCloudStorageAccount(credentials: AZSStorageCredentials(accountName: "boot3fsgpino", accountKey: "x72OylOl6VsOso7W6qdWnOTsv0jR9DPjmwuxfaLzWTe8EYAKZCGN8WHqq4oqLsQuL8MDeyOUt0X7+PmqqcxEuQ=="), useHttps: true)).getBlobClient()
	
	//--------------------------------------
	// MARK: - Getters
	//--------------------------------------
	
	func getImageContainer() -> AZSCloudBlobContainer {
		return self.blobClient.containerReference(fromName: "images")
	}
	
}
