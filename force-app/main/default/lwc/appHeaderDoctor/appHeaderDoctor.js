import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

// Ícones
import inicioIcon from '@salesforce/resourceUrl/APP_InicioIcon';
import saibamaisIcon from '@salesforce/resourceUrl/APP_SaibamaisIcon';
import agendaIcon from '@salesforce/resourceUrl/APP_AgendaIcon';
import servicosIcon from '@salesforce/resourceUrl/APP_ServicosIcon';
import prontuarioIcon from '@salesforce/resourceUrl/APP_ProntuarioIcon';
import conversasIcon from '@salesforce/resourceUrl/APP_ConversasIcon';
import faleconoscoIcon from '@salesforce/resourceUrl/APP_FaleconoscoIcon';
import suporteIcon from '@salesforce/resourceUrl/APP_SuporteIcon';
import politicaIcon from '@salesforce/resourceUrl/APP_PoliticaIcon';
import perguntasIcon from '@salesforce/resourceUrl/APP_PerguntasIcon';
import manualIcon from '@salesforce/resourceUrl/APP_ManualIcon';
import atendimentoIcon from '@salesforce/resourceUrl/APP_atendimentoIcon';
import laudoIcon from '@salesforce/resourceUrl/APP_LaudoIcon';

export default class AppHeaderDoctor extends NavigationMixin(LightningElement) {
    @api pageName;
    profileName;
    isMobile = false;

    // Ícones
    agenda = agendaIcon;
    conversas = conversasIcon;
    inicio = inicioIcon;
    prontuario = prontuarioIcon;
    saibamais = saibamaisIcon;
    servicos = servicosIcon;
    politica = politicaIcon;
    suporte = suporteIcon;
    faleconosco = faleconoscoIcon;
    perguntas = perguntasIcon;
    manual = manualIcon;
    atendimento = atendimentoIcon;
    laudo = laudoIcon;

    connectedCallback() {
        // Detecta se é mobile
        this.isMobile = window.innerWidth <= 768;
    }

    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD] })
    userRecord({ error, data }) {
        if (data) {
            this.profileName = data.fields.Profile.displayValue || data.fields.Profile.value;
            console.log('Perfil:', this.profileName);
        } else if (error) {
            console.error('Erro ao buscar perfil:', error);
        }
    }

    get iconName() {
        switch (this.pageName) {
            case 'Início': return this.inicio;
            case 'Minhas conversas': return this.conversas;
            case 'Política de privacidade': return this.politica;
            case 'Minha agenda': return this.agenda;
            case 'Suporte ao APP': return this.suporte;
            case 'Solicitar atendimento': return this.atendimento;
            case 'Perguntas frequentes': return this.perguntas;
            case 'Fale conosco': return this.faleconosco;
            case 'Meu prontuário': return this.prontuario;
            case 'Manual do paciente': return this.manual;
            case 'Laudos': return this.laudo;
            case 'Nossos serviços':
            case 'Meus pacientes': return this.saibamais;
            default: return this.saibamais; 
        }
    }

    get isAdminOrMedico() {
        return this.profileName === 'APP_Medico' || 
               this.profileName === 'System Administrator' || 
               this.profileName === 'Administrador do sistema';
    }

    get isMobileOnlyUser() {
        return this.isMobile && !this.isAdminOrMedico;
    }

    get isDesktopAdminUser() {
        return !this.isMobile && this.isAdminOrMedico;
    }

    get isMobileAdminUser() {
        return this.isMobile && this.isAdminOrMedico;
    }

    get headerClasses() {
        return `header ${this.isAdminOrMedico ? 'header-with-margin' : ''}`;
    }

    handleBack() {
        this.dispatchEvent(new CustomEvent('navigate', {
            detail: { pageName: 'Início' },
            bubbles: true,
            composed: true
        }));
    }

    handleNavigateInicio() {
        window.location.href = '/lightning/n/APP_Inicio';
    }
}