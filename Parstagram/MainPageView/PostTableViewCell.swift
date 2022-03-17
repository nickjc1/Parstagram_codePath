//
//  PostTableViewCell.swift
//  Parstagram
//
//  Created by Chao Jiang on 3/8/22.
//

import UIKit

protocol PostTableViewCellDelegate {
    func cellSubmitButtonTapped()
}

class PostTableViewCell: UITableViewCell {
    
    var delegate:PostTableViewCellDelegate?
    
    let authorImageView: UIImageView = {
        let ui = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        ui.circleImageView()
        ui.backgroundColor = .systemBlue
        return ui
    }()
    
    let authorLabel: UILabel = {
        let lb = UILabel()
        lb.font = .boldSystemFont(ofSize: 18)
//        lb.backgroundColor = .systemGray
        return lb
    }()
    
    let igPostImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemRed
        return iv
    }()
    
    let commentButton:UIButton = {
        let bt = UIButton(type: .system)
        bt.setImage(UIImage(named: "comIcon"), for: .normal)
        bt.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        bt.addTarget(self, action: #selector(commentButtonTapped(_:)), for: .touchUpInside)
        return bt
    }()
    
    let captionLabel: UILabel = {
        let lb = UILabel()
//        lb.font = .systemFont(ofSize: 18)
//        lb.backgroundColor = .systemMint
        lb.textAlignment = .natural
        lb.numberOfLines = 0
        return lb
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //add items into self.contentView!!!
        cellLayoutSetup()
        contentView.isUserInteractionEnabled = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PostTableViewCell {
    
    func cellLayoutSetup() {
        userImageViewLayoutSetup()
        authorLableLayoutSetup()
        igPosterImageViewLayoutSetup()
        commentButtonLayoutSetup()
        captionLayoutSetup()
    }
    
    func userImageViewLayoutSetup() {
        self.contentView.addSubview(authorImageView)
        authorImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            authorImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            authorImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
            authorImageView.heightAnchor.constraint(equalToConstant: 50),
            authorImageView.widthAnchor.constraint(equalTo: authorImageView.heightAnchor)
        ])
    }
    
    func authorLableLayoutSetup() {
        self.contentView.addSubview(authorLabel)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            authorLabel.centerYAnchor.constraint(equalTo: authorImageView.centerYAnchor),
            authorLabel.leadingAnchor.constraint(equalTo: authorImageView.trailingAnchor, constant: 5),
            authorLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5),
            authorLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func igPosterImageViewLayoutSetup() {
        self.contentView.addSubview(igPostImageView)
        igPostImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            igPostImageView.topAnchor.constraint(equalTo: authorImageView.bottomAnchor, constant: 5),
            igPostImageView.leadingAnchor.constraint(equalTo: authorImageView.leadingAnchor),
            igPostImageView.trailingAnchor.constraint(equalTo: authorLabel.trailingAnchor),
            igPostImageView.heightAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    func commentButtonLayoutSetup() {
        self.contentView.addSubview(commentButton)
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            commentButton.topAnchor.constraint(equalTo: igPostImageView.bottomAnchor, constant: 5),
            commentButton.leadingAnchor.constraint(equalTo: igPostImageView.leadingAnchor),
            commentButton.heightAnchor.constraint(equalToConstant: 30),
            commentButton.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func captionLayoutSetup() {
        self.contentView.addSubview(captionLabel)
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.captionLabel.leadingAnchor.constraint(equalTo: self.igPostImageView.leadingAnchor),
            self.captionLabel.trailingAnchor.constraint(equalTo: self.igPostImageView.trailingAnchor),
            self.captionLabel.topAnchor.constraint(equalTo: self.commentButton.bottomAnchor, constant: 5),
            self.captionLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor, constant: -5)
        ])

    }
    
}

extension PostTableViewCell {
    @objc func commentButtonTapped(_ sender: UIButton) {
//        print("The comment button is tapped")
        self.delegate?.cellSubmitButtonTapped()
    }
}


//MARK: - UIImageView extention
extension UIImageView {
    func circleImageView() {
        self.layer.cornerRadius = self.frame.size.width / 2.0
        self.layer.cornerCurve = .circular
        self.contentMode = .scaleAspectFill
        self.clipsToBounds = true
        layer.masksToBounds = true
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.white.cgColor
    }
}

