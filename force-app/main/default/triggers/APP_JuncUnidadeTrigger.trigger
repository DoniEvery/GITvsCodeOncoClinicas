trigger APP_JuncUnidadeTrigger on APP_JuncUnidade__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            APP_JuncUnidadeHandler.preventDuplicates(Trigger.new);
        }
    }
}