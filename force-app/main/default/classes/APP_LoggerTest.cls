@isTest
private class APP_LoggerTest {

    @isTest
    static void testLogErro() {
        Test.startTest();

        APP_Logger.logErro(
            '/servico/teste',
            500,
            'Erro interno do servidor',
            '{ "mensagem": "erro inesperado" }'
        );

        Test.stopTest();

        List<Log__c> logs = [SELECT Id, TipoLog__c, APP_Body__c, APP_Endpoint__c, APP_StatusCode__c, APP_ReturnMessage__c, APP_StatusDscription__c FROM Log__c];

        System.assertEquals(1, logs.size(), 'Deveria ter criado um log');
        Log__c log = logs[0];
        System.assertEquals('APP', log.TipoLog__c);
        System.assertEquals('/servico/teste', log.APP_Endpoint__c);
        System.assertEquals(500, log.APP_StatusCode__c);
        System.assertEquals('Erro interno do servidor', log.APP_ReturnMessage__c);
        System.assertEquals('Erro interno do servidor', log.APP_StatusDscription__c);
        System.assertEquals('{ "mensagem": "erro inesperado" }', log.APP_Body__c);
    }
}