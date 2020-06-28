//
//  PhotosViewController.swift
//  PSFlickr
//
//  Created by Nithin Gaddam on 6/21/20.
//  Copyright © 2020 Nithin Gaddam. All rights reserved.
//

import UIKit
import FlickrKit

class PhotosViewController: UIViewController {
    
    var userID: String?
    var userName: String?
    var didReachTheEnd = false
    var didFilter = false
    var isFetching = false
    var tag: String?
    var page = 1
    
    var photoURLs: [URL] = []
    var photoArray = [[String:Any]]()
    let photoPerPage = "20"
    
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(CustomCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: view.frame.height)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Tag"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        populatePhotos()
    }
    
    func populatePhotos() {
        isFetching = true
        let flickrInteresting = FKFlickrInterestingnessGetList()
        flickrInteresting.per_page = photoPerPage
        flickrInteresting.page = String(page)
        
        FlickrKit.shared().call(flickrInteresting) { (response, error) -> Void in
            if let response = response, let photoArray = FlickrKit.shared().photoArray(fromResponse: response) {
                // Pull out the photo urls from the results
                for photoDictionary in photoArray {
                    let photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.small320, fromPhotoDictionary: photoDictionary)
                    self.photoURLs.append(photoURL)
                    self.photoArray.append(photoDictionary)
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    self.isFetching = false
                    self.collectionView.reloadData()
                })
            } else {
                self.isFetching = false
                if let error = error as NSError? {
                    switch error.code {
                    case FKFlickrInterestingnessGetListError.serviceCurrentlyUnavailable.rawValue:
                        break;
                    default:
                        break;
                    }
                    
                    let alert = UIAlertController(title: "Error", message:error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    self.present(alert, animated: true, completion:  nil)
                }
            }
        }
    }
    
    func filterContentForSearchText(_ searchTag: String) {
        if searchTag.count < 3 {
            return
        }
        if !didReachTheEnd {
            self.photoURLs = []
            self.photoArray = []
        }
        isFetching = true
        FlickrKit.shared().call("flickr.photos.search", args: ["tags": searchTag, "per_page": photoPerPage, "page": String(page)] , maxCacheAge: FKDUMaxAge.neverCache, completion: { (response, error) -> Void in
                if let response = response, let photoArray = FlickrKit.shared().photoArray(fromResponse: response) {
                    for photoDictionary in photoArray {
                        let photoURL = FlickrKit.shared().photoURL(for: FKPhotoSize.small320, fromPhotoDictionary: photoDictionary)
                        self.photoURLs.append(photoURL)
                        self.photoArray.append(photoDictionary)
                    }
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.isFetching = false
                        self.collectionView.reloadData()
                    })
                } else {
                    self.isFetching = false
                }
            })
    }

}

extension PhotosViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width/2)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        if photoURLs.count > 0 {
            let request = URLRequest(url: photoURLs[indexPath.item])
            let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error -> Void in
                DispatchQueue.main.async { // Correct
                    if let data = data {
                        cell.image = UIImage(data: data)
                    } else {
                        cell.image = UIImage(named: "placeHolderImage")
                    }
                }
            })
            task.resume()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoDetailVC = PhotoDetailViewController()
        photoDetailVC.photoDictionary = photoArray[indexPath.item]
        self.navigationController?.pushViewController(photoDetailVC, animated: true)
    }
    
    //Infinite scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !isFetching {
                didReachTheEnd = true
                page += 1
                if didFilter {
                    guard let tag = tag else {
                        return
                    }
                    filterContentForSearchText(tag)
                } else {
                    populatePhotos()
                }
            }
        }
    }
}

extension PhotosViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    didFilter = true
    didReachTheEnd = false
    tag = searchBar.text!
    page = 1
    filterContentForSearchText(searchBar.text!)
  }
}


class CustomCell: UICollectionViewCell {
    
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
