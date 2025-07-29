public class encontroPacienteService {

    public static list<HealthCloudGA__EhrEncounter__c> getEncontros(String cpfPaciente){
        String pacienteId = [SELECT Id FROM Account WHERE CNPJ__c =: cpfPaciente].Id;
        return [SELECT Id,HealthCloudGA__ReasonLabel__c, HealthCloudGA__PeriodStart__c, Especialidade_que_atua_Corpo_Clinico__c, Resumo_Procedimento__c FROM HealthCloudGA__EhrEncounter__c WHERE HealthCloudGA__Account__c =: pacienteId ];
    }
    
    public static list<Case> getCasos(String cpfPaciente){
        String tipoRegistro = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Solicitacao_de_Cuidado').getRecordTypeId();
        return [SELECT Id,Procedimento__r.Name, Familia_do_Exame__c, Data_de_agendamento__c FROM Case WHERE Account.CNPJ__c =: cpfPaciente AND RecordTypeId =: tipoRegistro AND Status = 'Closed' AND ClosedDate > LAST_N_YEARS:5];
    }
}