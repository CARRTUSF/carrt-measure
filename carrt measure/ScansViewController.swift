import UIKit
import RealmSwift

class ScansViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView = UITableView()
    let partitionValue: String
    let realm: Realm
    var notificationToken: NotificationToken?
   
    let scans: Results<Scan>
	required init(realm: Realm, title: String) {

		// Ensure the realm was opened with sync.
		guard let syncConfiguration = realm.configuration.syncConfiguration else {
			fatalError("Sync configuration not found! Realm not opened with sync?")
		}

		self.realm = realm

		// Partition value must be of string type.
		partitionValue = syncConfiguration.partitionValue!.stringValue!

		
		scans = realm.objects(Scan.self).sorted(byKeyPath: "_id")

		super.init(nibName: nil, bundle: nil)

		self.title = title

	
		notificationToken = scans.observe { [weak self] (changes) in
			guard let tableView = self?.tableView else { return }
			switch changes {
			case .initial:
				
				tableView.reloadData()
			case .update(_, let deletions, let insertions, let modifications):
				// Query results have changed, so apply them to the UITableView.
				tableView.performBatchUpdates({
					// It's important to be sure to always update a table in this order:
					// deletions, insertions, then updates. Otherwise, you could be unintentionally
					// updating at the wrong index!
					tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }),
						with: .automatic)
					tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
						with: .automatic)
					tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
						with: .automatic)
				})
			case .error(let error):
				// An error occurred while opening the Realm file on the background worker thread
				fatalError("\(error)")
			}
		}
	}


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
		notificationToken?.invalidate()
    }

    override func viewDidLoad() {
        // Configure the view.
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = self.view.frame
        view.addSubview(tableView)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidClick))

        if isOwnScans() {
            // Only set up the manage team button if these are tasks the user owns.
            toolbarItems = [
                UIBarButtonItem(title: "Manage Team", style: .plain, target: self, action: #selector(manageTeamButtonDidClick))
            ]
            navigationController?.isToolbarHidden = false
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scans.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // This defines how the Tasks in the list look.
        // We want the task name on the left and some indication of its status on the right.
        let task = scans[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.selectionStyle = .none
        cell.textLabel?.text = task.name
        switch task.statusEnum {
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
        }
        return cell
    }

    @objc func addButtonDidClick() {
        let alertController = UIAlertController(title: "Add Scan", message: "", preferredStyle: .alert)

        // When the user clicks the add button, present them with a dialog to enter the task name.
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            _ -> Void in
            let textField = alertController.textFields![0] as UITextField

			
			let scan = Scan(partition: self.partitionValue, name: textField.text ?? "New Task")

			// Any writes to the Realm must occur in a write block.
			try! self.realm.write {
				// Add the Task to the Realm. That's it!
				self.realm.add(scan)
			}

        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addTextField(configurationHandler: { (textField: UITextField!) -> Void in
            textField.placeholder = "New Task Name"
        })

        // Show the dialog.
        self.present(alertController, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // User selected a task in the table. We will present a list of actions that the user can perform on this task.
        let scan = scans[indexPath.row]

        // Create the AlertController and add its actions.
        let actionSheet: UIAlertController = UIAlertController(title: scan.name, message: "Select an action", preferredStyle: .actionSheet)

		// If the task is not in the Open state, we can set it to open. Otherwise, that action will not be available.
		// We do this for the other two states -- InProgress and Complete.
		if scan.statusEnum != .empty {
			actionSheet.addAction(UIAlertAction(title: "Open", style: .default) { _ in
					// Any modifications to managed objects must occur in a write block.
					// When we modify the Task's state, that change is automatically reflected in the realm.
					try! self.realm.write {
						scan.statusEnum = .empty
					}
				})
		}

		if scan.statusEnum != .InProgress {
			actionSheet.addAction(UIAlertAction(title: "Start Progress", style: .default) { _ in
					try! self.realm.write {
						scan.statusEnum = .InProgress
					}
				})
		}

		if scan.statusEnum != .Uploaded {
			actionSheet.addAction(UIAlertAction(title: "Complete", style: .default) { _ in
					try! self.realm.write {
						scan.statusEnum = .Uploaded
					}
				})
		}


        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                actionSheet.dismiss(animated: true)
            })

        // Show the actions list.
        self.present(actionSheet, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        // User can swipe to delete items.
        let scan = scans[indexPath.row]

		try! realm.write {
			   // Delete the scan.
			   realm.delete(scan)
		   }
    }

    @objc func manageTeamButtonDidClick() {
        present(UINavigationController(rootViewController: ManageTeamViewController()), animated: true)
    }

    // Returns true if these are the user's own scans.
    func isOwnScans() -> Bool {
		return partitionValue == "project=\(app.currentUser!.id)"
       
    }
}
