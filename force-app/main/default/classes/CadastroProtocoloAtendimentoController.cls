public without sharing class CadastroProtocoloAtendimentoController 
{
    @AuraEnabled(cacheable=true)
    public static List<PickListValue> getPickListValuesOrigem(String recordTypeName){
        List<PickListValue> pickListValues = new List<PickListValue>();
        for(Schema.PickListEntry field : Case.Origem__c.getDescribe().getPickListValues()){
            if(recordTypeName == 'CasoAtendimentoPaciente' && ( 
                field.getLabel() == 'Callback' 
                || field.getLabel() == 'Clínica'
                || field.getLabel() == 'E-mail'
                || field.getLabel() == 'Telefonia'
                || field.getLabel() == 'WhatsApp')) {
                pickListValues.add(new PickListValue(field.getLabel(),field.getValue()));
            } else if(recordTypeName == null) {
                pickListValues.add(new PickListValue(field.getLabel(),field.getValue()));
            }
        }
        return pickListValues;
    }

    @AuraEnabled(cacheable=true)
    public static List<PickListValue> getPickListValuesMotivo(){
        List<PickListValue> pickListValues = new List<PickListValue>();
        for(Schema.PickListEntry field : Case.MotivoCaso__c.getDescribe().getPickListValues()){
            pickListValues.add(new PickListValue(field.getLabel(),field.getValue()));
        }
        return pickListValues;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<PickListValue> getPickListValuesMotivoNaoAgendamento(){
        List<PickListValue> pickListValues = new List<PickListValue>();
        for(Schema.PickListEntry field : Case.MotivoNaoAgendamento__c.getDescribe().getPickListValues()){
            pickListValues.add(new PickListValue(field.getLabel(),field.getValue()));
        }
        return pickListValues;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<PickListValue> getPickListValuesRazaoNaoAgendamento(){
        List<PickListValue> pickListValues = new List<PickListValue>();
        for(Schema.PickListEntry field : Case.RazaoNaoAgendamento__c.getDescribe().getPickListValues()){
            pickListValues.add(new PickListValue(field.getLabel(),field.getValue()));
        }
        return pickListValues; 
    }
    
    @AuraEnabled
    public static Case salvarCaso(String casoJson){
        Case response;
        System.debug(casoJson);
        try {
            response = CaseHelper.createCase((CaseHelper.CaseEntity) JSON.deserialize(casoJson, CaseHelper.CaseEntity.class), 'CasoAtendimentoPaciente');
        } catch (Exception e) {
            System.debug('Erro na execução: ' + e.getMessage());
            System.debug('Tipo: ' + e.getTypeName());
            System.debug('Stack trace string: ' + e.getStackTraceString());     
            throw new AuraHandledException(e.getMessage());
        } 
        return response;
    }

    @AuraEnabled(cacheable=false)
    public static Sobject salvarContato(String contatoJson, Boolean isNaoPaciente){
        Sobject response;
        System.debug(contatoJson);
        try {
            PacienteVO pacienteVO = (PacienteVO) JSON.deserialize(contatoJson, PacienteVO.class);
            response = (isNaoPaciente) ? PacienteHelper.criarNaoPaciente(pacienteVo) : PacienteHelper.criarPaciente(pacienteVo);
        } catch (Exception e) {
            String msgError = e.getMessage();
            System.debug('Erro na execução: ' + e.getMessage());
            System.debug('Tipo: ' + e.getTypeName());
            System.debug('Stack trace string: ' + e.getStackTraceString());
            if(e.getMessage().contains('DUPLICATE_VALUE') && e.getMessage().contains('HealthCloudGA__SourceSystemId__c ')){
                msgError = 'Paciente já cadastrado!';
            }
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                msgError = getMessageErrorField(e.getMessage());
            }
            throw new AuraHandledException(msgError);
        }        
        return response;
    }
     
    //getArticlesKnowledge
    @AuraEnabled(cacheable=true)
    public static ResultWrapper getArticlesKnowledge(String assunto, String motivo,String recordId){ 
        String knowledgeRecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get((string.isNotBlank(recordId)) ? 'ArtigoSolucaoDeCaso' :'ArtigoAberturaDeCaso').getRecordTypeId();   
        String PUBLISH_STATUS_ONLINE = 'Online';
        List<Knowledge__kav> lstArticles;
        List<WrapperArticle> lstArticlesWrapper = new List<WrapperArticle>();        
        system.debug(knowledgeRecordTypeId);
        try{
            Map<String, Object> acctBinds = new Map<String, Object>{
                'assuntoUnidade' => assunto, 'recordTypeId' => knowledgeRecordTypeId,
                'motivoAssuntoUnidade' => motivo,'status' => PUBLISH_STATUS_ONLINE
            };              
            String query = 'SELECT Id, Title, Summary, Question__c, Answer__c, PublishStatus, ArticleNumber, IsVisibleInCsp, AssuntoUnidade__c,  AssuntoUnidade__r.MotivoCaso__c FROM Knowledge__kav '; 
            String queryWhere = ' WHERE RecordTypeId != null ';              
       
            queryWhere += ' AND ( AssuntoUnidade__r.MotivoCaso__c = :motivoAssuntoUnidade )'; 
            queryWhere += ' AND ( AssuntoUnidade__c = :assuntoUnidade )';
            queryWhere += ' AND ( RecordTypeId = :recordTypeId ) ';
            queryWhere += ' AND ( PublishStatus = :status ) ';
       
            queryWhere += ' ORDER BY ArticleCreatedDate desc Limit 50';
            query += queryWhere;
            lstArticles =  Database.queryWithBinds(query, acctBinds, AccessLevel.USER_MODE);
            for(Knowledge__kav ar: lstArticles){
                lstArticlesWrapper.add(new WrapperArticle(ar));
            }
            system.debug(lstArticlesWrapper);
            return new ResultWrapper(lstArticlesWrapper.size(), lstArticlesWrapper);
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }            
    } 
        
    public class PickListValue{
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
        public PickListValue(string label,string value){
            this.label = label;
            this.value = value;
        }
    }    
      
    public class ResultWrapper{
        @AuraEnabled public Integer totalArticles;
        @AuraEnabled public List<WrapperArticle> lstArticles;
        public ResultWrapper(Integer totalArticles, List<WrapperArticle> lstArticles){
            this.totalArticles = totalArticles;
            this.lstArticles = lstArticles;
        }
    }     
    
    @AuraEnabled(cacheable=true)
    public static Account getAccountData(String idAccount){
        Account acc = new Account();
        try {
            acc = [Select id, PersonEmail, EmailMarketingMedico__pc, PersonMobilePhone,PersonHomePhone, CelularFormula__c from Account where id=:idAccount Limit 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()); 
        }
        return acc;
    }
    
    @AuraEnabled(cacheable=true)
    public static Lead getLeadData(String idLead){
        Lead l = new Lead();
        try {
            l = [Select id, Email, MobilePhone from Lead where id=:idLead Limit 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()); 
        }
        return l;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getAssuntosDetalhe(String idAssunto){
        List<String> idsReturn = new List<String>();
        List<AssuntoUnidade__c> assuntos = new List<AssuntoUnidade__c>();
        try {
            assuntos = [select Id, Assunto__c, AssuntoDetalhe__c, AssuntoDetalhe__r.AssuntoComparativo__c from AssuntoUnidade__c  where Assunto__c =: idAssunto];
            for(AssuntoUnidade__c ass: assuntos){
                idsReturn.add(ass.AssuntoDetalhe__c);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()); 
        }
        return idsReturn;
    }
    @AuraEnabled(cacheable=true)
    public static Case getCaseData(String idCase){
        Case c = new Case();
        try {
            c = [Select id, CaseNumber, MotivoCaso__c, AssuntoUnidade__c from Case where id=:idCase Limit 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()); 
        }
        return c;
    }
    public static string getMessageErrorField(string erro){
        return (erro.split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')[1]).split(':')[0];
    }
}