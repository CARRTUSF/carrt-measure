import Foundation
import RealmSwift


	class User: Object {
		@objc dynamic var _id: String = ""
		@objc dynamic var _partition: String = ""
		@objc dynamic var name: String = ""
		@objc dynamic var email: String = ""
		let customerOf = RealmSwift.List<customerOf>()
		override static func primaryKey() -> String? {
			return "_id"
		}
	}


class customerOf: EmbeddedObject {
	@objc dynamic var name: String?
	@objc dynamic var partition: String?
	convenience init(partition: String, name: String) {
		self.init()
		self.partition = partition
		self.name = name
	}
}


enum RoomStatus: String {
  case Uploaded
  case InProgress
  case empty
}


class Room: Object {
	@objc dynamic var _id: String = ""
	@objc dynamic var _partition: String = ""
	@objc dynamic var name: String = ""
	@objc dynamic var owner: String?
	@objc dynamic var status: String = ""
	@objc dynamic var scanImage: String = ""
	@objc dynamic var pcImage: String = ""
    @objc dynamic var roomID: String = ""
    @objc dynamic var parentFolderID: String = ""
	override static func primaryKey() -> String? {
		return "_id"
	}

	var statusEnum: RoomStatus {
		get {
			return RoomStatus(rawValue: status) ?? .empty
		}
		set {
			status = newValue.rawValue
		}
	}

	convenience init(partition: String, name: String) {
		self.init()
		self._partition = partition
		self.name = name
	}
}


struct Member {
    let id: String
    let name: String
    let customerFolderID: String
	//let email: String
    init(document: Document) {
        self.id = document["_id"]!!.stringValue!
        self.name = document["name"]!!.stringValue!
		self.customerFolderID = document["customerFolderID"]!!.stringValue!
    }
}



struct Employee {
	let id: String
	//let name: String
	let email: String
	init(document: Document) {
		self.id = document["_id"]!!.stringValue!
		//self.name = document["name"]!!.stringValue!
		self.email = document["email"]!!.stringValue!
	}
}

struct customerRoom {
	let id: String
	let name: String
	let roomID: String
	let parentFolderID: String
	init(document: Document) {
		self.id = document["_id"]!!.stringValue!
		self.name = document["name"]!!.stringValue!
		self.roomID = document["roomID"]!!.stringValue!
		self.parentFolderID = document["parentFolderID"]!!.stringValue!
	}
}


struct Customer {
	//let id: String
	let name: String
	let email: String
	let mobileNo: String
	let address: String
	init(document: Document) {
		//self.id = document["_id"]!!.stringValue!
		self.name = document["name"]!!.stringValue!
		self.email = document["email"]!!.stringValue!
		self.mobileNo = document["mobileNo"]!!.stringValue!
		self.address = document["address"]!!.stringValue!
		
	}
}

struct DbPhoto {
    
    //let _id: String
    let title: String
    let url: String
    let thumbnailurl: String
    init(document: Document) {
        //self.id = document["_id"]!!.stringValue!
        //self._id = document["_id"]!!.stringValue!
        self.title = document["title"]!!.stringValue!
        self.url = document["url"]!!.stringValue!
        self.thumbnailurl = document["thumbnailurl"]!!.stringValue!
        
    }
}



struct passingData: Decodable {
    
    var id: String
    var imageUrl: String
    var thumbnailUrl: String
    var passName: String
    var roomName: String 
    
    enum CodingKeys: String, CodingKey {
        
       
        case id
        case imageUrl
        case thumbnailUrl
        case passName
        case roomName
    }
}
