public with sharing class APP_CommunityFaqController {
    @AuraEnabled(Cacheable=true)
    public static List<APP_Artigo__c> getArtigoList(){
        User user = [select id, Perfil_de_Acesso__c from User where id = :Userinfo.getUserId()];
        return [SELECT Id, Assunto__c 
                FROM APP_Artigo__c 
                WHERE RecordType.DeveloperName = 'PerguntasFrequentes'
                AND Ativo__c = true 
                AND Perfil_de_Acesso__c = :user.Perfil_de_Acesso__c
                ORDER BY Ordem__c];
    }
    @AuraEnabled(cacheable=true)
    public static List<APP_Questao__c> getQuestoesByArtigo(Id artigoId) {
        if (artigoId == null) {
            AuraHandledException e = new AuraHandledException('ID nulo');
            e.setMessage('O ID do artigo é obrigatório.');
            throw e;
        }

        return [
            SELECT Id, Name, Pergunta__c, Resposta__c
            FROM APP_Questao__c
            WHERE Artigo__c = :artigoId
            AND Ativo__c = true
            ORDER BY Ordem__c];

    }
}