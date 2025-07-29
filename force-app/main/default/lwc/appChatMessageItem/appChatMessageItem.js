import { LightningElement, api } from 'lwc';

export default class AppChatMessageItem extends LightningElement {
    @api message;

    get messageClass() {
        return this.message.isOwnMessage ? 'sent' : 'received';
    }

    get isText() {
        return this.message.type === 'text';
    }

    get isImage() {
        return this.message.type === 'image';
    }

    get isFile() {
        return this.message.type === 'file';
    }

    get imageUrl() {
        return this.message.metadata?.imageUrl;
    }

    get fileName() {
        return this.message.metadata?.fileName;
    }

    get fileType() {
        return this.message.metadata?.fileType;
    }

    get fileSize() {
        return this.message.metadata?.fileSize;
    }

    get timestamp() {
        try {
            const dt = new Date(this.message.timestamp);
            return dt.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        } catch (e) {
            return '';
        }
    }
}