//
// Created by Igor Djachenko on 23/10/2017.
// Copyright (c) 2017 Igor Djachenko. All rights reserved.
//

import Foundation
import SceneKit
import ARCL

extension SCNVector3 {
    static let zero = SCNVector3(0, 0, 0)
    static let identity = SCNVector3(1, 1, 1)

    var length: Float {
        get {
            return hypot(x, y, z)
        }
    }

    func normalize() -> SCNVector3 {
        return self / length
    }

    static func /(left: SCNVector3, factor: CGFloat) -> SCNVector3 {
        return left / Double(factor)
    }

    static func /(left: SCNVector3, factor: Float) -> SCNVector3 {
        return left / Double(factor)
    }

    static func /(left: SCNVector3, factor: Double) -> SCNVector3 {
        return SCNVector3(
                Double(left.x) / factor,
                Double(left.y) / factor,
                Double(left.z) / factor
        )
    }

    static func *(left: SCNVector3, factor: Int) -> SCNVector3 {
        return left * Double(factor)
    }

    static func *(left: SCNVector3, factor: CGFloat) -> SCNVector3 {
        return left * Double(factor)
    }

    static func *(left: SCNVector3, factor: Float) -> SCNVector3 {
        return left * Double(factor)
    }

    static func *(left: SCNVector3, factor: Double) -> SCNVector3 {
        return SCNVector3(
                Double(left.x) * factor,
                Double(left.y) * factor,
                Double(left.z) * factor
        )
    }

    static func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(
                left.x + right.x,
                left.y + right.y,
                left.z + right.z
        )
    }

    static func +=(left: inout SCNVector3, right: SCNVector3) {
        left = left + right
    }

    static func -(left: SCNVector3, right: LocationTranslation) -> SCNVector3 {
        return left - SCNVector3(locationTranslation: right)
    }

    static func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(
                left.x - right.x,
                left.y - right.y,
                left.z - right.z
        )
    }

    static func -=(left: inout SCNVector3, right: SCNVector3) {
        left = left - right
    }

    static prefix func -(vector: SCNVector3) -> SCNVector3 {
        return SCNVector3(
                -vector.x,
                -vector.y,
                -vector.z
        )
    }

    init(unifiedValue: Float) {
        self.init(x: unifiedValue, y: unifiedValue, z: unifiedValue)
    }

    init(unifiedValue: CGFloat) {
        self.init(unifiedValue: Float(unifiedValue))
    }

    init(unifiedValue: Double) {
        self.init(unifiedValue: Float(unifiedValue))
    }

    init(locationTranslation: LocationTranslation) {
        self.init(
                x: Float(locationTranslation.longitudeTranslation),
                y: Float(locationTranslation.altitudeTranslation),
                z: Float(locationTranslation.latitudeTranslation)
        )
    }

    func distance(to: SCNVector3) -> Float {
        return (to - self).length
    }
}