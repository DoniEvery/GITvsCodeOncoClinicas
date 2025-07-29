import { LightningElement, track } from 'lwc';

export default class AppSearchBar extends LightningElement {
    @track searchValue = ''; 

    handleInput(event) {
        this.searchValue = event.target.value;
    }

    handleKeyDown(event) {
        if(event.key === 'Enter') {
            this.handleSearch();
        }
    }

    handleSearch() {
        console.log('Buscando por:', this.searchValue);
    }
}