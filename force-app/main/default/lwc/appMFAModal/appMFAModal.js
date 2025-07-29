import { LightningElement, api } from 'lwc';
import validateToken from '@salesforce/apex/MfaController.validateToken';

export default class MfaModal extends LightningElement {
    @api isOpen = false;
    token = '';
    errorMessage = '';

    handleChange(event) {
        this.token = event.detail.value;
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('close'));
        this.reset();
    }

    async handleConfirm() {
        this.errorMessage = '';
        if (!this.token || this.token.length !== 6) {
            this.errorMessage = 'Código inválido. Verifique e tente novamente.';
            return;
        }

        try {
            const isValid = await validateToken({ token: this.token });
            if (isValid) {
                this.dispatchEvent(new CustomEvent('validated'));
                this.reset();
            } else {
                this.errorMessage = 'Token incorreto ou expirado.';
            }
        } catch (error) {
            console.error('Erro ao validar token:', error);
            this.errorMessage = 'Erro de sistema. Tente novamente.';
        }
    }

    reset() {
        this.token = '';
        this.errorMessage = '';
        this.isOpen = false;
    }
}