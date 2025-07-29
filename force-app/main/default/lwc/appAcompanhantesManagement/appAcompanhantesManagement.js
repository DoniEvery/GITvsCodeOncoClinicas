import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AppAcompanhantesManagement extends LightningElement {
    
    @track acompanhantes = [];
    @track showModal = false;
    @track showDateModal = false;
    @track showRemoveModal = false;
    @track acompanhanteParaRemover = null;
    @track loading = false;
    @track novoAcompanhante = {
        nome: '',
        cpf: '',
        telefone: '',
        email: '',
        dataNascimento: '',
        parentesco: ''
    };

    // Dados mock para teste
    mockAcompanhantes = [
        {
            id: '1',
            nome: 'Maria Silva',
            cpf: '123.456.789-00',
            telefone: '(11) 99999-9999',
            email: 'maria@email.com',
            dataNascimento: '1985-03-15',
            parentesco: 'Esposa',
            ativo: true
        },
        {
            id: '2',
            nome: 'João Silva',
            cpf: '987.654.321-00',
            telefone: '(11) 88888-8888',
            email: 'joao@email.com',
            dataNascimento: '1980-07-22',
            parentesco: 'Irmão',
            ativo: true
        }
    ];

    // Getter para verificar se há acompanhantes
    get hasAcompanhantes() {
        return this.acompanhantes && this.acompanhantes.length > 0;
    }

    // Getter para formatar acompanhantes com data brasileira
    get acompanhantesFormatados() {
        return this.acompanhantes.map(acompanhante => ({
            ...acompanhante,
            dataNascimentoFormatada: this.formatarDataBrasileira(acompanhante.dataNascimento)
        }));
    }

    connectedCallback() {
        this.carregarAcompanhantes();
    }

    carregarAcompanhantes() {
        this.loading = true;
        
        // Simulando delay de carregamento
        setTimeout(() => {
            this.acompanhantes = [...this.mockAcompanhantes];
            this.loading = false;
        }, 500);
    }

    // Função para formatar data para padrão brasileiro
    formatarDataBrasileira(dataString) {
        if (!dataString) return '';
        
        try {
            const data = new Date(dataString);
            if (isNaN(data.getTime())) return dataString; // Retorna original se inválida
            
            const dia = String(data.getDate()).padStart(2, '0');
            const mes = String(data.getMonth() + 1).padStart(2, '0');
            const ano = data.getFullYear();
            
            return `${dia}/${mes}/${ano}`;
        } catch (error) {
            return dataString; // Retorna original em caso de erro
        }
    }

    handleAdicionar() {
        this.showModal = true;
    }

    handleFecharModal() {
        this.showModal = false;
        this.limparFormulario();
    }

    handleSalvar() {
        if (this.validarFormulario()) {
            const novoAcompanhante = {
                id: Date.now().toString(),
                ...this.novoAcompanhante,
                ativo: true
            };
            
            this.acompanhantes = [...this.acompanhantes, novoAcompanhante];
            this.showToast('Sucesso', 'Acompanhante adicionado com sucesso!', 'success');
            this.handleFecharModal();
        }
    }

    handleRemover(event) {
        const id = event.currentTarget.dataset.id;
        this.acompanhanteParaRemover = this.acompanhantes.find(a => a.id === id);
        this.showRemoveModal = true;
    }

    handleConfirmarRemocao() {
        this.acompanhantes = this.acompanhantes.filter(a => a.id !== this.acompanhanteParaRemover.id);
        this.showToast('Sucesso', 'Acompanhante removido com sucesso!', 'success');
        this.showRemoveModal = false;
        this.acompanhanteParaRemover = null;
    }

    handleFecharRemoveModal() {
        this.showRemoveModal = false;
        this.acompanhanteParaRemover = null;
    }

    handleInputChange(event) {
        const { name, value } = event.target;
        this.novoAcompanhante[name] = value;
    }

    handleEntendaComoFunciona() {
        this.showToast('Informação', 'Esta funcionalidade permite que você autorize uma pessoa de confiança a acessar suas informações médicas e gerenciar sua agenda de consultas.', 'info');
    }

    validarFormulario() {
        const { nome, cpf, telefone, email, dataNascimento, parentesco } = this.novoAcompanhante;
        
        if (!nome || !cpf || !telefone || !email || !dataNascimento || !parentesco) {
            this.showToast('Erro', 'Todos os campos são obrigatórios!', 'error');
            return false;
        }

        if (!this.validarCPF(cpf)) {
            this.showToast('Erro', 'CPF inválido!', 'error');
            return false;
        }

        if (!this.validarEmail(email)) {
            this.showToast('Erro', 'Email inválido!', 'error');
            return false;
        }

        return true;
    }

    validarCPF(cpf) {
        // Validação simples de CPF (apenas formato)
        const cpfLimpo = cpf.replace(/[^\d]/g, '');
        return cpfLimpo.length === 11;
    }

    validarEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    limparFormulario() {
        this.novoAcompanhante = {
            nome: '',
            cpf: '',
            telefone: '',
            email: '',
            dataNascimento: '',
            parentesco: ''
        };
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    handleBack() {
        // Navegação de volta
        const event = new CustomEvent('back');
        this.dispatchEvent(event);
    }
}