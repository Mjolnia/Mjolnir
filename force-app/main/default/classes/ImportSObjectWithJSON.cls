/**
 * Class use to build sObject from JSON or JSON from sObject.
 * @author Davy LAURENT
 * @version 1.0
 */
public class ImportSObjectWithJSON {
    private class FieldTooDeepException extends Exception{}
    private class RequiredActionException extends Exception{}
    private class UnsupportedTypeException extends Exception{}

    /**
     * Variable that store the pattern used to remove every character except digits, dots and comas
     */
    private static final Pattern NUMBERS_FORMATING_PATTERN = Pattern.compile('[^+-][^.,0-9]');

    private String sObjectName;
    private Map<String,String> fieldToJSONFieldMap;
    private Map<String,String> sObjectFieldsToSObjectFieldParentFieldKey;
    private Boolean isGMTDateTime;
    private String dateTimeFormat;
    private Boolean hasReferenceParentFields;

    private Map<String,Map<String,SObject>> sObjectFieldReferences;
    private Map<String,Map<Id,SObject>> sObjectFieldReferencesById;
    private Boolean hasCustomDateFormat;
    

    /**
     * Constructor.
     */
    public ImportSObjectWithJSON(
        String sObjectName,
        Map<String,String> fieldToJSONFieldMap, 
        Map<String,String> sObjectFieldsToSObjectFieldParentFieldKey, 
        Boolean isGMTDateTime,
        String dateTimeFormat
    ) {
        this.sObjectName = sObjectName;
        this.fieldToJSONFieldMap = fieldToJSONFieldMap;
        this.hasReferenceParentFields = (sObjectFieldsToSObjectFieldParentFieldKey != null);
        if(this.hasReferenceParentFields) {
            this.sObjectFieldsToSObjectFieldParentFieldKey = sObjectFieldsToSObjectFieldParentFieldKey;
        } else {
            this.sObjectFieldsToSObjectFieldParentFieldKey = new Map<String,String>();
        }
        this.isGMTDateTime = isGMTDateTime;
        this.hasCustomDateFormat=String.isNotBlank(dateTimeFormat);
        if(this.hasCustomDateFormat){
            this.dateTimeFormat=dateTimeFormat;
        }
    }
    
    /**
     * Constructor without DateTime formatting.
     */
    public ImportSObjectWithJSON(
        String sObjectName,
        Map<String,String> fieldToJSONFieldMap, 
        Map<String,String> sObjectFieldsToSObjectFieldParentFieldKey, 
        Boolean isGMTDateTime
    ) {
        this(sObjectName, fieldToJSONFieldMap, sObjectFieldsToSObjectFieldParentFieldKey, isGMTDateTime, null);
    }

    /**
     * Constructor without reference fields and without DateTime formatting.
     */
    public ImportSObjectWithJSON(
        String sObjectName,
        Map<String,String> fieldToJSONFieldMap, 
        Boolean isGMTDateTime
    ) {
        this(sObjectName, fieldToJSONFieldMap, null, isGMTDateTime,null);
    }

