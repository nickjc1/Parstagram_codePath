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
    
    ///sign up
    ///
    ///call event4success if sign up successfully completed
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
    
    ///sign in
    ///
    ///call event4success if authentication succeed
    static func userSignIn(for user: User_signin, event4success: @escaping successFunc, event4fail: @escaping failFunc) {
        PFUser.logInWithUsername(inBackground: user.username, password: user.password) { (user, error) in
            if(user != nil) {
                event4success()
            } else {
                event4fail(error)
            }
        }
    }
    
    ///log out
    ///
    ///Synchronously logs out the currently logged in user on disk.
    static func userLogout() {
        PFUser.logOut()
    }
    
    ///post image with caption to server
    ///
    ///call succeeded escaping clousure when the post process completed
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
    ///return fetched posts by using completion function to pass data out of the closure
    static func getImagePosts(lessEqualThen queryLimit: Int, completion: @escaping ([PostData_Fetch])->()) {
        
        let query = PFQuery(className: "Posts")
        query.includeKeys(["user", "comments", "comments.author"])
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
                guard let postId = post.objectId else {return}
                let comments:[PFObject]? = post["comments"] as? [PFObject]
                var postComments:[Comment_fetch]?
                if comments == nil {
                    postComments = nil 
                } else {
                    postComments = []
                    for com in comments! {
                        guard let commentAuthor = com["author"] as? PFUser else {return}
                        let comAuthorName = commentAuthor.username!
                        guard let comText = com["comment"] as? String else {return}
//                        print(comText)
                        let postComment = Comment_fetch(comAuthorName: comAuthorName, text: comText)
                        postComments?.append(postComment)
                    }
                }
                
                let fetchedPostData = PostData_Fetch(user: userWithPost, caption: caption, imageFile: postImageFile, postId: postId, comments: postComments)
                posts.append(fetchedPostData)
            }
            completion(posts)
        }
        
    }
    
    ///comment a post
    ///
    ///add a comment to a post
    static func addComments(with comment: Comment_post, completion: successFunc? = nil) {
        let commentText = comment.text
        let postId = comment.postId
        getPostToComment(for: postId) { post in
            let comment2Post = PFObject(className: "Comments")
            comment2Post["comment"] = commentText
            comment2Post["author"] = PFUser.current()!
            comment2Post["post"] = post
            post.add(comment2Post, forKey: "comments")
            post.saveInBackground { success, error in
                if(success) {
                    completion?()
                } else if let e = error {
                    print("encounter error when saving comment to the post(id: \(postId)). \nerror description:\(e.localizedDescription)")
                }
            }
            
        }
    }
    
    static func updateUserPortrait(to newPortrait: UIImage, completion: successFunc? = nil) {
        let currentUser = PFUser.current()!
        if let portraitFile = self.imageConvert(for: newPortrait) {
            currentUser.setObject(portraitFile, forKey: "portrait")
            currentUser.saveInBackground { succeed, error in
                if succeed {
                    print("succeed to update user portrait")
                    completion?()
                } else {
                    print("failed to update user portrait with error: \(error!.localizedDescription)")
                }
            }
        } else {
            print("Failed to update user portrait!")
        }
        
    }
    
    
//MARK: - class privite methods
    
    private static func imageConvert(for image: UIImage) -> PFFileObject? {
        if let imageData = image.pngData() {
            let imageFile = PFFileObject(name: "avatar", data: imageData)
            return imageFile
        }
        return nil
    }
    
    private static func getPostToComment(for id: String, completion: @escaping (PFObject)->()) {
        let query = PFQuery(className: "Posts")
        query.whereKey("objectId", equalTo: id)
        query.findObjectsInBackground { objects, error in
            if let posts = objects {
                completion(posts.first!)
            } else {
                print("Did not find the post with referred id : \(id)")
                guard let e = error else {return}
                print("The error: \(e.localizedDescription)")
            }
        }
    }
}
