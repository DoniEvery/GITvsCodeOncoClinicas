import { LightningElement } from 'lwc';

export default class AppFaqPage extends LightningElement {
    selectedArtigoId;

    handleArtigoChange(event) {
        this.selectedArtigoId = event.detail;
    }
}