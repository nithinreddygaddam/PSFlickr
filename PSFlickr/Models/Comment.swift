//
//  Comment.swift
//  PSFlickr
//
//  Created by Nithin Gaddam on 6/15/20.
//  Copyright © 2020 Nithin Gaddam. All rights reserved.
//

import Foundation

struct Comment {
    let text: String
    let creationDate: Date
    let username: String
    
    init (dictionary: [String: Any]) {
        self.text = dictionary["_content"] as? String ?? ""
        self.username = dictionary["authorname"] as? String ?? ""
        let secondsFrom1970 = dictionary["datecreate"] as? String ?? "0"
        self.creationDate = Date(timeIntervalSince1970: Double(secondsFrom1970)!)
    }
    
    init (text: String, username: String, creationDate:Date) {
        self.text = text
        self.username = username
        self.creationDate = creationDate
    }
}
