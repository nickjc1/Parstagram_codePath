//
//  Model.swift
//  Parstagram
//
//  Created by Chao Jiang on 3/11/22.
//

import UIKit
import Parse

struct User {
    let username: String
    let password: String
    let profileImage: UIImage
}

struct ImagePost {
    let user: PFUser
    let caption: String
    let image: PFFileObject
}


