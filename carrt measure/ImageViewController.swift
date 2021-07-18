//
//  ImageViewController.swift
//  Carrt Measure
//
//  Created by Varaha Maithreya on 6/27/21.
//  Copyright © 2021 carrt usf. All rights reserved.
//


#if os(iOS)
    import AuthenticationServices
#endif
import BoxPreviewSDK
import BoxSDK
import UIKit
import Photos

class ImageViewController: UITableViewController, ASWebAuthenticationPresentationContextProviding, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var model: dataPassage!
    private var sdk: BoxSDK!
    private var client: BoxClient!
    private var previewSDK: BoxPreviewSDK?
    private var folderItems: [FolderItem] = []
    private var folderItemsID: [String] = []
    private let initialPageSize: Int = 100
    private weak var imageView : UIImageView!
    var imageName: String!
    var imagePicker : UIImagePickerController = UIImagePickerController()
    var roomName: String = ""
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

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = roomName
        sdk = BoxSDK(clientId: Constants.clientId, clientSecret: Constants.clientSecret)
        getOAuthClient()
        getSinglePageOfFolderItems()
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Add Asset", style: .plain, target: self, action: #selector(AddImagePressed)), UIBarButtonItem(title: "Lidar Scans ",style: .plain, target: self, action: #selector(ScansButtonDidClick))]
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.tableFooterView = UIView()
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(getSinglePageOfFolderItems), for: .valueChanged)
        tableView.refreshControl = refresh
    }

    // MARK: - Actions

    
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
    
    @objc func ScansButtonDidClick() {
        
        let storyBoardController:UIStoryboard = UIStoryboard(name: "LidarScanModule", bundle: nil)
        let viewController : LidarScanModuleViewController = storyBoardController.instantiateViewController(withIdentifier: "LidarScanModule") as! LidarScanModuleViewController
        
        viewController.model = model
         
         self.navigationController!.pushViewController(viewController, animated: true)
        
    }
    
    
    @objc func AddImagePressed() {
       
                
                let alertController : UIAlertController = UIAlertController(title: "Title", message: "Select Camera or Photo Library", preferredStyle: .actionSheet)
                let cameraAction : UIAlertAction = UIAlertAction(title: "Camera", style: .default, handler: { [self] (cameraAction) in
                   
                    print("camera-A Selected...")
                    let storyBoardController:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController : ARViewController = storyBoardController.instantiateViewController(withIdentifier: "Main") as! ARViewController
                    
                    viewController.model = model
                     
                     self.navigationController!.pushViewController(viewController, animated: true)
                    
                   
               })

                let libraryAction : UIAlertAction = UIAlertAction(title: "Photo Library", style: .default, handler: { [self](libraryAction) in

                   print("Photo library selected....")
                    
                    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) == true {
                        imagePicker.allowsEditing = false
                        imagePicker.delegate = self
                        self.imagePicker.sourceType = .photoLibrary
                        self.present()
                   print("library available")
                   }
                    
                    else{

                    self.present(self.showAlert(Title: "Title", Message: "Photo Library is not available on this Device or accesibility has been revoked!"), animated: true, completion: nil)
                   }
               })
        
        let ScanAsset : UIAlertAction = UIAlertAction(title: "3D Scan", style: .default, handler: { [self](libraryAction) in

           print("3D Scan selected....")
            let storyBoardController:UIStoryboard = UIStoryboard(name: "LidarScanModule", bundle: nil)
            let viewController : LidarScanModuleViewController = storyBoardController.instantiateViewController(withIdentifier: "LidarScanModule") as! LidarScanModuleViewController
            
            viewController.model = model
             
             self.navigationController!.pushViewController(viewController, animated: true)
            
            
          
       })

                let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel , handler: {(cancelActn) in
               print("Cancel action was pressed")
               })

               alertController.addAction(cameraAction)

               alertController.addAction(libraryAction)
               
               alertController.addAction(ScanAsset)

               alertController.addAction(cancelAction)

                if let popoverController = alertController.popoverPresentationController {
                  popoverController.sourceView = self.view
                  popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                  popoverController.permittedArrowDirections = []
                }

                self.present(alertController, animated: true, completion: nil)
    }
        
        
        


    func present(){

        self.present(imagePicker, animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         
        if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL{
                let imgName = imgUrl.lastPathComponent
                let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                let localPath = documentDirectory?.appending(imgName)

                let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
                let data = image.pngData()! as NSData
                data.write(toFile: localPath!, atomically: true)
                let photoURL = URL.init(fileURLWithPath: localPath!)
                let filename = photoURL.lastPathComponent
                print(filename)
           
            
            let filenamealertController = UIAlertController(title: "Add Image", message: "", preferredStyle: .alert)
          
            
         
            filenamealertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { [self]
                _ -> Void in
                let textField = filenamealertController.textFields![0] as UITextField
                print("Adding Image: \(String(describing: textField.text))")
                
                    
                var Imagename: String? {
                    get {
                        return textField.text
                    }
                }
            
            
                let _: BoxUploadTask = client.files.upload(data: data as Data, name: "\(String(describing: Imagename!)).jpg", parentId: model.roomID) { (result: Result<File, BoxSDKError>) in
                guard case let .success(file) = result else {
                    print("Error uploading file")
                    return
                }

                print("File \(String(describing: file.name)) was uploaded at \(String(describing: file.createdAt)) into \"\(String(describing: file.parent?.name))\"")
                    
              
                    }
            }
             
            
        )
        )
        filenamealertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        filenamealertController.addTextField(configurationHandler: { (textField: UITextField!) -> Void in
                    textField.placeholder = "New Image Name"
                })

                // Show the dialog.
            
            if self.presentedViewController==nil{
                self.present(filenamealertController, animated: true, completion: nil)
            }else{
                self.presentedViewController!.present(filenamealertController, animated: true, completion: nil)
            }
               // self.present(filenamealertController, animated: true, completion: nil)
               
                
                
        

//        dismiss(animated: true)
        }}

    
    
    
  /*  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       // let tempImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
               let assetResources = PHAssetResource.assetResources(for: asset)
               imageName = assetResources.first!.originalFilename
               print(assetResources.first!.originalFilename)
            print("hi")
            
           }
       
        //guard let data = "test content".data(using: .) else { return <#default value#> }

        guard let imgData = tempImage.pngData() else { return  }
        
        let _: BoxUploadTask = client.files.upload(data: imgData, name: imageName, parentId: model.roomID) { (result: Result<File, BoxSDKError>) in
            guard case let .success(file) = result else {
                print("Error uploading file")
                return
            }

            print("File \(String(describing: file.name)) was uploaded at \(String(describing: file.createdAt)) into \"\(String(describing: file.parent?.name))\"")
        }

        // To cancel upload
        /*if someConditionIsSatisfied {
            task.cancel()
        }
        */
        self.dismiss(animated: true, completion: nil)
        
    }*/
   

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return folderItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath)
        let item = folderItems[indexPath.row]
        if case let .file(file) = item {
            cell.textLabel?.text = file.name
            cell.detailTextLabel?.text = String(format: "Date Modified %@", dateFormatter.string(from: file.modifiedAt ?? Date()))
            cell.accessoryType = .none
            var icon: String
            switch file.extension {
            case "boxnote":
                icon = "boxnote"
            case "jpg",
                 "jpeg",
                 "png",
                 "tiff",
                 "tif",
                 "gif",
                 "bmp",
                 "BMPf",
                 "ico",
                 "cur",
                 "xbm":
                icon = "image"
                if folderItemsID.contains(file.id) == false{
                    folderItemsID.append(file.id)}
            case "pdf":
                icon = "pdf"
            case "docx":
                icon = "word"
            case "pptx":
                icon = "powerpoint"
            case "xlsx":
                icon = "excel"
            case "zip":
                icon = "zip"
            default:
                icon = "generic"
            }
            cell.imageView?.image = UIImage(named: icon)
        }
        else if case let .folder(folder) = item {
            cell.textLabel?.text = folder.name
            cell.detailTextLabel?.text = ""
            cell.accessoryType = .disclosureIndicator
            cell.imageView?.image = UIImage(named: "folder")
            
        }

        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = folderItems[indexPath.row]
