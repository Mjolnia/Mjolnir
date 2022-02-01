import { LightningElement, api, track } from 'lwc';

import getFieldMetadata from '@salesforce/apex/RelatedListManagerController.getFieldMetadataApex';
import getData from '@salesforce/apex/RelatedListManagerController.getDataApex';
import saveRows from '@salesforce/apex/RelatedListManagerController.saveRowsApex';

import actions from '@salesforce/label/c.actions';
import save from '@salesforce/label/c.save';

export default class RelatedListManagerLWC extends LightningElement {
    label = {
        actions, 
        save
    };

    @api childSObjectAPIName;
    @api relationshipFieldName;
    @api relationshipFieldChildLabel;
    @api listOfSObjectFieldsString;
    @api picklistNoneLabel;
    @api iconName;

    @api recordId;

    @track awaitedAsyncAtInit = 2;
    @track reachedAsyncAtInit = 0;

    listOfSObjectFieldNames;
    listOfSObjectFieldNamesToQuery;
    @track listOfSObjectFieldMetadata;
    @track rows;
    rowsMapById;
    rowIndexMapById;
    rowIdsToDelete = [];
    rowCreatedTempMaxNumber = 0;
    timeFieldsToConvert;

    get reachedAsyncAtInitTestResult() {
        return this.reachedAsyncAtInit >= this.awaitedAsyncAtInit;
    }

    @api connectedCallback() {
        this.listOfSObjectFieldNames = this.listOfSObjectFieldsString.replace(/\s/g,'').split(',');
        
        getFieldMetadata(
            {
                sObjectName: this.childSObjectAPIName, 
                listOfFields: this.listOfSObjectFieldNames, 
                emptyPicklistLabel: this.picklistNoneLabel
            }
        ).then(
            result => this.onSuccessGetFieldMetadata(result)
        ).then(
            result => this.onSuccessGetRows(result)
        ).catch(
            error => this.errorHandling(error)
        );
    }

    saveRows() {
        this.reachedAsyncAtInit -= 2;

        let childSObjectAPIName = this.childSObjectAPIName;
        let timeFieldsToConvert = this.timeFieldsToConvert;
        let rowIdsToDelete = this.rowIdsToDelete;
        let rowsMapById = this.rowsMapById;

        let rowIds = Object.keys(rowsMapById);
        let rowsToInsert = [];
        let rowsToUpdate = [];
        let rowsToDelete = [];

        if(rowIds.length > 0) {
            rowIds.forEach(
                function(rowId) {
                    let row = rowsMapById[rowId];
                    
                    row.attributes = {type: childSObjectAPIName};
                    for(let i in timeFieldsToConvert) {
                        if(Object.prototype.hasOwnProperty.call(timeFieldsToConvert, i)) {
                            let timeFieldName = timeFieldsToConvert[i];
                            let data = row[timeFieldName];
                            
                            if(data && typeof data != 'number') {
                                let firstSplit = data.split('.');
                                let milliseconds = parseInt(firstSplit[1], 10);
                                let secondSplit = firstSplit[0].split(':');
                                let seconds = parseInt(secondSplit[2], 10);
                                let minutes = parseInt(secondSplit[1], 10);
                                let hours = parseInt(secondSplit[0], 10);
                                
                                row[timeFieldName] = (hours * 3600000) + (minutes * 60000) + (seconds * 60) + milliseconds;
                            }
                        }
                    }
                    if(rowIdsToDelete.indexOf(rowId) !== -1) {
                        if(!row.Id.startsWith('IPS')) {
                            rowsToDelete.push(row);
                        }
                    } else {
                        if(row.Id.startsWith('IPS')) {
                            delete row.Id;
                            rowsToInsert.push(row);
                        } else {
                            rowsToUpdate.push(row);
                        }
                    }
                }
            );
        }

		saveRows(
            {
                rowsToInsertJSON: JSON.stringify(rowsToInsert), 
                rowsToUpdateJSON: JSON.stringify(rowsToUpdate), 
                rowsToDeleteJSON: JSON.stringify(rowsToDelete)
            }
        ).then(
            result => this.onSuccessSaveRows(result)
        ).then(
            result => this.onSuccessGetRows(result)
        ).catch(
            error => this.errorHandling(error)
        );
    }

    createRow() {
        this.rowCreatedTempMaxNumber++;
        
        let row = {
            'attributes': {'type': this.childSObjectAPIName}, 
            'Id': 'IPS' + this.rowCreatedTempMaxNumber.toString()
        };
        row[this.relationshipFieldName] = this.recordId;

        this.rows.push(row);
        this.rowsMapById[row.Id] = row;
        this.rowIndexMapById[row.Id] = this.rows.length - 1;
    }

