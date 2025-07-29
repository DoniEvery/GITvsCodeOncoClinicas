trigger APP_JuncAcompanhanteTrigger on APP_JuncAcompanhante__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            APP_JuncAcompanhanteHandler.preventDuplicates(Trigger.new);
        }
    }
}