    /**
     * Constructor without reference fields.
     */
    public ImportSObjectWithJSON(
        String sObjectName,
        Map<String,String> fieldToJSONFieldMap, 
        Boolean isGMTDateTime,
        String dateTimeFormat
    ) {
        this(sObjectName, fieldToJSONFieldMap, null, isGMTDateTime,dateTimeFormat);
    }
    /**
     * Build the references data map for JSON to SObject.
     * This function contains queries in a loop. Per sObject, this function CANNOT exceed 40 queries per instance 
     * because you cannot have more that 40 reference fields on a sObject.
     * @param Map<String,Set<String>> dataFiltererBySObjectField    The data that will be use to filter queries per reference API field name.
     * @param Map<String,List<sObject>> existingDataBySObjectField  The data that will be use to fill map per reference API field name.
     */
    public void buildReferencesMapJSONToSObject(
        Map<String,Set<String>> dataFiltererBySObjectField, 
        Map<String,List<sObject>> existingDataBySObjectField
    ) {
        Map<String,Schema.SObjectField> sObjectFields = Schema.getGlobalDescribe()
                                                            .get(this.sObjectName)
                                                            .getDescribe()
                                                            .fields
                                                            .getMap();
                                                            
        this.sObjectFieldReferences = new Map<String,Map<String,SObject>>();

        if(this.hasReferenceParentFields) {
            if(dataFiltererBySObjectField != null) {
                Map<String,String> queriesToDoByReferenceField = new Map<String,String>();

                for(String sObjectField: dataFiltererBySObjectField.keySet()) {
                    Schema.DescribeFieldResult sObjectFieldDescribe = sObjectFields.get(sObjectField).getDescribe();
                    if(sObjectFieldDescribe.getType() == Schema.DisplayType.Reference) {
                        Map<String,SObject> referenceMap = new Map<String,SObject>();
                        this.sObjectFieldReferences.put(sObjectField, referenceMap);
                        
                        if(!sObjectFieldDescribe.isNamePointing()) {
                            String sObjectParentFieldKey = this.sObjectFieldsToSObjectFieldParentFieldKey.get(sObjectField);
                            Set<String> dataFilter = dataFiltererBySObjectField.get(sObjectField);

                            if(dataFilter.size() > 0) {
                                String tempSQLQuery = 
                                    'SELECT ' + sObjectParentFieldKey + ' '
                                    + 'FROM ' + sObjectFieldDescribe.getReferenceTo()[0].getDescribe().getName() + ' '
                                    + 'WHERE ' + sObjectParentFieldKey + ' '
                                        + 'IN ' + buildSOQLReadableList(dataFiltererBySObjectField.get(sObjectField)) + ' ';
                                queriesToDoByReferenceField.put(sObjectField, tempSQLQuery);
                                System.debug(tempSQLQuery);
                            }
                        }
                    }
                }

                for(String sObjectField: queriesToDoByReferenceField.keySet()) {
                    if(dataFiltererBySObjectField.containsKey(sObjectField)) {
                        List<SObject> queryResult = Database.query(queriesToDoByReferenceField.get(sObjectField));
                        if(queryResult != null) {
                            Map<String, sObject> sObjectByField = new Map<String, sObject>();
    
                            for(sObject so: queryResult) {
                                String valueOfField = get(so, this.sObjectFieldsToSObjectFieldParentFieldKey.get(sObjectField));
                                
                                sObjectByField.put(valueOfField, so);
                            }
        
                            this.sObjectFieldReferences.get(sObjectField).putAll(sObjectByField);
                        }
                    }
                }
            }
            
            if(existingDataBySObjectField != null) {
                for(String sObjectField: existingDataBySObjectField.keySet()) {
                    Map<String, sObject> sObjectByField = new Map<String, sObject>();

                    for(sObject so: existingDataBySObjectField.get(sObjectField)) {
                        String valueOfField = get(so, this.sObjectFieldsToSObjectFieldParentFieldKey.get(sObjectField));
                        
                        sObjectByField.put(valueOfField, so);
                    }

                    if(this.sObjectFieldReferences.containsKey(sObjectField)) {
                        this.sObjectFieldReferences.get(sObjectField).putAll(sObjectByField);
                    } else {
                        this.sObjectFieldReferences.put(sObjectField, sObjectByField);
                    }
                }
            }
        }
    }

