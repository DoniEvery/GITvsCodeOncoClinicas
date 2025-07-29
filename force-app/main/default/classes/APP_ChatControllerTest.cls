@isTest
public class APP_ChatControllerTest {

    static Id contato1Id;
    static Id contato2Id;
    static User user1;
    static User user2;
    
    @testSetup
    static void setupData() {
        // 1. Setup objects
        UserRole role = new UserRole(Name = 'Test Role');
        insert role;

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'APP_Paciente' LIMIT 1];

        User userOwner = new User(
            Username = 'owneruser@example.com.test',
            Alias = 'owner',
            Email = 'owneruser@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Sao_Paulo',
            ProfileId = UserInfo.getProfileId(),
            LastName = 'Owner',
            UserRoleId = role.Id
        );
        insert userOwner;

        // 2. Dados de negócio (non-setup)
        Test.startTest();
        System.runAs(userOwner) {
            Account acc = new Account(Name = 'Conta Teste');
            insert acc;

            Id rtMedico = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
                .get('MedicoCorpoClinico').getRecordTypeId();

            Contact c1 = new Contact(LastName = 'Contato 1', AccountId = acc.Id, RecordTypeId = rtMedico);
            Contact c2 = new Contact(LastName = 'Contato 2', AccountId = acc.Id, RecordTypeId = rtMedico);
            insert new List<Contact>{ c1, c2 };
            contato1Id = c1.Id;
            contato2Id = c2.Id;

            // Cria usuários com o ContactId já setado (sem update)
            user1 = new User(
                Username = 'pac1@example.com.test',
                Alias = 'pac1',
                Email = 'pac1@example.com',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Sao_Paulo',
                ProfileId = profile.Id,
                LastName = 'Usuário1',
                ContactId = c1.Id
            );

            user2 = new User(
                Username = 'pac2@example.com.test',
                Alias = 'pac2',
                Email = 'pac2@example.com',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/Sao_Paulo',
                ProfileId = profile.Id,
                LastName = 'Usuário2',
                ContactId = c2.Id
            );

            insert new List<User>{ user1, user2 };

            // Parâmetro
            RecordType rtChat = [
                SELECT Id FROM RecordType
                WHERE SObjectType = 'APP_Parametro__c'
                AND DeveloperName = 'Chat'
                LIMIT 1
            ];
            insert new APP_Parametro__c(
                RecordTypeId = rtChat.Id,
                ExpirationTime__c = 2
            );
        }
        Test.stopTest();
    }

    @isTest
    static void testGetSessionId() {
        Test.startTest();

        String sessionId = APP_ChatController.getSessionId();
        System.assertNotEquals(null, sessionId);

        Test.stopTest();
    }

    @isTest
    static void testIsCommunityUser() {
        Test.startTest();

        Boolean isCommunity = APP_ChatController.isCommunityUser();
        System.assertEquals(false, isCommunity); 

        Test.stopTest();
    }

    @isTest
    static void testGetCurrentUserContactId() {
        Test.startTest();

        User user = [SELECT Id FROM User WHERE Email = 'pac1@example.com' LIMIT 1];

        System.runAs(user) {
            Id contactId1 = [SELECT Id FROM Contact WHERE Name = 'Contato 1' LIMIT 1].Id;
            Id contactId = APP_ChatController.getCurrentUserContactId();
            System.assertEquals(contactId1, contactId);
        }
        Test.stopTest();
    }

    @isTest
    static void testGetSessions() {
        Test.startTest();

        Id contactId1 = [SELECT Id FROM Contact WHERE Name = 'Contato 1' LIMIT 1].Id;

        List<APP_ChatExperienceSession__c> result = APP_ChatController.getSessions(contactId1);
        System.assertNotEquals(null, result, 'A lista retornada não pode ser nula');
        System.assertEquals(0, result.size(), 'Por padrão, deve retornar lista vazia');
        
        Test.stopTest();
    }

    @isTest
    static void testCreateAndSendMessage() {
        Test.startTest();

        Id contactId1 = [SELECT Id FROM Contact WHERE Name = 'Contato 1' LIMIT 1].Id;
        Id contactId2 = [SELECT Id FROM Contact WHERE Name = 'Contato 2' LIMIT 1].Id;

        // Cria sessão
        APP_ChatExperienceSession__c session = APP_ChatController.getOrCreateSession(contato1Id, contato2Id);
        System.assertNotEquals(null, session.Id);

        // Envia mensagem
        Map<String, Object> metadata = new Map<String, Object>{
            'fileName' => 'documento.pdf',
            'fileSize' => 12345,
            'fileType' => 'pdf'
        };
        
        APP_ChatController.sendMessage(
            session.Id,
            String.valueOf(contato1Id),
            String.valueOf(contato2Id),
            'Olá, tudo bem?',
            'file',
            null,
            metadata
        );

        // Verifica se a mensagem foi salva
        List<APP_ChatExperienceMessage__c> mensagens = [
            SELECT Id, APP_Message__c
            FROM APP_ChatExperienceMessage__c
            WHERE APP_ChatSessionId__c = :session.Id
        ];

        System.assert(!mensagens.isEmpty(), 'Mensagem deveria ter sido inserida');
        System.assert(mensagens[0].APP_Message__c.contains('Olá, tudo bem?'));
        Test.stopTest();
    }

    @isTest
    static void testMarkMessagesAsRead() {
        Test.startTest();

        Id contactId1 = [SELECT Id FROM Contact WHERE Name = 'Contato 1' LIMIT 1].Id;
        Id contactId2 = [SELECT Id FROM Contact WHERE Name = 'Contato 2' LIMIT 1].Id;
        
        APP_ChatExperienceSession__c session = APP_ChatController.getOrCreateSession(contactId1, contactId2);

        // Inserir mensagem com readBy incompleto
        String json = JSON.serialize(new List<Object>{
            new Map<String, Object>{
                'messageId' => '1',
                'senderId' => String.valueOf(contactId1),
                'receiverId' => String.valueOf(contactId2),
                'timestamp' => String.valueOf(DateTime.now()),
                'content' => 'Oi',
                'type' => 'text',
                'replyTo' => null,
                'readBy' => new List<String>{ String.valueOf(contactId1) }
            }
        });

        insert new APP_ChatExperienceMessage__c(
            APP_ChatSessionId__c = session.Id,
            APP_Message__c = json
        );

        APP_ChatController.markMessagesAsRead(session.Id, contactId2);

        APP_ChatExperienceMessage__c updatedMsg = [
            SELECT APP_Message__c FROM APP_ChatExperienceMessage__c WHERE APP_ChatSessionId__c = :session.Id LIMIT 1
        ];

        System.assert(updatedMsg.APP_Message__c.contains(String.valueOf(contactId2)));
        
        Test.stopTest();
    }

    @isTest
    static void testGetMessages() {
        Test.startTest();

        Id contactId1 = [SELECT Id FROM Contact WHERE Name = 'Contato 1' LIMIT 1].Id;
        Id contactId2 = [SELECT Id FROM Contact WHERE Name = 'Contato 2' LIMIT 1].Id;
        
        APP_ChatExperienceSession__c session = APP_ChatController.getOrCreateSession(contactId1, contactId2);

        String json = JSON.serialize(new List<Object>{
            new Map<String, Object>{
                'messageId' => 'msg-1',
                'senderId' => String.valueOf(contactId1),
                'receiverId' => String.valueOf(contactId2),
                'timestamp' => String.valueOf(DateTime.now()),
                'content' => 'Oi',
                'type' => 'text',
                'replyTo' => null,
                'readBy' => new List<String>{ String.valueOf(contactId1) }
            }
        });

        insert new APP_ChatExperienceMessage__c(
            APP_ChatSessionId__c = session.Id,
            APP_Message__c = json
        );

        List<APP_ChatController.ChatMessageDTO> mensagens = APP_ChatController.getMessages(session.Id, contactId1);
        System.assertEquals(1, mensagens.size());
        System.assertEquals('Oi', mensagens[0].content);

        Test.stopTest();
    }

    @isTest
    static void testGetSessionOtherUser() {
        Test.startTest();

        Id contactId1 = [SELECT Id FROM Contact WHERE Name = 'Contato 1' LIMIT 1].Id;
        Id contactId2 = [SELECT Id FROM Contact WHERE Name = 'Contato 2' LIMIT 1].Id;
        
        APP_ChatExperienceSession__c session = APP_ChatController.getOrCreateSession(contactId1, contactId2);
        APP_ChatController.UserChatInfo info = APP_ChatController.getSessionOtherUser(session.Id, contactId1);
        System.assertEquals(contactId2, info.userId);

        Test.stopTest();
    }

    @isTest
    static void testGetSessionHistory() {
        Test.startTest();

        Id contactId1 = [SELECT Id FROM Contact WHERE Name = 'Contato 1' LIMIT 1].Id;
        Id contactId2 = [SELECT Id FROM Contact WHERE Name = 'Contato 2' LIMIT 1].Id;
        
        APP_ChatExperienceSession__c session = APP_ChatController.getOrCreateSession(contactId1, contactId2);
        List<Id> sessions = APP_ChatController.getSessionHistory(contactId1, contactId2);
        System.assert(!sessions.isEmpty());
        
        Test.stopTest();
    }

    @isTest
    static void testValidateOrRefreshSession() {
        Test.startTest();

        Id contactId1 = [SELECT Id FROM Contact WHERE Name = 'Contato 1' LIMIT 1].Id;
        Id contactId2 = [SELECT Id FROM Contact WHERE Name = 'Contato 2' LIMIT 1].Id;
        
        APP_ChatExperienceSession__c sessao = new APP_ChatExperienceSession__c(
            APP_CreatedByContactId__c = contato1Id,
            APP_CreatedToContactId__c = contato2Id,
            ChatChannel__c = 'AppChat',
            StartedAt__c = System.now().addHours(-3),
            Type__c = 'Individual',
            ExpirationDate__c = System.now().addMinutes(-10)
        );
        insert sessao;

        APP_ChatExperienceSession__c nova = APP_ChatController.validateOrRefreshSession(sessao.Id, contato1Id, contato2Id);
        System.assertNotEquals(sessao.Id, nova.Id);
        
        Test.stopTest();
    }
}