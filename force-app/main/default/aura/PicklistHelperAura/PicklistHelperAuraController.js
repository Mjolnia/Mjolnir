({
	getPicklistValuesAuraJS: function(component, event, helper) {
        let libAuraHelper = component.find('libAuraHelper');
        let parameters = event.getParam('arguments');
		return libAuraHelper.callApexControllerFunction(
            component, 
            'getPicklistValuesAura', 
            {
                'sObjectName': parameters.sObjectName, 
                'fieldName': parameters.fieldName
            }
        );
	}, 
	getPicklistLabelByValueMapAuraJS: function(component, event, helper) {
        let libAuraHelper = component.find('libAuraHelper');
        let parameters = event.getParam('arguments');
		return libAuraHelper.callApexControllerFunction(
            component, 
            'getPicklistLabelByValueMapAura', 
            {
                'sObjectName': parameters.sObjectName, 
                'fieldName': parameters.fieldName
            }
        );
	}, 
	getDependentPicklistValuesAuraJS: function(component, event, helper) {
        let libAuraHelper = component.find('libAuraHelper');
        let parameters = event.getParam('arguments');
		return libAuraHelper.callApexControllerFunction(
            component, 
            'getDependentPicklistValuesAura', 
            {
                'sObjectName': parameters.sObjectName, 
                'dependantFieldName': parameters.dependantFieldName
            }
        );
	}, 
})