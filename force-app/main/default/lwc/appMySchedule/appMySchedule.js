import { LightningElement, wire, track, api } from 'lwc';
import teleconsultaIcon from '@salesforce/resourceUrl/APP_TeleConsultaIcon';
import consultaPresencialIcon from '@salesforce/resourceUrl/APP_ConsultaPresencialIcon';
import medicoImagem from '@salesforce/resourceUrl/APP_MedicoImagem';
import perfilSemFoto from '@salesforce/resourceUrl/APP_PerfilSemFoto';
import dateIcon from '@salesforce/resourceUrl/APP_DateIcon';
import dateIcon2 from '@salesforce/resourceUrl/APP_DateIcon2';
import detalhesConsultaIcon from '@salesforce/resourceUrl/APP_DetalhesConsultaIcon';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import buscarParametros from '@salesforce/apex/APP_PatientController.buscarParametros';
import listarAgendaPacienteLogado from '@salesforce/apex/APP_PatientController.listarAgendaPacienteLogado';
import registrarErroLog from '@salesforce/apex/APP_PatientController.registrarErroLog';

export default class AppMySchedule extends LightningElement {
    @api modoHome = false;
    @api exibirTodas = false;
    agenda = [];
    filteredAgenda = [];
    selectedFilter = 'today';
    selectedLabel = 'hoje';
    erro;
    showModal = false;
    selectedConsulta;
    teleconsulta = teleconsultaIcon;
    consultaPresencial = consultaPresencialIcon;
    medico = medicoImagem;
    perfilSemFoto = perfilSemFoto;
    dateIcon = dateIcon;
    dateIcon2 = dateIcon2;
    detalhesConsulta = detalhesConsultaIcon;
    showModalData = false;
    showConfirmModal = false;
    dataInicial;
    dataFinal;
    @track expandedGroups = {}; //manter @track para exibir o conteúdo do card
    @track isLoading = true;

    async carregarAgendaReal() {
        this.isLoading = true;
    
        const { dateStart, dateEnd } = this.getFiltroDatas();
    
        try {
            const resultado = await listarAgendaPacienteLogado({ dateStart, dateEnd });    
            if (resultado && resultado.length) {
                const agendasOrdenadas = [...resultado].sort((a, b) => {
                    const dataA = a.start ? new Date(a.start).getTime() : 0;
                    const dataB = b.start ? new Date(b.start).getTime() : 0;
                    return dataA - dataB;
                });
    
                this.filteredAgenda = agendasOrdenadas.map(item => {
                    const data = item.start ? new Date(item.start) : null;
    
                    return {
                        ...item,
                        dataFormatada: data? (this.ehHoje(data) ? 'Hoje' : data.toLocaleDateString('pt-BR', { weekday: 'long', day: '2-digit', month: '2-digit', year: 'numeric' })): 'Data inválida',
                        horaFormatada: data ? data.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' }) : 'Hora inválida',
                        nomeMedico: item.actor?.[0]?.nomeMedico,
                        nomeMedicoFormatado: this.formatarNomeMedico(item.actor?.[0]?.nomeMedico),
                        fotoMedicoUrl: item.actor?.[0]?.fotoMedicoUrl || perfilSemFoto,
                        tipoConsultaFormatado: item.appointmentType?.display || 'Tipo não informado',
                        dataConsulta: data 
                    };
                });
            } else {
                this.filteredAgenda = [];
            }
        } catch (error) {
            console.error('Erro ao buscar agenda real:', error);
            this.erro = 'Erro ao buscar agenda real.';
        
            let erroJson = {
                endpoint: '',
                statusCode: 0,
                mensagem: 'Erro inesperado ao buscar agenda - Salesforce',
                body: error
            };
        
            try {
                if (error?.body?.message) {
                    erroJson = JSON.parse(error.body.message);
                }
            } catch (e) {
                console.warn('Erro ao fazer parse do JSON do erro do Apex:', e);
            }
        
            const endpoint = erroJson.endpoint || '';
            const statusCode = isNaN(parseInt(erroJson.statusCode)) ? 0 : parseInt(erroJson.statusCode);
            const mensagem = erroJson.mensagem || error;
            const body = erroJson.body || '';
        
            if (mensagem !== 'Erro inesperado ao buscar agenda - Salesforce') {
                registrarErroLog({ endpoint, statusCode, mensagem, body })
                    .catch(logError => {
                        console.error('Erro ao registrar o log de erro:', logError);
                    });
            }
        } finally {
            this.isLoading = false;
        }
    }

