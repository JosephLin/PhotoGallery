//
//  ViewController.swift
//  Gallery
//
//  Created by Joseph Lin on 5/3/17.
//  Copyright © 2017 Joseph Lin. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

class GridViewController: UICollectionViewController {

    let animationController = AnimationController()

    // MARK: -

    private struct Layout {
        private static let numberOfColumns = 2
        private static let sectionInset: CGFloat = 18
        private static let itemSpacing: CGFloat = 10
        private static let aspectRatio: CGFloat = 4.0 / 3.0

        static func updateLayout(_ layout: UICollectionViewFlowLayout, forViewWidth viewWidth: CGFloat) {
            layout.sectionInset = UIEdgeInsets(top: sectionInset, left: sectionInset, bottom: sectionInset, right: sectionInset)
            layout.minimumInteritemSpacing = itemSpacing
            layout.minimumLineSpacing = itemSpacing
            let width = floor((viewWidth - (2 * sectionInset) - (CGFloat(numberOfColumns - 1) * itemSpacing)) / CGFloat(numberOfColumns))
            let height = width / aspectRatio
            layout.itemSize = CGSize(width: width, height: height)
        }
    }

    // MARK: -

    private struct DataSource {
        static let numberOfImages = 1000

        /// Mock images
        static let sampleImages = [
            #imageLiteral(resourceName: "DSC09241"),
            #imageLiteral(resourceName: "DSC09249"),
            #imageLiteral(resourceName: "DSC09737"),
            ]

        static var mockIndices = [Int:Int]()

        static func image(at index: Int) -> UIImage {
            let mockIndex: Int
            if let knownMockIndex = mockIndices[index] {
                mockIndex = knownMockIndex
            } else {
                mockIndex = Int(arc4random_uniform(UInt32(sampleImages.count)))
                mockIndices[index] = mockIndex
            }
            return sampleImages[mockIndex]
        }
    }


    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        updateLayout()
    }

    func updateLayout() {
        guard let collectionView = collectionView, let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        Layout.updateLayout(layout, forViewWidth: collectionView.frame.size.width)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataSource.numberOfImages
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.imageView.image = DataSource.image(at: indexPath.item)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = DataSource.image(at: indexPath.item)
        let controller = DetailViewController.controller(with: image)
        controller.transitioningDelegate = self
        present(controller, animated: true, completion: nil)
    }
}

extension GridViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animationController.originFrame = CGRect.zero
        return self.animationController
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animationController.originFrame = CGRect.zero
        return self.animationController
    }

}

class DetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage!

    static func controller(with image: UIImage) -> DetailViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        controller.image = image
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


