//
// Created by Igor Djachenko on 23/11/2017.
// Copyright (c) 2017 Igor Djachenko. All rights reserved.
//

import Foundation
import SceneKit

func avg(_ a: Float, _ b: Float) -> Float {
    return (a + b) / 2.0
}

func interpolate(a: Float, b: Float, ratio: Float) -> Float {
    return a * (1 - ratio) + b * ratio
}

func interpolate(a: SCNVector3, b: SCNVector3, ratio: Float) -> SCNVector3 {
    return SCNVector3(
            interpolate(a: a.x, b: b.x, ratio: ratio),
            interpolate(a: a.y, b: b.y, ratio: ratio),
            interpolate(a: a.z, b: b.z, ratio: ratio)
    )
}

func hypot(_ values: Float...) -> Float {
    let sum = values.reduce(into: Float(0)) { (acc, el) in
        acc += pow(el, 2)
    }

    let hypo = sqrt(sum)

    return hypo
}