    /**
     * Fill a sObject from a JSON object.
     * @param SObject element                   The sObject element to fill.
     * @param Map<String,Object> dataOfJSON     The data from the JSON.
     * @return SObject                          The filled sObject
     */
    public SObject fillSObjectFromJSON(
        SObject element, 
        Map<String,Object> dataOfJSON
    ) {
        if(this.hasReferenceParentFields && this.sObjectFieldReferences == null) {
            throw new RequiredActionException('You must execute buildReferencesMapJSONToSObject first.');
        }

        Map<String,Schema.SObjectField> sObjectFields = element.getSObjectType().getDescribe().fields.getMap();
        
        for(String fieldAPIName: this.fieldToJSONFieldMap.keySet()) {
            if(
                this.fieldToJSONFieldMap.get(fieldAPIName) != null
                && sObjectFields.containsKey(fieldAPIName)
            ) {
                Schema.DescribeFieldResult sObjectFieldDescribe = sObjectFields.get(fieldAPIName).getDescribe();
                
                String fieldToJSONField = this.fieldToJSONFieldMap.get(fieldAPIName);
                if(
                    sObjectFieldDescribe.isAccessible()
                    && !String.isEmpty(fieldToJSONField)
                ) {
                    Object theElement = dataOfJSON.get(fieldToJSONField);
                    Object existingElement = element.get(fieldAPIName);
                    if(
                        theElement != null
                        && (
                            sObjectFieldDescribe.isCreateable()
                            || (
                                element.isSet(fieldAPIName)
                                && sObjectFieldDescribe.isUpdateable()
                            )
                        )
                    ) {
                        switch on sObjectFieldDescribe.getType() {
                            when Date {
                                String temp = ((String) theElement).trim();
                                Date tempDate = null;
                                try {
                                    tempDate = (String.isBlank(temp)) ? null : Date.valueOf(temp);
                                } catch(System.TypeException error) {
                                    tempDate = (String.isBlank(temp)) ? null : Date.parse(temp);
                                }
                                element.put(fieldAPIName, (String.isBlank(temp)) ? null : tempDate);
                            }
                            when Time {
                                /*FYI : this part cannot be tested in test generic test class because 
                                no time field exists in Salesforce standard.*/
                                String temp = ((String) theElement).trim();
                                Time tempTime = null;
                                try {
                                    tempTime = (String.isBlank(temp)) 
                                                ? null 
                                                : DateTime.valueOfGmt(
                                                    String.valueOf(Date.today()) + ' ' + temp
                                                ).timeGmt();
                                } catch(System.TypeException error) {
                                    tempTime = (String.isBlank(temp)) 
                                                ? null 
                                                : DateTime.parse(
                                                    Date.today().format() + ' ' + temp
                                                ).time();
                                }
                                element.put(fieldAPIName, (String.isBlank(temp)) ? null : tempTime);
                            }
                            when DateTime {
                                String temp = ((String) theElement).trim();
                                if(this.isGMTDateTime) {
                                    element.put(fieldAPIName, (String.isBlank(temp)) ? null : DateTime.valueOfGMT(temp));
                                } else {
                                    DateTime tempDateTime;
                                    try {
                                        tempDateTime = (String.isBlank(temp)) ? null : DateTime.valueOf(temp);
                                    } catch(System.TypeException error) {
                                        tempDateTime = (String.isBlank(temp)) ? null : DateTime.parse(temp);
                                    }
                                    element.put(fieldAPIName, tempDateTime);
                                }
                            }
                            when Double, Percent, Currency {
                                if(
                                    theElement instanceOf Decimal
                                    || theElement instanceOf Double
                                    || theElement instanceOf Integer
                                ) {
                                    element.put(fieldAPIName, theElement);
                                } else {
                                    String temp = ((String) theElement).trim();

                                    Decimal tempDecimal;
                                    if(temp == '.') {
                                        tempDecimal = 0.0;
                                    } else if(!String.isBlank(temp)) {
                                        temp = NUMBERS_FORMATING_PATTERN.matcher(temp).replaceAll('');
                                        if(temp.contains('.') && temp.contains(',')) {
                                            temp = temp.replace(',', '');
                                        } else if(temp.contains(',') && !temp.contains('.')) {
                                            temp = temp.replace(',', '.');
                                        }
                                        tempDecimal = Decimal.valueOf(temp);
                                    }
                                    element.put(fieldAPIName, tempDecimal);
                                }
                            }
                            when Reference {
                                String temp = ((String) theElement).trim();
                                if(this.sObjectFieldReferences.get(fieldAPIName).containsKey(temp)) {
                                    element.put(fieldAPIName, this.sObjectFieldReferences.get(fieldAPIName).get(temp).Id);
                                }
                            }
                            when Boolean {
                                if(theElement instanceof Boolean) {
                                    element.put(fieldAPIName, (Boolean) theElement);
                                } else {
                                    element.put(fieldAPIName, ((String) theElement) == 'true');
                                }
                            }
                            when MultiPicklist {
                                /*FYI : this part cannot be tested in test generic test class because 
                                no multipicklist field exists in Salesforce standard.*/
                                List<Object> temp = (List<Object>) theElement;
                                Set<String> multiPicklistElements = new Set<String>();
                                String actualValues = (String) element.get(fieldAPIName);
                                if(String.isNotBlank(actualValues)) {
                                    for(String actualValue: actualValues.split(';')) {
                                        multiPicklistElements.add(actualValue);
                                    }
                                }
                                for(Object aMultiPicklistElement: temp){
                                    multiPicklistElements.add((String) aMultiPicklistElement);
                                }

                                element.put(fieldAPIName, String.join(new List<String>(multiPicklistElements), ';'));
                            }
                            when Picklist, String, EncryptedString, TextArea, URL, Email, Phone {
                                String temp = ((String) theElement).trim();
                                element.put(fieldAPIName, temp);
                            }
                            when else {
                                String errorMsg = 'Type of the field ' + fieldAPIName + ' can\'t be handled by this function.';
                                System.debug(errorMsg);
                                throw new UnsupportedTypeException(errorMsg);
                            }
                        }
                    }
                }
            }
        }

        return element;
    }

