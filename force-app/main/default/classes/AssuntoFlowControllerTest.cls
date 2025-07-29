@isTest
public class AssuntoFlowControllerTest {
    @isTest
    static void searchListTest(){
        Account unidade = DataFactory.gerarUnidadeAtendimento();
        insert unidade;
        
        Assunto__c assuntoDetalhe1 = new Assunto__c();
        assuntoDetalhe1.Name = 'Teste2';
        assuntoDetalhe1.RecordTypeId = Schema.SObjectType.Assunto__c.getRecordTypeInfosByDeveloperName().get('Detalhe').getRecordTypeId();
        assuntoDetalhe1.Ativo__c = true;
        insert assuntoDetalhe1;
        
        Assunto__c assuntoDetalhe2 = new Assunto__c();
        assuntoDetalhe2.Name = 'Teste3';
        assuntoDetalhe2.RecordTypeId = Schema.SObjectType.Assunto__c.getRecordTypeInfosByDeveloperName().get('Detalhe').getRecordTypeId();
        assuntoDetalhe2.Ativo__c = true;
        insert assuntoDetalhe2;
        
        Assunto__c assuntoDetalhe3 = new Assunto__c();
        assuntoDetalhe3.Name = 'Teste5';
        assuntoDetalhe3.RecordTypeId = Schema.SObjectType.Assunto__c.getRecordTypeInfosByDeveloperName().get('Detalhe').getRecordTypeId();
        assuntoDetalhe3.Ativo__c = true;
        insert assuntoDetalhe3;
        
        Assunto__c assuntoDetalhe4 = new Assunto__c();
        assuntoDetalhe4.Name = 'Teste6';
        assuntoDetalhe4.RecordTypeId = Schema.SObjectType.Assunto__c.getRecordTypeInfosByDeveloperName().get('Detalhe').getRecordTypeId();
        assuntoDetalhe4.Ativo__c = true;
        insert assuntoDetalhe4;
        
        Assunto__c assuntoUnity = new Assunto__c();
        assuntoUnity.Name = 'Teste7';
        assuntoUnity.RecordTypeId = Schema.SObjectType.Assunto__c.getRecordTypeInfosByDeveloperName().get('AssuntoUnidade').getRecordTypeId();
        assuntoUnity.Ativo__c = true;
        insert assuntoUnity;
        
        Assunto__c assuntoUnity2 = new Assunto__c();
        assuntoUnity2.Name = 'Teste20';
        assuntoUnity2.RecordTypeId = Schema.SObjectType.Assunto__c.getRecordTypeInfosByDeveloperName().get('AssuntoUnidade').getRecordTypeId();
        assuntoUnity2.Ativo__c = true;
        insert assuntoUnity2;
        
        Assunto__c assunto1 = new Assunto__c();
        assunto1.Name = 'Teste';
		assunto1.DisponivelPaciente__c = true;
        assunto1.MotivoCaso__c = 'Elogio';
        assunto1.RecordTypeId = Schema.SObjectType.Assunto__c.getRecordTypeInfosByDeveloperName().get('AssuntoGlobal').getRecordTypeId();
        assunto1.Ativo__c = true;
        assunto1.AssuntoDetalhe__c = assuntoDetalhe1.id;
        insert assunto1;
        
        Assunto__c assunto2 = new Assunto__c();
        assunto2.Name = 'Teste2';
        assunto2.DisponivelNaoPacientes__c = true;
        assunto2.MotivoCaso__c = 'Elogio';
        assunto2.RecordTypeId = Schema.SObjectType.Assunto__c.getRecordTypeInfosByDeveloperName().get('AssuntoGlobal').getRecordTypeId();
        assunto2.Ativo__c = true;
        assunto2.AssuntoDetalhe__c = assuntoDetalhe2.id;
        insert assunto2;

        AssuntoUnidade__c assuntoUnidade = new AssuntoUnidade__c();
        assuntoUnidade.DisponivelPaciente__c = true;
        assuntoUnidade.MotivoCaso__c = 'Elogio';
        assuntoUnidade.Prioridade__c = 'baixa';
        assuntoUnidade.Unidade__c = unidade.id;
        assuntoUnidade.Ativo__c = true;
        assuntoUnidade.Assunto__c = assuntoUnity.id;
        assuntoUnidade.AssuntoDetalhe__c = assuntoDetalhe3.id;
        insert assuntoUnidade;
        
        AssuntoUnidade__c assuntoUnidade2 = new AssuntoUnidade__c();
        assuntoUnidade.DisponivelPaciente__c = false;
        assuntoUnidade2.DisponivelNaoPacientes__c = true;
        assuntoUnidade2.MotivoCaso__c = 'Elogio';
        assuntoUnidade2.Unidade__c = unidade.id;
        assuntoUnidade2.Ativo__c = true;
        assuntoUnidade2.Assunto__c = assuntoUnity2.id;
        assuntoUnidade.AssuntoDetalhe__c = assuntoDetalhe4.id;
        insert assuntoUnidade2;
        test.startTest();
        AssuntoFlowController.searchListAssunto('AssuntoUnidade__c',true,'Elogio',unidade.id,false,'');
        AssuntoFlowController.searchListAssunto('AssuntoUnidade__c',false,'Elogio',unidade.id,false,'');
        AssuntoFlowController.searchListAssunto('AssuntoUnidade__c',true,'Elogio',unidade.id,true,'');
        AssuntoFlowController.searchListAssunto('AssuntoUnidade__c',false,'Elogio',unidade.id,true,'');
        AssuntoFlowController.searchListAssunto('Assunto__c',true,'Elogio',unidade.id,false,'');
        AssuntoFlowController.searchListAssunto('Assunto__c',false,'Elogio',unidade.id,false,'');
        AssuntoFlowController.searchListAssunto('Assunto__c',true,'Elogio',unidade.id,true,'');
        AssuntoFlowController.searchListAssunto('Assunto__c',false,'Elogio',unidade.id,true,'');
        AssuntoFlowController.searchListDetalhe('AssuntoUnidade__c',true,'Elogio',unidade.id,'Teste7',false,'');
        AssuntoFlowController.searchListDetalhe('AssuntoUnidade__c',false,'Elogio',unidade.id,'Teste20',false,'');
        AssuntoFlowController.searchListDetalhe('Assunto__c',true,'Elogio',unidade.id,assunto1.Name,false,'');
	    AssuntoFlowController.searchListDetalhe('Assunto__c',false,'Elogio',unidade.id,assunto2.Name,false,'');
        AssuntoFlowController.searchListDetalhe('AssuntoUnidade__c',true,'Elogio',unidade.id,'Teste7',true,'');
        AssuntoFlowController.searchListDetalhe('AssuntoUnidade__c',false,'Elogio',unidade.id,'Teste20',true,'');
        AssuntoFlowController.searchListDetalhe('Assunto__c',true,'Elogio',unidade.id,assunto1.Name,true,'');
	    AssuntoFlowController.searchListDetalhe('Assunto__c',false,'Elogio',unidade.id,assunto2.Name,true,'');
       	AssuntoFlowController.searchIdAssunto('Assunto__c','teste','Teste2','','Elogio');
        AssuntoFlowController.searchIdAssunto('AssuntoUnidade__c','Teste7','Teste5',unidade.id,'Elogio');
        test.stopTest();
    }
}