@isTest
public class APP_AcompanhantesControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Criar record types necessários
        Id acompanhanteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Acompanhante').getRecordTypeId();
        Id pacienteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        
        // Criar conta do paciente
        Account pacienteAccount = new Account(
            Name = 'João Silva',
            CNPJ__c = '12345678901',
            PersonMobilePhone = '(11) 99999-9999',
            PersonEmail = 'joao.silva@teste.com',
            RecordTypeId = pacienteRecordTypeId,
            APP_Ativo__c = true
        );
        insert pacienteAccount;
        
        // Criar usuário do paciente
        Profile pacienteProfile = [SELECT Id FROM Profile WHERE Name = 'APP_Paciente' LIMIT 1];
        User pacienteUser = new User(
            Username = 'joao.silva@teste.com.paciente',
            Email = 'joao.silva@teste.com',
            FirstName = 'João',
            LastName = 'Silva',
            Alias = 'joao',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            ProfileId = pacienteProfile.Id,
            IsActive = true
        );
        insert pacienteUser;
        
        // Criar conta do acompanhante
        Account acompanhanteAccount = new Account(
            Name = 'Maria Silva',
            CNPJ__c = '98765432109',
            PersonMobilePhone = '(11) 88888-8888',
            PersonEmail = 'maria.silva@teste.com',
            RecordTypeId = acompanhanteRecordTypeId,
            APP_Ativo__c = true
        );
        insert acompanhanteAccount;
        
        // Criar junção entre paciente e acompanhante
        APP_JuncAcompanhante__c juncao = new APP_JuncAcompanhante__c(
            APP_Paciente__c = pacienteAccount.Id,
            APP_Acompanhantes__c = acompanhanteAccount.Id,
            APP_Ativo__c = true
        );
        insert juncao;
    }
    
    @isTest
    static void testBuscarAcompanhantes() {
        // Executar como usuário paciente
        User pacienteUser = [SELECT Id FROM User WHERE Username = 'joao.silva@teste.com.paciente' LIMIT 1];
        
        Test.startTest();
        System.runAs(pacienteUser) {
            List<APP_AcompanhantesController.AcompanhanteWrapper> acompanhantes = APP_AcompanhantesController.buscarAcompanhantes();
            
            System.assertEquals(1, acompanhantes.size(), 'Deveria retornar 1 acompanhante');
            System.assertEquals('Maria Silva', acompanhantes[0].nome, 'Nome do acompanhante deveria ser Maria Silva');
            System.assertEquals('98765432109', acompanhantes[0].cpf, 'CPF do acompanhante deveria ser 98765432109');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testBuscarAcompanhantesSemConta() {
        // Criar usuário sem conta associada
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User userSemConta = new User(
            Username = 'user.sem.conta@teste.com',
            Email = 'user.sem.conta@teste.com',
            FirstName = 'User',
            LastName = 'Sem Conta',
            Alias = 'user',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            ProfileId = adminProfile.Id,
            IsActive = true
        );
        insert userSemConta;
        
        Test.startTest();
        System.runAs(userSemConta) {
            try {
                APP_AcompanhantesController.buscarAcompanhantes();
                System.assert(false, 'Deveria ter lançado exceção');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Usuário não possui conta de paciente associada'), 
                            'Mensagem de erro deveria indicar falta de conta');
            }
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCriarAcompanhante() {
        User pacienteUser = [SELECT Id FROM User WHERE Username = 'joao.silva@teste.com.paciente' LIMIT 1];
        
        Test.startTest();
        System.runAs(pacienteUser) {
            APP_AcompanhantesController.criarAcompanhante(
                'Pedro Santos',
                '11122233344',
                '(11) 77777-7777',
                'pedro.santos@teste.com'
            );
            
            // Verificar se o acompanhante foi criado
            List<APP_AcompanhantesController.AcompanhanteWrapper> acompanhantes = APP_AcompanhantesController.buscarAcompanhantes();
            System.assertEquals(2, acompanhantes.size(), 'Deveria ter 2 acompanhantes agora');
            
            // Verificar se a conta foi criada
            List<Account> contas = [SELECT Id, Name, CNPJ__c FROM Account WHERE CNPJ__c = '11122233344'];
            System.assertEquals(1, contas.size(), 'Deveria ter criado a conta do acompanhante');
            
            // Verificar se a junção foi criada
            List<APP_JuncAcompanhante__c> juncoes = [
                SELECT Id FROM APP_JuncAcompanhante__c 
                WHERE APP_Acompanhantes__r.CNPJ__c = '11122233344'
            ];
            System.assertEquals(1, juncoes.size(), 'Deveria ter criado a junção');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCriarAcompanhanteCPFDuplicado() {
        User pacienteUser = [SELECT Id FROM User WHERE Username = 'joao.silva@teste.com.paciente' LIMIT 1];
        
        Test.startTest();
        System.runAs(pacienteUser) {
            try {
                APP_AcompanhantesController.criarAcompanhante(
                    'Outro Nome',
                    '98765432109', // CPF já existente
                    '(11) 66666-6666',
                    'outro@teste.com'
                );
                System.assert(false, 'Deveria ter lançado exceção para CPF duplicado');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Já existe um acompanhante cadastrado com este CPF'), 
                            'Mensagem de erro deveria indicar CPF duplicado');
            }
        }
        Test.stopTest();
    }
    
    @isTest
    static void testAtualizarAcompanhante() {
        User pacienteUser = [SELECT Id FROM User WHERE Username = 'joao.silva@teste.com.paciente' LIMIT 1];
        Account acompanhanteAccount = [SELECT Id FROM Account WHERE CNPJ__c = '98765432109' LIMIT 1];
        
        Test.startTest();
        System.runAs(pacienteUser) {
            APP_AcompanhantesController.atualizarAcompanhante(
                acompanhanteAccount.Id,
                '(11) 55555-5555',
                'maria.nova@teste.com'
            );
            
            // Verificar se os dados foram atualizados
            List<APP_AcompanhantesController.AcompanhanteWrapper> acompanhantes = APP_AcompanhantesController.buscarAcompanhantes();
            System.assertEquals('(11) 55555-5555', acompanhantes[0].celular, 'Celular deveria ter sido atualizado');
            System.assertEquals('maria.nova@teste.com', acompanhantes[0].email, 'Email deveria ter sido atualizado');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testAtualizarAcompanhanteInexistente() {
        User pacienteUser = [SELECT Id FROM User WHERE Username = 'joao.silva@teste.com.paciente' LIMIT 1];
        
        Test.startTest();
        System.runAs(pacienteUser) {
            try {
                APP_AcompanhantesController.atualizarAcompanhante(
                    '001000000000000', // ID inválido
                    '(11) 55555-5555',
                    'teste@teste.com'
                );
                System.assert(false, 'Deveria ter lançado exceção para acompanhante inexistente');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Acompanhante não encontrado'), 
                            'Mensagem de erro deveria indicar acompanhante não encontrado');
            }
        }
        Test.stopTest();
    }
    
    @isTest
    static void testRemoverAcompanhante() {
        User pacienteUser = [SELECT Id FROM User WHERE Username = 'joao.silva@teste.com.paciente' LIMIT 1];
        Account acompanhanteAccount = [SELECT Id FROM Account WHERE CNPJ__c = '98765432109' LIMIT 1];
        
        Test.startTest();
        System.runAs(pacienteUser) {
            APP_AcompanhantesController.removerAcompanhante(acompanhanteAccount.Id);
            
            // Verificar se o acompanhante foi removido da lista
            List<APP_AcompanhantesController.AcompanhanteWrapper> acompanhantes = APP_AcompanhantesController.buscarAcompanhantes();
            System.assertEquals(0, acompanhantes.size(), 'Deveria ter 0 acompanhantes agora');
            
            // Verificar se a junção foi desativada
            List<APP_JuncAcompanhante__c> juncoes = [
                SELECT Id, APP_Ativo__c FROM APP_JuncAcompanhante__c 
                WHERE APP_Acompanhantes__c = :acompanhanteAccount.Id
            ];
            System.assertEquals(1, juncoes.size(), 'Junção deveria existir');
            System.assertEquals(false, juncoes[0].APP_Ativo__c, 'Junção deveria estar inativa');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testRemoverAcompanhanteNaoAutorizado() {
        User pacienteUser = [SELECT Id FROM User WHERE Username = 'joao.silva@teste.com.paciente' LIMIT 1];
        
        Test.startTest();
        System.runAs(pacienteUser) {
            try {
                APP_AcompanhantesController.removerAcompanhante('001000000000000'); // ID inválido
                System.assert(false, 'Deveria ter lançado exceção para acompanhante não autorizado');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Acompanhante não encontrado ou não autorizado'), 
                            'Mensagem de erro deveria indicar acompanhante não autorizado');
            }
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCriarAcompanhanteSemConta() {
        // Criar usuário sem conta associada
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User userSemConta = new User(
            Username = 'user.sem.conta2@teste.com',
            Email = 'user.sem.conta2@teste.com',
            FirstName = 'User',
            LastName = 'Sem Conta 2',
            Alias = 'user2',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            ProfileId = adminProfile.Id,
            IsActive = true
        );
        insert userSemConta;
        
        Test.startTest();
        System.runAs(userSemConta) {
            try {
                APP_AcompanhantesController.criarAcompanhante(
                    'Teste',
                    '12345678900',
                    '(11) 12345-6789',
                    'teste@teste.com'
                );
                System.assert(false, 'Deveria ter lançado exceção');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Usuário não possui conta de paciente associada'), 
                            'Mensagem de erro deveria indicar falta de conta');
            }
        }
        Test.stopTest();
    }
    
    @isTest
    static void testAcompanhanteWrapper() {
        // Teste da classe wrapper
        APP_AcompanhantesController.AcompanhanteWrapper wrapper = new APP_AcompanhantesController.AcompanhanteWrapper(
            '001000000000000',
            'Teste Nome',
            '12345678901',
            '(11) 99999-9999',
            'teste@teste.com'
        );
        
        System.assertEquals('001000000000000', wrapper.id, 'ID deveria ser correto');
        System.assertEquals('Teste Nome', wrapper.nome, 'Nome deveria ser correto');
        System.assertEquals('12345678901', wrapper.cpf, 'CPF deveria ser correto');
        System.assertEquals('(11) 99999-9999', wrapper.celular, 'Celular deveria ser correto');
        System.assertEquals('teste@teste.com', wrapper.email, 'Email deveria ser correto');
    }
}