//
//  UserInfoUpdateViewController.swift
//  Parstagram
//
//  Created by Chao Jiang on 3/17/22.
//

import UIKit

class UserInfoUpdateViewController: UIViewController {
    
    let userPortraitImageView:UIImageView = {
        let iv = UIImageView()
        iv.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        iv.image = UIImage(named: "profile_tab")
        iv.circleImageView()
        return iv
    }()
    
    let guide = UILayoutGuide()
    
    let updateButton:UIButton = {
        let bt = UIButton(type: .system)
//        bt.addTarget(self, action: #selector(), for: .touchUpInside)
        bt.setTitle("Update", for: .normal)
        bt.titleLabel?.font = .boldSystemFont(ofSize: 18)
        bt.frame = CGRect(x: 0, y: 0, width: 75, height: 40)
        return bt
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        userPortraitImageViewLayoutSetup()
        updateButtonLayoutSetup()
        
        addUserPortraitTapGesture()
    }
}

//MARK: - View Layout
extension UserInfoUpdateViewController {
    
    func userPortraitImageViewLayoutSetup() {
        self.view.addLayoutGuide(guide)
        NSLayoutConstraint.activate([
            guide.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            guide.bottomAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        
        self.view.addSubview(userPortraitImageView)
        userPortraitImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userPortraitImageView.centerYAnchor.constraint(equalTo:self.guide.centerYAnchor),
            userPortraitImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            userPortraitImageView.heightAnchor.constraint(equalToConstant: 200),
            userPortraitImageView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func updateButtonLayoutSetup() {
        view.addSubview(updateButton)
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            updateButton.topAnchor.constraint(equalTo: userPortraitImageView.bottomAnchor, constant: 50),
            updateButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
}

//MARK: - Gesture Recognizer
extension UserInfoUpdateViewController {
    func addUserPortraitTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userPortraitTapped(_:)))
        self.userPortraitImageView.isUserInteractionEnabled = true
        self.userPortraitImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func userPortraitTapped(_ sender: UITapGestureRecognizer) {
//        print("image tapped")
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
            self.pickPhoto(by: .camera)
        }
        let photoAlbumAction = UIAlertAction(title: "Choose from Album", style: .default) { action in
            self.pickPhoto(by: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(photoAlbumAction)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
}

//MARK: - Pick image functionality
extension UserInfoUpdateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func pickPhoto(by source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        switch source {
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            } else {
                pickErrorAlert(for: source)
            }
            
        case .photoLibrary:
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            } else {
                pickErrorAlert(for: source)
            }
        default:
            return
        }
    }
    
    func pickErrorAlert(for pickSource: UIImagePickerController.SourceType) {
        let errorMessage = pickSource == .camera ? "The camera is not available" : "The photo library is not available"
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let dismissAlertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(dismissAlertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            let size = CGSize(width: 300, height: 300)
            let scaledImage = image.af.imageAspectScaled(toFill: size, scale: nil)
            self.userPortraitImageView.image = scaledImage
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
}
