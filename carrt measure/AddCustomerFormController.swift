#if os(iOS)
    import AuthenticationServices
#endif

import Foundation
import SwiftUI
import UIKit
import RealmSwift
import BoxSDK


class AddCustomerFormController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    private var sdk: BoxSDK!
    private var client: BoxClient!
    
    private var folderItems: [FolderItem] = []
   
    private let initialPageSize: Int = 100
    let group = DispatchGroup()
	let nameField = UITextField()
	let emailField = UITextField()
	let mobileField = UITextField()
	let AddressField = UITextField()
	let addCustButton = CustomUIButton(type: .roundedRect)
   
    private var customerfolderID: String = ""
    private var parentfolderID: String! = ""
	let errorLabel = UILabel()
	let activityIndicator = UIActivityIndicatorView(style: .medium)
	var id = UUID().uuidString
    
	var email: String? {
		get {
			return emailField.text
		}
	}

	var name: String? {
		get {
			return nameField.text
		}
	}

	var mobile: String? {
		get {
			return mobileField.text
		}
	}

	var address: String? {
		get {
			return AddressField.text
		}
	}

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy at HH:mm a"
        return formatter
    }()

    private lazy var errorView: BasicErrorView = {
        let errorView = BasicErrorView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        return errorView
    }()

    
    
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
        sdk = BoxSDK(clientId: Constants.clientId, clientSecret: Constants.clientSecret)
	    getOAuthClient()
        
		// Create a view that will automatically lay out the other controls.
		let container = UIStackView()
		container.translatesAutoresizingMaskIntoConstraints = false
		container.axis = .vertical
		container.alignment = .fill
		container.spacing = 16.0
		view.addSubview(container)

		// Configure the activity indicator.
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(activityIndicator)

		// Set the layout constraints of the container view and the activity indicator.
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
		infoLabel.text = "Please enter a details of customer."
		container.addArrangedSubview(infoLabel)

		emailField.placeholder = "email"
		emailField.borderStyle = .roundedRect
		emailField.autocapitalizationType = .none
		emailField.autocorrectionType = .no
		container.addArrangedSubview(emailField)

		nameField.placeholder = "name"
		nameField.autocorrectionType = .no
		nameField.borderStyle = .roundedRect
		container.addArrangedSubview(nameField)

		mobileField.placeholder = "mobile"
		mobileField.borderStyle = .roundedRect
		mobileField.autocapitalizationType = .none
		mobileField.autocorrectionType = .no
		container.addArrangedSubview(mobileField)

		AddressField.placeholder = "address"
		AddressField.borderStyle = .roundedRect
		AddressField.autocapitalizationType = .none
		AddressField.autocorrectionType = .no
		container.addArrangedSubview(AddressField)
		
		addCustButton.setTitle("Add Customer", for: .normal)
		addCustButton.addTarget(self, action: #selector(AddCustomer(sender:)), for: UIControl.Event.touchUpInside)
		addCustButton.Name = name
		addCustButton.Email = email
		addCustButton.Mobile = mobile
		addCustButton.Address = address
		
		container.addArrangedSubview(addCustButton)
		
		
		//let tapGesture = CustomTapGestureRecognizer(target: self, action: #selector(tapSelector(sender:)))
		//tapGesture.Name = name
		//tapGesture.Email = email
		//tapGesture.Mobile =
		//tapGesture.Address = address
		
		//self.view.addGestureRecognizer(tapGesture)
		
		
		
		errorLabel.numberOfLines = 0
		errorLabel.textColor = .red
		container.addArrangedSubview(errorLabel)
		
	}
	   
	//@objc func tapSelector(sender: CustomTapGestureRecognizer){
	//	print(sender.Name!)

  // }

		

	@objc func AddCustomer(sender: CustomUIButton) {
		print("Adding member: \(String(describing: sender.Name))")
		activityIndicator.startAnimating()
			let user = app.currentUser!
       
        self.group.enter()
           client.folders.listItems(
               folderId: "0",
               usemarker: true,
               fields: ["modified_at", "name", "type", "extension"]
           ){ [weak self] result in
               guard let self = self else {return}

               switch result {
               case let .success(items):
                   self.folderItems = []
                   
                   for i in 1...self.initialPageSize {
                       print ("Request Item #\(String(format: "%03d", i)) |")
                       items.next { result in
                           switch result {
                           case let .success(item):
                               print ("    Got Item #\(String(format: "%03d", i)) | \(item.debugDescription))")
                            
                            
                            
                            
                            
                               DispatchQueue.main.async {
                                   self.folderItems.append(item)
                               
                                if case let .folder(folder) = item {
                                    print(folder.name!)
                                    print("fetching details of folder")
                                    if folder.name == "Carrt-measure" {
                                        self.parentfolderID = folder.id
                                        
                                        print(folder.id)
                                        
                                    }
                                    
                                }
                                   
                                   
                                   
                               }
                           case let .failure(error):
                               print ("     No Item #\(String(format: "%03d", i)) | \(error.message)")
                               return
                           }
                       }
                   }
               case let .failure(error):
                   print("error in getSinglePageOfFolderItems: \(error)")
                   
               }
            self.group.leave()  }
        group.notify(queue: .main) { [self] in
            if parentfolderID == "" {
        
                client.folders.create(name: "Carrt-measure", parentId: "0") { [self] (result: Result<Folder, BoxSDKError>) in
            guard case let .success(folder) = result else {
                print("Error creating folder")
                return
            }
            
            print("Created folder \"\(String(describing: folder.name))\" ")
        
            parentfolderID = folder.id
        
            
            self.client.folders.create(name: self.name! , parentId: self.parentfolderID) { (result: Result<Folder, BoxSDKError>) in
                guard case let .success(folder) = result else {
                    print("Error creating folder")
                    return
                }
                
                print("Created folder \"\(String(describing: folder.name))\" inside of folder \"\(String(describing: folder.parent?.name))\"")
                customerfolderID = folder.id
               
                
                user.functions.addCustomer([AnyBSON(id),AnyBSON(email!), AnyBSON(name!), AnyBSON(mobile!), AnyBSON(address!), AnyBSON(parentfolderID), AnyBSON(customerfolderID)], self.onTeamMemberOperationComplete)
            }}
        } else {
            
            client.folders.create(name: name! , parentId: parentfolderID) { [self] (result: Result<Folder, BoxSDKError>) in
                guard case let .success(folder) = result else {
                    print("Error creating folder")
                    return
                }
                
                print("Created folder \"\(String(describing: folder.name))\" inside of folder \"")
                customerfolderID = folder.id
                
                user.functions.addCustomer([AnyBSON(id),AnyBSON(email!), AnyBSON(name!), AnyBSON(mobile!), AnyBSON(address!), AnyBSON(parentfolderID), AnyBSON(customerfolderID)], self.onTeamMemberOperationComplete)
            }
            
            
        }
        }
        
		
		self.dismiss(animated: true, completion: nil)
		

           }
        
    
	
    func getOAuthClient() {
        
        if #available(iOS 13, *) {
            sdk.getOAuth2Client(tokenStore: KeychainTokenStore(), context:self) { [weak self] result in
                switch result {
                case let .success(client):
                    self?.client = client
                   
                    
                case let .failure(error):
                    print("error in getOAuth2Client: \(error)")
                    self?.addErrorView(with: error)
                }
            }
        } else {
            sdk.getOAuth2Client(tokenStore: KeychainTokenStore()) { [weak self] result in
                switch result {
                case let .success(client):
                    self?.client = client
                   
                    
                case let .failure(error):
                    print("error in getOAuth2Client: \(error)")
                    self?.addErrorView(with: error)
                }
            }
        }
    }
	
    func addErrorView(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view.addSubview(self.errorView)
            let safeAreaLayoutGuide = self.view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                self.errorView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
                self.errorView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
                self.errorView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                self.errorView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
                ])
            self.errorView.displayError(error)
        }
    }
    
    
    func removeErrorView() {
        if !view.subviews.contains(errorView) {
            return
        }
        DispatchQueue.main.async {
            self.errorView.removeFromSuperview()
        }
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
			present(UINavigationController(rootViewController: ManageTeamViewController()), animated: true)
			print("manage team view out")
		}
	}
		
		
}
		
extension AddCustomerFormController {
    @available(iOS 13.0, *)
    func presentationAnchor(for session: ASWebAuthenticationSession) ->  ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}
//class CustomTapGestureRecognizer: UITapGestureRecognizer {
	//var Name: String?
	//var Email: String?
	//var Mobile: String?
	//var Address: String?
	
class CustomUIButton: UIButton{
	var Name: String?
	var Email: String?
	var Mobile: String?
	var Address: String?
	
}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	
