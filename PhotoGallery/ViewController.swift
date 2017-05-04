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

    // MARK: -

    private struct Layout {
        private static let numberOfColumns = 2
        private static let sectionInset: CGFloat = 30
        private static let itemSpacing: CGFloat = 15
        private static let aspectRatio: CGFloat = 4.0 / 3.0

        static func itemSize(fromViewWidth viewWidth: CGFloat) -> CGSize {
            let width = (viewWidth - (2 * sectionInset) - (CGFloat(numberOfColumns - 1) * itemSpacing)) / CGFloat(numberOfColumns)
            let height = width / aspectRatio
            return CGSize(width: width, height: height)
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

        layout.itemSize = Layout.itemSize(fromViewWidth: collectionView.frame.size.width)
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
        navigationController?.pushViewController(controller, animated: true)
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
}


