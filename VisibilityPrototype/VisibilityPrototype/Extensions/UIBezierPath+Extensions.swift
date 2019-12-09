//
// Created by Igor Djachenko on 20/11/2017.
// Copyright (c) 2017 Igor Djachenko. All rights reserved.
//

import Foundation
import UIKit

extension UIBezierPath {
    static let roundFlatness: CGFloat = 0.004

    convenience init(centerX: CGFloat, centerY: CGFloat, radius: CGFloat) {
        self.init(ovalIn: CGRect(centerX: centerX, centerY: centerY, width: radius * 2, height: radius * 2))

        flatness = UIBezierPath.roundFlatness
    }

    convenience init(center: CGPoint, radius: CGFloat) {
        self.init(centerX: center.x, centerY: center.y, radius: radius)
    }
}