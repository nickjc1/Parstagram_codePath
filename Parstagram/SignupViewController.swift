//
//  SignupViewController.swift
//  Parstagram
//
//  Created by Chao Jiang on 3/8/22.
//

import UIKit
import Parse
import AlamofireImage

class SignupViewController: UIViewController {

//MARK: - view contents
    let guide = UILayoutGuide()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.contentMode = .left
        tf.borderStyle = .roundedRect
        tf.autocorrectionType = UITextAutocorrectionType.no
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        tf.textContentType = UITextContentType.oneTimeCode
        tf.clearsOnBeginEditing = true
        tf.placeholder = "please create an username"
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "please create a password"
        tf.autocapitalizationType = .none
        tf.textContentType = UITextContentType.oneTimeCode
        tf.autocorrectionType = .no
        tf.clearsOnBeginEditing = true
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let addPhotoLable: UILabel = {
        let lb = UILabel()
        lb.text = "Please Add Photo"
        lb.textAlignment = .center
        lb.textColor = .systemRed
        lb.font = .systemFont(ofSize: 15)
        return lb
    }()
    
    let userImageView: UIImageView = {
        let ui = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        ui.circleImageView()
//        ui.backgroundColor = .systemBlue
        ui.image = UIImage(named: "addPhoto")
        ui.isUserInteractionEnabled = true
        return ui
    }()
    
    let signupButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.tintColor = .white
        bt.backgroundColor = .systemBlue
        bt.layer.cornerRadius = 5
        bt.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
        bt.setTitle("  Sign Up  ", for: .normal)
        bt.titleLabel?.font = .boldSystemFont(ofSize: 15)
        return bt
    }()

//MARK: - viewDidLoad()
    var imagePicked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        let userImageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(userImageViewTapped(_:)))
        self.userImageView.addGestureRecognizer(userImageViewTapGesture)
        
        layoutSetup()
        buttonAddTarget()
    }
}


//MARK: - Layout
extension SignupViewController {
    
    func layoutSetup() {
        setupUserImageViewLayout()
        setupAddPhotoLabelLayout()
        setupUsernameTextFieldLayout()
        setupPasswordTextFieldLayout()
        setupSignupButtonLayout()
    }
    
    func setupUserImageViewLayout() {
        
        self.view.addLayoutGuide(guide)
        NSLayoutConstraint.activate([
            guide.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            guide.bottomAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        self.view.addSubview(userImageView)
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            userImageView.centerYAnchor.constraint(equalTo: self.guide.centerYAnchor),
            userImageView.heightAnchor.constraint(equalToConstant: 80),
            userImageView.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func setupAddPhotoLabelLayout() {
        self.view.addSubview(addPhotoLable)
        addPhotoLable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addPhotoLable.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 8),
            addPhotoLable.centerXAnchor.constraint(equalTo: userImageView.centerXAnchor),
            addPhotoLable.heightAnchor.constraint(equalToConstant: 30),
            addPhotoLable.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    func setupUsernameTextFieldLayout() {
        self.view.addSubview(usernameTextField)
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: addPhotoLable.bottomAnchor, constant: 20),
            usernameTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
            usernameTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50),
            usernameTextField.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func setupPasswordTextFieldLayout() {
        self.view.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 10),
            passwordTextField.leadingAnchor.constraint(equalTo: usernameTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: usernameTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalTo: usernameTextField.heightAnchor)
        ])
    }
    
    func setupSignupButtonLayout() {
        self.view.addSubview(signupButton)
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signupButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            signupButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor, constant: 50)
        ])
    }
}

//MARK: - Image Picker
extension SignupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func userImageViewTapped(_ sender: Any?) {
        print("tapped")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
            
            if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
                picker.sourceType = .camera
                picker.cameraCaptureMode = .photo
                picker.modalPresentationStyle = .fullScreen
                self.present(picker, animated: true, completion: nil)
                
            } else {
                let alert = UIAlertController(title: "Error", message: "The camera is not avalible", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        let albumAction = UIAlertAction(title: "Choose from Album", style: .default) { action in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(albumAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            let size = CGSize(width: 200, height: 200)
            let scaledImage = image.af.imageScaled(to: size, scale: nil)
            self.userImageView.image = scaledImage
            picker.dismiss(animated: true, completion: nil)
            imagePicked = true
        }
    }
    
}

//MARK: - Sign up button functionality
extension SignupViewController {
    func buttonAddTarget() {
        self.signupButton.addTarget(self, action: #selector(signupButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc func signupButtonTapped(_ sender: UIButton) {
        if(usernameTextField.text == "" || passwordTextField.text == "" || !imagePicked ) {
            signupAlert(for: .isNotCompleted)
            return
        }
        if(passwordTextField.text!.count < 8) {
            signupAlert(for: .password2Short)
            return
        }
        
        let user = PFUser()
        user.username = self.usernameTextField.text!
        user.password = self.passwordTextField.text!
        let imagedata = userImageView.image?.pngData()
        if let data = imagedata {
            let imageFile = PFFileObject(name: "avatar", data: data)!
            user.setObject(imageFile, forKey: "portrait")
        }
        
        user.signUpInBackground { (success, error) in
            
            if(success) {
                print("new accout created successfully")
                self.presentMainViewController()
            } else if(error != nil){
                if(error!.localizedDescription == "Account already exists for this username.") {
                    self.signupAlert(for: .alreadyExited)
                }
                print("sign up failed with error \(error!.localizedDescription)")
            }
        }
    }
    
    enum Alert {
        case isNotCompleted
        case alreadyExited
        case password2Short
    }
    
    func signupAlert(for alert: Alert) {
        switch alert {
        case .isNotCompleted:
            showAlert(message: "Please complete your profile")
        case .alreadyExited:
            showAlert(message: "The account already exists")
        case .password2Short:
            showAlert(message: "Password at least 8 digits/charactors")
        }
    }
    
    func showAlert(message: String) {
        let alertMessage = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        alertMessage.addAction(action)
        self.present(alertMessage, animated: true, completion: nil)
    }
    
    func presentMainViewController() {
        let vc = MainViewController()
        let ngc = UINavigationController(rootViewController: vc)
        ngc.modalPresentationStyle = .fullScreen
        self.present(ngc, animated: true, completion: nil)
    }
}