    /**
     * Build the references data map.
     * This function contains queries in a loop. Per sObject, this function CANNOT exceed 40 queries per instance 
     * because you cannot have more that 40 reference fields on a sObject.
     * @param Map<String,Set<String>> dataIdFiltererBySObjectField  The data that will be use to filter queries per reference API field name.
     * @param Map<String,List<SObject>> existingDataBySObjectField  The data that will be use to fill map per reference API field name.
     */
    public void buildReferencesMapSObjectToJSON(
        Map<String,Set<String>> dataIdFiltererBySObjectField, 
        Map<String,List<SObject>> existingDataBySObjectField
    ) {
        Map<String,Schema.SObjectField> sObjectFields = Schema.getGlobalDescribe()
                                                            .get(this.sObjectName)
                                                            .getDescribe()
                                                            .fields
                                                            .getMap();
                                                            
        this.sObjectFieldReferencesById = new Map<String,Map<Id,SObject>>();

        if(this.hasReferenceParentFields) {
            if(dataIdFiltererBySObjectField != null) {
                Map<String,String> queriesToDoByReferenceField = new Map<String,String>();

                for(String sObjectField: dataIdFiltererBySObjectField.keySet()) {
                    Schema.DescribeFieldResult sObjectFieldDescribe = sObjectFields.get(sObjectField).getDescribe();
                    if(sObjectFieldDescribe.getType() == Schema.DisplayType.Reference) {
                        Map<Id,SObject> referenceIdMap = new Map<Id,SObject>();
                        this.sObjectFieldReferencesById.put(sObjectField, referenceIdMap);
                        
                        if(!sObjectFieldDescribe.isNamePointing()) {
                            String sObjectParentFieldKey = this.sObjectFieldsToSObjectFieldParentFieldKey.get(sObjectField);
                            Set<String> dataFilter = dataIdFiltererBySObjectField.get(sObjectField);

                            if(dataFilter.size() > 0) {
                                String tempSQLQuery = 
                                    'SELECT ' + sObjectParentFieldKey + ' '
                                    + 'FROM ' + sObjectFieldDescribe.getReferenceTo()[0].getDescribe().getName() + ' '
                                    + 'WHERE Id IN ' + buildSOQLReadableList(dataIdFiltererBySObjectField.get(sObjectField)) + ' ';
                                queriesToDoByReferenceField.put(sObjectField, tempSQLQuery);
                                System.debug(tempSQLQuery);
                            }
                        }
                    }
                }

                for(String sObjectField: queriesToDoByReferenceField.keySet()) {
                    if(dataIdFiltererBySObjectField.containsKey(sObjectField)) {
                        List<SObject> queryResult = Database.query(queriesToDoByReferenceField.get(sObjectField));
                        if(queryResult != null) {
                            Map<Id, sObject> sObjectById = new Map<Id, sObject>();
    
                            for(sObject so: queryResult) {
                                String idField = get(so, 'Id');
                                
                                sObjectById.put(idField, so);
                            }
        
                            this.sObjectFieldReferencesById.get(sObjectField).putAll(sObjectById);
                        }
                    }
                }
            }
            
            if(existingDataBySObjectField != null) {
                for(String sObjectField: existingDataBySObjectField.keySet()) {
                    Map<Id, sObject> sObjectById = new Map<Id, sObject>();

                    for(sObject so: existingDataBySObjectField.get(sObjectField)) {
                        String idField = get(so, 'Id');
                        
                        sObjectById.put(idField, so);
                    }

                    if(this.sObjectFieldReferencesById.containsKey(sObjectField)) {
                        this.sObjectFieldReferencesById.get(sObjectField).putAll(sObjectById);
                    } else {
                        this.sObjectFieldReferencesById.put(sObjectField, sObjectById);
                    }
                }
            }
        }
    }

