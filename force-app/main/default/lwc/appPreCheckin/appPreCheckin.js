import { LightningElement } from 'lwc';
import nurseImage from '@salesforce/resourceUrl/APP_Nurse';
import APP_MedicoImagem from '@salesforce/resourceUrl/APP_MedicoImagem';

export default class PreCheckin extends LightningElement {
    nurseImage = nurseImage;
    APP_MedicoImagem = APP_MedicoImagem;

    handleCheckin() {
        const modalEvent = new CustomEvent('openlgpdmodal');
        this.dispatchEvent(modalEvent);
    }
}