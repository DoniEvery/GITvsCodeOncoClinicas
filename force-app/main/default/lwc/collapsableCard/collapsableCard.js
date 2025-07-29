import { LightningElement, api } from 'lwc';

export default class CollapsableCard extends LightningElement {
	_showBody;
	_hideCollapse = false;

	@api showFooter;
    @api showHeader;
	@api iconName;
	@api iconSize;
	@api title;
	@api subtitle;
	@api thin;
	@api fullTitle;
    @api blockCollapse;

	@api get showBody() {
		return this._showBody;
	}

	set showBody(value) {
		this._showBody = value;
	}

	@api close() {
		this._showBody = false;
	}

	@api get hideCollapse() {
		return this._hideCollapse;
	}

	set hideCollapse(value) {
		this._hideCollapse = value;
	}

	toggleBody() {
        if (!this.blockCollapse) {
            this._showBody = !this._showBody;
        }
	}

	get headerClass() {
		return !this.thin ? 'slds-card__header slds-grid' : 'slds-card__header slds-grid thin-header';
	}

	get titleClass() {
		return !this.fullTitle ? 'slds-card__header-link slds-truncate' : 'slds-card__header-link';
	}

	get subtitleClass() {
		return !this.fullTitle ? 'slds-page-header__name-meta slds-truncate' : 'slds-page-header__name-meta';
	}



}