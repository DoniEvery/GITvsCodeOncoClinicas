import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import atualizarPerfil from '@salesforce/apex/APP_UserProfileController.atualizarPerfil';

import FIRSTNAME_FIELD from '@salesforce/schema/User.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/User.LastName';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import MOBILE_FIELD from '@salesforce/schema/User.MobilePhone';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import PHOTO_URL from '@salesforce/schema/User.FullPhotoUrl';

const FIELDS = [FIRSTNAME_FIELD, LASTNAME_FIELD, EMAIL_FIELD, MOBILE_FIELD, PHONE_FIELD, PHOTO_URL];

export default class AppUserProfileForm extends LightningElement {
    userId = USER_ID;
    userPhotoUrl = '';
    userFirstName = '';
    userLastName = '';
    userEmail = '';
    userMobilePhone = '';
    userPhone = '';
    firstName = '';
    lastName = '';
    email = '';
    mobilePhone = '';
    phone = '';
    isReady = false;
    isEditing = false;
    isLoading = false;
    emailEhAuto = false;

    @wire(getRecord, { recordId: '$userId', fields: FIELDS })
    wiredUser({ error, data }) {
        if (data) {
            this.firstName = data.fields.FirstName.value || '';
            this.lastName = data.fields.LastName.value || '';
            const emailValue = data.fields.Email.value || '';
            this.emailEhAuto = emailValue.includes('cliente.onco.');
            this.email = this.emailEhAuto ? '' : emailValue;
            this.mobilePhone = data.fields.MobilePhone.value || '';
            this.phone = data.fields.Phone.value || '';
            this.userPhotoUrl = data.fields.FullPhotoUrl.value || '';
            this.isReady = true;
            this.userFirstName = this.firstName;
            this.userLastName = this.lastName;
            this.userEmail = this.email;
            this.userMobilePhone = this.mobilePhone;
            this.userPhone = this.phone;
        } else if (error) {
            this.showToast('Erro', 'Falha ao carregar dados do usuário.', 'error');
            this.isReady = true;
        }
    }

    handleEditClick() {
        this.isEditing = true;
    }

    handleCancel() {
        this.firstName = this.userFirstName;
        this.lastName = this.userLastName;
        this.email = this.userEmail;
        this.mobilePhone = this.userMobilePhone;
        this.phone = this.userPhone;
        this.isEditing = false;
        this.isLoading = false;
    }

    handleInputChange(event) {
        const field = event.target.name;
        this[field.charAt(0).toLowerCase() + field.slice(1)] = event.target.value;
    }

    handleSave() {
        this.isLoading = true;

        const inputs = Array.from(this.template.querySelectorAll('lightning-input'));
        if (!inputs || inputs.length === 0) {
            this.showToast('Erro', 'Falha interna: campos não encontrados.', 'error');
            this.isLoading = false;
            return;
        }

        const getInputByName = (name) => inputs.find(i => i.name === name);

        const nomeInput = getInputByName('FirstName');
        const sobrenomeInput = getInputByName('LastName');
        const emailInput = getInputByName('Email');
        const celularInput = getInputByName('MobilePhone');

        if (!nomeInput || !sobrenomeInput || !emailInput || !celularInput) {
            this.showToast('Erro', 'Erro ao carregar os campos. Tente novamente.', 'error');
            this.isLoading = false;
            return;
        }

        let isValid = true;

        if (!this.firstName) {
            nomeInput.setCustomValidity('Nome é obrigatório.');
            isValid = false;
        } else {
            nomeInput.setCustomValidity('');
        }

        if (!this.lastName) {
            sobrenomeInput.setCustomValidity('Sobrenome é obrigatório.');
            isValid = false;
        } else {
            sobrenomeInput.setCustomValidity('');
        }

        if (!this.emailEhAuto && !this.email) {
            emailInput.setCustomValidity('E-mail é obrigatório.');
            isValid = false;
        } else {
            emailInput.setCustomValidity('');
        }

        if (!this.mobilePhone) {
            celularInput.setCustomValidity('Celular é obrigatório.');
            isValid = false;
        } else {
            celularInput.setCustomValidity('');
        }

        inputs.forEach(input => input.reportValidity());

        if (!isValid) {
            this.isLoading = false;
            return;
        }

        const emailParaSalvar = this.emailEhAuto ? null : this.email;

        atualizarPerfil({
            firstName: this.firstName,
            lastName: this.lastName,
            phone: this.phone,
            mobilePhone: this.mobilePhone,
            email: emailParaSalvar
        })
            .then(() => {
                this.showToast('Sucesso', 'Perfil atualizado com sucesso!', 'success');
                this.isEditing = false;
                this.isLoading = false;
            })
            .catch(() => {
                this.showToast('Erro', 'Falha ao salvar. Verifique os campos e tente novamente.', 'error');
                this.isEditing = true;
                this.isLoading = false;
            });
    }

    get name() {
        return `${this.firstName} ${this.lastName}`.trim();
    }

    get emailEhObrigatorio() {
        return !this.emailEhAuto;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant,
                mode: 'dismissable'
            })
        );
    }
}