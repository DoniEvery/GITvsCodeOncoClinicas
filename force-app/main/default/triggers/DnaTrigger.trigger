trigger DnaTrigger on dna__c (before insert, before update) {
    
    Boolean beforeInsert = trigger.isBefore && trigger.isInsert;
    Boolean beforeUpdate = trigger.isBefore && trigger.isUpdate;

    if(beforeInsert || beforeUpdate){
        DnaTriggerHandler.atualizarDnaMedico(trigger.new, trigger.oldMap);
    }
}