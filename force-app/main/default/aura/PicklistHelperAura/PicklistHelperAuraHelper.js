({
	callApexControllerFunctionHelper: function(component, callerComponent, apexFunctionName, parameters) {
        if(!apexFunctionName || apexFunctionName === '') {
            console.error('Function name cannot be empty.');
        }
        return new Promise(
            $A.getCallback(
                function(onSuccess, onFailure) {
                    let action = component.get('c.' + apexFunctionName);
                    action.setParams(parameters);
                    action.setCallback(
                        component, 
                        function(response) {
                            let state = response.getState();
                            switch(state) {
                                case 'SUCCESS':
                                    onSuccess({component: callerComponent, returnValue: response.getReturnValue()});
                                break;
                                case 'ERROR':
                                    let errors = response.getError();
                                    console.error('An Apex exception has occured');
                                    if(errors && Array.isArray(errors) && errors.length > 0) {
                                        for(let i in errors) {
                                            onFailure(errors[i]);
                                        }
                                    } else {
                                        console.error('Unknown error');
                                    }
                                break;
                                default: 
                                    console.error(state + ' state not handled.');
                                break;
                            }
                        }
                    );
                    $A.enqueueAction(action);
                }
            )
        );
    }, 
})