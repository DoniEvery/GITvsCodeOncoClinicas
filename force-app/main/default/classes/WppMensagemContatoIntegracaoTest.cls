@isTest
public class WppMensagemContatoIntegracaoTest {
	
    @testSetup
    public static void testData(){
        Account acc = DataFactory.gerarOrganizacao();
        insert acc;
        
        Contact con = DataFactory.gerarMedico(acc.Id);
        con.MobilePhone = '5511995894933';
        insert con;
    }
    
    @isTest
    public static void integraMensagemMedicoTest(){
        Contact con = [SELECT id FROM Contact LIMIT 1];
        List<Id> listaCon = new List<Id>{con.Id};

        Test.setMock(HttpCalloutMock.class, new WppMensagemContatoIntegracaoMock());
        test.startTest();
     	WppMensagemContatoIntegracao.integraMensagemMedico(listaCon);
        test.stopTest();
        Contact conRetorno = [SELECT id, StatusIntegracaoMensagem__c FROM Contact LIMIT 1];
        system.assertEquals('Integrado com Sucesso', conRetorno.StatusIntegracaoMensagem__c);
    }

    @isTest
    public static void integraMensagemMedicoErroTest(){
        Contact con = [SELECT id, mobilePhone FROM Contact LIMIT 1];
        List<Id> listaCon = new List<Id>{con.Id};
        con.mobilePhone = null;
        update con;

        Test.setMock(HttpCalloutMock.class, new WppMensagemContatoIntegracaoMock());
        test.startTest();
     	WppMensagemContatoIntegracao.integraMensagemMedico(listaCon);
        test.stopTest();
        Contact conRetorno = [SELECT id, StatusIntegracaoMensagem__c FROM Contact LIMIT 1];
        system.assertEquals(true, conRetorno.StatusIntegracaoMensagem__c.contains('Erro Apex'));
    } 
}