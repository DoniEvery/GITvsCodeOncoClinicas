public with sharing class APP_CommunityManualController {
    
    // Wrapper para Questão
    public class QuestaoDTO {
        @AuraEnabled public Id id {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String titulo {get;set;}
        @AuraEnabled public String conteudo {get;set;}
    }

    // Wrapper para Artigo (com as questões dentro)
    public class ArtigoDTO {
        @AuraEnabled public Id id {get;set;}
        @AuraEnabled public String tema {get;set;}
        @AuraEnabled public List<QuestaoDTO> questoes {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static List<ArtigoDTO> getArtigosComQuestoesDTO(){
        // Consulta dos artigos com subquery
        List<APP_Artigo__c> artigos = [
            SELECT Id, Tema__c,
                (SELECT Id, Name, Titulo__c, Conteudo__c
                 FROM ArtigoQuestoes__r
                 WHERE Ativo__c = true
                 ORDER BY Ordem__c)
            FROM APP_Artigo__c
            WHERE RecordType.DeveloperName = 'ManualPaciente'
            AND Ativo__c = true
            ORDER BY Ordem__c
        ];

        List<ArtigoDTO> resultado = new List<ArtigoDTO>();

        for (APP_Artigo__c artigo : artigos) {
            ArtigoDTO dto = new ArtigoDTO();
            dto.id = artigo.Id;
            dto.tema = artigo.Tema__c;
            dto.questoes = new List<QuestaoDTO>();

            for (APP_Questao__c q : artigo.ArtigoQuestoes__r) {
                QuestaoDTO qdto = new QuestaoDTO();
                qdto.id = q.Id;
                qdto.name = q.Name;
                qdto.titulo = q.Titulo__c;
                qdto.conteudo = q.Conteudo__c;
                dto.questoes.add(qdto);
            }

            resultado.add(dto);
        }

        return resultado;
    }
}