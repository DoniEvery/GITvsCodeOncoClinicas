@IsTest
public with sharing class CaseTriggerTest {
    
    @TestSetup
    static void makeData(){
        Datetime myDateTime = Datetime.newInstance(2021, 8, 20);
        Date myDate = Date.newInstance(2021, 8, 20);
        
        Account conta = DataFactory.gerarLocalOcCare();
        insert conta;
        
        Contact contato = DataFactory.gerarMedico(null);
        contato.Situacao_do_CRM__c = 'Regular';
        contato.Especialidade_que_Atua__c = 'ACUPUNTURA';
        insert contato;
        
        Product2 produto = DataFactory.gerarProduto();
        insert produto;
        
        Procedimento__c procedimento = DataFactory.gerarProcedimento(conta.Id, produto.Id);
        insert procedimento;
        
        Account convenio_oc = DataFactory.gerarConvenio();
        insert convenio_oc;
        
        Account conta2 = DataFactory.gerarPaciente();
        conta2.PersonBirthdate = myDate;
        conta2.FirstName = 'pacienteNome';
        conta2.LastName = 'pacienteSobrenome';
        conta2.CNPJ__c = '33418582028';
        conta2.PersonMobilePhone = '11999176700';
        conta2.PersonHomePhone = '1199962040';
        conta2.HealthCloudGA__Gender__pc = 'Outro';
        conta2.HealthCloudGA__PrimaryContact__c = contato.Id;
        conta2.Status_do_paciente__c = 'Ativo';
        insert conta2;
        
        Account local_oc = DataFactory.gerarLocalOcCare();
        local_oc.Name = 'Hospital Português';
        local_oc.Praca__c = 'SÃO PAULO';
        local_oc.Situacao_da_Local__c = 'Fora da rede';
        local_oc.Ativo__c = 'Sim';
        insert local_oc;
        
        Case caso = DataFactory.gerarCaso();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Solicitacao_de_Cuidado').getRecordTypeId();
        caso.AccountId = conta2.Id;
        caso.ContactId = contato.Id;
        caso.Status = 'Em andamento';
        caso.Data_de_agendamento__c = myDateTime;
        caso.Convenio_OC_Care__c = convenio_oc.Id;
        caso.EnvioProtocolo__c = true;
        caso.Segmento__c = 'Benigno';
        insert caso;
        
        Task tarefa = DataFactory.gerarTarefa(caso.id);
        insert tarefa;
    }
    
    
    @IsTest 
    public static void checkStatusCaseTest() {
        Test.startTest();
        Case caso = [SELECT Id, Status FROM Case LIMIT 1];
        try {
            caso.Status = 'Fechado';
            update caso;
        } catch (Exception e) {
            System.Assert(e.getMessage().contains('Para fechar o Caso é necessário que todas as atividades estejam concluídas.'));
        }
        
        Test.stopTest();
    }
    
    @isTest
    public static void enviaEmailAlternativoMKTTest(){
        Case caso = [SELECT Id, Status, EmailAlternativo__c, EnvioProtocolo__c, Envio_MKT_Cloud_RequestId__c FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MarketingCloudServiceMock(200, 202));
        caso.EmailAlternativo__c = 'teste@teste.com';
        caso.EnvioProtocoloEmailAlternativo__c =true;
        update caso;
        test.stopTest();
        Case casoFinal = [SELECT Id, Status, EmailAlternativo__c, EnvioProtocolo__c, Envio_MKT_Cloud_RequestId__c FROM Case LIMIT 1];
        System.assertEquals('c68be9ca-c5d8-4a07-8b45-8bd03e274741', casoFinal.Envio_MKT_Cloud_RequestId__c);
    }
    
    @isTest
    public static void enviaEmailAlternativoErroTokenTest(){
        Case caso = [SELECT Id, Status, EmailAlternativo__c, EnvioProtocolo__c FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MarketingCloudServiceMock(400, 202));
        caso.EmailAlternativo__c = 'teste@teste.com';
        caso.EnvioProtocoloEmailAlternativo__c =true;
        update caso;
        test.stopTest();
    }
    
}