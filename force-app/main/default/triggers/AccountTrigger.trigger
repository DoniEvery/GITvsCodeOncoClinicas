trigger AccountTrigger on Account (before update, after delete,before insert,after update,after insert) {

    Boolean afterDelete = Trigger.isAfter && Trigger.isDelete;
    Boolean beforeUpdate = Trigger.isBefore && Trigger.isUpdate;
    Boolean beforeInsert = Trigger.isBefore && Trigger.isInsert;
    Boolean afterUpdate = Trigger.isAfter && Trigger.isUpdate;
    Boolean afterInsert = Trigger.isAfter && Trigger.isInsert;

    if(beforeUpdate){
        AccountTriggerHandler.integraContatos(Trigger.new);
        AccountTriggerHandler.formatPersonMobilePhone(Trigger.new);
        
    }
    
    if(afterDelete){
        AccountTriggerHandler.impedirExclusaoConta(Trigger.old);
    }

    if (beforeInsert) {
            AccountTriggerHandler.formatPersonMobilePhone(Trigger.new);
        }

    }