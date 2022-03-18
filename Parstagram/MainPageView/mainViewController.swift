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
    
    let kbTextFieldContainer: UIView = {
        let uv = UIView()
        uv.backgroundColor = .white
//        uv.isHidden = true
        return uv
    }()
    
    var bottomConstraint: NSLayoutConstraint?
    
    let keyboardTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.placeholder = "say something..."
        tf.isEnabled = true
        return tf
    }()
    
    let submitCommentButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.setImage(UIImage(named: "submitButton"), for: .normal)
        bt.addTarget(self, action: #selector(submitButtonTapped(_:)), for: .touchUpInside)
        return bt
    }()
    
    let titleImageView: UIImageView = {
        let iv = UIImageView()
        iv.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        iv.circleImageView()
        iv.backgroundColor = .systemTeal
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    //pass the postId from the cell whose addCommentButton is tapped
    var commentToBePost: Comment_post?
    
    var posts = [PostData_Fetch]()
    var limit = 4
//MARK: - viewdidload()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
//        self.navigationItem.title = "Instagram"
        
        setupNavigationBarRightButton()
        setupNavigationBarLeftButton()
        imagePostTableViewLayoutSetup()
        drapDown2RefreshData()
        queryData()
        
        keyboardTextFieldLayoutSetup()
        keyboardObserverConfig()
        
        setupNavigationBarMiddlePortrait()
        addGestureToTitleView()
        
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
//        self.navigationItem.backButtonTitle = ""
    }
    
    @objc func rightBarButtonTapped(_ sender: UIBarButtonItem) {
        displayPostOption()
        self.navigationItem.backButtonTitle = ""
    }
}

//MARK: - Navigationbar leftbutton setup and functionality
extension MainViewController {
    func setupNavigationBarLeftButton() {
        let barButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonTapped(_:)))
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func logoutButtonTapped(_ sender: UIBarButtonItem) {
        ParseServerComm.userLogout()
        guard let windownScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windownScene.delegate as? SceneDelegate else {return}
        let vc = LoginViewController()
        delegate.window?.rootViewController = vc
    }
}

//MARK: - Navigationbar middle portrait set up
extension MainViewController {
    func setupNavigationBarMiddlePortrait() {
        let imageFile = PFUser.current()?.object(forKey: "portrait") as? PFFileObject
        
        if let portraitUrlStr = imageFile?.url {
            if let portraitUrl = URL(string: portraitUrlStr) {
                titleImageView.af.setImage(withURL: portraitUrl)
            }
        } else {
            titleImageView.image = UIImage(named: "profile_tab")
        }
        
        //user this uiview the contraint the titleimageview layout to be at the center of the navigationbar
        let titleUIView = UIView()
        titleUIView.addSubview(titleImageView)
        titleImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleImageView.centerXAnchor.constraint(equalTo: titleUIView.centerXAnchor),
            titleImageView.centerYAnchor.constraint(equalTo: titleUIView.centerYAnchor),
            titleImageView.heightAnchor.constraint(equalToConstant: 35),
            titleImageView.widthAnchor.constraint(equalToConstant: 35)
        ])

        self.navigationItem.titleView = titleImageView
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
    
    //Pick using camera by UIImagePickerController
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
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as? PostTableViewCell else {return UITableViewCell()}
            
            cell.delegate = self
            cell.post = post
            
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
        self.keyboardTextField.resignFirstResponder()
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

//MARK: - Keyboard textfield layout and functionality
extension MainViewController: PostTableViewCellDelegate {
    
    func keyboardTextFieldLayoutSetup() {
        
        self.view.addSubview(kbTextFieldContainer)
        kbTextFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            kbTextFieldContainer.heightAnchor.constraint(equalToConstant: 40),
            kbTextFieldContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            kbTextFieldContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
//            kbTextFieldContainer.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: keyboardBottomConst)
        ])
        bottomConstraint = NSLayoutConstraint(item: kbTextFieldContainer, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 50)
        self.view.addConstraint(bottomConstraint!)
        
        self.kbTextFieldContainer.addSubview(submitCommentButton)
        submitCommentButton.translatesAutoresizingMaskIntoConstraints = false
        self.kbTextFieldContainer.addSubview(keyboardTextField)
        keyboardTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submitCommentButton.trailingAnchor.constraint(equalTo: kbTextFieldContainer.trailingAnchor, constant: -5),
            submitCommentButton.heightAnchor.constraint(equalToConstant: 25),
            submitCommentButton.widthAnchor.constraint(equalToConstant: 25),
            submitCommentButton.centerYAnchor.constraint(equalTo: kbTextFieldContainer.centerYAnchor),
            
            keyboardTextField.heightAnchor.constraint(equalToConstant: 35),
            keyboardTextField.leadingAnchor.constraint(equalTo: kbTextFieldContainer.leadingAnchor, constant: 5),
            keyboardTextField.trailingAnchor.constraint(equalTo: submitCommentButton.leadingAnchor, constant: -5),
            keyboardTextField.centerYAnchor.constraint(equalTo:kbTextFieldContainer.centerYAnchor)
        ])
    }
    
    //postTableViewCellDelegateCell delegate function
    func addCommentButtonTapped(completion: () -> (Comment_post)?) {
        DispatchQueue.main.async {
//            self.kbTextFieldContainer.isHidden = false
            self.keyboardTextField.becomeFirstResponder()
        }
        self.commentToBePost = completion()
    }
    
    @objc func submitButtonTapped(_ sender: UIButton) {
        if let postId = self.commentToBePost?.postId {
            if self.keyboardTextField.text?.count != 0 {
                let text = self.keyboardTextField.text!
                ParseServerComm.addComments(with: Comment_post(postId: postId, text: text)) {
                    self.queryData()
                    print("successfully post a comment")
                }
            }
        }
        self.keyboardTextField.text = ""
        self.keyboardTextField.resignFirstResponder()
    }
    
    func keyboardObserverConfig() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if notification.name == UIResponder.keyboardWillShowNotification {
//                print("here")
                guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {return}
//                print(keyboardFrame)
                bottomConstraint?.constant = -keyboardFrame.height
            } else {
                bottomConstraint?.constant = 50
            }
            
            UIView.animate(withDuration: 0, delay: 0.02, options: .curveEaseOut) {
                self.view.layoutIfNeeded()
            } completion: {succeed in}

            
        }
    }
}

//MARK: - Gesturerecognizer for navigationbar user portrait
extension MainViewController {
    func addGestureToTitleView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(titleViewtapped(_:)))
        titleImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func titleViewtapped(_ sender: Any?) {
        print("titleImageView tapped")
        let vc = UserInfoUpdateViewController()
        guard let currentPortraitfile = PFUser.current()!.object(forKey: "portrait") as? PFFileObject else {
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        if let portraiturlStr = currentPortraitfile.url {
            if let url = URL(string: portraiturlStr) {
                vc.userPortraitImageView.af.setImage(withURL: url)
            }
        }
        self.navigationItem.backButtonTitle = "Cancel"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

