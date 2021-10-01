/**
 * @author Jeremy SML
 * @author Davy LAURENT
 * @version 2.0
 */
global class PicklistHelper {
    private static final String BASE_64_MAP = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    
    /**
     * Generate the List of picklist field value.
     * 
     * @param final String sObjectName             	The API Name of the sObject
     * @param final String fieldName                The API Name of the field
     * @return List<String>                         The builted List
     */
    global static List<String> getPicklistValues(final String sObjectName, final String fieldName) {
        List<String> generatedList = new List<String>();
        for(Schema.PicklistEntry row: Schema.getGlobalDescribe()
            .get(sObjectName)
            .getDescribe()
            .fields
            .getMap()
            .get(fieldName)
            .getDescribe()
            .getPicklistValues()
        ) {
            if(row.isActive()) {
                generatedList.add(row.getValue());
            }
        }
        return generatedList;
    }
    
    @auraEnabled
    global static List<String> getPicklistValuesAura(final String sObjectName, final String fieldName) {
        try {
            return getPicklistValues(sObjectName, fieldName);
        } catch(Exception error) {
            System.debug(LoggingLevel.ERROR, error.getStackTraceString());
            System.debug(LoggingLevel.ERROR, error.getMessage());
            throw new AuraHandledException(error.getMessage());
        }
    }
    
    /**
     * Generate the Set of picklist field value.
     * 
     * @param final String sObjectName              The API Name of the sObject
     * @param final String fieldName                The API Name of the field
     * @return Set<String>                          The builted Set
     */
    global static Set<String> getPicklistValuesSet(final String sObjectName, final String fieldName) {
        Set<String> generatedSet = new Set<String>();
        for(Schema.PicklistEntry row: Schema.getGlobalDescribe()
            .get(sObjectName)
            .getDescribe()
            .fields
            .getMap()
            .get(fieldName)
            .getDescribe()
            .getPicklistValues()
        ) {
            if(row.isActive()) {
                generatedSet.add(row.getValue());
            }
        }
        return generatedSet;
    }

    /**
     * Generate map based on picklist field.
     * 
     * @param final String sObjectName              The API Name of the sObject
     * @param final String fieldName                The API Name of the field
     * @return Map<String,String>                   The builted map
     */
    global static Map<String, String> getPicklistLabelByValueMap(
        final String sObjectName,
        final String fieldName
    ) {
        Map<String,String> generatedMap = new Map<String,String>();
        for(Schema.PicklistEntry row: Schema.getGlobalDescribe()
            .get(sObjectName)
            .getDescribe()
            .fields
            .getMap()
            .get(fieldName)
            .getDescribe()
            .getPickListValues()
        ) {
            if(row.isActive()) {
                generatedMap.put(row.getValue(), row.getLabel());
            }
        }
        return generatedMap;
    }
    
    @auraEnabled
    global static Map<String, String> getPicklistLabelByValueMapAura(final String sObjectName, final String fieldName) {
        try {
            return getPicklistLabelByValueMap(sObjectName, fieldName);
        } catch(Exception error) {
            System.debug(LoggingLevel.ERROR, error.getStackTraceString());
            System.debug(LoggingLevel.ERROR, error.getMessage());
            throw new AuraHandledException(error.getMessage());
        }
    }
    
    /**
     * Retrieve the picklist dependency of a field with sObject API name and field API name.
     * 
     * @param String sObjectName 							The sObject name of the picklist field.
     * @param String sObjectName 							The picklist field name.
     * @return Map<String, Map<String, String>>				The built dependency.
     */
    global static Map<String, Map<String, String>> getDependentPicklistValues(final String sObjectName, final String dependantFieldName) {
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);
        if(sObjectType == null) {
            return new Map<String, Map<String, String>>();
        }
        Schema.SObjectField dependantFieldSchema = sObjectType.getDescribe().fields.getMap().get(dependantFieldName);
        if(dependantFieldSchema != null) {
            return getDependentPicklistValues(dependantFieldSchema);
        }
        return new Map<String, Map<String, String>>();
    }
    
    @auraEnabled
    global static Map<String, Map<String, String>> getDependentPicklistValuesAura(final String sObjectName, final String dependantFieldName) {
        try {
            return getDependentPicklistValues(sObjectName, dependantFieldName);
        } catch(Exception error) {
            System.debug(LoggingLevel.ERROR, error.getStackTraceString());
            System.debug(LoggingLevel.ERROR, error.getMessage());
            throw new AuraHandledException(error.getMessage());
        }
    }
    
    /**
     * Retrieve the picklist dependency of a field.
     * WARNING : This code cannot be covered properly due to picklist dependencies does not exists in Salesforce standard.
     * 
     * @param Schema.SObjectField dependantFieldSchema 		The picklist field.
     * @return Map<String, Map<String, String>>				The built dependency.
     */
    global static Map<String, Map<String,String>> getDependentPicklistValues(Schema.SObjectField dependantFieldSchema) {
        Map<String, Map<String,String>> dependentPicklistValues = new Map<String, Map<String,String>>();
        
        Schema.DescribeFieldResult dependantField = dependantFieldSchema.getDescribe();
        Schema.SObjectField controllingFieldSchema = dependantField.getController();
        
        if(controllingFieldSchema == null) {
            return dependentPicklistValues;
        }
        
        List<Schema.PicklistEntry> controlEntries = controllingFieldSchema.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry : dependantField.getPicklistValues()) {
            if(entry.isActive()) {
                Map<String,Object> dependantFieldData = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry));
                String dependantFieldDataString = String.valueOf(dependantFieldData.get('validFor'));
                
                if(String.isNotEmpty(dependantFieldDataString)) {
                    List<String> base64chars = dependantFieldDataString.split('');
                    for(Integer index = 0; index < controlEntries.size(); index++) {
                        if((BASE_64_MAP.indexOf(base64chars[index / 6]) & (1 << (5 - Math.mod(index, 6)))) != 0) {
                            Schema.PicklistEntry controlEntry = controlEntries[index];
                            if(controlEntry.isActive()) {
                                String controlEntryValue = controlEntry.getValue();
                                if(dependentPicklistValues.containsKey(controlEntryValue)) {
                                    dependentPicklistValues.get(controlEntryValue).put(entry.getValue(), entry.getLabel());
                                } else {
                                    dependentPicklistValues.put(
                                        controlEntryValue, 
                                        new Map<String, String>{entry.getValue() => entry.getLabel()}
                                    );
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return dependentPicklistValues;
    }
}