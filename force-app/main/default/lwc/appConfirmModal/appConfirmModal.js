import { LightningElement, api } from 'lwc';
import detalhesConsultaIcon from '@salesforce/resourceUrl/APP_DetalhesConsultaIcon';

export default class AppConfirmModal extends LightningElement {
    @api titulo;
    @api texto;
    @api exibirModal = false;
    detalhesConsulta = detalhesConsultaIcon;

    fecharModal() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    confirmarAcao() {
        this.dispatchEvent(new CustomEvent('confirm'));
    }
}