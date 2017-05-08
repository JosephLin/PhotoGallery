//
//  Utilities.swift
//  PhotoGallery
//
//  Created by Joseph Lin on 5/7/17.
//  Copyright © 2017 Joseph Lin. All rights reserved.
//

import UIKit

extension UIViewController {
    class func controller(fromStoryboard storyboardName: String, identifier: String? = nil) -> Self? {
        return proxy(fromStoryboard: storyboardName, identifier: identifier)
    }

    private class func proxy<T: UIViewController>(fromStoryboard storyboardName: String, identifier: String? = nil) -> T? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier ?? String(describing: self))
        return controller as? T
    }
}

extension CGPoint {
    func distance(to point2: CGPoint) -> CGFloat {
        let distance = sqrt( pow(x - point2.x, 2) + pow(y - point2.y, 2) )
        return distance
    }
}
