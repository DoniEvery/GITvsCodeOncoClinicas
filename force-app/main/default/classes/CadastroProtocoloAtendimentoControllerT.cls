@isTest
public class CadastroProtocoloAtendimentoControllerT {
    @isTest
    static void getPickListOrigem() {
        Test.startTest();
        List<CadastroProtocoloAtendimentoController.PickListValue> lstPckOrigem = CadastroProtocoloAtendimentoController.getPickListValuesOrigem('CasoAtendimentoPaciente');
        Test.StopTest();
        System.assert(!lstPckOrigem.isEmpty());
    }
    @isTest
    static void getPickListMotivo() {
        Test.startTest();
        List<CadastroProtocoloAtendimentoController.PickListValue> lstPckOrigem = CadastroProtocoloAtendimentoController.getPickListValuesMotivo();
        Test.StopTest();
        System.assert(!lstPckOrigem.isEmpty());
    }   
    @isTest
    static void getPickListMotivoNaoAgendamento() {
        Test.startTest();
        List<CadastroProtocoloAtendimentoController.PickListValue> lstPckOrigem = CadastroProtocoloAtendimentoController.getPickListValuesMotivoNaoAgendamento();
        Test.StopTest();
        System.assert(!lstPckOrigem.isEmpty());
    }        
    @isTest
    static void getPickListRazaoNaoAgendamento() {
        Test.startTest();
        List<CadastroProtocoloAtendimentoController.PickListValue> lstPckOrigem = CadastroProtocoloAtendimentoController.getPickListValuesRazaoNaoAgendamento();
        Test.StopTest();
        System.assert(!lstPckOrigem.isEmpty());
    }
    @isTest
    static void salvarCaso() {
        Test.startTest();
        Account paciente = DataFactory.gerarPaciente();
        insert paciente;
        Account hosp = DataFactory.gerarOrganizacao();
        insert hosp;
        Contact medico = DataFactory.gerarMedico(hosp.Id);
        insert medico;
        Account unidade = DataFactory.gerarUnidadeAtendimento();
        insert unidade;
        Assunto__c assunto = DataFactory.gerarAssunto();
        insert assunto;
        AssuntoUnidade__c assuntoUnidade = DataFactory.gerarAssuntoUnidade(unidade, assunto);
        insert assuntoUnidade;
        Case caso = new Case(
            Origem__c = 'WhatsApp',
            MotivoCaso__c = 'Agendamento',
            EmailAlternativo__c = 'marcela@teste.com',
            NumeroRetorno__c = '(11) 96629-8954',
            Description = 'teste'
        );
        
        CaseHelper.CaseEntity caseEntity = new CaseHelper.CaseEntity();
        caseEntity.caso = caso;
        caseEntity.account = paciente;
        caseEntity.unidade = unidade;
        caseEntity.medico = medico;
        caseEntity.assuntoUnidade = assuntoUnidade;
        
        CadastroProtocoloAtendimentoController.salvarCaso(JSON.serialize(caseEntity));
        Test.stopTest();
        
    }
    @isTest
    static void salvarCasoError() {
        
        try{
            Test.startTest();
            CadastroProtocoloAtendimentoController.salvarCaso('');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(false, e.getMessage() == 'No content to map to Object due to end of input');
        }
    }
    @isTest
    static void salvarContatoNaoPaciente() {
        PacienteVO paciente = new PacienteVO();
        paciente.title  = 'Novo Paciente teste';
        paciente.nomeCompleto  = 'Paciente teste';
        paciente.CPF  = '153.742.658-30';
        paciente.celular  = '11992837373';
        paciente.email  = 'paciente@email.com';
        paciente.dataNascimento  = '13/04/2002';
        paciente.integrarTasy = false;
        Test.startTest();
        SObject response = CadastroProtocoloAtendimentoController.salvarContato(JSON.serialize(paciente), true);
        Test.stopTest();       
    }
    @isTest
    static void salvarContatoPaciente() {
        PacienteVO paciente = new PacienteVO();
        paciente.title  = 'Novo Paciente teste';
        paciente.nomeCompleto  = 'Paciente teste';
        paciente.CPF  = '153.742.658-30';
        paciente.celular  = '11992837373';
        paciente.email  = 'paciente@email.com';
        paciente.dataNascimento  = '13/04/2002';
        paciente.integrarTasy = false;
        Test.startTest();
        SObject response = CadastroProtocoloAtendimentoController.salvarContato(JSON.serialize(paciente), false);
        Test.stopTest();       
    }
    @isTest
    static void getPacienteTest(){
        PacienteVO paciente = new PacienteVO();
        paciente.title  = 'Novo Paciente teste';
        paciente.nomeCompleto  = 'Paciente teste';
        paciente.CPF  = '153.742.658-30';
        paciente.celular  = '11992837373';
        paciente.email  = 'paciente@email.com';
        paciente.dataNascimento  = '13/04/2002';
        paciente.integrarTasy = true;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize(''), 200, 'OK'));
        SObject response = CadastroProtocoloAtendimentoController.salvarContato(JSON.serialize(paciente), false);
        Test.StopTest();
    }
    
    @isTest
    static void getArticlesKnowledge() {
        Account unidade = DataFactory.gerarUnidadeAtendimento();
        insert unidade;
        Assunto__c ass = DataFactory.gerarAssunto();
        insert ass;
        AssuntoUnidade__c au = DataFactory.gerarAssuntoUnidade(unidade, ass);
        insert au;        
        Knowledge__kav kav = DataFactory.criarArtigo(au);
        insert kav;
        
        Test.startTest();
        CadastroProtocoloAtendimentoController.ResultWrapper result = CadastroProtocoloAtendimentoController.getArticlesKnowledge(au.Id, 'Agendamento','');
        Test.StopTest();
    }
    @isTest
    static void getAccountDataTest(){
        Account paciente = DataFactory.gerarPaciente();
        insert paciente;
        Test.startTest();
        Account acc = CadastroProtocoloAtendimentoController.getAccountData(paciente.Id);
        Test.stopTest();   
    }
    @isTest
    static void getLeadDataTest(){
        Lead ld = new Lead(MobilePhone = '11999999999',LastName = 'teste');
        insert ld;
        Test.startTest();
        Lead lead = CadastroProtocoloAtendimentoController.getLeadData(ld.Id);
        Test.stopTest();   
    }
    @isTest
    static void getAssuntosDetalheTest(){
        Account unidade = DataFactory.gerarUnidadeAtendimento();
        insert unidade;
        Assunto__c assunto = DataFactory.gerarAssunto();
        insert assunto;
        AssuntoUnidade__c assuntoUnidade = DataFactory.gerarAssuntoUnidade(unidade, assunto);
        insert assuntoUnidade;
        Test.startTest();
        List<String> assuntos = CadastroProtocoloAtendimentoController.getAssuntosDetalhe(assuntoUnidade.Id);
        Test.stopTest();   
    }
}