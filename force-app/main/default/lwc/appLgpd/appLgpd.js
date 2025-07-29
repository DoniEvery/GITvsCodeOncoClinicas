import { LightningElement, api, track } from 'lwc';

export default class AppLgpd extends LightningElement {
    @api isOpen = false;
    @track isDisabled = true;

    handleCheckboxChange(event) {
        this.isDisabled = !event.target.checked;
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
        this.isDisabled = true;
    }

    handleContinue() {
        this.dispatchEvent(new CustomEvent('accept'));
        this.isDisabled = true;
    }
}