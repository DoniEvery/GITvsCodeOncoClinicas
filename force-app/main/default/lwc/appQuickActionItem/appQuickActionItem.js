import { LightningElement, api, track, wire } from 'lwc';
import ICONS from '@salesforce/resourceUrl/CardIcons';
import DEFAULTICON from '@salesforce/resourceUrl/APP_Iconepadrao';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

const ALIAS_FIELD = 'User.Alias';

export default class AppQuickActionItem extends LightningElement {
    @api label;
    @api icon;
    @api type;
    @api content;

    @track resolvedIconUrl;
    isMedico = false;

    connectedCallback() {
        const tryIcon = `${ICONS}/CardIcons/${this.icon}.png`;
        fetch(tryIcon, { method: 'HEAD' })
            .then(response => {
                if (response.ok) {
                    this.resolvedIconUrl = tryIcon;
                } else {
                    this.resolvedIconUrl = DEFAULTICON;
                }
            })
            .catch(() => {
                this.resolvedIconUrl = DEFAULTICON;
            });
    }

    renderedCallback() {
        this.isMobile = window.innerWidth <= 767;
    }
    
    get cardClass() {
        return this.isMedico && !this.isMobile ? 'card card-full' : 'card';
    }

    get iconUrl() {
        return this.resolvedIconUrl || DEFAULTICON;
    }

    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD, ALIAS_FIELD] })
    userProfileHandler({ error, data }) {
        if (data) {
            const profileName = data.fields.Profile.displayValue || data.fields.Profile.value;
            const alias = data.fields.Alias.value;

            console.log('Perfil:', profileName);
            console.log('Alias:', alias);

            if (profileName === 'APP_Medico' || profileName === 'System Administrator' || alias === 'vito') {
                this.isMedico = true;
            } else {
                this.isMedico = false;
            }
        } else if (error) {
            console.error('Erro ao buscar perfil:', error);
        }
    }

    handleClick() {
        this.dispatchEvent(new CustomEvent('actionclick', {
            detail: { label: this.label },
            bubbles: true,
            composed: true
        }));
    }

    handleDragStart(event) {
        event.dataTransfer.setData('label', this.label);
        event.target.classList.add('dragging');
    }

    handleDragEnd(event) {
        event.target.classList.remove('dragging');
    }

    handleTouchStart(event) {
        // Pode ser usado para debug ou forçar estilo visual no touch
        event.currentTarget.classList.add('touching');
    }
}