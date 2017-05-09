# Change Log
This is a pseudo-changelog that documents the implementation process.

## 0.1
- Mock data source to provide large amount of randomly ordered images.
- Dynamic collection view layout for the grid view to match the design spec.
- Detail view is simply a full-screen image view with top and bottom bars.
- Default modal transition.

## 0.2
- Custom transition controller using `UIViewControllerTransitioningDelegate` and `UIViewControllerAnimatedTransitioning`
- Thumbnail expands into fullscreen image, with a dark background fading in at the same time.
- Tapping the close button will shrink the fullscreen image back to the thumbnail, with dark background fading out.

## 0.3
- Add support for swipe-to-dismiss gesture.

## 0.4
- Add support for swiping left and right to different images.
- Detail view now holds an UIPageViewController, with ImageViewController as its content.
- The end frame of the dismiss animation now needs to be calculated dynamically.

## 0.5
- Add support for single-tap to toggle toolbars.

## 0.6
- Add support for zooming the detail image.
- The ImageViewController now uses a ZoomableImageView instead of UIImageView.

## 0.7
- Add debug menu using iOS Settings Bundle
