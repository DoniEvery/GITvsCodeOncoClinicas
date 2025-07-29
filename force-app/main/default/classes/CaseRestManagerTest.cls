@isTest
public with sharing class CaseRestManagerTest {
    
    @TestSetup
    static void makeData(){
        Account paciente = DataFactory.gerarPaciente();
        paciente.CNPJ__c = '58886120060';
        insert paciente;

        Entitlement ent = DataFactory.gerarDireito(paciente.Id);
        insert ent;
    }
    
    @isTest
    public static void criarCasoPostTest(){
        List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
        Entitlement ent = [SELECT Id, BusinessHoursId FROM Entitlement limit 1];

        ent.BusinessHoursId = bhs[0].Id;
        update ent;
        test.startTest();
        CaseRestManager.caso casoRest = new CaseRestManager.caso();
        casoRest.nome = 'Teste teste';
        casoRest.cpf = '58886120060';
        casoRest.telefone1 = '11323344569';
        casoRest.email = 'teste@teste.com';
        casoRest.unidade = 'Unidade AOCP Barra Mansa'; 
        casoRest.cidade = 'testee'; 
        casoRest.medico = 'medico teste';
        casoRest.descricao = 'xyzabc.....';
        casoRest.tipoconta = 'Paciente';
        casoRest.especialidade = 'teste';
        casoRest.estado = 'SP';
        casoRest.dataNascimento = Date.valueOf('2000-02-02');
        casoRest.campanha = 'campanha01';
        casoRest.canalorigem = 'canalorigem01';
        casoRest.periodoAtend = 'Tarde';
        casoRest.telefoneOpc = '111';
        casoRest.autorizaContporWhatsapp = true;
        casoRest.tipoAtendimento = 'Particular';
        casoRest.utm_term = 'term';
        casoRest.utm_campaign = 'campaign';
        casoRest.utm_id = 'id';
        casoRest.utm_content = 'content';
        
        CaseRestManager.criarCasoPostTest(casoRest);
        
        CaseRestManager.caso casoRest2 = new CaseRestManager.caso();
        casoRest2.nome = 'Teste teste';
        casoRest2.cpf = '58886120060';
        casoRest2.telefone1 = '11323344569';
        casoRest2.email = 'teste@teste.com';
        casoRest2.unidade = 'Unidade AOCP Barra Mansa'; 
        casoRest2.cidade = 'testee'; 
        casoRest2.medico = 'medico teste';
        casoRest2.descricao = 'xyzabc.....';
        casoRest2.tipoconta = 'Paciente';
        casoRest2.especialidade = 'teste';
        casoRest2.estado = 'SP';
        casoRest2.dataNascimento = Date.valueOf('2000-02-02');
        casoRest2.campanha = 'campanha02';
        casoRest2.canalorigem = 'canalorigem02';
        casoRest2.periodoAtend = 'Tarde';
        casoRest2.telefoneOpc = '111';
        casoRest2.autorizaContporWhatsapp = true;   
        casoRest2.utm_term = 'term2';
        casoRest2.utm_campaign = 'campaign2';
        casoRest2.utm_id = 'id2';
        casoRest2.utm_content = 'content2';        

        CaseRestManager.criarCasoPostTest(casoRest2);

        CaseRestManager.caso casoRest3 = new CaseRestManager.caso();
        casoRest3.nome = 'Teste teste';
        casoRest3.cpf = '13017518033';
        casoRest3.telefone1 = '11323344569';
        casoRest3.email = 'teste@teste.com';
        casoRest3.unidade = 'Unidade AOCP Barra Mansa'; 
        casoRest3.cidade = 'testee'; 
        casoRest3.medico = 'medico teste';
        casoRest3.descricao = 'xyzabc.....';
        casoRest3.tipoconta = 'Paciente';
        casoRest3.especialidade = 'teste';
        casoRest3.estado = 'SP';
        casoRest3.dataNascimento = Date.valueOf('2000-02-02');
        casoRest3.campanha = 'campanha03';
        casoRest3.canalorigem = 'canalorigem03';
        casoRest3.periodoAtend = 'Tarde';
        casoRest3.telefoneOpc = '111';
        casoRest3.autorizaContporWhatsapp = false;  
        casoRest3.utm_term = 'term3';
        casoRest3.utm_campaign = 'campaign3';
        casoRest3.utm_id = 'id3';
        casoRest3.utm_content = 'content3';         

        CaseRestManager.criarCasoPostTest(casoRest3);
        
        test.stopTest();
        List<Account> listaAcc = [SELECT Id, CNPJ__c FROM Account WHERE CNPJ__c = :casoRest.cpf];
        
        System.assertEquals(true, !listaAcc.isEmpty());
        
        List<Case> listaCaso = [SELECT Id FROM Case WHERE Account.CNPJ__C = :casoRest.cpf];
        
        System.assertEquals(2, listaCaso.size());
        
        List<Account> listaAcc3 = [SELECT Id, CNPJ__c FROM Account WHERE CNPJ__c = :casoRest3.cpf];
        
        System.assertEquals(true, !listaAcc.isEmpty());
    }
    
    @isTest
    public static void criarCasoPostErroTest(){
        
        CaseRestManager.caso casoRest = new CaseRestManager.caso();
        casoRest.nome = 'Teste';
        casoRest.cpf = '13017518033';
        casoRest.telefone1 = '11323344569';
        casoRest.email = 'teste@teste.com';
        casoRest.unidade = 'Unidade AOCP Barra Mansa'; 
        casoRest.cidade = 'testee'; 
        casoRest.medico = 'medico teste';
        casoRest.descricao = 'xyzabc.....';
        casoRest.especialidade = 'teste';
        casoRest.estado = 'SP';
        casoRest.dataNascimento = Date.valueOf('2000-02-02');
        casoRest.campanha = 'campanha03';
        casoRest.canalorigem = 'canalorigem03';
        casoRest.periodoAtend = 'Tarde';
        casoRest.telefoneOpc = '111';
        casoRest.autorizaContporWhatsapp = true; 
        casoRest.utm_term = 'term';
        casoRest.utm_campaign = 'campaign';
        casoRest.utm_id = 'id';
        casoRest.utm_content = 'content';        
        
        CaseRestManager.criarCasoPostTest(casoRest);
        
        List<Account> listaAcc = [SELECT Id, CNPJ__c FROM Account WHERE CNPJ__c = :casoRest.cpf];
        
        System.assertEquals(true, listaAcc.isEmpty());
    }
}