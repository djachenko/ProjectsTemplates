//
// Created by Igor Djachenko on 26/01/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGFloat {
    func isEqual(to other: CGFloat, epsilon: CGFloat = .leastNormalMagnitude) -> Bool {
        Double(1).isEqual(to: x)

        return abs(self - other) <= epsilon
    }
}