import { LightningElement, track, wire } from 'lwc';
import HEADER_IMAGE from '@salesforce/resourceUrl/APP_FundoHeader';
import dateIcon from '@salesforce/resourceUrl/APP_DateIcon';
import dateIcon2 from '@salesforce/resourceUrl/APP_DateIcon2';
import detalhesConsultaIcon from '@salesforce/resourceUrl/APP_DetalhesConsultaIcon';
import { CurrentPageReference } from 'lightning/navigation';

export default class AppLayoutDoctor extends LightningElement {
    currentPage = 'Início';
    fromPage;
    
    headerImage = HEADER_IMAGE;
    dateIcon = dateIcon;
    dateIcon2 = dateIcon2;
    detalhesConsulta = detalhesConsultaIcon;

    @track showConfirmModal = false;
    @track showDetalhesModal = false;
    @track showDateFilterModal = false;
    @track selectedConsulta;
    isMobile = false;
    alturaCalculada;
    connectedCallback() {
        this.detectarAmbiente();

        const storedPage = localStorage.getItem('currentPage');
        if (storedPage) {
            console.log(
                'Valor de storedPage:',
                storedPage);
            
            this.currentPage = storedPage;
            localStorage.removeItem('currentPage');
        }

        // Desktop: usa URL diretamente
        if (!this.isMobile) {
            setTimeout(() => {
                this.definirPaginaPorUrl();
            }, 100);
        }
        setTimeout(() => {
            const container = this.template.querySelector('.main-container');
            if (container) {
                const rect = container.getBoundingClientRect();
                this.alturaCalculada = rect.height - rect.top;
                console.log('Altura enviada para o neto:', this.alturaCalculada);
            }
        }, 0);
    }

    detectarAmbiente() {
        const ua = navigator.userAgent || '';
        // Detecta Salesforce Mobile App ou dispositivo móvel
        this.isMobile = /SalesforceMobileApp|SalesforceMobile|iOS|Android/i.test(ua) || window.innerWidth < 768;
        console.log('🧭 Ambiente: ', this.isMobile ? 'Mobile' : 'Desktop');
    }

    definirPaginaPorUrl() {
        const urlPath = window.location.pathname;
        console.log('🌐 URL Desktop >>', urlPath);

        switch (true) {
            case urlPath.includes('/n/APP_Inicio'):
                this.currentPage = 'Início';
                break;
            case urlPath.includes('/n/APP_MinhaAgenda'):
                this.currentPage = 'Minha agenda';
                break;
            case urlPath.includes('/n/APP_Pacientes'):
                this.currentPage = 'Meus pacientes';
                break;
            default:
                this.currentPage = 'Início';
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        if (!this.isMobile) return;

        requestAnimationFrame(() => {
            setTimeout(() => {
                if (currentPageReference && currentPageReference.attributes) {
                    const pageRef = currentPageReference.attributes;
                    const pagePath = pageRef.apiName || pageRef.pageName || '';
                    console.log('📱 Page Reference Mobile:', pagePath);

                    switch (true) {
                        case pagePath.includes('APP_Inicio'):
                            this.currentPage = 'Início';
                            break;
                        case pagePath.includes('APP_MinhaAgenda'):
                            this.currentPage = 'Minha agenda';
                            break;
                        case pagePath.includes('APP_Pacientes'):
                            this.currentPage = 'Meus pacientes';
                            break;
                        default:
                            this.currentPage = 'Início';
                    }
                } else {
                    // Fallback se @wire falhar ou atrasar
                    console.warn('⚠️ PageReference não carregou, aplicando fallback...');
                    this.definirPaginaPorUrl();
                }
            }, 200); // tempo ajustado para mobile
        });
    }

    
    handleNavigate(event) {
        // Adonikan >>> fromPage
        const { fromPage, pageName } = event.detail;
        this.currentPage = pageName;
        if (fromPage) {        
            this.fromPage = fromPage;
        }

        localStorage.setItem('currentPage', this.currentPage);
    }

    get showHeader() {
        return this.currentPage !== 'Início';
    }

    get mainContainerClass() {
        return 'main-container';
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

    handleScrollTop() {

        const container = this.template.querySelector('.main-container');
        if (container) {
            container.scrollTop = 0;
            const rect = container.getBoundingClientRect();
            this.containerHeight = rect.height - rect.top;
        } else {
            window.scrollTo({ top: 0, behavior: 'auto' });
        }

    }

}