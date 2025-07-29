@isTest
public with sharing class TabelaAgendamentosControllerTest {

    @TestSetup
    static void makeData(){

        Account convenio = DataFactory.gerarConvenio();
        insert convenio;

        Lista_Plano_Convenios__c listaConv = DataFactory.gerarListaConvenio(convenio.Id);
        insert listaConv;

        Diagnostico__c diag = DataFactory.gerarDiagnostico();
        insert diag;

        Account unidade = DataFactory.gerarUnidadeAtendimento();
        insert unidade;

        Contact medico = DataFactory.gerarMedico(unidade.Id);
        insert medico;
        
        Contact medico2 = DataFactory.gerarMedico(unidade.Id);
        medico2.LastName = 'Alberto';
        insert medico2;  

        EspecialidadeMed__c espec = DataFactory.gerarEspecialidade();
        insert espec;

        AgendaMedica__c agenda = DataFactory.gerarAgendaMedica(medico.Id, espec.Id, unidade.Id);
        insert agenda;

        ConveniosAgenda__c convenioAgenda = DataFactory.gerarConveniosAgenda(listaConv.Id, agenda.Id);
        insert convenioAgenda;

        DiagnosticoNaoAtendido__c diagnosticoNaoAtendido = DataFactory.gerarDiagnosticosAgenda(diag.Id, agenda.Id);
        insert diagnosticoNaoAtendido;
    }

    @isTest
    public static void getDadosAgendaMedicaTest(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        String teste = TabelaAgendamentosController.getDadosAgendaMedica(con.Id, null, null);

        System.assertEquals(true, !String.isBlank(teste));
    }

    @isTest
    public static void getDadosAgendaMedicaVaziaTest(){
        Contact con = [SELECT Id FROM Contact Where LastName = 'Alberto' LIMIT 1];

        String teste = TabelaAgendamentosController.getDadosAgendaMedica(con.Id, null, null);

        System.assertEquals(true, String.isBlank(teste));
    }


}