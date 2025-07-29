import { track, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
import getDadosAgendaMedica from '@salesforce/apex/TabelaAgendamentosController.getDadosAgendaMedica';

//Colunas tabela Principal Agenda Médica
const columns = [
    { label: 'Id da Agenda', fieldName: 'agendaMedicaId', type: 'url', sortable: true,  
        typeAttributes: { 
            label: { fieldName: 'agendaMedicaLabel' }, 
            target: '_blank' 
        }
    },
    { label: 'Profissional', fieldName: 'profissional', type: 'text', sortable: true },
    { label: 'Especialidade', fieldName: 'especialidade', type: 'text', sortable: true },
    { label: 'Subespecialidade', fieldName: 'subespecialidade', type: 'text', sortable: true },
    { label: 'Unidade', fieldName: 'unidade', type: 'text', sortable: true },
    { label: 'Idade', fieldName: 'idade', type: 'text', sortable: true },
    { label: 'Sexo', fieldName: 'sexo', type: 'text', sortable: true },
    { label: 'Horário de Atendimento', fieldName: 'horarioAt', type: 'text', sortable: true },
    { label: 'Encaixe', fieldName: 'encaixe', type: 'text', sortable: true }
];

export default class TabelaAgendamentos extends NavigationMixin(LightningElement) {

    columns = columns
    @track infoTabela = [] //tabela imutavel durante o processo
    @track infoTabelaAux = []
    @track dadosConvenios = [] //tabela imutavel durante o processo
    @track filtroConvenio = []
    @track dadosDiagnostico = [] //tabela imutavel durante o processo
    @track filtroDiagnostico = []
    @track modalPlano = false
    @track modalFiltro = false
    @track filtroLateral = true
    @track medicoSelecionado;
    @track unidadeSelecionada;
    @track especialidadeSelecionada;
    @track mapAgendasByConvenios = [];

    @track columns = columns;
    @track sortBy;
    @track sortDirection;

    activeSections = ['Plano', 'Diag'];

    /* -------------------------------------------------------------------------- */
    /*                               LIFECYCLE HOOKS                              */
    /* -------------------------------------------------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                               METHOD HANDLER                               */
    /* -------------------------------------------------------------------------- */
    
    getDadosTabela(){
        this.infoTabela = []
        this.filtroConvenio = []
        this.dadosConvenios = []
        this.filtroDiagnostico = []
        this.dadosDiagnostico = []

        if(!this.medicoSelecionado && !this.unidadeSelecionada && !this.especialidadeSelecionada){
            this.showToast('Nenhum filtro selecionado', 'Por favor, selecione um valor para busca!', 'error')
        }else{
            getDadosAgendaMedica({filtrosMedico:this.medicoSelecionado, filtroUnidade:this.unidadeSelecionada, filtroEspecialidade:this.especialidadeSelecionada}).then((result) =>{
                let records = JSON.parse(result)
                console.log('result' , records)
                let tabela = []

                if(records){
                    records.forEach((dado) => {
                        var convenios = []
                        var diagnosticos = []
                        console.log('result' , dado.Id)
                        
                        //Dados de Convenios
                        if(dado.listaConvenios.length > 0){
                            dado.listaConvenios.forEach((dadoConv) => {
                                if(!this.dadosConvenios.includes(dadoConv)){
                                    const dataConv = {
                                        nomeFiltro : dadoConv,
                                        status : false         
                                    }
                                    this.dadosConvenios.push(dataConv)
                                }
                                convenios.push(dadoConv)
                            })
                        }

                        //Dados de Diagnósticos
                        if(dado.listaDiag.length > 0){
                            dado.listaDiag.forEach((dadoDiag) => {
                                if(!this.dadosDiagnostico.includes(dadoDiag)){
                                    const dataDiag = {
                                        nomeFiltro : dadoDiag,
                                        status : false         
                                    }
                                    this.dadosDiagnostico.push(dataDiag)
                                }
                                diagnosticos.push(dadoDiag)
                            })
                        }

                        //Dados de paciente
                        const data = {
                            agendaMedicaId : '/' + dado.agendaMedicaId,
                            agendaMedicaLabel : dado.agendaMedicaLabel,
                            profissional : dado.profissional,
                            especialidade : dado.especialidade,
                            subespecialidade : dado.subespecialidade,
                            unidade : dado.unidade,
                            idade : dado.idade,
                            sexo : dado.sexo,
                            horarioAt : dado.horarioAt,
                            encaixe : dado.encaixe,
                            listaConvenios : convenios,
                            listaDiagnosticos : diagnosticos
                        }

                        tabela.push(data)
                    })

                    if(this.dadosConvenios) this.filtroConvenio = this.dadosConvenios
                    if(this.dadosDiagnostico) this.filtroDiagnostico = this.dadosDiagnostico;
                    this.showToast('Busca realizada com sucesso!', 'Foram encontradas ' + tabela.length + ' agenda(s) Médica(s)', 'Success')
                }else{
                    this.showToast('Nenhum registro encontrado!', 'A busca não retornou resultados!', 'error')
                    tabela = []
                }
                this.infoTabela = tabela
                this.infoTabelaAux = this.infoTabela

            }).catch((error) =>{
                console.log("erro: " , error)
                this.showToast('Ocorreu um erro!', error, 'error')
            })
        }
    }

    //caixa de busca do filtro de convenio
    buscaConvenioPorNome(event) {
        try{
            var regex = new RegExp(event.target.value,'gi')
            this.filtroConvenio = this.dadosConvenios.filter(row => regex.test(row.nomeFiltro));
        }catch(error){
            console.log('erro: ' , error)
        }
    }

    //caixa de busca do filtro de diagnostico
    buscaDiagPorNome(event) {
        try{
            var regex = new RegExp(event.target.value,'i')
            console.log(regex)
            console.log('this.dadosDiagnostico: ' , JSON.stringify(this.dadosDiagnostico))
            this.filtroDiagnostico = this.dadosDiagnostico.filter(row => regex.test(row.nomeFiltro));
        }catch(error){
            console.log('erro: ' , error)
        }
    }

    //Verifica os convenios setados no filtro
    handleFiltroConvenio(event){
        var valor = event.target.checked
        let foundelement = this.filtroConvenio.find(ele => ele.nomeFiltro == event.target.dataset.id);
        foundelement.status = event.target.checked;
        
        this.filtroConvenio = [...this.filtroConvenio];

        this.handleFiltrosGeral()
    }

    //Verifica os diagnósticos setados no filtro
    handleFiltroDiagnostico(event){
        var valor = event.target.checked
        let foundelement = this.filtroDiagnostico.find(ele => ele.nomeFiltro == event.target.dataset.id);
        foundelement.status = event.target.checked;
        
        this.filtroDiagnostico = [...this.filtroDiagnostico];

        this.handleFiltrosGeral()
    }

    //Realiza a tratativa dos filtros na tabela principal
    handleFiltrosGeral(){
        var listaConvenioTrue = []
        var listaDiagTrue = []
        var listaTeste = []
        
        try{
            listaConvenioTrue = this.filtroConvenio.filter(row => row.status == true)
            listaDiagTrue = this.filtroDiagnostico.filter(row => row.status == true)
            
            if(listaConvenioTrue.length > 0 || listaDiagTrue.length > 0){
                
                //realiza a filtragem da tabela exibida
                this.infoTabelaAux = this.infoTabela.filter(item =>{
                    let temPlano = false
                    let temDiagnostico = false

                    if(listaDiagTrue.length > 0){
                        temDiagnostico = listaDiagTrue.some((dadoDiag) => {
                            return item.listaDiagnosticos.includes(dadoDiag.nomeFiltro)
                        })
                    }

                    if(listaConvenioTrue.length > 0){
                        temPlano = listaConvenioTrue.some((dado) => {
                            return item.listaConvenios.includes(dado.nomeFiltro)
                        })
                    }

                    if(listaConvenioTrue.length > 0){
                        if(temPlano && !temDiagnostico) return true
                    }else{
                        if(!temDiagnostico) return true
                        else return false
                    }
             
                })
            }else{
                //repopula a tabela com todos os registros
                this.infoTabelaAux = this.infoTabela;
            }

        }catch(error){

            console.log('error: ' , error)
        }

    }
    
    handleMedicoSelection(event){
        this.medicoSelecionado = event.target.value
    }

    handleUnidadeSelection(event){
        this.unidadeSelecionada = event.target.value
    }

    handleEspecialidadeSelection(event){
        this.especialidadeSelecionada = event.target.value
    }

    //Exibe ou esconde o filtro lateral
    handleFiltroTela() {
        if(!this.filtroLateral) this.filtroLateral = true
        else this.filtroLateral = false
    }

    //Toast de mensagens de sucesso e erro.
    showToast(titulo, mensagem, variant){
        console.log('teste')
        const event = new ShowToastEvent({
            title: titulo,
            message: mensagem,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    
    //Sort da tabela de agenda medica
    handleSortAccountData(event) {       
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        
        let parseData = JSON.parse(JSON.stringify(this.infoTabela));      
        let keyValue = (a) => {
            return a[fieldname];
        };

       let isReverse = direction === 'asc' ? 1: -1;

        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });
        
        this.infoTabela = parseData;
    }
    
    /* -------------------------------------------------------------------------- */
    /*                               GETTERS SETTERS                              */
    /* -------------------------------------------------------------------------- */

    get tamanhoTotal(){
        return !this.filtroLateral ? 12 : 10
    }

    get tabelaVazia(){
        return (this.infoTabela.length == 0 ? true : false)
    }

    get semFiltroPlano(){
        return (this.filtroConvenio.length == 0 ? true : false)
    }

    get telaFiltros(){
        return (this.filtroLateral ? 'Esconder Filtros' : 'Exibir Filtros')
    }

    get semFiltroDiagnostico(){
        return (this.filtroDiagnostico.length == 0 ? true : false)
    }
    
    get filtroPlanoLabel(){
        return 'Planos de Saúde (' + this.dadosConvenios.length + ')'
    }

    get filtroDiagLabel(){
        return 'Diagnósticos Não Atendidos (' + this.dadosDiagnostico.length + ')'
    }
}