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

export default class AppHeader extends NavigationMixin(LightningElement) {
    @api pageName;
    @api fromPage

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

    get isCommunityUser() {
        return window.location.pathname.startsWith('/apppaciente/s/');
    }

    get isAdminOrMedico() {
        const isAdmin = this.profileName === 'System Administrator' || this.profileName === 'Administrador do sistema';
        const isMedico = this.profileName === 'APP_Medico';
        return (isAdmin || isMedico) && !this.isCommunityUser;
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

    get isAdmin() {
        return this.profileName === 'System Administrator' || this.profileName === 'Administrador do sistema';
    }

    get isMedico() {
        return this.profileName === 'APP_Medico';
    }

    get headerClasses() {
        // Médico sempre tem margem
        if (this.isMedico) {
            return 'header header-with-margin';
        }

        // Admin no desktop (não comunidade) tem margem
        if (this.isAdmin && !this.isCommunityUser) {
            return 'header header-with-margin';
        }

        // Admin na comunidade só header normal
        if (this.isAdmin && this.isCommunityUser) {
            return 'header';
        }

        // Qualquer outro caso: header normal
        return 'header';
    }

    handleBack() {
        // console.log('ADONIKAN handleBack');

        if (!this.fromPage) {
            this.fromPage = 'Início';
        } else if (this.pageName === 'Meus pacientes') {
            this.fromPage = 'Início';
        } else if (this.pageName === 'Paciente') {
            this.fromPage = 'Meus pacientes';
        } else if (this.pageName === 'Prontuário' || this.pageName === 'Enviar arquivos' || this.pageName === 'Solicitar exames') {
            this.fromPage = 'Paciente';
        } else if (this.pageName === 'Tratamentos' || this.pageName === 'Diagnóstico e estadiamento' || this.pageName === 'Histórico de consultas' || this.pageName === 'Histórico de saúde') {
            this.fromPage = 'Prontuário';
        } else{
            this.fromPage = 'Início';
        }
        this.dispatchEvent(new CustomEvent('navigate', {
            detail: { pageName: this.fromPage },
            bubbles: true,
            composed: true
        }));
    }

    handleNavigateInicio() {
        window.location.href = '/lightning/n/APP_Inicio';
    }
}