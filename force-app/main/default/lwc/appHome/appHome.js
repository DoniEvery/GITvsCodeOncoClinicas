import { LightningElement, wire, track } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import DOCTORS_IMAGE from '@salesforce/resourceUrl/APP_ImagemDoctors'; 
import agendaIcon from '@salesforce/resourceUrl/APP_AgendaIcon';

const FIELDS = ['User.Name'];

export default class AppHome extends LightningElement {
    userName;
    quickActions = [];
    doctorsImage = DOCTORS_IMAGE;
    agenda = agendaIcon;
    @track exibirTodas = false;
    currentPage = 'Minha agenda'
    @track mostrarBotaoAgendaCompleta = true;
    @track agendaCarregada = false;

    get agendaComponent() {
        return this.template.querySelector('c-app-my-schedule');
    }

    connectedCallback() {
        if (this.agendaComponent) {
            this.agendaComponent.carregarAgendaReal();
        }
    }

    atualizarBotaoAgendaCompleta(event) {
        this.mostrarBotaoAgendaCompleta = event.detail.exibirBotao;
    };

    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    wiredUser(result) {
        if (result.data) {
            this.userName = result.data.fields.Name.value;
        } else if (result.error) {
            this.userName = 'Usuário';
        }
    }

    handleActionSelected(event) {
        const { label, type, content } = event.detail;

        if (type === 'Link') {
            window.open(content, '_blank');
        } else {
            this.dispatchEvent(new CustomEvent('navigate', {
                detail: {
                    pageName: label,
                },
                bubbles: true,
                composed: true
            }));
        }
    }

    refreshGrid() {
        const grid = this.template.querySelector('c-app-quick-actions-grid');
        if (grid) {
            grid.refreshCards();
        }
    }

    toggleExpandAgenda() {
        this.irParaAgendaCompleta();
    }
    

    irParaAgendaCompleta() {
        this.dispatchEvent(new CustomEvent('navigate', {
            detail: {
                pageName: 'Minha agenda'
            },
            bubbles: true,
            composed: true
        }));
    }
}