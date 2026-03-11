/**
 * Capacitor plugin interface for saving, deleting and listing images.
 */
export interface WidgetImageStorePlugin {
  /**
   * Saves a base64 image to storage.
   * @returns Path where the image was saved
   */
  save(options: WidgetImageStoreSaveOptions): Promise<{ path: string }>;

  /**
   * Deletes a previously saved image.
   */
  delete(options: WidgetImageStoreFileOptions): Promise<void>;

  /**
   * Deletes all images from storage except for the ones explicitly listed in `keep`.
   *
   * This is useful for cleaning up unused images after refreshing or regenerating widget data.
   */
  deleteExcept(options: WidgetImageStoreDeleteExceptOptions): Promise<void>;

  /**
   * Lists all saved image filenames.
   * @returns A list of filenames
   */
  list(options: WidgetImageStoreListOptions): Promise<{ files: string[] }>;

  /**
   * Checks if the given image exists.
   * @returns True if file exists
   */
  exists(options: WidgetImageStoreFileOptions): Promise<{ exists: boolean }>;

  /**
   * Returns the full path to the image file.
   * @returns The absolute file path
   */
  getPath(options: WidgetImageStoreFileOptions): Promise<{ path: string }>;
}

export type WidgetImageStoreImageFormat = 'auto' | 'jpeg' | 'jpg' | 'png' | 'webp';

/**
 * Options for saving an image to storage.
 */
export interface WidgetImageStoreSaveOptions {
  /** Base64 encoded image string, optionally with data URL prefix */
  base64: string;

  /** Filename to store the image under (e.g. `example.jpg`) */
  filename: string;

  /** App Group ID (iOS), ignored on Android */
  appGroup: string;

  /** Whether to resize image to max 1024px before saving (optional) */
  resize?: boolean;

  /**
   * Output format strategy.
   * - Omitted or `auto`: chooses based on explicit source type when available and preserves alpha when needed
   * - `jpeg` / `jpg`, `png`, `webp`: forces a concrete format
   *
   * If `filename` includes an extension, it must match the resolved output format.
   * Filenames without an extension are allowed.
   */
  format?: WidgetImageStoreImageFormat;

  /**
   * Compression quality between 0 and 1.
   * Used by lossy formats (`jpeg` and lossy `webp`), ignored by `png`.
   * Defaults to `0.85`.
   */
  quality?: number;
}

/**
 * Options for deleting an image.
 */
export interface WidgetImageStoreFileOptions {
  /** Filename of the image to delete */
  filename: string;

  /** App Group ID (iOS), ignored on Android */
  appGroup: string;
}

/**
 * Options for deleting all images except specific ones.
 */
export interface WidgetImageStoreDeleteExceptOptions {
  /**
   * List of filenames to keep. All other images will be deleted.
   */
  keep: string[];

  /**
   * App Group ID (iOS), ignored on Android.
   */
  appGroup: string;
}

/**
 * Options for listing all saved images.
 */
export interface WidgetImageStoreListOptions {
  /** App Group ID (iOS), ignored on Android */
  appGroup: string;
}
