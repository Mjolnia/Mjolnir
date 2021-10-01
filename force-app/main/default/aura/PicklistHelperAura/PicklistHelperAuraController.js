({
	getPicklistValuesAuraJS: function(component, event, helper) {
        let parameters = event.getParam('arguments');
        return helper.callApexControllerFunctionHelper(
            component,
            parameters.callerComponent, 
            'getPicklistValuesAura', 
            {
                'sObjectName': parameters.sObjectName, 
                'fieldName': parameters.fieldName
            }
        );
	}, 
	getPicklistLabelByValueMapAuraJS: function(component, event, helper) {
        let parameters = event.getParam('arguments');
        return helper.callApexControllerFunctionHelper(
            component,
            parameters.callerComponent, 
            'getPicklistLabelByValueMapAura', 
            {
                'sObjectName': parameters.sObjectName, 
                'fieldName': parameters.fieldName
            }
        );
	}, 
	getDependentPicklistValuesAuraJS: function(component, event, helper) {
        let parameters = event.getParam('arguments');
        return helper.callApexControllerFunctionHelper(
            component,
            parameters.callerComponent, 
            'getDependentPicklistValuesAura', 
            {
                'sObjectName': parameters.sObjectName, 
                'dependantFieldName': parameters.dependantFieldName
            }
        );
	}, 
})