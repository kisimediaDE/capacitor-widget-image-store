# capacitor-widget-image-store

Save base64 images to shared App Group container

## Install

```bash
npm install capacitor-widget-image-store
npx cap sync
```

## API

<docgen-index>

* [`save(...)`](#save)
* [`delete(...)`](#delete)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### save(...)

```typescript
save(options: { base64: string; filename: string; appGroup: string; }) => Promise<{ path: string; }>
```

| Param         | Type                                                                 |
| ------------- | -------------------------------------------------------------------- |
| **`options`** | <code>{ base64: string; filename: string; appGroup: string; }</code> |

**Returns:** <code>Promise&lt;{ path: string; }&gt;</code>

--------------------


### delete(...)

```typescript
delete(options: { filename: string; appGroup: string; }) => Promise<void>
```

| Param         | Type                                                 |
| ------------- | ---------------------------------------------------- |
| **`options`** | <code>{ filename: string; appGroup: string; }</code> |

--------------------

</docgen-api>
