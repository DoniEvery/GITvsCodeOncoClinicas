trigger APP_UserTrigger on User (before insert, before update, after insert, after update) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        System.debug('Entrou na trigger');
        APP_UserHandler.atualizarFotoEmConta(Trigger.oldMap, Trigger.new);
    }
}