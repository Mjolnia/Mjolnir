({
	doInit: function(component, event, helper) {
		let libAuraHelper = component.find('libAuraHelper');
		let libPicklistHelper = component.find('libPicklistHelperAura');
		let libDatabaseRequester = component.find('libDatabaseRequester');
        
        libPicklistHelper.getPicklistValues(
            'Account', 
            'mjlnr__Active__c'
        ).then(
            function(result) {
                let component = result.component;
                let returnValue = result.returnValue;

                console.log(JSON.stringify(returnValue));
                return libPicklistHelper.getPicklistLabelByValueMap(
            		'Account', 
            		'mjlnr__Active__c'
        		);
            }
        ).then(
            function(result) {
                let component = result.component;
                let returnValue = result.returnValue;

                console.log(JSON.stringify(returnValue));
                return libPicklistHelper.getDependentPicklistValues(
            		'Account', 
            		'Industry'
        		);
            }
        ).then(
            function(result) {
                let component = result.component;
                let returnValue = result.returnValue;
                
                console.log(JSON.stringify(returnValue));
                return libAuraHelper.getTranslations(
            		['Account', 'Contact']
        		);
            }
        ).then(
            function(result) {
                let component = result.component;
                let returnValue = result.returnValue;
                
                console.log(JSON.stringify(returnValue));
                return libDatabaseRequester.getSelectFieldsFromSObject(
                    component, 
                    ['Id', 'Name'], 
                    'Account'
        		);
            }
        ).then(
            function(result) {
                let component = result.component;
                let returnValue = result.returnValue;

                console.log(JSON.stringify(returnValue));
            }
        ).catch(
            function(error) {
                console.error(error.message);
            }
        );
	}
})