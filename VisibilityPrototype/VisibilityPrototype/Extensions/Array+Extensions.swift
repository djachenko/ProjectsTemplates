//
// Created by Igor Djachenko on 23/10/2017.
// Copyright (c) 2017 Igor Djachenko. All rights reserved.
//

import Foundation

extension Array {
    init(count: Int, generator:(Int) -> Element) {
        self.init()

        (0..<count).forEach({index in
            let element = generator(index)

            append(element)
        })
    }

    func all(_ predicate: (Element) -> Bool) -> Bool {
        for item in self {
            if !predicate(item) {
                return false
            }
        }

        return true
    }

    mutating func remove(at indexes: [Int]) {
        indexes.reversed().forEach { index in
            remove(at: index)
        }
    }

    mutating func trim(to size: Index) {
        let exceedingSize = count - size

        if exceedingSize > 0 {
            removeLast(exceedingSize)
        }
    }
}

extension Array where Element: Equatable {
    func indexes(of x: Element) -> [Int] {
        var indexes = [Int]()

        enumerated().forEach { (index, element) in
            if element == x {
                indexes.append(index)
            }
        }

        return indexes
    }
}

extension Array where Element: Comparable {
    func indexOfMin() -> Int? {
        guard let minValue = self.min() else {
            return nil
        }

        let valueIndex = index(of: minValue)

        return valueIndex
    }
}