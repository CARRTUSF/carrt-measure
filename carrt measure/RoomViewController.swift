#if os(iOS)
    import AuthenticationServices
#endif


import UIKit
import RealmSwift
import Foundation
import SwiftUI
import Combine
import BoxSDK
//import FirebaseStorage

class RoomViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate,  UITableViewDelegate, UITableViewDataSource, ASWebAuthenticationPresentationContextProviding{
    
    
	var imagePicker : UIImagePickerController = UIImagePickerController()
    var passName:String = ""
	var passId:String = ""
    var customerFolderID: String = ""
	var url:String = ""
    let tableView = UITableView()
	var Rooms: [customerRoom] = []
	var ImageFetchedRoomList: [customerRoom] = []
    var roomName:String = ""
    private var sdk: BoxSDK!
    private var client: BoxClient!
    
    private var folderItems: [FolderItem] = []
    private let initialPageSize: Int = 100
    
	//var notificationToken: NotificationToken?
	private weak var imageView : UIImageView!
    private var model = dataPassage()
   
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
		
		//setupLongPressGesture()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.frame = self.view.frame
        
        view.addSubview(tableView)
		//NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: ManageTeamViewController.notificationName, object: nil)
		print(passId)
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidClick))
		/*let imageView = UIImageView(frame: CGRect(x: 400, y: 80, width: 400, height: 400))
				imageView.backgroundColor = .lightGray
				view.addSubview(imageView)
				self.imageView = imageView*/
		fetchRooms()
        sdk = BoxSDK(clientId: Constants.clientId, clientSecret: Constants.clientSecret)
        getOAuthClient()
         
            
		
		
		
		
		//NotificationCenter.default.removeObserver(self)
		/*if isOwnScans() {
			
			toolbarItems = [
				UIBarButtonItem(title: "Manage Rooms", style: .plain, target: self, action: #selector(manageTeamButtonDidClick))
			]
			navigationController?.isToolbarHidden = false
		}*/
	}

	/*@objc func onNotification(notification:Notification)
	{
		print(notification.userInfo )
	}*/
//	func setupLongPressGesture() {
//
//		let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
//		longPressGesture.minimumPressDuration = 1.0
//		//longPressGesture.delegate = self
//		self.tableView.addGestureRecognizer(longPressGesture)
//
//	}
//
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
       let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent("/\(passName)/\(Rooms[indexPath.row].name)")
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        
       
        model.roomID = Rooms[indexPath.row].roomID
        
        
        let storyBoardController:UIStoryboard = UIStoryboard(name: "ImageView", bundle: nil)
        let viewController : ImageViewController = storyBoardController.instantiateViewController(withIdentifier: "ImageView") as! ImageViewController
        viewController.passName = passName
        viewController.roomName = Rooms[indexPath.row].name
        viewController.model = model

      
        //print(self.passId)
        //print(self.roomName)
         
         self.navigationController!.pushViewController(viewController, animated: true)
        
        
         
        

        
        //viewController.passId = passId
        //viewController.roomName =  roomName
        //print(self.passId)
        //print(self.roomName)
         
        
        
        
       
		//let ImageroomName = Rooms[indexPath.row].name
		/*if Rooms[indexPath.row].roomID != "" || Rooms[indexPath.row].roomID.isEmpty == false {
			
            roomName = Rooms[indexPath.row].name
            model.roomID = Rooms[indexPath.row].id
            print(model.roomID)
			/* getRoomImage(name: passId, ImageroomName: ImageroomName)
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in // Change `2.0` to the desired number of seconds.
			print("inside delay")
			
			let ImageFetchedRoom =  ImageFetchedRoomList[0]
			// Code you want to be delayed
		}*/
		
			/*let tempImage = convertBase64StringToImage(imageBase64String: Rooms[indexPath.row].scanImage)
			imageView.image  = tempImage
				self.imageView.reloadInputViews()*/
           
            
          /*  let vc = model
                   let childView = UIHostingController(rootView: PhotoGalleryView(model: vc))
            
            present(childView, animated: true, completion: nil)*/
           // let hostingController = UIHostingController(rootView: PhotoGalleryView(, model: <#dataPassage#>))
				
           
                

				//present(hostingController, animated: true, completion: nil)
			//self.navigationController!.pushViewController(GalleryView(), animated: true)
                    
		}
		else{
            roomName = Rooms[indexPath.row].name
            model.roomID = Rooms[indexPath.row].roomID
            print(model.roomID)
            //let vc = model
                   //let childView = UIHostingController(rootView: PhotoGalleryView(model: vc))
            
           // present(childView, animated: true, completion: nil)			//let hostingController = UIHostingController(rootView: PhotoGalleryView())
				
				

				//present(hostingController, animated: true, completion: nil)
			
			//self.present(self.showAlert(Title: "Alert", Message: "no image found. please upload one"), animated: true, completion: nil)
			
		}*/
		
		
		
		
	}
