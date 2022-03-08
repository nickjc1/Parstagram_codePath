//
//  ViewController.swift
//  Parstagram
//
//  Created by Chao Jiang on 3/6/22.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
//MARK: - variable of Logo ImageView
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "instagram_logo")
        iv.contentMode = .scaleAspectFit
//        iv.backgroundColor = .systemBlue
        return iv
    }()
    
//MARK: - variable of username and password
    let guide = UILayoutGuide()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.contentMode = .left
        tf.borderStyle = .roundedRect
        tf.autocorrectionType = UITextAutocorrectionType.no
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        tf.textContentType = UITextContentType.oneTimeCode
        tf.clearsOnBeginEditing = true
        tf.placeholder = "username"
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "password"
        tf.autocapitalizationType = .none
        tf.textContentType = UITextContentType.oneTimeCode
        tf.autocorrectionType = .no
        tf.clearsOnBeginEditing = true
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let loginStackView: UIStackView = {
        let sv = UIStackView()
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.axis = .vertical
        return sv
    }()
    
//MARK: - Sign up, sign in button
    let signupButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        bt.setTitle("Sign Up", for: .normal)
        return bt
    }()
    
    let signinButton: UIButton = {
        let bt = UIButton(type: .system)
        bt.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        bt.setTitle("Sign In", for: .normal)
        return bt
    }()
    
//MARK: - Viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setuplogoImageViewLayout()
        setupLoginStackViewLayout()
        setupSignupSigninButtonViewLayout()
        
        buttonsAddTarget()
    }
}


//MARK: - setup login view layout
extension LoginViewController {
    
    func addSubView2LoginStackView() {
        self.loginStackView.addArrangedSubview(usernameTextField)
        self.loginStackView.addArrangedSubview(passwordTextField)
    }
    
    func setuplogoImageViewLayout() {
        self.view.addSubview(logoImageView)
        self.logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 70),
            logoImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            logoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            logoImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func setupLoginStackViewLayout() {
        self.view.addSubview(loginStackView)
        addSubView2LoginStackView()
        
        self.view.addLayoutGuide(guide)
        NSLayoutConstraint.activate([
            guide.topAnchor.constraint(equalTo: self.logoImageView.bottomAnchor),
            guide.bottomAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        loginStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginStackView.leadingAnchor.constraint(equalTo: self.logoImageView.leadingAnchor),
            loginStackView.trailingAnchor.constraint(equalTo: self.logoImageView.trailingAnchor),
            loginStackView.topAnchor.constraint(equalTo: self.guide.centerYAnchor),
            loginStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    func setupSignupSigninButtonViewLayout() {
        self.view.addSubview(signupButton)
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signupButton.topAnchor.constraint(equalTo: loginStackView.bottomAnchor, constant: 20),
            signupButton.leadingAnchor.constraint(equalTo: loginStackView.leadingAnchor, constant: 10)
        ])
        
        self.view.addSubview(signinButton)
        signinButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signinButton.topAnchor.constraint(equalTo: loginStackView.bottomAnchor, constant: 20),
            signinButton.trailingAnchor.constraint(equalTo: loginStackView.trailingAnchor, constant: -10)
        ])
    }
    
}

//MARK: - Buttons functionality
extension LoginViewController {
    
    func buttonsAddTarget() {
        signupButton.addTarget(self, action: #selector(signupButtonTapped(_:)), for: .touchUpInside)
        signinButton.addTarget(self, action: #selector(signinButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc func signupButtonTapped(_ sender: UIButton) {
        if(usernameTextField.text?.count != 0 && passwordTextField.text?.count != 0) {
            if(passwordTextField.text!.count < 8) {
                displayAlert(for: nil, for: "Password should be at least 8 characters") { alert in
                    self.present(alert, animated: true, completion: nil)
                }
                passwordTextField.text = ""
                return
            }
            let user = PFUser()
            user.username = usernameTextField.text
            user.password = passwordTextField.text
            user.signUpInBackground { (success, error) in
                if(success) {
                    self.present2MainViewController()
                } else if(error != nil){
                    //print("here with error")
                    self.displayAlert(for: error, for: nil) { alert in
                        self.present(alert, animated: true, completion: nil)
                        self.passwordTextField.text = ""
                    }
                } else {
                    //print("here with error message")
                    self.displayAlert(for: nil, for: "Failed to Sign up with unknown error") { alert in
                        self.present(alert, animated: true, completion: nil)
                        self.passwordTextField.text = ""
                    }
                }
            }
        }
    }
    
    @objc func signinButtonTapped(_ sender: UIButton) {
        if(usernameTextField.text?.count == 0 || passwordTextField.text?.count == 0) {
            displayAlert(for: nil, for: "Please give currect user name and password") { alertMessage in
                self.present(alertMessage, animated: true, completion: nil)
            }
            return
        }
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if(user != nil) {
                self.present2MainViewController()
            } else if(error != nil){
                self.displayAlert(for: error, for: nil) { alertMessage in
                    self.present(alertMessage, animated: true, completion: nil)
                }
            } else {
                self.displayAlert(for: nil, for: "Failed to log in with unknown error") { alertMessage in
                    self.present(alertMessage, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    func present2MainViewController() {
        let mvc = MainViewController()
        let nvc = UINavigationController(rootViewController: mvc)
        nvc.modalPresentationStyle = .fullScreen
        self.modalPresentationStyle = .fullScreen
        self.present(nvc, animated: true, completion: nil)
    }
    
    func displayAlert(for error: Error?, for errorMessage: String?, present: (UIAlertController) -> ()){
        let errorStr = error != nil ? error!.localizedDescription : errorMessage!
        let alertMessage = UIAlertController(title: "Error", message: errorStr, preferredStyle: UIAlertController.Style.alert)
        let alertConformButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alertMessage.addAction(alertConformButton)
        present(alertMessage)
    }
}

