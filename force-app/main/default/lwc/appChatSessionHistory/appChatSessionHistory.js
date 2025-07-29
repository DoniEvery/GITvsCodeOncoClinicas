import { LightningElement, wire } from 'lwc';
import getSessions from '@salesforce/apex/APP_ChatController.getSessions';
import USER_ID from '@salesforce/user/Id';

export default class AppChatSessionHistory extends LightningElement {
    // sessions = [
    //     { id: 'sess1', title: 'Alice', lastUpdated: 'Ontem' },
    //     { id: 'sess2', title: 'Bruno', lastUpdated: 'Hoje 10:00' }
    // ];

    // handleSessionClick(event) {
    //     const sessionId = event.target.dataset.id;
    //     this.dispatchEvent(new CustomEvent('sessionselected', {
    //         detail: { sessionId }
    //     }));
    // }

    // sessions = [];

    // @wire(getSessions, { userId: USER_ID })
    // wiredSessions({ error, data }) {
    //     if (data) {
    //         this.sessions = data.map(session => ({
    //             id: session.Id,
    //             title: this.resolveName(session),
    //             lastUpdated: new Date(session.LastMessageDate__c).toLocaleString()
    //         }));
    //     } else if (error) {
    //         console.error('Erro ao buscar sessões:', error);
    //     }
    // }

    // resolveName(session) {
    //     return session.User1__r.Name === 'Você' ? session.User2__r.Name : session.User1__r.Name;
    //     // Opcional: substituir "Você" por lógica que compare USER_ID com o id retornado
    // }

    handleSessionClick(event) {
        const sessionId = event.target.dataset.id;
        this.dispatchEvent(new CustomEvent('sessionselected', {
            detail: { sessionId }
        }));
    }
    
}