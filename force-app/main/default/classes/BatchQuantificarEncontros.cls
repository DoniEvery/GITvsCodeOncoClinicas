public without sharing class BatchQuantificarEncontros implements Database.Batchable<sObject>, Database.Stateful {

    public Date dataInicio{get; set;}
    public Date dataFim{get; set;}
    public Integer ano{get; set;}

    public BatchQuantificarEncontros(Integer ano){
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
      query += 'OR Tipo_de_Medico__c = \'Corpo Clinico - Hospitais\' OR (Tipo_de_Medico__c = \'Corpo Clinico - Clinicas\' AND Especialidade_que_Atua__c NOT IN :setEspecialidades)';
      return Database.getQueryLocator(query);
  }
    
    public void execute(Database.BatchableContext BC, List<Contact> scope){
        Integer mesAtual = system.today().month();
        Set<String> setIdMedico = new Set<String>();
        Map<String, DNA__c> mapaMedicoDNA = new Map<String, DNA__c>();

        for(Contact medico :scope){
            setIdMedico.add(medico.Id);
        }

        for(aggregateResult resultado :[SELECT Identificador_Medico_Ref_Contact__c medico, Resumo_Procedimento_II__c tipo, 
                                        CALENDAR_MONTH(HealthCloudGA__PeriodStart__c) mes, COUNT(Id) total FROM
                                        HealthCloudGA__EhrEncounter__c WHERE Identificador_Medico_Ref_Contact__c 
                                        IN :setIdMedico AND HealthCloudGA__PeriodStart__c >= :dataInicio AND Resumo_Procedimento_II__c != null
                                        AND Resumo_Procedimento_II__c != '-' AND HealthCloudGA__PeriodStart__c <= :dataFim AND 
                                        Identificador_Medico_Ref_Contact__c != null GROUP BY Identificador_Medico_Ref_Contact__c,
                                        Resumo_Procedimento_II__c, CALENDAR_MONTH(HealthCloudGA__PeriodStart__c)]){

            if(mapaMedicoDNA.containsKey((String) resultado.get('medico'))){
                DNA__c dna = mapaMedicoDNA.get((String) resultado.get('medico'));
                String tipoEncontro = (String) resultado.get('tipo');
                
                if((integer) resultado.get('mes') <= mesAtual){
                    if(tipoEncontro.equalsIgnoreCase('primeira_QT') || tipoEncontro.equalsIgnoreCase('primeira_RT')) dna.TotalTratativasMes__c += (Integer) resultado.get('total');
                    else dna.TotalConsultasMes__c += (Integer) resultado.get('total');
                }
                
                if(tipoEncontro.equalsIgnoreCase('primeira_QT') || tipoEncontro.equalsIgnoreCase('primeira_RT')) dna.TotalTratativas__c += (Integer) resultado.get('total');
                else dna.TotalConsultas__c += (Integer) resultado.get('total');
                
                mapaMedicoDNA.put(dna.Medico__c, dna);
            }else{
                DNA__c dna = new DNA__c();
                dna.Medico__c = (String) resultado.get('medico');
                String tipoEncontro = (String) resultado.get('tipo');
                if(tipoEncontro.equalsIgnoreCase('primeira_QT') || tipoEncontro.equalsIgnoreCase('primeira_RT')){
                    dna.TotalTratativas__c = (Integer) resultado.get('total');
                    dna.TotalConsultas__c = 0;
                }else{
                    dna.TotalConsultas__c = (Integer) resultado.get('total');
                    dna.TotalTratativas__c = 0;
                }
                
                if((integer) resultado.get('mes') <= mesAtual){
                    if(tipoEncontro.equalsIgnoreCase('primeira_QT') || tipoEncontro.equalsIgnoreCase('primeira_RT')){
                        dna.TotalTratativasMes__c = (Integer) resultado.get('total');
                        dna.TotalConsultasMes__c = 0; 
                    } 
                    else{
                        dna.TotalConsultasMes__c = (Integer) resultado.get('total');
                        dna.TotalTratativasMes__c = 0;
                    } 
                }else{
                    dna.TotalTratativasMes__c = 0;
                    dna.TotalConsultasMes__c = 0;
                }
                dna.Chave__c = dna.Medico__c + '-' + this.ano;
                dna.Ano__c = this.ano;
                mapaMedicoDNA.put(dna.Medico__c, dna);
            }
        }

        for(Contact medico :scope){
            if(!mapaMedicoDNA.containsKey(medico.Id)){
                DNA__c dna = new DNA__c();
                dna.Medico__c = medico.Id;
                dna.TotalTratativas__c = 0;
                dna.TotalConsultas__c = 0;
                dna.TotalTratativasMes__c = 0;
                dna.TotalConsultasMes__c = 0;
                dna.Chave__c = dna.Medico__c + '-' + this.ano;
                dna.Ano__c = this.ano;
                mapaMedicoDNA.put(dna.Medico__c, dna);
            }
        }

        UPSERT mapaMedicoDNA.values() Chave__c;
    }
    
    public void finish(Database.BatchableContext BC){
        this.ano ++;
        if(this.ano > system.today().year()) Database.executeBatch(new BatchCalcularDNA(2022));
        else Database.executeBatch(new BatchQuantificarEncontros(this.ano));
    }
}