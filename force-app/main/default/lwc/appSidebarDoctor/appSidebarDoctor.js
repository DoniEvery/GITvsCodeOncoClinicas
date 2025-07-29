import { LightningElement, wire, api, track } from 'lwc';
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
import engrenagemIcon from '@salesforce/resourceUrl/APP_EngrenagemIcon';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

const FIELDS = ['User.Name', 'User.SmallPhotoUrl'];

export default class AppSidebarDoctor extends NavigationMixin(LightningElement) {
    userName;
    userPhotoUrl;

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
    engrenagemIcon = engrenagemIcon;

    @track sidebarOpen = false;
    sidebarVisible = false;
    isMobile = false;
    
    connectedCallback() {
        this.checkScreenSize();
        window.addEventListener('resize', () => this.checkScreenSize());
    }

    checkScreenSize() {
        const width = window.innerWidth;
        const path = window.location.pathname;
        
        this.isMobile = width < 768 || path.includes('/profile');
    }

    @api
    openSidebar() {
        this.sidebarOpen = true;
    }

    @api
    closeSidebar() {
        this.sidebarOpen = false;
    }

    get sidebarClass() {
        return 'custom-sidebar';
    }

    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    wiredUser(result) {
        if (result.data) {
            this.userName = result.data.fields.Name.value;
            this.userPhotoUrl = result.data.fields.SmallPhotoUrl.value;
        } else if (result.error) {
            this.userName = 'Usuário';
        }
    }

    handleProfileClick() {
        const basePath = window.location.origin;
        const profilePath = `/portalpaciente/s/profile/${USER_ID}`;
        window.location.href = basePath + profilePath;
    }

    handleClick(event) {
        const isInProfile = window.location.pathname.includes('/profile');
        const name = event.currentTarget.dataset.name;
        let apiName;
        let label;
    
        switch (name) {
            case 'inicio':
                apiName = 'APP_Inicio';
                label = 'Início';
                break;
            case 'conversas':
                apiName = 'APP_MinhasConversas';
                label = 'Minhas Conversas';
                break;
            case 'politica':
                apiName = 'APP_PoliticaPrivacidade';
                label = 'Política de Privacidade';
                break;
            default:
                return;
        }
    
        console.log('name >> ' + name);
        console.log('api name >> ' + apiName);
    
        if (isInProfile) {
            localStorage.setItem('currentPage', label);
            window.location.href = '/lightning/settings/personal/PersonalInformation/home';
            return;
        }
    
        this.dispatchEvent(new CustomEvent('menuselected', {
            detail: label
        }));
    
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: apiName
            }
        });
    }
    
    
    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleLogout() {
        window.open('/secur/logout.jsp', '_self');
    }

    get sidebarClass() {
        let classes = 'custom-sidebar';
        if (this.sidebarOpen) classes += ' open';
        if (this.isMobile) classes += ' mobile';
        return classes;
    }   
}