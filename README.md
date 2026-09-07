# The Quiet Atlas

A Flutter flipbook with eight illustrated pages, solid opaque paper, a shaded spine,
and interactive page folds. The sample artwork is drawn locally; no external
assets or additional packages are needed.

## Run

```sh
flutter pub get
flutter run -d chrome
```

The book starts closed with an illustrated front cover. Drag its right edge or
press Next to open it. Going back from the first spread closes the front cover.
Turning forward from pages 07–08 closes the book onto its back cover. Drag the
back cover’s left edge or press Previous to reopen the last spread.
Both covers fold like paper, using the same drag-driven crease, reverse
side, and crease shading as the inner pages. The book and turning sheets cast
no external shadows.
Page faces fully cover the content underneath; shading is confined to the crease.

Drag from either outer edge to turn forward or backward. The fold follows both
axes of the pointer. Release past the middle or flick to complete a turn; shorter
drags settle back. Arrow buttons and the left/right keyboard arrows also turn pages.
Use a finger or hold the primary mouse button to drag, on mobile or desktop.
Edge grab areas expand on small screens, and grabbing uses the initial press
position so fast movement does not miss the edge.
Double-tap a page to fit its full width and height inside the reading area;
the tapped page is centered, and closed covers fit as a single page. Double-tap
again to return to the original size. Pinch with two fingers for zoom between 1x and 3x. While zoomed,
drag the page body to pan or its outer edge to turn. Adding a second finger
cancels a pending page turn before zooming. The header and bottom controls stay
fixed: only the flipbook transforms, clipped to the reading area.
The flipbook has external padding of 24 logical pixels on the left and right,
and 12 on the top and bottom at default zoom. This padding scales and pans with
the book and is included when fitting a page into the reading area.
Extreme pulls are constrained by the sheet's distance from both spine endpoints,
so the fold stays attached to the binding when dragged beyond the book.

The book scales to the available screen. Page content is painted in
`BookPainter._paintPage` in `lib/main.dart`. The effect uses a geometric fold with
reflected reverse-side content and dynamic shading, rather than a physical
paper simulation.

Page artwork is recorded once and warmed into reusable images. Pointer and
animation updates repaint only the book instead of rebuilding the screen.
The cache uses the display scale, caps images at 2x resolution (about 51 MiB
for ten faces), and releases its images and pictures when the book is disposed.

## Verify

```sh
flutter analyze
flutter test
flutter build web
```

For an informational headless rendering benchmark, run
`flutter test test/render_benchmark.dart`. It reports drawing-command recording
and rasterization/readback time; it does not measure browser or device FPS.
Use `flutter run -d chrome --release` to check normal playback performance.
# ppcts
