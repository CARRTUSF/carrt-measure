import Foundation
import UIKit
import RealmSwift

class ProjectsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView = UITableView()
    let userRealm: Realm
    var notificationToken: NotificationToken?
    var userData: User?

    init(userRealm: Realm) {
        self.userRealm = userRealm

        super.init(nibName: nil, bundle: nil)
		
		let usersInRealm = userRealm.objects(User.self)

		notificationToken = usersInRealm.observe { [weak self, usersInRealm] (_) in
			self?.userData = usersInRealm.first
			guard let tableView = self?.tableView else { return }
			tableView.reloadData()
		}

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)  not  implemented")
    }
    
	
    deinit {
		notificationToken?.invalidate()
            }

    override func viewDidLoad() {
        super.viewDidLoad()

        
        title = "Hub"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = self.view.frame
        view.addSubview(tableView)

        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutButtonDidClick))
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


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return userData?.customerOf.count ?? 1
        
    }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
		cell.selectionStyle = .none

		
		let projectName = userData?.customerOf[indexPath.row].name ?? "My Project"
		cell.textLabel?.text = projectName

		return cell
	}


	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let user = app.currentUser!
		let project = userData?.customerOf[indexPath.row] ?? customerOf(partition: "\(user.id)", name: "My Project")

		Realm.asyncOpen(configuration: user.configuration(partitionValue: project.partition!)) { [weak self] (result) in
			switch result {
			case .failure(let error):
				fatalError("Failed to open realm: \(error)")
			case .success(let realm):
				self?.navigationController?.pushViewController(
					RoomViewController(/*realm: realm, title: "\(project.partition!)'s Scans"*/),
					animated: true
				)
			}
		}
	}

}
