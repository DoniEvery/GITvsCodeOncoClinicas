import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import login from '@salesforce/apex/APP_LoginController.login';
import existAccount from '@salesforce/apex/APP_LoginController.existAccount';
import getUserData from '@salesforce/apex/APP_LoginController.getUserData';
import precisaAceitarTermo from '@salesforce/apex/APP_TermoUsoPageController.precisaAceitarTermo';

export default class AppLoginForm extends LightningElement {
    @api tipoUsuario;
    @track acompanhanteId;
    @track termoNaoAceito = false;
    @track loginUrl = '';
    tipoDocumento = '';
    numeroDocumento = '';
    senha = '';

    @track errorMessage = '';
    @track successMessage = '';

    @track showLogin = true;
    @track showRecuperarSenha = false;
    @track showPrimeiroAcesso = false;
    @track mostrarAcompanhante = false;

    connectedCallback() {
        precisaAceitarTermo()
            .then((precisa) => {
                if (precisa) {
                    this.termoNaoAceito = true;
                }
            })
            .catch(error => {
                console.error('Erro ao verificar aceite do termo:', error);
            });
    }    

    get documentoOptions() {
        return [
            { label: 'CPF', value: 'CPF' },
            { label: 'Passaporte', value: 'Passaporte' },
            { label: 'RNE', value: 'RNE' }
        ];
    }

    handleTipoDocumentoChange(event) {
        this.tipoDocumento = event.target.value;
    }

    handleNumeroDocumentoChange(event) {
        this.numeroDocumento = event.target.value;
    }

    handleSenhaChange(event) {
        this.senha = event.target.value;
    }

    handleLogin() {
        this.errorMessage = '';
    
        if (!this.tipoDocumento || !this.numeroDocumento || !this.senha) {
            this.errorMessage = 'Todos os campos são obrigatórios.';
            return;
        }
    
        let accountId = '';
    
        existAccount({ 
            tipoDocumento: this.tipoDocumento, 
            numeroDocumento: this.numeroDocumento, 
            tipoUsuario: this.tipoUsuario 
        })
        .then(account => {
            accountId = account.Id;
            return getUserData({ accountId: account.Id });
        })
        .then(user => login({ username: user.Username, password: this.senha }))
        .then(result => {
            if (this.tipoUsuario === 'Acompanhante') {
                this.loginUrl = result;
                this.acompanhanteId = accountId; 
                this.mostrarAcompanhante = true;
                this.showLogin = false;
            } else if (result && (result.includes('frontdoor.jsp') || result.includes('/s/'))) {
                window.location.href = result;
            }
        })
        .catch(error => {
            this.errorMessage = error?.body?.message || error?.message || 'Erro desconhecido durante o login.';
        });
    }
    

    handleVoltar() {
        this.dispatchEvent(new CustomEvent('voltar'));
    }

    exibirRecuperarSenha() {
        this.showLogin = false;
        this.showRecuperarSenha = true;
        this.showPrimeiroAcesso = false;
    }

    exibirPrimeiroAcesso() {
        this.showLogin = false;
        this.showRecuperarSenha = false;
        this.showPrimeiroAcesso = true;
    }

    voltarParaLogin() {
        this.showLogin = true;
        this.showRecuperarSenha = false;
        this.showPrimeiroAcesso = false;
    }

    get botaoDesabilitado() {
        return !this.tipoDocumento || !this.numeroDocumento || !this.senha;
    }
    
    get botaoSeguirClass() {
        return this.botaoDesabilitado ? 'custom-button disabled' : 'custom-button';
    }

    handleRedirect() {
        window.location.href = '/portalpaciente/s/';
    }
    
    
}