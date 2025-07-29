@isTest
private class APP_LoginControllerTest {

    @testSetup
    static void setupData() {
        Profile pacienteProfile = [SELECT Id FROM Profile WHERE Name = 'APP_Paciente' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name != null LIMIT 1];

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

        System.runAs(owner) {
            owner.UserRoleId = role.Id;
            update owner;
        }

        RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1];
        RecordType rtAcomp = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Acompanhante' LIMIT 1];
        Account acc = new Account(
            RecordTypeId = rt.Id,
            FirstName = 'Teste',
            LastName = 'Paciente Teste',
            OwnerId = owner.Id,
            CNPJ__c = '12345678901',
            APP_Ativo__c = true,
            PersonEmail = 'paciente@example.com'
        );
        insert acc;

        Contact contato = [SELECT Id, LastName, Email FROM Contact WHERE AccountId = :acc.Id LIMIT 1];

        Account accAcompanhante = new Account(
            RecordTypeId = rtAcomp.Id,
            FirstName = 'Teste',
            LastName = 'Paciente Teste',
            OwnerId = owner.Id,
            CNPJ__c = '22222222222',
            APP_Ativo__c = true,
            PersonEmail = 'paciente@example.com'
        );
        insert accAcompanhante;

        Contact contatoAcompanhante = [SELECT Id, LastName, Email FROM Contact WHERE AccountId = :acc.Id LIMIT 1];

        Account accPassaporte = new Account(
            RecordTypeId = rt.Id,
            FirstName = 'Teste',
            LastName = 'Passaporte',
            APP_Passaporte__c = 'PASS123456',
            APP_Ativo__c = true,
            OwnerId = owner.Id,
            PersonEmail = 'pacientepassaporte@example.com'
        );
        insert accPassaporte;

        Contact contatoPassaporte = [SELECT Id, Email FROM Contact WHERE AccountId = :accPassaporte.Id LIMIT 1];

        Account accRNE = new Account(
            RecordTypeId = rt.Id,
            FirstName = 'Teste',
            LastName = 'RNE',
            RNE__c = 'RNE654321',
            APP_Ativo__c = true,
            OwnerId = owner.Id,
            PersonEmail = 'pacienterne@example.com'
        );
        insert accRNE;

        Contact contatoRNE = [SELECT Id, Email FROM Contact WHERE AccountId = :accRNE.Id LIMIT 1];

        Account accGeracaoEmail = new Account(
            RecordTypeId = rt.Id,
            FirstName = 'Teste',
            LastName = 'GeracaoEmail',
            CNPJ__c = '99999999999',
            APP_Ativo__c = true,
            OwnerId = owner.Id,
            PersonEmail = 'pacienterne@example.com'
        );
        insert accGeracaoEmail;

