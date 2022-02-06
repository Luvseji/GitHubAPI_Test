//
//  Extension.swift
//  API_Test
//
//  Created by Константин Машейченко on 06.02.2022.
//

import Foundation
import UIKit

var imageCahce = NSCache<NSString, UIImage>()
extension UIImageView {
    func load(urlString: String) {
        if let image = imageCahce.object(forKey: urlString as NSString) {
            self.image = image
            return
        }
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                imageCahce.setObject(image, forKey: urlString as NSString)
                self.image = image
            }
        }
    }
}
