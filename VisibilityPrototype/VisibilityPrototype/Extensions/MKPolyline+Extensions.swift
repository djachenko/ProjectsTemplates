//
// Created by Igor Djachenko on 31/10/2017.
// Copyright (c) 2017 Igor Djachenko. All rights reserved.
//

import Foundation
import MapKit

extension MKPolyline {
    public var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: self.pointCount)

        getCoordinates(&coords, range: NSRange(location: 0, length: self.pointCount))

        return coords
    }

    func append(coordinates newCoordinates: [CLLocationCoordinate2D]) -> MKPolyline {
        var ownCoordinates = coordinates
        ownCoordinates.append(contentsOf: newCoordinates)

        let newPolyline = MKPolyline(coordinates: ownCoordinates, count: ownCoordinates.count)

        return newPolyline
    }
}