@isTest
private with sharing class ConsultaEmailContatoControllerTest {

    @isTest
	static void testBuscaEmailsMkt() {
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MarketingCloudServiceMock(200, 200));
			Object retorno = ConsultaEmailContatoController.buscaEmailsMkt('111', Date.today(), Date.today()); 
        test.stopTest();

        //System.assertEquals(true, contato.CRM__c == '12345');
	}
    
}