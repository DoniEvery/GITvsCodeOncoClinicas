@isTest
private class TaskRestManagerTest 
{
    @TestSetup
    public static void setup()
    {
        Account unidade = new Account(Name = 'UnitTest', 
                                      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Local_OC_Care').getRecordTypeId(),
                                      Ativo__c = 'Sim',
                                      Situacao_da_Local__c = 'Rede Propria');
        insert unidade;
        
        Account conta = new Account(Name = 'Conta', UnidadeCuidadosContinuados__c = unidade.Id, CNPJ__c = '12345678901');
        insert conta;
        
        Contact contato = new Contact(AccountId = conta.Id,
                                      RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ContatoPaciente').getRecordTypeId(),
                                      FirstName = 'Test',
                                      LastName = 'Teste',
                                      MobilePhone = '11988888888');
        insert contato;
        
        Campaign campanha = new Campaign(Name = 'CAMPANHA_CUIDADOS_CONTINUADOS',
                                         IgnorarValidacao__c = true);
        insert campanha;
        
        CampaignMember membro = new CampaignMember(ContactId = contato.Id,
                                                   CampaignId = campanha.Id);
        insert membro;
        
        Group fila = [SELECT Id FROM Group WHERE DeveloperName = :('LOC' + unidade.Id)];
        System.runAs(new User(Id=UserInfo.getUserId()))
		{
        	QueuesObject testQueue = new QueueSObject(QueueID = fila.id, SObjectType = 'Task');
    		insert testQueue;
        }
    }
    
    @isTest
    static void criarCasoPostTest() 
    {
        List<TaskRestManager.Tarefa> tarefaLista = new List<TaskRestManager.Tarefa>();
        
        // Criando objetos de tarefa de teste
        TaskRestManager.Tarefa tarefa1 = new TaskRestManager.Tarefa();
        tarefa1.DS_ESTABELECIMENTO = 'Estabelecimento A';
        tarefa1.NR_ATENDIMENTO = '123';
        tarefa1.CPF = '12345678901';
        tarefa1.nome_medico_responsavel = 'Dr. Silva';
        tarefa1.DT_LIBERACAO = '2024-04-27';
        tarefa1.CD_PERFIL = 'CP Exclusivo';
        tarefa1.DS_PERFIL = 'CP Exclusivo';
        tarefa1.CD_FASES = 'Instável';
        tarefa1.DS_FASES = 'Morte Iminente';

        tarefaLista.add(tarefa1);
        
        TaskRestManager.Tarefa tarefa2 = new TaskRestManager.Tarefa();
        tarefa2.DS_ESTABELECIMENTO = 'Estabelecimento A';
        tarefa2.NR_ATENDIMENTO = '123';
        tarefa2.CPF = '12345678901';
        tarefa2.nome_medico_responsavel = 'Dr. Silva';
        tarefa2.DT_LIBERACAO = '2024-04-27';
        tarefa2.CD_PERFIL = 'CP Exclusivo';
        tarefa2.DS_PERFIL = 'CP Exclusivo';
        tarefa2.CD_FASES = 'Instável';
        tarefa2.DS_FASES = 'Deteriorando';

        tarefaLista.add(tarefa2);
        
        TaskRestManager.Tarefa tarefa3 = new TaskRestManager.Tarefa();
        tarefa3.DS_ESTABELECIMENTO = 'Estabelecimento A';
        tarefa3.NR_ATENDIMENTO = '123';
        tarefa3.CPF = '12345678901';
        tarefa3.nome_medico_responsavel = 'Dr. Silva';
        tarefa3.DT_LIBERACAO = '2024-04-27';
        tarefa3.CD_PERFIL = 'CP Exclusivo';
        tarefa3.DS_PERFIL = 'CP Exclusivo';
        tarefa3.CD_FASES = 'Instável';
        tarefa3.DS_FASES = 'Instável';

        tarefaLista.add(tarefa3);
        
        TaskRestManager.Tarefa tarefa4 = new TaskRestManager.Tarefa();
        tarefa4.DS_ESTABELECIMENTO = 'Estabelecimento A';
        tarefa4.NR_ATENDIMENTO = '123';
        tarefa4.CPF = '12345678901';
        tarefa4.nome_medico_responsavel = 'Dr. Silva';
        tarefa4.DT_LIBERACAO = '2024-04-27';
        tarefa4.CD_PERFIL = 'CP Exclusivo';
        tarefa4.DS_PERFIL = 'CP test';
        tarefa4.CD_FASES = 'Instável';
        tarefa4.DS_FASES = 'test';

        tarefaLista.add(tarefa4);
        
        Test.startTest();
        String result = TaskRestManager.criarCasoPostTest(tarefaLista);
        Test.stopTest();
        
        // Verificando se a operação foi bem-sucedida
        System.assertEquals('Tarefas criadas com sucesso', result, 'Deveria ter criado as tarefas sem erros');
    }
    
    @isTest
    static void cenarioDeErroTest() 
    {
        List<TaskRestManager.Tarefa> tarefaLista = new List<TaskRestManager.Tarefa>();
        
        // Criando objetos de tarefa de teste
        TaskRestManager.Tarefa tarefa1 = new TaskRestManager.Tarefa();
        tarefa1.DS_ESTABELECIMENTO = 'Estabelecimento A';
        tarefa1.NR_ATENDIMENTO = '123';
        tarefa1.CPF = '12345678900';
        tarefa1.nome_medico_responsavel = 'Dr. Silva';
        tarefa1.DT_LIBERACAO = '2024-04-27';
        tarefa1.CD_PERFIL = 'CP Exclusivo';
        tarefa1.DS_PERFIL = 'Perfil Exclusivo';
        tarefa1.CD_FASES = 'Instável';
        tarefa1.DS_FASES = 'Morte Iminente';

        tarefaLista.add(tarefa1);
        
        Test.startTest();
        String result = TaskRestManager.criarCasoPostTest(tarefaLista);
        Test.stopTest();
        
        // Verificando se a operação foi bem-sucedida
        System.assertEquals('Paciente de CPF', result.substring(0,15), 'Deveria ter dado erro');
    }
    
    @isTest
    static void cenarioExceptionTest() 
    {
        List<TaskRestManager.Tarefa> tarefaLista = new List<TaskRestManager.Tarefa>();
        
        // Criando objetos de tarefa de teste
        TaskRestManager.Tarefa tarefa1 = new TaskRestManager.Tarefa();
        tarefa1.DS_ESTABELECIMENTO = 'Estabelecimento A';
        tarefa1.NR_ATENDIMENTO = '123';
        tarefa1.CPF = '12345678901';
        tarefa1.nome_medico_responsavel = 'Dr. Silva';
        tarefa1.DT_LIBERACAO = '2024-04-277';
        tarefa1.CD_PERFIL = 'CP Exclusivo';
        tarefa1.DS_PERFIL = 'CP Exclusivo';
        tarefa1.CD_FASES = 'Instável';
        tarefa1.DS_FASES = 'Instável';

        tarefaLista.add(tarefa1);

        tarefaLista.add(tarefa1);
        
        Test.startTest();
        String result = TaskRestManager.criarCasoPostTest(tarefaLista);
        Test.stopTest();
        
        // Verificando se a operação foi bem-sucedida
        System.assertEquals('Paciente de CPF', result.substring(0,15), 'Deveria ter dado erro');
    }
}