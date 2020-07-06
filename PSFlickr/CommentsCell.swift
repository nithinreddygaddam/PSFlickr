//
//  CommentsCell.swift
//  PSFlickr
//
//  Created by Nithin Gaddam on 6/25/20.
//  Copyright © 2020 Nithin Gaddam. All rights reserved.
//

import UIKit

class CommentsCell: UICollectionViewCell {
    
    var comment: Comment?
    {
        didSet{
            setupAttributedCaption()
            // TODO fetch profile image
        }
    }
    
    let textLabel: UILabel = {
        let tLabel = UILabel()
        tLabel.font = UIFont.systemFont(ofSize: 14)
        tLabel.numberOfLines = 0
        tLabel.textColor = .white
        return tLabel
    }()
    
    let profileImageView: UIImageView = {
        let pImageView = UIImageView()
        pImageView.backgroundColor = .white
        pImageView.contentMode = .scaleAspectFill
        pImageView.clipsToBounds = true
        return pImageView
    }()
    
    fileprivate func setupAttributedCaption(){
        
        guard let comment = self.comment else{return}
        
        let attributedText = NSMutableAttributedString(string: comment.username, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.white])
        
        attributedText.append(NSAttributedString(string: "   \(comment.text)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        
        let timeAgoDisplay = comment.creationDate.timeAgoDisplay()
        
        attributedText.append(NSAttributedString(string: " \(timeAgoDisplay)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        

        self.textLabel.attributedText = attributedText
        
    }

    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        self.backgroundColor = .black
        
        addSubview(profileImageView)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.layer.cornerRadius = 50 / 2
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(textLabel)
        textLabel.anchor(top: topAnchor, left:profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