//        if case let .file(file) = item {
//            showPreviewViewController(file: file)
//        }
        
        if case let .file(file) = item {
            showImagePreviewViewController(images: folderItemsID, selectedimageid: file.id )
            
        }
    }
}

// MARK: - Helpers

private extension ImageViewController {
    func getOAuthClient() {
        tableView.refreshControl?.beginRefreshing()
        if #available(iOS 13, *) {
            sdk.getOAuth2Client(tokenStore: KeychainTokenStore(), context:self) { [weak self] result in
                switch result {
                case let .success(client):
                    self?.client = client
                    self?.previewSDK = BoxPreviewSDK(client: client)
                    self?.getSinglePageOfFolderItems()
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
                    self?.previewSDK = BoxPreviewSDK(client: client)
                    self?.getSinglePageOfFolderItems()
                case let .failure(error):
                    print("error in getOAuth2Client: \(error)")
                    self?.addErrorView(with: error)
                }
            }
        }
    }

    @objc func getSinglePageOfFolderItems() {
        client.folders.listItems(
            folderId: model.roomID,
            usemarker: true,
            fields: ["modified_at", "name", "extension"]
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
                                    

                                self.tableView.reloadData()
                                
                            }
                        case let .failure(error):
                            print ("     No Item #\(String(format: "%03d", i)) | \(error.message)")
                            return
                        }
                    }
                }
            case let .failure(error):
                print("error in getSinglePageOfFolderItems: \(error)")
                self.addErrorView(with: error)
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    func showPreviewViewController(file: File) {
        let previewController: PreviewViewController? = previewSDK?.openFile(file: file, delegate: self)

        
        
        guard let unwrappedPreviewController = previewController else {
            return
        }

        navigationController?.pushViewController(unwrappedPreviewController, animated: true)
    }
    
    
    func openImageFiles(
        fileIds: [String],
        selectedId: String,
        delegate: PreviewViewControllerDelegate? = nil,
        allowedAction: [FileInteractions] = FileInteractions.allCases,
        displayThumbnails: Bool = true) -> PreviewPageViewController {
        guard let selectedFileIndex = fileIds.firstIndex(of: selectedId) else {
            fatalError("Provided wrong selected file id")
        }

        return PreviewPageViewController(
            client: client,
            fileIds: fileIds,
            index: selectedFileIndex,
            delegate: delegate,
            allowedActions: allowedAction,
            displayThumbnails: displayThumbnails
        )
    }
    
    
    func showImagePreviewViewController(images: [String], selectedimageid: String)
    
    {
        let previewController: PreviewPageViewController? = openImageFiles(fileIds: images, selectedId: selectedimageid)
        
        guard let unwrappedPreviewController = previewController else {
            return
        }

        navigationController?.pushViewController(unwrappedPreviewController, animated: true)
    }
    
}






extension ImageViewController: PreviewViewControllerDelegate {

    func previewViewControllerFailed(error: BoxPreviewError) {
        print("Error returned by PreviewViewController: \(error)")
    }

    func makeCustomErrorView() -> ErrorView? {
        // Create custom error view here
        return nil
    }
}

private extension ImageViewController {

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

// MARK: - ASWebAuthenticationPresentationContextProviding

/// Extension for ASWebAuthenticationPresentationContextProviding conformance
extension ImageViewController {
    @available(iOS 13.0, *)
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}

