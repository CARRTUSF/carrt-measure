

import Foundation
import SwiftUI
import UIKit
import RealmSwift

class DisplayCustInfoViewController: UIViewController {
	let nameField = UITextField()
	let emailField = UITextField()
	let mobileField = UITextField()
	let AddressField = UITextField()
	let addCustButton = CustomUIButton(type: .roundedRect)
	let errorLabel = UILabel()
	let activityIndicator = UIActivityIndicatorView(style: .medium)
	var passName:String = ""
	var customers: [Customer] = []
	
	//@IBOutlet weak var textLabel:UILabel?
	var email: String?
	var name: String?
	var mobile: String?
	var address: String?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		//textLabel?.text = passName
		view.backgroundColor = .white
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(activityIndicator)
		print("display info view loaded")
		displayCustomerInfo(name: passName)
		// Create a view that will automatically lay out the other controls.
		
		// Configure the activity indicator.
				
		// Set the layout constraints of the container view and the activity indicator.
		
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
			print("inside delay")
			self.getStackView()
			// Code you want to be delayed
		}
		
}
	   

	func getStackView() -> UIStackView {
		
	print("mamamia")
		
		let container = UIStackView()
		container.translatesAutoresizingMaskIntoConstraints = false
		container.axis = .vertical
		container.alignment = .fill
		container.spacing = 16.0
		view.addSubview(container)
		
		
		
		let guide = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			// This pins the container view to the top and stretches it to fill the parent
			// view horizontally.
			container.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
			container.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
			container.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16),
			// The activity indicator is centered over the rest of the view.
			activityIndicator.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
			activityIndicator.centerXAnchor.constraint(equalTo: guide.centerXAnchor)
			])
		
		
	
		// Add some text at the top of the view to explain what to do.
		
		
		
		let infoLabel = UILabel()
		infoLabel.numberOfLines = 0
		infoLabel.text = "Details of customer."
		container.addArrangedSubview(infoLabel)
		
		let spacingLabel = UILabel()
		spacingLabel.numberOfLines = 2
		spacingLabel.text = " "
		container.addArrangedSubview(spacingLabel)
		
		let customer = customers[0]
		let emailLabel = UILabel()
		emailLabel.numberOfLines = 0
		emailLabel.text = "Email:"
		container.addArrangedSubview(emailLabel)
		emailField.attributedPlaceholder = NSAttributedString(string: customer.email, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
		
		emailField.borderStyle = .roundedRect
		
		emailField.autocapitalizationType = .none
		emailField.autocorrectionType = .no
		emailField.isUserInteractionEnabled = false
		container.addArrangedSubview(emailField)

		let nameLabel = UILabel()
		nameLabel.numberOfLines = 0
		nameLabel.text = "Name:"
		container.addArrangedSubview(nameLabel)
		nameField.attributedPlaceholder = NSAttributedString(string: customer.name, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
		nameField.autocorrectionType = .no
		nameField.textColor = UIColor.black
		nameField.borderStyle = .roundedRect
		nameField.isUserInteractionEnabled = false
		container.addArrangedSubview(nameField)

		let mobileLabel = UILabel()
		mobileLabel.numberOfLines = 0
		mobileLabel.text = "Mobile:"
		container.addArrangedSubview(mobileLabel)
		mobileField.attributedPlaceholder = NSAttributedString(string: customer.mobileNo, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
		mobileField.borderStyle = .roundedRect
		mobileField.autocapitalizationType = .none
		mobileField.autocorrectionType = .no
		mobileField.textColor = UIColor.black
		mobileField.isUserInteractionEnabled = false
		container.addArrangedSubview(mobileField)

		let addressLabel = UILabel()
		addressLabel.numberOfLines = 0
		addressLabel.text = "Address:"
		container.addArrangedSubview(addressLabel)
		AddressField.attributedPlaceholder = NSAttributedString(string: customer.address, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
		AddressField.isSecureTextEntry = true
		AddressField.borderStyle = .roundedRect
		AddressField.textColor = UIColor.black
		AddressField.isUserInteractionEnabled = false
		container.addArrangedSubview(AddressField)
		
		addCustButton.setTitle("Back", for: .normal)
		addCustButton.addTarget(self, action: #selector(backButton), for: UIControl.Event.touchUpInside)
		
		
		container.addArrangedSubview(addCustButton)
		
		
		//let tapGesture = CustomTapGestureRecognizer(target: self, action: #selector(tapSelector(sender:)))
		//tapGesture.Name = name
		//tapGesture.Email = email
		//tapGesture.Mobile =
		//tapGesture.Address = address
		
		//self.view.addGestureRecognizer(tapGesture)
		
		print(passName)
		
		errorLabel.numberOfLines = 0
		errorLabel.textColor = .red
		container.addArrangedSubview(errorLabel)
		
		return container
	}

	func displayCustomerInfo(name: String) {
		print("fetching info of: \(name)")
		activityIndicator.startAnimating()
		let group = DispatchGroup()
		group.enter()
		print("hello")
		
		let user = app.currentUser!
		user.functions.displayCustomerInfo([AnyBSON(name)] ) { [weak self](result, error) in
			DispatchQueue.main.async { [self] in
				guard self != nil else {
					// This can happen if the view is dismissed
					// before the operation completes
					print("customer details no longer needed.")
					return
				}
				// Stop loading indicator
				self!.activityIndicator.stopAnimating()
				
				guard error == nil else {
					print("Fetch customer details failed: \(error!.localizedDescription)")
					return
				}
				print("Fetch customer details complete.")
				
				print(result!)
				print("hi")
				group.leave()
				print("yeah")								// Convert documents to members array
				self!.customers = result!.arrayValue!.map({ (bson) in
					return Customer(document: bson!.documentValue!)
					
					
				})
							// Notify UI of changed data
				//print(self!.customer[1])
				
					}
			
			
		}
		
		print("wassup")
		
		
		}
	
	
	
	private func onTeamMemberOperationComplete(result: AnyBSON?, realmError: Error?) {
		DispatchQueue.main.async { [self] in
			// Always be sure to stop the activity indicator
			activityIndicator.stopAnimating()
			
			
			navigationController!.pushViewController(ManageTeamViewController(), animated: true)
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
				//let alertController = UIAlertController(
				//	title: "Error",
				//	message: errorMessage!,
					//preferredStyle: .alert
			//	)

				//alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
				//present(alertController, animated: true)
				return
			}

			// Otherwise, fetch new team members list
			print("Team operation successful")
			print("manage team view in")
			
			
		}
	}
	
	
	  @objc func backButton() {
	//self.dismiss(animated: true, completion: nil)
		_ = navigationController?.popViewController(animated: true)
 }
		// Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


