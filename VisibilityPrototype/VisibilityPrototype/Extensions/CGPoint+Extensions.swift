//
// Created by Igor Djachenko on 23/10/2017.
// Copyright (c) 2017 Igor Djachenko. All rights reserved.
//

import Foundation
import SceneKit
import ARCL
import CoreLocation

extension CGPoint {
    var length: CGFloat {
        get {
            return hypot(x, y)
        }
    }

    init(coordinate: CLLocationCoordinate2D) {
        self.init(x: CGFloat(coordinate.latitude), y: CGFloat(coordinate.longitude))
    }

    init(_ a: CGFloat, _ b: CGFloat) {
        self.init(x: a, y: b)
    }

    func normalize() -> CGPoint {
        return self / length
    }

    static func /(left: CGPoint, factor: Float) -> CGPoint {
        return left / CGFloat(factor)
    }

    static func /(left: CGPoint, factor: CGFloat) -> CGPoint {
        return CGPoint(
                CGFloat(left.x) / factor,
                CGFloat(left.y) / factor
        )
    }

    static func *(left: CGPoint, factor: Int) -> CGPoint {
        return left * CGFloat(factor)
    }

    static func *(left: CGPoint, factor: Float) -> CGPoint {
        return left * CGFloat(factor)
    }

    static func *(left: CGPoint, factor: CGFloat) -> CGPoint {
        return CGPoint(
                left.x * factor,
                left.y * factor
        )
    }

    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(
                left.x + right.x,
                left.y + right.y
        )
    }

    static func +=(left: inout CGPoint, right: CGPoint) {
        left = left + right
    }

    static func -(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(
                left.x - right.x,
                left.y - right.y
        )
    }

    static func -=(left: inout CGPoint, right: CGPoint) {
        left = left - right
    }

    static prefix func -(vector: CGPoint) -> CGPoint {
        return CGPoint(
                -vector.x,
                -vector.y
        )
    }

    func distance(to: CGPoint) -> CGFloat {
        return (to - self).length
    }

    func liesBetween(point a: CGPoint, point b: CGPoint) -> Bool {
        let epsilon: CGFloat = 0.00001

        return a.distance(to: b).isEqual(to: distance(to: a) + distance(to: b), epsilon: epsilon)
    }
}