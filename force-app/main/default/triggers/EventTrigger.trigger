trigger EventTrigger on Event(before insert, before update) {
    
	Boolean beforeInsert = Trigger.isBefore && Trigger.isInsert;
	Boolean beforeUpdate = Trigger.isBefore && Trigger.isUpdate;

	if (beforeInsert || beforeUpdate) {
		new EventTriggerHandler().atualizaEventoContato(Trigger.new, Trigger.oldMap);
	}
}