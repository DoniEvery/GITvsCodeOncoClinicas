@isTest
private class APP_TermoUsoPageControllerTest {

    @testSetup
    static void setupData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User user = new User(
            Alias = 'usrterm',
            Email = 'usertermo@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Termo',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            TimeZoneSidKey = 'America/Sao_Paulo',
            ProfileId = p.Id,
            Username = 'usertermo' + DateTime.now().getTime() + '@example.com'
        );
        insert user;

        System.runAs(user) {
            insert new List<APP_Term__c>{
                new APP_Term__c(
                    Term_Type__c = 'Termo e Condições de Uso',
                    Is_Active__c = true,
                    Term_Content__c = 'Conteúdo do Termo',
                    Version__c = 2
                ),
                new APP_Term__c(
                    Term_Type__c = 'Política de Privacidade',
                    Is_Active__c = true,
                    Term_Content__c = 'Conteúdo da Política',
                    Version__c = 1
                )
            };
        }
    }

    @isTest
    static void testPrecisaAceitarTermoTrue() {
        User u = [SELECT Id FROM User WHERE Alias = 'usrterm' LIMIT 1];

        System.runAs(u) {
            Test.startTest();
            Boolean precisa = APP_TermoUsoPageController.precisaAceitarTermo();
            Test.stopTest();
            System.assertEquals(true, precisa);
        }
    }

    @isTest
    static void testRegistrarAceite() {
        User u = [SELECT Id FROM User WHERE Alias = 'usrterm' LIMIT 1];

        System.runAs(u) {
            List<String> tipos = new List<String>{'Termo e Condições de Uso', 'Política de Privacidade'};

            Test.startTest();
            APP_TermoUsoPageController.registrarAceite(tipos);
            Test.stopTest();

            List<APP_Term_Agreement__c> acordos = [
                SELECT Id FROM APP_Term_Agreement__c WHERE User__c = :u.Id
            ];
            System.assertEquals(2, acordos.size());
        }
    }

    @isTest
    static void testPrecisaAceitarTermoFalse() {
        User u = [SELECT Id FROM User WHERE Alias = 'usrterm' LIMIT 1];

        System.runAs(u) {
            List<APP_Term__c> termos = [
                SELECT Id, Version__c FROM APP_Term__c
            ];

            List<APP_Term_Agreement__c> acordos = new List<APP_Term_Agreement__c>();
            for (APP_Term__c termo : termos) {
                acordos.add(new APP_Term_Agreement__c(
                    User__c = u.Id,
                    Term__c = termo.Id,
                    Accepted_DateTime__c = DateTime.now(),
                    Accepted_User__c = 'hash',
                    Version__c = termo.Version__c
                ));
            }
            insert acordos;

            Test.startTest();
            Boolean precisa = APP_TermoUsoPageController.precisaAceitarTermo();
            Test.stopTest();

            System.assertEquals(false, precisa);
        }
    }

    @isTest
    static void testObterConteudoTermo() {
        Test.startTest();
        String conteudo = APP_TermoUsoPageController.obterConteudoTermo();
        Test.stopTest();
        System.assertEquals('Conteúdo do Termo', conteudo);
    }

    @isTest
    static void testObterConteudoTermoSemRegistro() {
        delete [SELECT Id FROM APP_Term__c WHERE Term_Type__c = 'Termo e Condições de Uso'];

        Test.startTest();
        String conteudo = APP_TermoUsoPageController.obterConteudoTermo();
        Test.stopTest();
        System.assertEquals('Termo de uso não disponível.', conteudo);
    }

    @isTest
    static void testObterTermosPendentes() {
        User u = [SELECT Id FROM User WHERE Alias = 'usrterm' LIMIT 1];

        System.runAs(u) {
            Test.startTest();
            Map<String, Boolean> pendentes = APP_TermoUsoPageController.obterTermosPendentes();
            Test.stopTest();

            System.assertEquals(true, pendentes.get('Termo e Condições de Uso'));
            System.assertEquals(true, pendentes.get('Política de Privacidade'));
        }
    }

    @isTest
    static void testObterConteudoPolitica() {
        Test.startTest();
        String politica = APP_TermoUsoPageController.obterConteudoPolitica();
        Test.stopTest();

        System.assertEquals('Conteúdo da Política', politica);
    }

    @isTest
    static void testObterConteudoPoliticaSemRegistro() {
        delete [SELECT Id FROM APP_Term__c WHERE Term_Type__c = 'Política de Privacidade'];

        Test.startTest();
        String politica = APP_TermoUsoPageController.obterConteudoPolitica();
        Test.stopTest();

        System.assertEquals('Política de privacidade não disponível.', politica);
    }
}