public with sharing class TabelaAgendamentosController {

    @AuraEnabled
    public static String getDadosAgendaMedica(String filtrosMedico, String filtroUnidade, String filtroEspecialidade){

        String query = 'SELECT Id, Name, ID__c, Profissional__r.Name, Especialidade__r.Name, Subespecialidade__c, ObservacoesHorariosAtendimentos__c, Unidade__c, Unidade__r.Name, AceitaEncaixe__c, RestricaoIndicacaoMedica__c, IdadeMinima__c, Sexo__c '; 
        query += ', (SELECT Lista_Plano_de_Convenio__r.Name, Lista_Plano_de_Convenio__r.Id_do_Convenio__r.Name FROM ConveniosAgendas__r)'; 
        query += ', (SELECT Diagnostico__r.Name FROM DiagnosticosNaoAtendidos__r) ';
        query += 'FROM AgendaMedica__c WHERE ';
        if(!String.isBlank(filtrosMedico)) query += 'Profissional__c = :filtrosMedico';
        if(!String.isBlank(filtroUnidade)) query += ( !String.isBlank(filtrosMedico) ? ' AND ' : '') + 'Unidade__c = :filtroUnidade';
        if(!String.isBlank(filtroEspecialidade)) query += ( !String.isBlank(filtrosMedico) || !String.isBlank(filtroUnidade) ? ' AND ' : '') +  'Especialidade__c = :filtroEspecialidade';

        List<AgendaMedica__c> listaAgendas = Database.query(query);
        List<AgendaMedica> listaAgendaTabela = new List<AgendaMedica>();

        if(!listaAgendas.isEmpty()){
            for(AgendaMedica__c ag : listaAgendas){
                AgendaMedica agenda = new AgendaMedica();
                agenda.agendaMedicaId = ag.Id;
                agenda.agendaMedicaLabel = ag.ID__c;
                agenda.profissional = ag.Profissional__r.Name;
                agenda.especialidade = ag.Especialidade__r.Name;
                agenda.subespecialidade = ag.Subespecialidade__c;
                agenda.unidade = ag.Unidade__r.Name;
                agenda.idade = ag.IdadeMinima__c;
                agenda.sexo = ag.Sexo__c;
                agenda.horarioAt = ag.ObservacoesHorariosAtendimentos__c;
                agenda.encaixe = (ag.AceitaEncaixe__c ? 'Sim' : 'Não');
                listaAgendaTabela.add(agenda);
                agenda.listaConvenios = new List<String>();
                agenda.listaDiag = new List<String>();

                for(ConveniosAgenda__c conv : ag.ConveniosAgendas__r){
                    agenda.listaConvenios.add(conv.Lista_Plano_de_Convenio__r.Id_do_Convenio__r.Name + ' | ' + conv.Lista_Plano_de_Convenio__r.Name);
                }

                for(DiagnosticoNaoAtendido__c diag : ag.DiagnosticosNaoAtendidos__r){
                    agenda.listaDiag.add(diag.Diagnostico__r.Name);
                }

            }
        }
        
        if(!listaAgendaTabela.isEmpty()) return JSON.serialize(listaAgendaTabela);
        else return null;
    }

    public class AgendaMedica{
        @AuraEnabled public String agendaMedicaId;
        @AuraEnabled public String agendaMedicaLabel;
        @AuraEnabled public String profissional;
        @AuraEnabled public String especialidade;
        @AuraEnabled public String subespecialidade;
        @AuraEnabled public String unidade;
        @AuraEnabled public decimal idade;
        @AuraEnabled public String sexo;
        @AuraEnabled public String horarioAt;
        @AuraEnabled public String encaixe;
        @AuraEnabled public List<String> listaConvenios;
        @AuraEnabled public List<String> listaDiag;
    }
}