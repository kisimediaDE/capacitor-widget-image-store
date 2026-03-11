# Breaking Changes 8.1.0

This plugin update introduces behavioral breaking changes even though the public TypeScript API remains backwards-compatible.

## Affected behavior

### `save(...)` now validates filename extensions against the resolved output format

If `filename` includes an extension, it must match the final encoded format.

Examples:

- `example.jpg` must resolve to JPEG
- `example.png` must resolve to PNG
- `example.webp` must resolve to WebP

If the extension does not match, the save operation is rejected.

This is a breaking change because older versions could still write image data even when the filename extension did not reflect the actual encoded format.

### Omitting `format` now behaves like `auto`

When `format` is not provided, the plugin resolves the format from:

- explicit source MIME type when available
- filename extension when useful
- alpha/transparency requirements

This can cause inputs that were previously stored as JPEG to now resolve to PNG instead.

Example:

- a transparent image saved with `filename: "image.jpg"` and no explicit `format` may now be rejected, because `auto` resolves to PNG while the filename still says `.jpg`

## Not breaking

- Adding `format` and `quality` is additive at the API level
- Filenames without an extension are still allowed
- Alpha handling is more correct on iOS and no longer drops some transparent images into JPEG by mistake
