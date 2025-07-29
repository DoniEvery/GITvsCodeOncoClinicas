import { LightningElement, track } from 'lwc';
import telaLogin from '@salesforce/resourceUrl/APP_TelaLogin';
import logoOnco from '@salesforce/resourceUrl/APP_LogoOncoclinicas';

export default class AppLoginContainer extends LightningElement {
    @track mostrarPreLogin = true;
    @track mostrarLoginForm = false;
    @track mostrarEsqueciSenha = false;
    @track tipoUsuarioSelecionado = '';
    telaLogin = telaLogin;
    logoOnco = logoOnco ;
    @track mostrarConteudoMobile = false;

    isMobile() {
        return window.innerWidth <= 768;
    }

    handleIniciar() {
        this.mostrarConteudoMobile = true;
    }

    handleNext(event) {
        this.tipoUsuarioSelecionado = event.detail;
        this.mostrarPreLogin = false;
        this.mostrarLoginForm = true;
        console.log("Usuario Selecionado >>> " + this.tipoUsuarioSelecionado);
    }

    handleVoltarParaPreLogin() {
        this.mostrarPreLogin = true;
        this.mostrarLoginForm = false;
        this.mostrarEsqueciSenha = false;

        // Detecta se é mobile (por largura de tela)
        this.mostrarConteudoMobile = this.isMobile();
    }

    handleVoltarParaLogin() {
        this.mostrarEsqueciSenha = false;
        this.mostrarLoginForm = true;
    }
}