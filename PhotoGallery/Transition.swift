//
//  Transition.swift
//  PhotoGallery
//
//  Created by Joseph Lin on 5/5/17.
//  Copyright © 2017 Joseph Lin. All rights reserved.
//

import UIKit

protocol ImageZoomable {

    /// Notify the caller to show/hide necessary view(s) for animation
    var isTransitioning: Bool { get set }

    /// The target image for the zooming animation
    var targetImage: UIImage { get }

    /// Notify the caller to prepare the frame for animation.
    ///
    /// - Parameter view: The return value will be converted to this view's coordinate.
    /// - Returns: The frame that the target image should animate to/from.
    func prepareTargetFrame(in view: UIView) -> CGRect
}

// MARK: -  Transition Controller

class TransitionController: NSObject  {
    fileprivate let animator: Animator
    fileprivate let interactionController: InteractionController

    override init() {
        animator = Animator()
        interactionController = InteractionController()
        interactionController.animator = animator
        super.init()
    }

    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        interactionController.handlePan(recognizer)
    }
}

// MARK: -

extension TransitionController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.direction = .presenting
        return animator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.direction = .dismissing
        return animator
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactionController.isPanning {
            return interactionController
        }
        return nil
    }
}

// MARK: - Animator

private class Animator: NSObject {

    // MARK: Animation Characristics

    let transitionDuration: TimeInterval = 0.5
    let dampingRatio: CGFloat = 0.8

    // MARK: Properties

    enum Direction {
        case presenting
        case dismissing
    }
    var direction: Direction = .presenting

    fileprivate let dummyView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
}

// MARK: -

extension Animator: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
            else {
                return
        }

        // Grab necessary variables
        var gridZoomable: ImageZoomable
        var detailZoomable: ImageZoomable
        switch direction {
        case .presenting:
            gridZoomable = fromViewController.findViewController(ofType: ImageZoomable.self)!
            detailZoomable = toViewController.findViewController(ofType: ImageZoomable.self)!
        case .dismissing:
            gridZoomable = toViewController.findViewController(ofType: ImageZoomable.self)!
            detailZoomable = fromViewController.findViewController(ofType: ImageZoomable.self)!
        }

        // Calculate the frames
        let image = detailZoomable.targetImage
        let viewFrame = transitionContext.finalFrame(for: toViewController)
        let gridImageFrame = gridZoomable.prepareTargetFrame(in: transitionContext.containerView)
        let detailImageFrame = detailZoomable.prepareTargetFrame(in: transitionContext.containerView)
        toView.frame = viewFrame

        // Hides the image views...
        gridZoomable.isTransitioning = true
        detailZoomable.isTransitioning = true

        // ...and use a dummy image view for animation
        dummyView.image = image

        // Set proper states by direction
        let startState, endState: () -> Void
        switch direction {
        case .presenting:
            startState = {
                transitionContext.containerView.addSubview(self.dummyView)
                transitionContext.containerView.insertSubview(toView, belowSubview: self.dummyView)
                toView.alpha = 0.0
                self.dummyView.frame = gridImageFrame
            }
            endState = {
                toView.alpha = 1.0
                self.dummyView.frame = detailImageFrame
            }
        case .dismissing:
            startState = {
                // If dummyView is already in the view, it means the animator is taking over an interactive transition.
                if !self.dummyView.isDescendant(of: transitionContext.containerView) {
                    transitionContext.containerView.addSubview(self.dummyView)
                    fromView.alpha = 1.0
                    self.dummyView.frame = detailImageFrame
                }
                transitionContext.containerView.insertSubview(toView, at: 0)
            }
            endState = {
                fromView.alpha = 0.0
                self.dummyView.frame = gridImageFrame
            }
        }

        // Kick off the animation!
        startState()
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            usingSpringWithDamping: dampingRatio,
            initialSpringVelocity: 0.0,
            options: [.curveEaseInOut],
            animations: {
                endState()
            },
            completion: { (_) in
                gridZoomable.isTransitioning = false
                detailZoomable.isTransitioning = false
                self.dummyView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}

// MARK: - Interaction Controller

private class InteractionController: NSObject {

    // MARK: Gesture Characristics

    fileprivate let minimumPanDistance: CGFloat = 50
    fileprivate let maximumPanDistance: CGFloat = 150

    // MARK: Properties

    fileprivate weak var animator: Animator?
    fileprivate var transitionContext: UIViewControllerContextTransitioning?

    fileprivate var origin: CGPoint?
    fileprivate var isPanning: Bool {
        return origin != nil
    }
}

extension InteractionController {
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let detailZoomable = transitionContext?.viewController(forKey: .from)?.findViewController(ofType: ImageZoomable.self)
        let gridZoomable = transitionContext?.viewController(forKey: .to)?.findViewController(ofType: ImageZoomable.self)

        switch recognizer.state {
        case .began:
            origin = recognizer.view?.center

        case .changed:
            guard
                let origin = origin,
                let dummyView = animator?.dummyView,
                let transitionContext = transitionContext,
                let fromView = transitionContext.view(forKey: .from),
                let toView = transitionContext.view(forKey: .to),
                var gridZoomable = gridZoomable,
                var detailZoomable = detailZoomable
                else {
                    return
            }

            // Add toView, if not already in the stack
            if toView.isDescendant(of: transitionContext.containerView) == false {
                transitionContext.containerView.insertSubview(toView, at: 0)
            }

            // Add toView, if not already in the stack
            if !dummyView.isDescendant(of: transitionContext.containerView) {
                dummyView.frame = detailZoomable.prepareTargetFrame(in: transitionContext.containerView)
                dummyView.image = detailZoomable.targetImage
                transitionContext.containerView.addSubview(dummyView)

                // this is only called for its side-effect :/
                _ = gridZoomable.prepareTargetFrame(in: transitionContext.containerView)
            }

            detailZoomable.isTransitioning = true
            gridZoomable.isTransitioning = true

            let translation = recognizer.translation(in: recognizer.view)
            let distance = translation.distance(to: .zero)
            let alpha = 1.0 - min(1.0, distance / maximumPanDistance)
            fromView.alpha = alpha
            dummyView.center = CGPoint(x: origin.x + translation.x, y: origin.y + translation.y)

        case .ended:
            guard
                let origin = origin,
                let dummyView = animator?.dummyView,
                let transitionContext = transitionContext,
                let fromView = transitionContext.view(forKey: .from),
                var gridZoomable = gridZoomable,
                var detailZoomable = detailZoomable
                else {
                    return
            }

            if origin.distance(to: dummyView.center) > minimumPanDistance {
                animator?.animateTransition(using: transitionContext)
                self.transitionContext = nil
            } else {
                UIView.animate(
                    withDuration: 0.2,
                    animations: {
                        fromView.alpha = 1.0
                        self.animator?.dummyView.center = origin
                    },
                    completion: { (_) in
                        detailZoomable.isTransitioning = false
                        gridZoomable.isTransitioning = false
                        transitionContext.cancelInteractiveTransition()
                        transitionContext.completeTransition(false)
                        self.animator?.dummyView.removeFromSuperview()
                    }
                )
            }
            self.origin = nil

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
