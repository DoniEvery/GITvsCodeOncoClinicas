@isTest
public  class BatchQuantificarEncontrosTest {
    @isTest
    public static void testarClasseParteUm(){

        User usuario = DataFactory.gerarUsuario();

        System.runAs(usuario) {
            Account paciente = DataFactory.gerarPaciente();
            paciente.CNPJ__c ='12405573024';
            INSERT paciente;

            Account hospital = DataFactory.gerarOrganizacao();
            INSERT hospital;

            Contact medico = DataFactory.gerarMedico(hospital.Id);
            medico.Tipo_de_Medico__c = 'Especialista Medico';
            INSERT medico;

            HealthCloudGA__EhrEncounter__c encontro = DataFactory.gerarEncontro(paciente.Id);
            encontro.HealthCloudGA__TypeLabel__c = 'Consulta';
            encontro.HealthCloudGA__PeriodStart__c = system.today();
            encontro.EPrimeiraConsulta__c = true;
            encontro.Identificador_Medico_Ref_Contact__c = medico.Id;
            encontro.Resumo_Procedimento_II__c = 'primeiro_atendimento';
            INSERT encontro;

            HealthCloudGA__EhrEncounter__c encontroTratamento = DataFactory.gerarEncontro(paciente.Id);
            encontroTratamento.HealthCloudGA__TypeLabel__c = 'Tratamento';
            encontroTratamento.HealthCloudGA__PeriodStart__c = system.today();
            encontroTratamento.EPrimeiraTratativa__c = true;
            encontroTratamento.Identificador_Medico_Ref_Contact__c = medico.Id;
            encontro.Resumo_Procedimento_II__c = 'primeira_RT';
            INSERT encontroTratamento;

            test.startTest();
            Database.executeBatch(new BatchQuantificarEncontros(system.today().year() - 1));
            test.stopTest();
        }
    }

    @isTest
    public static void testarClasseParteDois(){

        User usuario = DataFactory.gerarUsuario();

        System.runAs(usuario) {
            Account paciente = DataFactory.gerarPaciente();
            paciente.CNPJ__c ='12405573024';
            INSERT paciente;

            Account hospital = DataFactory.gerarOrganizacao();
            INSERT hospital;

            Contact medico = DataFactory.gerarMedico(hospital.Id);            
            medico.Tipo_de_Medico__c = 'Especialista Medico';
            INSERT medico;

            HealthCloudGA__EhrEncounter__c encontroTratamento = DataFactory.gerarEncontro(paciente.Id);
            encontroTratamento.HealthCloudGA__TypeLabel__c = 'Tratamento';
            encontroTratamento.HealthCloudGA__PeriodStart__c = system.today();
            encontroTratamento.EPrimeiraTratativa__c = true;
            encontroTratamento.Identificador_Medico_Ref_Contact__c = medico.Id;
            INSERT encontroTratamento;

            test.startTest();
            Database.executeBatch(new BatchQuantificarEncontros(system.today().year() - 1));
            test.stopTest();
        }
    }
}