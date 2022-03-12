//
//  ServerCommunication.swift
//  Parstagram
//
//  Created by Chao Jiang on 3/12/22.
//

import UIKit
import Parse

struct ParseServerComm {
    
    typealias successFunc = ()->()
    typealias failFunc = (Error?)->()
    
    
    //sign up
    static func userSignup(for user: User,  event4success: @escaping successFunc, event4fail: @escaping failFunc) {
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
    static func userSignIn(for user: User, event4success: @escaping successFunc, event4fail: @escaping failFunc) {
        PFUser.logInWithUsername(inBackground: user.username, password: user.password) { (user, error) in
            if(user != nil) {
                event4success()
            } else {
                event4fail(error)
            }
        }
    }
    
    //post to server
    static func post(imagePost: ImagePost, succeeded: @escaping successFunc, failed: @escaping failFunc) {
        let post = PFObject(className: "Posts")
        post["user"] = imagePost.user
        post["image"] = imagePost.image
        post["caption"] = imagePost.caption
        post.saveInBackground { success, error in
            if(success) {
                succeeded()
            } else {
                failed(error)
            }
        }
        
    }
    
    //fetch posts from server
    
    
    
    private static func imageConvert(for image: UIImage) -> PFFileObject? {
        if let imageData = image.pngData() {
            let imageFile = PFFileObject(name: "avatar", data: imageData)
            return imageFile
        }
        return nil
    }
}
