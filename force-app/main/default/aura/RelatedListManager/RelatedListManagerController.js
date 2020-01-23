({
	doInit: function(component, event, helper) {
		let libAuraHelper = component.find('libAuraHelper');
        
        let listOfSObjectFieldNames = component.get('v.listOfSObjectFieldsString').replace(/\s/g,'').split(',');
        
        component.set('v.listOfSObjectFieldNames', listOfSObjectFieldNames);
        
		libAuraHelper.callApexControllerFunction(
            component, 
            'getFieldMetadataApex', 
            {
                sObjectName: component.get('v.childSObjectAPIName'), 
                listOfFields: component.get('v.listOfSObjectFieldNames')
            }
        ).then(
            helper.onSuccessGetFieldMetadata, 
            libAuraHelper.onFailureDefault
        ).then(
            helper.onSuccessGetRows, 
            libAuraHelper.onFailureDefault
        ).catch(
            function(error) {
                console.error(error.message);
            }
        );
	}, 
    saveRowsController: function(component, event, helper) {
        component.set('v.reachedAsyncAtInit', component.get('v.reachedAsyncAtInit') - 2);
        let childSObjectAPIName = component.get('v.childSObjectAPIName');
        let rowsMapById = component.get('v.rowsMapById');
        let rowIdsToDelete = component.get('v.rowIdsToDelete');
        let timeFieldsToConvert = component.get('v.timeFieldsToConvert');
        let rowIds = Object.keys(rowsMapById);
        let rowsToInsert = [];
        let rowsToUpdate = [];
        let rowsToDelete = [];
        
        if(rowIds.length > 0) {
            rowIds.forEach(function (rowId) {
                let row = rowsMapById[rowId];
                
                row.attributes = {type: childSObjectAPIName};
                for(let i in timeFieldsToConvert) {
                    let timeFieldName = timeFieldsToConvert[i];
                    let data = row[timeFieldName];
                    
                    if(data && typeof data != 'number') {
                        let firstSplit = data.split('.');
                        let milliseconds = parseInt(firstSplit[1]);
                        let secondSplit = firstSplit[0].split(':');
                        let seconds = parseInt(secondSplit[2]);
                        let minutes = parseInt(secondSplit[1]);
                        let hours = parseInt(secondSplit[0]);
                        
                        row[timeFieldName] = (hours * 3600000) + (minutes * 60000) + (seconds * 60) + milliseconds;
                    }
                }
                if(rowIdsToDelete.indexOf(rowId) != -1) {
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
            });
        }
        
        let libAuraHelper = component.find('libAuraHelper');
		libAuraHelper.callApexControllerFunction(
            component, 
            'saveRowsApex', 
            {
                rowsToInsertJSON: JSON.stringify(rowsToInsert), 
                rowsToUpdateJSON: JSON.stringify(rowsToUpdate), 
                rowsToDeleteJSON: JSON.stringify(rowsToDelete)
            }
        ).then(
            helper.onSuccessSaveRows, 
            libAuraHelper.onFailureDefault
        ).then(
            helper.onSuccessGetRows, 
            libAuraHelper.onFailureDefault
        ).catch(
            function(error) {
                console.error(error.message);
            }
        );
    },
    createRow: function(component, event, helper) {
        let rowCreatedTempMaxNumber = component.get('v.rowCreatedTempMaxNumber');
        
        let rows = component.get('v.rows');
        
        rowCreatedTempMaxNumber++;
        
        let row = {
            'attributes': {'type': component.get('v.childSObjectAPIName')}, 
            'Id': 'IPS' + rowCreatedTempMaxNumber.toString()
        };
        row[component.get('v.relationshipFieldName')] = component.get('v.recordId');
        
        rows.push(row);
        component.set('v.rows', rows);
        component.get('v.rowsMapById')[row.Id] = row;
        component.get('v.rowIndexMapById')[row.Id] = rows.length - 1;
        component.set('v.rowCreatedTempMaxNumber', rowCreatedTempMaxNumber);
    },
    cloneRow: function(component, event, helper) {
        let rowCreatedTempMaxNumber = component.get('v.rowCreatedTempMaxNumber');
        
        let rows = component.get('v.rows');
        
        rowCreatedTempMaxNumber++;
        
        let rowId = event.getSource().get('v.value').replace('clone-', '');
        let rowsMapById = component.get('v.rowsMapById');
        let rowIndexMapById = component.get('v.rowIndexMapById');
        let row = Object.assign({}, rowsMapById[rowId]);
        row.Id = 'IPS' + rowCreatedTempMaxNumber.toString();
        
        rows.push(row);
        component.set('v.rows', rows);
        rowsMapById[row.Id] = row;
        rowIndexMapById[row.Id] = rows.length - 1;
        component.set('v.rowCreatedTempMaxNumber', rowCreatedTempMaxNumber);
    },
    deleteRow: function(component, event, helper) {
        let rowId = event.getSource().get('v.value').replace('delete-', '');
        let rows = component.get('v.rows');
        let rowsMapById = component.get('v.rowsMapById');
        let rowIndexMapById = component.get('v.rowIndexMapById');
        let rowIndex = rowIndexMapById[rowId];
        rows.splice(rowIndex, 1);
        component.get('v.rowIdsToDelete').push(rowId);
        component.set('v.rows', rows);
        delete rowIndexMapById[rowId];
        for(let i = rowIndex; i < rows.length; i++) {
            rowIndexMapById[rows[i].Id] = i;
        }
    },
})