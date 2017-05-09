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

    fileprivate let dummyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
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
        let gridImageFrame = gridZoomable.targetFrame(in: transitionContext.containerView, shouldCenterIfOffScreen: true)
        let detailImageFrame = detailZoomable.targetFrame(in: transitionContext.containerView, shouldCenterIfOffScreen: false)
        toView.frame = viewFrame


        // Hides the image views...
        gridZoomable.isTransitioning = true
        detailZoomable.isTransitioning = true

        // ...and use a dummy image view for animation
        dummyImageView.image = image

        // Set proper states by direction
        let startState, endState: () -> Void
        switch direction {
        case .presenting:
            startState = {
                transitionContext.containerView.addSubview(self.dummyImageView)
                transitionContext.containerView.insertSubview(toView, belowSubview: self.dummyImageView)
                toView.alpha = 0.0
                self.dummyImageView.frame = gridImageFrame
            }
            endState = {
                toView.alpha = 1.0
                self.dummyImageView.frame = detailImageFrame
            }
        case .dismissing:
            startState = {
                if !self.dummyImageView.isDescendant(of: transitionContext.containerView) {
                    transitionContext.containerView.addSubview(self.dummyImageView)
                    fromView.alpha = 1.0
                    self.dummyImageView.frame = detailImageFrame
                }
                transitionContext.containerView.insertSubview(toView, at: 0)
            }
            endState = {
                fromView.alpha = 0.0
                self.dummyImageView.frame = gridImageFrame
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
                self.dummyImageView.removeFromSuperview()
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
        var detailZoomable = transitionContext?.viewController(forKey: .from)?.findViewController(ofType: ImageZoomable.self)
        var gridZoomable = transitionContext?.viewController(forKey: .to)?.findViewController(ofType: ImageZoomable.self)

        switch recognizer.state {
        case .began:
            origin = recognizer.view?.center

        case .changed:
            if let origin = origin, let imageView = animator?.dummyImageView {
                let translation = recognizer.translation(in: recognizer.view)

                if let transitionContext = transitionContext, let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) {
                    if !imageView.isDescendant(of: transitionContext.containerView) {
                        if let frame = detailZoomable?.targetFrame(in: transitionContext.containerView, shouldCenterIfOffScreen: false) {
                            imageView.frame = frame
                        }
                        imageView.image = detailZoomable?.targetImage
                        transitionContext.containerView.addSubview(imageView)
                    }
                    _ = gridZoomable?.targetFrame(in: transitionContext.containerView, shouldCenterIfOffScreen: true)


                    detailZoomable?.isTransitioning = true
                    gridZoomable?.isTransitioning = true

                    if toView.isDescendant(of: transitionContext.containerView) == false {
                        transitionContext.containerView.insertSubview(toView, at: 0)
                    }

                    let distance = translation.distance(to: .zero)
                    let alpha = 1.0 - min(1.0, distance / (0.5 * fromView.frame.size.height))
                    fromView.alpha = alpha
                }

                imageView.center = CGPoint(x: origin.x + translation.x, y: origin.y + translation.y)
            }

        case .ended:
            if let origin = origin, let imageView = animator?.dummyImageView, origin.distance(to: imageView.center) > minimumPanDistance {
                if let transitionContext = transitionContext {
                    animator?.animateTransition(using: transitionContext)
                }
                transitionContext = nil
            } else {
                UIView.animate(withDuration: 0.2, animations: { 
                    self.animator?.dummyImageView.center = self.origin!
                    let fromView = self.transitionContext?.view(forKey: .from)
                    fromView!.alpha = 1.0

                }, completion: { (_) in
                    detailZoomable?.isTransitioning = false
                    gridZoomable?.isTransitioning = false
                    self.transitionContext?.cancelInteractiveTransition()
                    self.transitionContext?.completeTransition(false)
                    self.animator?.dummyImageView.removeFromSuperview()
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
