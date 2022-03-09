//
//  ImageViewController.swift
//  
//
//  Created by Chao Jiang on 3/7/22.
//

import UIKit
import Parse

class ImagePostViewController: UIViewController {

//MARK: - Class memeber
    let selectedImageView:UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let caption:UITextView = {
        let tv = UITextView()
        tv.contentMode = .left
        tv.textColor = .systemGray
        tv.text = "Write a caption..."
        tv.font = .systemFont(ofSize: 18)
        return tv
    }()
    
//MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        caption.delegate = self
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        self.view.addGestureRecognizer(viewTapGesture)

        
        setupImageViewlayout()
        setupCaptionLayout()
        navigationBarRightButtonSetup()
    }

}

//MARK: - UI Layout
extension ImagePostViewController {
    func setupImageViewlayout() {
        self.view.addSubview(selectedImageView)
        selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            selectedImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            selectedImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8),
            selectedImageView.heightAnchor.constraint(equalToConstant: 120),
            selectedImageView.widthAnchor.constraint(equalTo: selectedImageView.heightAnchor)
        ])
    }
    
    func setupCaptionLayout() {
        self.view.addSubview(caption)
        caption.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            caption.topAnchor.constraint(equalTo: self.selectedImageView.topAnchor),
            caption.leadingAnchor.constraint(equalTo: self.selectedImageView.trailingAnchor, constant: 8),
            caption.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
            caption.bottomAnchor.constraint(equalTo: self.selectedImageView.bottomAnchor)
        ])
    }
}

//MARK: - setup caption textview placeholder via UITextViewDelegate; added gesture recognizer to self.view
extension ImagePostViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.text = ""
        textView.textColor = .black
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text == "") {
            textView.textColor = .systemGray
            textView.text = "Write a caption..."
        }
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        caption.resignFirstResponder()
    }
}

//MARK: - Navigation bar right button set up
extension ImagePostViewController {
    func navigationBarRightButtonSetup() {
        let button = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem = button
    }
    
    @objc func shareButtonTapped(_ sender: UIBarButtonItem) {
        let post = PFObject(className: "Posts")
        if let imageData = selectedImageView.image?.pngData() {
            post["image"] = PFFileObject(name: "image", data: imageData)
            if(caption.text != "Write a caption...") {
                post["caption"] = self.caption.text
            } else {
                post["caption"] = ""
            }
            guard let user = PFUser.current() else {return}
            post["user"] = user
        }
        post.saveInBackground { (success, error) in
            if(success) {
                print("successfully saved!")
                self.navigationController?.popViewController(animated: true)
            } else {
                let errorData = error == nil ? "unknown error" : error!.localizedDescription
                print("failed to save data with error: \(errorData)")
            }
        }
    }
}