({
    insertSObjectsJS: function(component, event, helper) {
        let parameters = event.getParam('arguments');
        return helper.callApexControllerFunctionHelper(
            component,
            parameters.callerComponent, 
            'insertSObjectsApex', 
            {
                'rowsToInsertJSON': (
                    (parameters.rowsToInsert && parameters.rowsToInsert.length > 0) 
                    ? JSON.stringify(parameters.rowsToInsert) 
                    : '[]'
                )
            }
        );
    }, 
    updateSObjectsJS: function(component, event, helper) {
        let parameters = event.getParam('arguments');
        return helper.callApexControllerFunctionHelper(
            component,
            parameters.callerComponent,  
            'updateSObjectsApex', 
            {
                'rowsToUpdateJSON': (
                    (parameters.rowsToUpdate && parameters.rowsToUpdate.length > 0) 
                    ? JSON.stringify(parameters.rowsToUpdate) 
                    : '[]'
                )
            }
        );
    }, 
    deleteSObjectsJS: function(component, event, helper) {
        let parameters = event.getParam('arguments');
        return helper.callApexControllerFunctionHelper(
            component,
            parameters.callerComponent, 
            'deleteSObjectsApex', 
            {
                'rowsToDeleteJSON': (
                    (parameters.rowsToDelete && parameters.rowsToDelete.length > 0) 
                    ? JSON.stringify(parameters.rowsToDelete) 
                    : '[]'
                )
            }
        );
    }, 
})