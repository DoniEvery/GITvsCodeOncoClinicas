public without sharing class DynamicPickListFectcher {

    @AuraEnabled(cacheable=true)
    public static List<String> getPickListLabels ( String objectApiName, String fieldApiName ) {
        List<String> labels = new List<String>();
        try {
            Schema.SObjectType obj_describe = Schema.getGlobalDescribe().get(objectApiName) ;
            Schema.DescribeSObjectResult obj_describe_result = obj_describe.getDescribe() ;
            Map<String,Schema.SObjectField> fields = obj_describe_result.fields.getMap() ;
            Schema.DescribeFieldResult fieldResult = fields.get(fieldApiName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple) {
                labels.add(pickListVal.getLabel());
            }
        } catch (Exception e) {
            System.debug('DynamicPickListFectcher.getPickListLabels errorMessage: ' + e.getMessage());
        }
        return labels;

    }
    @AuraEnabled
	public static List<String> getDependentPickListLabels(String objectApiName, String fieldApiName, String parentFieldValue){
      	Schema.SObjectType obj_describe = Schema.getGlobalDescribe().get(objectApiName) ;
      	Schema.DescribeSObjectResult obj_describe_result = obj_describe.getDescribe() ;
      	Map<String,Schema.SObjectField> fields = obj_describe_result.fields.getMap() ;
      	Schema.SObjectField dependentField = fields.get(fieldApiName);
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        Schema.DescribeFieldResult dependentFieldResult = dependentField.getDescribe();
        Schema.sObjectField controllerField = dependentFieldResult.getController();
        if(controllerField == null) return null;
        
        Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
        List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean ? null : controllerFieldResult.getPicklistValues());
         
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
         
        for (Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()){
            if (entry.isActive()){
                List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer i = 0; i < controllerValues.size(); i++){
                    Object controllerValue = (controllerValues == null ? (Object) (i == 1) : (Object) (controllerValues[i].isActive() ? controllerValues[i].getLabel() : null));
                    Integer bitIndex = i / 6;
                    Integer bitShift = 5 - Math.mod(i, 6 );
                    if(controllerValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0){
                        continue;
                    } 
                    if (!dependentPicklistValues.containsKey(controllerValue)){
                        dependentPicklistValues.put(controllerValue, new List<String>());
                    }
                    dependentPicklistValues.get(controllerValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues?.get(parentFieldValue);
    }
}