//	@IBAction func handleLongPress(_ gestureRecognizer:UILongPressGestureRecognizer){
//
//
//		if gestureRecognizer.state == .began {
//			let touchPoint = gestureRecognizer.location(in: self.tableView)
//
//
//
//
//			if let indexPath = tableView.indexPathForRow(at: touchPoint){
//
//				roomName = Rooms[indexPath.row].name
//
//				// User selected a task in the table. We will present a list of actions that the user can perform on this task.
//
//				let alertController : UIAlertController = UIAlertController(title: "Title", message: "Select Camera or Photo Library", preferredStyle: .actionSheet)
//				let cameraAction : UIAlertAction = UIAlertAction(title: "Camera", style: .default, handler: { [self] (cameraAction) in
//
//					print("camera-A Selected...")
//
//					let storyBoardController:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//					let viewController : ARViewController = storyBoardController.instantiateViewController(withIdentifier: "Main") as! ARViewController
//
//
//
//
//
//					//print(self.passId)
//					//print(self.roomName)
//
//					 self.navigationController!.pushViewController(viewController, animated: true)
//
//
//
//
//
//					/*if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {
//						imagePicker.allowsEditing = false
//						self.imagePicker.sourceType = .camera
//					   self.present()
//
//				   }else{
//					self.present(self.showAlert(Title: "Title", Message: "Camera is not available on this Device or accesibility has been revoked!"), animated: true, completion: nil)
//
//				   }*/
//
//			   })
//
//				let libraryAction : UIAlertAction = UIAlertAction(title: "Photo Library", style: .default, handler: { [self](libraryAction) in
//
//				   print("Photo library selected....")
//
//					if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) == true {
//						imagePicker.allowsEditing = false
//						imagePicker.delegate = self
//						self.imagePicker.sourceType = .photoLibrary
//					   self.present()
//		print("library available")
//				   }else{
//
//					self.present(self.showAlert(Title: "Title", Message: "Photo Library is not available on this Device or accesibility has been revoked!"), animated: true, completion: nil)
//				   }
//			   })
//
//				let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel , handler: {(cancelActn) in
//			   print("Cancel action was pressed")
//			   })
//
//			   alertController.addAction(cameraAction)
//
//			   alertController.addAction(libraryAction)
//
//			   alertController.addAction(cancelAction)
//
//			   //alertController.popoverPresentationController?.sourceView = view
//			   //alertController.popoverPresentationController?.sourceRect = view.frame
//
//
//				if let popoverController = alertController.popoverPresentationController {
//				  popoverController.sourceView = self.view
//				  popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//				  popoverController.permittedArrowDirections = []
//				}
//
//				self.present(alertController, animated: true, completion: nil)
//}
//		}
//	}

	
	/*func makeUIViewController(context:
			 UIViewControllerRepresentableContext<ARView>) -> ARViewController {
		let storyboard = UIStoryboard(name: "Main",     // < your storyboard name here
			  bundle: nil)
		let assetsListVC = storyboard.instantiateViewController(identifier:
			  "ARViewController")      // < your controller storyboard id here

		assetsListVC.taskID = taskID
		return assetsListVC

	}*/
	
	
	
	
