//
//  PhotoGalleryView.swift
//  Carrt Measure
//
//  Created by Varaha Maithreya on 6/24/21.
//  Copyright © 2021 carrt usf. All rights reserved.
//

import SwiftUI
import Kingfisher

struct PhotoGalleryView: View {
    
    @ObservedObject var model: dataPassage
    @ObservedObject var ViewModel: GalleryViewModel
    
    init(model: dataPassage) {
        self.model = model
            self.ViewModel = GalleryViewModel(model: model)
        }

    
    
    
   
    
    var body: some View {
        
        let _ = print(model.roomID)
        let _ = print(ViewModel.passName)
    
        Grid(itemSize: self.ViewModel.Images.count , columns: 4, rowSpacing: 8, columnSpacing: 8) {
            index, width in KFImage(URL(string: self.ViewModel.Images[index].thumbnailurl))
                .cancelOnDisappear(true)
                .resizable()
                .frame(width: width, height: width )
                .cornerRadius(16)
            
            
        
        
        
        }
        
        
    }
    
    }


struct PhotoGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        
        PhotoGalleryView(model: dataPassage.init())
        
    }
}
