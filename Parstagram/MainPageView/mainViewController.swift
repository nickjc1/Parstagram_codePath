//
//  mainViewController.swift
//  Parstagram
//
//  Created by Chao Jiang on 3/6/22.
//

import UIKit
import PhotosUI
import AlamofireImage
import Parse


class MainViewController: UIViewController {
    
    let imagePostTableView: UITableView = {
        let tv = UITableView()
        tv.register(PostTableViewCell.self, forCellReuseIdentifier: "postCell")
        tv.register(CommentTableViewCell.self, forCellReuseIdentifier: "commentCell")
        return tv
    }()
    
    
    var posts = [PostData_Fetch]()
    var limit = 4

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "Instagram"
        
        setupNavigationBarRightButton()
        imagePostTableViewLayoutSetup()
        drapDown2RefreshData()
        queryData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        queryData()
    }
}

//MARK: - Navigationbar rightbutton setup and functionality
extension MainViewController {
    func setupNavigationBarRightButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "insta_camera_btn"), style: .plain, target: self, action: #selector(rightBarButtonTapped(_:)))
        self.navigationItem.backButtonTitle = ""
    }
    
    @objc func rightBarButtonTapped(_ sender: UIBarButtonItem) {
        displayPostOption()
    }
}

//MARK: - AlertController for user to choose between camera and album
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    func displayPostOption() {
        let optionAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraChoice = UIAlertAction(title: "Camera", style: .default) { action in
            self.pickUsingCamera()
        }
        let libraryChoice = UIAlertAction(title: "Choose from Album", style: .default) { action in
            self.pickUsingAlbum()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        optionAlert.addAction(cameraChoice)
        optionAlert.addAction(libraryChoice)
        optionAlert.addAction(cancel)
        self.present(optionAlert, animated: true, completion: nil)
    }

    // Picer using album by PHPickerViewController
    func pickUsingAlbum() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = PHPickerFilter.images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.presentNextViewController(image: image)
                    }
                    
                }
            }
        }
    }
    
    //Pick using camera buy UIImagePickerController
    func pickUsingCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "The camera is not avalible", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            DispatchQueue.main.async {
                self.presentNextViewController(image: image)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    //push to next viewcontroller after picking the image
    func presentNextViewController(image: UIImage) {
        let size = CGSize(width: 300, height: 300)
        let scaledImage:UIImage = image.af.imageScaled(to: size, scale: nil)
        let vc = ImagePostViewController()
        vc.selectedImageView.image = scaledImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - tableViewLayout setup; tableViewDelegate, tableViewDataSource functionality
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func imagePostTableViewLayoutSetup() {
        self.view.addSubview(imagePostTableView)
        
        imagePostTableView.delegate = self
        imagePostTableView.dataSource = self
        imagePostTableView.allowsSelection = true
        
//        imagePostTableView.estimatedRowHeight = 500
        imagePostTableView.rowHeight = UITableView.automaticDimension
        imagePostTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imagePostTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            imagePostTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            imagePostTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            imagePostTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts[section].comments == nil ? 1 : 1 + self.posts[section].comments!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let post = self.posts[indexPath.section]
//        print("the section is: \(indexPath.section)")
//        print("the row is: \(indexPath.row)")
//        print(post.caption)
//        print(post.comments ?? "no comments")
//        print()
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as? PostTableViewCell else {return UITableViewCell()}
            let postAuthorName:String = post.user.username
            cell.authorLabel.text = postAuthorName
            
            let postAuthroPortraitFile = post.user.profileImageFile
            if let portraitUrlStr = postAuthroPortraitFile.url {
                if let portraitUrl = URL(string: portraitUrlStr) {
                    cell.authorImageView.af.setImage(withURL: portraitUrl)
                }
            }
            
            let captionAuthorName = postAuthorName
            let boldStrAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
            let attributedCaption = NSMutableAttributedString(string: captionAuthorName, attributes: boldStrAttribute)
            
            let caption = NSMutableAttributedString(string: " \(post.caption)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
            attributedCaption.append(caption)
            cell.captionLabel.attributedText = attributedCaption
            
            let postImageFile = post.imageFile
            if let imageUrlStr = postImageFile.url {
                if let imageUrl = URL(string: imageUrlStr) {
                    cell.igPostImageView.af.setImage(withURL: imageUrl)
                }
            }
            return cell
        } else {
            guard let commentCell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as? CommentTableViewCell else {return UITableViewCell()}
            if let comment = post.comments?[indexPath.row - 1] {
                let name = comment.comAuthorName
                let content = " \(comment.text)"
                let boldStrAttr = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
                let normalStrAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
                let attributedComment = NSMutableAttributedString(string: name, attributes: boldStrAttr)
                attributedComment.append(NSMutableAttributedString(string: content, attributes: normalStrAttr))
                commentCell.commentLable.attributedText = attributedComment
            }
            return commentCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.section == posts.count - 1) {
            if(self.limit <= posts.count) {
                self.limit += 2
                queryData()
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPost = self.posts[indexPath.section]
        let comment = Comment_post(postId: selectedPost.postId, text: "this a test comment")
        ParseServerComm.addComments(with: comment) {
            print("successfully to post a comment")
        }
    }
    
}

//MARK: - fetch data from parse
extension MainViewController {
    
    func queryData() {
        
        ParseServerComm.getImagePosts(lessEqualThen: self.limit) { posts in
            self.posts = posts
            self.imagePostTableView.reloadData()
        }
//        self.imagePostTableView.reloadData()
//        print("here")
    }
}

//MARK: - reload data by drop down
extension MainViewController {
    func drapDown2RefreshData() {
        self.imagePostTableView.refreshControl = UIRefreshControl()
        imagePostTableView.refreshControl?.addTarget(self, action: #selector(tableViewDrappedDown), for: .valueChanged)
    }
    
    @objc func tableViewDrappedDown() {
        self.limit = 4
        self.queryData()
        DispatchQueue.main.async {
            self.imagePostTableView.refreshControl?.endRefreshing()
        }
    }
}

