//
//  ZoomableImageView.swift
//  PhotoGallery
//
//  Created by Joseph Lin on 5/9/17.
//  Copyright © 2017 Joseph Lin. All rights reserved.
//

import UIKit

class ZoomableImageView: UIScrollView {

    fileprivate let imageView = UIImageView()

    /// Expose the recognizer so that dependency can be created if needed.
    let doubleTapRecognizer = UITapGestureRecognizer()

    var image: UIImage? {
        didSet {
            imageView.image = image
            updateZoomScaleAndFrame()
        }
    }

    // MARK: -

    /// Common init
    private init(coder: NSCoder? = nil, frame: CGRect? = nil) {
        if let coder = coder {
            super.init(coder: coder)!
        } else if let frame = frame {
            super.init(frame: frame)
        } else {
            super.init()
        }

        imageView.contentMode = .scaleAspectFit
        imageView.frame = bounds

        addSubview(imageView)
        delegate = self
        bouncesZoom = true

        doubleTapRecognizer.addTarget(self, action: #selector(handleDoubleTap))
        doubleTapRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapRecognizer)
    }

    convenience override init(frame: CGRect) {
        self.init(coder: nil, frame: frame)
    }

    convenience required init?(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder, frame: nil)
    }

    // MARK: -

    override func layoutSubviews() {
        super.layoutSubviews()
        if zoomScale == 1.0 {
            updateZoomScaleAndFrame()
        }
    }

    private func updateZoomScaleAndFrame() {
        let imageSize = image?.size ?? .zero
        let scaleWidth = imageSize.width / bounds.size.width
        let scaleHeight = imageSize.height / bounds.size.height

        minimumZoomScale = 1.0
        maximumZoomScale = max(scaleWidth, scaleHeight)
        zoomScale = minimumZoomScale

        // Put imageView's origin at .zero and use contentInset to center it.
        // (Use origin to center the image would leave undesirable margins when zoomed)
        imageView.frame = CGRect(origin: .zero, size: bounds.aspectFit(size: imageSize).size)
        updateContentInset()
    }

    fileprivate func updateContentInset() {
        let horizontalInset = max(0, 0.5 * (bounds.size.width - imageView.frame.size.width))
        let verticalInset = max(0, 0.5 * (bounds.size.height - imageView.frame.size.height))
        contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }

    func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        if zoomScale == 1.0 {
            setZoomScale(maximumZoomScale, animated: true)
        } else {
            setZoomScale(1.0, animated: true)
        }
    }
}

// MARK: -

extension ZoomableImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentInset()
    }
}