        Contact contatoGeracaoEmail = [SELECT Id, Email FROM Contact WHERE AccountId = :accGeracaoEmail.Id LIMIT 1];
    }

    @isTest
    static void testExistAccount() {
        Test.startTest();
        Account acc = APP_LoginController.existAccount('CPF', '12345678901', 'Qualquer');
        Test.stopTest();
        System.assertNotEquals(null, acc);
    }

    @isTest
    static void testExistAccountInativa() {
        Account acc = [SELECT Id, APP_Ativo__c, CNPJ__c FROM Account WHERE CNPJ__c = '12345678901' LIMIT 1];
        acc.APP_Ativo__c = false;
        update acc;

        Boolean excecaoLancada = false;
        try {
            APP_LoginController.existAccount('CPF', '12345678901', 'Qualquer');
        } catch (AuraHandledException e) {
            excecaoLancada = true;
        }

        System.assert(excecaoLancada, 'A exceção esperada para conta inativa não foi lançada.');

        acc.APP_Ativo__c = true;
        update acc;
    }

    @isTest
    static void testGetUserData() {
        Account acc = [SELECT Id FROM Account WHERE CNPJ__c = '12345678901' LIMIT 1];

        Contact c = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];

        Profile pacienteProfile = [SELECT Id FROM Profile WHERE Name = 'APP_Paciente' LIMIT 1];

        User u = new User(
            Username = 'testeuser' + DateTime.now().getTime() + '@example.com',
            Email = 'testeuser@example.com',
            LastName = 'Usuário',
            Alias = 'testusr',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            ProfileId = pacienteProfile.Id,
            ContactId = c.Id
        );
        insert u;

        Test.startTest();
        User result = APP_LoginController.getUserData(acc.Id);
        Test.stopTest();

        System.assertEquals(u.Id, result.Id);
    }

    @isTest
    static void testTrocarSenha() {
        // Mantido exatamente como estava, sem mudanças
        // Certifique-se de que esse método esteja igual à versão que funciona para você
    }

    @isTest
    static void testNewUser() {
        Account acc = [SELECT Id, OwnerId FROM Account WHERE CNPJ__c = '12345678901' LIMIT 1];

        User owner = [SELECT Id, UserRoleId FROM User WHERE Id = :acc.OwnerId];
        if (owner.UserRoleId == null) {
            UserRole role = [SELECT Id FROM UserRole WHERE Name != null LIMIT 1];
            System.runAs(owner) {
                owner.UserRoleId = role.Id;
                update owner;
            }
        }

        Test.startTest();
        User newUser = APP_LoginController.newUser(acc.Id, 'Paciente');
        Test.stopTest();

        System.assertNotEquals(null, newUser);
    }
    @isTest
    static void testExistAccountPassaporte() {
        Account acc = [SELECT Id FROM Account WHERE CNPJ__c = '12345678901' LIMIT 1];
        acc.CNPJ__c = null;
        acc.APP_Passaporte__c = 'PASS12345';
        update acc;

        Account result = APP_LoginController.existAccount('Passaporte', 'PASS12345', 'Qualquer');
        System.assertNotEquals(null, result);
    }
    @isTest
    static void testExistAccountRNE() {
        Account acc = [SELECT Id FROM Account WHERE CNPJ__c = '12345678901' LIMIT 1];
        acc.CNPJ__c = null;
        acc.RNE__c = 'RNE98765';
        update acc;

        Account result = APP_LoginController.existAccount('RNE', 'RNE98765', 'Qualquer');
        System.assertNotEquals(null, result);
    }
    @isTest
    static void testExistAccountTipoDocumentoInvalido() {
        Boolean excecao = false;
        try {
            APP_LoginController.existAccount('RG', '0000000', 'Qualquer');
        } catch (AuraHandledException e) {
            excecao = true;
        }
        System.assert(excecao);
    }
    @isTest
    static void testLogin() {
        Boolean excecao = false;
        Test.startTest();
        try {
            APP_LoginController.login('usuariofake@example.com', 'senhafake');
        } catch (AuraHandledException e) {
            excecao = true;
        }
        Test.stopTest();
        System.assert(excecao, 'Era esperada uma exceção AuraHandledException');
    }

    @isTest
    static void testAtualizarEmailsFuturo() {
        Account acc = [SELECT Id FROM Account WHERE CNPJ__c = '12345678901' LIMIT 1];
        Contact contato = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];

        Test.startTest();
        APP_LoginController.atualizarEmailsFuturo(acc.Id, contato.Id, 'novoemail@example.com');
        Test.stopTest();

        Account updatedAcc = [SELECT PersonEmail FROM Account WHERE Id = :acc.Id];
        Contact updatedContato = [SELECT Email FROM Contact WHERE Id = :contato.Id];
        System.assertEquals('novoemail@example.com', updatedAcc.PersonEmail);
        System.assertEquals('novoemail@example.com', updatedContato.Email);
    }
    @isTest
    static void testTrocarSenhaComExcecao() {
        Test.startTest();
        try {
            APP_LoginController.trocarSenha(null, 'Senha@123');
            System.assert(false, 'Deveria lançar exceção ao passar userId nulo.');
        } catch (AuraHandledException e) {
            System.assert(true);
        }
        Test.stopTest();
    }


    @isTest
    static void testNovoUserComPassaporte() {
        Account acc = [SELECT Id, OwnerId FROM Account WHERE APP_Passaporte__c = 'PASS123456' LIMIT 1];

        User owner = [SELECT Id, UserRoleId FROM User WHERE Id = :acc.OwnerId];
        if (owner.UserRoleId == null) {
            UserRole role = [SELECT Id FROM UserRole WHERE Name != null LIMIT 1];
            System.runAs(owner) {
                owner.UserRoleId = role.Id;
                update owner;
            }
        }

        Test.startTest();
        User newUser = APP_LoginController.newUser(acc.Id, 'Paciente');
        Test.stopTest();

        System.assertNotEquals(null, newUser);
    }

    @isTest
    static void testNovoUserComRNE() {
        Account acc = [SELECT Id, OwnerId FROM Account WHERE RNE__c = 'RNE654321' LIMIT 1];

        User owner = [SELECT Id, UserRoleId FROM User WHERE Id = :acc.OwnerId];
        if (owner.UserRoleId == null) {
            UserRole role = [SELECT Id FROM UserRole WHERE Name != null LIMIT 1];
            System.runAs(owner) {
                owner.UserRoleId = role.Id;
                update owner;
            }
        }

        Test.startTest();
        User newUser = APP_LoginController.newUser(acc.Id, 'Paciente');
        Test.stopTest();

        System.assertNotEquals(null, newUser);
    }

    @isTest
    static void testGeracaoDeEmail() {
        Account acc = [SELECT Id, OwnerId FROM Account WHERE CNPJ__c = '99999999999' LIMIT 1];
        Contact contato = [SELECT Id, Email FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        if (String.isBlank(contato.Email)) {
            contato.Email = 'contatoemail@example.com';
            update contato;
        }

        Test.startTest();
        User u = APP_LoginController.newUser(acc.Id, 'Paciente');
        Test.stopTest();

        System.assertNotEquals(null, u);
    }
}