//
// Created by Igor Djachenko on 20/11/2017.
// Copyright (c) 2017 Igor Djachenko. All rights reserved.
//

import Foundation
import UIKit

extension CGRect {
    init(centerX: CGFloat, centerY: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(x: -width / 2 + centerX, y: -height / 2 + centerY, width: width, height: height)
    }

    var center: CGPoint {
        get {
            return CGPoint(
                    x: width / 2,
                    y: height / 2
            )
        }
    }
}