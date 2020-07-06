//
//  PhotosCell.swift
//  PSFlickr
//
//  Created by Nithin Gaddam on 7/5/20.
//  Copyright © 2020 Nithin Gaddam. All rights reserved.
//

import UIKit

class PhotosCell: UICollectionViewCell {
    
    var image: UIImage? {
        didSet {
            bg.image = image
        }
    }
    
    fileprivate let bg: UIImageView = {
       let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(bg)

        bg.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
