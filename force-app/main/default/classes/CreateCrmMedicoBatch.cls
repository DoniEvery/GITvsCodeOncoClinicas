public class CreateCrmMedicoBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    String CORPO_CLINICO_RTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MedicoCorpoClinico').getRecordTypeId();
    String MEDICO_RTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();
    String CPF = null;

    public CreateCrmMedicoBatch(){}
    public CreateCrmMedicoBatch(String cpf){
        this.CPF = cpf;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String Query = 'SELECT Id,Recordtype.Name,CPF__c,CRM_UF__c,CRM__c,Codigo_Especialidade_CRM__c,Situacao_do_CRM__c,Tipo_Inscricao_CRM__c,UF_do_CRM__c FROM Contact WHERE (RecordtypeId = : MEDICO_RTYPE OR RecordtypeId = : CORPO_CLINICO_RTYPE) AND ';
        Query += (CPF != null) ? 'CPF__c =: CPF' : 'CPF__c != null';
        return Database.getQueryLocator(Query);
    }
    public void execute(Database.BatchableContext BC, List<Contact> scope){
        try{
            List<CRMMedico__c> CrmToInsert = new List<CRMMedico__c>();
            for(Contact ct : scope){
                System.debug(ct.CPF__c + '//'+ ct.Recordtype.Name);
                CrmToInsert.add(
                    new CRMMedico__c(
                        Name = (ct.CRM_UF__c != null) ? ct.CRM_UF__c : null,
                        CRM__c = (ct.CRM__c != null) ? ct.CRM__c : null,
                        CodigoEspecialidadeCRM__c = (ct.Codigo_Especialidade_CRM__c != null) ? ct.Codigo_Especialidade_CRM__c : null,
                        Medico__c = ct.Id,
                        SituacaoCRM__c = (ct.Situacao_do_CRM__c != null) ? ct.Situacao_do_CRM__c : null,
                        TipoInscricaoCRM__c = (ct.Tipo_Inscricao_CRM__c != null) ? ct.Tipo_Inscricao_CRM__c : null,
                        UF__c = (ct.UF_do_CRM__c != null) ? ct.UF_do_CRM__c : null
                    )
                );
            }
            if(CrmToInsert.size()>0){
                insert CrmToInsert;
            }
        }catch (Exception e) {
            System.debug('Erro na execução: ' + e.getMessage());
            System.debug('Tipo: ' + e.getTypeName());
            System.debug('Stack trace string: ' + e.getStackTraceString());  
        }
    }
    public void finish(Database.BatchableContext BC){
        //if(!Test.isRunningTest()) Database.executeBatch(new MergeContactBatch(),1);
    }
}