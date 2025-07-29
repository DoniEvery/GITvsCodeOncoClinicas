public with sharing class CustomLookupController {

    @AuraEnabled(cacheable=true)
    public static list<CustomObject> searchLookupData(string searchKey,string strObj,string parentChild){//,string recordId) {  
        List <CustomObject> returnList = new List <CustomObject>();
        if(string.isNotBlank(searchKey) || parentChild == 'Parent'){
            try{
                LookupAtributos lookupAtributos = (LookupAtributos) JSON.deserialize(strObj,LookupAtributos.class);
                string sWildCardText = '%' + searchKey + '%';
                string sQuery = 'SELECT Id';
                string condQuery = '';
                if(String.isNotBlank(lookupAtributos.field1) && lookupAtributos.field1.toLowerCase() != 'id') sQuery+= ', '+lookupAtributos.field1;
                if(String.isNotBlank(lookupAtributos.field2) && lookupAtributos.field1.toLowerCase() != 'id') sQuery+= ', '+lookupAtributos.field2;
                if(String.isNotBlank(lookupAtributos.field3) && lookupAtributos.field1.toLowerCase() != 'id') sQuery+= ', '+lookupAtributos.field3;
                if(String.isNotBlank(lookupAtributos.recordTypeId)){
                    string recordTypeId = lookupAtributos.recordTypeId;
                    condQuery+= ' AND recordTypeId =: recordTypeId';
                }
                if(String.isNotBlank(lookupAtributos.fieldfilter) &&  String.isNotBlank(lookupAtributos.valuefilter)){
                    string valuefilter = lookupAtributos.valuefilter;
                    condQuery+= ' AND '+lookupAtributos.fieldfilter+' =: valuefilter';  
                }
                if(String.isNotBlank(lookupAtributos.fieldfilterParent) &&  String.isNotBlank(lookupAtributos.fieldfilterParentValue)){
                    string valuefilterParent = lookupAtributos.fieldfilterParentValue;
                    condQuery+= ' AND '+lookupAtributos.fieldfilterParent+' =: valuefilterParent';  
                }
            /*  if(String.isNotBlank(recordId)){
                    string strRecordId = recordId;
                    condQuery+= ' AND Id =: strRecordId';  
                }*/
                
                sQuery+= ' FROM ' + lookupAtributos.sObjectApiName + ' WHERE '+ lookupAtributos.field1 +' Like : sWildCardText'+condQuery + ' LIMIT 49000';

                System.debug(sQuery);

                for (sObject obj: database.query(sQuery)) {
                    CustomObject customObj = new CustomObject();
                    customObj.Id = obj.id;
                    customObj.Name = string.valueOf(obj.get(string.valueOf(lookupAtributos.field1)));
                    if(String.isNotBlank(lookupAtributos.field1) && string.valueOf(obj.get(string.valueOf(lookupAtributos.field1))) != null) customObj.field1 = string.valueOf(obj.get(string.valueOf(lookupAtributos.field1)));
                    if(String.isNotBlank(lookupAtributos.field2) && string.valueOf(obj.get(string.valueOf(lookupAtributos.field2))) != null) customObj.field2 = string.valueOf(obj.get(string.valueOf(lookupAtributos.field2)));
                    if(String.isNotBlank(lookupAtributos.field3) && string.valueOf(obj.get(string.valueOf(lookupAtributos.field3))) != null) customObj.field3 = string.valueOf(obj.get(string.valueOf(lookupAtributos.field3)));
                    returnList.add(customObj);
                    system.debug(returnList);
                }
            }catch(Exception e ){
                System.debug('Erro na execução: ' + e.getMessage());
                System.debug('Tipo: ' + e.getTypeName());
                System.debug('Stack trace string: ' + e.getStackTraceString());

                if(e.getMessage().contains('No such column')){
                    throw new CustomLookupControllerException(e.getMessage().split('. If')[0]);
                }
            }
        }
        return returnList;
    }
     
    // Metodo para  lookup default value 
    @AuraEnabled
    public static sObject searchDefaultRecord(string recordId , string sObjectApiName) { 
        string sRecId =  recordId;

        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
    public class CustomObject{
        @auraEnabled
        public string Id;
        @auraEnabled
        public string Name;
        @auraEnabled
        public string field1;
        @auraEnabled
        public string field2;
        @auraEnabled
        public string field3;
        public CustomObject(){}
    }

    public class LookupAtributos{
        @auraEnabled
        public string sObjectApiName; 
        @auraEnabled
        public string recordTypeId;
        @auraEnabled
        public string field1;
        @auraEnabled
        public string field2;
        @auraEnabled
        public string field3;
        @auraEnabled
        public string fieldfilter;
        @auraEnabled
        public string valuefilter;
        @auraEnabled
        public string fieldfilterParent;
        @auraEnabled
        public string fieldfilterParentValue;
    }
    public class CustomLookupControllerException extends Exception{}
}