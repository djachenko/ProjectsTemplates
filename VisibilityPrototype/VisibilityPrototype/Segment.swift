//
// Created by Igor Djachenko on 25/01/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

import Foundation
import CoreGraphics

class Segment {
    let start: CGPoint
    let end: CGPoint

    init(_ start: CGPoint, _ end: CGPoint) {
        self.start = start
        self.end = end
    }

    init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }

    func det(a: CGPoint, b: CGPoint) -> CGFloat {
        let d = a.x * b.y - a.y * b.x

        return d
    }

    func intersectsLine(of segment: Segment) -> Bool {
        let shiftedOtherEnd = segment.end - segment.start
        let shiftedStart = start - segment.start
        let shiftedEnd = end - segment.start


        let d1 = det(a: shiftedOtherEnd, b: shiftedStart)
        let d2 = det(a: shiftedOtherEnd, b: shiftedEnd)

        if (d1 * d2).isEqual(to: 0) {
            return shiftedOtherEnd.liesBetween(point: shiftedStart, point: shiftedEnd) ||
                    CGPoint.zero.liesBetween(point: shiftedStart, point: shiftedEnd)

        }

        let intersects = d1 * d2 < 0

        return intersects
    }

    func intersects(_ other: Segment) -> Bool {
        let otherIntersectsSelf = other.intersectsLine(of: self)
        let selfIntersectsOther = self.intersectsLine(of: other)

        return otherIntersectsSelf && selfIntersectsOther
    }






    static func test() {
        let testSegments = [
            Segment(CGPoint(0, 0), CGPoint(0, 0)),
            Segment(CGPoint(0, 0), CGPoint(0, 1)),
            Segment(CGPoint(0, 1), CGPoint(0, 2)),
            Segment(CGPoint(0, 0.5), CGPoint(0, 1.5)),
            Segment(CGPoint(0, 2), CGPoint(0, 3))
        ]

        let res = testSegments.map { s1 in
            return testSegments.map { s2 in
                return s1.intersects(s2)
            }
        }

        let a = 7
    }
}
