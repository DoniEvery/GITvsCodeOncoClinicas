import { LightningElement, wire, track } from 'lwc';
import getArtigoList from '@salesforce/apex/APP_CommunityManualController.getArtigoList';

export default class AppManualSidebar extends LightningElement {
    @track artigos = [];
    @track error;

    selectedId;
    rendered = false;

    @wire(getArtigoList)
    wiredArtigos({ error, data }) {
        if (data) {
            this.artigos = data;
            this.error = undefined;
            this.rendered = false; 
        } else if (error) {
            this.error = error;
            this.artigos = [];
        }
    }

    handleClick(event) {
        const artigoId = event.currentTarget.dataset.id;
        this.selectedId = artigoId;
        const selectEvent = new CustomEvent('artigochange', {
            detail: artigoId
        });
        this.dispatchEvent(selectEvent);
    }

    renderedCallback() {
        if (this.rendered || !this.artigos.length) return;

        this.artigos.forEach((artigo) => {
            const el = this.template.querySelector(`div[data-html-id="${artigo.Id}"]`);
            if (el) {
                el.innerHTML = artigo.Tema__c;
            }
        });

        this.rendered = true;
    }
}