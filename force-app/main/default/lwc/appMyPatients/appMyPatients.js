import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import atendimentoIcon from '@salesforce/resourceUrl/APP_atendimentoIcon';

export default class AppMyPatients extends NavigationMixin(LightningElement) {
    atendimento = atendimentoIcon;

    handleNavigateInicio() {
        window.location.href = '/lightning/n/APP_Inicio';
    }
}