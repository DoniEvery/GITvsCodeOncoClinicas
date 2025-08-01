public without sharing class APP_GestaoAcompanhantesService {

    public static Boolean response = true;

    public static AcompanhanteWrapper buscarAcompanhante(String documento) {

        User usr = buscarPaciente();
        System.debug('usr '+usr);
        System.debug('documento '+documento);
        List<APP_JuncAcompanhante__c> acompanhantes = [SELECT Id, APP_Acompanhantes__c, APP_Acompanhantes__r.Name, APP_Acompanhantes__r.CNPJ__c, APP_Ativo__c  FROM APP_JuncAcompanhante__c WHERE  APP_Acompanhantes__r.CNPJ__c =: documento AND APP_Paciente__c =: usr.Contact.AccountId];
        AcompanhanteWrapper juncao = new AcompanhanteWrapper();

        if (acompanhantes.isEmpty()) {
            return juncao;
        }else{

            for (APP_JuncAcompanhante__c acpts : acompanhantes) {
                juncao.idJuncao = acpts.APP_Acompanhantes__c;
                juncao.nome = acpts.APP_Acompanhantes__r.Name;
                juncao.cpf = acpts.APP_Acompanhantes__r.CNPJ__c;
                juncao.ativo = acpts.APP_Ativo__c;
            }    

        }
        return juncao;
    }

    public static Boolean inativaAcompanhante(String idAcompanhante) {

        try {
           update new APP_JuncAcompanhante__c(Id = idAcompanhante, APP_Ativo__c = true);
        } catch (Exception e) {
            response = false;
           throw new AuraHandledException(e.getMessage());
        }
         return response;
    }      

    public static Boolean criaAcompanhante(String formDataJson) {
        Map<String, Object> formData = (Map<String, Object>) JSON.deserializeUntyped(formDataJson);

        Account personAcc = new Account(
                RecordTypeId = obterRecordTypePersonAccount(),
                LastName =   String.valueOf(formData.get('nome')),
                CNPJ__c = String.valueOf(formData.get('cnpj')),
                Phone = String.valueOf(formData.get('telefone')),
                PersonEmail = String.valueOf(formData.get('email'))
        );
      
        // try {
            insert personAcc;

            User usr = buscarPaciente();
            APP_JuncAcompanhante__c accompanhante = new APP_JuncAcompanhante__c(APP_Acompanhantes__c = personAcc.Id, APP_Paciente__c = usr.Contact.AccountId, APP_Ativo__c = true);
                
            insert accompanhante;

            createCommunityUserAsync(personAcc.Id);
            
        // } catch (Exception e) {
        //     response = false;           
        //    throw new AuraHandledException(e.getMessage()+ '');
        // }
         return response;
    }

    
    public static User buscarPaciente() {
        return [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1]; 
    }

    public static List<APP_JuncAcompanhante__c> listaAcompanhantes() {
        User usr = buscarPaciente();
        return [SELECT APP_Acompanhantes__r.Name, APP_Acompanhantes__r.CNPJ__c, APP_Acompanhantes__r.PersonMobilePhone, APP_Acompanhantes__r.PersonEmail  FROM APP_JuncAcompanhante__c WHERE APP_Paciente__c =: usr.Contact.AccountId]; 
    }

    private static Id obterRecordTypePersonAccount() {
        return [SELECT Id FROM RecordType WHERE IsPersonType = True AND DeveloperName = 'Acompanhante' LIMIT 1].Id;
    } 

    @future
    private static void createCommunityUserAsync(Id accountId) {

        APP_LoginController.newUser(accountId, 'Acompanhante');   
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