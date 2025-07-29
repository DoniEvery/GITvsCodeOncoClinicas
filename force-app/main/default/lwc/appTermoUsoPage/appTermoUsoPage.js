import { LightningElement, api } from 'lwc';
import obterConteudoTermo from '@salesforce/apex/APP_TermoUsoPageController.obterConteudoTermo';
import registrarAceite from '@salesforce/apex/APP_TermoUsoPageController.registrarAceite';
import obterTermosPendentes from '@salesforce/apex/APP_TermoUsoPageController.obterTermosPendentes';
import obterConteudoPolitica from '@salesforce/apex/APP_TermoUsoPageController.obterConteudoPolitica';
import { NavigationMixin } from 'lightning/navigation';
import logoOnco from '@salesforce/resourceUrl/APP_LogoOncoclinicas';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class AppTermoUsoPage extends NavigationMixin(LightningElement) {
    @api origem;
    @api accepted = false;
    termo;
    desabilitarBotao = true;
    logoOnco = logoOnco;
    exibirTermoUso = false;
    mostrarTermoUso = false;
    mostrarPoliticaPrivacidade = false;
    mostrarConteudoFallback = false;
    politicaConteudo;

    get isFlow() {
        return this.origem === 'flow';
    }

    connectedCallback() {
        obterTermosPendentes()
            .then((resultado) => {
                const mostrarTermo = resultado['Termo e Condições de Uso'];
                const mostrarPolitica = resultado['Política de Privacidade'];
                // Redireciona se ambos já foram aceitos
                if (!mostrarTermo && !mostrarPolitica) {
                    if (this.isFlow) {
                        this.accepted = true;
                        this.dispatchEvent(new FlowNavigationNextEvent());
                    } else {
                        this.redirecionarParaHome();
                    }
                    return;
                }

                this.exibirTermoUso = true;
                // Ajusta exibição conforme pendências
                this.mostrarTermoUso = mostrarTermo;
                this.mostrarPoliticaPrivacidade = mostrarPolitica;

                if (this.mostrarTermoUso) {
                    this.carregarConteudoTermoUso();
                } else if (this.mostrarPoliticaPrivacidade) {
                    this.carregarPoliticaPrivacidade();
                }
            })
            .catch(error => {
                this.mostrarConteudoFallback = true;
            });
    }

    carregarConteudoTermoUso() {
        obterConteudoTermo()
            .then((conteudo) => {
                this.termo = conteudo;
                const termoEl = this.template.querySelector('.termo-uso');
                if (termoEl) {
                    termoEl.innerHTML = conteudo;
                }
            })
            .catch(() => {
                this.mostrarConteudoFallback = true;
            });
    }

    carregarPoliticaPrivacidade() {
        if (this.politicaConteudo) return;

        obterConteudoPolitica()
            .then((conteudo) => {
                this.politicaConteudo = conteudo;
                const politicaEl = this.template.querySelector('.politica-privacidade');
                if (politicaEl) {
                    politicaEl.innerHTML = conteudo;
                }
            })
            .catch(() => {
                this.mostrarConteudoFallback = true;
            });
    }

    handleCheckboxChange(event) {
        this.desabilitarBotao = !event.target.checked;
    }

    handleAceite() {
        const termosAceitos = [];
        if (this.mostrarTermoUso) termosAceitos.push('Termo e Condições de Uso');
        if (this.mostrarPoliticaPrivacidade) termosAceitos.push('Política de Privacidade');

        registrarAceite({ tiposTermos: termosAceitos })
            .then(() => {
                if (this.isFlow) {
                    this.accepted = true;
                    this.dispatchEvent(new FlowNavigationNextEvent());
                } else {
                    this.redirecionarParaHome();
                }
            })
            .catch(() => {
                this.mostrarConteudoFallback = true;
            });
    }

    handleTabActive(event) {
        const aba = event.target.value;
        if (aba === 'Política de Privacidade') {
            this.carregarPoliticaPrivacidade();
        } else if (aba === 'Termo e Condições de Uso') {
            this.carregarConteudoTermoUso();
        }
    }

    handleLogout() {
        if (this.isFlow) {
            this.accepted = false;
            this.dispatchEvent(new FlowNavigationNextEvent());
        } else {
            this[NavigationMixin.Navigate]({
                type: 'comm__loginPage',
                attributes: {
                    actionName: 'logout'
                }
            });
        }
    }

    redirecionarParaHome() {
        const basePath = window.location.origin + window.location.pathname.split('/s')[0] + '/s';
        window.location.href = basePath;
    }

    get acessarButtonClass() {
        return `custom-button ${this.desabilitarBotao ? 'disabled' : ''}`;
    }
    
    get checkboxLabel() {
        if (this.mostrarTermoUso && this.mostrarPoliticaPrivacidade) {
            return 'Estou de acordo com os Termos, condições de uso e Política de Privacidade.';
        }
        if (this.mostrarTermoUso) {
            return 'Estou de acordo com os Termos e condições de uso.';
        }
        if (this.mostrarPoliticaPrivacidade) {
            return 'Estou de acordo com a Política de Privacidade.';
        }
        return ''; // Caso nenhum termo esteja visível
    }

}