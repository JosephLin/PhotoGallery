//
//  ViewController.swift
//  Gallery
//
//  Created by Joseph Lin on 5/3/17.
//  Copyright © 2017 Joseph Lin. All rights reserved.
//

import UIKit

class GridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Properties

    private let numberOfColumns = 2
    private let sectionInset: CGFloat = 18
    private let itemSpacing: CGFloat = 10
    private let aspectRatio: CGFloat = 4.0 / 3.0
    fileprivate let dataSource = MockDataSource()

    // MARK: - Layout

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

    // MARK: - Collection View DataSource / Delegate

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.imageView.image = dataSource.image(at: indexPath.item)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataSource.currentIndex = indexPath.item
        let controller = DetailViewController.controller(with: dataSource)
        present(controller, animated: true, completion: nil)
    }
}

extension GridViewController: ImageZoomable {
    var targetImage: UIImage {
        return dataSource.image(at: dataSource.currentIndex) ?? UIImage()
    }

    func targetFrame(in view: UIView) -> CGRect {
        let indexPath = IndexPath(item: dataSource.currentIndex, section: 0)
        guard let collectionView = collectionView, let attributes = collectionView.layoutAttributesForItem(at: indexPath) else {
            return .zero
        }
        let frame = collectionView.convert(attributes.frame, to: view)
        return frame
    }
}

// MARK: - Image Cell

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
