//
//  ViewController.swift
//  Gallery
//
//  Created by Joseph Lin on 5/3/17.
//  Copyright © 2017 Joseph Lin. All rights reserved.
//

import UIKit

class GridViewController: UICollectionViewController {

    // MARK: - Properties

    private let numberOfColumns = 2
    private let sectionInset: CGFloat = 18
    private let itemSpacing: CGFloat = 10
    private let aspectRatio: CGFloat = 4.0 / 3.0
    private let dataSource = MockDataSource()

    // MARK: -

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateCollectionViewLayout()
    }

    func updateCollectionViewLayout() {
        guard let collectionView = collectionView, let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
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

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItems
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.imageView.image = dataSource.image(at: indexPath.item)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let frame = collectionView.layoutAttributesForItem(at: indexPath)!.frame
        let convertedFrame = collectionView.convert(frame, to: collectionView.window)
        let image = dataSource.image(at: indexPath.item)

        let controller = DetailViewController.controller(with: image)
        controller.transitionController.setThumbnail(image, frame: convertedFrame)
        present(controller, animated: true, completion: nil)
    }
}

// MARK: - Image Cell

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
