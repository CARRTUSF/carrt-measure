//
//  objView.swift
//  Carrt Measure
//
//  Created by Varaha Maithreya on 7/25/21.
//  Copyright © 2021 carrt usf. All rights reserved.
//

import Foundation
import UIKit

protocol objViewDelegate: AnyObject {
    func objShared(objURL: URL)
    func objRenamed(objURL: URL)
    func objDeleted(objURL: URL)
}

class objView: UIView {
  
  private var coverImageView: UIImageView!
  private var indicatorView: UIActivityIndicatorView!
  private var valueObservation: NSKeyValueObservation!
  private var textLabel: UILabel!
  private var objURL: URL!
  public var delegate: objViewDelegate!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit(objPath: "NA")
  }
  
    init(frame: CGRect, objURL: URL) {
        super.init(frame: frame)
        self.objURL = objURL
        commonInit(objPath: objURL.path)
        DispatchQueue.global().async {
            let downloadedImage = UIImage(named: "zip")
          DispatchQueue.main.async {
            self.coverImageView.image = downloadedImage
          }
        }
    }

  private func commonInit(objPath: String) {
    
    // Setup the background
    backgroundColor = .black
    // Create the cover image view
    coverImageView = UIImageView()
    coverImageView.translatesAutoresizingMaskIntoConstraints = false
    
    valueObservation = coverImageView.observe(\.image, options: [.new]) { [unowned self] observed, change in
      if change.newValue is UIImage {
        self.indicatorView.stopAnimating()
      }
    }
    
    //Text Label
    textLabel = UILabel()
    textLabel.numberOfLines = 0
    textLabel.text  =
        URL(fileURLWithPath: objPath).lastPathComponent + "\n" +
        URL(fileURLWithPath: objPath).fileSizeString + "\n" +
        (try! URL(fileURLWithPath: objPath).resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate!.getFormattedDate(format: "yyyy-MM-dd HH:mm:ss"))
    textLabel.textColor = .white
    textLabel.textAlignment = .left

    //Stack View
    let stackView   = UIStackView()
    stackView.axis  = NSLayoutConstraint.Axis.horizontal
    stackView.distribution  = UIStackView.Distribution.fill
    stackView.alignment = UIStackView.Alignment.center
    stackView.spacing   = 8.0

    stackView.addArrangedSubview(coverImageView)
    stackView.addArrangedSubview(textLabel)
    stackView.translatesAutoresizingMaskIntoConstraints = false

    addSubview(stackView)

    // Create the indicator view
    indicatorView = UIActivityIndicatorView()
    indicatorView.translatesAutoresizingMaskIntoConstraints = false
    indicatorView.style = .whiteLarge
    indicatorView.startAnimating()
    addSubview(indicatorView)
    
    NSLayoutConstraint.activate([
      stackView.leftAnchor.constraint(equalTo: self.leftAnchor),
      stackView.rightAnchor.constraint(equalTo: self.rightAnchor),
      stackView.topAnchor.constraint(equalTo: self.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      coverImageView.widthAnchor.constraint(equalToConstant: 180 - 5),
      indicatorView.centerXAnchor.constraint(equalTo: coverImageView.centerXAnchor),
      indicatorView.centerYAnchor.constraint(equalTo: coverImageView.centerYAnchor)
      ])
    
    let interaction = UIContextMenuInteraction(delegate: self)
    self.addInteraction(interaction)
  }
    
    func highlightobj(_ didHighlightView: Bool) {
      if didHighlightView == true {
        backgroundColor = .white
        textLabel.textColor = .black
      } else {
        backgroundColor = .black
        textLabel.textColor = .white
      }
    }
}



extension objView: UIContextMenuInteractionDelegate {
               
      func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
           
            // Create an action for sharing
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
                // Show system share sheet
                self.delegate?.objShared(objURL: self.objURL)
            }
    
            // Create an action for renaming
            let rename = UIAction(title: "Rename", image: UIImage(systemName: "square.and.pencil")) { action in
                // Perform renaming
                self.delegate?.objRenamed(objURL: self.objURL)
            }
    
            // Here we specify the "destructive" attribute to show that it’s destructive in nature
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                // Perform delete
                self.delegate?.objDeleted(objURL: self.objURL)
            }
    
            // Create and return a UIMenu with all of the actions as children
            return UIMenu(title: "", children: [share, rename, delete])
        }
    }
}
