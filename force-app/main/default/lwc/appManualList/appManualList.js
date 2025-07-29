import { LightningElement, api, wire } from 'lwc';
import getQuestoesByArtigo from '@salesforce/apex/APP_CommunityManualController.getQuestoesByArtigo';

export default class AppManualList extends LightningElement {
    @api artigoId;
    questions = [];
    error;

    @wire(getQuestoesByArtigo, { artigoId: '$artigoId' })
    wiredQuestoes({ error, data }) {
        if (data) {
            this.questions = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.questions = [];
        }
    }
}