    /**
     * Generate a JSON object based on an sObject.
     * You MUST use writeStartObject() on your generator before launching this function.
     * You need to don"t forget the writeEndObject() after calling this function.
     * @param SObject element                   The sObject element that contains the data.
     * @param JSONGenerator generator           The JSON generator
     * @return JSONGenerator                    The filled JSONGenerator
     */
    public JSONGenerator generateJSONFromSObject(
        SObject element, 
        JSONGenerator generator
    ) {
        if(this.hasReferenceParentFields && this.sObjectFieldReferencesById == null) {
            throw new RequiredActionException('You must execute buildReferencesMapSObjectToJSON() first.');
        }

        Map<String,Schema.SObjectField> sObjectFields = element.getSObjectType().getDescribe().fields.getMap();
        
        for(String fieldAPIName: this.fieldToJSONFieldMap.keySet()) {
            if(
                this.fieldToJSONFieldMap.get(fieldAPIName) != null
                && sObjectFields.containsKey(fieldAPIName)
            ) {
                Schema.DescribeFieldResult sObjectFieldDescribe = sObjectFields.get(fieldAPIName).getDescribe();
                
                String fieldToJSONField = this.fieldToJSONFieldMap.get(fieldAPIName);
                
                if(!String.isEmpty(fieldToJSONField) && sObjectFieldDescribe.isAccessible()) {
                    Object theElement = element.get(fieldAPIName);
                    if(theElement != null) {
                        switch on sObjectFieldDescribe.getType() {
                            when Date {
                                Date temp = (Date) theElement;

                                if(temp != null) {
                                    generator.writeDateField(fieldToJSONField, temp);
                                }
                            }
                            when Time {
                                /*FYI : this part cannot be tested in test generic test class because 
                                no time field exists in Salesforce standard.*/

                                Time temp = (Time) theElement;

                                if(temp != null) {
                                    generator.writeTimeField(fieldToJSONField, temp);
                                }
                            }
                            when DateTime {
                                DateTime temp = (DateTime) theElement;

                                if(temp != null) {
                                    if(this.isGMTDateTime) {
                                        if(this.hasCustomDateFormat){
                                            generator.writeStringField(fieldToJSONField,temp.formatGmt(this.dateTimeFormat));
                                        }
                                        else{
                                            generator.writeStringField(fieldToJSONField, String.valueOfGmt(temp));
                                        }
                                    } else {
                                        if(this.hasCustomDateFormat){
                                            generator.writeStringField(fieldToJSONField,temp.format(this.dateTimeFormat));
                                        }
                                        else{
                                            generator.writeStringField(fieldToJSONField, String.valueOf(temp));
                                        }
                                    }
                                }
                            }
                            when Double, Percent, Currency {
                                Decimal temp = (Decimal) theElement;

                                if(temp != null) {
                                    generator.writeNumberField(fieldToJSONField, temp);
                                }
                            }
                            when Reference {
                                Id tempId = (Id) get(
                                    element, 
                                    fieldAPIName
                                );

                                if(tempId != null) {
                                    if(this.sObjectFieldsToSObjectFieldParentFieldKey.containsKey(fieldAPIName)) {
                                        if(this.sObjectFieldReferencesById.get(fieldAPIName).containsKey(tempId)) {
                                            Object tempData = this.sObjectFieldReferencesById.get(fieldAPIName).get(tempId).get(
                                                this.sObjectFieldsToSObjectFieldParentFieldKey.get(fieldAPIName)
                                            );
                                            if(tempData != null) {
                                                if(
                                                    tempData instanceOf Decimal 
                                                ) {
                                                    generator.writeNumberField(
                                                        fieldToJSONField, 
                                                        (Decimal) tempData
                                                    );
                                                } else if(
                                                    tempData instanceOf Integer 
                                                ) {
                                                    generator.writeNumberField(
                                                        fieldToJSONField, 
                                                        (Integer) tempData
                                                    );
                                                } else if(
                                                    tempData instanceOf Long 
                                                ) {
                                                    generator.writeNumberField(
                                                        fieldToJSONField, 
                                                        (Long) tempData
                                                    );
                                                } else if(
                                                    tempData instanceOf Boolean 
                                                ) {
                                                    generator.writeBooleanField(
                                                        fieldToJSONField, 
                                                        (Boolean) tempData
                                                    );
                                                } else if(
                                                    tempData instanceOf Date 
                                                ) {
                                                    generator.writeDateField(
                                                        fieldToJSONField, 
                                                        (Date) tempData
                                                    );
                                                } else if(
                                                    tempData instanceOf DateTime 
                                                ) {
                                                    DateTime tempDateTime = (DateTime) tempData;
                                                    if(this.isGMTDateTime) {
                                                        if(this.hasCustomDateFormat){
                                                            generator.writeStringField(fieldToJSONField,tempDateTime.formatGmt(this.dateTimeFormat));
                                                        }
                                                        else{
                                                            generator.writeStringField(fieldToJSONField, String.valueOfGmt(tempDateTime));
                                                        }
                                                    } else {
                                                        if(this.hasCustomDateFormat){
                                                            generator.writeStringField(fieldToJSONField,tempDateTime.format(this.dateTimeFormat));
                                                        }
                                                        else{
                                                            generator.writeStringField(fieldToJSONField, String.valueOf(tempDateTime));
                                                        }
                                                    }
                                                } else if(
                                                    tempData instanceOf Time 
                                                ) {
                                                    generator.writeTimeField(
                                                        fieldToJSONField, 
                                                        (Time) tempData
                                                    );
                                                } else {
                                                    generator.writeStringField(
                                                        fieldToJSONField, 
                                                        (String) tempData
                                                    );
                                                }
                                            }
                                        }
                                    } else {
                                        generator.writeStringField(
                                            fieldToJSONField, 
                                            tempId
                                        );
                                    }
                                }
                            }
                            when Boolean {
                                Boolean temp = (Boolean) theElement;

                                if(temp != null) {
                                    generator.writeBooleanField(fieldToJSONField, temp);
                                }
                            }
                            when MultiPicklist {
                                /*FYI : this part cannot be tested in test generic test class because 
                                no multipicklist field exists in Salesforce standard.*/
                                String temp = (String) theElement;

                                if(temp != null) {
                                    generator.writeObjectField(fieldToJSONField, temp.split(';'));
                                }
                            }
                            when Picklist, String, EncryptedString, TextArea, URL, Email, Phone, Id {
                                String temp = (String) theElement;

                                if(temp != null) {
                                    generator.writeStringField(fieldToJSONField, temp);
                                }
                            }
                            when else {
                                String errorMsg = 'Type of the field ' + fieldAPIName + ' can\'t be handled by this function.';
                                System.debug(errorMsg);
                                throw new UnsupportedTypeException(errorMsg);
                            }
                        }
                    }
                }
            }
        }

        return generator;
    }

