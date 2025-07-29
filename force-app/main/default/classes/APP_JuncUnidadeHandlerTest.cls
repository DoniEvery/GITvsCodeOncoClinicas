@isTest
public class APP_JuncUnidadeHandlerTest {
    static Id getRT(String obj, String devName) {
        return [SELECT Id FROM RecordType WHERE SObjectType = :obj AND DeveloperName = :devName LIMIT 1].Id;
    }

    @testSetup
    static void setup() {
        Id rtPaciente = getRT('Account', 'PersonAccount');
        Id rtUnidade = getRT('Account', 'IndustriesBusiness');
        Id rtMedico = getRT('Contact', 'MedicoCorpoClinico');
        Id rtEquipe = getRT('Contact', 'APP_EquipeMulti');

        insert new Account(RecordTypeId = rtPaciente, FirstName = 'Paciente', LastName = 'Teste');
        insert new Account(RecordTypeId = rtUnidade, Name = 'Unidade Teste', HealthCloudGA__SourceSystemId__c = 'goc Teste',APP_Ativo__c = True);
        insert new Contact(RecordTypeId = rtMedico, FirstName = 'Médico', LastName = 'Teste');
        insert new Contact(RecordTypeId = rtEquipe, FirstName = 'Equipe', LastName = 'Teste');

        Account paciente = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1];
        Account unidade = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'IndustriesBusiness' LIMIT 1];
        Contact medico = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'MedicoCorpoClinico' LIMIT 1];
        Contact equipe = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'APP_EquipeMulti' LIMIT 1];

        insert new APP_JuncUnidade__c(
            APP_Paciente__c = paciente.Id,
            APP_Medico__c = medico.Id,
            APP_EquipeMulti__c = equipe.Id,
            APP_Unidade__c = unidade.Id
        );
    }

    @isTest
    static void testDuplicateInsertShouldFail() {
        Account paciente = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1];
        Account unidade = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'IndustriesBusiness' LIMIT 1];
        Contact medico = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'MedicoCorpoClinico' LIMIT 1];
        Contact equipe = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'APP_EquipeMulti' LIMIT 1];

        List<APP_JuncUnidade__c> duplicados = new List<APP_JuncUnidade__c>{
            new APP_JuncUnidade__c(APP_Paciente__c = paciente.Id, APP_Unidade__c = unidade.Id),
            new APP_JuncUnidade__c(APP_Medico__c = medico.Id, APP_Unidade__c = unidade.Id),
            new APP_JuncUnidade__c(APP_EquipeMulti__c = equipe.Id, APP_Unidade__c = unidade.Id)
        };

        for (APP_JuncUnidade__c dup : duplicados) {
            try {
                insert dup;
                System.assert(false, 'Deveria falhar por duplicidade.');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('Pessoa/Unidade') || e.getMessage().contains('Médico/Unidade') || e.getMessage().contains('Equipe/Unidade'),
                              'Mensagem de erro esperada.');
            }
        }
    }

    @isTest
    static void testUniqueInsertShouldPass() {
        Account novaUnidade = new Account(
                                        RecordTypeId = getRT('Account', 'IndustriesBusiness'),
                                        Name = 'Outra Unidade',
                                        HealthCloudGA__SourceSystemId__c = 'goc OutroTeste',
                                        APP_Ativo__c = True
                                    );

        insert novaUnidade;

        Account paciente = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1];
        Contact medico = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'MedicoCorpoClinico' LIMIT 1];
        Contact equipe = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'APP_EquipeMulti' LIMIT 1];

        List<APP_JuncUnidade__c> validos = new List<APP_JuncUnidade__c>{
            new APP_JuncUnidade__c(APP_Paciente__c = paciente.Id, APP_Unidade__c = novaUnidade.Id),
            new APP_JuncUnidade__c(APP_Medico__c = medico.Id, APP_Unidade__c = novaUnidade.Id),
            new APP_JuncUnidade__c(APP_EquipeMulti__c = equipe.Id, APP_Unidade__c = novaUnidade.Id)
        };

        Test.startTest();
        insert validos;
        Test.stopTest();

        for (APP_JuncUnidade__c rec : validos) {
            System.assertNotEquals(null, rec.Id, 'Registro válido deve ser inserido.');
        }
    }
}