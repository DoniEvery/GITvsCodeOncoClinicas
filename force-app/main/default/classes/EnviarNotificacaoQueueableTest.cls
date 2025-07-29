@IsTest
public class EnviarNotificacaoQueueableTest {
    @TestSetup
    static void makeData(){
        Account accountObj = new Account(
            LastName = 'Cartaxo',
            FirstName = 'Wilton',
            MiddleName = 'Manoel Da Silva',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(),
            Especialidades_Core_do_CRM__pc = 'SELECIONAR',
            et4ae5__Mobile_Country_Code__pc = 'US',
            Calendario_Repete_a_cada__pc = 1
        );
        insert accountObj;
        
        Contact contactObj = new Contact(
            LastName = 'Reis',
            FirstName = 'Edgar',
            MiddleName = 'Soares',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MedicoCorpoClinico').getRecordTypeId(),
            MobilePhone = '996856985',
            CPF__c = '10762491752',
            DDD_Celular__c = '11',
            Especialidade_que_Atua__c = 'ACUPUNTURA',
            et4ae5__Mobile_Country_Code__c = 'US',
            Calendario_Repete_a_cada__c = 1,
            StatusMedico__c = 'Ativo'
        );
        insert contactObj;
        MedicacaoAltoCusto__c medicacaoaltocustoObj = new MedicacaoAltoCusto__c(
            Ativo__c = true,
            Custo__c = 'Alto',
            DataAdministracao__c = date.newinstance(2024,01,01),
            DataDispensacao__c = date.newinstance(2024,02,06),
            DataPrescricao__c = date.newinstance(2023,11,24),
            DataRenovacao__c = date.newinstance(2024,01,29),
            MedicoQuePrescreveuProtocolo__c = contactObj.Id,
            NomeDrogaAtiva__c = 'Ácido zoledrônico',
            NomeProtocolo__c = 'teste protocolo 2',
            ManterMedicacao__c = 'Sim',
            Paciente__c = accountObj.Id
        );
        insert medicacaoaltocustoObj;
        Task taskObj = new Task(
            RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('EnfermeiraDrogaAltoCusto').getRecordTypeId(),
            WhatId = medicacaoaltocustoObj.Id,
            Subject = 'Protocolo Inativo Alto Custo',
            ActivityDate = date.newinstance(2024, 01, 31),
            Status = 'Em andamento',
            Priority = 'Normal',
            HealthCloudGA__TaskType__c = 'Relacionamento Médico (Conjunta)',
            Status_Reuniao__c = 'Agendada',
            Tipo_Assunto__c = 'Visita',
            Tentativa__c = 1,
            NomeMedico__c = 'Edgar Soares Reis',
            NotificaMedico__c = false
        );
        insert taskObj;
        GerenciadorParametros__c gerenciadorparametrosObj = new GerenciadorParametros__c(
            Ativo__c = true,
            FechamentoAutomatico__c = 7,
            QuantidadeDeDiasPosPrescricao__c = 60,
            TipoGerenciador__c = 'Parametrização para alto custo'
        );
        insert gerenciadorparametrosObj;
    }
    @IsTest
    static void testQueue200(){
        map<Id,Task> taskMap = new map<Id,Task>([SELECT Id,WhatId,NotificaMedico__c FROM Task]);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize('{}'), 200, 'OK'));
        System.enqueueJob(new EnviarNotificacaoQueueable(taskMap));
        Test.stopTest();
    }
    @IsTest
    static void testQueue400(){
        map<Id,Task> taskMap = new map<Id,Task>([SELECT Id,WhatId,NotificaMedico__c FROM Task]);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(JSON.serialize('{}'), 400, 'OK'));
        System.enqueueJob(new EnviarNotificacaoQueueable(taskMap));
        Test.stopTest();
    }
    @IsTest
    static void testTaskEnvio(){
        Task t = [SELECT Id,WhatId,NotificaMedico__c FROM Task];
        Test.startTest();
        t.NotificaMedico__c = true;
        update t;
        Test.stopTest();
    }
}