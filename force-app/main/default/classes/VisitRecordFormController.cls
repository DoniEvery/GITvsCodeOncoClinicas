public without sharing class VisitRecordFormController {
private static Id GRUPOUNIDADE_RTYPE = Schema.SObjectType.GruposUnidade__c.getRecordTypeInfosByDeveloperName().get('GruposMedicos').getRecordTypeId();
    @AuraEnabled(cacheable=true)
    public static List<String> getPickListLabels( String objectApiName, String fieldApiName ) {
        List<String> labels = new List<String>();
        labels = DynamicPickListFectcher.getPickListLabels ( objectApiName, fieldApiName );
        return labels;
    }
    
    @AuraEnabled
    public static List<String> getDependentPickListLabels( String objectApiName, String fieldApiName, String parentFieldValue ) {
        List<String> labels = new List<String>();
        labels = DynamicPickListFectcher.getDependentPickListLabels ( objectApiName, fieldApiName, parentFieldValue );
        return labels;
    }
    @AuraEnabled(cacheable=true)
    public static List<CustomObj> getMultiPickListContacts(){
        List<CustomObj> retorno = new List<CustomObj>();
        for(GruposUnidade__c gu : [Select Id,Name,(SELECT Id,Medico__c FROM Contatosdogrupo__r) FROM GruposUnidade__c WHERE CreatedById =: UserInfo.getUserId() AND RecordTypeId =: GRUPOUNIDADE_RTYPE]){
            List<String> ids = new List<String>();
            for(ContatoGrupo__c userGp : gu.Contatosdogrupo__r){
                ids.add(userGp.Medico__c);
            }
            retorno.add(new CustomObj(gu.Name,gu.Id,ids));
        }
        return retorno;
    }

    @AuraEnabled
    public static String save(String voJson) {

        try {
            EventVO vo = (EventVO) JSON.deserialize(voJson, EventVO.class);
            String response = EventHelper.createEvents(vo);
            return response;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class CustomObj{
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
        @AuraEnabled
        public List<string> contactIds;
        public CustomObj(string label,string value,List<string> contactIds){
            this.label = label;
            this.value = value;
            this.contactIds = contactIds;
        }
    }

}