    formatDateForApi(date, isEndDate = false) {
        const data = new Date(date);
        if (isEndDate) {
            data.setHours(23, 59, 59, 999);
        } else {
            data.setHours(0, 0, 0, 0);
        }
        // Formato: yyyy-MM-ddTHH:mm:ss
        const isoString = data.toISOString();
        return isoString.substring(0, 19); // Remove o `.000Z`
    } 
    
    connectedCallback() {
        this.carregarParametros();
        this.carregarAgendaReal();
    }
    
    carregarParametros() {
        buscarParametros()
            .then(result => {
                if (result) {
                    this.maximumRetroactivePeriodMonths = result.MaximumRetroactivePeriodMonths__c ?? 0;
                    this.maximumFuturePeriodMonths = result.MaximumFuturePeriodMonths__c ?? 0;
                }
            })
            .catch(error => {
                console.error('Erro ao buscar parâmetros:', error);
            });
    }

    ehHoje(data) {
        const hoje = new Date();
        return data.getDate() === hoje.getDate() &&
            data.getMonth() === hoje.getMonth() &&
            data.getFullYear() === hoje.getFullYear();
    }

    //método responsável por enviar as datas para a integração
    getFiltroDatas() { 
        const hoje = new Date();
        hoje.setHours(0, 0, 0, 0);
        
        let dateStart = new Date(hoje);
        let dateEnd = new Date(hoje);
    
        if (this.modoHome) {
            dateStart.setHours(0, 0, 0, 0);
            dateEnd.setHours(23, 59, 59, 999);
        } 
        else if (this.selectedFilter === '7days') {
            dateEnd.setDate(dateStart.getDate() + 7);
        } 
        else if (this.selectedFilter === '30days') {
            dateEnd.setDate(dateStart.getDate() + 30);
        } 
        else if (this.selectedFilter === 'customRange' && this.dataInicial && this.dataFinal) {
            dateStart = new Date(this.dataInicial);
            dateStart.setHours(0, 0, 0, 0);
            dateEnd = new Date(this.dataFinal);
            dateEnd.setHours(23, 59, 59, 0);
        } 
        else {
            dateStart.setHours(0, 0, 0, 0);
            dateEnd.setHours(23, 59, 59, 0);
        }
    
        return {
            dateStart: this.formatDateForApi(dateStart),
            dateEnd: this.formatDateForApi(dateEnd, true) 
        };
    }

    normalizarData(dataString) {
        const d = new Date(dataString);
        d.setHours(0, 0, 0, 0);
        return d;
    }
    
    aplicarFiltro() {
        const hoje = new Date();
        hoje.setHours(0, 0, 0, 0);
    
        const fim7dias = new Date(hoje);
        fim7dias.setDate(hoje.getDate() + 7);
    
        const fim30dias = new Date(hoje);
        fim30dias.setDate(hoje.getDate() + 30);
    
        let agendaFiltrada = this.agenda
            .map(item => {
                const dataConsulta = this.normalizarData(item.start);
                const dataObj = new Date(item.start);
    
                const horaFormatada = dataObj.toLocaleTimeString('pt-BR', {
                    hour: '2-digit',
                    minute: '2-digit',
                    hour12: false
                });
    
                const diasSemana = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
                const diaSemana = diasSemana[dataObj.getDay()];
                const dia = String(dataObj.getDate()).padStart(2, '0');
                const mes = String(dataObj.getMonth() + 1).padStart(2, '0');
                const ano = dataObj.getFullYear();
    
                const dataFormatada = dataConsulta.getTime() === hoje.getTime()
                    ? `Hoje`
                    : `${diaSemana}, ${dia}/${mes}/${ano}`;
    
                return {
                    ...item,
                    isRemoto: item.tipoConsulta === 'Tele',
                    dataConsulta,
                    hora: horaFormatada,
                    dataFormatada,
                    tipoConsutaFormatado: this.formatarTipoAgenda(item.appointmentType?.display)
                };
            });
    
            if (this.modoHome) {
                this.filteredAgenda = this.filteredAgenda
                    .filter(item => {
                        if (!item.dataConsulta) return false;
                        return item.dataConsulta.getTime() === hoje.getTime();
                    })
                    .sort((a, b) => a.dataConsulta - b.dataConsulta); 
                
                if (!this.exibirTodas) {
                    this.filteredAgenda = this.filteredAgenda.slice(0, 4); 
                }
                return;
            }
    
        this.filteredAgenda = agendaFiltrada.filter(item => {
            if (this.selectedFilter === 'today') {
                return item.dataConsulta.getTime() === hoje.getTime();
            }
    
            if (this.selectedFilter === '7days') {
                return item.dataConsulta >= hoje && item.dataConsulta <= fim7dias;
            }
    
            if (this.selectedFilter === '30days') {
                return item.dataConsulta >= hoje && item.dataConsulta <= fim30dias;
            }
    
            if (this.selectedFilter === 'customRange' && this.dataInicial && this.dataFinal) {
                const dataConsultaLimpa = new Date(item.dataConsulta);
                dataConsultaLimpa.setHours(0, 0, 0, 0);
    
                const dataInicio = new Date(this.dataInicial);
                const dataFim = new Date(this.dataFinal);
                dataInicio.setHours(0, 0, 0, 0);
                dataFim.setHours(23, 59, 59, 999);
    
                return dataConsultaLimpa >= dataInicio && dataConsultaLimpa <= dataFim;
            }
    
            return true;
        });
    }     

