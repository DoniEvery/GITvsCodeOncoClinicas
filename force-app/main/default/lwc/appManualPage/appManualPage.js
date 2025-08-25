import { LightningElement } from 'lwc';

export default class AppManualPage extends LightningElement {
    selectedArtigoId;

    handleArtigoChange(event) {
        this.selectedArtigoId = event.detail;
    }


    renderedCallback() {

        // a pagina estava sempre sendo carregada na metade, e nao me permitia dar o scroll, ai fui no avo e dei o scroll
        const scrollEvent = new CustomEvent('scrolltoprequest', {
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(scrollEvent);

    }
}