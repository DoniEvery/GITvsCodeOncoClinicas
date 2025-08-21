import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

const ALIAS_FIELD = 'User.Alias';

export default class AppMainContent extends LightningElement {
    @api currentPage;
    @api altura;
    isLoading = false;
    isMedico = false;
    agenda = [];
    selectedPatient;
    // ADONIKAN
    fromPage = 'Início';

    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD, ALIAS_FIELD] })
    userProfileHandler({ error, data }) {
        if (data) {
            const profileName = data.fields.Profile.displayValue || data.fields.Profile.value;
            const alias = data.fields.Alias.value;

            if (profileName === 'APP_Medico' || profileName === 'System Administrator' || alias === 'vito') {
                this.isMedico = true;
            } else {
                this.isMedico = false;
            }
        } else if (error) {
            console.error('Erro ao buscar perfil:', error);
        }
    }


    // Adonikan >>> handlePatientSelected
    handlePatientSelected(event) {

        const { patient, pageName, fromPage } = event.detail;

        this.selectedPatient = patient;
        this.currentPage = pageName;
        this.fromPage = fromPage;


        this.dispatchEvent(new CustomEvent('navigate', {
            detail: {
                pageName: pageName,
                fromPage: fromPage
            },
            bubbles: true,
            composed: true
        }));
    }

    get isPageNotFound() {
        const validPages = [
            'Início',
            'Minhas conversas',
            'Política de privacidade',
            'Minha agenda',
            'Perguntas frequentes',
            'Suporte ao APP',
            'Solicitar atendimento',
            'Fale conosco',
            'Laudos',
            'Manual do paciente',
            'Meu prontuário',
            'Acompanhantes',
            'Gerenciar notificações',
            'Nossos serviços',
            'Saiba mais sobre o APP',
            'Meus pacientes',
            'Paciente',
            'Prontuário',
            'Enviar arquivos',
            'Solicitar exames',
            'Tratamentos',
            'Diagnóstico e estadiamento',
            'Histórico de consultas',
            'Histórico de saúde',
            'Pré checkin'
        ];

        return this.currentPage && !validPages.includes(this.currentPage);
    }

    get isHome() {
        return this.currentPage === 'Início';
    }

    get isConversas() {
        if (this.currentPage === 'Minhas conversas') {
            window.location.href = '/apppaciente/s/chat';
        }
    }

    get isPrivacidade() {
        return this.currentPage === 'Política de privacidade';
    }

    get isPerfil() {
        return this.currentPage === 'Perfil';
    }

    get showAgenda() {
        return this.currentPage === 'Minha agenda';
    }

    get showPerguntasFrequentes() {
        return this.currentPage === 'Perguntas frequentes';
    }

    get showSuporte() {
        return this.currentPage === 'Suporte ao APP';
    }

    get showAtendimento() {
        return this.currentPage === 'Solicitar atendimento';
    }

    get showFaleConosco() {
        return this.currentPage === 'Fale conosco';
    }

    get showLaudos() {
        return this.currentPage === 'Laudos';
    }

    get showMeuProntuario() {
        return this.currentPage === 'Meu prontuário';
    }

    get showAcompanhantes() {
        return this.currentPage === 'Acompanhantes';
    }

    get showGerenciarNotificacoes() {
        return this.currentPage === 'Gerenciar notificações';
    }



    get showManual() {
        return this.currentPage === 'Manual do paciente';
    }

    get showNossosServicos() {
        return this.currentPage === 'Nossos serviços';
    }

    get showSaibaMais() {
        return this.currentPage === 'Saiba mais sobre o APP';
    }

    get showPacientes() {
        return this.currentPage === 'Meus pacientes';
    }

    // ADONIKAN
    get showPaciente() {
        return this.currentPage === 'Paciente';
    }
    // ADONIKAN
    get showProntuario() {
        return this.currentPage === 'Prontuário';
    }
    // ADONIKAN
    get showEnviarArquivos() {
        return this.currentPage === 'Enviar arquivos';
    }
    // ADONIKAN
    get showSolicitarExames() {
        return this.currentPage === 'Solicitar exames';
    }
    get showTratamentos() {
        return this.currentPage === 'Tratamentos';
    }
    get showDiagnostico() {
        return this.currentPage === 'Diagnóstico e estadiamento';
    }
    get showHistoricoCconsultas() {
        return this.currentPage === 'Histórico de consultas';
    }
    get showHistoricoSaude() {
        return this.currentPage === 'Histórico de saúde';
    }
    get showCheckin() {
        return this.currentPage === 'Pré checkin';
    }

    handleNavigate(event) {
        this.dispatchEvent(new CustomEvent('navigate', {
            detail: event.detail,
            bubbles: true,
            composed: true
        }));
    }

    handleBack() {
        this.dispatchEvent(new CustomEvent('navigate', {
            detail: {
                pageName: this.fromPage
            },
            bubbles: true,
            composed: true
        }));
    }

    renderedCallback() {
        if (this.currentPage === 'Início') {
            const homeComponent = this.template.querySelector('c-app-home');
            if (homeComponent && typeof homeComponent.refreshGrid === 'function') {
                homeComponent.refreshGrid();
            }
        }
    }

    @api aplicarFiltroCustomRange(dataInicial, dataFinal) {
        const agendaPaciente = this.template.querySelector('c-app-my-schedule');
        
        if (agendaPaciente) {
            return agendaPaciente.aplicarFiltroCustomRange(dataInicial, dataFinal);
        }
        const agendaMedico = this.template.querySelector('c-app-my-schedule-doctor');
    
        if (agendaMedico) {
            return agendaMedico.aplicarFiltroCustomRange(dataInicial, dataFinal);
        }
    
        return false;
    }


    // Adonikan >>> handleScrollTop
    handleScrollTop() {

        const container = this.template.querySelector('.main-container');
        if (container) {
            container.scrollTop = 0;
        } else {
            window.scrollTo({ top: 0, behavior: 'auto' });
        }
        const scrollEvent = new CustomEvent('scrolltoprequest', {
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(scrollEvent);
    }
}