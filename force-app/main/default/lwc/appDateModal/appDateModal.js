import { LightningElement } from 'lwc';
import dateIcon from '@salesforce/resourceUrl/APP_DateIcon';
import dateIcon2 from '@salesforce/resourceUrl/APP_DateIcon2';

export default class AppDateModal extends LightningElement {
    dateIcon = dateIcon;
    dateIcon2 = dateIcon2;
    dataInicial;
    dataFinal;

    get botaoDesabilitado() {
        return !(this.dataInicial && this.dataFinal);
    }

    get confirmButtonClass() {
        return this.botaoDesabilitado ? 'confirm-date disabled' : 'confirm-date';
    }

    handleDataInicialChange(event) {
        const valor = event.target.value;
        if (valor) {
            const [ano, mes, dia] = valor.split('-').map(Number);
            const data = new Date(ano, mes - 1, dia, 12);
            data.setHours(0, 0, 0, 0);
            this.dataInicial = data;
        } else {
            this.dataInicial = null;
        }
    }

    handleDataFinalChange(event) {
        const valor = event.target.value;
        if (valor) {
            const [ano, mes, dia] = valor.split('-').map(Number);
            const data = new Date(ano, mes - 1, dia, 12);
            data.setHours(0, 0, 0, 0);
            this.dataFinal = data;
        } else {
            this.dataFinal = null;
        }
    }

    aplicarFiltro() {
        if (this.botaoDesabilitado) return;

        this.dispatchEvent(new CustomEvent('confirmar', {
            detail: {
                dataInicial: this.dataInicial,
                dataFinal: this.dataFinal
            },
            bubbles: true,
            composed: true
        }));
    }

    fecharModal() {
        this.dispatchEvent(new CustomEvent('fechar', {
            bubbles: true,
            composed: true
        }));
    }
}