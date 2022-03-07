//
//  mainViewController.swift
//  Parstagram
//
//  Created by Chao Jiang on 3/6/22.
//

import UIKit

class MainViewController: UIViewController {

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
        
        let vc = CreatImageViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
