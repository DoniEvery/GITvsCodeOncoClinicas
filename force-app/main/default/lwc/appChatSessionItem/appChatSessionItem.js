import { LightningElement, api } from 'lwc';

export default class AppChatSessionItem extends LightningElement {
    @api session;

    handleClick() {
        this.dispatchEvent(new CustomEvent('sessionselected', {
            detail: { sessionId: this.session.id }
        }));
    }
}