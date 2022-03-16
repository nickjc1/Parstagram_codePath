//
//  CommentTableViewCell.swift
//  Parstagram
//
//  Created by Chao Jiang on 3/15/22.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    let commentLable:UILabel = {
        let lb = UILabel()
//        lb.frame.size.height = 30
//        lb.frame.size.width = 400
        lb.textAlignment = .natural
        lb.numberOfLines = 0
        return lb
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.commentLableLayoutSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commentLableLayoutSetup() {
        self.addSubview(commentLable)
        commentLable.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            commentLable.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            commentLable.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            commentLable.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -5),
            commentLable.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        ])
    }
    
}
