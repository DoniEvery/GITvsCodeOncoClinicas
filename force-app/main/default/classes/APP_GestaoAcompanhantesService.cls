public class APP_GestaoAcompanhantesService {

    public static AcompanhanteWrapper buscarAcompanhante(String documento) {

        User usr = buscarPaciente();
        List<APP_JuncAcompanhante__c> acompanhantes = [SELECT Id, APP_Acompanhantes__c, APP_Acompanhantes__r.Name, APP_Acompanhantes__r.CNPJ__c, APP_Ativo__c  FROM APP_JuncAcompanhante__c WHERE  APP_Acompanhantes__c =: documento AND APP_MeuCadastroPaciente__c =: usr.AccountId];
        AcompanhanteWrapper juncao = new AcompanhanteWrapper();

        if (acompanhantes.isEmpty()) {
            return juncao;
        }else{

            for (APP_JuncAcompanhante__c acpts : acompanhantes) {
                juncao.idJuncao = acpts.APP_Acompanhantes__c;
                juncao.nome = acpts.APP_Acompanhantes__r.Name;
                juncao.cpf = acpts.APP_Acompanhantes__r.CNPJ__c;
                juncao.ativo = acpts.APP_Acompanhantes__r.APP_Ativo__c;
            }    

        }
        return juncao;
    }

    public static void inativaAcompanhante(String idAcompanhante) {

        try {
           update new APP_JuncAcompanhante__c(Id = idAcompanhante, APP_Ativo__c = true);
        } catch (Exception e) {
           
           throw new AuraHandledException(e.getMessage());
        }
         
    }      

    // public static void criaAcompanhante(StringString formDataJson) {
    //     Map<String, Object> formData = (Map<String, Object>) JSON.deserializeUntyped(formDataJson);

    //     try {
    //        update new APP_JuncAcompanhante__c(Id = idAcompanhante, APP_Ativo__c = true);
    //     } catch (Exception e) {
           
    //        throw new AuraHandledException(e.getMessage());
    //     }
         
    // }

    
    public static User buscarPaciente() {
        return [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1]; 
    }

    public static List<APP_JuncAcompanhante__c> listaAcompanhantes() {
        User usr = buscarPaciente();
        return [SELECT APP_Acompanhantes__r.Name, APP_Acompanhantes__r.CNPJ__c, APP_Acompanhantes__r.PersonMobilePhone, APP_Acompanhantes__r.PersonEmail  FROM APP_JuncAcompanhante__c WHERE APP_MeuCadastroPaciente__c =: usr.AccountId]; 
    }

    private static Id obterRecordTypePersonAccount() {
        return [SELECT Id FROM RecordType WHERE IsPersonType = True AND DeveloperName = 'Acompanhante' LIMIT 1].Id;
    } 


    public class AcompanhanteWrapper {     
        @InvocableVariable
        public String idJuncao;

        @InvocableVariable
        public String cpf;

        @InvocableVariable
        public String nome;

        @InvocableVariable
        public Boolean ativo;
    }
}