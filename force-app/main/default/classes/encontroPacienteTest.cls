@isTest
public class encontroPacienteTest {

    @isTest
    public static void getEncontroTest() {
        // Teste sem nenhum encontro
        Test.setMock(HttpCalloutMock.class, new timeLineMock());
        
        String mockJson = '{"cpfPaciente": "94868614550"}';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/timelineEncontro';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(mockJson);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Account paciente = DataFactory.gerarPaciente();
        paciente.CNPJ__c = '94868614550'; // Mantido o campo CPF__c
        insert paciente;
        
        test.startTest();
            encontroPacienteController.responseEncontro response = encontroPacienteAPI.getEncontro();
        test.stopTest();
        
        System.assertEquals(true, response.codigoStatus == '004');
    }

    @isTest
    public static void getEncontro1Test() {
        // Teste buscando encontro de atendimento (Encontro)
        Test.setMock(HttpCalloutMock.class, new timeLineMock());
        
        String mockJson = '{"cpfPaciente": "94868614550"}';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/timelineEncontro';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(mockJson);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Account paciente = DataFactory.gerarPaciente();
        paciente.CNPJ__c = '94868614550'; // Mantido o campo CPF__c
        insert paciente;
        
        HealthCloudGA__EhrEncounter__c encontro = DataFactory.gerarEncontro(paciente.Id);
        insert encontro;
        
        test.startTest();
            encontroPacienteController.responseEncontro response = encontroPacienteAPI.getEncontro();
        test.stopTest();
        
        System.assertEquals(true, response.codigoStatus == '001');
    }

    @isTest
    public static void getEncontro2Test() {
        // Teste buscando caso de solicitação de cuidado
        Test.setMock(HttpCalloutMock.class, new timeLineMock());
        
        String mockJson = '{"cpfPaciente": "94868614550"}';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/timelineEncontro';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(mockJson);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Account paciente = DataFactory.gerarPaciente();
        paciente.CNPJ__c = '94868614550'; // Mantido o campo CPF__c
        insert paciente;
        
        Case caso = DataFactory.gerarCaso();
        caso.AccountId = paciente.Id;
        caso.Status = 'Closed';
        caso.Segmento__c = 'Oncológico';
        insert caso;
        
        test.startTest();
            encontroPacienteController.responseEncontro response = encontroPacienteAPI.getEncontro();
        test.stopTest();
        
        System.assertEquals(true, response.codigoStatus == '002');
    }

    @isTest
    public static void getEncontro3Test() {
        // Teste buscando caso de solicitação de cuidado e encontro de atendimento
        Test.setMock(HttpCalloutMock.class, new timeLineMock());
        
        String mockJson = '{"cpfPaciente": "94868614550"}';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/timelineEncontro';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(mockJson);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Account paciente = DataFactory.gerarPaciente();
        paciente.CNPJ__c = '94868614550'; // Mantido o campo CPF__c
        insert paciente;

        HealthCloudGA__EhrEncounter__c encontro = DataFactory.gerarEncontro(paciente.Id);
        insert encontro;
        
        Case caso = DataFactory.gerarCaso();
        caso.AccountId = paciente.Id;
        caso.Status = 'Closed';
        caso.Segmento__c = 'Oncológico';
        insert caso;
        
        test.startTest();
            encontroPacienteController.responseEncontro response = encontroPacienteAPI.getEncontro();
        test.stopTest();
        
        System.assertEquals(true, response.codigoStatus == '003');
    }
    
    public class timeLineMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}');
            return res;
        }
    }
    
}