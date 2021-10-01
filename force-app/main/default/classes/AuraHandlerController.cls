global class AuraHandlerController {
    @testVisible
    private static Map<String,Map<String,String>> getTranslations(List<String> listOfSObjects) {
        Map<String,Map<String,String>> translations = new Map<String,Map<String,String>>();
        
        for(String sObjectAPIName: listOfSObjects) {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectAPIName);
            
            if(sObjectType != null) {
            	Schema.DescribeSObjectResult sObjectDescribe = Schema.getGlobalDescribe().get(sObjectAPIName).getDescribe();
            	Map<String,Schema.SObjectField> sObjectFields = sObjectDescribe.fields.getMap();
                
                Map<String, String> translationsOfSObject = new Map<String, String>();
                translationsOfSObject.put('Label', sObjectDescribe.getLabel());
                translationsOfSObject.put('LabelPlural', sObjectDescribe.getLabelPlural());
                
                for(Schema.SObjectField sObjectField: sObjectFields.values()) {
                    Schema.DescribeFieldResult sObjectFieldDescribe = sObjectField.getDescribe();
                    translationsOfSObject.put(sObjectFieldDescribe.getLocalName(), sObjectFieldDescribe.getLabel());
                }
                
                translations.put(sObjectDescribe.getLocalName(), translationsOfSObject);
            }
        }
        
        return translations;
    }
    
    @auraEnabled
    global static Map<String,Map<String,String>> getTranslationsAura(List<String> listOfSObjects) {
        try {
            return getTranslations(listOfSObjects);
        } catch(Exception error) {
            System.debug(error.getStackTraceString());
            System.debug(error.getMessage());
            throw new AuraHandledException(error.getMessage());
        }
    }
}