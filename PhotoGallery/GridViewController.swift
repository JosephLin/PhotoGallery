//
//  ViewController.swift
//  Gallery
//
//  Created by Joseph Lin on 5/3/17.
//  Copyright © 2017 Joseph Lin. All rights reserved.
//

import UIKit

class GridViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate let dataSource = MockDataSource()
    private let numberOfColumns = 2
    private let sectionInset: CGFloat = 18
    private let itemSpacing: CGFloat = 10
    private let aspectRatio: CGFloat = 4.0 / 3.0

    var isTransitioning = false {
        didSet {
            let cell = collectionView.cellForItem(at: IndexPath(item: dataSource.currentIndex, section: 0))
            if isTransitioning {
                cell?.alpha = 0.0
            } else {
                cell?.alpha = 1.0
            }
        }
    }

    // MARK: Layout

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
}

// MARK: - UICollectionView DataSource / Delegate

extension GridViewController: UICollectionViewDataSource, UICollectionViewDelegate {

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

// MARK: - ImageZoomable

extension GridViewController: ImageZoomable {

    var targetImage: UIImage {
        return dataSource.image(at: dataSource.currentIndex) ?? UIImage()
    }

    func prepareTargetFrame(in view: UIView) -> CGRect {
        return prepareTargetFrame(in: view, shouldCenterIfOffScreen: true)
    }

    func prepareTargetFrame(in view: UIView, shouldCenterIfOffScreen: Bool) -> CGRect {
        let indexPath = IndexPath(item: dataSource.currentIndex, section: 0)
        guard let collectionView = collectionView, let attributes = collectionView.layoutAttributesForItem(at: indexPath) else {
            return .zero
        }
        let frame = collectionView.convert(attributes.frame, to: view)

        if shouldCenterIfOffScreen && collectionView.frame.intersects(frame) == false {
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            return prepareTargetFrame(in: view, shouldCenterIfOffScreen: false)
        } else {
            return frame
        }
    }
}

// MARK: - Image Cell

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        alpha = 1.0
    }
}
