import { LightningElement, track } from 'lwc';
import vistoMensagemIcon from '@salesforce/resourceUrl/APP_VistoMensagemIcon';
import cameraIcon from '@salesforce/resourceUrl/APP_CameraIcon';

export default class AppConversations extends LightningElement {
    vistoMensagemIcon = vistoMensagemIcon;
    cameraIcon = cameraIcon;

    @track conversations = [];

    connectedCallback() {
        const rawData = [
            {
                id: '1',
                initials: 'PC',
                name: 'Paulo Campelo',
                role: 'Concierge',
                icon: 'Photo',
                hasPhoto: true,
                date: '01/11/25'
            },
            {
                id: '2',
                initials: 'JG',
                name: 'João Gilberto',
                role: 'Paciente',
                icon: 'Mensagem',
                hasPhoto: false,
                date: '01/11/25'
            },
            {
                id: '3',
                initials: 'PC',
                name: 'Gláucio Motta',
                role: 'Paciente',
                icon: 'Photo',
                hasPhoto: false,
                date: '01/11/25'
            }
        ];

        // Processa a lista para incluir as flags booleanas que o HTML vai usar
        this.conversations = rawData.map(conv => ({
            ...conv,
            isPhoto: conv.icon === 'Photo',
            isMensagem: conv.icon === 'Mensagem'
        }));
    }
}