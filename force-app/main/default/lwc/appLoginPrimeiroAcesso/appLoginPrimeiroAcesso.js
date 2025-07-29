import { LightningElement, track, api, wire } from 'lwc';
import existAccount from '@salesforce/apex/APP_LoginController.existAccount';
import getUserData from '@salesforce/apex/APP_LoginController.getUserData';
import trocarSenha from '@salesforce/apex/APP_LoginController.trocarSenha';
import newUser from '@salesforce/apex/APP_LoginController.newUser';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import login from '@salesforce/apex/APP_LoginController.login';

export default class AppLoginPrimeiroAcesso extends NavigationMixin(LightningElement) {
    @track tipoDocumento;
    @track numeroDocumento = '';
    @track novaSenha = '';
    @track confirmaSenha = '';
    @track mostrarCamposDocumento = true;
    @track mostrarNovaSenha = false;
    @track errorMessage = '';
    @track successMessage = '';
    @track accountId = '';
    @track userId = '';
    @track username = '';
    @track showRecuperarSenha = false;
    @track showPrimeiroAcesso = true;
    @track userData = {};

    @api tipoPerfil;

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
        this.successMessage = '';

        existAccount({
            tipoDocumento: this.tipoDocumento,
            numeroDocumento: this.numeroDocumento,
            tipoUsuario: this.tipoPerfil
        })
        .then(account => {
            this.accountId = account.Id;
            return getUserData({ accountId: this.accountId });
        })
        .then(user => {
            // Usuário já existe → Abre o componente Esqueci Senha
            this.userData = {
                userId: user.Id,
                accountId: this.accountId,
                contactId: user.ContactId
            };
            this.exibirRecuperarSenha();
        })
        .catch(error => {
            const msg = this.extractErrorMessage(error);
            if (msg.includes('Usuário não encontrado')) {
                // Usuário ainda não existe → Cria novo
                newUser({ accountId: this.accountId, tipoPerfil: this.tipoPerfil })
                    .then(newUserResult => {
                        this.userId = newUserResult.Id;
                        this.username = newUserResult.Username;
                        this.mostrarCamposDocumento = false;
                        this.mostrarNovaSenha = true;
                    })
                    .catch(newUserError => {
                        this.errorMessage = this.extractErrorMessage(newUserError);
                    });
            } else {
                this.errorMessage = `${msg}`;
            }
        });
    }

    handleVoltar() {
        this.dispatchEvent(new CustomEvent('voltar'));
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

        if (!this.userId || !this.username) {
            this.errorMessage = 'Usuário não encontrado para alterar a senha.';
            return;
        }

        trocarSenha({ userId: this.userId, novaSenha: this.novaSenha })
            .then(() => {
                this.successMessage = 'Senha definida com sucesso! Aguarde enquanto redirecionamos para o sistema';

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
                            this.successMessage = '';
                        });
                }, 2000);
            })
            .catch(error => {
                this.errorMessage = this.extractErrorMessage(error);
            });
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

    exibirRecuperarSenha() {
        this.showPrimeiroAcesso = false;
        this.showRecuperarSenha = true;
    }

    exibirPrimeiroAcesso() {
        this.showRecuperarSenha = false;
        this.showPrimeiroAcesso = true;
    }

    voltarParaLogin() {
        this.showRecuperarSenha = false;
        this.showPrimeiroAcesso = false;
    }

    get botaoDesabilitado() {
        return !this.tipoDocumento || !this.numeroDocumento;
    }
    
    get botaoSeguirClass() {
        return this.botaoDesabilitado ? 'custom-button disabled' : 'custom-button';
    }
    
}