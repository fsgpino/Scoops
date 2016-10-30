//
//  AnonymousNewsTableViewController.swift
//  Scoops
//
//  Created by Francisco Solano Gómez Pino on 29/10/2016.
//  Copyright © 2016 Francisco Solano Gómez Pino. All rights reserved.
//

import UIKit

class AnonymousNewsTableViewController: UITableViewController {
	
	//--------------------------------------
	// MARK: - Variables
	//--------------------------------------
	
	var model: [Dictionary<String, AnyObject>]? = []
	
	//--------------------------------------
	// MARK: - UIViewControllerDelegate
	//--------------------------------------
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.loadData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//--------------------------------------
	// MARK: - Table view data source
	//--------------------------------------
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if (model?.isEmpty)! {
			return 0
		}
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (model?.isEmpty)! {
			return 0
		}
		
		return (model?.count)!
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! newsTableViewCell
		
		cell.model = model?[indexPath.row]
		cell.syncModelWithView()
		
		return cell
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 70
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		let item = model?[indexPath.row]
		
		performSegue(withIdentifier: "viewNews", sender: item)
		
	}
	
	//--------------------------------------
	// MARK: - Actions
	//--------------------------------------

	@IBAction func loginUser(_ sender: Any) {
		
		if let _ = manager.client.currentUser {
			
			self.performSegue(withIdentifier: "goToAuthenticatedZone", sender: self)
			
		} else {
			
			manager.client.login(withProvider: "facebook", parameters: nil, controller: self, animated: true) { (user, error) in
				
				if let _ = error {
					let alert = UIAlertController(title: "Login Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
						(action) -> Void in
						alert.dismiss(animated: true, completion: nil)
					}))
					self.present(alert, animated: true, completion: nil)
					return
				}
				
				if let _ = user {
					
					MSAITelemetryManager.trackEvent(withName: "User logged with Facebook", properties: ["userid": user!.userId! ])
					
					self.performSegue(withIdentifier: "goToAuthenticatedZone", sender: self)
				}
			}
		}
	}

	//--------------------------------------
	// MARK: - Navigation
	//--------------------------------------

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		
		if segue.identifier == "viewNews" {
			let vc = segue.destination as? newsViewController
			vc?.model = sender as? Dictionary<String, AnyObject>
		}
		
    }
	
	//--------------------------------------
	// MARK: - Internal functions
	//--------------------------------------
	
	func loadData() {
		
		let table = manager.client.table(withName: "news")
		let query = table.query()
		query.predicate =  NSPredicate(format: "published == true")
		query.order(byDescending: "createdAt")
		
		query.read {
			(results, error) in
			
			if let _ = error {
				let alert = UIAlertController(title: "Loading news error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
					(action) -> Void in
					alert.dismiss(animated: true, completion: nil)
				}))
				self.present(alert, animated: true, completion: nil)
			}
			
			if let _ = results {
				
				if !((self.model?.isEmpty)!) {
					self.model?.removeAll()
				}
				
				if let items = results, let itemss = items.items {
					
					for item in itemss {
						self.model?.append(item as! [String : AnyObject])
					}
					
					DispatchQueue.main.async {
						self.tableView.reloadData()
					}
					
				}
				
			}
			
		}
		
	}
	
}
