trigger CaseTrigger on Case (before update, after insert, after update) {

    boolean beforeUpdate = Trigger.isBefore && Trigger.isUpdate;
    boolean afterInsert = Trigger.isAfter && Trigger.isInsert;
    boolean afterUpdate = Trigger.isAfter && Trigger.isUpdate;

    if(beforeUpdate)  {
        new CaseTriggerHandler().checkStatusCase(Trigger.new);
    }

    if(afterInsert || afterUpdate){
        CaseTriggerHandler.enviaEmailAlternativoMKT(Trigger.new, Trigger.oldMap);
    }

}