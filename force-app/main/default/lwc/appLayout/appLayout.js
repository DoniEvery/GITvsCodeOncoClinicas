import { LightningElement } from 'lwc';

//Componente desativado
export default class AppLayout extends LightningElement {
    currentPage = 'Início';

    handleMenuSelection(event) {
    this.currentPage = event.detail;
}

}