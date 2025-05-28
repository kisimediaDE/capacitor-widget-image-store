import { WebPlugin } from '@capacitor/core';

import type { WidgetImageStorePlugin } from './definitions';

export class WidgetImageStoreWeb extends WebPlugin implements WidgetImageStorePlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
