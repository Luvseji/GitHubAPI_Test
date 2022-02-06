//
//  GitTableViewCell.swift
//  API_Test
//
//  Created by Константин Машейченко on 06.02.2022.
//

import UIKit

class GitTableViewCell: UITableViewCell {

    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        avatarImageView.image = nil
    }

    func fillData(imageUrl: String, title: String, subTitle: Int) {
        avatarImageView.load(urlString: imageUrl)
        titleLabel.text = title
        subTitleLabel.text = String(subTitle)
    }
    
    func setDefaultImage() {
        avatarImageView.image = UIImage(named: "avatar")
    }
    
    func giveImage() -> UIImage? {
        return avatarImageView.image ?? nil
    }
    
    func giveLogin() -> String? {
        return titleLabel.text ?? nil
    }
    
}
