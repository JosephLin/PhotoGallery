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

extension UIViewController {

    /// Check if 'self' is a given type, or if 'self' is a container controller, check its child view controller(s).
    func findViewController<T>(ofType type: T.Type) -> T? {
        if let controller = self as? T {
            return controller
        }
        if let navController = self as? UINavigationController, let controller = navController.topViewController as? T {
            return controller
        }
        return nil

    }
}

extension CGPoint {
    func distance(to point2: CGPoint) -> CGFloat {
        let distance = sqrt( pow(x - point2.x, 2) + pow(y - point2.y, 2) )
        return distance
    }
}

extension CGRect {
    func aspectFit(size: CGSize) -> CGRect {
        var finalWidth = self.size.width
        var finalHeight = finalWidth * (size.height / size.width)

        if finalHeight > self.size.height {
            finalHeight = self.size.height
            finalWidth = finalHeight * (size.width / size.height)
        }

        let finalFrame = self.insetBy(dx: 0.5 * (self.size.width - finalWidth), dy: 0.5 * (self.size.height - finalHeight))
        
        return finalFrame
    }
}
