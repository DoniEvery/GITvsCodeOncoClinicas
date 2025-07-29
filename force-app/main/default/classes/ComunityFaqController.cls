public with sharing class ComunityFaqController {
    /*@AuraEnabled(Cacheable=true)
    public static List<Artigo__c> getArtigoList(){
        try {
            User user = [select id, Perfil_de_Acesso__c from User where id = :Userinfo.getUserId()];
            return [SELECT Id, Assunto__c 
                    FROM Artigo__c 
                    WHERE RecordType.DeveloperName = 'PerguntasFrequentes' 
                    AND Perfil_de_Acesso__c = :user.Perfil_de_Acesso__c
                    ORDER BY Ordem__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Questao__c> getQuestoesByArtigo(Id artigoId) {
        if (artigoId == null) {
            throw new AuraHandledException('O ID do artigo é obrigatório.');
        }
        try{
            return [
                SELECT Id, Name, Pergunta__c, Resposta__c
                FROM Questao__c
                WHERE Artigo__c = :artigoId
                ORDER BY Ordem__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }


    }*/
}