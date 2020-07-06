//
//  PhotoViewController.swift
//  PSFlickr
//
//  Created by Nithin Gaddam on 6/14/20.
//  Copyright © 2020 Nithin Gaddam. All rights reserved.
//

import UIKit
import FlickrKit

class PhotoDetailViewController: UIViewController {

    var photoDictionary: [String: Any]?
    var user: User?
    var currentUserName: String?
    
    let usernameLabel: UILabel = {
        let uLabel = UILabel()
        uLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight(rawValue: 5))
        uLabel.numberOfLines = 0
        uLabel.textColor = .white
        return uLabel
    }()
    
    let profileImageView: UIImageView = {
        let pImageView = UIImageView()
        pImageView.backgroundColor = .white
        pImageView.contentMode = .scaleAspectFill
        pImageView.clipsToBounds = true
        return pImageView
    }()
    
    let photoImageView: UIImageView = {
        let pImageView = UIImageView()
        pImageView.contentMode = .scaleAspectFill
        pImageView.clipsToBounds = true
        pImageView.backgroundColor = .black
        pImageView.image = #imageLiteral(resourceName: "placeHolderImage")
        return pImageView
    }()
    
    let commentButton: UIButton = {
        let cButton = UIButton(type: .system)
        cButton.backgroundColor = UIColor(red: 56/255, green: 156/255, blue: 252/255, alpha: 1)
        cButton.setTitle("Comment", for: .normal)
        cButton.setTitleColor(.white, for: .normal)
        cButton.addTarget(self, action: #selector(handleCommentButton), for: .touchUpInside)
        return cButton
    }()
    
    let photoText: UILabel = {
        let pLabel = UILabel()
        pLabel.font = .systemFont(ofSize: 13)
        pLabel.textColor = .white
        pLabel.translatesAutoresizingMaskIntoConstraints = false
        return pLabel
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.view.alpha = 0
        view.backgroundColor = .black
        photoImageView.frame = CGRect(x: 0, y: view.frame.height/3, width: view.frame.width, height: view.frame.height/4)
        commentButton.frame = CGRect(x: view.frame.width * 0.1, y: view.frame.height - 90, width: view.frame.width * 0.8 , height: 40)
        
        view.addSubview(photoImageView)
        view.addSubview(commentButton)
        
        view.addSubview(photoText)
        photoText.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: view.frame.height / 8, paddingRight: 0, width: view.frame.width, height: 0)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 100, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.layer.cornerRadius = 50 / 2
        
        view.addSubview(usernameLabel)
        usernameLabel.anchor(top: view.topAnchor, left:profileImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 115, paddingLeft: 6, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
        
        guard let photoDictionary = photoDictionary, let userID = self.photoDictionary?["owner"], let text = self.photoDictionary?["title"]  else {
            return
        }
        let id = userID as! String
        FlickrKit.shared().call("flickr.people.getInfo", args: ["user_id": id], completion: { (response, error) -> Void in
            let user = response?["person"] as! NSDictionary
            let data = user["username"] as! NSDictionary
            let username = data["_content"] as! String
            self.user = User(id: id, username: username, profileImageUrl: "")
            DispatchQueue.main.async {
                self.usernameLabel.text = username
            }
            //Download profile image
        })
        
        // Download photo
        let photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.small320, fromPhotoDictionary: photoDictionary)
        let request = URLRequest(url: photoURL)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error -> Void in
            guard let data = data else {
                return
            }
            DispatchQueue.main.async {
                self.photoImageView.image = UIImage(data: data)
                self.photoText.text = text as? String
            }
        })
        task.resume()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 0.25) {
            self.navigationController?.view.alpha = 1.0
        }
    }
    
    @objc func handleCommentButton () {
        let commentsVC = CommentsViewController()
        commentsVC.photoDictionary = photoDictionary
        commentsVC.currentUserName = currentUserName
        self.navigationController!.pushViewController(commentsVC, animated: true)
    }

}
