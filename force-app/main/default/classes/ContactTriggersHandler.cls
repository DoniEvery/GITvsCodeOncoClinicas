public class ContactTriggersHandler {
    
    public static void limparDNA(List<Contact> listaTriggerNew, Map<Id, Contact> mapaTriggerOld){
        String tipoRegistroMedico = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();
        
        Set<String> setEspecialidades = new Set<String>();
        for(Especialidade__mdt especialidade :[SELECT Id, label FROM Especialidade__mdt]){
            setEspecialidades.add(especialidade.label);
        }
        
        if(Trigger.isInsert){
            for(Contact medico :listaTriggerNew){
                if(medico.recordTypeId == tipoRegistroMedico && medico.Tipo_de_Medico__c == 'Corpo Clinico - Clinicas' 
                   && setEspecialidades.contains(medico.Especialidade_que_Atua__c)){
                       medico.DNA__c = null;
                       medico.DNAAnoAnterior__c = null;
                       medico.DnaAnoAnteriorCompleto__c = null;
                   }
            }
        }else{
            for(Contact medico :listaTriggerNew){
                if(medico.recordTypeId == tipoRegistroMedico && medico.Tipo_de_Medico__c == 'Corpo Clinico - Clinicas' 
                   && setEspecialidades.contains(medico.Especialidade_que_Atua__c)){
                       medico.DNA__c = null;
                       medico.DNAAnoAnterior__c = null;
                       medico.DnaAnoAnteriorCompleto__c = null;
                   }
            }
        }
    }
    
    public static void impedirExclusaoContato(List<Contact> lstContact){
        Map<String, Bloqueio_Perfil_Exclusao_Conta_Contato__mdt> mapPerfisBloqueio = Bloqueio_Perfil_Exclusao_Conta_Contato__mdt.getAll();
        Profile perfil = [SELECT Id, Name, PermissionsModifyAllData FROM Profile WHERE Id =: UserInfo.getProfileId()];
        if (perfil.PermissionsModifyAllData == false) {
            for(Contact contato : lstContact){
                if(mapPerfisBloqueio.containsKey(perfil.name) && contato.MasterRecordId == null) contato.addError('Você não tem permissão para excluir este contato.');
            }
        }    
    }
}