public class TaskTriggerHelper 
{   
    private static String followUpRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('FollowUp').getRecordTypeId(); 
    public static void verificaTarefasDatas (Map<Id, Task> mapaTarefasDeletadas) 
    {
        ConfiguracoesOC__c configOC = ConfiguracoesOC__c.getInstance(UserInfo.getUserId());
        
        for (Task t : mapaTarefasDeletadas.values()) {
            if (configOC.PodeExcluirDataComemorativa__c == false) {  
                Id recordTypeId = t.recordTypeId;                
                if (recordTypeId.equals(Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('DatasComemorativas').getRecordTypeId())) {
                    if (mapaTarefasDeletadas.containskey(t.Id)){
                        mapaTarefasDeletadas.get(t.Id).addError('Você não tem permissão para excluir a tarefa!');
                    }                    
                }
            }            
        }
    }
    
    public static void enviarNotificacao(Map<Id, Task> newTaskMap, Map<Id, Task> oldTaskMap) 
    {
        Map<Id,Task> mapEnviarNotificacao = new Map<Id,Task>();
        for (Task t : newTaskMap.values()) 
        {                            
            if (t.NotificaMedico__c == true) mapEnviarNotificacao.put(t.Id, t);
        }          
        if(mapEnviarNotificacao.size() > 0) System.enqueueJob(new EnviarNotificacaoQueueable(mapEnviarNotificacao));  
    }    
    
    public static void verificarViolacaoCaso(List<Task> newTaskList) {
        Map<Id, Case> mapCasesOfTasks = new Map<Id, Case>();
        Set<Id> setCasesId = new Set<Id>();
        for (Task t: newTaskList) {
            String whatId = t?.WhatId;
            if (!String.isBlank(whatId) && whatId.substring(0,3)=='500' && t?.Type=='Re-chamada' && t.RecordTypeId==followUpRecordTypeId){
                setCasesId.add(t.WhatId);
            }
        }
        mapCasesOfTasks.putAll([SELECT Id, ViolacaoCaso__c FROM Case WHERE id =:setCasesId]);
        for (Task t: newTaskList) {
            if (mapCasesOfTasks.containskey(t?.WhatId)){
                if (!mapCasesOfTasks.get(t.WhatId).ViolacaoCaso__c){
                   t.addError('Tarefas de "Follow Up" do tipo "Re-chamada" só podem ser criadas quando o caso estiver violado!'); 
                }
            }
        }
    }    
    
    public static void updateCaseReChegada(List<Task> newTaskList) {
        List<Case> lstCasesForUpdate = new List<Case>();
        Set<Id> setCasesId = new Set<Id>();
        for (Task t: newTaskList) {
            String whatId = t?.WhatId;
            if (!String.isBlank(whatId) && whatId.substring(0,3)=='500' && t?.Type=='Re-chamada' && t.RecordTypeId==followUpRecordTypeId){
                setCasesId.add(t.WhatId);
            }
        }
        lstCasesForUpdate = [SELECT Id, ReChamada__c FROM Case WHERE id =:setCasesId AND ReChamada__c = false];
        for (Case c: lstCasesForUpdate) {
            c.ReChamada__c = true;
        }
        if (!lstCasesForUpdate.isEmpty()) update lstCasesForUpdate;
    }      
}