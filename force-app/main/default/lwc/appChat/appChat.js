import { api, LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getSessionId from '@salesforce/apex/APP_ChatController.getSessionId';
import getOrCreateSession from '@salesforce/apex/APP_ChatController.getOrCreateSession';
import getMessages from '@salesforce/apex/APP_ChatController.getMessages';
import sendMessage from '@salesforce/apex/APP_ChatController.sendMessage';
import validateOrRefreshSession from '@salesforce/apex/APP_ChatController.validateOrRefreshSession';
import getCurrentUserContactId from '@salesforce/apex/APP_ChatController.getCurrentUserContactId';
import getSessionOtherUser from '@salesforce/apex/APP_ChatController.getSessionOtherUser';
import getSessionHistory from '@salesforce/apex/APP_ChatController.getSessionHistory';
import markMessagesAsRead from '@salesforce/apex/APP_ChatController.markMessagesAsRead';

// empApi (apenas Salesforce interno)
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

// CometD (para comunidades)
import COMETD from '@salesforce/resourceUrl/APP_cometd';
import { loadScript } from 'lightning/platformResourceLoader';

const PLATFORM_EVENT_CHANNEL = '/event/APP_ChatPlataformEvent__e';

export default class AppChat extends LightningElement {
    @api recordId; // ID do registro associado ao chat
    @track selectedUser = null;
    @track sessionId = null;
    @track messages = [];
    @track isSending = false;
    @track showLoadMore = false;

    isCommunity = false;
    cometdInitialized = false;
    cometdSubscription;
    cometd;
    empSubscription = null;
    currentContactId;
    loadedSessions = []; // lista de sessões já carregadas
    sessionHistory = []; // todas as sessões dessa conversa (ordenadas)

    // ======================================================
    // Evento ao clicar numa mensagem no sino de notificação
    // ======================================================
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        try {
            if (this.recordId) { // Está no ambiente Salesforce interno
                this.subscribeEmpApi();
                this.sessionId = this.recordId;
            } else { // Está no ambiente de comunidade
                this.initializeCometD();
                this.sessionId = currentPageReference?.state?.c__sessionId;
            }

            getCurrentUserContactId()
                .then(contactId => {
                    this.currentContactId = contactId;
                    return getSessionOtherUser({ sessionId: this.sessionId, currentUserId: this.currentContactId });
                })
                .then(user => {
                    this.selectedUser = { id: user.userId, name: user.userName };
                    return getSessionHistory({ user1Id: this.currentContactId, user2Id: this.selectedUser.id });
                })
                .then(history => {
                    this.sessionHistory = history;
                    this.loadedSessions = [this.sessionId];
                    this.loadMessages(this.sessionId, true).then(() => {
                        this.setScrollMode('bottom');
                        this.showLoadMore = this.loadedSessions.length < this.sessionHistory.length;
                    });
                    
                })
                .catch(error => {
                    console.error('Erro ao carregar sessão:', error);
                });
        } catch (error) {
            console.error('Erro na navegação:', error.body?.message || error.message);
        }
    }

    // ========================================
    // Ciclo de Vida
    // ========================================
    connectedCallback() {
        this.init();
    }

    disconnectedCallback() {
        this.unsubscribeFromEvent();
    }

    // ==========================
    // Métodos
    // ==========================

    // Inicialização
    async init() {
        this.isCommunity = window.location.pathname.includes('/s/');

        try {
            // Obtém o ContactId do usuário logado
            this.currentContactId = await getCurrentUserContactId();

            // Verifica se é um usuário de comunidade
            if (this.isCommunity) {
                this.initializeCometD();
            } else {
                this.registerErrorListener();
                this.subscribeEmpApi();
            }
            
        } catch (error) {
            console.error('Erro ao obter ContactId do usuário:', error.body?.message || error.message);
        }
    }

    // empApi (Salesforce)
    subscribeEmpApi() {
        try {
            if (this.empSubscription) return;

            subscribe(PLATFORM_EVENT_CHANNEL, -1, (event) => {
                this.handleIncomingMessage(event.data.payload);
            }).then(response => {
                this.empSubscription = response;
            }).catch(error => {
                console.error('Erro ao usar empApi:', error.body?.message || error.message);
            });
        } catch (error) {
            console.error('Erro ao iniciar EmpApi:', error.body?.message || error.message);
        }
    }

    // CometD (Comunidade)
    initializeCometD() {
        try {
            if (this.cometdInitialized) return;

            Promise.all([
                loadScript(this, COMETD),
                getSessionId()
            ])
            .then(([_, sessionId]) => {
                this.cometd = new window.org.cometd.CometD();
                this.cometd.unregisterTransport();
                this.cometd.registerTransport('long-polling', window.org.cometd.LongPollingTransport);
                this.cometd.configure({
                    // url: window.location.protocol + '//' + window.location.host + '/cometd/64.0/',
                    url: '/cometd/64.0/',
                    requestHeaders: { Authorization: 'Bearer ' + sessionId },
                    appendMessageTypeToURL: false,
                    useWorkerScheduler: false,
                    logLevel: 'info'
                });
                this.cometd.websocketEnabled = false;
                this.cometd.handshake((handshake) => {
                    if (handshake.successful) {
                        this.cometdInitialized = true;
                        this.cometd.subscribe(
                            PLATFORM_EVENT_CHANNEL,
                            (message) => {
                                this.handleIncomingMessage(message.data.payload);
                            },
                            (subscription) => {
                                this.cometdSubscription = subscription;
                            }
                        );
                    } else {
                        console.error('Falha no handshake CometD:', handshake);
                    }
                });
            })
            .catch(error => {
                console.error('Erro ao iniciar CometD com SessionId:', error.body?.message || error.message);
            });
        } catch (error) {
            console.error('Erro ao iniciar CometD:', error.body?.message || error.message);
        }
    }

    // Cancela inscrição em empApi ou CometD
    unsubscribeFromEvent() {
        if (this.cometdSubscription) {
            this.cometd.unsubscribe(this.cometdSubscription, () => {
                this.cometdSubscription = null;
            });
        } else if (this.empSubscription) {
            unsubscribe(this.empSubscription, () => {
                this.empSubscription = null;
            });
        }
    }

    // Escuta erros do empApi
    registerErrorListener() {
        if (!this.isCommunity) {
            onError((error) => {
                console.error('Erro empApi:', JSON.stringify(error));
            });
        }
    }

    // Carregar mensagens
    async loadMessages(sessionId, isInitial = false) {
        try {
            if (isInitial && sessionId === this.sessionId) {
                await markMessagesAsRead({
                    sessionId: this.sessionId,
                    userId: this.currentContactId
                });
            }

            const result = await getMessages({
                sessionId: sessionId,
                userId: this.currentContactId
            });

            const formatted = result.map(msg => ({
                ...msg,
                isOwnMessage: msg.senderId === this.currentContactId,
                isRead: msg.readBy?.includes(this.currentContactId),
                isUnread: !msg.readBy?.includes(this.currentContactId) && msg.senderId !== this.currentContactId,
                dataUnread: (!msg.readBy?.includes(this.currentContactId) && msg.senderId !== this.currentContactId) ? 'true' : undefined
            }));

            if (isInitial) {
                const combined = [...this.messages, ...formatted];
                const uniqueMap = new Map();

                for (const msg of combined) {
                    uniqueMap.set(msg.messageId, msg); // mantém a última ocorrência
                }

                const allMessages = Array.from(uniqueMap.values());
                allMessages.sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
                this.messages = allMessages;
            } else {
                const combined = [...formatted, ...this.messages];
                combined.sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
                this.messages = combined;
            }

        } catch (error) {
            console.error('Erro ao carregar mensagens:', error.body?.message || error.message);
        }
    }

    // Método de rolagem
    setScrollMode(mode) {
        const chatMessages = this.template.querySelector('c-app-chat-messages');
        if (chatMessages) {
            if (mode === 'bottom') {
                chatMessages.scrollToBottom();
            } else if (mode === 'unread') {
                chatMessages.scrollToFirstUnread();
            }
        }
    }

    // ========================================
    // Handlers de UI
    // ========================================

    // Manipula o evento de seleção de usuário
    async handleUserSelected(event) {
        const { userId, userName } = event.detail;

        // Caso o valor tenha sido limpo pelo componente de busca
        if (!userId) {
            this.selectedUser = null;
            this.sessionId = null;
            this.messages = [];
            return;
        }

        // Define o usuário selecionado
        this.selectedUser = { id: userId, name: userName };
        this.sessionId = null;
        this.messages = [];

        try {
            // Cria ou recupera sessão entre usuário logado e selecionado
            const session = await getOrCreateSession({
                user1Id: this.currentContactId,
                user2Id: userId
            });
            this.sessionId = session.Id;

            // Recupera o histórico de sessões
            const history = await getSessionHistory({
                user1Id: this.currentContactId,
                user2Id: this.selectedUser.id
            });
            this.sessionHistory = history;
            this.loadedSessions = [this.sessionId];

            // Carrega as mensagens da sessão atual
            await this.loadMessages(this.sessionId, true);

            // Ajusta scroll e visibilidade do botão "Carregar mais"
            this.setScrollMode('bottom');
            this.showLoadMore = this.loadedSessions.length < this.sessionHistory.length;

        } catch (error) {
            console.error('Erro ao carregar mensagens:', error.body?.message || error.message);
        }
    }

    // Carregar mais mensagens
    async handleLoadMore() {
        const nextIndex = this.loadedSessions.length;
        
        if (nextIndex < this.sessionHistory.length) {
            const nextSessionId = this.sessionHistory[nextIndex];
            this.loadedSessions.push(nextSessionId);

            try {
                await this.loadMessages(nextSessionId, false);
                this.showLoadMore = this.loadedSessions.length < this.sessionHistory.length;
            } catch (error) {
                console.error('Erro ao carregar mais mensagens:', error.body?.message || error.message);
            }
        }
    }

    // Manipulação de Sessão
    async handleSessionSelected(event) {
        const sessionId = event.detail.sessionId;
        this.sessionId = sessionId;
        this.selectedUser = null;
        this.messages = [];

        try {
            const result = await getMessages({ sessionId, userId: this.currentContactId });
            this.messages = result;
        } catch (error) {
            console.error('Erro ao carregar sessão histórica:', error.body?.message || error.message);
        }
    }

    // Envio de Mensagem
    async handleSendMessage(event) {
        const { content, type, replyTo, metadata } = event.detail;
        
        try {
            if (!this.sessionId || !content) return;

            this.isSending = true;

            // 1. Verifica se a sessão atual está válida
            const newSession = await validateOrRefreshSession({
                sessionId: this.sessionId,
                user1Id: this.currentContactId,
                user2Id: this.selectedUser.id
            });

            // 2. Atualiza sessionId se necessário
            this.sessionId = newSession.Id;

            // 3. Envia a mensagem com o novo sessionId
            await sendMessage({
                sessionId: this.sessionId,
                senderId: this.currentContactId,
                receiverId: this.selectedUser.id,
                content,
                type,
                replyTo,
                metadataInput: metadata || {}
            });

            // 4. Recarrega as mensagens
            await this.loadMessages(this.sessionId, true);

            // 5. Rola para o final
            this.setScrollMode('bottom');

        } catch (error) {
            console.error('Erro ao enviar mensagem:', error.body?.message || error.message);
        } finally {
            this.template.querySelector('c-app-chat-input').sentMsg();
            this.template.querySelector('c-app-chat-input').enableSend();
            this.isSending = false;
        }
    }
    
    // Mensagem recebida (empApi ou CometD)
    async handleIncomingMessage(payload) {
        try {
            if (payload.APP_SessionId__c !== this.sessionId) return;

            await markMessagesAsRead({ sessionId: this.sessionId, userId: this.currentContactId });
            
            const message = JSON.parse(payload.APP_Message__c);
            message.isOwnMessage = message.senderId === this.currentContactId;
            message.isRead = message.readBy && message.readBy.includes(this.currentContactId);
            message.isUnread = !payload.readBy?.includes(this.currentContactId) && payload.senderId !== this.currentContactId;
            message.dataUnread = (!payload.readBy?.includes(this.currentContactId) && payload.senderId !== this.currentContactId) ? 'true' : undefined

            // Verifica se já existe essa mensagem no chat
            if (this.messages.some(m => m.messageId === message.messageId)) {
                return; // já existe, não adiciona
            }

            this.messages = [...this.messages, message];
            
            const chatMessages = this.template.querySelector('c-app-chat-messages');
            if (chatMessages) {
                chatMessages.scrollToBottom();
            }
        } catch (error) {
            console.error('Erro ao enviar mensagem:', error.body?.message || error.message);
        }
    }
    
}