import { LightningElement } from 'lwc';
import nurseImage from '@salesforce/resourceUrl/APP_Nurse';

export default class AppCheckinConfirm extends LightningElement {
    nurseImage = nurseImage;

    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancelar'));
    }

    handleConfirm() {
        this.dispatchEvent(new CustomEvent('confirmar'));
    }
}