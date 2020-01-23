public class AuraHelperController {
    public static Map<String,Map<String,String>> getTranslations(List<String> listOfSObjects) {
        System.debug(listOfSObjects);
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
    public static Map<String,Map<String,String>> getTranslationsAura(List<String> listOfSObjects) {
        try {
            return getTranslations(listOfSObjects);
        } catch(Exception error) {
            System.debug(error.getStackTraceString());
            throw new AuraHandledException(error.getMessage());
        }
    }
}