//
// Created by Igor Djachenko on 01/11/2017.
// Copyright (c) 2017 Igor Djachenko. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    func distance(to point: CLLocationCoordinate2D) -> Double {
        return hypot(longitude - point.longitude, latitude - point.latitude)
    }

    func liesBetween(point a: CLLocationCoordinate2D, point b:CLLocationCoordinate2D) -> Bool {
        let epsilon = 0.00001

        return distance(to: a) + distance(to: b) - a.distance(to: b) < epsilon
    }

    init?(string: String) {
        let stringCoordinates = string.split(separator: ";")

        guard stringCoordinates.count == 2 else {
            return nil
        }

        let numericCoordinates = stringCoordinates.map { string in
            return Double(string)
        }
        .compactMap { $0 }

        guard numericCoordinates.count == stringCoordinates.count else {
            return
        }

        self.init(latitude: numericCoordinates[0], longitude: numericCoordinates[1])
    }
}