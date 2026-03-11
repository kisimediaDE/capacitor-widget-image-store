# 🖼️ capacitor-widget-image-store

[![npm](https://img.shields.io/npm/v/capacitor-widget-image-store)](https://www.npmjs.com/package/capacitor-widget-image-store)
[![bundle size](https://img.shields.io/bundlephobia/minzip/capacitor-widget-image-store)](https://bundlephobia.com/result?p=capacitor-widget-image-store)
[![License: MIT](https://img.shields.io/npm/l/capacitor-widget-image-store)](./LICENSE)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20Android-orange)](#-platform-behavior)
[![Capacitor](https://img.shields.io/badge/capacitor-8.x-blue)](https://capacitorjs.com/)

A lightweight Capacitor plugin to **save**, **delete**, and **list** base64-encoded images in a shared app container — perfect for widget integrations on iOS and Android.

Supports:

✅ iOS (App Group container)  
✅ Android (internal file storage)  
✅ Resize on save (optional)  
✅ Cleanup helpers like `deleteExcept` and `exists`

---

## 🚀 Install

```bash
npm install capacitor-widget-image-store
npx cap sync
```

## 📱 Platform Behavior

### iOS

- Uses FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:)
- Only image files (.jpg, .jpeg, .png, .webp) are listed or deleted
- Non-image metadata is automatically filtered from list()
- appGroup is required

### Android

- Uses internal app files directory via getContext().getFilesDir()
- Ignores appGroup
- Same image file filtering applies

## 💡 Why this plugin?

Native widgets require local image file paths, not base64 strings. This plugin bridges the gap by storing base64-encoded images as accessible files — great for:

- iOS Widgets (via App Group)
- Android Widgets
- Local image caching for offline use
- Shared asset cleanup via deleteExcept

## 📘 API

<docgen-index>

* [`save(...)`](#save)
* [`delete(...)`](#delete)
* [`deleteExcept(...)`](#deleteexcept)
* [`list(...)`](#list)
* [`exists(...)`](#exists)
* [`getPath(...)`](#getpath)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

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
delete(options: WidgetImageStoreFileOptions) => Promise<void>
```

Deletes a previously saved image.

| Param         | Type                                                                                |
| ------------- | ----------------------------------------------------------------------------------- |
| **`options`** | <code><a href="#widgetimagestorefileoptions">WidgetImageStoreFileOptions</a></code> |

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


### exists(...)

```typescript
exists(options: WidgetImageStoreFileOptions) => Promise<{ exists: boolean; }>
```

Checks if the given image exists.

| Param         | Type                                                                                |
| ------------- | ----------------------------------------------------------------------------------- |
| **`options`** | <code><a href="#widgetimagestorefileoptions">WidgetImageStoreFileOptions</a></code> |

**Returns:** <code>Promise&lt;{ exists: boolean; }&gt;</code>

--------------------


### getPath(...)

```typescript
getPath(options: WidgetImageStoreFileOptions) => Promise<{ path: string; }>
```

Returns the full path to the image file.

| Param         | Type                                                                                |
| ------------- | ----------------------------------------------------------------------------------- |
| **`options`** | <code><a href="#widgetimagestorefileoptions">WidgetImageStoreFileOptions</a></code> |

**Returns:** <code>Promise&lt;{ path: string; }&gt;</code>

--------------------


### Interfaces


#### WidgetImageStoreSaveOptions

Options for saving an image to storage.

| Prop           | Type                                                                                | Description                                                                                                                                                                                                                                                                                                            |
| -------------- | ----------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`base64`**   | <code>string</code>                                                                 | Base64 encoded image string, optionally with data URL prefix                                                                                                                                                                                                                                                           |
| **`filename`** | <code>string</code>                                                                 | Filename to store the image under (e.g. `example.jpg`)                                                                                                                                                                                                                                                                 |
| **`appGroup`** | <code>string</code>                                                                 | App Group ID (iOS), ignored on Android                                                                                                                                                                                                                                                                                 |
| **`resize`**   | <code>boolean</code>                                                                | Whether to resize image to max 1024px before saving (optional)                                                                                                                                                                                                                                                         |
| **`format`**   | <code><a href="#widgetimagestoreimageformat">WidgetImageStoreImageFormat</a></code> | Output format strategy. - Omitted or `auto`: chooses based on explicit source type when available and preserves alpha when needed - `jpeg` / `jpg`, `png`, `webp`: forces a concrete format If `filename` includes an extension, it must match the resolved output format. Filenames without an extension are allowed. |
| **`quality`**  | <code>number</code>                                                                 | Compression quality between 0 and 1. Used by lossy formats (`jpeg` and lossy `webp`), ignored by `png`. Defaults to `0.85`.                                                                                                                                                                                            |


#### WidgetImageStoreFileOptions

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


### Type Aliases


#### WidgetImageStoreImageFormat

<code>'auto' | 'jpeg' | 'jpg' | 'png' | 'webp'</code>

</docgen-api>
