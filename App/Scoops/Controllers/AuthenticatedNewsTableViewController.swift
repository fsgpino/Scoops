//
//  AuthenticatedNewsTableViewController.swift
//  Scoops
//
//  Created by Francisco Solano Gómez Pino on 29/10/2016.
//  Copyright © 2016 Francisco Solano Gómez Pino. All rights reserved.
//

import UIKit

class AuthenticatedNewsTableViewController: UITableViewController {
	
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
		
        let cell = tableView.dequeueReusableCell(withIdentifier: "yourNewsCell", for: indexPath) as! YourNewsTableViewCell
		
		cell.model = model?[indexPath.row]
		cell.syncModelWithView()
		
        return cell
    }

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 70
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	// Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
			let item = self.model? [indexPath.row]
			
			MSAITelemetryManager.trackEvent(withName: "User remove news", properties: item)
			
			manager.client.table(withName: "news").delete(item!, completion: {
				(result, error) in
				if let _ = error {
					let alert = UIAlertController(title: "Remove news error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
						(action) -> Void in
						alert.dismiss(animated: true, completion: nil)
					}))
					self.present(alert, animated: true, completion: nil)
				}
			})
			self.model?.remove(at: indexPath.row)
			
			if (self.model?.count)! > 1 {
				tableView.beginUpdates()
				tableView.deleteRows(at: [indexPath], with: .fade)
				tableView.endUpdates()
			} else {
				tableView.reloadData()
			}
			
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
	
	//--------------------------------------
	// MARK: - Internal functions
	//--------------------------------------
	
	func loadData() {
		
		let table = manager.client.table(withName: "news")
		
		let query = table.query()
		query.predicate =  NSPredicate(format: "userid == %@", (manager.client.currentUser?.userId)!)
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
