@isTest
public class cirurgioesAPITest {
    
    @isTest
    public static void createEncaminhamentoCaseTest() {
        //teste criando caso com paciente novo e médico existente
        Test.setMock(HttpCalloutMock.class, new cirurgioesControllerMock());
        
        String mockJson = '[{"nomePaciente": "João da Silva","email": "joao.silva@example.com","CPFPaciente": "94868614550","RGPaciente": "123456789","celularPaciente": "11912345678","telefonePaciente": "1112345678","dataNascimento": "1990-01-01","genero": "Masculino","CID": "A00","unidade": "IMU106","Praca": "FLORIANOPOLIS","nomeMedico": "Dra. Maria Oliveira","CRMUF": "25501MG"}]';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/encaminhamentoCirurgioes';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(mockJson);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Account organizacao = DataFactory.gerarOrganizacao();
        insert organizacao;
        
        Contact medico = DataFactory.gerarMedico(organizacao.Id);
        medico.CRM_UF__c = '25501MG';
        insert medico;

        test.startTest();
		cirurgioesAPI.createEncaminhamentoCase();
        test.stopTest();
    }
    
    @isTest
    public static void createEncaminhamentoCase1Test() {
        //teste criando caso com paciente novo e médico inexistente
        Test.setMock(HttpCalloutMock.class, new cirurgioesControllerMock());
        
        String mockJson = '[{"nomePaciente": "João da Silva","email": "joao.silva@example.com","CPFPaciente": "94868614550","RGPaciente": "123456789","celularPaciente": "11912345678","telefonePaciente": "1112345678","dataNascimento": "1990-01-01","genero": "Masculino","CID": "A00","unidade": "IMU106","Praca": "FLORIANOPOLIS","nomeMedico": "Dra. Maria Oliveira","CRMUF": "25501MG"}]';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/encaminhamentoCirurgioes';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(mockJson);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Account organizacao = DataFactory.gerarOrganizacao();
        insert organizacao;
        
        Contact medico = DataFactory.gerarMedico(organizacao.Id);
        medico.CRM_UF__c = '25501SP';
        insert medico;

        test.startTest();
		cirurgioesAPI.createEncaminhamentoCase();
        test.stopTest();
    }
   
    @isTest
    public static void createEncaminhamentoCase2Test() {
        //teste criando caso com paciente somente com Primeiro nome Erro ao criar paciente
        Test.setMock(HttpCalloutMock.class, new cirurgioesControllerMock());
        
        String mockJson = '[{"nomePaciente": "João","email": "joao.silva@example.com","CPFPaciente": "94868614550","RGPaciente": "123456789","celularPaciente": "11912345678","telefonePaciente": "1112345678","dataNascimento": "1990-01-01","genero": "Masculino","CID": "A00","unidade": "IMU106","Praca": "FLORIANOPOLIS","nomeMedico": "Dra. Maria Oliveira","CRMUF": "25501MG"}]';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/encaminhamentoCirurgioes';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(mockJson);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Account organizacao = DataFactory.gerarOrganizacao();
        insert organizacao;
        
        Contact medico = DataFactory.gerarMedico(organizacao.Id);
        medico.CRM_UF__c = '25501MG';
        insert medico;

        test.startTest();
        cirurgioesAPI.createEncaminhamentoCase();
        test.stopTest();

    }
    
    @isTest
    public static void createEncaminhamentoCase3Test() {
        //teste faltando campo obrigatório
        Test.setMock(HttpCalloutMock.class, new cirurgioesControllerMock());
        
        String mockJson = '[{"nomePaciente": "João","email": "","CPFPaciente": "94868614550","RGPaciente": "123456789","celularPaciente": "11912345678","telefonePaciente": "1112345678","dataNascimento": "1990-01-01","genero": "Masculino","CID": "A00","unidade": "IMU106","Praca": "FLORIANOPOLIS","nomeMedico": "Dra. Maria Oliveira","CRMUF": "25501MG"}]';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/encaminhamentoCirurgioes';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(mockJson);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Account organizacao = DataFactory.gerarOrganizacao();
        insert organizacao;
        
        Contact medico = DataFactory.gerarMedico(organizacao.Id);
        medico.CRM_UF__c = '25501MG';
        insert medico;

        test.startTest();
		cirurgioesAPI.createEncaminhamentoCase();
        test.stopTest();
    }
    
    @isTest
    public static void createEncaminhamentoCase4Test() {
        //teste enviando dados de um paciente já existente
        Test.setMock(HttpCalloutMock.class, new cirurgioesControllerMock());
        
        String mockJson = '[{"nomePaciente": "João","email": "","CPFPaciente": "94868614550","RGPaciente": "123456789","celularPaciente": "11912345678","telefonePaciente": "1112345678","dataNascimento": "1990-01-01","genero": "Masculino","CID": "A00","unidade": "IMU106","Praca": "FLORIANOPOLIS","nomeMedico": "Dra. Maria Oliveira","CRMUF": "25501MG"}]';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/encaminhamentoCirurgioes';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(mockJson);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Account paciente = DataFactory.gerarPaciente();
        paciente.CNPJ__c = '94868614550';
        insert paciente;
        
        Account organizacao = DataFactory.gerarOrganizacao();
        insert organizacao;
        
        Contact medico = DataFactory.gerarMedico(organizacao.Id);
        medico.CRM_UF__c = '25501MG';
        insert medico;

        test.startTest();
		cirurgioesAPI.createEncaminhamentoCase();
        test.stopTest();
    }
    
    @isTest
    public static void createEncaminhamentoCase5Test() {
        //teste ERRO ao criar caso
        Test.setMock(HttpCalloutMock.class, new cirurgioesControllerMock());
        
        String mockJson = '[{"nomePaciente": "João Marcos","email": "joao.silva@example.com","CPFPaciente": "94868614550","RGPaciente": "123456789","celularPaciente": "11912345678","telefonePaciente": "1112345678","dataNascimento": "1990-01-01","genero": "Masculino","CID": "A00","unidade": "IMU106","Praca": "Floripa","nomeMedico": "Dra. Maria Oliveira","CRMUF": "25501MG"}]';
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/encaminhamentoCirurgioes';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(mockJson);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Account paciente = DataFactory.gerarPaciente();
        paciente.CNPJ__c = '94868614550';
        insert paciente;
        
        Account organizacao = DataFactory.gerarOrganizacao();
        insert organizacao;
        
        Contact medico = DataFactory.gerarMedico(organizacao.Id);
        medico.CRM_UF__c = '25501MG';
        insert medico;

        test.startTest();
		cirurgioesAPI.createEncaminhamentoCase();
        test.stopTest();
    }
    
    public class cirurgioesControllerMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"');
            return res;
        }
    }
}