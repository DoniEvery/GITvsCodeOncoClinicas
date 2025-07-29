public class VerificarTelefoneEntity {
    public class Telefone{
        @AuraEnabled public String id;
        @AuraEnabled public String to;
        @AuraEnabled public String method;
        @AuraEnabled public String uri;
    }
    public class Retorno{
        @AuraEnabled public String status;
        @AuraEnabled public Reason reason;
        
    }
    public class Reason{
        @AuraEnabled public String code;
        @AuraEnabled public String description;
        
    }
    ///////Atributos de envio de mensagem
    public class EnvioMensagem{
        @AuraEnabled public String id;
        @AuraEnabled public String to;
        @AuraEnabled public String type = 'application/json';
        @AuraEnabled public Content content;
    }
    public class Content{
        @AuraEnabled public String type = 'template';
        @AuraEnabled public Template template;
    }
    public class Template{
        @AuraEnabled public String namespace = '8cd8ec1c_60df_ce96_3eef_ec7d6763adc0';
        @AuraEnabled public String name = 'modelo_pesquisa_copia';
        @AuraEnabled public Language language;
        @AuraEnabled public List<Components> components;
    }
    public class Language{
        @AuraEnabled public String code = 'pt_BR';
        @AuraEnabled public String policy = 'deterministic';
    }
    public class Components{
        @AuraEnabled public String type = 'button';
        @AuraEnabled public String sub_type = 'url';
        @AuraEnabled public Integer index = 0;
        @AuraEnabled public List<Parameters> parameters;
    }
    public class Parameters{
        @AuraEnabled public String type = 'text';
        @AuraEnabled public String text;
    }

}