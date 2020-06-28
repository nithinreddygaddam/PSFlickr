//
//  CommentsViewController.swift
//  PSFlickr
//
//  Created by Nithin Gaddam on 6/14/20.
//  Copyright © 2020 Nithin Gaddam. All rights reserved.
//

import UIKit
import FlickrKit

class CommentsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {

    var photoDictionary: [String: Any]?
    let cellId = "cellId"
    var comments = [Comment]()
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Comments"
        
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.backgroundColor = .white
        collectionView?.register(CommentsCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        
        self.commentTextField.delegate = self
        
        fetchComments()
    }
    
    fileprivate func fetchComments() {
        guard let photoId = photoDictionary?["id"] else {
            return
        }
        FlickrKit.shared().call("flickr.photos.comments.getList", args: ["photo_id": photoId], completion: { (response, error) -> Void in
            
            guard let response = response, let commentsDict:NSDictionary  = response["comments"] as? NSDictionary, var commentsArray:NSArray = commentsDict["comment"] as? NSArray else {
                return
            }
            
            commentsArray = commentsArray.suffix(30) as NSArray
            
            for comment in commentsArray {
                self.comments.append(Comment(dictionary: comment as! [String: Any]))
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.collectionView.reloadData()
                let lastItemIndex = (self.collectionView?.numberOfItems(inSection: 0))! - 1
                let indexPath = NSIndexPath(item: lastItemIndex, section: 0)
                   
                self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: UICollectionView.ScrollPosition.bottom, animated: false)
                self.commentTextField.text = ""
                self.commentTextField.attributedPlaceholder = NSAttributedString(string: "Enter Comment", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.8)])
            })
            
        })
    }
    
    fileprivate func orderCommentsAndDisplay(){
        self.comments.sort(by: { (c1, c2) -> Bool in
            return c1.creationDate.compare(c2.creationDate) == .orderedAscending
        })

        self.collectionView?.reloadData()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentsCell

        cell.comment = comments[indexPath.item]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)

        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        containerView.addSubview(submitButton)
        submitButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)

        containerView.addSubview(self.commentTextField)
        self.commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        return containerView
    }()


    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Comment", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.8)])
        textField.textColor = .black
        return textField
    }()

    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    @objc func handleSubmit() {
        guard let photoId = photoDictionary?["id"] else {
            return
        }
        
        FlickrKit.shared().call("flickr.photos.comments.addComment", args: ["photo_id": photoId, "comment_text": commentTextField.text ?? ""], completion: { (response, error) -> Void in
            if error == nil {
                self.fetchComments()
            }
        })
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentTextField.resignFirstResponder()
        return true;
    }

}

