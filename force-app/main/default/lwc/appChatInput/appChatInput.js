import { LightningElement, api } from 'lwc';

export default class AppChatInput extends LightningElement {
    newMessage = '';
    type = 'text'; // padrão
    metadata = null;
    replyTo = null;

    disabled = false;
    @api disableSend() {
        this.disabled = true;
    }

    @api enableSend() {
        this.disabled = false;
    }

    sending = false;
    @api sendingMsg() {
        this.sending = true;
    }

    @api sentMsg() {
        this.sending = false;
    }

    connectedCallback() {
        // this.disableSend();
        this.sentMsg();
    }

    handleInputChange(event) {
        this.newMessage = event.target.value;
    }

    handleSend() {
        if (!this.newMessage?.trim() || this.sending) return;
        console.log('Sending message:', this.newMessage.trim());

        this.disableSend();
        this.sendingMsg();

        const detail = {
            content: this.newMessage.trim(),
            type: this.type,
            replyTo: this.replyTo,
            metadata: this.metadata
        };

        this.dispatchEvent(new CustomEvent('sendmessage', { detail }));

        this.newMessage = '';
        this.replyTo = null;
        this.metadata = null;
    }

    handleKeydown(event) {
        if (event.key === 'Enter') {
            this.handleSend();
        }
    }
    // newMessage = '';

    // handleChange(event) {
    //     this.newMessage = event.target.value;
    // }

    // handleKeydown(event) {
    //     if (event.key === 'Enter') {
    //         this.send();
    //     }
    // }

    // send() {
    //     const content = this.newMessage.trim();
    //     if (!content) return;

    //     this.dispatchEvent(new CustomEvent('sendmessage', {
    //         detail: { content }
    //     }));

    //     this.newMessage = '';
    // }
}