
#if os(iOS)
    import AuthenticationServices
#endif
import UIKit
import RealmSwift
import BoxSDK

import BoxPreviewSDK

class ManageTeamViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, ASWebAuthenticationPresentationContextProviding {
	var passName:String = ""
    let tableView = UITableView()
    var activityIndicator = UIActivityIndicatorView(style: .large)
    var customers: [Member] = []
	var userData: User?
	var Employees: [Member] = []
	static let notificationName = Notification.Name("myNotificationName")
	
    private var sdk: BoxSDK!
    private var client: BoxClient!
    
    private var folderItems: [FolderItem] = []
    private let initialPageSize: Int = 100

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
		setupLongPressGesture()
		
        title = "My Customers"
        
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Box"), for: .normal)
        button.setTitle("", for: .normal)
           button.sizeToFit()
        
        
        
        button.addTarget(self, action: #selector(self.boxSyncButtonDidClick), for: .touchUpInside)
        
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutButtonDidClick))
        //navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidClick))
		navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(fetchTeamRefresh)), UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidClick)),
        UIBarButtonItem(customView: button)]

        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = self.view.frame

        view.addSubview(tableView)

         

        fetchTeamMembers()
        sdk = BoxSDK(clientId: Constants.clientId, clientSecret: Constants.clientSecret)
        getOAuthClient()
		
    }
	
	func setupLongPressGesture() {
		
		let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
		longPressGesture.minimumPressDuration = 1.0
		//longPressGesture.delegate = self
		self.tableView.addGestureRecognizer(longPressGesture)
		
	}
	@objc func fetchTeamRefresh() {
		
		fetchTeamMembers()
		
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let user = app.currentUser!
		//let partitionValue = user.id
		
		//let configuration = user.configuration(partitionValue: partitionValue)
		//NotificationCenter.default.post(name: ManageTeamViewController.notificationName, object: nil, userInfo: [passName: customers[indexPath.row].name])
		//let passName = customers[indexPath.row].name
		
       let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent(customers[indexPath.row].name)
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        
		let vc = RoomViewController(nibName: "RoomViewController", bundle: nil)
        vc.passId = customers[indexPath.row].id
        vc.passName =  customers[indexPath.row].name
        vc.customerFolderID =  customers[indexPath.row].customerFolderID
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
		navigationController?.pushViewController(vc, animated: true)

	}
	
	func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
	   print("table view button displayed")
	   //doSomethingWithItem(indexPath.row)
	   
		
		let vc = DisplayCustInfoViewController(nibName: "DisplayCustInfoViewController", bundle: nil)
			
		
		
			
			vc.passName =  customers[indexPath.row].name
			
			navigationController?.pushViewController(vc, animated: true)
			//present(UINavigationController(rootViewController: DisplayCustomerInfoController()), animated: true)
			//displayCustomerInfo  (name: customers[indexPath.row].name)
			
		
		
		
		
		
	   
	   
	   
   }
    
	
	@IBAction func handleLongPress(_ gestureRecognizer:UILongPressGestureRecognizer){
		if gestureRecognizer.state == .began {
			let touchPoint = gestureRecognizer.location(in: self.tableView)
			
			if let indexPath = tableView.indexPathForRow(at: touchPoint){
			let evc = EmployeeViewController(nibName: "EmployeeViewController", bundle: nil)
			evc.passCustID =  customers[indexPath.row].id
			
			navigationController?.pushViewController(evc, animated: true)
			}
		}
	}
	

	@objc func logOutButtonDidClick() {
		let alertController = UIAlertController(title: "Log Out", message: "", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Yes, Log Out", style: .destructive, handler: {
			_ -> Void in
			print("Logging out...")
			app.currentUser?.logOut { (_) in
				DispatchQueue.main.async {
					print("Logged out!")
					self.navigationController?.popViewController(animated: true)
				}
			}
		}))
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		self.present(alertController, animated: true, completion: nil)
	}

    @objc func addButtonDidClick() {
		present(UINavigationController(rootViewController: AddCustomerFormController()), animated: true)
		
		fetchTeamMembers()
    }
    
    @objc func boxSyncButtonDidClick() {
        let storyBoardController:UIStoryboard = UIStoryboard(name: "BoxSync", bundle: nil)
        let BoxviewController : BoxSyncViewController = storyBoardController.instantiateViewController(withIdentifier: "BoxSync") as! BoxSyncViewController
         
        

        
        //viewController.passName = passName
        //viewController.roomName =  roomName
        //print(self.passName)
        //print(self.roomName)
         
         self.navigationController!.pushViewController(BoxviewController, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let member = customers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.selectionStyle = .none
        cell.textLabel?.text = member.name
		cell.accessoryType = .detailDisclosureButton
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        removeCustomer(name: customers[indexPath.row].name, folderID: customers[indexPath.row].customerFolderID)
    }

    
	// Calls a Realm function to fetch the team members and adds them to the list
	func fetchTeamMembers() {
		// Start loading indicator
		activityIndicator.startAnimating()
		let user = app.currentUser!

		user.functions.getMyCustomersList([]) { [weak self](result, error) in
			DispatchQueue.main.async {
				guard self != nil else {
					// This can happen if the view is dismissed
					// before the operation completes
					print("Team members list no longer needed.")
					return
				}
				// Stop loading indicator
				self!.activityIndicator.stopAnimating()
				guard error == nil else {
					print("Fetch team members failed: \(error!.localizedDescription)")
					return
				}
				print("Fetch team members complete.")
				print(result!)
				// Convert documents to members array
				self!.customers = result!.arrayValue!.map({ (bson) in
					return Member(document: bson!.documentValue!)
					
					
				})

				// Notify UI of changed data
				self!.tableView.reloadData()
			}
		}
	}


	


    func removeCustomer(name: String, folderID: String) {
		print("Removing member: \(name)")
		activityIndicator.startAnimating()
		let user = app.currentUser!

		user.functions.removeCustomer([AnyBSON(name)], self.onTeamMemberOperationComplete)
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent(name)
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            do {
                try FileManager.default.removeItem(at: dataPath)
                
            } catch {
                print(error.localizedDescription)
            }
            print("customer folder removed")
        }
        
        
        client.folders.delete(folderId: folderID, recursive: true) { (result: Result<Void, BoxSDKError>) in
            guard case .success = result else {
                print("Error deleting folder")
                return
            }

            print("Folder and contents successfully deleted")
        
        }
        
        
        
        
	}
	
	
    func getOAuthClient() {
        tableView.refreshControl?.beginRefreshing()
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
    
    @available(iOS 13.0, *)
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
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
            fetchTeamMembers()
        }
    }
}
