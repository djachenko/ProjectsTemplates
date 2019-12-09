//
// Created by Igor Djachenko on 25/01/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

import Foundation
import CoreGraphics

class Building {
    private let corners: [CGPoint]

    init?(corners: [CGPoint]) {
        guard corners.count >= 3 else {
            return nil
        }

        self.corners = corners
    }

    var walls: [Segment] {
        get {
            var segments = (1..<corners.count).map { i in
                return Segment(start: corners[i - 1], end: corners[i])
            }

            segments.append(Segment(start: corners.last!, end: corners.first!))

            return segments
        }
    }

    func between(point a: CGPoint, point b: CGPoint) -> Bool {
        let sightSegment = Segment(start: a, end: b)

        let intersectionChecks = walls.map { wall in
            return wall.intersects(sightSegment)
        }

        let obscures = !intersectionChecks.all { !$0 }

        return obscures
    }
}
