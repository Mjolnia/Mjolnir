({
	doInit: function(component, event, helper) {
		let libAuraHelper = component.find('libAuraHelper');
		let libPicklistHelper = component.find('libPicklistHelperAura');
        
        libPicklistHelper.getPicklistValues(
            'Account', 
            'Controlling_field__c'
        ).then(
            function(response) {
                console.log(JSON.stringify(response.getReturnValue()));
                return libPicklistHelper.getPicklistLabelByValueMap(
            		'Account', 
            		'Dependant_field__c'
        		)
    		}, 
            libAuraHelper.onFailureDefault
        ).then(
            function(response) {
                console.log(JSON.stringify(response.getReturnValue()));
                return libPicklistHelper.getDependentPicklistValues(
            		'Account', 
            		'Dependant_field__c'
        		)
            }, 
            libAuraHelper.onFailureDefault
        ).then(
            function(response) {
                console.log(JSON.stringify(response.getReturnValue()));
                return libAuraHelper.getTranslations(
            		['Account','Contact']
        		)
            }, 
            libAuraHelper.onFailureDefault
        ).then(
            function(response) {
                console.log(JSON.stringify(response.getReturnValue()));
            }, 
            libAuraHelper.onFailureDefault
        );
	}
})