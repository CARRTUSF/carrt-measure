//
//  GalleryViewModel.swift
//  Carrt Measure
//
//  Created by Varaha Maithreya on 6/23/21.
//  Copyright © 2021 carrt usf. All rights reserved.
//

import Foundation
import RealmSwift
import Combine
import SwiftUI

final class GalleryViewModel: ObservableObject {
    
    @Published var Images: [DbPhoto] = []
         var passName: String = "HelloThere from galleryViewModel"
     private var model: dataPassage
    
    
    init(model: dataPassage) {
           
    print("model intialized in gvm")
        
    
        self.model = model
        self.fetchImages()
            
            
        
    }
    
    private   func fetchImages() {
        // Start loading indicator
        
        let user = app.currentUser!

        user.functions.getImageList([AnyBSON(model.roomID)]) { [weak self](result, error) in
            DispatchQueue.main.async {
                guard self != nil else {
                    // This can happen if the view is dismissed
                    // before the operation completes
                    print("Image list no longer needed.")
                    return
                }
                // Stop loading indicator
                guard error == nil else {
                    print("Fetch Images  failed: \(error!.localizedDescription)")
                    return
                }
                print("Fetch Images  complete.")
                print(result!)
                // Convert documents to members array
                self!.Images = result!.arrayValue!.map({ (bson) in
                    return DbPhoto(document: bson!.documentValue!)
                    
                    
                })

                // Notify UI of changed data
                
            }
        }
    }
        
        
        
    }


