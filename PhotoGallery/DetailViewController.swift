//
//  DetailViewController.swift
//  PhotoGallery
//
//  Created by Joseph Lin on 5/5/17.
//  Copyright © 2017 Joseph Lin. All rights reserved.
//

import UIKit

//protocol DetailViewControllerDataSource: class {
//    func image(at index: Int) -> UIImage?
//    func frameForThumbnail(at index: Int, in view: UIView) -> CGRect
//}
//
//protocol DetailViewControllerDelegate: class {
//    func didScrollToImage(at index: Int)
//}

// MARK: -

class DetailViewController: UIViewController {
    fileprivate var dataSource: DataSource!
    private let transitionController = TransitionController()
    fileprivate let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 10])

    // MARK: -

    static func controller(with dataSource: DataSource) -> DetailViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
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

extension DetailViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let controller = pageViewController.viewControllers?.first as? ImageViewController {
            dataSource.currentIndex = controller.index
        }
    }
}

extension DetailViewController: ImageZoomable {
    var targetImage: UIImage {
        return dataSource.image(at: dataSource.currentIndex) ?? UIImage()
    }

    func targetFrame(in view: UIView) -> CGRect {
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

// MARK: -

class ImageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage!
    var index: Int!

    // MARK: -

    static func controller(with image: UIImage, index: Int) -> ImageViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
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
