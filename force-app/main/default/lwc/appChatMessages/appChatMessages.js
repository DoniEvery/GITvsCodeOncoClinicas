import { LightningElement, api } from 'lwc';

export default class AppChatMessages extends LightningElement {
    @api messages = [];
    @api showLoadMore = false;
    // _scrollMode = null;

    handleLoadMore() {
        this.dispatchEvent(new CustomEvent('loadmore'));
    }

    @api
    scrollToBottom() {
        requestAnimationFrame(() => {
            const container = this.template.querySelector('.chat-messages-container');
            if (container) {
                container.scrollTop = container.scrollHeight;
            }
        });
    }

    @api
    scrollToFirstUnread() {
        requestAnimationFrame(() => {
            const unread = this.template.querySelector('c-app-chat-message-item[data-unread="true"]');
            if (unread) {
                unread.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });
    }

    // scrollToBottom() {
    //     const container = this.template.querySelector('.chat-messages-container');
    //     if (container) {
    //         container.scrollTop = container.scrollHeight;
    //     }
    // }

    // scrollToFirstUnread() {
    //     const unread = this.template.querySelector('c-app-chat-message-item[data-unread="true"]');
    //     if (unread) {
    //         unread.scrollIntoView({ behavior: 'smooth', block: 'start' });
    //     }
    // }

    renderedCallback() {
        if (this._scrollMode === 'bottom') {
            this.scrollToBottom();
        } else if (this._scrollMode === 'unread') {
            this.scrollToFirstUnread();
        }
        this._scrollMode = null;
    }

    // renderedCallback() {
    //     // Scroll automático na renderização
    //     const container = this.template.querySelector('.chat-messages-container');
    //     const unread = this.template.querySelector('[data-unread="true"]');
    //     if (unread) {
    //         unread.scrollIntoView({ behavior: 'smooth', block: 'start' });
    //     } else if (container) {
    //         container.scrollTop = container.scrollHeight;
    //     }
    // }
}