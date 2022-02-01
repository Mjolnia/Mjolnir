/**
 * This class has been made to replace data on an sObject by other data, 
 * depending the constraints of the object or the fields.
 *
 * @author Davy LAURENT
 * @version 2.0
 */
public without sharing class AnonymizationDatabase {
    private class NullParameterException extends Exception {}
    private class NotAnSObjectException extends Exception {}
    private class SObjectFieldNotFoundException extends Exception {}
    private class RequiredFieldMissingException extends Exception {}
    private class WrongDataTypeException extends Exception {}
    private class WrongPicklistElementException extends Exception {}
    
    private Map<Id,sObject> dataToAnonymize;
    private Map<String,Object> dataToUseForAnonymizationByField;
    private Set<String> fieldsToTreat;
    
    private Map<String,Schema.SObjectField> sObjectFields;
    private String sObjectAPIName;
    
    /*
     * Main constructor for this class.
     *
     * @param List<sObject> dataToAnonymize                             Data you want to replace
     * @param Map<String,Object> dataToUseForAnonymizationByField       Data you want to put inside the sObjects
     * @param Set<String> fieldsToTreat                                 Set of field API names to be treated
     */
    public AnonymizationDatabase(
        List<sObject> dataToAnonymize, 
        Map<String,Object> dataToUseForAnonymizationByField, 
        Set<String> fieldsToTreat
    ) {
        if(dataToAnonymize != null) {
            this.dataToAnonymize = new Map<Id,sObject>(dataToAnonymize);
        } else {
            this.dataToAnonymize = new Map<Id,sObject>();
        }
        
        if(dataToUseForAnonymizationByField != null) {
            this.dataToUseForAnonymizationByField = dataToUseForAnonymizationByField;
        } else {
            this.dataToUseForAnonymizationByField = new Map<String,Object>();
        }
        
        if(fieldsToTreat == null) {
            throw new NullParameterException('The parameter fieldsToTreat is required.');
        }
        this.fieldsToTreat = fieldsToTreat;
        
        if(this.dataToAnonymize.size() > 0) {
            Schema.SObjectType currentSObjectType = dataToAnonymize[0].getSObjectType();
            this.sObjectFields = currentSObjectType.getDescribe().fields.getMap();
            this.sObjectAPIName = currentSObjectType.getDescribe().getName();
        }
    }
    
    /*
     * Launch replacement of your data.
     *
     * @param Boolean allOrNone                                         Means some exceptions will not be thrown
     *
     * @return List<sObject>                                            sObjects with replaced elements
     */
    public List<sObject> anonymize(
        Boolean allOrNone
    ) {
        Map<Id,Map<String,Object>> dataAnonymized = anonymizeData();
        putAnonymizedData(dataToAnonymize, dataAnonymized, this.fieldsToTreat, true, allOrNone);
        return dataToAnonymize.values();
    }
    
    /*
     * Launch replacement of your data. This is the static version of the class.
     *
     * @param Boolean allOrNone                                         Means some exceptions will not be thrown
     * @param Map<Id,Map<String,Object>> dataAnonymized                 Data you want to put into your sObjects by element
     *
     * @return List<sObject>                                            sObjects with replaced elements
     */
    public static List<sObject> anonymize(
        Map<Id,sObject> dataToAnonymize, 
        Map<Id,Map<String,Object>> dataAnonymized, 
        Boolean allOrNone
    ) {
        if(dataToAnonymize.size() > 0) {
            Set<String> fieldsToTreat;
            if(
                dataAnonymized != null 
                && dataAnonymized.size() > 0 
                && dataAnonymized.values() != null
                && dataAnonymized.values().size() > 0
            ) {
                fieldsToTreat = dataAnonymized.values()[0].keySet();
            } else {
                fieldsToTreat = new Set<String>();
            }
            putAnonymizedData(dataToAnonymize, dataAnonymized, fieldsToTreat, false, allOrNone);
        }
        return dataToAnonymize.values();
    }
    
    /*
     * Get lastest increment for unique fields
     *
     * @return Map<String,Integer>                                      Lastest increments by field
     */
    private Map<String,Integer> lastestNumberForUniqueFields() {
        Pattern integerFormatingPattern = Pattern.compile('[^0-9]');
        
        Map<String,Integer> lastestUsedNumberForUniqueFields = new Map<String,Integer>();
        
        for(String field: fieldsToTreat) {
            Schema.SObjectField sObjectField = this.sObjectFields.get(field);
            Object patternObject = this.dataToUseForAnonymizationByField.get(field);
            if(sObjectField != null && patternObject != null) {
                Schema.DescribeFieldResult sObjectFieldDescribe = sObjectField.getDescribe();
                if(
                    sObjectFieldDescribe.isUnique() 
                    || (
                        this.sObjectAPIName == 'User' 
                        && field == 'Username'
                    )
                ) {
                    if(
                        (
                            sObjectFieldDescribe.getType() == Schema.DisplayType.Email
                            || sObjectFieldDescribe.getType() == Schema.DisplayType.String
                        )
                        && (patternObject instanceof String)
                    ) {
                        String patternElement = (String) patternObject;
                        List<sObject> lastNumberedElements = Database.query(
                            'SELECT ' + field + ' ' + 
                            'FROM ' + this.sObjectAPIName + ' ' + 
                            'WHERE ' + field + ' LIKE \'' + patternElement + '%\'' + ' ' + 
                            'ORDER BY ' + field + ' DESC ' +  
                            'LIMIT 1'
                        );
                        String temp;
                        if(lastNumberedElements != null && lastNumberedElements.size() == 1) {
                            temp = integerFormatingPattern.matcher(
                                (
                                    (String) lastNumberedElements[0].get(field)
                                ).remove(patternElement)
                            ).replaceAll('');
                        }
                        if(String.isBlank(temp)) {
                            lastestUsedNumberForUniqueFields.put(field, 0);
                        } else {
                            lastestUsedNumberForUniqueFields.put(field, Integer.valueOf(temp));
                        }
                    }
                }
            }
        }
        
        return lastestUsedNumberForUniqueFields;
    }
    
    /*
     * Generate the new data based on input of the constructor.
     *
     * @return Map<Id,Map<String,Object>>                               New data per sObject and per field
     *
     * @throws SObjectFieldNotFoundException                            Field does not exist
     * @throws WrongPicklistElementException                            Field is picklist and element does not exist in picklist of field
     */
    private Map<Id,Map<String,Object>> anonymizeData() {
        Map<Id,Map<String,Object>> anonymizedData = new Map<Id,Map<String,Object>>();
        
        for(sObject row: this.dataToAnonymize.values()) {
            anonymizedData.put(row.Id, new Map<String,Object>());
        }
        
        if(this.dataToAnonymize.size() > 0) {
            Map<String,Integer> lastestUsedNumberForUniqueFields = lastestNumberForUniqueFields();
                
            for(String field: fieldsToTreat) {
                Schema.SObjectField sObjectField = this.sObjectFields.get(field);
                
                if(sObjectField != null) {
                    Schema.DescribeFieldResult sObjectFieldDescribe = sObjectField.getDescribe();
                    if(dataToUseForAnonymizationByField.containsKey(field)) {
                        Object dataToPutInField = dataToUseForAnonymizationByField.get(field);
                        
                        if(dataToPutInField != null) {
                            typeChecking(sObjectFieldDescribe.getType(), dataToPutInField, field);
                            switch on sObjectFieldDescribe.getType() {
                                when Integer {
                                    if(!sObjectFieldDescribe.isUnique() && dataToPutInField != null) {
                                        dataToPutInField = ((Decimal) dataToPutInField).intValue();
                                    }
                                }
                                when Double {
                                    if(!sObjectFieldDescribe.isUnique()) {
                                        dataToPutInField = (Decimal) dataToPutInField;
                                    }
                                }
                                when Percent, Currency {
                                    dataToPutInField = (Decimal) dataToPutInField;
                                }
                                when Picklist, MultiPicklist {
                                    Set<String> picklist = new Set<String>();
                                    for(Schema.PicklistEntry row: Schema.getGlobalDescribe()
                                        .get(this.sObjectAPIName)
                                        .getDescribe()
                                        .fields
                                        .getMap()
                                        .get(field)
                                        .getDescribe()
                                        .getPickListValues()
                                    ) {
                                        if(row.isActive()) {
                                            picklist.add(row.getValue());
                                        }
                                    }
                                    if(
                                        dataToPutInField != null 
                                        && sObjectFieldDescribe.isRestrictedPicklist()
                                        && !picklist.contains((String) dataToPutInField)
                                    ) {
                                        throw new WrongPicklistElementException(
                                            'The element ' + dataToPutInField + ' for field ' + field 
                                            + ' does not exist in picklist.'
                                        );
                                    }
                                }
                                when String {
                                    if(
                                        sObjectFieldDescribe.isUnique()
                                        || (
                                            this.sObjectAPIName == 'User' 
                                            && field == 'Username'
                                        )
                                    ) {
                                        if(dataToUseForAnonymizationByField.containsKey(field)) {
                                            Integer lastestUsesNumber;
                                            lastestUsesNumber = lastestUsedNumberForUniqueFields.get(field);
                                            lastestUsesNumber++;
                                            dataToPutInField = ((String) dataToPutInField) 
                                                + lastestUsesNumber.format();
                                            lastestUsedNumberForUniqueFields.put(field, lastestUsesNumber);
                                        }
                                    }
                                }
                                when Email {
                                    if(sObjectFieldDescribe.isUnique()) {
                                        if(dataToUseForAnonymizationByField.containsKey(field)) {
                                            Integer lastestUsesNumber;
                                            lastestUsesNumber = lastestUsedNumberForUniqueFields.get(field);
                                            lastestUsesNumber++;
                                            List<String> dataToPutInFieldSplitted;
                                            dataToPutInFieldSplitted = ((String) dataToPutInField).split('@');
                                            dataToPutInField = dataToPutInFieldSplitted[0] 
                                                + lastestUsesNumber.format() 
                                                + '@'
                                                + dataToPutInFieldSplitted[1];
                                            lastestUsedNumberForUniqueFields.put(field, lastestUsesNumber);
                                        }
                                    }
                                }
                            }
                        }
                        for(sObject row: this.dataToAnonymize.values()) {
                            anonymizedData.get(row.Id).put(field, dataToPutInField);
                        }
                    }
                } else {
                    throw new SObjectFieldNotFoundException(
                        'The field ' + field + ' on ' + this.sObjectAPIName + ' does not exist.'
                    );
                }
            }
        }
        
        return anonymizedData;
    }
    
    /*
     * This function will fill all sObjects with new data.
     *
     * @param Map<Id,sObject> dataToAnonymize                           sObjects to be changed
     * @param Map<Id,Map<String,Object>> dataAnonymized                 New data per sObject and per field
     * @param Set<String> fieldsToTreat                                 Set of fields to be treated
     * @param Boolean isValidData                                       If true, will test data type integrity
     * @param Boolean allOrNone                                         Means some exceptions will not be thrown
     *
     * @throws RequiredFieldMissingException                            Thrown if there is no data for a field marked as required
     */
    private static void putAnonymizedData(
        Map<Id,sObject> dataToAnonymize, 
        Map<Id,Map<String,Object>> dataAnonymized, 
        Set<String> fieldsToTreat, 
        Boolean isValidData, 
        Boolean allOrNone
    ) {
        if(dataToAnonymize.size() > 0) {
            Schema.SObjectType sObjectType = dataToAnonymize.values()[0].getSObjectType();
            Map<String,Schema.SObjectField> sObjectFields = sObjectType.getDescribe().fields.getMap();
            String sObjectAPIName = sObjectType.getDescribe().getName();
            
            for(Id sObjectId: dataToAnonymize.keySet()) {
                Map<String,Object> dataAnonymizedForCurrectSObject = dataAnonymized.get(sObjectId);
                if(dataAnonymizedForCurrectSObject != null) {
                    for(String field: fieldsToTreat) {
                        Object dataToPutInField = dataAnonymizedForCurrectSObject.get(field);
                        if(!isValidData) {
                            Schema.SObjectField sObjectField = sObjectFields.get(field);
                            if(sObjectField != null) {
                                Schema.DescribeFieldResult sObjectFieldDescribe = sObjectField.getDescribe();
                                String sObjectFieldName = sObjectFieldDescribe.getName();
                                if(dataToPutInField == null && !sObjectFieldDescribe.isNillable()) {
                                    String fieldIsRequiredMessage = 'Field ' + sObjectFieldName + ' is required.';
                                    if(allOrNone) {
                                        throw new RequiredFieldMissingException(fieldIsRequiredMessage);
                                    } else {
                                        System.debug(fieldIsRequiredMessage);
                                    }
                                } else if(dataToPutInField != null) {
                                    typeChecking(sObjectFieldDescribe.getType(), dataToPutInField, sObjectFieldName);
                                }
                            }
                        }
                        dataToAnonymize.get(sObjectId).put(field, dataToPutInField);
                    }
                }
            }
        }
    }
    
    /*
     * This function has be made to reduce code repeated.
     * Only thrown exceptions.
     *
     * @param Schema.DisplayType awaitedDataType                        Data type for the field you are testing
     * @param Object dataToPutInField                                   New data that will be tested
     * @param String sObjectField                                       Field that will be tested
     *
     * @throws WrongDataTypeException                                   Thrown if Object type does not correspond to awaited data type
     */
    private static void typeChecking(Schema.DisplayType awaitedDataType, Object dataToPutInField, String sObjectField) {
        switch on awaitedDataType {
            when Date {
                if(!(dataToPutInField instanceof Date)) {
                    throw new WrongDataTypeException(
                        'Data for ' + sObjectField + ' need to be a Date.'
                    );
                }
            }
            when Time {
                if(!(dataToPutInField instanceof Time)) {
                    throw new WrongDataTypeException(
                        'Data for ' + sObjectField + ' need to be a Time.'
                    );
                }
            }
            when DateTime {
                if(!(dataToPutInField instanceof DateTime)) {
                    throw new WrongDataTypeException(
                        'Data for ' + sObjectField + ' need to be a DateTime.'
                    );
                }
            }
            when Integer {
                if(!(dataToPutInField instanceof Integer)) {
                    throw new WrongDataTypeException(
                        'Data for ' + sObjectField + ' need to be a Integer.'
                    );
                }
            }
            when Double, Percent, Currency {
                if(
                    !(dataToPutInField instanceof Decimal)
                    && !(dataToPutInField instanceof Double)
                    && !(dataToPutInField instanceof Integer)
                ) {
                    throw new WrongDataTypeException(
                        'Data for ' + sObjectField + ' need to be a Decimal.'
                    );
                }
            }
            when Reference {
                if(!(dataToPutInField instanceof Id)) {
                    throw new WrongDataTypeException(
                        'Data for ' + sObjectField + ' need to be a Id.'
                    );
                }
            }
            when 
                String, 
                EncryptedString, 
                Picklist, 
                TextArea, 
                URL, 
                Email, 
                Phone 
            {
                if(!(dataToPutInField instanceof String)) {
                    throw new WrongDataTypeException(
                        'Data for ' + sObjectField + ' need to be a String.'
                    );
                }
            }
        }
    }
}