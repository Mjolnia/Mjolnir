({
	doInit: function(component, event, helper) {
        let fieldMetadata = component.get('v.fieldMetadata');
        let data = component.get('v.sObject')[fieldMetadata.name];
        if(data) {
            switch(fieldMetadata.dataType) {
                case 'TIME':
                    let temp = data;
                    let milliseconds = temp % 1000;
                    temp = temp / 1000;
                    let seconds = temp % 60;
                    temp = temp / 60;
                    let minutes = temp % 60;
                    let hours = Math.floor(temp / 60);
                    
                    data = ((hours < 10) ? '0' : '') + hours.toString() + ':' 
                        + ((minutes < 10) ? '0' : '') + minutes.toString() + ':' 
                        + ((seconds < 10) ? '0' : '') + seconds.toString() + '.';
                    if(milliseconds < 10) {
                        data += '00';
                    } else if(milliseconds < 100) {
                        data += '0';
                    }
                    data += milliseconds.toString();
                break;
                default:
                    
                break;
            }
        }
		component.set('v.value', data);
	}, 
	onChangeData: function(component, event, helper) {
        component.get('v.sObject')[component.get('v.fieldMetadata').name] = component.get('v.value');
	}, 
})