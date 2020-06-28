//
//  LoginViewController.swift
//  PSFlickr
//
//  Created by Nithin Gaddam on 6/14/20.
//  Copyright © 2020 Nithin Gaddam. All rights reserved.
//

import UIKit
import FlickrKit
import WebKit

class LoginViewController: UIViewController {
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Check if user is authorized
        _ = FlickrKit.shared().checkAuthorization { (userName, userId, fullName, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if ((error == nil)) {
                    let viewController = PhotosViewController()
                    viewController.userName = userName
                    viewController.userID = userId
                    let navigationController = UINavigationController(rootViewController: viewController)
                    navigationController.modalPresentationStyle = .overCurrentContext
                    let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                    keyWindow?.rootViewController = navigationController
                } else {
                    self.authorize()

                }
            });
        }
    }
    
    func authorize() {
        // Begin the authentication process
        let callbackURLString = "psflickr://auth"
        let url = URL(string: callbackURLString)
        FlickrKit.shared().beginAuth(withCallbackURL: url!, permission: FKPermission.delete, completion: { (url, error) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if ((error == nil)) {
                    let urlRequest = NSMutableURLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30)
                    self.webView.load(urlRequest as URLRequest)
                } else {
                    let alert = UIAlertController(title: "Error", message:error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    self.present(alert, animated: true, completion:  nil)
                }
            });
        })
    }
    
    func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(webView)

        webView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.width, height: view.frame.height)
        
        webView.navigationDelegate = self
    }

}

extension LoginViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {

            if url.scheme == "psflickr" {
                _ = FlickrKit.shared().completeAuth(with: url, completion: { (userName, userId, fullName, error) -> Void in
                    DispatchQueue.main.async(execute: { () -> Void in
                        if ((error == nil)) {
                            let viewController = PhotosViewController()
                            viewController.userName = userName
                            viewController.userID = userId
                            let navigationController = UINavigationController(rootViewController: viewController)
                            navigationController.modalPresentationStyle = .overCurrentContext
                            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                            keyWindow?.rootViewController = navigationController
                        }
                    });
                })
            }
        }
        decisionHandler(.allow)
        return
    }
}
