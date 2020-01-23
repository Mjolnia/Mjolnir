({
	getTranslationsJS: function(component, event, helper) {
		let parameters = event.getParam('arguments');
        return helper.callApexControllerFunctionHelper(
            component, 
            'getTranslationsAura', 
            {
                'listOfSObjects': parameters.listOfSObjects
            }
        );
	}, 
	callApexControllerFunctionHelperJS: function(component, event, helper) {
        let parameters = event.getParam('arguments');
        return helper.callApexControllerFunctionHelper(
            parameters.callerComponent, 
            parameters.apexFunctionName, 
            parameters.parameters
        );
	}, 
	onFailureDefaultHelper: function(component, event, helper) {
		let parameters = event.getParam('arguments');
        return helper.onFailureDefault(
            parameters.response
        );
	}, 
})