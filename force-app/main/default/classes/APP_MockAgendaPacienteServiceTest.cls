@IsTest
private class APP_MockAgendaPacienteServiceTest {

    @IsTest
    static void testeSimplesBuscarAgendaMock() {
        
        Test.setMock(HttpCalloutMock.class, new MockRetorno());

        Test.startTest();
        String resultado = APP_MockAgendaPacienteService.buscarAgendaMock();
        Test.stopTest();

        System.assertNotEquals(null, resultado, 'A resposta não pode ser nula');
    }

    private class MockRetorno implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"ok":true}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest 
    static void testBuscarParametros() {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'APP_Parametro__c' AND DeveloperName = 'Agenda' LIMIT 1];

        APP_Parametro__c parametro = new APP_Parametro__c(
            RecordTypeId = rt.Id,
            MaximumRetroactivePeriodMonths__c = 6,
            MaximumFuturePeriodMonths__c = 12
        );
        insert parametro;

        Test.startTest();
        APP_Parametro__c resultado = APP_MockAgendaPacienteService.buscarParametros();
        Test.stopTest();

        System.assertNotEquals(null, resultado, 'Deve retornar um registro');
        System.assertEquals(parametro.MaximumRetroactivePeriodMonths__c, resultado.MaximumRetroactivePeriodMonths__c, 'Valor do MaximumRetroactivePeriodMonths__c deve bater');
        System.assertEquals(parametro.MaximumFuturePeriodMonths__c, resultado.MaximumFuturePeriodMonths__c, 'Valor do MaximumFuturePeriodMonths__c deve bater');
    }
}