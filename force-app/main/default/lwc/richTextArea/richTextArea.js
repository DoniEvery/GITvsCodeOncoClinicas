import { LightningElement, api } from 'lwc';

export default class richTextArea extends LightningElement {
    @api fieldLabel = 'Digite aqui';
    @api fieldValue = '';
    @api fieldLenght;   
    @api required = false;
    @api visibleLines = 10;
    @api isReadOnly = false;

    allowedFormats = [
        'font', 'size', 'bold', 'italic', 'underline', 'strike', 'list',
        'indent', 'link', 'align', 'clean', 'table', 'header', 'color',
        'background', 'code', 'code-block', 'script', 'blockquote', 'direction',
    ];

    connectedCallback() {
        document.documentElement.style.setProperty('--rta-visiblelines', `${this.visibleLines * 2}em`);
    }
    
    renderedCallback() {
        if (this.isReadOnly) {
            const container = this.template.querySelector('.slds-rich-text-editor__output');
            if (container) {
                container.innerHTML = this.fieldValue || '';
            }
        }
    }

    handleChange(event) {
        this.fieldValue = event.target.value;
    }

    @api
    validate() {
        const value = this.fieldValue ? this.fieldValue.trim() : '';

        if (this.required && !value) {
            return {
                isValid: false,
                errorMessage: 'Este campo é obrigatório.'
            };
        }

        if (this.fieldLenght && value.length > this.fieldLenght) {
            return {
                isValid: false,
                errorMessage: `O campo deve ter menos de ${this.fieldLenght} caracteres`
            };
        }

        return { isValid: true };
    }
}