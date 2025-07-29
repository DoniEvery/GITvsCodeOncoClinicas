public with sharing class CaseHelper{
    public class CaseHelperException extends Exception {}
    public class CaseEntity{
        public Case caso ;
        public EspecialidadeMed__c especialidadeMedica ;
        public Lista_Plano_Convenios__c convenio ;
        public Boolean isNaoPaciente;
        public Lead lead ;
        public Account account ;
        public Account unidade ;
        public Contact medico;
        public AssuntoUnidade__c assuntoUnidade;
    }

    public static Case createCase(CaseEntity caseEntity, String recordTypeDeveloperName){
        String pacienteCaseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
        Case caso = caseEntity.caso;
        caso.AssuntoDetalhe__c = (caseEntity.assuntoUnidade.NomeDetalhe__c != null) ? caseEntity.assuntoUnidade.NomeDetalhe__c : null;
        caso.AssuntoUnidade__c = (caseEntity.assuntoUnidade?.Id != null) ? caseEntity.assuntoUnidade.Id : null;
        caso.Assunto__c	= (caseEntity.assuntoUnidade.Assunto__c != null) ? caseEntity.assuntoUnidade.Assunto__c : null;
        caso.BusinessHoursId = (caseEntity.assuntoUnidade.SLA__r.BusinessHoursId != null) ? caseEntity.assuntoUnidade.SLA__r.BusinessHoursId : null;
        caso.ContactId	= (caseEntity.account.PersonContactId != null) ? caseEntity.account.PersonContactId : null;
        caso.ConvenioNaoAtendido__c	= (caseEntity.convenio?.Id != null) ? caseEntity.convenio.Id : null;
        caso.ConvenioPaciente__c = (caseEntity.account.Convenio_Ultima_Consulta__c != null) ? caseEntity.account.Convenio_Ultima_Consulta__c : null;
        caso.EntitlementId	= (caseEntity.assuntoUnidade.SLA__c != null) ? caseEntity.assuntoUnidade.SLA__c : null;
        caso.EspecialidadeNaoAtendida__c = (caseEntity.especialidadeMedica?.Id != null) ? caseEntity.especialidadeMedica.Id : null;
        caso.Lead__c = (caseEntity.lead?.Id != null) ? caseEntity.lead.Id : null;
        caso.AccountId = (caseEntity.account?.Id != null) ? caseEntity.account.Id : null;
        caso.Nome_Medico__c	= (caseEntity.medico?.Id != null) ? caseEntity.medico.Id : null;
        caso.Priority	= (caseEntity.assuntoUnidade.Prioridade__c != null) ? caseEntity.assuntoUnidade.Prioridade__c : null;
        caso.RecordTypeId = pacienteCaseRecordType;
        caso.Subject = (caseEntity.assuntoUnidade.NomeAssuntoUnid__c != null) ? caseEntity.assuntoUnidade.NomeAssuntoUnid__c : null;
        caso.TipoAssunto__c = 'Assuntos por unidade';
        caso.Unidade__c	= (caseEntity.unidade?.Id != null) ? caseEntity.unidade.Id : null;
        caso.EmailAlternativo__c = (caso.EmailAlternativo__c != null) ? ((caso.EmailAlternativo__c)?.toLowerCase() == (caso.ContactEmail)?.toLowerCase()) ? '' : caso.EmailAlternativo__c : '';
        caso.EnvioProtocoloEmailAlternativo__c = (caso.EmailAlternativo__c != null) ? true : false;
        caso.ContadorEnvio__c = (caso.EmailAlternativo__c != null && caso.EnvioProtocoloEmailAlternativo__c == true) ? 1 : 0;
        caso.Caso_fechado__c = caseEntity.assuntoUnidade.Nasce_fechado__c;
        caso.ValidaFlow__c = 'cadastroProtocoloAtendimento';
        
        if(caseEntity.assuntoUnidade.Nasce_fechado__c == true) caso.Status = 'Closed';

        if(caseEntity.assuntoUnidade.FilaAtendimento__r.FilaAtendimento__c != null){
            caso.OwnerId = getGroupQueue(caseEntity.assuntoUnidade.FilaAtendimento__r.FilaAtendimento__c).Id;
        }
        insert caso;
        return caso;
    }
    private static Group getGroupQueue(String filaAtendimentoId){
        Group gr = new Group();
        List<Group> Groups = [
                                SELECT 
                                    id, 
                                    Type, 
                                    DeveloperName  
                                FROM Group 
                                WHERE 
                                    DeveloperName =: filaAtendimentoId 
                                    AND Type = 'Queue' Limit 1
                                ];
        if(Groups.size()>0){
            gr = Groups.get(0);
        }else{
            throw new CaseHelperException('Fila não encontrada!');
        }
        return gr;
    }
}