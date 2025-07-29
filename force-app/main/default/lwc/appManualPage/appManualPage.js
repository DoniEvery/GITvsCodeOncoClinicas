import { LightningElement } from 'lwc';

export default class AppManualPage extends LightningElement {
    selectedArtigoId;

    handleArtigoChange(event) {
        this.selectedArtigoId = event.detail;
    }
}