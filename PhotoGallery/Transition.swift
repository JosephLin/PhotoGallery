//
//  Transition.swift
//  PhotoGallery
//
//  Created by Joseph Lin on 5/5/17.
//  Copyright © 2017 Joseph Lin. All rights reserved.
//

import UIKit

// MARK: -  Transition Controller

class TransitionController: NSObject  {
    var source: (frame: CGRect, image: UIImage)? {
        get {
            return animationController.source
        }
        set {
            animationController.source = newValue
        }
    }
    let animationController = AnimationController()
}

extension TransitionController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController.direction = .presenting
        return animationController
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController.direction = .dismissing
        return animationController
    }
}

// MARK: - Animation Controller

class AnimationController: NSObject {
    enum Direction {
        case presenting
        case dismissing
    }
    var direction: Direction = .presenting

    var source: (frame: CGRect, image: UIImage)?
}

extension AnimationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to),
            let toViewController = transitionContext.viewController(forKey: .to),
            let source = source
            else {
                return
        }

        func frame(for imageSize: CGSize, centeredIn frame: CGRect) -> CGRect {
            var finalWidth = frame.size.width
            var finalHeight = finalWidth * (imageSize.height / imageSize.width)
            if finalHeight > frame.size.height {
                finalHeight = frame.size.height
                finalWidth = finalHeight * (imageSize.width / imageSize.height)
            }
            let finalFrame = frame.insetBy(dx: 0.5 * (frame.size.width - finalWidth), dy: 0.5 * (frame.size.height - finalHeight))
            return finalFrame
        }

        let duration = transitionDuration(using: transitionContext)
        let initialFrame = source.frame
        let finalFrame = frame(for: source.image.size, centeredIn: transitionContext.finalFrame(for: toViewController))

        let imageView = UIImageView(image: source.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        switch direction {
        case .presenting:
            transitionContext.containerView.addSubview(imageView)
            imageView.frame = source.frame
            UIView.animate(withDuration: duration, animations: {
                imageView.frame = finalFrame
            }, completion: { (_) in
                transitionContext.containerView.addSubview(toView)
                imageView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        case .dismissing:
            transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
            fromView.alpha = 1.0
            UIView.animate(withDuration: duration, animations: {
                fromView.alpha = 0.0
            }, completion: { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }

    }

}

struct AnimationHelper {
    static func yRotation(_ angle: Double) -> CATransform3D {
        return CATransform3DMakeRotation(CGFloat(angle), 0.0, 1.0, 0.0)
    }

    static func perspectiveTransformForContainerView(_ containerView: UIView) {
        var transform = CATransform3DIdentity
        transform.m34 = -0.002
        containerView.layer.sublayerTransform = transform
    }
}
