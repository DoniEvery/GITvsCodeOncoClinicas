import { LightningElement, track, api } from 'lwc';
import existAccount from '@salesforce/apex/APP_LoginController.existAccount';
import getUserData from '@salesforce/apex/APP_LoginController.getUserData';
import trocarSenha from '@salesforce/apex/APP_LoginController.trocarSenha';
import login from '@salesforce/apex/APP_LoginController.login';
import { CurrentPageReference } from 'lightning/navigation';
import { wire } from 'lwc';

export default class AppLoginEsqueciSenha extends LightningElement {
    @api tipoDocumento = '';
    @api numeroDocumento = '';
    @track novaSenha = '';
    @track confirmaSenha = '';
    @track mostrarCamposDocumento = true;
    @track mostrarNovaSenha = false;
    @track errorMessage = '';
    @track successMessage = '';
    @track accountId = '';
    @track userId = '';
    @track username = '';
renderedCallback() {
    if (this.tipoDocumento) {
        const select = this.template.querySelector('select[name="tipoDocumento"]');
        if (select && select.value !== this.tipoDocumento) {
            select.value = this.tipoDocumento;
        }
    }
}

    get tiposDocumento() {
        return [
            { label: 'CPF', value: 'CPF' },
            { label: 'Passaporte', value: 'Passaporte' },
            { label: 'RNE', value: 'RNE' }
        ];
    }

    handleTipoDocumentoChange(event) {
        this.tipoDocumento = event.target.value;
        this.errorMessage = '';
    }

    handleNumeroDocumentoChange(event) {
        this.numeroDocumento = event.target.value;
        this.errorMessage = '';
    }

    handleSeguir() {
        if (!this.tipoDocumento || !this.numeroDocumento) {
            this.errorMessage = 'Todos os campos são obrigatórios.';
            return;
        }

        this.errorMessage = '';

        existAccount({
            tipoDocumento: this.tipoDocumento,
            numeroDocumento: this.numeroDocumento,
            tipoUsuario: 'PersonAccount'
        })
        .then(account => {
            this.accountId = account.Id;
            return getUserData({ accountId: this.accountId });
        })
        .then(user => {
            this.userId = user.Id;
            this.username = user.Username; 
            this.mostrarCamposDocumento = false;
            this.mostrarNovaSenha = true;
        })
        .catch(error => {
            this.errorMessage = this.extractErrorMessage(error);
        });
    }


    handleNovaSenhaChange(event) {
        this.novaSenha = event.target.value;
        this.errorMessage = '';
        this.successMessage = '';
    }

    handleConfirmaSenhaChange(event) {
        this.confirmaSenha = event.target.value;
        this.errorMessage = '';
        this.successMessage = '';
    }

    get regrasSenha() {
        const senha = this.novaSenha || '';
        const temMaiuscula = /[A-Z]/.test(senha);
        const temMinuscula = /[a-z]/.test(senha);
        const temNumero = /[0-9]/.test(senha);
        const tamanhoMinimo = senha.length >= 8;

        return [
            {
                id: 'maiuscula',
                label: 'Ao menos 1 letra maiúscula',
                iconChar: temMaiuscula ? '✔' : '✖',
                itemClass: temMaiuscula ? 'regra-item slds-text-color_success' : 'regra-item slds-text-color_error'
            },
            {
                id: 'minuscula',
                label: 'Ao menos 1 letra minúscula',
                iconChar: temMinuscula ? '✔' : '✖',
                itemClass: temMinuscula ? 'regra-item slds-text-color_success' : 'regra-item slds-text-color_error'
            },
            {
                id: 'numero',
                label: 'Ao menos 1 número',
                iconChar: temNumero ? '✔' : '✖',
                itemClass: temNumero ? 'regra-item slds-text-color_success' : 'regra-item slds-text-color_error'
            },
            {
                id: 'tamanho',
                label: 'Ao menos 8 caracteres',
                iconChar: tamanhoMinimo ? '✔' : '✖',
                itemClass: tamanhoMinimo ? 'regra-item slds-text-color_success' : 'regra-item slds-text-color_error'
            }
        ];
    }

    handleSalvar() {
        this.errorMessage = '';
        this.successMessage = '';

        if (this.novaSenha !== this.confirmaSenha) {
            this.errorMessage = 'As senhas não coincidem.';
            return;
        }

        const regras = this.regrasSenha;
        const regrasInvalidas = regras.filter(r => r.iconChar === '✖');
        if (regrasInvalidas.length > 0) {
            this.errorMessage = 'A senha não atende a todos os critérios.';
            return;
        }

        if (!this.userId) {
            this.errorMessage = 'Usuário não encontrado para alterar a senha.';
            return;
        }

        trocarSenha({ userId: this.userId, novaSenha: this.novaSenha })
            .then(() => {
                this.successMessage = 'Senha alterada com sucesso! Aguarde enquanto redirecionamos para o sistema';
                setTimeout(() => {
                    login({ username: this.username, password: this.novaSenha })
                        .then(result => {
                            if (result && (result.includes('frontdoor.jsp') || result.includes('/s/'))) {
                                window.location.href = result;
                            } else {
                                this.errorMessage = 'Erro ao redirecionar para o sistema.';
                                this.successMessage = '';
                            }
                        })
                        .catch(error => {
                            const msg = this.extractErrorMessage(error);
                            if (msg.includes('invalid repeated password')) {
                                this.errorMessage = 'Essa senha já foi utilizada, digite uma nova senha.';
                            } else {
                                this.errorMessage = msg;
                            }
                        });
                }, 2000);
            })
            .catch(error => {
                this.errorMessage = this.extractErrorMessage(error);
            });
    }

    handleVoltar() {
        this.dispatchEvent(new CustomEvent('voltar'));
    }
    
    extractErrorMessage(error) {
        if (error && error.body && error.body.message) {
            return error.body.message;
        } else if (error && error.message) {
            return error.message;
        } else {
            return 'Erro inesperado ao processar a requisição.';
        }
    }
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference && currentPageReference.state) {
            this.userId = currentPageReference.state.userId || '';
            this.accountId = currentPageReference.state.accountId || '';

            if (this.userId && this.accountId) {
                this.mostrarCamposDocumento = false;
                this.mostrarNovaSenha = true;
            }
        }
    }

    get botaoDesabilitado() {
        return !this.tipoDocumento || !this.numeroDocumento;
    }
    
    get botaoSeguirClass() {
        return this.botaoDesabilitado ? 'custom-button disabled' : 'custom-button';
    }
}