    cloneRow(event) {
        this.rowCreatedTempMaxNumber++;
        
        let rowId = event.target.value;
        let row = Object.assign({}, this.rowsMapById[rowId]);
        row.Id = 'IPS' + this.rowCreatedTempMaxNumber.toString();
        
        this.rows.push(row);
        this.rowsMapById[row.Id] = row;
        this.rowIndexMapById[row.Id] = this.rows.length - 1;
    }

    deleteRow(event) {
        let rowId = event.target.value;

        let rowIndex = this.rowIndexMapById[rowId];
        this.rows.splice(rowIndex, 1);
        this.rowIdsToDelete.push(rowId);

        this.rowIndexMapById = {};
        for(let i = 0; i < this.rows.length; i++) {
            this.rowIndexMapById[this.rows[i].Id] = i;
        }
    }
    
    onSuccessGetFieldMetadata(result) {
        this.reachedAsyncAtInit += 1;
        this.listOfSObjectFieldMetadata = result;

        this.timeFieldsToConvert = [];
        for(let i in this.listOfSObjectFieldMetadata) {
            if(Object.prototype.hasOwnProperty.call(this.listOfSObjectFieldMetadata, i)) {
                let fieldMetadata = this.listOfSObjectFieldMetadata[i];
                
                switch(fieldMetadata.dataType) {
                    case 'TIME':
                        this.timeFieldsToConvert.push(fieldMetadata.name);
                    break;
                    case 'PICKLIST':
                    case 'MULTIPICKLIST':
                    case 'REFERENCE': 
                    default:
                        
                    break;
                }
            }
        }

        this.listOfSObjectFieldNamesToQuery = this.listOfSObjectFieldNames.slice(0);
        this.listOfSObjectFieldNamesToQuery.push(this.relationshipFieldName);

        return getData(
            {
                fieldAPINames: this.listOfSObjectFieldNamesToQuery, 
                sObjectName: this.childSObjectAPIName, 
                whereClause: this.relationshipFieldName + ' = \'' + this.recordId + '\''
            }
        );
    }
	onSuccessSaveRows() {
        this.reachedAsyncAtInit += 1;
        
        return getData(
            {
                fieldAPINames: this.listOfSObjectFieldNamesToQuery, 
                sObjectName: this.childSObjectAPIName, 
                whereClause: this.relationshipFieldName + ' = \'' + this.recordId + '\''
            }
        );
    }
    onSuccessGetRows(result) {
        this.reachedAsyncAtInit += 1;
        this.rows = result;
        this.rowsMapById = {};
        this.rowIndexMapById = {};
        if(this.rows && Array.isArray(this.rows)) {
            for(let i = 0; i < this.rows.length; i++) {
                let row = this.rows[i];
                
                this.rowsMapById[row.Id] = row;
                this.rowIndexMapById[row.Id] = i;

                for(let j in this.listOfSObjectFieldMetadata) {
                    if(Object.prototype.hasOwnProperty.call(this.listOfSObjectFieldMetadata, j)) {
                        let fieldMetadata = this.listOfSObjectFieldMetadata[j];
                        let data = row[fieldMetadata.name];
                        switch(fieldMetadata.dataType) {
                            case 'TIME': {
                                let temp = data;
                                let milliseconds = temp % 1000;
                                temp = temp / 1000;
                                let seconds = temp % 60;
                                temp = temp / 60;
                                let minutes = temp % 60;
                                let hours = Math.floor(temp / 60);
                                
                                data = ((hours < 10) ? '0' : '') + hours.toString() + ':' 
                                    + ((minutes < 10) ? '0' : '') + minutes.toString() + ':' 
                                    + ((seconds < 10) ? '0' : '') + seconds.toString() + '.';
                                if(milliseconds < 10) {
                                    data += '00';
                                } else if(milliseconds < 100) {
                                    data += '0';
                                }
                                data += milliseconds.toString();
                                
                                row[fieldMetadata.name] = data;
                                break;
                            }
                            case 'PICKLIST':
                            case 'MULTIPICKLIST':
                            case 'REFERENCE': {
                                if(!data || data === null || data === '') {
                                    row[fieldMetadata.name] = '';
                                }
                                break;
                            }
                            default:
                                
                            break;
                        }
                    }
                }
            }
        }
    }
    
    handleRLMLWCValueHasChanged(event) {
        this.rowsMapById[event.detail.id][event.detail.field] = event.detail.value;
    }

    
    @api
    errorHandling(error) {
        if(error && error.body) {
            window.console.error(((error.body.errorCode) ? error.body.errorCode : 'APEX_ERROR') + ': ' + error.body.message);
            
            this.reachedAsyncAtInit = this.awaitedAsyncAtInit;
        }
    }
}