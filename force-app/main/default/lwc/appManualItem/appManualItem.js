import { LightningElement, api } from 'lwc';

export default class AppManualItem extends LightningElement {
    @api pergunta;
    @api resposta;
    expanded = false;

    perguntaRenderizada = false;
    respostaRenderizada = false;

    toggle() {
        this.expanded = !this.expanded;

        if (this.expanded) {
            this.respostaRenderizada = false;
        }
    }

    renderedCallback() {
        if (!this.perguntaRenderizada) {
            const perguntaContainer = this.template.querySelector('.pergunta-richtext');
            if (perguntaContainer) {
                perguntaContainer.innerHTML = this.pergunta;
                this.perguntaRenderizada = true;
            }
        }

        if (this.expanded && !this.respostaRenderizada) {
            const respostaContainer = this.template.querySelector('.resposta-richtext');
            if (respostaContainer) {
                respostaContainer.innerHTML = this.resposta;
                this.respostaRenderizada = true;
            }
        }
    }
}