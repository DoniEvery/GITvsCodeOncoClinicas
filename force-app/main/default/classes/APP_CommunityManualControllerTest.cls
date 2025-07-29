@isTest
private class APP_CommunityManualControllerTest {

    @testSetup
    static void setupData() {
        RecordType rtArt = [SELECT Id FROM RecordType 
                         WHERE SObjectType = 'APP_Artigo__c' 
                         AND DeveloperName = 'ManualPaciente' 
                         LIMIT 1];
        RecordType rtQst = [SELECT Id FROM RecordType 
                         WHERE SObjectType = 'APP_Questao__c' 
                         AND DeveloperName = 'ManualPaciente' 
                         LIMIT 1];

        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        u.Perfil_de_Acesso__c = 'PACIENTE E ACOMPANHANTE';
        update u;

        APP_Artigo__c artigo = new APP_Artigo__c(
            Assunto__c = 'Artigo de Teste',
            RecordTypeId = rtArt.Id,
            Ativo__c = true,
            Perfil_de_Acesso__c = 'PACIENTE E ACOMPANHANTE',
            Ordem__c = 1
        );
        insert artigo;

        APP_Questao__c questao = new APP_Questao__c(
            Name = 'Questão de Teste',
            Artigo__c = artigo.Id,
            RecordTypeId = rtQst.Id,
            Pergunta__c = '<p><b>Pergunta:</b> Qual o objetivo?</p>',
            Resposta__c = '<p>Resposta: Fornecer informações frequentes</p>',
            Ativo__c = true,
            Ordem__c = 1
        );
        insert questao;
    }

    @isTest
    static void testGetArtigoList() {
        Test.startTest();
        List<APP_Artigo__c> artigos = APP_CommunityManualController.getArtigoList();
        Test.stopTest();
        System.assertNotEquals(0, artigos.size(), 'Deve retornar pelo menos um artigo válido');
    }

    @isTest
    static void testGetQuestoesByArtigo_Success() {
        APP_Artigo__c artigo = [SELECT Id FROM APP_Artigo__c LIMIT 1];
        Test.startTest();
        List<APP_Questao__c> questoes = APP_CommunityManualController.getQuestoesByArtigo(artigo.Id);
        Test.stopTest();
        System.assertEquals(1, questoes.size(), 'Deve retornar a questão relacionada ao artigo');
    }

    @isTest
    static void testGetQuestoesByArtigo_NullId() {
        Test.startTest();
        try {
            APP_CommunityFaqController.getQuestoesByArtigo(null);
            System.assert(false, 'Deveria lançar exceção ao passar ID nulo');
        } catch (AuraHandledException e) {
            System.assertEquals('O ID do artigo é obrigatório.', e.getMessage());
        }
        Test.stopTest();
    }

}