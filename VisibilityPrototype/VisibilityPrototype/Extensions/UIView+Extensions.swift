//
// Created by Igor Djachenko on 17/11/2017.
// Copyright (c) 2017 Igor Djachenko. All rights reserved.
//

import Foundation
import UIKit

extension UIView : Xibable {
    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)

        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)

            let image = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()

            return image
        }

        return nil
    }
}

protocol Xibable { }

extension Xibable {
    static func fromXib() -> Self? {
        return fromXib(name: String(describing: self)) as? Self
    }

    static func fromXib(name: String) -> UIView? {
        let loaded = Bundle.main.loadNibNamed(name, owner: nil)!

        let viewArray = loaded.filter({item in
            return item is UIView
        }) as! [UIView]

        return viewArray.first
    }
}