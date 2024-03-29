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
- User can single-tap the view to hide/reveal the top and bottom toolbars.
- One of the most common and desirable feature is to allow swiping left or right to the previous or next photo.
  - When dismissing, it would need to transition to the thumbnail corresponding to the image currently on screen.
  - If the corresponding thumbnail is offscreen, the grid to scroll to center that thumbnail.
- Another common and desirable feature is image zooming:
  - At minimum zoom scale, the image would aspect-fit the screen. This is also the default scale when a detail view is being presented.
  - At maximum zoom scale, the image would at its 100% size.
  - When user tries to pinch beyond the allowed zoom scales, the zoom should bounce to provide a nice physical feedback.
  - User can double-tap the image to toggle between minimum and maximum scale.
    - This gesture to take precedence of the single-tap gesture mentioned above, so that the toolbars wouldn't toggle on a double-tap.
  - Zooming should be reset when user scrolls to a different image.


## Transition
- The easiest solution is to show the detail view with a standard iOS modal pop-up. When user taps the 'x' button, dismiss the modal with a standard dismiss animation. But of course this is lame because:
  1. It's not 'contextual'- there's no visual cue to tell user which image is being presented. This is a even bigger issue when dismissing, because the user might already forget where they came from.
  2. The 'x' button, being on the upper-right corner, is hard to tap on larger screens.
- We can address (i) by doing a custom zooming transition:
  - When tapping on a thumbnail, the image should expand into its full-size position, as in the detail view. The background should crossfade into the solid black color at the same pace.
  - When dismissing, the full-size image should shrink into its corresponding thumbnail's position. The solid black background to crossfade away. Remember that user might have already swiped to a different image.
  - This effect can be achieved by providing a implemetation of `UIViewControllerAnimatedTransitioning` and `UIViewControllerTransitioningDelegate`
- We can adress (ii) by providing a 'swipe-to-dismiss' gesture:
  - When user pans the full-size image, the image should move with their finger; the background to crossfade as they move, to provide a cue that the view is about to be dismissed. When the user lets go their figure, the image should shrink back to the thumbnail as described above.
  - Since we preserved the swiping left/right gesture to image browsing, the dismiss gesture will only be triggered on swiping up or down.
  - Swipe-to-dismiss is only allowed when the image is not zoomed beyond the size of the screen.
  - If the user let go the figure without moving too much, the view should not be dismissed.
- We can make the animation looks physically natural by using a curve with ease-inout and slight overshoot and bouncing.
  - A debug panel is provided in the system settings to control the animation variables.
- We can experiment with haptic feedback and/or sound effect to see if they enhence the experience. 3D touch & peek is another interesting option. (TODO)


# TODO
- Support device rotation
  - The current animation frame calculation code is buggy when the grid view's size changes dynamically. Support for landscape mode is disabled for now.
- Support different screen sizes
  - Current two-column grid view functions fine on an iPad, but the cells look ridiculously large. We'll need an adaptive design in later versions.
- Allow swipe-to-dismiss when zoomed
  - This is a minor feature that might improve usability. 

# Inspirations

I'm an amature photographer and I've accumulated quite a large amount of photos over the years. I've been constantly looking for a better photo browsing and managing app, so this is a topic that I care deeply about. My approach for this project is influenced by apps that I'm using or have used extensively in the past: Picasa, iPhoto, Aperture, Photos on mac and on iOS, Lightroom, Google Photos, etc. I also drew insiprations from other image-centric apps, like tumblr and instagram.

## Case study
(This only covers the user interaction, but not the functional stuff like syncing, performance, or AI) 

- (iOS) Photos
  - very natural zooming transition.
  - bouncing at the end of the zoom is a nice touch.
  - swipe up for detail with subtle animations going on.
  - swipe down to dismiss. If the current photo is outside of the frame, the grid re-centers.
  - Since the swipe-to-dismiss gesture is only on one direction, the dismiss/cancel behavior feels more deterministic. Though it's arguably less discoverable.
  - swipe left/right to change photo, though the parallex effect feels a bit too much.
  - Photo stripe at the bottom is my favorite feature- it allows user to change photo without any transition, making photo comparison a lot easier.
  - problematic scrolling and loading performance on large dataset. :( 

- Google Photos
  - zooming transition usually works great, but..
  - occasionally the animation path seems a bit odd, and the grid view might show the blank at a wrong position.
  - no bouncing at the end of the zoom.
  - pinch-zoomable grid is a nice feature
  - swipe up/down to dismiss. If the current photo is outside of the frame, the grid doesn't re-center. 
  - since the swipe-to-dismiss gesture is bi-directional, it's a bit trickier to cancel.
  
- Tumblr
  - The single-column feed serves a much different purpose than a grid.
  - Zooming animation, swipe-to-dismiss are both one-dimensional. It integrats nicely with the vertical feed scrolling.

- [NYTPhotoViewer](https://github.com/NYTimes/NYTPhotoViewer)
  - This open-source library from New York Times provides a nice out-of-box photo browser. I chose to write my own implementation instead of including it as a framework ~because it would be too easy~ because its approach doesn't allow the presenting view (i.e. the grid view) to be visible during the transition, and the gesture controls are not exactly to my liking. It did provide a solid starting point for my own transition controller implemetation.
  
