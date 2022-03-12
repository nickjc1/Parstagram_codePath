//
//  PostTableViewCell.swift
//  Parstagram
//
//  Created by Chao Jiang on 3/8/22.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
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
    
    let captionLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 18)
//        lb.backgroundColor = .systemMint
        return lb
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        cellLayoutSetup()
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
        captionLabelLayoutSetup()
    }
    
    func userImageViewLayoutSetup() {
        self.addSubview(authorImageView)
        authorImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            authorImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            authorImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            authorImageView.heightAnchor.constraint(equalToConstant: 50),
            authorImageView.widthAnchor.constraint(equalTo: authorImageView.heightAnchor)
        ])
    }
    
    func authorLableLayoutSetup() {
        self.addSubview(authorLabel)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            authorLabel.centerYAnchor.constraint(equalTo: authorImageView.centerYAnchor),
            authorLabel.leadingAnchor.constraint(equalTo: authorImageView.trailingAnchor, constant: 5),
            authorLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            authorLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func igPosterImageViewLayoutSetup() {
        self.addSubview(igPostImageView)
        igPostImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            igPostImageView.topAnchor.constraint(equalTo: authorImageView.bottomAnchor, constant: 5),
            igPostImageView.leadingAnchor.constraint(equalTo: authorImageView.leadingAnchor),
            igPostImageView.trailingAnchor.constraint(equalTo: authorLabel.trailingAnchor),
            igPostImageView.heightAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    func captionLabelLayoutSetup() {
        self.addSubview(captionLabel)
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            captionLabel.topAnchor.constraint(equalTo: igPostImageView.bottomAnchor, constant: 2),
            captionLabel.leadingAnchor.constraint(equalTo: igPostImageView.leadingAnchor),
            captionLabel.trailingAnchor.constraint(equalTo: igPostImageView.trailingAnchor),
            captionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
        ])
    }
}


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
