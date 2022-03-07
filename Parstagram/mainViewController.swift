//
//  mainViewController.swift
//  Parstagram
//
//  Created by Chao Jiang on 3/6/22.
//

import UIKit

class MainViewController: UIViewController {
    
    let postOptionPickView: UIPickerView = {
        let pv = UIPickerView()
        return pv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "Instagram"
        
        setupNavigationBarRightButton()
    }
    
}

extension MainViewController {
    func setupNavigationBarRightButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "insta_camera_btn"), style: .plain, target: self, action: #selector(rightBarButtonTapped(_:)))
        self.navigationItem.backButtonTitle = "Cancel"
    }
    
    @objc func rightBarButtonTapped(_ sender: UIBarButtonItem) {
        displayPostOption()
    }
}

extension MainViewController {
    func displayPostOption() {
        let optionAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraChoice = UIAlertAction(title: "Camera", style: .default) { action in
            let vc = CameraViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let libraryChoice = UIAlertAction(title: "Choose from Album", style: .default) { action in
            let vc = AlbumLibraryViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        optionAlert.addAction(cameraChoice)
        optionAlert.addAction(libraryChoice)
        optionAlert.addAction(cancel)
        self.present(optionAlert, animated: true, completion: nil)
    }
    
    func presentNextViewController(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
