//
//  ServerCommunication.swift
//  Parstagram
//
//  Created by Chao Jiang on 3/12/22.
//

import UIKit
import Parse
import AlamofireImage

struct ParseServerComm {
    
    typealias successFunc = ()->()
    typealias failFunc = (Error?)->()
    
    
    //sign up
    static func userSignup(for user: User_signup,  event4success: @escaping successFunc, event4fail: @escaping failFunc) {
        let pfUser = PFUser()
        pfUser.username = user.username
        pfUser.password = user.password
        let userProfileImage = user.profileImage
        if let fileOfUserImage = imageConvert(for: userProfileImage) {
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
    static func userSignIn(for user: User_signin, event4success: @escaping successFunc, event4fail: @escaping failFunc) {
        PFUser.logInWithUsername(inBackground: user.username, password: user.password) { (user, error) in
            if(user != nil) {
                event4success()
            } else {
                event4fail(error)
            }
        }
    }
    
///post image with caption to server
    static func post(imagePost: PostData_post, succeeded: @escaping successFunc, failed: @escaping failFunc) {
        let post = PFObject(className: "Posts")
        
        guard let user = PFUser.current() else {
            print("failed to get current loggined user infomation")
            return
        }
        guard let imageData = imagePost.image.pngData() else {return}
        guard let imageFile = PFFileObject(name: "image", data: imageData) else {
            print("failed to create a imagefile as PFFileObject when posting")
            return
        }
        
        post["user"] = user
        post["image"] = imageFile
        post["caption"] = imagePost.caption
        
        post.saveInBackground { success, error in
            if(success) {
                succeeded()
            } else {
                failed(error)
            }
        }
        
    }
    
///fetch posts from server with limit.
///
///return fetched posts by completion function to pass data to the outside of the closure
    static func getImagePost(lessEqualThen queryLimit: Int, completion: @escaping ([PostData_Fetch])->()) {

        let query = PFQuery(className: "Posts")
        query.includeKey("user")
        query.order(byDescending: "createdAt")
        query.limit = queryLimit
        
        query.findObjectsInBackground { (fetchedPosts, error) in
            var posts = [PostData_Fetch]()
            guard let fetchedposts = fetchedPosts else {
                let e:String = error == nil ? "Unknown error" : error!.localizedDescription
                print("Unable to fetch posts from server with error: \(e)")
                return
            }
            
            for post in fetchedposts {
                let postAuthor = post["user"] as! PFUser
                let userWithPost = User_withPost(username: postAuthor.username!, profileImageFile: postAuthor.object(forKey: "portrait") as! PFFileObject)
                guard let postImageFile = post["image"] as? PFFileObject else {return}
                guard let caption = post["caption"] as? String else {return}
                
                let fetchedPostData = PostData_Fetch(user: userWithPost, caption: caption, imageFile: postImageFile)
                posts.append(fetchedPostData)
            }
            
            completion(posts)
        }

    }
    
    
    
    private static func imageConvert(for image: UIImage) -> PFFileObject? {
        if let imageData = image.pngData() {
            let imageFile = PFFileObject(name: "avatar", data: imageData)
            return imageFile
        }
        return nil
    }
}
