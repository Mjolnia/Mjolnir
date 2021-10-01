({
	getSelectFieldsFromSObjectJS: function(component, event, helper) {
        let parameters = event.getParam('arguments');
        return helper.callApexControllerFunctionHelper(
            component,
            parameters.callerComponent, 
            'getSelectFieldsFromSObjectAura', 
            {
                fieldNameSet: parameters.fieldNameSet,
                sObjectName: parameters.sObjectName,
                usingScopeClause: parameters.usingScopeClause, 
                whereClause: parameters.whereClause,
                withClause: parameters.withClause,
                groupByClause: parameters.groupByClause,
                havingClause: parameters.havingClause,
                orderByClause: parameters.orderByClause,
                limitClause: parameters.limitClause,
                offsetClause: parameters.offsetClause,
                forClause: parameters.forClause,
                updateClause: parameters.updateClause
            }
        );
    }, 
    searchInSObjectsJS: function(component, event, helper) {
        let parameters = event.getParam('arguments');
        return helper.callApexControllerFunctionHelper(
            component,
            parameters.callerComponent, 
            'searchInSObjectsAura', 
            {
                fieldNameSet: parameters.fieldNameSet,
                searchString: parameters.searchString,
                inClause: parameters.inClause,
                returningClause: parameters.returningClause,
                withClauses: parameters.withClauses,
                limitClause: parameters.limitClause,
                updateClause: parameters.updateClause
            }
        );
    }, 
})