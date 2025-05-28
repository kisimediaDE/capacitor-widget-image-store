import { registerPlugin } from '@capacitor/core';

import type { WidgetImageStorePlugin } from './definitions';

const WidgetImageStore = registerPlugin<WidgetImageStorePlugin>('WidgetImageStore', {
  web: () => import('./web').then((m) => new m.WidgetImageStoreWeb()),
});

export * from './definitions';
export { WidgetImageStore };
