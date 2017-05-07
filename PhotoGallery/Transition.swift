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
    let animationController = AnimationController()
    let interactionController = InteractionController()

    var source: (frame: CGRect, image: UIImage)? {
        get {
            return animationController.source
        }
        set {
            animationController.source = newValue
        }
    }
}

// MARK: -

extension TransitionController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController.direction = .presenting
        return animationController
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController.direction = .dismissing
        return animationController
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactionController.isPanning {
            interactionController.animator = animator
            return interactionController
        }
        return nil
    }
}

// MARK: - Animation Controller

class AnimationController: NSObject {

    // MARK: Constants

    let transitionDuration: TimeInterval = 0.5
    let dampingRatio: CGFloat = 0.8

    // MARK: Properties

    enum Direction {
        case presenting
        case dismissing
    }
    var direction: Direction = .presenting

    var source: (frame: CGRect, image: UIImage)?

}

// MARK: -

extension AnimationController: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
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

        func aspectFitFrame(for size: CGSize, in frame: CGRect) -> CGRect {
            var finalWidth = frame.size.width
            var finalHeight = finalWidth * (size.height / size.width)

            if finalHeight > frame.size.height {
                finalHeight = frame.size.height
                finalWidth = finalHeight * (size.width / size.height)
            }

            let finalFrame = frame.insetBy(dx: 0.5 * (frame.size.width - finalWidth), dy: 0.5 * (frame.size.height - finalHeight))

            return finalFrame
        }

        let duration = transitionDuration(using: transitionContext)

        // Calculate needed frames
        let initialImageFrame = source.frame
        let finalViewFrame = transitionContext.finalFrame(for: toViewController)
        let finalImageFrame = aspectFitFrame(for: source.image.size, in: finalViewFrame)

        // Insert the toView at the bottom. It would be fully covered by blackBackground until the end of the animation.
        transitionContext.containerView.insertSubview(toView, at: 0)

        // A white mask that covers the source image, so that it looks like the image is being moved instead of copied.
        let mask = UIView()
        mask.backgroundColor = .white
        mask.frame = initialImageFrame
        transitionContext.containerView.addSubview(mask)

        // A black background that fades with the zooming animation
        let blackBackground = UIView()
        blackBackground.backgroundColor = .black
        blackBackground.frame = finalViewFrame
        transitionContext.containerView.addSubview(blackBackground)

        // The image view used in the zooming animation
        let imageView = UIImageView(image: source.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        transitionContext.containerView.addSubview(imageView)

        let startState, endState: () -> Void
        switch direction {
        case .presenting:
            startState = {
                blackBackground.alpha = 0.0
                imageView.frame = initialImageFrame
            }
            endState = {
                blackBackground.alpha = 1.0
                imageView.frame = finalImageFrame
            }


        case .dismissing:
            startState = {
                fromView.alpha = 0.0
                blackBackground.alpha = 1.0
                imageView.frame = finalImageFrame
            }
            endState = {
                blackBackground.alpha = 0.0
                imageView.frame = initialImageFrame
            }
        }

        startState()
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            usingSpringWithDamping: dampingRatio,
            initialSpringVelocity: 0.0,
            options: [.curveEaseInOut],
            animations: {
                endState()
            },
            completion: { (_) in
                mask.removeFromSuperview()
                blackBackground.removeFromSuperview()
                imageView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}

// MARK: - Interaction Controller

class InteractionController: NSObject {
    private var origin: CGPoint?
    fileprivate var transitionContext: UIViewControllerContextTransitioning?
    var animator: UIViewControllerAnimatedTransitioning?

    var isPanning: Bool {
        return origin != nil
    }

    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            origin = recognizer.view?.center

        case .changed:
            if let origin = origin {
                let translation = recognizer.translation(in: recognizer.view)
                recognizer.view?.center = CGPoint(x: origin.x + translation.x, y: origin.y + translation.y)
            }

        case .cancelled:
            transitionContext?.cancelInteractiveTransition()
            origin = nil
            transitionContext = nil

        case .ended:
            if let transitionContext = transitionContext {
                animator?.animateTransition(using: transitionContext)
            }
            origin = nil
            transitionContext = nil

        default:
            break;
        }
    }
}

extension InteractionController: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
    }
}
