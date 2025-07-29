public without sharing class BatchCalcularDNA implements Database.Batchable<sObject>, Database.Stateful {

    public Date dataInicio{get; set;}
    public Date dataFim{get; set;}
    public Integer ano{get; set;}

    public BatchCalcularDNA(Integer ano){
        this.dataInicio = Date.newInstance(ano, 1, 1);
        this.dataFim = Date.newInstance(ano, 12, 31);
        this.ano = ano;
    }

  public Database.QueryLocator start(Database.BatchableContext BC){
      Set<String> setEspecialidades = new Set<String>();
      for(Especialidade__mdt especialidade :[SELECT Id, label FROM Especialidade__mdt]){
          setEspecialidades.add(especialidade.label);
      }
      
      String query = 'SELECT Id FROM Contact WHERE Tipo_de_Medico__c = \'Especialista Medico\' OR Tipo_de_Medico__c = \'Corpo Clinico - Parcerias Hospitalares\'';
      query += 'OR Tipo_de_Medico__c = \'Corpo Clinico - Parcerias Clinicas Espec\' OR (Tipo_de_Medico__c = \'Corpo Clinico - Clinicas\' AND Especialidade_que_Atua__c NOT IN :setEspecialidades)';
      return Database.getQueryLocator(query);
  }
    
    public void execute(Database.BatchableContext BC, List<Contact> scope){
        Set<String> setIdMedico = new Set<String>();
        List<Dna__c> listaDNA = new List<Dna__c>();
        Map<String, list<dnaCustom>> mapaMedicoIdxDnas = new Map<String, List<dnaCustom>>();
        for(Contact medico :scope){
            setIdMedico.add(medico.Id);
        }

        for(Dna__c dna :[SELECT Id, Medico__c, TotalConsultas__c, TotalTratativas__c, Ano__c, TotalTratativasMes__c, TotalConsultasMes__c 
                         FROM Dna__c WHERE Medico__c IN :setIdMedico AND Ano__c <= :this.ano]){
            if(mapaMedicoIdxDnas.containsKey(dna.Medico__c)) mapaMedicoIdxDnas.get(dna.Medico__c).add(gerarDnaCustom(dna));
            else mapaMedicoIdxDnas.put(dna.Medico__c, new List<dnaCustom>{gerarDnaCustom(dna)});
        }

        for(String medicoId :mapaMedicoIdxDnas.KeySet()){
            integer totalTratativas = 0, totalConsultas = 0, totalTratativasRetroativos = 0, totalTratativasUltimoAno = 0, totalTratativasAteDoisAnos = 0;
            integer totalTratativasMes = 0, totalConsultasMes = 0, totalTratativasRetroativosMes = 0, totalTratativasAteDoisAnosMes = 0;
            list<dnaCustom> listaDnas = mapaMedicoIdxDnas.get(medicoId);
            listaDnas.sort();

            for(dnaCustom dna :listaDnas){
                totalTratativas += dna.totalTratativas;
                totalConsultas += dna.totalConsultas;
                
                if(dna.ano != this.ano){
                    totalTratativasRetroativos += dna.totalTratativas;
                    totalTratativasRetroativosMes += dna.totalTratativas;
                    totalTratativasMes += dna.totalTratativas;
                    totalConsultasMes += dna.totalConsultas;
                } 
                else{
                    totalTratativasMes += dna.totalTratativasMes;
                    totalConsultasMes += dna.totalConsultasMes; 
                }
                if(dna.ano == this.ano - 1) totalTratativasUltimoAno += dna.totalTratativas;  
                
            }

            Dna__c dna2Update = new Dna__c();
            dna2Update.Chave__c = medicoId + '-' + this.ano;
            dna2Update.DNA__c = calcularResultado(totalTratativas, totalConsultas, totalTratativasRetroativos, totalTratativasUltimoAno);
            dna2Update.DNAMes__c = calcularResultado(totalTratativasMes, totalConsultasMes, totalTratativasRetroativosMes, totalTratativasUltimoAno);

            listaDNA.add(dna2Update);
        }

        UPSERT listaDNA Chave__c;
    }
    
    public void finish(Database.BatchableContext BC){
        this.ano ++;
        if(this.ano <= system.today().year()) Database.executeBatch(new BatchCalcularDNA(this.ano), 100);
    }
    
    public static String calcularResultado(Integer totalTratativas, Integer totalConsultas, Integer totalTratativasRetroativos, Integer totalTratativasUltimoAno){
        String retorno = null;
        if(totalTratativas == 0 && totalConsultas != 0) retorno = 'Somente Consulta';
        if(totalTratativas == 0 && totalConsultas == 0) retorno = 'Nunca Encaminhou';
        if(totalTratativasRetroativos == 0 && totalTratativas != 0) retorno = 'Conquista';
        if(totalTratativasRetroativos != 0 && totalTratativas > totalTratativasRetroativos) retorno = 'Manutenção';
        if(totalTratativasUltimoAno == 0 && totalTratativas > totalTratativasRetroativos && totalTratativasRetroativos != 0) retorno = 'Reconquista';
        if(totalTratativasUltimoAno != 0 && totalTratativas == totalTratativasRetroativos && totalTratativasRetroativos != 0) retorno = 'Deixou de Encaminhar (Ano Anterior)';
        if(totalTratativas == totalTratativasRetroativos && totalTratativasRetroativos != 0 && totalTratativasUltimoAno == 0) retorno = 'Deixou de Encaminhar';
        return retorno;
    }

    public static dnaCustom gerarDnaCustom(Dna__c dna){
        dnaCustom dnaCustom = new dnaCustom();
        dnaCustom.ano = (integer) dna.Ano__c;
        dnaCustom.totalConsultas = (integer)  dna.TotalConsultas__c;
        dnaCustom.totalTratativas = (integer) dna.TotalTratativas__c;
        dnaCustom.totalConsultasMes = (integer)  dna.TotalConsultasMes__c;
        dnaCustom.totalTratativasMes = (integer) dna.TotalTratativasMes__c;
        return dnaCustom;
    }

    //criei esse objeto na class para poder customizar a ordenação.
    public class dnaCustom implements Comparable{
        public Integer ano{get;set;}
        public Integer totalConsultas{get;set;}
        public Integer totalTratativas{get;set;}
        public Integer totalConsultasMes{get;set;}
        public Integer totalTratativasMes{get;set;}

        public Integer compareTo(Object compareTo){
        dnaCustom otherDna = (dnaCustom)compareTo;

        //Deixa os campos em branco por último na exibição. 
        if (ano == null) return 1;
        else if (otherDna.ano == null) return -1;

        if(ano == otherDna.ano) return 0;
        else if(ano < otherDna.ano) return 1;
        else return -1;
        
        }
    }
}