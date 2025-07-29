public class EnviarNotificacaoEntity 
{
    public class Request{
        @AuraEnabled public String cpf;
        @AuraEnabled public String topicId;
        @AuraEnabled public String fullText;
        @AuraEnabled public String notificationText;
    }
    
    public class Retorno{
        //@AuraEnabled public String status;
        //@AuraEnabled public Reason reason;        
        @AuraEnabled public Integer statusCode;
        @AuraEnabled public String bodyResponse;
    }
    
    public class Reason{
        @AuraEnabled public String code;
        @AuraEnabled public String description;
    }
}