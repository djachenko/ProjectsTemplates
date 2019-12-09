//
// Created by Igor Djachenko on 29/01/2018.
// Copyright (c) 2018 Igor Djachenko. All rights reserved.
//

import Foundation
import CoreGraphics

class VisibilityManager {
    private let buildings: [Building]

    init(buildings: [Building]) {
        self.buildings = buildings
    }

    func visible(coordinate: CGPoint, from: CGPoint) -> Bool {
        let checkResults = buildings.map { building in
            return building.between(point: from, point: coordinate)
        }

        let globalResult = checkResults.all { $0 }

        return globalResult
    }
}
