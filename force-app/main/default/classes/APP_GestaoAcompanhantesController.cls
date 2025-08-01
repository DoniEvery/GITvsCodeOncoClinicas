public without sharing class APP_GestaoAcompanhantesController {

    @AuraEnabled(cacheable=true)
    public static APP_GestaoAcompanhantesService.AcompanhanteWrapper buscarAcompanhante(String documento) {
       
        return APP_GestaoAcompanhantesService.buscarAcompanhante(documento);
        
    }

    @AuraEnabled(cacheable=true)
    public static List<APP_JuncAcompanhante__c> listarAcompanhantes() {
       
        return APP_GestaoAcompanhantesService.listaAcompanhantes();
        
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean inativaAcompanhante(String idAcompanhante) {
       
        return APP_GestaoAcompanhantesService.inativaAcompanhante(idAcompanhante);
        
    }

    @AuraEnabled(cacheable=true)
    public static Boolean criaAcompanhante(String formDataJson) {
       
      return APP_GestaoAcompanhantesService.criaAcompanhante(formDataJson);
        
    }
}