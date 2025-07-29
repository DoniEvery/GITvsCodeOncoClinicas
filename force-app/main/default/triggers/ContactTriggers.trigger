trigger ContactTriggers on Contact (before insert, before update, after delete) {

    boolean beforeInsert = Trigger.isBefore && Trigger.isInsert;
    boolean beforeUpdate = Trigger.isBefore && Trigger.isUpdate;
    Boolean afterDelete = Trigger.isAfter && Trigger.isDelete;
    
    if(beforeInsert || beforeUpdate){
        ContactTriggersHandler.limparDNA(trigger.new, trigger.oldMap);
    }
    
    if(afterDelete){
        ContactTriggersHandler.impedirExclusaoContato(Trigger.old);
    }
}