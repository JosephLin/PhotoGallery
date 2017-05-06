//
//  ViewController.swift
//  Gallery
//
//  Created by Joseph Lin on 5/3/17.
//  Copyright © 2017 Joseph Lin. All rights reserved.
//

import UIKit

class GridViewController: UICollectionViewController {

    // MARK: - Static Helper Structs

    private struct Layout {
        private static let numberOfColumns = 2
        private static let sectionInset: CGFloat = 18
        private static let itemSpacing: CGFloat = 10
        private static let aspectRatio: CGFloat = 4.0 / 3.0

        static func updateLayout(on collectionView: UICollectionView) {
            guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
                return
            }

            layout.sectionInset = UIEdgeInsets(top: sectionInset, left: sectionInset, bottom: sectionInset, right: sectionInset)
            layout.minimumInteritemSpacing = itemSpacing
            layout.minimumLineSpacing = itemSpacing
            let viewWidth = collectionView.frame.size.width
            let width = floor((viewWidth - (2 * sectionInset) - (CGFloat(numberOfColumns - 1) * itemSpacing)) / CGFloat(numberOfColumns))
            let height = width / aspectRatio
            layout.itemSize = CGSize(width: width, height: height)
        }
    }

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let collectionView = collectionView {
            Layout.updateLayout(on: collectionView)
        }
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
        let frame = collectionView.layoutAttributesForItem(at: indexPath)!.frame
        let convertedFrame = collectionView.convert(frame, to: collectionView.window)
        let image = DataSource.image(at: indexPath.item)

        let controller = DetailViewController.controller(with: image)
        controller.transitionController.source = (frame: convertedFrame, image: image)
        present(controller, animated: true, completion: nil)
    }
}

// MARK: - Image Cell

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
