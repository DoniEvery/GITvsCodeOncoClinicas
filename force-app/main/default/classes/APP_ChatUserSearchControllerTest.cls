@isTest
public class APP_ChatUserSearchControllerTest {
    
    @testSetup
    static void setupData() {
        // Record Types
        Id rtPacienteId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Id rtMedicoId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MedicoCorpoClinico').getRecordTypeId();
        Id rtEquipeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('APP_EquipeMulti').getRecordTypeId();
        Id rtUnidadeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();

        // Conta paciente
        Account acc = new Account(
            RecordTypeId = rtPacienteId,
            FirstName = 'Joao',
            LastName = 'Paciente',
            APP_Ativo__c = true
        );
        insert acc;

        Contact paciente = [SELECT Id FROM Contact WHERE AccountId =: acc.Id LIMIT 1];
        
        // Unidade e junção
        Account unidade = new Account(Name = 'Unidade X', RecordTypeId = rtUnidadeId, HealthCloudGA__SourceSystemId__c = 'goc Teste', APP_Ativo__c = true);
        insert unidade;

        Contact medico = new Contact(
            FirstName = 'Maria',
            LastName = 'Medica',
            RecordTypeId = rtMedicoId,
            APP_Ativo__c = true,
            APP_AvailableInChat__c = true
        );
        insert medico;

        // Relacionamento unidade-médico
        insert new APP_JuncUnidade__c(
            APP_Unidade__c = unidade.Id,
            APP_Paciente__c = acc.Id,
            APP_Medico__c = medico.Id,
            APP_Ativo__c = true
        );
    }

    @isTest
    static void testSearchPatients() {
        Test.startTest();

        Id rtPacienteId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Contact paciente = [SELECT Id FROM Contact WHERE Account.RecordTypeId =: rtPacienteId LIMIT 1];
        Profile pacienteProfile = [SELECT Id FROM Profile WHERE Name = 'APP_Paciente' LIMIT 1]; // simula 'APP_Paciente'
        User uPaciente = new User(
            Username = 'paciente@app.com.test',
            Email = 'paciente@app.com',
            LastName = 'Paciente',
            Alias = 'paciente',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            ProfileId = pacienteProfile.Id,
            ContactId = paciente.Id
        );
        insert uPaciente;

        List<APP_ChatUserSearchController.MinimalUserResult> results = APP_ChatUserSearchController.searchPatients('Joao');
        System.assertEquals(1, results.size());
        System.assert(results[0].name.contains('Joao'));

        Test.stopTest();
    }

    @isTest
    static void testSearchProfessionalsPaciente() {
        Test.startTest();

        Id rtPacienteId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Contact paciente = [SELECT Id FROM Contact WHERE Account.RecordTypeId =: rtPacienteId LIMIT 1];
        Profile pacienteProfile = [SELECT Id FROM Profile WHERE Name = 'APP_Paciente' LIMIT 1]; // simula 'APP_Paciente'
        User uPaciente = new User(
            Username = 'paciente@app.com.test',
            Email = 'paciente@app.com',
            LastName = 'Paciente',
            Alias = 'paciente',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            ProfileId = pacienteProfile.Id,
            ContactId = paciente.Id
        );
        insert uPaciente;

        Id rtMedicoId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MedicoCorpoClinico').getRecordTypeId();
        Contact medico = [SELECT Id FROM Contact WHERE RecordTypeId =: rtMedicoId LIMIT 1];
        Profile medicoProfile = [SELECT Id FROM Profile WHERE Name = 'APP_Medico' LIMIT 1]; // simula 'APP_Medico'
        // Usuário do médico (APP_ContatoId__c)
        User uMedico = new User(
            Username = 'medico@app.com.test',
            Email = 'medico@app.com',
            LastName = 'Medico',
            Alias = 'medico',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            ProfileId = medicoProfile.Id,
            APP_ContatoId__c = medico.Id
        );
        insert uMedico;
        
        List<APP_ChatUserSearchController.MinimalUserResult> results = APP_ChatUserSearchController.searchProfessionals('Maria', uPaciente.Id);
        System.assertEquals(1, results.size());
        System.assert(results[0].name.contains('Maria'));

        Test.stopTest();
    }

    @isTest
    static void testSearchProfessionalsNaoPaciente() {
        Test.startTest();

        // Simula um usuário com outro perfil
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        Contact c = new Contact(
            FirstName = 'Ana',
            LastName = 'Admin',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'APP_EquipeMulti' LIMIT 1].Id,
            APP_Ativo__c = true,
            APP_AvailableInChat__c = true
        );
        insert c;

        User admin = new User(
            Username = 'admin@app.com.test',
            Email = 'admin@app.com',
            LastName = 'Admin',
            Alias = 'admin',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            ProfileId = prof.Id,
            APP_ContatoId__c = c.Id
        );
        insert admin;

        List<APP_ChatUserSearchController.MinimalUserResult> results = APP_ChatUserSearchController.searchProfessionals('Ana', admin.Id);
        System.assertEquals(1, results.size());
        System.assert(results[0].name.contains('Ana'));

        Test.stopTest();
    }

    @isTest
    static void testInvalidPrefix() {
        Test.startTest();

        // Testa com prefixo inválido (menor que 3 caracteres)
        List<APP_ChatUserSearchController.MinimalUserResult> res1 = APP_ChatUserSearchController.searchPatients('Jo');
        List<APP_ChatUserSearchController.MinimalUserResult> res2 = APP_ChatUserSearchController.searchProfessionals('', UserInfo.getUserId());
        System.assertEquals(0, res1.size());
        System.assertEquals(0, res2.size());

        Test.stopTest();
    }
}