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
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    fileprivate var dataSource: DataSource!
    fileprivate let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 10])
    private let transitionController = TransitionController()

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

// MARK: - ImageZoomable

extension DetailViewController: ImageZoomable {
    var targetImage: UIImage {
        return dataSource.image(at: dataSource.currentIndex) ?? UIImage()
    }

    func targetFrame(in view: UIView, shouldCenterIfOffScreen: Bool) -> CGRect {
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

        return aspectFitFrame(for: targetImage.size, in: pageViewController.view.frame)
    }
}

// MARK: - ImageViewController

class ImageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
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
