@isTest
public class App_JuncEspMedicoHandlerTest {

    static Id getRecordTypeId(String sObjectApiName, String developerName) {
        return [SELECT Id FROM RecordType WHERE SObjectType = :sObjectApiName AND DeveloperName = :developerName LIMIT 1].Id;
    }

    @testSetup
    static void setup() {
        Id rtMedico = getRecordTypeId('Contact', 'MedicoCorpoClinico');

        Contact medico = new Contact(
            RecordTypeId = rtMedico,
            FirstName = 'Médico',
            LastName = 'Teste'
        );
        insert medico;

        APP_EspecialidadeMedico__c especialidade = new APP_EspecialidadeMedico__c(
            Name = 'Cardiologia'
        );
        insert especialidade;

        App_JuncEspMedico__c existente = new App_JuncEspMedico__c(
            APP_Medico__c = medico.Id,
            APP_EspecialidadeMedico__c = especialidade.Id
        );
        insert existente;
    }

    @isTest
    static void testInsertDuplicateShouldFail() {
        Contact medico = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'MedicoCorpoClinico' LIMIT 1]; // ← atualizado
        APP_EspecialidadeMedico__c especialidade = [SELECT Id FROM APP_EspecialidadeMedico__c LIMIT 1];

        App_JuncEspMedico__c duplicado = new App_JuncEspMedico__c(
            APP_Medico__c = medico.Id,
            APP_EspecialidadeMedico__c = especialidade.Id
        );

        Test.startTest();
        try {
            insert duplicado;
            System.assert(false, 'Deveria lançar exceção por duplicidade.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Médico e Especialidade'), 'Mensagem de erro esperada.');
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertDifferentShouldPass() {
        Contact medico = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'MedicoCorpoClinico' LIMIT 1]; // ← atualizado

        APP_EspecialidadeMedico__c novaEspecialidade = new APP_EspecialidadeMedico__c(Name = 'Ortopedia');
        insert novaEspecialidade;

        App_JuncEspMedico__c novo = new App_JuncEspMedico__c(
            APP_Medico__c = medico.Id,
            APP_EspecialidadeMedico__c = novaEspecialidade.Id
        );

        Test.startTest();
        insert novo;
        Test.stopTest();

        System.assertNotEquals(null, novo.Id, 'Registro com combinação única deve ser inserido.');
    }

    @isTest
    static void testUpdateToDuplicateShouldFail() {
        Contact medico = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'MedicoCorpoClinico' LIMIT 1]; // ← atualizado
        APP_EspecialidadeMedico__c especialidade = [SELECT Id FROM APP_EspecialidadeMedico__c LIMIT 1];

        APP_EspecialidadeMedico__c novaEspecialidade = new APP_EspecialidadeMedico__c(Name = 'Dermatologia');
        insert novaEspecialidade;

        App_JuncEspMedico__c registro = new App_JuncEspMedico__c(
            APP_Medico__c = medico.Id,
            APP_EspecialidadeMedico__c = novaEspecialidade.Id
        );
        insert registro;

        registro.APP_EspecialidadeMedico__c = especialidade.Id;

        Test.startTest();
        try {
            update registro;
            System.assert(false, 'Atualização duplicada deveria falhar.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Médico e Especialidade'), 'Mensagem de erro esperada na atualização.');
        }
        Test.stopTest();
    }
}