import { LightningElement, api } from 'lwc';

export default class AppFaqItem extends LightningElement {
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
        // Renderiza a pergunta como rich text uma única vez
        if (!this.perguntaRenderizada) {
            const perguntaContainer = this.template.querySelector('.pergunta-richtext');
            if (perguntaContainer) {
                perguntaContainer.innerHTML = this.pergunta;
                this.perguntaRenderizada = true;
            }
        }

        // Renderiza a resposta como rich text quando expandido
        if (this.expanded && !this.respostaRenderizada) {
            const respostaContainer = this.template.querySelector('.resposta-richtext');
            if (respostaContainer) {
                respostaContainer.innerHTML = this.resposta;
                this.respostaRenderizada = true;
            }
        }
    }
}