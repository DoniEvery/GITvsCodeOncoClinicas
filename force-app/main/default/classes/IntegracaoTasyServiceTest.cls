@isTest
private with sharing class IntegracaoTasyServiceTest {

    @isTest
	static void testCriaPaciente() {
        Account paciente = DataFactory.gerarPaciente();
        paciente.CNPJ__c = '49026952007';
        insert paciente;
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new IntegracaoTasyServiceMock(200, 200));

            IntegracaoTasyService.InserePacienteTasyRequest inserePacienteTasyRequest = new IntegracaoTasyService.InserePacienteTasyRequest();
            inserePacienteTasyRequest.accountId = paciente.Id;
            inserePacienteTasyRequest.nome = paciente.FirstName;
            inserePacienteTasyRequest.sobrenome = paciente.LastName;
            inserePacienteTasyRequest.cpf = '49026952007';
            inserePacienteTasyRequest.email = '49026952007@gmail.com';
            inserePacienteTasyRequest.dataNascimento = Date.today();

            List<IntegracaoTasyService.InserePacienteTasyRequest> listParam = new List<IntegracaoTasyService.InserePacienteTasyRequest>();
            listParam.add(inserePacienteTasyRequest);

			List<Integer> retorno = IntegracaoTasyService.inserePacienteTasy(listParam); 
        test.stopTest(); 
	}
    
}