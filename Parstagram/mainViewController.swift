//
//  mainViewController.swift
//  Parstagram
//
//  Created by Chao Jiang on 3/6/22.
//

import UIKit
import PhotosUI
import AlamofireImage


class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "Instagram"
        
        setupNavigationBarRightButton()
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
        if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
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
    }
    
    //push to next viewcontroller after picking the image
    func presentNextViewController(image: UIImage) {
        let size = CGSize(width: 300, height: 300)
        let scaledImage:UIImage = image.af.imageScaled(to: size, scale: nil)
        let vc = ImageViewController()
        vc.selectedImageView.image = scaledImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
