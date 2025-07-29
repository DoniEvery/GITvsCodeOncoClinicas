trigger App_JuncEspMedicoTrigger on App_JuncEspMedico__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            App_JuncEspMedicoHandler.preventDuplicates(Trigger.new);
        }
    }
}