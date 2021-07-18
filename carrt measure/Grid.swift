//
//  Grid.swift
//  Carrt Measure
//
//  Created by Rrt Carrt on 6/12/21.
//  Copyright © 2021 carrt usf. All rights reserved.
//

import SwiftUI

struct Grid<Content: View>: View {
	
	let itemSize: Int
	let columns: Int
	let rowSpacing: CGFloat
	let columnSpacing: CGFloat
	let content: (Int, CGFloat) -> Content
	
	var body: some View{
		
		let rows = (Double(self.itemSize) / Double(self.columns)).rounded(.up)
		
		GeometryReader { geometry in
			let totalColumnSpacing = CGFloat(self.columns - 1) * self.columnSpacing
			let columnWidth = (geometry.size.width - totalColumnSpacing) / CGFloat(self.columns)
			
			
			
			
			ScrollView(.vertical) {
				ForEach(0..<Int(rows), id: \.self ) { row in
					Spacer(minLength: self.rowSpacing)
					HStack(spacing: self.columnSpacing) {
						ForEach(0..<self.columns, id: \.self) { column in
							let index = row * self.columns + column
							
							
							if index < self.itemSize {
								self.content(index, columnWidth).frame(width: columnWidth)
								
								
								
								
								
								
							} else {
								Spacer().frame(width: columnWidth)
							}
							
							
							
							
						}
						
					}
				}
				
			}
			
		}
	}
}
	
	struct Grid_Preview: PreviewProvider {
		static var previews: some View {
			
			Grid(itemSize: 4,  columns: 2, rowSpacing: 8, columnSpacing: 8) { index, _ in
				Text("\(index)")
				
				
			}
		}
		
		
		
		
	}
	
	
	



