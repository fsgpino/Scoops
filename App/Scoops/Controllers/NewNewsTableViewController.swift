//
//  NewNewsTableViewController.swift
//  Scoops
//
//  Created by Francisco Solano Gómez Pino on 29/10/2016.
//  Copyright © 2016 Francisco Solano Gómez Pino. All rights reserved.
//

import UIKit
import CoreLocation

class NewNewsTableViewController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
	
	//--------------------------------------
	// MARK: - Variables
	//--------------------------------------
	
	var imageSelected:Bool = false
	var locationManager : CLLocationManager?
	var lastLocation:CLLocation = CLLocation(latitude: 0, longitude: 0)
	
	//--------------------------------------
	// MARK: - IBOutlets
	//--------------------------------------
	
	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var detailTextField: UITextField!
	@IBOutlet weak var authorTextField: UITextField!
	@IBOutlet weak var photoImageView: UIImageView!
	@IBOutlet weak var selectImageButton: UIButton!
	@IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
	
	//--------------------------------------
	// MARK: - UIViewControllerDelegate
	//--------------------------------------
	
	// METHOD viewDidLoad
	// This method load when this view started before of show GUI
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		// Defining delegate textFields
		self.titleTextField.delegate = self
		self.detailTextField.delegate = self
		self.authorTextField.delegate = self
		
		// Hidding image view
		self.photoImageView.isHidden = true
		
		// Location manager
		self.locationManager = CLLocationManager()
		self.locationManager?.delegate = self
		self.locationManager?.requestWhenInUseAuthorization()
		self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager?.startUpdatingLocation()
		
		// Stop loading
		self.loadingIndicator.stopAnimating()
		
    }

	// METHOD didReceiveMemoryWarning
	// This method load when the memory is limited
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//--------------------------------------
	// MARK: - CLLocationManagerDelegate
	//--------------------------------------
	
	// METHOD locationManager:manager:didUpdateLocations:
	// Obtain last location
	public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		self.locationManager?.stopUpdatingLocation()
		self.locationManager = nil
		if let lastLocation:CLLocation = locations.last {
			self.lastLocation = lastLocation
		}
	}
	
	//--------------------------------------
	// MARK: - UIImagePickerControllerDelegate
	//--------------------------------------
	
	// METHOD imagePickerController:didFinishPickingImage:editingInfo:
	// Show image selected in image view
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
		
		// Dismiss picker view
		self.dismiss(animated: true, completion: nil)
		
		// Setting new image
		self.photoImageView.image = image
		self.photoImageView.isHidden = false
		self.imageSelected = true
		self.selectImageButton.titleLabel?.text = ""
	}
	
	//--------------------------------------
	// MARK: - UITextFieldDelegate
	//--------------------------------------
	
	// METHOD textFieldShouldReturn
	// Remove the keyboard when editing the textField ends
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	//--------------------------------------
	// MARK: - IBActions
	//--------------------------------------
	
	// METHOD selectImage [linked with button]
	// Show a menu controller for set, change or replace profile image
	@IBAction func selectImage(_ sender: Any) {
		self.tableView.endEditing(true)
		if self.imageSelected {
			self.showUploadImageOptionMenu(0)
		} else {
			self.showUploadImageOptionMenu(1)
		}
	}
	
	// METHOD saveNews [linked with button]
	// Upload user news to server
	@IBAction func saveNews(_ sender: Any) {
		
		self.loadingIndicator.startAnimating()
		
		uploadImage { (imageUUID) in
			
			let newNews:[String : Any] = [ "title" : self.titleTextField.text!,
			                               "text" : self.detailTextField.text!,
			                               "imageUUID" : imageUUID,
			                               "latitude" : self.lastLocation.coordinate.latitude,
			                               "longitude" : self.lastLocation.coordinate.longitude,
			                               "author" : self.authorTextField.text!] as [String : Any]
			
			manager.client.table(withName: "News").insert(newNews) {
				(result, error) in
				
				self.loadingIndicator.stopAnimating()
				
				if let _ = error {
					let alert = UIAlertController(title: "Upload news error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
						(action) -> Void in
						alert.dismiss(animated: true, completion: nil)
					}))
					self.present(alert, animated: true, completion: nil)
				}
				
				if let _ = result {
					
					MSAITelemetryManager.trackEvent(withName: "User upload news", properties: newNews)
					
					let alert = UIAlertController(title: "News sended", message: nil, preferredStyle: UIAlertControllerStyle.alert)
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
	
	//--------------------------------------
	// MARK: - Internal functions
	//--------------------------------------
	
	// METHOD uploadImage:
	// Upload image to server
	fileprivate func uploadImage(_ block:@escaping (_ imageUUID:String)->()){
		
		let imageUUID:String = UUID().uuidString
		
		if self.imageSelected {
			
			let imageBlob = manager.getImageContainer().blockBlobReference(fromName: imageUUID)
			
			imageBlob.upload(from: UIImageJPEGRepresentation(self.photoImageView.image!, 0.5)!, completionHandler: {
				(error:Error?) in
				if let _ = error {
					let alert = UIAlertController(title: "Upload image Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
						(action) -> Void in
						alert.dismiss(animated: true, completion: nil)
					}))
					self.present(alert, animated: true, completion: nil)
				}
				block(imageUUID)
			})
			
		} else {
			block("n/a")
		}
		
	}
	
	
	// METHOD showUploadImageOptionMenu
	// Show a option menu for upload, remove, replace image
	fileprivate func showUploadImageOptionMenu(_ menu: Int){
		
		if (menu == 1) {
			
			// Make a picker
			let picker = UIImagePickerController()
			
			// Setting preference of editing and delegate
			picker.allowsEditing = true
			picker.delegate = self
			
			// Make actionSheet
			let actionSheet:UIAlertController = UIAlertController(title: "Select source for image", message: nil, preferredStyle: (UIDevice.current.userInterfaceIdiom == .phone ? .actionSheet : .alert))
			
			// Camera option
			if UIImagePickerController.isCameraDeviceAvailable(.rear){
				actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
					(action:UIAlertAction) in
					
					// Remove actionSheet
					actionSheet.dismiss(animated: true, completion: nil)
					
					// Setting source image
					picker.sourceType = UIImagePickerControllerSourceType.camera
					
					// Show picker
					self.present(picker, animated: true, completion: nil)
					
				}))
			}
			
			// Photo library option
			actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default, handler: {
				(action:UIAlertAction) in
				
				// Remove actionSheet
				actionSheet.dismiss(animated: true, completion: nil)
				
				// Setting source image
				picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
				
				// Show picker
				self.present(picker, animated: true, completion: nil)
				
			}))
			
			// Cancel option
			actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
				(action:UIAlertAction) in
				
				// Remove actionSheet
				actionSheet.dismiss(animated: true, completion: nil)
				
			}))
			
			// Show actionSheet in view
			self.present(actionSheet, animated: true, completion: nil)
			
		} else { // Else: (menu == 1)
			
			// Make actionSheet
			let actionSheet:UIAlertController = UIAlertController(title: "You want to do with the current image?", message: nil, preferredStyle: (UIDevice.current.userInterfaceIdiom == .phone ? .actionSheet : .alert))
			
			// Remove option
			actionSheet.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: {
				(action:UIAlertAction) in
				
				// Remove actionSheet
				actionSheet.dismiss(animated: true, completion: nil)
				
				// Remove image
				self.photoImageView.image = nil
				self.photoImageView.isHidden = true
				self.imageSelected = false
				
				// Set title button
				self.selectImageButton.titleLabel?.text = "Select image"
				
			}))
			
			// Replace option
			actionSheet.addAction(UIAlertAction(title: "Replace", style: .default, handler: {
				(action:UIAlertAction) in
				
				// Remove actionSheet
				actionSheet.dismiss(animated: true, completion: nil)
				
				// Show a menu option for new image
				self.showUploadImageOptionMenu(1)
				
			}))
			
			// Cancel option
			actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
				(action:UIAlertAction) in
				
				// Remove actionSheet
				actionSheet.dismiss(animated: true, completion: nil)
				
			}))
			
			// Show actionSheet in view
			self.present(actionSheet, animated: true, completion: nil)
			
		} // End: (menu == 1)
		
	}
	
}

