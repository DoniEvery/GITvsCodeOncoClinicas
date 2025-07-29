public without sharing class APP_ChatController {
    @AuraEnabled
    public static String getSessionId() {
        return UserInfo.getSessionId();
    }

    @AuraEnabled
    public static Boolean isCommunityUser() {
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        return profileName == 'APP_Paciente' || profileName == 'APP_Acompanhante';
    }

    public static Boolean isCommunityUser(Id userId) {
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :userId].Profile.Name;
        return profileName == 'APP_Paciente' || profileName == 'APP_Acompanhante';
    }

    @AuraEnabled
    public static Id getCurrentUserContactId() {
        User user = [
            SELECT ContactId, APP_ContatoId__c, Profile.Name
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        if (user.Profile.Name == 'APP_Paciente' || user.Profile.Name == 'APP_Acompanhante') {
            return user.ContactId;
        }

        return user.APP_ContatoId__c;
    }

    @AuraEnabled
    public static APP_ChatExperienceSession__c validateOrRefreshSession(Id sessionId, Id user1Id, Id user2Id) {
        APP_ChatExperienceSession__c session = [
            SELECT Id, Expired__c
            FROM APP_ChatExperienceSession__c
            WHERE Id = :sessionId
            LIMIT 1
        ];

        if (session.Expired__c) {
            // cria nova sessão válida
            return getOrCreateSession(user1Id, user2Id);
        }

        return session;
    }

    @AuraEnabled
    public static List<ChatMessageDTO> getMessages(Id sessionId, Id userId) {
        List<APP_ChatExperienceMessage__c> registros = [
            SELECT Id, APP_Message__c
            FROM APP_ChatExperienceMessage__c
            WHERE APP_ChatSessionId__c = :sessionId
            ORDER BY CreatedDate ASC
        ];

        List<ChatMessageDTO> mensagens = new List<ChatMessageDTO>();

        for (APP_ChatExperienceMessage__c msgRegistro : registros) {
            if (String.isNotBlank(msgRegistro.APP_Message__c)) {
                try {
                    List<Object> jsonList = (List<Object>) JSON.deserializeUntyped(msgRegistro.APP_Message__c);

                    for (Object rawItem : jsonList) {
                        Map<String, Object> item = (Map<String, Object>) rawItem;

                        String senderId = (String) item.get('senderId');
                        String receiverId = (String) item.get('receiverId');
                        String content = (String) item.get('content');
                        String type = (String) item.get('type');
                        String messageId = (String) item.get('messageId');
                        String timestamp = (String) item.get('timestamp');
                        Object replyTo = item.containsKey('replyTo') ? item.get('replyTo') : null;
                        List<Object> readByRaw = (List<Object>) item.get('readBy');
                        List<String> readBy = new List<String>();

                        for (Object r : readByRaw) {
                            readBy.add((String) r);
                        }

                        mensagens.add(new ChatMessageDTO(
                            messageId,
                            sessionId,
                            senderId,
                            receiverId,
                            timestamp,
                            content,
                            type,
                            replyTo,
                            readBy
                        ));
                    }

                } catch (Exception e) {
                    System.debug('Erro ao desserializar mensagem: ' + e.getMessage());
                }
            }
        }

        return mensagens;
    }

    /** Metadata tipo arquivo
     "metadata": {
        "fileName": "laudo.pdf",
        "fileSize": 102400,
        "fileType": "pdf"
        }
     */
    /** Metadata tipo imagem
     "imageUrl": "https://...",
     "thumbnailUrl": "https://...",
     "dimensions": {
         "width": 800,
         "height": 600
     },
     "imageType": "jpg"
     */
    @AuraEnabled
    public static void sendMessage(
        Id sessionId,
        String senderId,
        String receiverId,
        String content,
        String type, // "text", "file", "image"
        String replyTo,
        Map<String, Object> metadataInput 
    ) {
        // 1. Prepara metadata dinamicamente
        Map<String, Object> metadataFinal = new Map<String, Object>();

        if (type == 'file') {
            metadataFinal.put('fileName', metadataInput.get('fileName'));
            metadataFinal.put('fileSize', metadataInput.get('fileSize'));
            metadataFinal.put('fileType', metadataInput.get('fileType'));
        } else if (type == 'image') {
            metadataFinal.put('imageUrl', metadataInput.get('imageUrl'));
            metadataFinal.put('thumbnailUrl', metadataInput.get('thumbnailUrl'));
            metadataFinal.put('dimensions', metadataInput.get('dimensions'));
            metadataFinal.put('imageType', metadataInput.get('imageType'));
        }

        // 2. Cria nova mensagem individual
        Map<String, Object> newMessage = new Map<String, Object>{
            'messageId' => String.valueOf(UUID.randomUUID()),
            'type' => type,
            'senderId' => senderId,
            'receiverId' => receiverId,
            'timestamp' => DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
            'content' => content,
            'replyTo' => String.isBlank(replyTo) ? null : replyTo,
            'readBy' => new List<String>{ senderId },
            'metadata' => metadataFinal
        };

        String novaMensagemJson = JSON.serialize(newMessage);
        Boolean adicionou = false;

        // 3. Tenta adicionar ao último registro de mensagens
        List<APP_ChatExperienceMessage__c> mensagens = [
            SELECT Id, APP_Message__c
            FROM APP_ChatExperienceMessage__c
            WHERE APP_ChatSessionId__c = :sessionId
            ORDER BY CreatedDate DESC
        ];

        for (APP_ChatExperienceMessage__c msg : mensagens) {
            List<Object> listaExistente;
            try {
                listaExistente = (List<Object>) JSON.deserializeUntyped(msg.APP_Message__c);
            } catch (Exception e) {
                listaExistente = new List<Object>();
            }

            listaExistente.add(newMessage);
            String atualizado = JSON.serialize(listaExistente);

            if (atualizado.length() <= 131072) {
                msg.APP_Message__c = atualizado;
                update msg;
                adicionou = true;
                break;
            }
        }

        // 4. Se nenhuma mensagem pôde ser atualizada, cria novo registro
        if (!adicionou) {
            try {
                List<Object> novaLista = new List<Object>{ newMessage };
                APP_ChatExperienceMessage__c nova = new APP_ChatExperienceMessage__c(
                    APP_ChatSessionId__c = sessionId,
                    APP_Message__c = JSON.serialize(novaLista)
                );
                insert nova;
            } catch (Exception e) {
                System.debug('Erro ao inserir nova mensagem: ' + e.getMessage());
                throw new AuraHandledException('Erro ao registrar mensagem no chat.');
            }
        }

        // 5. Atualiza o campo LastMessageAt__c da sessão
        try {
            APP_ChatExperienceSession__c sessao = new APP_ChatExperienceSession__c(
                Id = sessionId,
                LastMessageAt__c = System.now()
            );
            update sessao;
        } catch (Exception e) {
            System.debug('Erro ao atualizar LastMessageAt__c da sessão: ' + e.getMessage());
            throw new AuraHandledException('Erro ao atualizar a sessão de chat.');
        }

        // 6. Dispara evento de plataforma para o outro usuário
        APP_ChatPlataformEvent__e evento = new APP_ChatPlataformEvent__e(
            APP_SessionId__c = sessionId,
            APP_SenderId__c = senderId,
            APP_ReceiverId__c = receiverId,
            APP_MessageId__c = String.valueOf(newMessage.get('messageId')),
            APP_Timestamp__c = DateTime.now(),
            APP_Message__c = JSON.serialize(newMessage)
        );
        EventBus.publish(evento);

        // 7. Envia notificação para o outro usuário
        sendBellNotification(receiverId, sessionId, content);

    }

    @AuraEnabled
    public static APP_ChatExperienceSession__c getOrCreateSession(Id user1Id, Id user2Id) {
        // 1. Tempo de expiração padrão = 0 (sem expiração)
        Integer expirationHours = 0;

        List<APP_Parametro__c> parametros = [
            SELECT ExpirationTime__c
            FROM APP_Parametro__c
            WHERE RecordType.DeveloperName = 'Chat'
        ];
        if (!parametros.isEmpty() && parametros[0].ExpirationTime__c != null) {
            expirationHours = Integer.valueOf(Math.floor(parametros[0].ExpirationTime__c));
        }

        // 2. Busca sessão ativa existente (não expirada e não encerrada manualmente)
        List<APP_ChatExperienceSession__c> existing = [
            SELECT Id
            FROM APP_ChatExperienceSession__c
            WHERE 
                (Expired__c = false AND EndedByType__c = '') AND (
                    (
                        (APP_CreatedByContactId__c = :user1Id AND APP_CreatedToContactId__c = :user2Id) OR
                        (APP_CreatedByContactId__c = :user2Id AND APP_CreatedToContactId__c = :user1Id)
                    )
                )
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (!existing.isEmpty()) {
            return existing[0]; // Sessão ativa encontrada
        }

        // 3. Criação da nova sessão
        APP_ChatExperienceSession__c nova = new APP_ChatExperienceSession__c(
            APP_CreatedByContactId__c = user1Id,
            APP_CreatedToContactId__c = user2Id,
            ChatChannel__c = 'AppChat',
            StartedAt__c = System.now(),
            Type__c = 'Individual'
        );
        
        // Se houver configuração de expiração, adiciona os campos
        if (expirationHours > 0) {
            nova.ExpirationTime__c = expirationHours;
            nova.ExpirationDate__c = System.now().addHours(expirationHours);
        }

        insert nova;
        return nova;
    }

    @AuraEnabled
    public static List<Id> getSessionHistory(Id user1Id, Id user2Id) {
        List<APP_ChatExperienceSession__c> sessions = [
            SELECT Id
            FROM APP_ChatExperienceSession__c
            WHERE (
                (APP_CreatedByContactId__c = :user1Id AND APP_CreatedToContactId__c = :user2Id) OR
                (APP_CreatedByContactId__c = :user2Id AND APP_CreatedToContactId__c = :user1Id)
            )
            ORDER BY StartedAt__c DESC
        ];

        List<Id> sessionIds = new List<Id>();
        for (APP_ChatExperienceSession__c s : sessions) {
            sessionIds.add(s.Id);
        }

        return sessionIds;
    }

    @AuraEnabled
    public static void markMessagesAsRead(Id sessionId, Id userId) {
        List<APP_ChatExperienceMessage__c> registros = [
            SELECT Id, APP_Message__c
            FROM APP_ChatExperienceMessage__c
            WHERE APP_ChatSessionId__c = :sessionId
        ];

        for (APP_ChatExperienceMessage__c reg : registros) {
            Boolean updated = false;
            if (String.isNotBlank(reg.APP_Message__c)) {
                List<Object> jsonList = (List<Object>) JSON.deserializeUntyped(reg.APP_Message__c);
                for (Object itemObj : jsonList) {
                    Map<String, Object> item = (Map<String, Object>) itemObj;
                    List<Object> readBy = (List<Object>) item.get('readBy');
                    if (!readBy.contains(userId)) {
                        readBy.add(userId);
                        updated = true;
                    }
                }

                if (updated) {
                    reg.APP_Message__c = JSON.serialize(jsonList);
                }
            }
        }

        update registros;
    }
    
    @AuraEnabled
    public static List<APP_ChatExperienceSession__c> getSessions(Id userId) {
        // return [
        //     SELECT Id, User1__r.Name, User2__r.Name, LastMessageDate__c
        //     FROM Chat_Session__c
        //     WHERE User1__c = :userId OR User2__c = :userId
        //     ORDER BY LastMessageDate__c DESC
        // ];
        return new List<APP_ChatExperienceSession__c>();
    }

    public static void sendBellNotification(Id receiverContactId, Id sessionId, String messageContent) {
        // 1. Buscar UserId associado ao contato (padrão ou customizado)
        List<User> matchedUsers = [
            SELECT Id
            FROM User
            WHERE IsActive = true AND (ContactId = :receiverContactId OR APP_ContatoId__c = :receiverContactId)
            LIMIT 1
        ];

        if (matchedUsers.isEmpty()) {
            System.debug('Nenhum usuário encontrado para o contato informado: ' + receiverContactId);
            return;
        }

        Id receiverUserId = matchedUsers[0].Id;

        // 2. Verifica se o usuário é da comunidade
        Boolean isCommunityUser = isCommunityUser(receiverUserId);

        // 3. Buscar o tipo de notificação
        Id notifTypeId = [
            SELECT Id FROM CustomNotificationType
            WHERE DeveloperName = 'APP_NovaMensagemChat'
            LIMIT 1
        ].Id;

        // 4. Monta o TargetPageRef (Salesforce ou Comunidade)
        Map<String, Object> pageRef;

        if (isCommunityUser) {
            pageRef = new Map<String, Object>{
                'type' => 'standard__webPage',
                'attributes' => new Map<String, Object>{
                    'url' => '/chat?c__sessionId=' + sessionId
                }
            };
        } else {
            // pageRef = new Map<String, Object>{
            //     'type' => 'standard__navItemPage',
            //     'attributes' => new Map<String, Object>{
            //         'apiName' => 'APP_Chat'
            //     },
            //     'state' => new Map<String, Object>{
            //         'c__sessionId' => String.valueOf(sessionId)
            //     }
            // };
            pageRef = new Map<String, Object>{
                'type' => 'standard__recordPage',
                'attributes' => new Map<String, Object>{
                    'recordId' => String.valueOf(sessionId),
                    'objectApiName' => 'PersonAccount',
                    'actionName' => 'view'
                }
            };
        }
        String pageRefJson = JSON.serialize(pageRef);

        // 5. Monta e envia a notificação
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setNotificationTypeId(notifTypeId);
        notification.setTitle('Nova mensagem no chat');
        notification.setBody(messageContent);

        if (isCommunityUser) {
            notification.setTargetPageRef(pageRefJson);
        }
        else {
            notification.setTargetId(sessionId);
        }
        
        notification.send(new Set<String>{ String.valueOf(receiverUserId) });
    }

    @AuraEnabled
    public static UserChatInfo getSessionOtherUser(Id sessionId, Id currentUserId) {
        APP_ChatExperienceSession__c sess = [
            SELECT Id, APP_CreatedByContactId__c, APP_CreatedToContactId__c
            FROM APP_ChatExperienceSession__c
            WHERE Id = :sessionId
            LIMIT 1
        ];

        Id otherUserId = sess.APP_CreatedByContactId__c == currentUserId
            ? sess.APP_CreatedToContactId__c
            : sess.APP_CreatedByContactId__c;

        Contact c = [SELECT Id, Nome_completo__c FROM Contact WHERE Id = :otherUserId LIMIT 1];

        return new UserChatInfo(c.Id, c.Nome_completo__c);
    }

    public class UserChatInfo {
        @AuraEnabled public Id userId;
        @AuraEnabled public String userName;
        public UserChatInfo(Id u, String n) {
            userId = u;
            userName = n;
        }
    }

    public class ChatMessageDTO {
        @AuraEnabled public String messageId;
        @AuraEnabled public Id sessionId;
        @AuraEnabled public String senderId;
        @AuraEnabled public String receiverId;
        @AuraEnabled public String timestamp;
        @AuraEnabled public String content;
        @AuraEnabled public String type;
        @AuraEnabled public Object replyTo;
        @AuraEnabled public List<String> readBy;

        public ChatMessageDTO(
            String messageId,
            Id sessionId,
            String senderId,
            String receiverId,
            String timestamp,
            String content,
            String type,
            Object replyTo,
            List<String> readBy
        ) {
            this.messageId = messageId;
            this.sessionId = sessionId;
            this.senderId = senderId;
            this.receiverId = receiverId;
            this.timestamp = timestamp;
            this.content = content;
            this.type = type;
            this.replyTo = replyTo;
            this.readBy = readBy;
        }
    }
}