    /**
     * Get the value from an sObject. Useful to retrieve a value on a parent sObject of the current one.
     * @param SObject so                        The sObject element that contains the data.
     * @param String fieldName                  The field name.
     * @return String                           The data as a String.
     */
    @testVisible
    private static String get(sObject so, String fieldName) {
        String[] splittedName = fieldName.split('\\.');
        return get_CORE(so, splittedName, 0);
    }

    /**
     * Recursive function. Get the value from an sObject. Useful to retrieve a value on a parent sObject of the current one.
     * @param SObject so                        The sObject element that contains the data.
     * @param String fieldName                  The field name.Integer 
     * @param Integer currentRelationDepth      The current depth.
     * @return String                           The data as a String.
     */
    private static String get_CORE(sObject so, List<String> splitted, Integer currentRelationDepth) {
        if(splitted.size() == 1) {
            if(so.get(splitted[0]) instanceof Date) {
                return String.valueOf((Date)so.get(splitted[0]));
            }
            else {
                return String.valueOf(so.get(splitted[0]));
            }
        }
        else {
            if(currentRelationDepth >= 5) {
                throw new FieldTooDeepException('Cannot go deeper than 5 level in relationship.');
            }
            sObject tmp= so.getSObject(splitted[0]);
            splitted.remove(0);
            return get_CORE(tmp, splitted, currentRelationDepth + 1);
        }
    }
    
    /**
     * Build the string for a IN clause based on a set of string.
     * @param Set<String> dataToConvert         The set of data.
     * @return String                           The set readable for an SOQL IN clause.
     */
    private static String buildSOQLReadableList(Set<String> dataToConvert) {
        if(dataToConvert == null || dataToConvert.size() == 0) {
            return '()';
        }
        List<String> dataFiltererEscaped = new List<String>();
        for(String dataToEscape: dataToConvert) {
            if(!String.isBlank(dataToEscape)) {
                dataFiltererEscaped.add(
                    dataToEscape.replace('\\', '\\\\')
                                .replace('\'', '\\\'')
                                .replace('"', '\\"')
                );
            } else {
                dataFiltererEscaped.add(dataToEscape);
            }
        }
        if(dataFiltererEscaped.size() == 0) {
            return '()';
        }
        return '(\'' + String.join(dataFiltererEscaped, '\', \'') + '\')';
    }
}