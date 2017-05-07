//
//  DetailViewController.swift
//  PhotoGallery
//
//  Created by Joseph Lin on 5/5/17.
//  Copyright © 2017 Joseph Lin. All rights reserved.
//

import UIKit

protocol LayoutDelegate: class {
    func frameForThumbnail(at index: Int, in view: UIView) -> CGRect
}

class DetailViewController: UIViewController {
    var dataSource: DataSource!
    var currentIndex: Int!
    weak var layoutDelegate: LayoutDelegate!
    let transitionController = TransitionController()
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 10])

    // MARK: -

    static func controller(with dataSource: DataSource, currentIndex: Int, delegate: LayoutDelegate) -> DetailViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        controller.dataSource = dataSource
        controller.currentIndex = currentIndex
        controller.layoutDelegate = delegate
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

        let image = dataSource.image(at: currentIndex)
        let controller = ImageViewController.controller(with: image, index: currentIndex)
        pageViewController.setViewControllers([controller], direction: .forward, animated: false, completion: nil)

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
        let newIndex = currentIndex - 1
        guard newIndex >= 0 else {
            return nil
        }
        let image = dataSource.image(at: newIndex)
        let controller = ImageViewController.controller(with: image, index: newIndex)
        return controller
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let newIndex = currentIndex + 1
        guard newIndex < dataSource.numberOfItems else {
            return nil
        }
        let image = dataSource.image(at: newIndex)
        let controller = ImageViewController.controller(with: image, index: newIndex)
        return controller
    }
}

extension DetailViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let controller = pageViewController.viewControllers?.first as? ImageViewController {
            currentIndex = controller.index
        }
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
