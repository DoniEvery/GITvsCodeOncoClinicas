public with sharing class CaseTriggerHandler extends TriggerHelper {

    private static Id CASO_CUIDADO_RTYPE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Solicitacao_de_Cuidado').getRecordTypeId();

    public void checkStatusCase(List<Case> cases) {
        Set<Id> caseIdsToTask = new Set<Id>();

        for(Case caso : cases) {
            if (isChanged(caso, new Set<String>{'Status'})) {
                caseIdsToTask.add(caso.Id);
            }
        }

        if(caseIdsToTask.size() > 0) {
            List<Task> listTask = [
                SELECT Id
                FROM Task
                WHERE WhatId IN :caseIdsToTask AND Status = 'Em andamento'
                WITH SECURITY_ENFORCED
                LIMIT 25000
            ];

            if(listTask.size() > 0) {
                for(Case caso : cases){
                    if(caso.RecordTypeId == CASO_CUIDADO_RTYPE) {
                        if(caso.Status != 'Em andamento') {
                            caso.Status.addError('Para fechar o Caso é necessário que todas as atividades estejam concluídas.');
                        }
                    }                                   
                }
            }
        }
    }

    //Envia email alternativo para a API do MKT Cloud
    public static void enviaEmailAlternativoMKT(list<Case> listaCasos, map<Id, Case> mapCaseOld){
        Set<String> setCasoId = new Set<String>();
        for(Case caso : listaCasos){
            if(caso.EmailAlternativo__c != null && (trigger.isUpdate && caso.EnvioProtocoloEmailAlternativo__c && caso.EnvioProtocoloEmailAlternativo__c != mapCaseOld.get(caso.Id).EnvioProtocoloEmailAlternativo__c) 
              || (trigger.isInsert && caso.EnvioProtocoloEmailAlternativo__c)){
                setCasoId.add(caso.Id);
            }
        }
        if(!setCasoId.isEmpty()) Database.executebatch(new EnviaEmailAlternativoMktBatch(setCasoId), 10);
    }
    
}