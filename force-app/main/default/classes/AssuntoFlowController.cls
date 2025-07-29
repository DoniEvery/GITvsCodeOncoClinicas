public with sharing class AssuntoFlowController {
    private static Id ASSUNTO_RTYPE = Schema.SObjectType.Assunto__c.getRecordTypeInfosByDeveloperName().get('AssuntoGlobal').getRecordTypeId();
    @AuraEnabled(cacheable=true)
    public static List<string> searchListAssunto(String objName,Boolean disponivelPaciente,String motivoCaso,String unidade,Boolean recategorizado,String IdassuntoExistente){
        string sQuery = '';
        system.debug(objName);
        if(objName == 'AssuntoUnidade__c' && disponivelPaciente && recategorizado == false){
            sQuery+='SELECT Id,NomeAssunto__c FROM '+objName+' WHERE DisponivelPaciente__c ='+disponivelPaciente+' AND MotivoCaso__c =\'' +motivoCaso+ '\' AND Unidade__c =\''+unidade+'\' AND Ativo__c = true AND AssuntoAtivo__c = true ORDER BY NomeAssunto__c';
        }else if(objName == 'AssuntoUnidade__c' && disponivelPaciente == false && recategorizado == false){
            sQuery+='SELECT Id,NomeAssunto__c FROM '+objName+' WHERE DisponivelNaoPacientes__c = true AND MotivoCaso__c =\'' +motivoCaso+ '\' AND Unidade__c =\''+unidade+'\' AND Ativo__c = true AND AssuntoAtivo__c = true ORDER BY NomeAssunto__c';
        }else if(objName == 'AssuntoUnidade__c' && disponivelPaciente == false && recategorizado == true){
            sQuery+='SELECT Id,NomeAssunto__c FROM '+objName+' WHERE DisponivelNaoPacientes__c = true AND MotivoCaso__c =\'' +motivoCaso+ '\' AND Unidade__c =\''+unidade+'\' AND Ativo__c = true AND AssuntoAtivo__c = true AND Id !=\''+IdassuntoExistente+'\' ORDER BY NomeAssunto__c';
        }else if((objName == 'AssuntoUnidade__c' && disponivelPaciente && recategorizado == true)){
            sQuery+='SELECT Id,NomeAssunto__c FROM '+objName+' WHERE DisponivelPaciente__c ='+disponivelPaciente+' AND MotivoCaso__c =\'' +motivoCaso+ '\' AND Unidade__c =\''+unidade+'\' AND Ativo__c = true AND AssuntoAtivo__c = true AND Id !=\''+IdassuntoExistente+'\' ORDER BY NomeAssunto__c';
        }else if(objName == 'Assunto__c' && disponivelPaciente == true && recategorizado == false){
            sQuery+='SELECT Id,Name FROM '+objName+' WHERE DisponivelPaciente__c ='+disponivelPaciente+' AND MotivoCaso__c =\'' +motivoCaso+ '\' AND RecordTypeId =\''+ASSUNTO_RTYPE+'\' AND Ativo__c = true ORDER BY Name';
        }else if(objName == 'Assunto__c' && disponivelPaciente == true && recategorizado == true){
            sQuery+='SELECT Id,Name FROM '+objName+' WHERE DisponivelPaciente__c ='+disponivelPaciente+' AND MotivoCaso__c =\'' +motivoCaso+ '\' AND RecordTypeId =\''+ASSUNTO_RTYPE+'\' AND Ativo__c = true AND Id !=\''+IdassuntoExistente+'\' ORDER BY Name';
        }else if(objName == 'Assunto__c' && disponivelPaciente == false && recategorizado == false){
            sQuery+='SELECT Id,Name FROM '+objName+' WHERE DisponivelNaoPacientes__c = true AND MotivoCaso__c =\'' +motivoCaso+ '\' AND RecordTypeId =\''+ASSUNTO_RTYPE+'\' AND Ativo__c = true ORDER BY Name';
        }else if(objName == 'Assunto__c' && disponivelPaciente == false && recategorizado == true){
            sQuery+='SELECT Id,Name FROM '+objName+' WHERE DisponivelNaoPacientes__c = true AND MotivoCaso__c =\'' +motivoCaso+ '\' AND RecordTypeId =\''+ASSUNTO_RTYPE+'\' AND Ativo__c = true AND Id !=\''+IdassuntoExistente+'\' ORDER BY Name';
        }
        system.debug(sQuery);
        Set<String> objListFilter = new Set<String>();
        for(sObject obj : database.query(sQuery)){
            if(objName == 'AssuntoUnidade__c'){
                customObj custom = new customObj();
                custom.Name = string.valueOf(obj.get('NomeAssunto__c'));
                objListFilter.add(custom.Name);
            }else{
                customObj custom = new customObj();
                custom.Name = string.valueOf(obj.get('Name'));
                objListFilter.add(custom.Name);
            }

        }

        List<String> accListaFiltrada = new  List<String>();
        for(string s :objListFilter){
            accListaFiltrada.add(s);
        }
        return accListaFiltrada;
    }

    @AuraEnabled(cacheable=true)
    public static List<string> searchListDetalhe(String objName,Boolean disponivelPaciente,String motivoCaso,String unidade,string assuntoName,Boolean recategorizado,String IdassuntoExistente){
        List<AssuntoUnidade__c> listaAu = new List<AssuntoUnidade__c>();
        List<Assunto__c> listaAssunto = new List<Assunto__c>();
        if(objName == 'AssuntoUnidade__c' && disponivelPaciente && recategorizado == false){ 
            listaAu = [SELECT id,AssuntoDetalhe__r.Name FROM AssuntoUnidade__c WHERE DisponivelPaciente__c =:disponivelPaciente AND MotivoCaso__c =:motivoCaso AND Unidade__c =:unidade AND Ativo__c = true AND AssuntoAtivo__c = true AND NomeAssunto__c =:assuntoName ORDER BY AssuntoDetalhe__r.Name];
        }else if(objName == 'AssuntoUnidade__c' && disponivelPaciente == false && recategorizado == false){
            listaAu = [SELECT id,AssuntoDetalhe__r.Name FROM AssuntoUnidade__c WHERE DisponivelNaoPacientes__c = true AND MotivoCaso__c =:motivoCaso AND Unidade__c =:unidade AND Ativo__c = true AND AssuntoAtivo__c = true AND NomeAssunto__c =:assuntoName ORDER BY AssuntoDetalhe__r.Name];
        }else if(objName == 'AssuntoUnidade__c' && disponivelPaciente == false && recategorizado == true){
            listaAu = [SELECT id,AssuntoDetalhe__r.Name FROM AssuntoUnidade__c WHERE DisponivelNaoPacientes__c = true AND MotivoCaso__c =:motivoCaso AND Unidade__c =:unidade AND Ativo__c = true AND AssuntoAtivo__c = true AND NomeAssunto__c =:assuntoName AND Id !=:IdassuntoExistente ORDER BY AssuntoDetalhe__r.Name];
        }else if(objName == 'AssuntoUnidade__c' && disponivelPaciente && recategorizado == true){
            listaAu = [SELECT id,AssuntoDetalhe__r.Name FROM AssuntoUnidade__c WHERE DisponivelPaciente__c =:disponivelPaciente AND MotivoCaso__c =:motivoCaso AND Unidade__c =:unidade AND Ativo__c = true AND AssuntoAtivo__c = true AND NomeAssunto__c =:assuntoName AND Id !=:IdassuntoExistente ORDER BY AssuntoDetalhe__r.Name];
        }else if(objName == 'Assunto__c' && disponivelPaciente && recategorizado == false){
            listaAssunto = [SELECT id,AssuntoDetalhe__r.Name FROM Assunto__c WHERE DisponivelPaciente__c =:disponivelPaciente AND MotivoCaso__c =:motivoCaso AND RecordTypeId =:ASSUNTO_RTYPE AND Ativo__c = true AND Name =:assuntoName ORDER BY AssuntoDetalhe__r.Name];
        }else if(objName == 'Assunto__c' && disponivelPaciente == false && recategorizado == false){
            listaAssunto = [SELECT id,AssuntoDetalhe__r.Name FROM Assunto__c WHERE DisponivelNaoPacientes__c = true AND MotivoCaso__c =:motivoCaso AND RecordTypeId =:ASSUNTO_RTYPE AND Ativo__c = true AND Name =:assuntoName ORDER BY AssuntoDetalhe__r.Name]; 
        }else if(objName == 'Assunto__c' && disponivelPaciente && recategorizado == true){
            listaAssunto = [SELECT id,AssuntoDetalhe__r.Name FROM Assunto__c WHERE DisponivelPaciente__c =:disponivelPaciente AND MotivoCaso__c =:motivoCaso AND RecordTypeId =:ASSUNTO_RTYPE AND Ativo__c = true AND Name =:assuntoName AND Id !=:IdassuntoExistente ORDER BY AssuntoDetalhe__r.Name];
        }else if(objName == 'Assunto__c' && disponivelPaciente == false && recategorizado == true){
            listaAssunto = [SELECT id,AssuntoDetalhe__r.Name FROM Assunto__c WHERE DisponivelNaoPacientes__c = true AND MotivoCaso__c =:motivoCaso AND RecordTypeId =:ASSUNTO_RTYPE AND Ativo__c = true AND Name =:assuntoName AND Id !=:IdassuntoExistente ORDER BY AssuntoDetalhe__r.Name]; 
        }

        Set<String> objListFilter = new Set<String>();
        if(objName == 'AssuntoUnidade__c'){
            if(listaAu.size() > 1){
                for(AssuntoUnidade__c au : listaAu){
                    customObj custom = new customObj();
                    custom.Name = (au.AssuntoDetalhe__c != null) ? au.AssuntoDetalhe__r.Name : 'Nenhum';
                    objListFilter.add(custom.Name);
                }
            }else{
                for(AssuntoUnidade__c au : listaAu){
                    customObj custom = new customObj();
                    custom.Name = au.AssuntoDetalhe__r.Name;
                    objListFilter.add(custom.Name);
                }
            }
        }else{
            if(listaAssunto.size() > 1){
                for(Assunto__c au : listaAssunto){
                    customObj custom = new customObj();
                    custom.Name = (au.AssuntoDetalhe__c != null) ? au.AssuntoDetalhe__r.Name : 'Nenhum';
                    objListFilter.add(custom.Name);
                } 
            }else{
                for(Assunto__c au : listaAssunto){
                    customObj custom = new customObj();
                    custom.Name = au.AssuntoDetalhe__r.Name;
                    objListFilter.add(custom.Name);
                }
            }
        }

        List<String> contListaFiltrada = new  List<String>();
        for(string s :objListFilter){
            contListaFiltrada.add(s);
        }
       // contListaFiltrada.sort();
        return contListaFiltrada;
    }

    @AuraEnabled(cacheable=true)
    public static customObj searchIdAssunto(String objName,String nomeAssunto,String nomeDetalhe,String unidade,String motivoCaso){
        customObj retorno = new customObj();
        nomeDetalhe = (nomeDetalhe == 'Nenhum') ? '' : nomeDetalhe;
        system.debug('aoba => '+ nomeDetalhe);
        if(objName == 'AssuntoUnidade__c'){
            AssuntoUnidade__c assuntoUnidade = [SELECT id,AssuntoDetalhe__c FROM AssuntoUnidade__c WHERE  NomeAssunto__c =: nomeAssunto AND AssuntoDetalhe__r.Name =: nomeDetalhe AND Unidade__c =: unidade AND MotivoCaso__c =: motivoCaso];
            retorno.IdAssunto = assuntoUnidade.id;
            retorno.IdDetalhe = assuntoUnidade.AssuntoDetalhe__c;
        }else{
            Assunto__c assunto = [SELECT id,AssuntoDetalhe__c FROM Assunto__c WHERE RecordTypeId =:ASSUNTO_RTYPE AND Name =: nomeAssunto AND AssuntoDetalhe__r.Name =: nomeDetalhe AND MotivoCaso__c =: motivoCaso];
            retorno.IdAssunto = assunto.id;
            retorno.IdDetalhe = assunto.AssuntoDetalhe__c;
        }
        return retorno;
    }

    public class customObj{
    @AuraEnabled
    public string Name;
    @AuraEnabled
    public string IdAssunto;
    @AuraEnabled
    public string IdDetalhe;
}
}