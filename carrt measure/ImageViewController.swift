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
import Zip


class ImageViewController: UITableViewController, ASWebAuthenticationPresentationContextProviding, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    

    
    
    var model: dataPassage!
    private var sdk: BoxSDK!
    private var client: BoxClient!
    private var previewSDK: BoxPreviewSDK?
    private var folderItems: [FolderItem] = []
    var filePath: URL!
    var fileName: String = ""
    var unzipDirectory: URL!
    var passfilePath: URL!
    
    var passName: String = ""
    private var openedDatabasePath: URL?
    private var currentDatabaseIndex: Int = 0
    private var databases = [URL]()
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
    func getDocumentDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func updateDatabases()
    {
        databases.removeAll()
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: getDocumentDirectory().appendingPathComponent("/\(passName)/\(roomName)"), includingPropertiesForKeys: nil)
            // if you want to filter the directory contents you can do like this:
            
            let data = fileURLs.map { url in
                        (url, (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast)
                    }
                    .sorted(by: { $0.1 > $1.1 }) // sort descending modification dates
                    .map { $0.0 } // extract file names
            databases = data.filter{ $0.pathExtension == "zip" }
            print("exiting updateDatabases")
            
        } catch {
            print("Error while enumerating files : \(error.localizedDescription)")
            return
        }
    }
    
    @objc func ScansButtonDidClick() {
        
        
            updateDatabases();
            print("entering alertController creation")
            if databases.isEmpty {
                return
            }
            
            let alertController = UIAlertController(title: "Lidar Scans", message: nil, preferredStyle: .alert)
            let customView = VerticalScrollerView()
            customView.dataSource = self
            customView.delegate = self
            customView.reload()
        print("Image View Controller line: 130")
            alertController.view.addSubview(customView)
            customView.translatesAutoresizingMaskIntoConstraints = false
            customView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 60).isActive = true
            customView.rightAnchor.constraint(equalTo: alertController.view.rightAnchor, constant: -10).isActive = true
            customView.leftAnchor.constraint(equalTo: alertController.view.leftAnchor, constant: 10).isActive = true
            customView.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -45).isActive = true
            
            alertController.view.translatesAutoresizingMaskIntoConstraints = false
            alertController.view.heightAnchor.constraint(equalToConstant: 600).isActive = true
            alertController.view.widthAnchor.constraint(equalToConstant: 400).isActive = true

            customView.backgroundColor = .darkGray

            let selectAction = UIAlertAction(title: "Select", style: .default) { (action) in
                self.openObjViewer(fileUrl: self.databases[self.currentDatabaseIndex])
                print("zip file url is \(self.databases[self.currentDatabaseIndex])" )
            }
              
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(selectAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        print("Image View Controller line: 152")
        
    }
    
    
    func openObjViewer(fileUrl: URL) {
        
        //unzipObjfile(fileUrl: filePath)
        
        let storyBoardController:UIStoryboard = UIStoryboard(name: "objView", bundle: nil)
        let viewController : objPreviewViewController =  storyBoardController.instantiateViewController(withIdentifier: "objView") as! objPreviewViewController
        
       
        viewController.filePath = fileUrl
        viewController.fileName = fileUrl.lastPathComponent//.replacingOccurrences(of: ".zip", with: ".obj")
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
            viewController.CustomerName = passName
            viewController.RoomName = roomName
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
    
    func unzipObjfile(fileUrl: URL){
        let fileManager = FileManager()
        //let currentWorkingPath = fileManager.currentDirectoryPath
        //var sourceURL = fileUrl
        //sourceURL.appendPathComponent("file.txt")
        //var destinationURL = URL(fileURLWithPath: currentWorkingPath)
       // destinationURL.appendPathComponent("archive.zip")
        do {
             unzipDirectory = try Zip.quickUnzipFile(fileUrl)
            print("Directory unzipped")
            print(try fileManager.contentsOfDirectory(at: unzipDirectory, includingPropertiesForKeys: [.nameKey, .fileSizeKey]))
            
        } catch {
            print("Creation of ZIP archive failed with error:\(error)")
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
extension ImageViewController: VerticalScrollerViewDelegate {
    func verticalScrollerView(_ horizontalScrollerView: VerticalScrollerView, didSelectViewAt index: Int) {
    //1
    let previousDatabaseView = horizontalScrollerView.view(at: currentDatabaseIndex) as! objView
    previousDatabaseView.highlightobj(false)
    //2
    currentDatabaseIndex = index
    //3
    let databaseView = horizontalScrollerView.view(at: currentDatabaseIndex) as! objView
    databaseView.highlightobj(true)
    //4
  }
}

extension ImageViewController: VerticalViewDataSource {
  func numberOfViews(in horizontalScrollerView: VerticalScrollerView) -> Int {
    return databases.count
  }
  
  func getScrollerViewItem(_ horizontalScrollerView: VerticalScrollerView, viewAt index: Int) -> UIView {
    print(databases[index].path)
    let objView = objView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), objURL: databases[index])

    objView.delegate = self
    
    if currentDatabaseIndex == index {
        objView.highlightobj(true)
    } else {
        objView.highlightobj(false)
    }

    return objView
  }
}

extension ImageViewController: objViewDelegate {
    
    
    func objShared(objURL: URL) {
        self.dismiss(animated: true)
        self.shareFile(objURL)
    }
    
    func objRenamed(objURL: URL) {
        self.dismiss(animated: true)
        
        if(openedDatabasePath?.lastPathComponent == objURL.lastPathComponent)
        {
            let alertController = UIAlertController(title: "Rename Database", message: "Database \(objURL.lastPathComponent) is already opened, cannot rename it.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            alertController.addAction(okAction)
            present(alertController, animated: true)
            return
        }
        
        self.rename(fileURL: objURL)
    }
    
    func rename(fileURL: URL)
    {
        //Step : 1
        let alert = UIAlertController(title: "Rename Scan", message: "Scan Database Name (*.db):", preferredStyle: .alert )
        //Step : 2
        let rename = UIAlertAction(title: "Rename", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if textField.text != "" {
                //Read TextFields text data
                let fileName = textField.text!+".db"
                let filePath = self.getDocumentDirectory().appendingPathComponent("/\(self.passName)/\(self.roomName)/\(fileName)").path
                if FileManager.default.fileExists(atPath: filePath) {
                    let alert = UIAlertController(title: "File Already Exists", message: "Do you want to overwrite the existing file?", preferredStyle: .alert)
                    let yes = UIAlertAction(title: "Yes", style: .default) {
                        (UIAlertAction) -> Void in
                        
                        do {
                            try FileManager.default.moveItem(at: fileURL, to: URL(fileURLWithPath: filePath))
                            print("File \(fileURL) renamed to \(filePath)")
                        }
                        catch {
                            print("Error renaming file \(fileURL) to \(filePath)")
                        }
                       // self.openLibrary()
                    }
                    alert.addAction(yes)
                    let no = UIAlertAction(title: "No", style: .cancel) {
                        (UIAlertAction) -> Void in
                    }
                    alert.addAction(no)
                    
                    self.present(alert, animated: true, completion: nil)
                } else {
                    do {
                        try FileManager.default.moveItem(at: fileURL, to: URL(fileURLWithPath: filePath))
                        print("File \(fileURL) renamed to \(filePath)")
                    }
                    catch {
                        print("Error renaming file \(fileURL) to \(filePath)")
                    }
                    //self.openLibrary()
                }
            }
        }

        //Step : 3
        alert.addTextField { (textField) in
            var components = fileURL.lastPathComponent.components(separatedBy: ".")
            if components.count > 1 { // If there is a file extension
              components.removeLast()
                textField.text = components.joined(separator: ".")
            } else {
                textField.text = fileURL.lastPathComponent
            }
        }

        //Step : 4
        alert.addAction(rename)
        //Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { (alertAction) in })

        self.present(alert, animated: true) {
            alert.textFields?.first?.selectAll(nil)
        }
    }
    
    func shareFile(_ fileUrl: URL) {
        let fileURL = NSURL(fileURLWithPath: fileUrl.path)

        // Create the Array which includes the files you want to share
        var filesToShare = [Any]()

        // Add the path of the file to the Array
        filesToShare.append(fileURL)

        // Make the activityViewContoller which shows the share-view
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }

        // Show the share-view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func objDeleted(objURL: URL) {
        self.dismiss(animated: true)
        
        if(openedDatabasePath?.lastPathComponent == objURL.lastPathComponent)
        {
            let alertController = UIAlertController(title: "Delete Database", message: "Database \(objURL.lastPathComponent) is already opened, cannot delete it.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            alertController.addAction(okAction)
            present(alertController, animated: true)
            return
        }
        
        do {
            try FileManager.default.removeItem(at: objURL)
            print("File \(objURL) deleted")
        }
        catch {
            print("Error deleting file \(objURL)")
        }
        self.updateDatabases()
        if(!databases.isEmpty)
        {
            //self.openLibrary()
        }
        else {
            //self.updateState(state: self.mState)
        }
    }
  }