    @api aplicarFiltroCustomRange(dataInicial, dataFinal) {
        if (dataInicial && dataFinal) {
            const inicio = new Date(dataInicial);
            const fim = new Date(dataFinal);

            inicio.setHours(0, 0, 0, 0);
            fim.setHours(23, 59, 59, 999);
    
            const hoje = new Date();
            hoje.setHours(0, 0, 0, 0);
    
            const mesesRetroativos = this.maximumRetroactivePeriodMonths;
            const mesesFuturos = this.maximumFuturePeriodMonths;
    
            const temLimiteRetroativo = mesesRetroativos !== null && mesesRetroativos !== undefined && mesesRetroativos !== 0;
            const temLimiteFuturo = mesesFuturos !== null && mesesFuturos !== undefined && mesesFuturos !== 0;
    
            const limiteRetroativo = new Date(hoje);
            if (temLimiteRetroativo) {
                limiteRetroativo.setMonth(hoje.getMonth() - mesesRetroativos);
            }

            const limiteFuturo = new Date(hoje);
            if (temLimiteFuturo) {
                limiteFuturo.setMonth(hoje.getMonth() + mesesFuturos);
            }
            limiteFuturo.setHours(23, 59, 59, 999); 
    
            if (temLimiteRetroativo && inicio < limiteRetroativo) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Limite retroativo excedido',
                    message: `A data inicial não pode ser anterior a ${mesesRetroativos} meses.`,
                    variant: 'warning'
                }));
                return false;
            }
    
            if (temLimiteFuturo && fim > limiteFuturo) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Limite futuro excedido',
                    message: `A data final não pode ser posterior a ${mesesFuturos} meses.`,
                    variant: 'warning'
                }));
                return false;
            }
    
            if (fim < inicio) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Atenção',
                    message: 'Data final não pode ser menor que a inicial.',
                    variant: 'warning'
                }));
                return false;
            }
    
            this.dataInicial = inicio;
            this.dataFinal = fim;
            this.selectedFilter = 'customRange';
            this.selectedLabel = `de ${inicio.toLocaleDateString('pt-BR')} até ${fim.toLocaleDateString('pt-BR')}`;
            this.carregarAgendaReal();
            return true;
        }
    
        this.dispatchEvent(new ShowToastEvent({
            title: 'Campos obrigatórios',
            message: 'Selecione as duas datas.',
            variant: 'error'
        }));
        return false;
    }     
    
    getIconSeta(expanded) {
        return expanded ? 'utility:chevrondown' : 'utility:chevronright';
    }
    
    formatarNomeMedico(nome) {
        if (!nome) return '';
        return nome.length > 16 ? nome.substring(0, 16) + '...' : nome;
    }
    
    formatarTipoAgenda(tipoAgenda) {
        if (!tipoAgenda) return '';
        return tipoAgenda.length > 16 ? tipoAgenda.substring(0, 16) + '...' : tipoAgenda;
    }

    get hasAgenda() {
        return this.filteredAgenda && this.filteredAgenda.length > 0;
    }

    get agendaAgrupada() {
        const grupos = {};
    
        this.filteredAgenda.forEach(item => {
            const dataObj = new Date(item.start);
    
            const diasSemana = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
            const diaSemana = diasSemana[dataObj.getDay()];
            const dia = String(dataObj.getDate()).padStart(2, '0');
            const mes = String(dataObj.getMonth() + 1).padStart(2, '0');
            const ano = dataObj.getFullYear();
    
            const label = `${diaSemana}, ${dia}/${mes}/${ano}`;
    
            if (!grupos[label]) {
                grupos[label] = [];
            }
            grupos[label].push(item);
        });
    
        return Object.keys(grupos).map(dataLabel => {
            const expanded = this.selectedFilter === 'today' ? true : (this.expandedGroups[dataLabel] || false);
            return {
                dataLabel,
                consultas: grupos[dataLabel],
                expanded,
                iconeSeta: expanded ? 'utility:chevrondown' : 'utility:chevronright',
                exibirSeta: this.selectedFilter !== 'today'
            };
        });
    }    

    @api
    async refreshAgenda() {
        await this.carregarAgendaReal();
    }
    
    toggleExpand(event) {
        if (this.selectedFilter === 'today') {
            return; // Bloqueia o clique quando for "hoje"
        }
    
        const label = event.currentTarget.dataset.label;
        this.expandedGroups[label] = !this.expandedGroups[label];
    }
    
    get isHoje() {
        return this.selectedFilter === 'today';
    }
    
    abrirModal(event) {
        const consultaId = event.currentTarget.dataset.id;
        const consulta = this.filteredAgenda.find(c => c.id == consultaId); 
        
        if (consulta) {
            this.dispatchEvent(new CustomEvent('abrirdetalhesmodal', {
                detail: { consulta },
                bubbles: true,
                composed: true
            }));
        } else {
            console.error('Consulta não encontrada para ID:', consultaId);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Erro',
                message: 'Não foi possível carregar os detalhes da consulta.',
                variant: 'error'
            }));
        }
    }

    abrirModalData() {
        this.dispatchEvent(new CustomEvent('abrirdatemodal', {
            bubbles: true,
            composed: true
        }));
    }
    
    get todayButtonClass() {
        return this.selectedFilter === 'today' ? 'filter-button selected' : 'filter-button';
    }
    
    get sevenDaysButtonClass() {
        return this.selectedFilter === '7days' ? 'filter-button selected' : 'filter-button';
    }
    
    get thirtyDaysButtonClass() {
        return this.selectedFilter === '30days' ? 'filter-button selected' : 'filter-button';
    }
    
    get escolherButtonClass() {
        return this.selectedFilter === 'customRange' ? 'filter-button selected' : 'filter-button';
    }    

    filterToday = () => {
        this.selectedFilter = 'today';
        this.selectedLabel = 'hoje';
        this.aplicarFiltro();
        this.carregarAgendaReal();
    };

    filter7Days = () => {
        this.selectedFilter = '7days';
        this.selectedLabel = 'nos próximos 7 dias';
        this.aplicarFiltro();
        this.carregarAgendaReal();
    };

    filter30Days = () => {
        this.selectedFilter = '30days';
        this.selectedLabel = 'nos próximos 30 dias';
        this.aplicarFiltro();
        this.carregarAgendaReal();
    };
    
    aplicarFiltroCustom() {
        if (this.dataInicial && this.dataFinal) {
            if (this.dataFinal < this.dataInicial) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Atenção',
                        message: 'Data final não pode ser menor que a inicial.',
                        variant: 'warning'
                    })
                );
                return;
            }
    
            this.selectedFilter = 'customRange';
    
            const dataInicialFormatada = this.dataInicial.toLocaleDateString('pt-BR');
            const dataFinalFormatada = this.dataFinal.toLocaleDateString('pt-BR');
    
            this.selectedLabel = `de ${dataInicialFormatada} até ${dataFinalFormatada}`;
    
            this.aplicarFiltro();
            this.showModalData = false;
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Campos obrigatórios',
                    message: 'Selecione as duas datas.',
                    variant: 'error'
                })
            );
        }
    }     

    abrirModalConfirmacao() {
        this.dispatchEvent(new CustomEvent('abrirconfirmmodal', {
            detail: {
                imagem: this.imagemDetalhe 
            },
            bubbles: true, 
            composed: true
        }));
    }

    confirmarConsultaSelecionada() {
        this.showConfirmModal = false;
    }

    get showNoAgendaAndModoHome() {
        return !this.hasAgenda && this.modoHome;
    }
      
    get showNoAgendaAndNotModoHome() {
        return !this.hasAgenda && !this.modoHome;
    }

    get consultasParaExibir() {
        if (this.modoHome) {
            if (this.exibirTodas) {
                return this.filteredAgenda;
            }
            return this.filteredAgenda.slice(0,4);
        }
        return [];
    }  

    renderedCallback() {
        this.dispatchEvent(new CustomEvent('statusagenda', {
            detail: { exibirBotao: !this.showNoAgendaAndModoHome }
        }));
    }
}