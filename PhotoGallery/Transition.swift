//
//  Transition.swift
//  PhotoGallery
//
//  Created by Joseph Lin on 5/5/17.
//  Copyright © 2017 Joseph Lin. All rights reserved.
//

import UIKit

protocol ImageZoomable {
    var isTransitioning: Bool { get set }
    var targetImage: UIImage { get }
    func targetFrame(in view: UIView, shouldCenterIfOffScreen: Bool) -> CGRect
}

// MARK: -  Transition Controller

class TransitionController: NSObject  {
    fileprivate let animationController: AnimationController
    fileprivate let interactionController: InteractionController

    override init() {
        animationController = AnimationController()
        interactionController = InteractionController()
        interactionController.animator = animationController
        super.init()
    }

    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        interactionController.handlePan(recognizer)
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
            interactionController.animator = animationController
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
}

// MARK: -

extension AnimationController: UIViewControllerAnimatedTransitioning {

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
        func imageZoomable(from vc: UIViewController) -> ImageZoomable? {
            if let controller = vc as? ImageZoomable {
                return controller
            }
            if let navController = vc as? UINavigationController, let controller = navController.topViewController as? ImageZoomable {
                return controller
            }
            return nil
        }
        var gridZoomable: ImageZoomable
        var detailZoomable: ImageZoomable
        switch direction {
        case .presenting:
            gridZoomable = imageZoomable(from: fromViewController)!
            detailZoomable = imageZoomable(from: toViewController)!
        case .dismissing:
            gridZoomable = imageZoomable(from: toViewController)!
            detailZoomable = imageZoomable(from: fromViewController)!
        }

        // Calculate the frames
        let image = detailZoomable.targetImage
        let viewFrame = transitionContext.finalFrame(for: toViewController)
        let gridImageFrame = gridZoomable.targetFrame(in: transitionContext.containerView, shouldCenterIfOffScreen: true)
        let detailImageFrame = detailZoomable.targetFrame(in: transitionContext.containerView, shouldCenterIfOffScreen: false)
        toView.frame = viewFrame


        // Hides the image views...
        gridZoomable.isTransitioning = true
        detailZoomable.isTransitioning = true

        // ...and use a mock image view for animation
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        transitionContext.containerView.addSubview(imageView)

        // Set proper states by direction
        let startState, endState: () -> Void
        switch direction {
        case .presenting:
            startState = {
                transitionContext.containerView.insertSubview(toView, belowSubview: imageView)
                toView.alpha = 0.0
                imageView.frame = gridImageFrame
            }
            endState = {
                toView.alpha = 1.0
                imageView.frame = detailImageFrame
            }
        case .dismissing:
            startState = {
                transitionContext.containerView.insertSubview(toView, at: 0)
                fromView.alpha = 1.0
                imageView.frame = detailImageFrame
            }
            endState = {
                fromView.alpha = 0.0
                imageView.frame = gridImageFrame
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
                imageView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}

// MARK: - Interaction Controller

class InteractionController: NSObject {
    weak var animator: AnimationController?
    fileprivate var transitionContext: UIViewControllerContextTransitioning?
    private var origin: CGPoint?
    private let minimumPanDistance: CGFloat = 50

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
            transitionContext?.completeTransition(false)
            origin = nil

        case .ended:
            if let origin = origin, let center = recognizer.view?.center, origin.distance(to: center) > minimumPanDistance {
                if let transitionContext = transitionContext {
                    animator?.animateTransition(using: transitionContext)
                }
                transitionContext = nil
            } else {
                UIView.animate(withDuration: 0.2, animations: { 
                    recognizer.view?.center = self.origin!
                }, completion: { (_) in
                    self.transitionContext?.cancelInteractiveTransition()
                    self.transitionContext?.completeTransition(false)
                })
            }
            origin = nil

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
