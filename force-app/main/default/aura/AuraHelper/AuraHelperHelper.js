({
	callApexControllerFunctionHelper: function(callerComponent, apexFunctionName, parameters) {
        if(!apexFunctionName || apexFunctionName === '') {
            console.error('Function name cannot be empty.');
        }
        return new Promise(
            $A.getCallback(
                function(onSuccess, onFailure) {
                    let action = callerComponent.get('c.' + apexFunctionName);
                    action.setParams(parameters);
                    action.setCallback(
                        callerComponent, 
                        function(response) {
                            let state = response.getState();
                            switch(state) {
                                case 'SUCCESS':
                                    onSuccess({response: response, component: callerComponent});
                                break;
                                case 'ERROR':
                                    onFailure(response);
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
    onFailureDefaultHelper: function(response) {
        console.error('An Apex exception has occured');
        let errors = response.getError();
        if(errors) {
            for(let i in errors) {
                console.error(errors[i]);
            }
        }
        return response;
    }, 
})