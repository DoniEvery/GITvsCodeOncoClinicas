@RestResource(urlMapping = '/criarCaso')
global with sharing class CaseRestManager {
    
    @HttpPost
    global static String criarCasoPostTest(Caso caso){
        Savepoint sp = Database.setSavepoint();
        try{
            
            String pacienteRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Conta pessoal').getRecordTypeId();
            String pacienteid;

            List<Entitlement> listaDireito = [SELECT Id, Type, BusinessHoursId FROM Entitlement WHERE Type = 'Formulário de agendamento' AND BusinessHoursId != null ORDER BY Createddate desc LIMIT 1];
            
            if(!listaDireito.isEmpty()){
                //Busca paciente existente
                if(!String.isBlank(caso.cpf)){
                    List<Account> listaPersonAccount = [SELECT Id, CNPJ__c FROM Account WHERE CNPJ__c = :caso.cpf AND RecordtypeId = :pacienteRecordType ORDER BY Createddate DESC limit 1];
                    
                    if(!listaPersonAccount.isEmpty()){
                        pacienteid = listaPersonAccount[0].Id;
                    }else{  
                        Account acc = new Account();
                        //tratativa do Nome
                        if(!caso.nome.contains(' ')){
                            acc.LastName = caso.nome;
                        }else{ 
                            List<String> nomeSplit = caso.nome.split(' ');
                            acc.LastName = nomeSplit[nomeSplit.size() - 1];
                            nomeSplit.remove(nomeSplit.size() - 1);
                            acc.FirstName = (nomeSplit.size() > 1 ? String.join(nomeSplit, ' ') : nomeSplit[0]);
                        }
                        acc.CNPJ__c = caso.cpf;
                        acc.PersonHomePhone = caso.telefone1;
                        acc.PersonEmail = caso.email;
                        acc.PersonBirthdate = caso.dataNascimento;
                        acc.RecordTypeId = pacienteRecordType;
                        insert acc;
                        
                        pacienteid = acc.Id;
                    }
                }
                
                Case casoFormulario = criarCaso(caso, pacienteId, listaDireito[0].Id, listaDireito[0].BusinessHoursId);
                insert casoFormulario;
                
                return 'Caso inserido com sucesso!';
            }else{
                return 'Erro: Não existe um SLA definido para Fomulário de Agendamento';
            }
                
        }catch(Exception e){
            Database.rollback(sp);
            system.debug(e.getStackTraceString());
            return 'Ocorreu um erro interno Salesforce: ' + e.getMessage();
        }       
    }
    
    global static Case criarCaso(Caso casoRest, String pacienteId, String direitoId, String horarioComercialId){
        
        String caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Formulário de agendamento').getRecordTypeId();
        
        Case caso = new Case();
        caso.UnidadeAgendamento__c = casoRest.unidade;
        caso.CidadeAtendimento__c = casoRest.cidade;
        if(!String.isBlank(pacienteId)) caso.AccountId = pacienteId;
        caso.RecordTypeId = caseRecordType;
        caso.Medico__c = casoRest.medico;
        caso.Estado__c = casoRest.estado;
        caso.Especialidade_de_Atendimento__c = casoRest.especialidade;
        caso.Description = casoRest.descricao;
        caso.TelefoneAtendimento__c = casoRest.telefone1;
        caso.EnvioProtocolo__c = true;
        caso.EntitlementId = direitoId;
        caso.BusinessHoursId = horarioComercialId;
        caso.Campanha__c = casoRest.campanha;
        caso.CanalOrigem__c = casoRest.canalorigem;
        caso.Periodoatendimento__c = casoRest.periodoAtend;
        caso.Telefoneopcional__c = casoRest.telefoneOpc;
        caso.AutorizacontatoWhatsApp__c = casoRest.autorizaContporWhatsapp;
        caso.TipoAtendimento__c = casoRest.tipoAtendimento;
        caso.utm_term__c = casoRest.utm_term;
        caso.utm_campaign__c = casoRest.utm_campaign;
        caso.utm_content__c = casoRest.utm_content;
        caso.utm_id__c = casoRest.utm_id;
        
        return caso;
    }
    
    global class Caso{
        global String nome { get; set; }
        global String cpf { get; set; }
        global String telefone1 { get; set; }
        global String email { get; set; }
        global String unidade { get; set; } 
        global String cidade { get; set; } 
        global String medico { get; set; }
        global String descricao { get; set; }
        global String tipoconta { get; set; }
        global String estado { get; set; }
        global String especialidade { get; set;}
        global Date dataNascimento { get; set; }
        global String campanha { get; set; }
        global String canalorigem { get; set; }
        global String periodoAtend { get; set; }
        global String telefoneOpc {get; set;}
        global boolean autorizaContporWhatsapp {get;set;} 
        global String tipoAtendimento {get; set;}
        global String utm_term { get; set; }
        global String utm_campaign { get; set; }
        global String utm_content { get;set; }
        global String utm_id { get; set; }
    }
}