# capacitor-widget-image-store

Save base64 images to shared App Group container (iOS) or app-private storage (Android).  
Supports optional resizing and JPEG compression.

## Install

```bash
npm install capacitor-widget-image-store
npx cap sync
```

## Platform Behavior

On **iOS**, images are saved in the specified App Group container, which allows sharing data with widgets or other extensions.

On **Android**, images are stored in the app’s internal storage (`getFilesDir()`), private to the app by default.

## API

<docgen-index>

* [`save(...)`](#save)
* [`delete(...)`](#delete)
* [`deleteExcept(...)`](#deleteexcept)
* [`list(...)`](#list)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

Capacitor plugin interface for saving, deleting and listing images.

### save(...)

```typescript
save(options: WidgetImageStoreSaveOptions) => Promise<{ path: string; }>
```

Saves a base64 image to storage.

| Param         | Type                                                                                |
| ------------- | ----------------------------------------------------------------------------------- |
| **`options`** | <code><a href="#widgetimagestoresaveoptions">WidgetImageStoreSaveOptions</a></code> |

**Returns:** <code>Promise&lt;{ path: string; }&gt;</code>

--------------------


### delete(...)

```typescript
delete(options: WidgetImageStoreDeleteOptions) => Promise<void>
```

Deletes a previously saved image.

| Param         | Type                                                                                    |
| ------------- | --------------------------------------------------------------------------------------- |
| **`options`** | <code><a href="#widgetimagestoredeleteoptions">WidgetImageStoreDeleteOptions</a></code> |

--------------------


### deleteExcept(...)

```typescript
deleteExcept(options: WidgetImageStoreDeleteExceptOptions) => Promise<void>
```

Deletes all images from storage except for the ones explicitly listed in `keep`.

This is useful for cleaning up unused images after refreshing or regenerating widget data.

| Param         | Type                                                                                                |
| ------------- | --------------------------------------------------------------------------------------------------- |
| **`options`** | <code><a href="#widgetimagestoredeleteexceptoptions">WidgetImageStoreDeleteExceptOptions</a></code> |

--------------------


### list(...)

```typescript
list(options: WidgetImageStoreListOptions) => Promise<{ files: string[]; }>
```

Lists all saved image filenames.

| Param         | Type                                                                                |
| ------------- | ----------------------------------------------------------------------------------- |
| **`options`** | <code><a href="#widgetimagestorelistoptions">WidgetImageStoreListOptions</a></code> |

**Returns:** <code>Promise&lt;{ files: string[]; }&gt;</code>

--------------------


### Interfaces


#### WidgetImageStoreSaveOptions

Options for saving an image to storage.

| Prop           | Type                 | Description                                                    |
| -------------- | -------------------- | -------------------------------------------------------------- |
| **`base64`**   | <code>string</code>  | Base64 encoded image string, optionally with data URL prefix   |
| **`filename`** | <code>string</code>  | Filename to store the image under (e.g. `example.jpg`)         |
| **`appGroup`** | <code>string</code>  | App Group ID (iOS), ignored on Android                         |
| **`resize`**   | <code>boolean</code> | Whether to resize image to max 1024px before saving (optional) |


#### WidgetImageStoreDeleteOptions

Options for deleting an image.

| Prop           | Type                | Description                            |
| -------------- | ------------------- | -------------------------------------- |
| **`filename`** | <code>string</code> | Filename of the image to delete        |
| **`appGroup`** | <code>string</code> | App Group ID (iOS), ignored on Android |


#### WidgetImageStoreDeleteExceptOptions

Options for deleting all images except specific ones.

| Prop           | Type                  | Description                                                  |
| -------------- | --------------------- | ------------------------------------------------------------ |
| **`keep`**     | <code>string[]</code> | List of filenames to keep. All other images will be deleted. |
| **`appGroup`** | <code>string</code>   | App Group ID (iOS), ignored on Android.                      |


#### WidgetImageStoreListOptions

Options for listing all saved images.

| Prop           | Type                | Description                            |
| -------------- | ------------------- | -------------------------------------- |
| **`appGroup`** | <code>string</code> | App Group ID (iOS), ignored on Android |

</docgen-api>
