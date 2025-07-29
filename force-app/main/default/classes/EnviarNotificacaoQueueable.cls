public class EnviarNotificacaoQueueable implements Queueable, Database.AllowsCallouts {
    
	private map<Id,Task> taskMap;
    
    public EnviarNotificacaoQueueable(map<Id,Task> taskMap){
        this.taskMap = taskMap;
    }
    
    public void execute(QueueableContext context){
        Id idTask;
        for(Id idAcc : taskMap.keyset()){
            idTask = idAcc;
            break;
        }
        try{
            Task task = new Task(Id = idTask,NotificaMedico__c = false);

            MedicacaoAltoCusto__c mac = [SELECT id, MedicoQuePrescreveuProtocolo__c,MedicoQuePrescreveuProtocolo__r.CPF__c,Paciente__r.Name,MedicoQuePrescreveuProtocolo__r.Name,NumeroAtendimento__r.Sequencia_Atendimento__c,NomeProtocolo__c,Retorno_Integracao_JSON__c,Status_da_Integracao__c
                                          FROM MedicacaoAltoCusto__c 
                                         WHERE id =: taskMap.get(idTask).WhatId Limit 1];
            GerenciadorParametros__c gp = [SELECT Id,QuantidadeDeDiasPosPrescricao__c FROM GerenciadorParametros__c WHERE Ativo__c = true AND TipoGerenciador__c= 'Parametrização para alto custo' LIMIT 1];
            if (mac?.Id != null){
                EnviarNotificacaoEntity.Request request = new EnviarNotificacaoEntity.Request();
                request.cpf = mac.MedicoQuePrescreveuProtocolo__r.CPF__c;
                request.topicId = mac.Id;
                request.fullText = String.format(Label.Alerta_Medico_MSG_APP, new List<string>{mac.MedicoQuePrescreveuProtocolo__r.Name,mac.Paciente__r.Name,String.valueOf(mac.NumeroAtendimento__r.Sequencia_Atendimento__c),mac.NomeProtocolo__c,String.valueOf(gp.QuantidadeDeDiasPosPrescricao__c)});
                request.notificationText = Label.Alerta_Medico_MSG_APP_Title;

                EnviarNotificacaoEntity.Retorno response =  new EnviarNotificacaoService().enviarNotificacao(JSON.serialize(request));
				Boolean statusCodeOk = (response?.statusCode == 200 || response?.statusCode == 201);

                mac.Status_da_Integracao__c = (statusCodeOk) ? 'Integrado' : 'Erro de Integração';
                mac.Retorno_Integracao_JSON__c = (statusCodeOk) ? 'Integrado com Sucesso!' : 'Erro ao Integrar! - Retorno :: ' + response?.bodyResponse ;
                update new List<Sobject>{task,mac};
            }
            
        }catch(Exception e){
            System.debug('Erro na execução: ' + e.getMessage());
            System.debug('Tipo: ' + e.getTypeName());
            System.debug('Stack trace string: ' + e.getStackTraceString());
        }finally{
            taskMap.remove(idTask);
            if(!taskMap.isEmpty() && !Test.isRunningTest()){
                System.enqueueJob(new EnviarNotificacaoQueueable(taskMap));
            }
        }
    }
}