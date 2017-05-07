//
//  Data.swift
//  PhotoGallery
//
//  Created by Joseph Lin on 5/6/17.
//  Copyright © 2017 Joseph Lin. All rights reserved.
//

import UIKit

protocol DataSource {
    var numberOfItems: Int { get }
    func image(at: Int) -> UIImage
}

class MockDataSource: DataSource {
    let mockImages = [
        #imageLiteral(resourceName: "DSC09241"),
        #imageLiteral(resourceName: "DSC09249"),
        #imageLiteral(resourceName: "DSC09737"),
        ]

    var mockIndices = [Int: Int]()

    var numberOfItems: Int {
        return 1000
    }

    func image(at index: Int) -> UIImage {
        let mockIndex: Int
        if let knownMockIndex = mockIndices[index] {
            mockIndex = knownMockIndex
        } else {
            mockIndex = Int(arc4random_uniform(UInt32(mockImages.count)))
            mockIndices[index] = mockIndex
        }
        return mockImages[mockIndex]
    }
}
