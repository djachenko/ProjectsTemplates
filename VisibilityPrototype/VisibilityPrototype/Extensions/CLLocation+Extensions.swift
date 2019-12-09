//
// Created by Igor Djachenko on 22/12/2017.
// Copyright (c) 2017 Igor Djachenko. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
    convenience init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, altitude: CLLocationDistance) {
        let coordinate = CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
        )

        self.init(coordinate: coordinate, altitude: altitude)
    }

    convenience init(coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance = 0) {
        self.init(coordinate: coordinate, altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
    }
}