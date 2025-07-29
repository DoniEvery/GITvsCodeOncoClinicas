import { LightningElement, track, wire } from 'lwc';
import getAvailableCards from '@salesforce/apex/APP_CardOrderController.getAvailableCards';
import getUserCardOrder from '@salesforce/apex/APP_CardOrderController.getUserCardOrder';
import saveUserCardOrder from '@salesforce/apex/APP_CardOrderController.saveUserCardOrder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import servicosIcon from '@salesforce/resourceUrl/APP_ServicosIcon';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import ALIAS_FIELD from '@salesforce/schema/User.Alias';
import USER_ID from '@salesforce/user/Id';

export default class AppQuickActionsGrid extends LightningElement {
    @track cards = [];
    @track isLoading = true;
    @track isSaving = false;
    @track isEditing = false;
    @track originalCards = [];
    @track showAll = false;
    servicos = servicosIcon;
    draggedIndex = null;
    userProfileName;
    userAlias;

    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD, ALIAS_FIELD] })
    userProfileHandler({ error, data }) {
        if (data) {
            this.userProfileName = data.fields.Profile.displayValue || data.fields.Profile.value;
            this.userAlias = data.fields.Alias.value;
            this.loadCards(); // ⚠️ só carrega os cards após saber o perfil
        } else if (error) {
            console.error('Erro ao buscar perfil do usuário:', error);
        }
    }


    get toggleButtonLabel() {
        return this.showAll ? 'Ver menos' : 'Ver todos';
    }    

    handleToggleView() {
        this.showAll = !this.showAll;
    }
    

    get visibleCards() {
        return this.showAll ? this.cards : this.cards.slice(0, 4);
    }

    get temMuitosCards() {
        return this.cards.length > 4;
    }
    
    connectedCallback() {
        this.isMobile = window.innerWidth <= 768;
        console.log('Largura: ' + window.innerWidth + 'px');
        console.log('Altura: ' + window.innerHeight + 'px');
    }

    get showMedicoMobileMessage() {
        return this.userProfileName === 'APP_Medico' && this.isMobile;
    }      

    async loadCards() {
        this.isLoading = true;
        try {
            const allCards = await getAvailableCards();    
            const isAdmin = (
                this.userProfileName === 'System Administrator' || 
                this.userProfileName === 'Administrador do sistema' ||
                this.userProfileName === 'Administrador'
            );
    
            const filteredCards = isAdmin
                ? allCards
                : allCards.filter(c => !c.perfil || c.perfil === this.userProfileName);
    
            this.originalCards = filteredCards;
            await this.loadUserOrder(filteredCards);
    
        } catch (error) {
            console.error('Erro ao carregar os cards:', error);
        } finally {
            this.isLoading = false;
        }
    }

    async loadUserOrder(allCards) {
        try {
            const order = await getUserCardOrder();
            if (order?.length > 0) {
                const ordered = order
                    .map(id => allCards.find(c => c.id === id))
                    .filter(Boolean);
                const remaining = allCards.filter(c => !order.includes(c.id));
                this.cards = [...ordered, ...remaining];
            } else {
                this.cards = allCards;
            }
        } catch (error) {
            console.error('Erro ao carregar ordem personalizada:', error);
            this.cards = allCards;
        }
    }

    handleEditPositions() {
        this.isEditing = true;
        this.originalCards = [...this.cards];
    }

    handleCancelEdit() {
        this.cards = [...this.originalCards];
        this.isEditing = false;
        this.draggedIndex = null;
    }

    async handleSaveOrder() {
        this.isSaving = true;

        try {
            await saveUserCardOrder({ cardIds: this.cards.map(c => c.id) });
            this.originalCards = [...this.cards];
            this.isEditing = false;
            this.draggedIndex = null;
            this.showToast('Sucesso', 'Ordem salva com sucesso!', 'success');
            location.reload();
        } catch (error) {
            console.error('Erro ao salvar ordem dos cards:', error);
            this.showToast('Erro', 'Falha ao salvar a ordem', 'error');
        } finally {
            this.isSaving = false;
        }
    }

    handleDragStart(event) {
        if (!this.isEditing) return;
        this.draggedIndex = Number(event.currentTarget.dataset.index);
    }

    handleDragOver(event) {
        if (!this.isEditing) return;
        event.preventDefault();
    }

    handleDrop(event) {
        if (!this.isEditing) return;
        event.preventDefault();

        const droppedIndex = Number(event.currentTarget.dataset.index);
        if (this.draggedIndex === null || droppedIndex === this.draggedIndex) return;

        const cardsCopy = [...this.cards];
        const draggedCard = cardsCopy[this.draggedIndex];
        cardsCopy.splice(this.draggedIndex, 1);
        cardsCopy.splice(droppedIndex, 0, draggedCard);

        this.cards = cardsCopy;
        this.draggedIndex = null;
    }

    handleActionClick(event) {
        if (this.isEditing) return;

        const label = event.detail.label;
        const card = this.cards.find(c => c.title === label);
        if (card) {
            if (card.content?.startsWith('http')) {
                window.open(card.content, '_blank');
            } else {
                this.dispatchEvent(new CustomEvent('navigate', {
                    detail: { pageName: card.title, iconName: card.icon },
                    bubbles: true,
                    composed: true
                }));
            }
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant,
            })
        );
    }
}