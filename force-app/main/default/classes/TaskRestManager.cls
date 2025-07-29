@RestResource(urlMapping = '/criarTarefa')
global with sharing class TaskRestManager 
{
    @HttpPost
    global static String criarCasoPostTest(List<Tarefa> records)
    {
        Savepoint sp = Database.setSavepoint();
        List<String> errorList = new List<String>();
        
        try
        {
            Set<String> cpfList = new Set<String>();
            List<Task> insertTasks = new List<Task>();
            Set<Id> contactIdList = new Set<Id>();
            Set<Id> contactWithCampaignList = new Set<Id>();
            Map<String, Account> pacienteMap = new Map<String, Account>();
            Map<String, Contact> contatoMap = new Map<String, Contact>();
            Map<ID, CampaignMember> membrosMap;
            Set<String> filaNameList = new Set<String>();
            Map<String, Id> filaMap = new Map<String, Id>();

            for(Tarefa tarefa : records)
            {
                cpfList.add(tarefa.CPF);
            }

            for(Account acc : [SELECT Id, CNPJ__c, UnidadeCuidadosContinuados__r.UnidadeLOC__c, (SELECT Id FROM Contacts LIMIT 1) FROM Account WHERE CNPJ__c IN :cpfList])
            {
                pacienteMap.put(acc.CNPJ__c, acc);
                if(!acc.Contacts.isEmpty())
                {
                    System.debug('Entrou Aqui Unidade LOC:' + acc.UnidadeCuidadosContinuados__r.UnidadeLOC__c);
                    contatoMap.put(acc.CNPJ__c, acc.Contacts[0]);
                    contactIdList.add(acc.Contacts[0].Id);
                    filaNameList.add(acc.UnidadeCuidadosContinuados__r.UnidadeLOC__c);
                }
            }

            for(CampaignMember membro : [SELECT Id, ContactId FROM CampaignMember WHERE ContactId IN :contactIdList AND NomeCampanha__c = 'CAMPANHA_CUIDADOS_CONTINUADOS'])
            {
                contactWithCampaignList.add(membro.ContactId);
                System.debug('Entrou Aqui Unidade contactWithCampaignList:' + membro.ContactId);
            }
            
            System.debug('Entrou Aqui Unidade filaNameList:' + filaNameList);

            for(Group fila : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN :filaNameList])
            {
                filaMap.put(fila.DeveloperName, fila.Id);
                System.debug('Entrou Aqui Unidade filaMap:' + fila.DeveloperName + '--' + fila.Id);
            }

            for(Tarefa tarefa : records)
            {
                if(contatoMap.containsKey(tarefa.CPF)
                && contactWithCampaignList.contains(contatoMap.get(tarefa.CPF).Id))
                {
                    try 
                    {
                        Account acc = pacienteMap.get(tarefa.CPF);
                        insertTasks.add(criarTarefa(tarefa, acc, filaMap.get(acc.UnidadeCuidadosContinuados__r.UnidadeLOC__c)));
                    } 
                    catch (Exception e) 
                    {
                        errorList.add('Paciente de CPF ' + tarefa.CPF + ' encontrou o seguinte erro:' + e.getMessage());
                    }
                }
                else
                {
                    errorList.add('Paciente de CPF ' + tarefa.CPF + ' não possui campanha Cuidados Continuados.');
                }
            }

            if(!insertTasks.isEmpty())
                insert insertTasks;
            
            if(errorList.isEmpty())
                return 'Tarefas criadas com sucesso';
            else 
                return String.join(errorList, ' -- ');
        }
        catch(Exception e)
        {
            Database.rollback(sp);
            system.debug(e.getStackTraceString());
            system.debug(e.getMessage());
            return 'Ocorreu um erro interno Salesforce: ' + e.getMessage() + '\n' + String.join(errorList, '\n');
        }       
    }

    global static Task criarTarefa(Tarefa tarefa, Account conta, Id filaId)
    {
        String perfil = tarefa.DS_PERFIL;
        String fase = tarefa.DS_FASES;
        Date vencimento = Date.valueOf(tarefa.DT_LIBERACAO);
        String assunto;

        if(fase.equals('Estável') || fase.equals('Deteriorando'))
        {
            vencimento = vencimento.addDays(30);
            if((fase.equals('Estável') && perfil.equals('CP Predominante'))
            || (fase.equals('Deteriorando') && perfil.equals('CP Exclusivo')))
                assunto = 'Telemonitoramento mensal/controle de sintomas';
            else
                assunto = 'Telemonitoramento mensal';
        } 
        else if(fase.equals('Instável'))
        {
            vencimento = vencimento.addDays(perfil.equals('CP Exclusivo') ? 7 : 14);
            assunto = perfil.equals('CP Exclusivo') ? 'Telemonitoramento em até 7 dias' : 'Telemonitoramento entre 7 a 14 dias';
        }
        else if(fase.equals('Morte Iminente') && perfil.equals('CP Exclusivo'))
        {
            vencimento = vencimento.addDays(2);
            assunto = 'Telemonitoramento diário/Frequencia de acompanhamente de acordo com necessidade identificada';
        }
        else
        {
            vencimento = vencimento.addDays(30);
            assunto = 'Monitoramento não mapeado';
        }

        Datetime vencimentoTime = DateTime.newInstance(vencimento.year(), vencimento.month(), vencimento.day(), 10, 00, 00);

        return new Task
        (
            OwnerId = filaId,
            RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CarePlanTask').getRecordTypeId(),
            WhatId = conta.Id,
            Subject = assunto,
            ActivityDate = vencimento,
            Status = 'Em andamento',
            Description = ('Estabelecimento: ' + tarefa.DS_ESTABELECIMENTO + '\nAtendimento: ' + tarefa.NR_ATENDIMENTO + '\nMédico: ' + tarefa.nome_medico_responsavel + '\nPerfil: ' + tarefa.DS_PERFIL + ' / Fase: ' + tarefa.DS_FASES),
            IsReminderSet = true,
            ReminderDateTime = vencimentoTime
        );
    }

    global class Tarefa
    {
        global String DS_ESTABELECIMENTO { get; set; }
        global String NR_ATENDIMENTO { get; set; }
        global String CPF { get; set; }
        global String nome_medico_responsavel { get; set; }
        global String DT_LIBERACAO { get; set; } 
        global String CD_PERFIL { get; set; } 
        global String DS_PERFIL { get; set; }
        global String CD_FASES { get; set; }
        global String DS_FASES { get; set; }
    }
}