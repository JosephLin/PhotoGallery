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
        let initialImageFrame = source.frame
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        let finalImageFrame = frame(for: source.image.size, centeredIn: finalFrame)

        let imageView = UIImageView(image: source.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        let blackBackground = UIView()
        blackBackground.backgroundColor = .black
        blackBackground.frame = finalFrame
        blackBackground.alpha = 0.0

        let cover = UIView()
        cover.backgroundColor = .white
        cover.frame = initialImageFrame

        switch direction {
        case .presenting:
            transitionContext.containerView.addSubview(cover)
            transitionContext.containerView.addSubview(blackBackground)
            transitionContext.containerView.addSubview(imageView)
            imageView.frame = initialImageFrame
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0.0,
                options: [.curveEaseInOut],
                animations: {
                    blackBackground.alpha = 1.0
                    imageView.frame = finalImageFrame
            },
                completion: { (_) in
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
