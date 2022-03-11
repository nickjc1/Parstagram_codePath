//
//  Model.swift
//  Parstagram
//
//  Created by Chao Jiang on 3/11/22.
//

import Foundation
import Parse


struct User {
    let username: String
    let password: String
    let profileImage: UIImage
}

struct Post {
    let user: User
    let caption: String
    let image: UIImage
}

struct ParseServerComm {
    
    //sign up
    static func userSignup(for user: User,  event4success: @escaping ()->(), event4fail: @escaping (Error?)->()) {
        let pfUser = PFUser()
        pfUser.username = user.username
        pfUser.password = user.password
        
        if let fileOfUserImage = imageConvert(for: user.profileImage) {
            pfUser.setObject(fileOfUserImage, forKey: "portrait")
        }
        
        pfUser.signUpInBackground { success, error in
            if(success) {
                event4success()
            } else {
                event4fail(error)
            }
        }
    }
    
    //sign in
    static func userSignIn(for user: User, event4success: @escaping ()->(), event4fail: @escaping (Error?)->()) {
        PFUser.logInWithUsername(inBackground: user.username, password: user.password) { (user, error) in
            if(user != nil) {
                event4success()
            } else {
                event4fail(error)
            }
        }
    }
    
    //post to server
    
    //fetch posts from server
    
    private static func imageConvert(for image: UIImage) -> PFFileObject? {
        if let imageData = image.pngData() {
            let imageFile = PFFileObject(name: "avatar", data: imageData)
            return imageFile
        }
        return nil
    }
}
