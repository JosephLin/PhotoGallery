# PhotoGallery
A proof-of-concept prototype that demonstrate the transition between the grid view and the detail view.

## Grid View
- In a typical gallery app like this, we would likely need to handle a large amount of images, and provide smooth scrolling across them. Topics to consider includes:
  - generate low-res thumbnails for the grid view, since the full-sized image might be huge.
  - prefetch images
  - release offscreen images vigilantly
- Since the focus of this prototypeo is the transition, we wouldn't spend too much effort on the performance. 
  - `MockDataSource`, a concrete implementation of `DataSource`, provides a seemly large amount of images from a few hi-res photos.
  - By using a protocol, we can easily replace the data source with a real one, or a different mock for unit testing.
  
### Questions / Feedback
- The spec shows the thumbnails in a fixed 4:3 aspect ratio. Unless the expected data source contains only 4:3 images, I assume we want the images to aspect-fill into the 4:3 frames.
  - Two other options: 1) Show the thumbnails in their original aspect ratios. It would mean that the inter-item spacing would no longer be constant. 2) Use square thumbnails. This seem to be a popular choice among gallery apps.
- The spec doesn't show a status bar. I would double-check if it's omitted to make the mock-up platform agnostic, or if they really don't want it to show on the actual product.
  - I would strongly suggest showing the status bar, because nobody wants to quit an app just to check the time or their network status. 


## Detail View
- The spec doesn't show an example of a portrait photo. I assume it'll aspect-fit the entire screen (extend behind top and bottom bars for very tall images).
- One of the most common and desirable feature is to allow swiping left or right to the previous or next photo.
  - When dismissing, it would need to transition to the thumbnail corresponding to the image currently on screen.
  - If the corresponding thumbnail is offscreen, the grid to scroll to center that thumbnail.
- Another common and desirable feature is image zooming (TODO)


## Transition
- The easiest solution is to show the detail view with a standard iOS modal pop-up. When user taps the 'x' button, dismiss the modal with a standard dismiss animation. But of course this is lame because:
  1. It's not 'contextual'- there's no visual cue to tell user which image is being presented. This is a even bigger issue when dismissing, because the user might already forget where they came from.
  2. The 'x' button, being on the upper-right corner, is hard to tap on larger screens.
- We can address (i) by doing a custom zooming transition:
  - When tapping on a thumbnail, the image should expand into its full-size position, as in the detail view. The background should crossfade into the solid black color at the same pace.
  - When dismissing, the full-size image should shrink into its corresponding thumbnail's position. The solid black background to crossfade away. Remember that user might have already swiped to a different image.
  - This effect can be achieved by providing a implemetation of `UIViewControllerAnimatedTransitioning` and `UIViewControllerTransitioningDelegate`
- We can adress (ii) by providing a 'swipe-to-dismiss' gesture:
  - When user pans the full-size image, the image should move with their figure; the background to crossfade as they move, to provide a cue that the view is about to be dismissed. When the user lets go their figure, the image should shrink back to the thumbnail as described above.
  - Since we preserved the swiping left/right gesture to image browsing, the dismiss gesture will only be triggered on swiping up or down.
  - Since we allow user to zoom an image, the swipe-to-dismiss gesture should only trigger when the top (or bottom) edge of the image is showing. (TODO)
  - If the user let go the figure without moving too much, the view should not be dismissed.
- We can make the animation looks physically natural by using a curve with ease-inout and slight overshoot and bouncing.
  - provide debug panel to control the animation variables (TODO)
- We can experiment with haptic feedback and/or sound effect to see if they enhence the experience. 3D touch & peek is another interesting option. (TODO)


# TODO
- Zoom
- debug menu
