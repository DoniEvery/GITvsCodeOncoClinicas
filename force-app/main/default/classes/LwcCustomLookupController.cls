public with sharing class LwcCustomLookupController {

    @AuraEnabled(cacheable=true)
    public static List<sObject> searchLookupData(String searchKey , String sObjectApiName, String recordId, List<String> fieldsWhereQuery, List<String> fieldsReturnQuery, String condition,Boolean isMap,string fieldCustomNameToShow,string fildFilterMap) {    
        List<sObject> returnList = new List<sObject>();
        //String sWildCardText = '%' + searchKey + '%';
        String sWildCardText = (removerAcentos(searchKey) + '%').replace(' ','%');
        system.debug('sObjectApiName :' + sObjectApiName);
        system.debug('fieldCustomNameToShow :' + fieldCustomNameToShow);
        system.debug('sWildCardText :' + sWildCardText);

        
        String sQuery = 'SELECT Id,Name';
        String condQuery = '';

        for(String field : fieldsReturnQuery) sQuery+= ', '+field;

        for(String field : fieldsWhereQuery){
            condQuery+= ' OR '+field+' Like : sWildCardText';
        }
        
        condQuery = fieldsWhereQuery.size() > 0 ? condQuery + ') ' : condQuery ;

        if(String.isNotBlank(condition)) condQuery+= ' AND '+condition;

        if(sObjectApiName == 'Account' || sObjectApiName == 'Lead'){
        	sQuery+= ' FROM ' + sObjectApiName + (fieldsWhereQuery.size() > 0 ? ' WHERE ( Name_Clear__c' : ' WHERE Name_Clear__c' ) + ' Like : sWildCardText' + condQuery + ' ORDER BY Name ASC LIMIT 10';
        } else if(sObjectApiName == 'AssuntoUnidade__c') { 
            sQuery += ' FROM ' + sObjectApiName + (fieldsWhereQuery.size() > 0 ? ' WHERE (Name' : ' WHERE Name') + ' LIKE :sWildCardText' + condQuery + ' ORDER BY Assunto__r.Name ASC';
        }else{
        	sQuery+= ' FROM ' + sObjectApiName + (fieldsWhereQuery.size() > 0 ? ' WHERE ( Name' : ' WHERE Name' ) + ' Like : sWildCardText' + condQuery + ' ORDER BY Name ASC LIMIT 10';        
        }


        System.debug(sQuery);
        returnList = database.query(sQuery);

        if(isMap == true){
            Map<String,sObject> objFilterNameMap = new Map<String,sObject>();
            for (sObject obj: returnList){
                if(obj.get(fildFilterMap) != null && objFilterNameMap.containsKey((obj.get(fieldCustomNameToShow)).toString())){
                    objFilterNameMap.put((obj.get(fieldCustomNameToShow)).toString(),obj);
                }else if(!objFilterNameMap.containsKey((obj.get(fieldCustomNameToShow)).toString())){
                    objFilterNameMap.put((obj.get(fieldCustomNameToShow)).toString(),obj);
                }
            }
            if(objFilterNameMap.size()>0){
                returnList = objFilterNameMap.values();
            }
        }
        return returnList;
    }
    public static String removerAcentos(String especialChar) {
        especialChar = especialChar.toLowerCase();
        especialChar = especialChar.replaceAll('á', 'a');
        especialChar = especialChar.replaceAll('à', 'a');
        especialChar = especialChar.replaceAll('ã', 'a');
        especialChar = especialChar.replaceAll('â', 'a');
        especialChar = especialChar.replaceAll('ä', 'a');
        especialChar = especialChar.replaceAll('é', 'e');
        especialChar = especialChar.replaceAll('è', 'e');
        especialChar = especialChar.replaceAll('ê', 'e');
        especialChar = especialChar.replaceAll('ë', 'e');
        especialChar = especialChar.replaceAll('í', 'i');
        especialChar = especialChar.replaceAll('ì', 'i');
        especialChar = especialChar.replaceAll('î', 'i');
        especialChar = especialChar.replaceAll('ï', 'i');
        especialChar = especialChar.replaceAll('ó', 'o');
        especialChar = especialChar.replaceAll('ò', 'o');
        especialChar = especialChar.replaceAll('õ', 'o');
        especialChar = especialChar.replaceAll('ô', 'o');
        especialChar = especialChar.replaceAll('ö', 'o');
        especialChar = especialChar.replaceAll('ú', 'u');
        especialChar = especialChar.replaceAll('ù', 'u');
        especialChar = especialChar.replaceAll('û', 'u');
        especialChar = especialChar.replaceAll('ü', 'u');
        especialChar = especialChar.replaceAll('ç', 'c');
        return especialChar;
    }
    // Metodo para  lookup default value 
    @AuraEnabled
    public static sObject searchDefaultRecord(string recordId , string sObjectApiName) { 
        string sRecId =  recordId;

        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        
        for (sObject obj: database.query(sQuery)) return obj;

        return null;
    }
}