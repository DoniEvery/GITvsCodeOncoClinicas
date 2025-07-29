import { LightningElement, api } from 'lwc';
import inicioIcon from '@salesforce/resourceUrl/APP_InicioIcon';
import conversasIcon from '@salesforce/resourceUrl/APP_ConversasIcon';
import agendaIcon from '@salesforce/resourceUrl/APP_AgendaIcon';
import servicosIcon from '@salesforce/resourceUrl/APP_ServicosIcon';
import menuIcon from '@salesforce/resourceUrl/APP_MenuIcon';

export default class AppTabBar extends LightningElement {
    @api activeTab = 'inicio';

    // Ícones
    inicio = inicioIcon;
    conversas = conversasIcon;
    agenda = agendaIcon;
    servicos = servicosIcon;
    menu = menuIcon;

    get inicioClass() { return this.activeTab === 'Início' ? 'active' : ''; }
    get conversasClass() { return this.activeTab === 'Minhas conversas' ? 'active' : ''; }
    get agendaClass() { return this.activeTab === 'Minha agenda' ? 'active' : ''; }
    get servicosClass() { return this.activeTab === 'Nossos serviços' ? 'active' : ''; }
    get menuClass() { return this.activeTab === 'menu' ? 'active' : ''; }

    selectInicio() { this.dispatchTabChange('Início'); }
    selectConversas() { this.dispatchTabChange('Minhas conversas'); }
    selectAgenda() { this.dispatchTabChange('Minha agenda'); }
    selectServicos() { this.dispatchTabChange('Nossos serviços'); }
    
    selectMenu() {
        const event = new CustomEvent('opensidebar');
        this.dispatchEvent(event);
    }
    
    dispatchTabChange(tabName) {
        const isInProfile = window.location.pathname.includes('/profile');
    
        if (isInProfile) {
            localStorage.setItem('currentPage', tabName);
            window.location.href = '/apppaciente/s/';
        } else {
            this.dispatchEvent(new CustomEvent('tabchange', { detail: tabName }));
        }
    }
    
}