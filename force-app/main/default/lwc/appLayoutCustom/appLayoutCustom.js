import { LightningElement, track } from 'lwc';
import HEADER_IMAGE from '@salesforce/resourceUrl/APP_FundoHeader'; 
import dateIcon from '@salesforce/resourceUrl/APP_DateIcon';
import dateIcon2 from '@salesforce/resourceUrl/APP_DateIcon2';
import detalhesConsultaIcon from '@salesforce/resourceUrl/APP_DetalhesConsultaIcon';
import precisaAceitarTermo from '@salesforce/apex/APP_TermoUsoPageController.precisaAceitarTermo';
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
    @track mostrarTermo = false;

    connectedCallback() {
        this.updateIsMobile();
        this.checkCurrentUrl();
        window.addEventListener('resize', () => this.updateIsMobile());
        window.addEventListener('popstate', () => this.checkCurrentUrl());

        const storedPage = localStorage.getItem('currentPage');
        if (storedPage) {
            this.currentPage = storedPage;
            localStorage.removeItem('currentPage');
        }

        precisaAceitarTermo()
            .then((precisa) => {
                console.log('Valor de precisaAceitarTermo:', precisa);
                console.log('URL atual:', window.location.pathname);
                if (precisa) {
                    this.mostrarTermo = true;
                }
            })
            .catch(error => {
                console.error('Erro ao verificar aceite do termo:', error);
            });

        this.buscaIdPlusoft();
            
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
            
            console.log('sucesso? >>', sucesso);
            if (sucesso) {
                this.showDateFilterModal = false;
            }
        }
    }
    

    abrirDateFilterModal() {
        this.showDateFilterModal = true;
    }

    abrirConfirmModal() {
        console.log('Abrindo modal de confirmação');
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
        // Sua lógica de confirmação
        this.fecharTodosModais();
    }

    handleTermoAceito() {
        this.mostrarTermo = false;
    }

    renderedCallback() {
        if(this.mostrarTermo) {
            document.body.classList.add('ocultar-header');
        } else {
            document.body.classList.remove('ocultar-header');
        }
    }

    buscaIdPlusoft() {
       
        identificarCliente()
        .then(result => {          
        })
        .catch(error => {
            console.error('Erro ao identificar cliente:', error);           
        });
    }
    
}