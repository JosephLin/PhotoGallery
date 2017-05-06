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

        transitionController.addPanRecognizer(to: view)
        imageView.image = image
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
