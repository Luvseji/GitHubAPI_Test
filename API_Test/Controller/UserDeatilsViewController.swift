//
//  UserDeatilsViewController.swift
//  API_Test
//
//  Created by Константин Машейченко on 06.02.2022.
//

import UIKit

class UserDeatilsViewController: UIViewController {
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var companyLabel: UILabel!
    @IBOutlet private weak var followersLabel: UILabel!
    @IBOutlet private weak var followingLabel: UILabel!
    @IBOutlet private weak var createdAtLabel: UILabel!
    
    private let requestManager = RequestManager()
    
    var avatar: UIImage?
    var login: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let avatar = avatar,
              let login = login else { return }

        requestManager.requestFor(user: login) { result in
            guard result,
                  let fetchedData = self.requestManager.resultRequestUser else { return }
            DispatchQueue.main.async {
                self.avatarImageView.image = avatar
                self.nameLabel.text = (self.nameLabel.text ?? "") + (fetchedData.name ?? "-")
                self.emailLabel.text = (self.emailLabel.text ?? "") + (fetchedData.email ?? "-")
                self.companyLabel.text = (self.companyLabel.text ?? "") + (fetchedData.company ?? "-")
                self.followersLabel.text = (self.followersLabel.text ?? "") + (String(fetchedData.followers ?? 0))
                self.followingLabel.text = (self.followingLabel.text ?? "") + (String(fetchedData.following ?? 0))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.YYYY"
                let stringDate = dateFormatter.string(from: fetchedData.createdAt)
                self.createdAtLabel.text = (self.createdAtLabel.text ?? "") + stringDate
            }
        }
    }
}
