@isTest
public  class DnaTriggerTest {

    @isTest
    public static void testarClasse(){
        User usuario = DataFactory.gerarUsuario();

        System.runAs(usuario) {
            Account hospital = DataFactory.gerarOrganizacao();
            INSERT hospital;

            Contact medico = DataFactory.gerarMedico(hospital.Id);
            medico.Tipo_de_Medico__c = 'Especialista Medico';
            INSERT medico;

            test.startTest();
            List<Dna__c> listaDnas = new List<Dna__c>();
            Dna__c dnaAnoAnterior = DataFactory.gerarDna(system.today().year() - 1, medico.Id);
            dnaAnoAnterior.Dna__c = 'Somente Consulta';
            listaDnas.add(dnaAnoAnterior);
            
            Dna__c dna = DataFactory.gerarDna(system.today().year(), medico.Id);
            dna.Dna__c = 'Conquista';
            listaDnas.add(dna);
            
            INSERT listaDnas;

            Contact medicoAtt = [SELECT Id, dna__c, DnaAnoAnteriorCompleto__c FROM Contact LIMIT 1];

            system.assertEquals('Conquista', medicoAtt.dna__c);
            system.assertEquals('Somente Consulta', medicoAtt.DnaAnoAnteriorCompleto__c);

            dna.Dna__c = 'Reconquista';
            UPDATE dna;
            
            dnaAnoAnterior.Dna__c = 'Deixou de Encaminhar';
            UPDATE dnaAnoAnterior;

            medicoAtt = [SELECT Id, dna__c, DnaAnoAnteriorCompleto__c FROM Contact LIMIT 1];

            system.assertEquals('Reconquista', medicoAtt.dna__c);
            system.assertEquals('Deixou de Encaminhar', medicoAtt.DnaAnoAnteriorCompleto__c);
            test.stopTest();
        }
    }
}