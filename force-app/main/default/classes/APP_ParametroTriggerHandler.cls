public class APP_ParametroTriggerHandler {
    
    public static void validateUniqueChatRecord(List<APP_Parametro__c> newList, Map<Id, APP_Parametro__c> oldMap) {
        
        Set<Id> recordTypeIds = new Set<Id>();
        for (APP_Parametro__c param : newList) {
            if (param.RecordTypeId != null) {
                recordTypeIds.add(param.RecordTypeId);
            }
        }

        Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>(
            [SELECT Id, DeveloperName FROM RecordType WHERE Id IN :recordTypeIds AND SObjectType = 'APP_Parametro__c']
        );

        // Conta registros existentes do tipo Chat e Agenda
        Map<String, Integer> existingCountMap = new Map<String, Integer>();
        for (AggregateResult ar : [
            SELECT RecordType.DeveloperName devName, COUNT(Id) qtd
            FROM APP_Parametro__c
            WHERE RecordType.DeveloperName IN ('Chat', 'Agenda')
            GROUP BY RecordType.DeveloperName
        ]) {
            existingCountMap.put((String)ar.get('devName'), (Integer)ar.get('qtd'));
        }

        for (APP_Parametro__c param : newList) {
            
            String devName = recordTypeMap.get(param.RecordTypeId)?.DeveloperName;

            if (String.isBlank(devName)) continue;

            // Verificação para Chat
            if (devName == 'Chat') {
                Boolean isCreatingNew = param.Id == null;
                Boolean isChangingToChat = oldMap == null || oldMap.get(param.Id)?.RecordTypeId != param.RecordTypeId;

                if (existingCountMap.get('Chat') > 0 && (isCreatingNew || isChangingToChat)) {
                    param.addError('Já existe um registro do tipo Chat. Apenas um registro desse tipo é permitido.');
                }
            }

            // Verificação para Agenda
            if (devName == 'Agenda') {
                Boolean isCreatingNew = param.Id == null;
                Boolean isChangingToAgenda = oldMap == null || oldMap.get(param.Id)?.RecordTypeId != param.RecordTypeId;

                if (existingCountMap.get('Agenda') > 0 && (isCreatingNew || isChangingToAgenda)) {
                    param.addError('Já existe um registro do tipo Agenda. Apenas um registro desse tipo é permitido.');
                }
            }
        }
    }
}