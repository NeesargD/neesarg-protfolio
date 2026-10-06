# Work assets

Screenshots and app icons for the "Selected Work" gallery. These were pulled
from the live App Store listings (`<slug>_1.<ext>` = screenshot,
`<slug>_icon.jpg` = app icon) and are bundled as assets.

Projects + App Store IDs are defined in
`lib/core/data/resume_data.dart` → `featuredWork`.

To refresh or add an app: add its entry in `featuredWork`, drop
`<slug>_1.png` and `<slug>_icon.jpg` here, and rebuild. A missing screenshot
falls back to a styled placeholder, so the build never breaks.
