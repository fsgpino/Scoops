//
//  newsViewController.swift
//  Scoops
//
//  Created by Francisco Solano Gómez Pino on 30/10/2016.
//  Copyright © 2016 Francisco Solano Gómez Pino. All rights reserved.
//

import UIKit

class newsViewController: UIViewController {
	
	//--------------------------------------
	// MARK: - Variables
	//--------------------------------------
	
	var model: Dictionary<String, AnyObject>?
	
	//--------------------------------------
	// MARK: - IBOutlets
	//--------------------------------------
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var photoImageLabel: UIImageView!
	@IBOutlet weak var authorAndDateLabel: UILabel!
	@IBOutlet weak var lextLabel: UITextView!
	@IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
	@IBOutlet weak var ratingLabel: UILabel!
	@IBOutlet weak var detailTextView: UITextView!
	@IBOutlet weak var sendingRatingIndicator: UIActivityIndicatorView!
	
	//--------------------------------------
	// MARK: - UIViewControllerDelegate
	//--------------------------------------
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		self.loadingIndicator.stopAnimating()
		self.sendingRatingIndicator.stopAnimating()
		
		// Tracking
		MSAITelemetryManager.trackEvent(withName: "Anonymous user view news", properties: model)
		
		if let model = self.model {
			
			let dateFormatter:DateFormatter = DateFormatter()
			dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
			let imageUUID: String = model["imageUUID"] as! String
			let sumRating = model["sumratings"] as! Double
			let voters = model["voters"] as! Double
			var rating: Double = 0
			if voters != 0.0 {
				rating = round((sumRating / voters) * 100) / 100
			}
			let date:Date = model["createdAt"] as! Date
			
			self.photoImageLabel.image = nil
			self.titleLabel.text = model["title"] as? String
			self.authorAndDateLabel.text = "Written by \(model["author"] as! String) on \(dateFormatter.string(from: date))"
			self.ratingLabel.text = "Actual rating: \(rating)"
			self.detailTextView.text = model["text"] as? String
			
			
			if imageUUID != "n/a" {
				
				self.loadingIndicator.startAnimating()
				
				let blob = manager.getImageContainer().blockBlobReference(fromName: imageUUID)
				
				blob.downloadToData(completionHandler: {
					(error, data) in
					
					if let data = data {
						
						DispatchQueue.main.async {
							self.loadingIndicator.stopAnimating()
							self.photoImageLabel.image = UIImage(data: data)
						}
						
					}
					
				})
				
			}
			
		}
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	//--------------------------------------
	// MARK: - Actions
	//--------------------------------------
	
	@IBAction func ratingNews(_ sender: Any) {
		
		self.sendingRatingIndicator.startAnimating()
		
		manager.client.invokeAPI("ratings", body: nil, httpMethod: "PUT", parameters: [ "id": self.model!["id"] as! String, "rating": (sender as AnyObject).tag ], headers: nil) {
			(result, respose, error) in
			
			self.sendingRatingIndicator.stopAnimating()
			
			if let _ = error {
				let alert = UIAlertController(title: "Sending rating error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
					(action) -> Void in
					alert.dismiss(animated: true, completion: nil)
				}))
				self.present(alert, animated: true, completion: nil)
			}
			
			if let _ = result {
				
				MSAITelemetryManager.trackEvent(withName: "Rate news", properties: [ "id": self.model!["id"] as! String, "rating": (sender as AnyObject).tag ] )
				
				let alert = UIAlertController(title: "¡Thank for your rating!", message: "", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
					(action) -> Void in
					alert.dismiss(animated: true, completion: nil)
					self.navigationController!.popViewController(animated: true)
				}))
				self.present(alert, animated: true, completion: nil)
			}
			
		}
		
	}
	
}
