//
//  Photo.swift
//  Carrt Measure
//
//  Created by Rrt Carrt on 6/12/21.
//  Copyright © 2021 carrt usf. All rights reserved.
//

import Foundation

struct Photo: Decodable {
	
	let albumId: Int
	let id: Int
	let title: String
	let url: String
	let thumbnailUrl: String
	
	enum CodingKeys: String, CodingKey {
		
		case albumId
		case id = "id"
		case title
		case url
		case thumbnailUrl
		
	}
}
