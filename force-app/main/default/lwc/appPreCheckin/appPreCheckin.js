import { LightningElement, track } from 'lwc';
import nurseImage from '@salesforce/resourceUrl/APP_Nurse';
import APP_MedicoImagem from '@salesforce/resourceUrl/APP_MedicoImagem';

export default class AppPreCheckin extends LightningElement {
    nurseImage = nurseImage;
    APP_MedicoImagem = APP_MedicoImagem;

    @track showCheckin = true;
    @track showLgpd = false;
    @track showDadosCadastrais = false;
    @track showDadosResidenciais = false;
    @track showConfirmCheckin = false;

    handleCheckin() {
        this.showCheckin = false;
        this.showLgpd = true;
    }

    handleModalClose() {
        this.showLgpd = false;
        this.showCheckin = true;
    }

    handleModalAccept() {
        this.showLgpd = false;
        this.showDadosCadastrais = true;
    }

    handleContinuarCadastrais() {
        this.showDadosCadastrais = false;
        this.showDadosResidenciais = true;
    }

    // 🔧 ADICIONE ESTE MÉTODO para avançar da tela de dados residenciais para a tela de confirmação
    handleContinuarResidenciais() {
        this.showDadosResidenciais = false;
        this.showConfirmCheckin = true;
    }

    // 🔧 Pode manter esse se depois da tela de confirmação quiser fazer algo
    handleConfirmCheckin() {
        // Por exemplo: navegação final, ou resetar tudo
        console.log('Pré-check-in confirmado!');
    }

    handleVoltarParaCheckin() {
        this.showCheckin = true;
        this.showDadosCadastrais = false;
        this.showDadosResidenciais = false;
        this.showConfirmCheckin = false;
    }
}