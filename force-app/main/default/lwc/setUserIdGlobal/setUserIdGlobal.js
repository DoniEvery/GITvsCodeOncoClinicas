import BasePrechat from 'lightningsnapin/basePrechat';
import { LightningElement, api, track } from 'lwc';

export default class SetUserIdGlobal extends LightningElement {
    @api prechatFields;
    @api backgroundImgURL;
    @track fields;
    @track namelist;
    startChatLabel;

    /**
     * Set the button label and prepare the prechat fields to be shown in the form.
     */
    connectedCallback() {
        try {
            this.startChatLabel = 'Start Chat';
            this.fields = this.prechatFields.map(field => {
                const { label, name, value, required, maxLength } = field;
                return { label, value, name, required, maxLength };
            });
            
            this.namelist = this.fields.map(field => field.name);
        } catch (error) {
            console.log('ERRO: ', error.message);
        }
    }

    /**
     * Focus on the first input after this component renders.
     */
    renderedCallback() {
        this.template.querySelector("lightning-input").focus();
    }

    /**
     * On clicking the 'Start Chatting' button, send a chat request.
     */
    handleStartChat() {
        this.template.querySelectorAll("lightning-input").forEach(input => {
            this.fields[this.namelist.indexOf(input.name)].value = input.value;
        });

        if (this.validateFields(this.fields).valid) {
            this.startChat(this.fields);
        } else {
            // Error handling if fields do not pass validation.
        }
    }
}