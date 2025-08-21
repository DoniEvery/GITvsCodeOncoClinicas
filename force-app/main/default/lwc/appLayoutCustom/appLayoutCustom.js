import { LightningElement, track } from 'lwc';
import HEADER_IMAGE from '@salesforce/resourceUrl/APP_FundoHeader'; 
import dateIcon from '@salesforce/resourceUrl/APP_DateIcon';
import dateIcon2 from '@salesforce/resourceUrl/APP_DateIcon2';
import detalhesConsultaIcon from '@salesforce/resourceUrl/APP_DetalhesConsultaIcon';
import identificarCliente from '@salesforce/apex/APP_ApiIdentificacaoClienteController.identificarCliente';

export default class AppLayoutCustom extends LightningElement {
    currentPage = 'Início';
    isMobile = false;
    sidebarVisible = false;
    headerImage = HEADER_IMAGE;
    dateIcon = dateIcon;
    dateIcon2 = dateIcon2;
    detalhesConsulta = detalhesConsultaIcon;
    @track showConfirmModal = false;
    @track showDetalhesModal = false;
    @track selectedConsulta;
    @track detalhesConsulta;
    @track showDateFilterModal = false;
    @track bloqueado = false;
    @track mostrarLoginContainer = false;
    @track tipoUsuarioSelecionado = '';

    connectedCallback() {
        this.updateIsMobile();
        this.checkCurrentUrl();
        this.buscaIdPlusoft();
        this.verificarTipoUsuario();
        window.addEventListener('resize', () => this.updateIsMobile());
        window.addEventListener('popstate', () => this.checkCurrentUrl());

        const storedPage = localStorage.getItem('currentPage');
        if (storedPage) {
            this.currentPage = storedPage;
            localStorage.removeItem('currentPage');
        }
     
    }


    updateIsMobile() {
        const width = window.innerWidth;
        const path = window.location.pathname;
    
        this.isMobile = width < 768 || (width <= 1180 && path.includes('/profile'));
    }
    

    handleMenuSelection(event) {
        this.currentPage = event.detail;
        this.checkCurrentUrl();
        this.sidebarVisible = false; // Fecha sidebar após seleção
        document.body.classList.remove('opensidebar'); //exibe o header padrão salesforce
    }

    handleNavigate(event) {
        this.currentPage = event.detail.pageName;
        this.checkCurrentUrl();
    }

    checkCurrentUrl() {
        const path = window.location.pathname;
    }

    handleTabChange(event) {
        this.currentPage = event.detail;
    }

    handleOpenSidebar() {
        this.sidebarVisible = true;
        document.body.classList.add('opensidebar'); //oculta o header padrão salesforce
    }
    
    handleCloseSidebar() {
        this.sidebarVisible = false;
        document.body.classList.remove('opensidebar'); //exibe o header padrão salesforce
    }    

    get sidebarMobileContainerClass() {
        return this.sidebarVisible ? 'sidebar-mobile-container open' : 'sidebar-mobile-container';
    }

    get isProfilePage() {
        const path = window.location.pathname;
        return path.includes('/profile');
    }

    get showHeader() {
        return this.currentPage !== 'Início' && !this.isProfilePage;
    }

    get mainContainerClass() {
        return this.isProfilePage ? 'main-container hidden-main' : 'main-container';
    }

    get overlayClass() {
        return this.isProfilePage ? 'layout-overlay disable-pointer' : 'layout-overlay';
    }
    
    
    get hostClass() {
        return this.isProfilePage ? 'host-wrapper normal-flow' : 'host-wrapper fixed-flow';
    }
        
    handleOpenChat() {
        if (window.embedded_svc && window.embedded_svc.liveAgentAPI) {
            window.embedded_svc.liveAgentAPI.startChat();
        } else {
            console.warn('Chat API não está carregada.');
        }
    }

    aplicarFiltroDatas(event) {
        const { dataInicial, dataFinal } = event.detail;
    
        const mainContent = this.template.querySelector('c-app-main-content');
        if (mainContent) {
            const sucesso = mainContent.aplicarFiltroCustomRange(dataInicial, dataFinal);
            if (sucesso) {
                this.showDateFilterModal = false;
            }
        }
    }
    

    abrirDateFilterModal() {
        this.showDateFilterModal = true;
    }

    abrirConfirmModal() {
        this.detalhesConsulta = null; 
        this.showConfirmModal = true;
        this.showDetalhesModal = false;
    }
    

    abrirDetalhesModal(event) {
        this.selectedConsulta = event.detail.consulta;
        this.showDetalhesModal = true;
    }    

    fecharTodosModais() {
        this.showConfirmModal = false;
        this.showDetalhesModal = false;
        this.showDateFilterModal = false;
        this.selectedConsulta = null;
        this.detalhesConsulta = null;
    }

    confirmarConsulta() {
        this.fecharTodosModais();
    }

    buscaIdPlusoft() {
       
        identificarCliente()
        .then(result => {          
        })
        .catch(error => {
            console.error('Erro ao identificar cliente:', error);           
        });
    }

    verificarTipoUsuario() {
        const tipoUsuario = localStorage.getItem('tipoUsuarioSelecionado');
        const pacienteId = localStorage.getItem('pacienteId');
    
        console.log("tipo Usuário >>> " + tipoUsuario);
        console.log("Paciente selecionado >>> " + pacienteId);
    
        if (tipoUsuario === 'Acompanhante' && !pacienteId) {
            // Só mostra login acompanhante se ainda não tiver paciente selecionado
            this.mostrarLoginContainer = true;
            this.tipoUsuarioSelecionado = tipoUsuario;
        } else {
            this.mostrarLoginContainer = false;
        }
    }    

    handleAcompanhante(event) {
        this.mostrarLoginContainer = false;
        console.log("caiu no handle >>> " + tipoUsuario);
        // Armazena o ID do paciente selecionado
        localStorage.setItem('pacienteSelecionadoId', event.detail.id);
        // Limpa o tipo de usuário do localStorage
        localStorage.removeItem('tipoUsuarioSelecionado');
        
        // Atualiza a interface para mostrar o layout principal
        this.currentPage = 'Início'; // Ou a página que deve ser mostrada após seleção
    }


    handleLoginConcluido(event) {
        const pacienteId = event.detail.pacienteId;
        console.log('Login concluído com pacienteId:', pacienteId);

        // Salva no localStorage
        localStorage.setItem('pacienteId', pacienteId);

        this.pacienteId = pacienteId;
        this.mostrarLoginContainer = false;
    }

    renderedCallback() {
        if(this.mostrarLoginContainer) {
            document.body.classList.add('ocultar-header');
        } else {
            document.body.classList.remove('ocultar-header');
        }
    }
}