import { LightningElement, api } from 'lwc';

export default class LightningInputConfigurationLWC extends LightningElement {
    @api fieldMetadata;
    @api sObject;
    
    value;

    get isBoolean() {
        return this.fieldMetadata.dataType === 'BOOLEAN';
    }

    get isString() {
        return this.fieldMetadata.dataType === 'STRING';
    }

    get isEmail() {
        return this.fieldMetadata.dataType === 'EMAIL';
    }

    get isPhone() {
        return this.fieldMetadata.dataType === 'PHONE';
    }

    get isURL() {
        return this.fieldMetadata.dataType === 'URL';
    }

    get isInteger() {
        return this.fieldMetadata.dataType === 'INTEGER';
    }

    get isDouble() {
        return this.fieldMetadata.dataType === 'DOUBLE';
    }

    get isCurrency() {
        return this.fieldMetadata.dataType === 'CURRENCY';
    }

    get isPercent() {
        return this.fieldMetadata.dataType === 'PERCENT';
    }

    get isDate() {
        return this.fieldMetadata.dataType === 'DATE';
    }

    get isDateTime() {
        return this.fieldMetadata.dataType === 'DATETIME';
    }

    get isTime() {
        return this.fieldMetadata.dataType === 'TIME';
    }

    get isPicklist() {
        return this.fieldMetadata.dataType === 'PICKLIST';
    }

    get isMultiPicklist() {
        return this.fieldMetadata.dataType === 'MULTIPICKLIST';
    }

    get isReference() {
        return this.fieldMetadata.dataType === 'REFERENCE';
    }

    @api connectedCallback() {
		this.value = this.sObject[this.fieldMetadata.name];
        this.id = this.sObject.Id;
    }
    
	onChangeData(event) {
        this.value = event.detail.value;

        this.dispatchEvent(
            new CustomEvent(
                'rlmlwcvaluehaschanged', 
                {
                    detail: {
                        id: this.sObject.Id, 
                        field: this.fieldMetadata.name, 
                        value: this.value
                    }
                }
            )
        );
	}
}