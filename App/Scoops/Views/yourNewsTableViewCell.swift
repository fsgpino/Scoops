//
//  YourNewsTableViewCell.swift
//  Scoops
//
//  Created by Francisco Solano Gómez Pino on 29/10/2016.
//  Copyright © 2016 Francisco Solano Gómez Pino. All rights reserved.
//

import UIKit

class YourNewsTableViewCell: UITableViewCell {
	
	//--------------------------------------
	// MARK: - Variables
	//--------------------------------------
	
	var model: Dictionary<String, AnyObject>?
	
	//--------------------------------------
	// MARK: - IBOutlets
	//--------------------------------------
	
	@IBOutlet weak var photoImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
	@IBOutlet weak var publishedLabel: UILabel!
	@IBOutlet weak var ratingLabel: UILabel!
	
	//--------------------------------------
	// MARK: - UICollectionViewCell
	//--------------------------------------
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	//--------------------------------------
	// MARK: - Syncing
	//--------------------------------------
	
	func syncModelWithView() {
		
		self.loadingIndicator.stopAnimating()
		
		if let model = self.model {
			
			let imageUUID: String = model["imageUUID"] as! String
			let sumRating = model["sumratings"] as! Double
			let voters = model["voters"] as! Double
			var rating: Double = 0
			if voters != 0.0 {
				rating = round((sumRating / voters) * 100) / 100
			}
			
			self.photoImageView.image = nil
			self.titleLabel.text = model["title"] as? String
			self.ratingLabel.text = "Rating: \(rating)"
			
			if (model["published"] as! Bool) {
				self.publishedLabel.text = "Published"
			} else {
				self.publishedLabel.text = "No Published"
			}
			
			if imageUUID != "n/a" {
				
				self.loadingIndicator.startAnimating()
				
				let blob = manager.getImageContainer().blockBlobReference(fromName: imageUUID)
				
				blob.downloadToData(completionHandler: {
					(error, data) in
					
					if let data = data {
						
						DispatchQueue.main.async {
							self.loadingIndicator.stopAnimating()
							self.photoImageView.image = UIImage(data: data)
						}
						
					}
					
				})
				
			}
			
		}
		
	}
	
}
