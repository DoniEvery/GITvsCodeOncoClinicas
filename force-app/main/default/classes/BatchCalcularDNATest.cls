@isTest
public class BatchCalcularDNATest {
    @isTest
    public static void testarClasseParteUm(){

        User usuario = DataFactory.gerarUsuario();

        System.runAs(usuario) {
            List<Dna__c> listaDnas = new List<Dna__C>();

            Account hospital = DataFactory.gerarOrganizacao();
            INSERT hospital;

            Contact medico = DataFactory.gerarMedico(hospital.Id);
            medico.Tipo_de_Medico__c = 'Especialista Medico';
            INSERT medico;

            Dna__c dnaAno3 = DataFactory.gerarDna(system.today().year() - 3, medico.Id);
            listaDnas.add(dnaAno3);
            Dna__c dnaAno2 = DataFactory.gerarDna(system.today().year() - 2, medico.Id);
            listaDnas.add(dnaAno2);
            Dna__c dnaAno1 = DataFactory.gerarDna(system.today().year() - 1, medico.Id);
            listaDnas.add(dnaAno1);
            Dna__c dnaAnoAtual = DataFactory.gerarDna(system.today().year(), medico.Id);
            listaDnas.add(dnaAnoAtual);

            INSERT listaDnas;

            test.startTest();
            Database.executeBatch(new BatchCalcularDNA(system.today().year() - 1));
            test.stopTest();
        }
    }
}