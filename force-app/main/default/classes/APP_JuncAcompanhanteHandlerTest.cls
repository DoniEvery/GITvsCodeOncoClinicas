@isTest
public class APP_JuncAcompanhanteHandlerTest {

    static Id getRecordTypeId(String sObjectApiName, String developerName) {
        return [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = :sObjectApiName AND DeveloperName = :developerName 
            LIMIT 1
        ].Id;
    }

    @testSetup
    static void setup() {
        Id rtPaciente = getRecordTypeId('Account', 'PersonAccount');
        Id rtAcompanhante = getRecordTypeId('Account', 'Acompanhante');

        Account paciente = new Account(
            RecordTypeId = rtPaciente,
            FirstName = 'Paciente',
            LastName = 'Teste'
        );
        insert paciente;

        Account acompanhante = new Account(
            RecordTypeId = rtAcompanhante,
            FirstName = 'Acompanhante',
            LastName = 'Teste'
        );
        insert acompanhante;

        APP_JuncAcompanhante__c existente = new APP_JuncAcompanhante__c(
            APP_Paciente__c = paciente.Id,
            APP_Acompanhantes__c = acompanhante.Id
        );
        insert existente;
    }

    @isTest
    static void testInsertDuplicateShouldFail() {
        Account paciente = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1];
        Account acompanhante = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Acompanhante' LIMIT 1];

        APP_JuncAcompanhante__c duplicado = new APP_JuncAcompanhante__c(
            APP_Paciente__c = paciente.Id,
            APP_Acompanhantes__c = acompanhante.Id
        );

        Test.startTest();
        try {
            insert duplicado;
            System.assert(false, 'Deveria lançar exceção por duplicidade.');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('registro com esta combinação de Paciente e Acompanhante'),
                'Mensagem de erro esperada.'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertDifferentShouldPass() {
        Account paciente = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1];
        Account outroAcompanhante = new Account(
            RecordTypeId = getRecordTypeId('Account', 'Acompanhante'),
            FirstName = 'Outro',
            LastName = 'Acompanhante'
        );
        insert outroAcompanhante;

        APP_JuncAcompanhante__c novo = new APP_JuncAcompanhante__c(
            APP_Paciente__c = paciente.Id,
            APP_Acompanhantes__c = outroAcompanhante.Id
        );

        Test.startTest();
        insert novo;
        Test.stopTest();

        System.assertNotEquals(null, novo.Id, 'Registro com combinação única deve ser inserido com sucesso.');
    }

    @isTest
    static void testUpdateToDuplicateShouldFail() {
        Account paciente = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1];
        Account novoAcompanhante = new Account(
            RecordTypeId = getRecordTypeId('Account', 'Acompanhante'),
            FirstName = 'Acompanhante',
            LastName = 'Novo'
        );
        insert novoAcompanhante;

        APP_JuncAcompanhante__c registro = new APP_JuncAcompanhante__c(
            APP_Paciente__c = paciente.Id,
            APP_Acompanhantes__c = novoAcompanhante.Id
        );
        insert registro;

        Account acompanhanteDuplicado = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Acompanhante' LIMIT 1];

        registro.APP_Acompanhantes__c = acompanhanteDuplicado.Id;

        Test.startTest();
        try {
            update registro;
            System.assert(false, 'Atualização duplicada deveria falhar.');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('registro com esta combinação de Paciente e Acompanhante'),
                'Mensagem de erro esperada na atualização.'
            );
        }
        Test.stopTest();
    }
}