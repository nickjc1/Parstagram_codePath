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
        print("image tapped")
//        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
//            <#code#>
//        }
    }
}

extension UserInfoUpdateViewController {
    
}
