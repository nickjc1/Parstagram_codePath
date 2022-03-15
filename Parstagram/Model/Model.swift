//
//  Model.swift
//  Parstagram
//
//  Created by Chao Jiang on 3/11/22.
//

import UIKit
import Parse

struct User_signup {
    let username: String
    let password: String
    let profileImage: UIImage
//    let profileImageFile: PFFileObject?
}

struct User_signin {
    let username: String
    let password: String
}

struct User_withPost {
    let username: String
    let profileImageFile: PFFileObject
}

struct PostData_post {
    let caption: String
    let image: UIImage
}

struct PostData_Fetch {
    let user: User_withPost
    let caption: String
    let imageFile: PFFileObject
    let postId: String
    
}

struct comment_post {
    let postId: String
    let text: String
}

