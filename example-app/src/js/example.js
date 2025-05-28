import { WidgetImageStore } from 'capacitor-widget-image-store';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    WidgetImageStore.echo({ value: inputValue })
}
