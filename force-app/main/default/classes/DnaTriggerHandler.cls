public class DnaTriggerHandler {

    public static void atualizarDnaMedico(list<Dna__c> listaTriggerNew, Map<Id, DNA__c> mapaTriggerOld){
        Map<String, Contact> mapaMedicos = new Map<String, Contact>();

        if(Trigger.isInsert){
            for(Dna__c dna : listaTriggerNew) {
                Contact medico;
                if(mapaMedicos.containsKey(dna.Medico__c)) medico = mapaMedicos.get(dna.Medico__c);
                else medico = new Contact();
                
                if (dna.Ano__c == System.today().year()) {
                    medico.Id = dna.Medico__c;
                    medico.DNA__c = dna.Dna__c;
                }
                if (dna.Ano__c == System.today().year() - 1) {
                    medico.Id = dna.Medico__c;
                    medico.DnaAnoAnteriorCompleto__c = dna.Dna__c; // FY (2021: atual ano anterior)
                    medico.DNAAnoAnterior__c = dna.DNAMes__c; // YTD (2021: atual ano anterior)
                }
                if (dna.Ano__c == 2020) {
                    medico.Id = dna.Medico__c;
                    medico.DNA2020FY__c = dna.Dna__c;
                }
                
                if(medico.Id != null) mapaMedicos.put(medico.Id, medico);
            }
        }else{
            for(Dna__c dna : listaTriggerNew) {
                //if(dna.Dna__c != mapaTriggerOld.get(dna.Id).Dna__c){
                    Contact medico;
                    if(mapaMedicos.containsKey(dna.Medico__c)) medico = mapaMedicos.get(dna.Medico__c);
                    else medico = new Contact();
                    
                    if (dna.Ano__c == System.today().year()) {
                        medico.Id = dna.Medico__c;
                        medico.DNA__c = dna.Dna__c;
                    }
                    if (dna.Ano__c == System.today().year() - 1) {
                        medico.Id = dna.Medico__c;
                        medico.DnaAnoAnteriorCompleto__c = dna.Dna__c; // FY (2021: atual ano anterior)
                        medico.DNAAnoAnterior__c = dna.DNAMes__c; // YTD (2021: atual ano anterior)
                    }
                    if (dna.Ano__c == 2020) {
                        medico.Id = dna.Medico__c;
                        medico.DNA2020FY__c = dna.Dna__c;
                    }
                    
                    if(medico.Id != null) mapaMedicos.put(medico.Id, medico);
                //}
            }
        }

        UPDATE mapaMedicos.values();
    }
}