//
//  EmployeeViewController.swift
//  Carrt Measure
//
//  Created by Rrt Carrt on 4/18/21.
//  Copyright © 2021 carrt usf. All rights reserved.
//

import UIKit
import RealmSwift
import Foundation
import SwiftUI

class EmployeeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

	var passCustID:String = ""
	var passID:String = ""
	let tableView = UITableView()
	var activityIndicator = UIActivityIndicatorView(style: .large)
	var Employees: [Employee] = []
	var userData: User?
	static let notificationName = Notification.Name("myNotificationName")
	
	
	
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()

		
		title = "Employees"
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(backButton))
		

		tableView.dataSource = self
		tableView.delegate = self
		tableView.frame = self.view.frame

		view.addSubview(tableView)

		 

		fetchEmployeeList()
		
		
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let user = app.currentUser!
		
		passID = Employees[indexPath.row].id
		
		user.functions.ShareCustomer([AnyBSON(passID),AnyBSON(passCustID)], self.onTeamMemberOperationComplete)
		//let partitionValue = user.id
		
		//let configuration = user.configuration(partitionValue: partitionValue)
		//NotificationCenter.default.post(name: ManageTeamViewController.notificationName, object: nil, userInfo: [passName: customers[indexPath.row].name])
		//let passName = customers[indexPath.row].name
		
		
		//let room = userData?.customerOf[indexPath.row] ?? customerOf(partition: "\(user.id)", name: "My Project")
		/*Realm.asyncOpen(configuration: configuration) { [weak self] (result) in
			switch result {
			case .failure(let error):
				fatalError("Failed to open realm: \(error)")
			case .success(let realm):
				self?.navigationController?.pushViewController(
					RoomViewController(realm: realm, title: "\(passName)'s Rooms"),
					animated: true
				)
			}
		}*/
	

	}
	
	
	

	

	

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Employees.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let member = Employees[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
		cell.selectionStyle = .none
		cell.textLabel?.text = member.email
		return cell
	}

	

	
	// Calls a Realm function to fetch the team members and adds them to the list
	func fetchEmployeeList() {
		// Start loading indicator
		
		let user = app.currentUser!

		user.functions.GetEmployeeList([]) { [weak self](result, error) in
			DispatchQueue.main.async {
				guard self != nil else {
					// This can happen if the view is dismissed
					// before the operation completes
					print("Team employee list no longer needed.")
					return
				}
				// Stop loading indicator
				guard error == nil else {
					print("Fetch employee members failed: \(error!.localizedDescription)")
					return
				}
				print("Fetch employee members complete.")
				print(result!)
				// Convert documents to members array
				self!.Employees = result!.arrayValue!.map({ (bson) in
					return Employee(document: bson!.documentValue!)
					
					
				})

				// Notify UI of changed data
				self!.tableView.reloadData()
			}
		}
	}


	@objc func backButton() {
   //self.dismiss(animated: true, completion: nil)
	   _ = navigationController?.popViewController(animated: true)
   }


	
	
	


	private func onTeamMemberOperationComplete(result: AnyBSON?, realmError: Error?) {
		DispatchQueue.main.async { [self] in
			// Always be sure to stop the activity indicator
			activityIndicator.stopAnimating()

			// There are two kinds of errors:
			// - The Realm function call itself failed (for example, due to network error)
			// - The Realm function call succeeded, but our business logic within the function returned an error,
			//   (for example, user is not a member of the team).
			var errorMessage: String?

			if realmError != nil {
				// Error from Realm (failed function call, network error...)
				errorMessage = realmError!.localizedDescription
			} else if let resultDocument = result?.documentValue {
				// Check for user error. The addTeamMember function we defined returns an object
				// with the `error` field set if there was a user error.
				errorMessage = resultDocument["error"]??.stringValue
			} else {
				// The function call did not fail but the result was not a document.
				// This is unexpected.
				errorMessage = "Unexpected result returned from server"
			}

			// Present error message if any
			guard errorMessage == nil else {
				print("Team operation failed: \(errorMessage!)")
				let alertController = UIAlertController(
					title: "Error",
					message: errorMessage!,
					preferredStyle: .alert
				)

				alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
				present(alertController, animated: true)
				return
			}

			// Otherwise, fetch new team members list
			print("Team operation successful")
		
		}
	}
}


 

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


