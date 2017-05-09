//
//  DetailViewController.swift
//  PhotoGallery
//
//  Created by Joseph Lin on 5/5/17.
//  Copyright © 2017 Joseph Lin. All rights reserved.
//

import UIKit

// MARK: - DetailViewController

class DetailViewController: UIViewController {

    // MARK: - Constants

    static let interPageSpacing: CGFloat = 10.0
    let toolbarAnimationDuration: TimeInterval = 0.1

    // MARK: - Properties

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    fileprivate var dataSource: DataSource!
    fileprivate let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: interPageSpacing])
    private let transitionController = TransitionController()

    var isToolbarsHidden: Bool {
        return navigationBar.alpha == 0.0
    }
    var wasToolbarsHiddenBeforeTransitioning = false

    // MARK: -

    static func controller(with dataSource: DataSource) -> DetailViewController {
        let controller = DetailViewController.controller(fromStoryboard: "Main")!
        controller.dataSource = dataSource
        controller.transitioningDelegate = controller.transitionController
        return controller
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        addChildViewController(pageViewController)
        view.insertSubview(pageViewController.view, at: 0)
        pageViewController.didMove(toParentViewController: self)

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pageViewController.view.addGestureRecognizer(panRecognizer)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)

        if let dataSource = dataSource, let image = dataSource.image(at: dataSource.currentIndex) {
            let controller = ImageViewController.controller(with: image, index: dataSource.currentIndex)
            pageViewController.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
        }

        pageViewController.delegate = self;
        pageViewController.dataSource = self;
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        pageViewController.view.frame = self.view.bounds
    }

    // MARK: - User Interaction

    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        transitionController.handlePan(recognizer)

        switch recognizer.state {
        case .began:
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }

    func handleTap(_ recognizer: UITapGestureRecognizer) {
        setToolbarsHidden(!isToolbarsHidden, animated: true)
    }

    func setToolbarsHidden(_ hidden: Bool, animated: Bool) {
        let endState = {
            let newAlpha: CGFloat = (hidden) ? 0.0 : 1.0
            self.navigationBar.alpha = newAlpha
            self.toolbar.alpha = newAlpha
        }
        if animated {
            UIView.animate(withDuration: toolbarAnimationDuration, animations: endState)
        } else {
            endState()
        }
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIPageViewControllerDataSource

extension DetailViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let newIndex = dataSource.currentIndex - 1
        guard let image = dataSource.image(at: newIndex) else {
            return nil
        }
        let controller = ImageViewController.controller(with: image, index: newIndex)
        return controller
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let newIndex = dataSource.currentIndex + 1
        guard let image = dataSource.image(at: newIndex) else {
            return nil
        }
        let controller = ImageViewController.controller(with: image, index: newIndex)
        return controller
    }
}

// MARK: - UIPageViewControllerDelegate

extension DetailViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let controller = pageViewController.viewControllers?.first as? ImageViewController {
            dataSource.currentIndex = controller.index
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let controller = pageViewController.viewControllers?.first as? ImageViewController, otherGestureRecognizer == controller.imageView.doubleTapRecognizer {
            return true
        }
        return false
    }
}

// MARK: - ImageZoomable

extension DetailViewController: ImageZoomable {
    func setTransitioning(_ isTransitioning: Bool) {
        if isTransitioning {
            pageViewController.view.alpha = 0.0
            wasToolbarsHiddenBeforeTransitioning = isToolbarsHidden
            setToolbarsHidden(true, animated: true)

        } else {
            pageViewController.view.alpha = 1.0
            setToolbarsHidden(wasToolbarsHiddenBeforeTransitioning, animated: true)
        }
    }

    var targetImage: UIImage {
        return dataSource.image(at: dataSource.currentIndex) ?? UIImage()
    }

    func prepareTargetFrame(in view: UIView) -> CGRect {
        return pageViewController.view.frame.aspectFit(size: targetImage.size)
    }
}

// MARK: - ImageViewController

class ImageViewController: UIViewController {
    @IBOutlet weak var imageView: ZoomableImageView!
    var image: UIImage!
    var index: Int!

    // MARK: -

    static func controller(with image: UIImage, index: Int) -> ImageViewController {
        let controller = ImageViewController.controller(fromStoryboard: "Main")!
        controller.image = image
        controller.index = index
        return controller
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
