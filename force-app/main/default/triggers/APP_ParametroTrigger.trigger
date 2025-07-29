trigger APP_ParametroTrigger on APP_Parametro__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            APP_ParametroTriggerHandler.validateUniqueChatRecord(Trigger.new, Trigger.oldMap);
        }
    }
}