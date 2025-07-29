public with sharing class APP_CommunityManualController {
    @AuraEnabled(Cacheable=true)
    public static List<APP_Artigo__c> getArtigoList(){
        User user = [select id, Perfil_de_Acesso__c from User where id = :Userinfo.getUserId()];
        return [SELECT Id, Tema__c 
                FROM APP_Artigo__c 
                WHERE RecordType.DeveloperName = 'ManualPaciente'
                AND Ativo__c = true 
                ORDER BY Ordem__c];
    }
    @AuraEnabled(cacheable=true)
    public static List<APP_Questao__c> getQuestoesByArtigo(Id artigoId) {
        if (artigoId == null) {
            throw new AuraHandledException('O ID do artigo e obrigatorio.');
        }
        return [
            SELECT Id, Name, Titulo__c, Conteudo__c
            FROM APP_Questao__c
            WHERE Artigo__c = :artigoId
            AND Ativo__c = true
            ORDER BY Ordem__c];

    }
}