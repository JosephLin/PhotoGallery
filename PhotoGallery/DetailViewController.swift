//
//  DetailViewController.swift
//  PhotoGallery
//
//  Created by Joseph Lin on 5/5/17.
//  Copyright © 2017 Joseph Lin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage!
    let transitionController = TransitionController()
    let panRecognizer = UIPanGestureRecognizer()

    // MARK: -

    static func controller(with image: UIImage) -> DetailViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        controller.image = image
        controller.transitioningDelegate = controller.transitionController
        return controller
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        panRecognizer.addTarget(self, action: #selector(handlePan))
        imageView.addGestureRecognizer(panRecognizer)
        imageView.image = image
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        transitionController.interactionController.handlePan(recognizer)

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