//	func convertBase64StringToImage (imageBase64String:String) -> UIImage {
//		let imageData = Data.init(base64Encoded: imageBase64String, options: .init(rawValue: 0))
//		let image = UIImage(data: imageData!)
//		return image!
//	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Rooms.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// This defines how the Tasks in the list look.
		// We want the task name on the left and some indication of its status on the right.
		let room = Rooms[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
		cell.selectionStyle = .none
		cell.textLabel?.text = room.name
		
		/*switch room.statusEnum {
		case .empty:
			cell.accessoryView = nil
			cell.accessoryType = UITableViewCell.AccessoryType.none
		case .InProgress:
			let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
			label.text = "In Progress"
			cell.accessoryView = label
		case .Uploaded:
			cell.accessoryView = nil
			cell.accessoryType = UITableViewCell.AccessoryType.checkmark
		}*/
		return cell
	}
	 
	@objc func addButtonDidClick() {
		let alertController = UIAlertController(title: "Add Room", message: "", preferredStyle: .alert)
		let id = UUID().uuidString
		
		//var owner:String = ""		// When the user clicks the add button, present them with a dialog to enter the task name.
		alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { [self]
			_ -> Void in
			let textField = alertController.textFields![0] as UITextField
			print("Adding Room: \(String(describing: textField.text))")
			
				let user = app.currentUser!
			var name: String? {
				get {
					return textField.text
				}
			}
            
            
			
            client.folders.create(name: name!, parentId: customerFolderID) { (result: Result<Folder, BoxSDKError>) in
                guard case let .success(folder) = result else {
                    print("Error creating folder")
                    return
                }
                
                print("Created folder \"\(String(describing: folder.name))\" inside of folder \"\(String(describing: folder.parent?.name))\"")
                user.functions.addRoom([AnyBSON(id), AnyBSON(name!), AnyBSON(passId), AnyBSON(folder.id),AnyBSON(folder.parent!.id)], self.onTeamMemberOperationComplete)
                
                
            }
            
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            let docURL = URL(string: documentsDirectory)!
            let dataPath = docURL.appendingPathComponent("/\(passName)/\(name!)")
            if !FileManager.default.fileExists(atPath: dataPath.path) {
                do {
                    try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                }
            }
            
			/*user.functions.addRoom([AnyBSON(id), AnyBSON(name!), AnyBSON(passId), AnyBSON(roomid)], self.onTeamMemberOperationComplete)*/
			//let room = Room(partition: self.partitionValue, name: textField.text ?? "New Room")

			// Any writes to the Realm must occur in a write block.
			//try! self.realm.write {
				// Add the Task to the Realm. That's it!
				//self.realm.add(room)
			//}

		}))
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alertController.addTextField(configurationHandler: { (textField: UITextField!) -> Void in
			textField.placeholder = "New Room Name"
		})

		// Show the dialog.
		self.present(alertController, animated: true, completion: nil)
		
		fetchRooms()
	}

	func fetchRooms() {
		// Start loading indicator
		
		let user = app.currentUser!

		user.functions.getCustomerRoomsList([AnyBSON(passId)]) { [weak self](result, error) in
			DispatchQueue.main.async {
				guard self != nil else {
					// This can happen if the view is dismissed
					// before the operation completes
					print("Team members list no longer needed.")
					return
				}
				// Stop loading indicator
				guard error == nil else {
					print("Fetch team members failed: \(error!.localizedDescription)")
					return
				}
				print("Fetch team members complete.")
				print(result!)
				// Convert documents to members array
				self!.Rooms = result!.arrayValue!.map({ (bson) in
					return customerRoom(document: bson!.documentValue!)
					
					
				})

				// Notify UI of changed data
				self!.tableView.reloadData()
			}
		}
	}
	
	
	
	
	func present(){

		self.present(imagePicker, animated: true, completion: nil)

	}


