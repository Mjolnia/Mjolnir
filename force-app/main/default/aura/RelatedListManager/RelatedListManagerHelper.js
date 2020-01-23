({
	onSuccessGetFieldMetadata: function(result) {
        let component = result.component;
        let response = result.response;
        
        component.set('v.reachedAsyncAtInit', component.get('v.reachedAsyncAtInit') + 1);
        let listOfSObjectFieldMetadata = response.getReturnValue();
        let timeFieldsToConvert = [];
        for(let i in listOfSObjectFieldMetadata) {
            let fieldMetadata = listOfSObjectFieldMetadata[i];
            
            switch(fieldMetadata.dataType) {
                case 'TIME':
                    timeFieldsToConvert.push(fieldMetadata.name);
                break;
                case 'PICKLIST':
                case 'MULTIPICKLIST':
                case 'REFERENCE':
                    let options = [];
                    if(fieldMetadata.isRequired == false) {
                        options.push(
                            {
                                value: '', 
                                label: component.get('v.picklistNoneLabel')
                            }
                        );
                    }
                    if(fieldMetadata.picklistLabelsByValuesMap) {
                        let keys = Object.keys(fieldMetadata.picklistLabelsByValuesMap);
                        for(let i in keys) {
                            let value = keys[i];
                            let label = fieldMetadata.picklistLabelsByValuesMap[value];
                            
                            options.push(
                                {
                                    value: value, 
                                    label: label
                                }
                            );
                        }
                    }
                    
                    fieldMetadata.options = options;
                break;
                default:
                    
                break;
            }
        }
        
        component.set('v.listOfSObjectFieldMetadata', listOfSObjectFieldMetadata);
        component.set('v.timeFieldsToConvert', timeFieldsToConvert);
        
        return component.find('libAuraHelper').callApexControllerFunction(
            component, 
            'getRowsApex', 
            {
                recordId: component.get('v.recordId'), 
                sObjectName: component.get('v.childSObjectAPIName'), 
                relationshipField: component.get('v.relationshipFieldName'), 
                listOfFields: component.get('v.listOfSObjectFieldNames')
            }
        );
    }, 
	onSuccessSaveRows: function(result) {
        let component = result.component;
        let response = result.response;
        
        component.set('v.reachedAsyncAtInit', component.get('v.reachedAsyncAtInit') + 1);
        
        return component.find('libAuraHelper').callApexControllerFunction(
            component, 
            'getRowsApex', 
            {
                recordId: component.get('v.recordId'), 
                sObjectName: component.get('v.childSObjectAPIName'), 
                relationshipField: component.get('v.relationshipFieldName'), 
                listOfFields: component.get('v.listOfSObjectFieldNames')
            }
        );
    }, 
    onSuccessGetRows: function(result) {
        let component = result.component;
        let response = result.response;
        
    	component.set('v.reachedAsyncAtInit', component.get('v.reachedAsyncAtInit') + 1);
    	component.set('v.rows', response.getReturnValue());
        
        let rows = component.get('v.rows');
        
        let rowsMapById = {};
        let rowIndexMapById = {};
        if(rows && Array.isArray(rows)) {
            for(let i = 0; i < rows.length; i++) {
                let row = rows[i];
                
                rowsMapById[row.Id] = row;
                rowIndexMapById[row.Id] = i;
            }
        }
        component.set('v.rowsMapById', rowsMapById);
        component.set('v.rowIndexMapById', rowIndexMapById);
	}, 
})