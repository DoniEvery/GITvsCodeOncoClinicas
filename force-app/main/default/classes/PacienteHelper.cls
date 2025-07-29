public with sharing class PacienteHelper {
	
    private static Account acc;
    
    public static SObject criarPaciente(PacienteVO pacienteVo)
    {
        String lastName = '';
        String pacienteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();      
        List<String> nameParts = pacienteVo.nomeCompleto.split(' ');
        acc = new Account();

        acc.FirstName = nameParts[0];
        acc.LastName = formatLastname(nameParts);
        acc.CNPJ__c = pacienteVo.CPF.replace('.','').replace('-','');
        acc.EUmPreCadastro__c = true;
        acc.PersonBirthdate = dateFromString(pacienteVo.dataNascimento); 
        acc.PersonEmail = pacienteVo.email;
        acc.PersonMobilePhone = pacienteVo.celular;
        acc.RecordTypeId = pacienteRecordTypeId;
        acc.Status_do_paciente__c = 'Pré-cadastro';  
        acc.IntegrarTasy__c = pacienteVo?.integrarTasy == null ? true : pacienteVo.integrarTasy;
        system.debug(acc);
        insert acc;
        system.debug(acc.Id);
        if (acc.IntegrarTasy__c)
        {
			integrarPacienteTasy(acc.Id);
        }
        
        return acc;
    }
      
    public static SObject criarNaoPaciente(PacienteVO pacienteVo)
    {
        String naoPacienteRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('NaoPaciente').getRecordTypeId(); 
        List<String> nameParts = pacienteVo.nomeCompleto.split(' ');
        Lead lead = new Lead();
        lead.HealthCloudGA__BirthDate__c = dateFromString(pacienteVo.dataNascimento); 
        lead.FirstName = nameParts[0];
        lead.LastName = formatLastname(nameParts);
        lead.Email = pacienteVo.email;
        lead.MobilePhone = pacienteVo.celular;
        lead.RecordTypeId = naoPacienteRecordTypeId;
        insert lead;
        
        return lead;        
    }
    
    @future
    public static void integrarPacienteTasy(String recordId)
    {
        acc = getPaciente(recordId);
        if (acc?.Id == null){
            IntegracaoTasyService.InserePacienteTasyRequest reqTasy = new IntegracaoTasyService.InserePacienteTasyRequest();
            reqTasy.accountId = acc.Id;
            reqTasy.cpf = acc.CNPJ__c;
            reqTasy.dataNascimento = acc.PersonBirthdate;
            reqTasy.email = acc.PersonEmail;
            reqTasy.nome = acc.FirstName;
            reqTasy.sobrenome = acc.LastName;        
            IntegracaoTasyService.inserePacienteTasy(new List<IntegracaoTasyService.InserePacienteTasyRequest>{reqTasy});           
        }

    }
    
    private static Account getPaciente(String accountId){
        return [SELECT Id, Name, PersonEmail, CNPJ__c, PersonBirthdate, FirstName, LastName  FROM Account WHERE Id =: accountId Limit 1];
    }    
    
    public static Date dateFromString(String dateString) 
    {
        Date parsedDate;
        try{
           parsedDate = Date.valueOf(dateString);
        }catch (Exception ex){
            return null;
        }
        return parsedDate;
    }    
    
    private static String formatLastname(List<String> parts)
    {
        String retorno = '';
        if (parts.size() >= 2)
        {
            for (integer ind=1; ind < parts.size(); ind++){
                retorno += parts[ind] + ' ';
            }            
        }          
        return retorno;
    }

}