//	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//		let tempImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
//		imageView.image  = tempImage
//		/*if let data = tempImage.pngData() { // convert your UIImage into Data object using png representation
//			  FirebaseStorageManager().uploadImageData(data: data, serverFileName: "your_server_file_name.png") { (isSuccess, url) in
//					 print("uploadImageData: \(isSuccess), \(url)")
//			   }
//		}*/
//		let user = app.currentUser!
//		let name = convertImageToBase64String(img: tempImage)
//		print("adding room image ", roomName)
//		user.functions.addRoomImage([AnyBSON(passId), AnyBSON(roomName), AnyBSON(name)], self.onTeamMemberOperationComplete)
//
//
//
//		self.dismiss(animated: true, completion: nil)
//
//	}
//	func convertImageToBase64String (img: UIImage) -> String {
//		return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
//	}
//
//	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//		dismiss(animated: true, completion: nil)
//	}


	//Show Alert


	func showAlert(Title : String!, Message : String!)  -> UIAlertController {

		let alertController : UIAlertController = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
		let okAction : UIAlertAction = UIAlertAction(title: "Ok", style: .default) { (alert) in
		   print("User pressed ok function")

	   }

	   alertController.addAction(okAction)
	   alertController.popoverPresentationController?.sourceView = view
	   alertController.popoverPresentationController?.sourceRect = view.frame

	   return alertController
	 }

	private func onTeamMemberOperationComplete(result: AnyBSON?, realmError: Error?) {
		DispatchQueue.main.async { [self] in
			// Always be sure to stop the activity indicator
			
			
			
			//navigationController!.pushViewController(ManageTeamViewController(), animated: true)
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
			//present(UINavigationController(rootViewController: ManageTeamViewController()), animated: true)
			print("manage team view out")
            fetchRooms()
		}
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }

        removeRoom(roomID: Rooms[indexPath.row].id , folderID: Rooms[indexPath.row].roomID, name: Rooms[indexPath.row].name)
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
    
    func removeRoom(roomID: String, folderID: String, name: String) {
        print("Removing room: \(roomID)")
        //activityIndicator.startAnimating()
        let user = app.currentUser!

        user.functions.removeRoom([AnyBSON(roomID)], self.onTeamMemberOperationComplete)
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent("/\(passName)/\(name)")
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            do {
                try FileManager.default.removeItem(at: dataPath)
                
            } catch {
                print(error.localizedDescription)
            }
            print("Room folder removed")
        }
        
        
        client.folders.delete(folderId: folderID, recursive: true) { (result: Result<Void, BoxSDKError>) in
            guard case .success = result else {
                print("Error deleting folder")
                return
            }

            print("Folder and contents successfully deleted")
        
        }
        
        
        
        
    }
    
//	func getRoomImage(name: String, ImageroomName: String) {
//		print("fetching image of: \(ImageroomName)")
//
//		let group = DispatchGroup()
//		group.enter()
//		print("hello")
//
//		let user = app.currentUser!
//		user.functions.getRoomImage([AnyBSON(passId), AnyBSON(ImageroomName)] ) { [weak self](result, error) in
//			DispatchQueue.main.async { [self] in
//				guard self != nil else {
//					// This can happen if the view is dismissed
//					// before the operation completes
//					print("customer details no longer needed.")
//					return
//				}
//				// Stop loading indicator
//
//
//				guard error == nil else {
//					print("Fetch customer details failed: \(error!.localizedDescription)")
//					return
//				}
//				print("Fetch customer details complete.")
//
//				print(result!)
//				print("hi")
//				group.leave()
//				print("yeah")								// Convert documents to members array
//				self!.ImageFetchedRoomList = result!.arrayValue!.map({ (bson) in
//					return customerRoom(document: bson!.documentValue!)
//
//
//				})
//							// Notify UI of changed data
//
//
//					}
//
//
//		}
//
//		print("wassup")
//
//
//		}
	// Returns true if these are the user's own scans.
	/*func isOwnRoom() -> Bool {
		return partitionValue == "project=\(app.currentUser!.id)"
	   
	}*/


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    

}

private extension RoomViewController {

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
}
extension RoomViewController {
    @available(iOS 13.0, *)
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}
