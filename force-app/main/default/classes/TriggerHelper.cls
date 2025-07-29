public abstract class TriggerHelper {

    public Boolean isChanged(SObject pSObject, Set<String> psField) {
		Map<Id, SObject> tOldMap = Trigger.oldMap;

		for (String field : psField) {
			SObject sObjectOld = Trigger.isUpdate ? tOldMap.get(pSObject.Id) : null;

			if (pSObject != null && (Trigger.isInsert || (Trigger.isUpdate && sObjectOld != null && pSObject.get(field) != sObjectOld.get(field)))) {
				return true;
			}
		}

		return false;
	}
}