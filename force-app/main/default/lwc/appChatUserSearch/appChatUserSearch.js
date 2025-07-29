import { LightningElement, track } from 'lwc';
import isCommunityUser from '@salesforce/apex/APP_ChatController.isCommunityUser';
import searchPatients from '@salesforce/apex/APP_ChatUserSearchController.searchPatients';
import searchProfessionals from '@salesforce/apex/APP_ChatUserSearchController.searchProfessionals';
import USER_ID from '@salesforce/user/Id';

export default class AppChatUserSearch extends LightningElement {
    @track searchText = '';
    @track userType = 'Paciente';
    @track filteredUsers = [];
    @track isFixedPaciente = true; // Se true, força tipo "Paciente" e oculta combobox

    userTypeOptions = [
        { label: 'Paciente', value: 'Paciente' },
        { label: 'Profissional', value: 'Profissional' }
    ];

    connectedCallback() {
        isCommunityUser()
            .then(result => {
                this.isFixedPaciente = result;
                if (this.isFixedPaciente) {
                    this.userType = 'Profissional';
                }
            })
            .catch(error => {
                console.error('Erro ao verificar perfil do usuário:', error);
            });
    }

    handleBlur() {
        const trimmed = this.searchText?.trim();
        if (!trimmed) {
            this.filteredUsers = [];

            this.dispatchEvent(new CustomEvent('userselected', {
                detail: {
                    userId: null,
                    userName: null
                }
            }));
        }
    }

    handleInputChange(event) {
        this.searchText = event.target.value;
        this.performSearch();
    }

    handleTypeChange(event) {
        this.userType = event.detail.value;

        // Limpa tudo ao trocar tipo
        this.searchText = '';
        this.filteredUsers = [];

        // Notifica o componente pai que o usuário foi limpo
        this.dispatchEvent(new CustomEvent('userselected', {
            detail: {
                userId: null,
                userName: null
            }
        }));
    }

    performSearch() {
        const prefix = this.searchText.trim();

        clearTimeout(this.debounceTimeout);

        this.debounceTimeout = setTimeout(() => {
            if (!prefix || prefix.length < 3) {
                this.filteredUsers = [];
                return;
            }

            if (this.userType === 'Paciente') {
                searchPatients({ prefix })
                    .then(result => this.filteredUsers = result)
                    .catch(error => console.error('Erro ao buscar pacientes:', error));
            } else {
                searchProfessionals({ prefix, userId: USER_ID })
                    .then(result => this.filteredUsers = result)
                    .catch(error => console.error('Erro ao buscar profissionais:', error));
            }
        }, 300);
    }

    handleSelect(event) {
        const userId = event.currentTarget.dataset.id;
        const selected = this.filteredUsers.find(user => user.id === userId);

        if (selected) {
            // Dispara evento com id + nome
            this.dispatchEvent(new CustomEvent('userselected', {
                detail: {
                    userId: selected.id,
                    userName: selected.name
                }
            }));

            // Exibe o nome no campo de input e limpa sugestões
            this.searchText = selected.name;
            this.filteredUsers = [];
        }
    }
}