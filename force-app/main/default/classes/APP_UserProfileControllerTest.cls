@isTest
private class APP_UserProfileControllerTest {

    @testSetup
    static void setupData() {
        Profile pacienteProfile = [SELECT Id FROM Profile WHERE Name = 'APP_Paciente' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name != null LIMIT 1];

        // Criar owner sem UserRole inicialmente
        User owner = new User(
            Alias = 'owner',
            Email = 'owner@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Owner',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            TimeZoneSidKey = 'America/Sao_Paulo',
            ProfileId = UserInfo.getProfileId(),
            Username = 'owneruser' + DateTime.now().getTime() + '@example.com'
        );
        insert owner;

        // Atribuir UserRole no contexto runAs
        System.runAs(owner) {
            owner.UserRoleId = role.Id;
            update owner;
        }

        // Criar Person Account
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1];

        Account acc = new Account(
            RecordTypeId = rt.Id,
            FirstName = 'Paciente',
            LastName = 'Teste',
            CNPJ__c = '12345678901',
            Ativo__c = 'Sim',
            OwnerId = owner.Id,
            PersonEmail = 'paciente@example.com'
        );
        insert acc;

        // Apenas para garantir que o contato foi criado
        Contact c = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
    }

    @isTest
    static void testAtualizarPerfil() {
        // Buscar dados criados no @testSetup
        Account acc = [SELECT Id FROM Account WHERE CNPJ__c = '12345678901' LIMIT 1];
        Contact c = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        Profile pacienteProfile = [SELECT Id FROM Profile WHERE Name = 'APP_Paciente' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name != null LIMIT 1];

        // Criar User com ContactId e Profile corretos
        User u = new User(
            Username = 'testeuser' + DateTime.now().getTime() + '@example.com',
            Email = 'testeuser@example.com',
            FirstName = 'Fulano',
            LastName = 'Original',
            Alias = 'testusr',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            ProfileId = pacienteProfile.Id,
            ContactId = c.Id
        );
        insert u;

        // Executar método dentro do runAs do próprio usuário
        System.runAs(u) {
            Test.startTest();
            APP_UserProfileController.atualizarPerfil('Novo', 'Nome', '11332211', '99887766', 'novoemail@example.com');
            Test.stopTest();
        }

        // Verificações
        User atualizado = [SELECT FirstName, LastName, Phone, MobilePhone, Email FROM User WHERE Id = :u.Id];
        System.assertEquals('Novo', atualizado.FirstName);
        System.assertEquals('Nome', atualizado.LastName);
        System.assertEquals('11332211', atualizado.Phone);
        System.assertEquals('99887766', atualizado.MobilePhone);
        System.assertEquals('novoemail@example.com', atualizado.Email);

        Contact contatoAtualizado = [SELECT Email FROM Contact WHERE Id = :c.Id];
        System.assertEquals('novoemail@example.com', contatoAtualizado.Email);

        Account accAtualizado = [SELECT PersonEmail FROM Account WHERE Id = :acc.Id];
        System.assertEquals('novoemail@example.com', accAtualizado.PersonEmail);
    }
}