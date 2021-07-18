
import Photos
import UIKit

class ImagePickViewController:  UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
	
	var imagePicker : UIImagePickerController = UIImagePickerController()
    
 override func viewDidLoad() {
   super.viewDidLoad()
	let view = UIView()
   let addPictureBtn = UIButton(type: .system)

   imagePicker.delegate = self
	addPictureBtn.frame = CGRect(x: 20, y: 20, width: 100, height: 50)
	addPictureBtn.setTitle("Tap me", for: .normal)
	addPictureBtn.setTitle("Pressed + Hold", for: .highlighted)
	addPictureBtn.setTitle("add", for: .normal)
	addPictureBtn.addTarget(self , action: #selector(addPictureBtnAction) , for: .touchUpInside)
	view.addSubview(addPictureBtn)
		  self.view = view
  }



	//============================================================================================================================================================

//////
//
//PROFILE PICTURE FUNCTIONS
//
/////




@IBAction func addPictureBtnAction(sender: UIButton) {

   //addPictureBtn.enabled = false

	let alertController : UIAlertController = UIAlertController(title: "Title", message: "Select Camera or Photo Library", preferredStyle: .actionSheet)
	let cameraAction : UIAlertAction = UIAlertAction(title: "Camera", style: .default, handler: {(cameraAction) in
	   print("camera-A Selected...")
		
		let viewController:UIViewController = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "Main")
		
		
		self.navigationController!.pushViewController(viewController, animated: true)
		//self.present(viewController, animated: false, completion: nil)
		
		
		//if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {

			//self.imagePicker.sourceType = .camera
		   //self.present()

	   //}else{
		//self.present(self.showAlert(Title: "Title", Message: "Camera is not available on this Device or //accesibility has been revoked!"), animated: true, completion: nil)

	   //}

   })

	let libraryAction : UIAlertAction = UIAlertAction(title: "Photo Library", style: .default, handler: {(libraryAction) in

	   print("Photo library selected....")

		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) == true {

			self.imagePicker.sourceType = .photoLibrary
		   self.present()

	   }else{

		self.present(self.showAlert(Title: "Title", Message: "Photo Library is not available on this Device or accesibility has been revoked!"), animated: true, completion: nil)
	   }
   })

	let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel , handler: {(cancelActn) in
   print("Cancel action was pressed")
   })

   alertController.addAction(cameraAction)

   alertController.addAction(libraryAction)

   alertController.addAction(cancelAction)

   alertController.popoverPresentationController?.sourceView = view
   alertController.popoverPresentationController?.sourceRect = view.frame

	self.present(alertController, animated: true, completion: nil)



}

func present(){

	self.present(imagePicker, animated: true, completion: nil)

}


func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
	print("info of the pic reached :\(info) ")
	self.imagePicker.dismiss(animated: true, completion: nil)

}




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
	
	/*func profilePictureUploading(infoOnThePicture : [String : AnyObject],completionBlock : (()->Void)) {

		if let referenceUrl = infoOnThePicture[UIImagePickerController.InfoKey.referenceURL.rawValue] {
			print(referenceUrl)

			let assets = PHAsset.fetchAssetsWithALAssetURLs([referenceUrl /*as! NSURL*/], options: nil)
			print(assets)

			let asset = assets.firstObject
			print(asset)

			asset?.requestContentEditingInputWithOptions(nil, completionHandler: { (ContentEditingInput, infoOfThePicture)  in

				let imageFile = ContentEditingInput?.fullSizeImageURL
				print("imagefile : \(imageFile)")

				let filePath = FIRAuth.auth()!.currentUser!.uid +  "/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000))/\(imageFile!.lastPathComponent!)"

				print("filePath : \(filePath)")


					FIRControllerClass.storageRef.child("ProfilePictures").child(filePath).putFile(imageFile!, metadata: nil, completion: {



						(metadata, error) in

							 if error != nil{

								print("error in uploading image : \(error)")

								self.delegate.firShowAlert("Error Uploading Your Profile Pic", Message: "Please check your network!")

							 }
							  else{

									print("metadata in : \(metadata!)")

									print(metadata?.downloadURL())

									print("The pic has been uploaded")

									print("download url : \(metadata?.downloadURL())")

									self.uploadSuccess(metadata!, storagePath: filePath)

									completionBlock()
						}

				})
			})

		}else{

				print("No reference URL found!")

		}
	}*/






	//Saving the path in your core data to search through later when you retrieve your picture from DB


	/*func uploadSuccess(metadata : FIRStorageMetadata , storagePath : String)
	{


		print("upload succeded!")

		print(storagePath)

		UserDefaults.standardUserDefaults().setObject(storagePath, forKey: "storagePath.\((FIRAuth.auth()?.currentUser?.uid)!)")

		UserDefaults.standardUserDefaults().synchronize()

	}*/
	

}
