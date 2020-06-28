//
//  User.swift
//  PSFlickr
//
//  Created by Nithin Gaddam on 6/14/20.
//  Copyright © 2020 Nithin Gaddam. All rights reserved.
//

import Foundation
import FlickrKit

struct User{
    let id: String
    let username: String
    let profileImageUrl: String
    
    init(id: String, username: String, profileImageUrl: String) {
        self.id = id
        self.username = username
        self.profileImageUrl = profileImageUrl
    }
}
