//
// Created by Igor Djachenko on 27/12/2017.
// Copyright (c) 2017 Igor Djachenko. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(white: Int) {
        let w = CGFloat((white >> 0) & 0xFF)

        self.init(white: w, alpha: 1)
    }

    convenience init(rgb: Int) {
        let R = CGFloat((rgb >> 16) & 0xFF)
        let G = CGFloat((rgb >> 8)  & 0xFF)
        let B = CGFloat((rgb >> 0)  & 0xFF)

        self.init(
                red: R / 255.0,
                green: G / 255.0,
                blue: B / 255.0,
                alpha: 1.0
        )
    }

    convenience init(rgba: Int) {
        let R = CGFloat((rgba >> 24) & 0xFF)
        let G = CGFloat((rgba >> 16) & 0xFF)
        let B = CGFloat((rgba >> 8)  & 0xFF)
        let A = CGFloat((rgba >> 0)  & 0xFF)

        self.init(
                red: R / 255.0,
                green: G / 255.0,
                blue: B / 255.0,
                alpha: A / 255.0
        )
    }

    convenience init?(hex: String) {
        guard let rgb = Int(hex) else {
            return nil
        }

        self.init(rgb: rgb)
    }
}