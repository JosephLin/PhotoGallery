//
//  Transition.swift
//  PhotoGallery
//
//  Created by Joseph Lin on 5/5/17.
//  Copyright © 2017 Joseph Lin. All rights reserved.
//

import UIKit

protocol ImageZoomable {
    var targetImage: UIImage { get }
    func targetFrame(in view: UIView) -> CGRect
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

        let duration = transitionDuration(using: transitionContext)

        // Calculate needed frames
        let gridZoomable: ImageZoomable
        let detailZoomable: ImageZoomable
        switch direction {
        case .presenting:
            gridZoomable = fromViewController as! ImageZoomable
            detailZoomable = toViewController as! ImageZoomable
        case .dismissing:
            gridZoomable = toViewController as! ImageZoomable
            detailZoomable = fromViewController as! ImageZoomable
        }

        let image = detailZoomable.targetImage
        let viewFrame = transitionContext.finalFrame(for: toViewController)
        let gridImageFrame = gridZoomable.targetFrame(in: transitionContext.containerView)
        let detailImageFrame = detailZoomable.targetFrame(in: transitionContext.containerView)


        // Insert the toView at the bottom. It would be fully covered by blackBackground until the end of the animation.
        transitionContext.containerView.insertSubview(toView, at: 0)

        // A white mask that covers the source image, so that it looks like the image is being moved instead of copied.
        let mask = UIView()
        mask.backgroundColor = .white
        mask.frame = gridImageFrame
        transitionContext.containerView.addSubview(mask)

        // A black background that fades with the zooming animation
        let blackBackground = UIView()
        blackBackground.backgroundColor = .black
        blackBackground.frame = viewFrame
        transitionContext.containerView.addSubview(blackBackground)

        // The image view used in the zooming animation
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        transitionContext.containerView.addSubview(imageView)

        let startState, endState: () -> Void
        switch direction {
        case .presenting:
            startState = {
                blackBackground.alpha = 0.0
                imageView.frame = gridImageFrame
            }
            endState = {
                blackBackground.alpha = 1.0
                imageView.frame = detailImageFrame
            }


        case .dismissing:
            startState = {
                fromView.alpha = 0.0
                blackBackground.alpha = 1.0
                imageView.frame = detailImageFrame
            }
            endState = {
                blackBackground.alpha = 0.0
                imageView.frame = gridImageFrame
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
    weak var animator: AnimationController?
    fileprivate var transitionContext: UIViewControllerContextTransitioning?
    private var origin: CGPoint?


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
