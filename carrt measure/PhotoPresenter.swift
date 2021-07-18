//
//  PhotoPresenter.swift
//  Carrt Measure
//
//  Created by Rrt Carrt on 6/12/21.
//  Copyright © 2021 carrt usf. All rights reserved.
//

import Foundation

struct PhotoPresenter: Identifiable {
let id = UUID()
let imageUrl: String

	init(with model: Photo ){
		self.imageUrl = model.thumbnailUrl
	}
}
