public class MergeContactBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    public class MergeContactBatchException extends Exception {}
    Id CORPO_CLINICO_RTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MedicoCorpoClinico').getRecordTypeId();
    Id MEDICO_RTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Medico').getRecordTypeId();
    Set<String> CpfJaAtualizado = new Set<String>();
    
    List<ObjAux> objAuxList = new List<ObjAux>{
            new ObjAux('Case',new List<String>{'ContactId','Nome_Medico__c'}),
            new ObjAux('Event',new List<String>{'WhatId','WhoId'}),
            new ObjAux('Account',new List<String>{'HealthCloudGA__PrimaryContact__c','MedicoSolicitante__c'}),
            new ObjAux('ContatoGrupo__c',new List<String>{'Medico__c'}),
            new ObjAux('CRMMedico__c',new List<String>{'Medico__c'}),
            new ObjAux('DNA__c',new List<String>{'Medico__c'}),
            new ObjAux('Emails_do_Contato__c',new List<String>{'Contato__c'}),
            new ObjAux('TimeSlot',new List<String>{'Contato__c'}),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
            new ObjAux('DuplicateRecordItem',new List<String>{'RecordId'}),
            new ObjAux('Lead',new List<String>{'HealthCloudGA__SigningProvider__c','HealthCloudGA__ReferringPractitioner__c','HealthCloudGA__ReferredToPractitioner__c','HealthCloudGA__PrimaryCareProvider__c','HealthCloudGA__AssignCareCoordinatorContact__c'}),
            new ObjAux('Log__c',new List<String>{'ContactID__c'}),
            new ObjAux('SurveyTaker__c',new List<String>{'Contact__c'}),
            new ObjAux('Task',new List<String>{'WhatId','WhoId'}),
            new ObjAux('LiveChatTranscript',new List<String>{'ContactId'}),
            new ObjAux('Tratamento__c',new List<String>{'MedicoResponsavel__c'}),
            new ObjAux('User',new List<String>{'ContactId'}),
            new ObjAux('MessagingEndUser',new List<String>{'ContactId'})
    };
    String CPF = null;

    public MergeContactBatch(){}
    public MergeContactBatch(String cpf){
        this.CPF = cpf;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String Query = 'SELECT Id,CPF__c FROM Contact WHERE (RecordtypeId = : MEDICO_RTYPE OR RecordtypeId = : CORPO_CLINICO_RTYPE) AND ';
        Query += (CPF != null) ? 'CPF__c =: CPF' : 'CPF__c != null';
        Query +=' ORDER BY CPF__c ASC';
        return Database.getQueryLocator(Query);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> scope){
        try{
            if(!CpfJaAtualizado.contains(scope[0].CPF__c)){
                this.CPF = scope[0].CPF__c;
                Map<Id,Contact> contatosComMesmoCPF = new Map<Id,Contact>([SELECT Id,RecordtypeId,CPF__c,Unidade_Principal__c,UnidadeAtuacao2__c,UnidadeAtuacao3__c,UnidadeAtuacao4__c FROM Contact WHERE CPF__c =: scope[0].CPF__c AND (RecordtypeId =: MEDICO_RTYPE OR RecordtypeId =: CORPO_CLINICO_RTYPE) ORDER BY CreatedDate ASC]);
                List<Sobject> objsUpdateList = new List<Sobject>();
                Contact contatoPrincipal = getContatoPrincipal(contatosComMesmoCPF.values(),CORPO_CLINICO_RTYPE);

                if(contatoPrincipal == null) contatoPrincipal = getContatoPrincipal(contatosComMesmoCPF.values(),MEDICO_RTYPE);

                if(contatoPrincipal != null){
                    if(contatosComMesmoCPF.containsKey(contatoPrincipal.Id)) contatosComMesmoCPF.remove(contatoPrincipal.Id);
                    objsUpdateList.add(atribuirUnidadeDeAtuacao(contatoPrincipal,contatosComMesmoCPF.values()));
                    for(ObjAux objAux : objAuxList){
                        List<Sobject> objReturn = getSobjectConvertRelation(contatosComMesmoCPF.keySet(),contatoPrincipal.Id,objAux);

                        if(objReturn.size()>0)objsUpdateList.addAll(objReturn);
                    }
                }

                if(objsUpdateList.size()>0){
                    update objsUpdateList;
                }

                CpfJaAtualizado.clear();
                CpfJaAtualizado.add(scope[0].CPF__c);
            }
        }catch (Exception e) {
            System.debug('Erro na execução: ' + e.getMessage());
            System.debug('Tipo: ' + e.getTypeName());
            System.debug('Stack trace string: ' + e.getStackTraceString()); 
            throw new MergeContactBatchException('CPF-> '+this.CPF+' Erro na execução: ' + e.getMessage());
        }
    }
    public void finish(Database.BatchableContext BC){}

    public Contact getContatoPrincipal(List<Contact> contatosComMesmoCPF, Id RTYPE){
        Contact contatoPrincipal;
        for(Contact ct : contatosComMesmoCPF){
            if(contatoPrincipal == null && ct.RecordtypeId == RTYPE) contatoPrincipal = ct;
        }
        if(RTYPE == MEDICO_RTYPE && contatoPrincipal != null){
            contatoPrincipal.RecordtypeId = CORPO_CLINICO_RTYPE;
            update contatoPrincipal;
        }
        
        return contatoPrincipal;
    }
    /* -------------------------------------------------------------------------- */
    /*                            OBJETOS RELACIONADOS                            */
    /* -------------------------------------------------------------------------- */
    public List<Sobject> getSobjectConvertRelation(Set<Id> contactIdSet,String contatoPrincipalId,ObjAux objAux){
        List<Sobject> sobjectList = new List<Sobject>();
            String query = 'SELECT Id';
            String queryWhere='';
            
    
            for(String field : objAux.fields){
                query+=','+field;
                if(queryWhere.contains('WHERE')) queryWhere+=' OR '+ field+ ' IN: contactIdSet';
                else queryWhere = ' WHERE '+ field+ ' IN: contactIdSet';
            }
    
            query+=' FROM '+objAux.sobjectName+queryWhere+' ALL ROWS';
            sobjectList = Database.query(query);
            
            for(Sobject obj : sobjectList){
                for(String field : objAux.fields){
                    if(contactIdSet.contains(String.valueOf(obj.get(field)))) obj.put(field,contatoPrincipalId);
                }
            }   
        return sobjectList;
    }
    public Contact atribuirUnidadeDeAtuacao(Contact contatoPrincipal,List<Contact> contatosDuplicados){
        for(Contact ct : contatosDuplicados){
            if(contatoPrincipal.Unidade_Principal__c == null)    contatoPrincipal   = setUnidadeAtuacao(contatoPrincipal,'Unidade_Principal__c',ct);
            else if(contatoPrincipal.UnidadeAtuacao2__c == null) contatoPrincipal   = setUnidadeAtuacao(contatoPrincipal,'UnidadeAtuacao2__c',ct);
            else if(contatoPrincipal.UnidadeAtuacao3__c == null) contatoPrincipal   = setUnidadeAtuacao(contatoPrincipal,'UnidadeAtuacao3__c',ct);
            else if(contatoPrincipal.UnidadeAtuacao4__c == null) contatoPrincipal   = setUnidadeAtuacao(contatoPrincipal,'UnidadeAtuacao4__c',ct);
            else break;
        }
        return contatoPrincipal;
    }

    public Contact setUnidadeAtuacao(Contact contatoPrincipal,String campoCtPrincipal,Contact ctREF){
        for(string campo : new List<String>{'Unidade_Principal__c','UnidadeAtuacao2__c','UnidadeAtuacao3__c','UnidadeAtuacao4__c'}){
            if(contatoPrincipal.get(campoCtPrincipal) == null && ctREF.get(campo) != null) contatoPrincipal.put(campoCtPrincipal,String.valueOf(ctREF.get(campo)));
        }
        return contatoPrincipal;
    }

    public class ObjAux{
        public String sobjectName;
        public List<String> fields;
        public ObjAux(String sobjectName,List<String> fields){
            this.sobjectName = sobjectName;
            this.fields = fields;
        }
    }
}