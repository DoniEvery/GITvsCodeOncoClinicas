@isTest
public  class DataFactory {

    public static User gerarUsuario(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@oncoclinicas.com';
        Profile perfil = [SELECT Id FROM Profile WHERE (Name='Administrador do sistema' OR name = 'System Administrator')];
        User usuario = new User();
        usuario.Alias = 'dinte';
        usuario.Email='standarduser@oncoclinicas.com';
        usuario.EmailEncodingKey='UTF-8';
        usuario.LastName='Testing';
        usuario.LanguageLocaleKey='en_US';
        usuario.LocaleSidKey='en_US';
        usuario.ProfileId = perfil.Id;
        usuario.TimeZoneSidKey='America/Los_Angeles';
        usuario.UserName=uniqueUserName;
        return usuario;
    }

    public static Account gerarPaciente(){
        Account conta = new account();
        conta.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        conta.FirstName = 'Jose';
        conta.LastName = 'Dawn';
        return conta;
    }

    public static Account gerarOrganizacao(){
        Account conta = new account();
        conta.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        conta.Name = 'Hospital Hospitaleiro';
        return conta;
    }

    public static HealthCloudGA__EhrEncounter__c gerarEncontro(String pacienteId){
        HealthCloudGA__EhrEncounter__c encontro = new HealthCloudGA__EhrEncounter__c();
        encontro.HealthCloudGA__Account__c = pacienteId;
        return encontro;
    }

    public static Contact gerarMedico(String contaId){
        Contact contato = new Contact();
        contato.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();
        contato.firstName = 'Shaun';
        contato.LastName = 'Murphy';
        contato.accountId = contaId;
        contato.Email = 'medicoteste@teste.com';
        return contato;
    }

    public static Dna__c gerarDna(Integer ano, String medicoId){
        DNA__c dna = new DNA__c();
        dna.Medico__c = medicoId;
        dna.TotalTratativas__c = 0;
        dna.TotalConsultas__c = 0;
        dna.TotalTratativasMes__c = 0;
        dna.TotalConsultasMes__c = 0;
        dna.Chave__c = medicoId + '-' + ano;
        dna.Ano__c = ano;
        return dna;
    }

    public static EspecialidadeMed__c gerarEspecialidade(){
        EspecialidadeMed__c espec = new EspecialidadeMed__c();
        espec.Name = 'teste espec';
        espec.Ativo__c = true;
        
        return espec;
    }

    public static Account gerarUnidadeAtendimento(){
        Account conta = new account();
        conta.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('UnidadeAtendimento').getRecordTypeId();
        conta.Name = 'Unidade Teste';
        return conta;
    }
    
    public static Assunto__c gerarAssunto(){
        Assunto__c ass = new Assunto__c();
		ass.Ativo__c = true;
        ass.DescricaoAssunto__c = 'Assunto Descricao';
        ass.DisponivelPaciente__c = true;
        ass.Nasce_fechado__c = false;
        ass.Prioridade__c = 'High';
        
        return ass;
        
    }    
    
    public static AssuntoUnidade__c gerarAssuntoUnidade(Account unidade, Assunto__c assunto){
        AssuntoUnidade__c au = new AssuntoUnidade__c();
        au.Unidade__c = unidade.Id;
        au.DisponivelPaciente__c = true;
        au.Ativo__c = true;
        au.Assunto__c = assunto.Id;
        au.MotivoCaso__c = 'Agendamento';
        return au;
        
    }

    public static AgendaMedica__c gerarAgendaMedica(String medicoId, String especialidadeId, String unidadeId){
        AgendaMedica__c agenda = new AgendaMedica__c();
        agenda.Name = 'teste';
        agenda.Unidade__c = unidadeId;
        agenda.Especialidade__c = especialidadeId;
        agenda.Profissional__c = medicoId;

        return agenda;
    }

    public static Account gerarConvenio(){
        Account convenio = new account();
        convenio.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Convenio_OC_Care').getRecordTypeId();
        convenio.Name = 'Convenio teste';
        
        return convenio;
    }

    public static Account gerarLocalOcCare(){
        Account acc = new Account();
        acc.Name = 'teste Local OC Care';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Local_OC_Care').getRecordTypeId();
        return acc;
    }

    public static Lista_Plano_Convenios__c gerarListaConvenio(String convenioId){
        Lista_Plano_Convenios__c listaConv = new Lista_Plano_Convenios__c();
        listaConv.Name = 'listaConv teste';
        listaConv.Id_do_Convenio__c = convenioId;

        return listaConv;
    }

    public static ConveniosAgenda__c gerarConveniosAgenda(String listaConvId, String agendaId){
        ConveniosAgenda__c convAgenda = new ConveniosAgenda__c();
        convAgenda.Lista_Plano_de_Convenio__c = listaConvId;
        convAgenda.ListaConvenios__c = agendaId;

        return convAgenda;
    }

    public static Diagnostico__c gerarDiagnostico(){
        Diagnostico__c diag = new Diagnostico__c();
        diag.Name = 'Teste diagnostico';
        diag.CID__c = '123';

        return diag;
    }

    public static DiagnosticoNaoAtendido__c gerarDiagnosticosAgenda(String diagnosticoId, String agendaId){
        DiagnosticoNaoAtendido__c diagnostico = new DiagnosticoNaoAtendido__c();
        diagnostico.Diagnostico__c = diagnosticoId;
        diagnostico.AgendaMedica__c = agendaId;

        return diagnostico;
    }

    public static Product2 gerarProduto(){
        Product2 produto = new Product2();
        produto.Name = 'produtoTest';

        return produto;
    }

    public static Procedimento__c gerarProcedimento(String contaId, String produtoId){
        Procedimento__c procedimento = new Procedimento__c();
        procedimento.Name = 'procedimentoTeste';
        procedimento.Conta__c = contaId;
        procedimento.Produto__c = produtoId;

        return procedimento;
    }

    public static Case gerarCaso(){
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Solicitacao_de_Cuidado').getRecordTypeId();

        return caso;
    }

    public static Task gerarTarefa(String objetoId){
        Task tarefa = new Task();
        tarefa.subject = 'tarefa teste';
        tarefa.WhatId = objetoId;
        
        return tarefa;
    }

    public static Entitlement gerarDireito(String AccountId){
        Entitlement direito = new Entitlement();
        direito.Name = 'teste';
        direito.AccountId = AccountId;
        direito.type = 'Formulário de agendamento';
        return direito;
    }
    
    public static Knowledge__kav criarArtigo(AssuntoUnidade__c au){
        Knowledge__kav kav = new Knowledge__kav();
        kav.Question__c = 'Pergunta do artigo teste';
        kav.Answer__c = 'Resposta do artigo teste';
        kav.Summary = 'Resumo do artigo teste';
        kav.Title = 'Titulo do artigo teste';
        //kav.PublishStatus = true;
        kav.AssuntoUnidade__c = au.Id;
        kav.UrlName = 'artigo-teste';
        kav.RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('ArtigoAberturaDeCaso').getRecordTypeId();   
        return kav;
    }
}