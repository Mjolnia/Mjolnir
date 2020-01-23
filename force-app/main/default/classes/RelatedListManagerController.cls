public with sharing class RelatedListManagerController {
    class FieldMetadata {
        @auraEnabled public String name;
        @auraEnabled public String label;
        @auraEnabled public String childRelationshipLabel;
        @auraEnabled public String dataType;
        @auraEnabled public Boolean isRequired;
        @auraEnabled public String increment;
        @auraEnabled public Map<String,String> picklistLabelsByValuesMap;
        
        public FieldMetadata(
            String name, 
            String label, 
            String childRelationshipLabel, 
            String dataType, 
            Boolean isRequired, 
            Integer scale, 
            Map<String,String> picklistLabelsByValuesMap
        ) {
            this.name = name;
            this.label = label;
            this.childRelationshipLabel = childRelationshipLabel;
            this.dataType = dataType;
            this.isRequired = isRequired;
            if(scale != null) {
                this.increment = '0.' + ''.leftPad(scale - 1, '0') + '1';
            }
            
            this.picklistLabelsByValuesMap = picklistLabelsByValuesMap;
        }
    }
    
    @auraEnabled
    public static List<FieldMetadata> getFieldMetadataApex(String sObjectName, List<String> listOfFields) {
        try {
            List<FieldMetadata> fieldMetadataList = new List<FieldMetadata>();
            
            Map<String,Schema.SObjectField> sObjectFieldsMap = Schema.getGlobalDescribe()
            .get(sObjectName)
            .getDescribe()
            .fields
            .getMap();
            
            for(String fieldAPIName: listOfFields) {
                if(sObjectFieldsMap.containsKey(fieldAPIName)) {
                    Schema.DescribeFieldResult describeSObjectField = sObjectFieldsMap.get(fieldAPIName).getDescribe();
                    Schema.DisplayType dataType = describeSObjectField.getType();
                    Map<String,String> picklistElements;
                    
                    if(dataType == Schema.DisplayType.Picklist || dataType == Schema.DisplayType.MultiPicklist) {
                        picklistElements = PicklistHelper.getPicklistLabelByValueMap(sObjectName, fieldAPIName);
                    } else if(dataType == Schema.DisplayType.Reference) {
                        if(!describeSObjectField.isNamePointing()) {
                            picklistElements = new Map<String,String>();
                            List<sObject> parentSObjectRows = DatabaseRequesterWithSharing.getSelectFieldsFromSObjectFor(
                                new Set<String>{'Id', 'Name'}, 
                                describeSObjectField.getReferenceTo()[0].getDescribe().getLocalName(), 
                                null, 
                                null, 
                                null, 
                                null, 
                                null, 
                                null, 
                                null
                            );
                            for(sObject row: 
                                DatabaseRequesterWithSharing.getSelectFieldsFromSObjectFor(
                                    new Set<String>{'Id', 'Name'}, 
                                    describeSObjectField.getReferenceTo()[0].getDescribe().getLocalName(), 
                                    null, 
                                    null, 
                                    null, 
                                    null, 
                                    null, 
                                    null, 
                                    null
                                )
                            ) {
                                picklistElements.put((String) row.get('Id'), (String) row.get('Name'));
                            }
                        }
                    }
                    
                    fieldMetadataList.add(
                        new FieldMetadata(
                            describeSObjectField.getLocalName(), 
                            describeSObjectField.getLabel(), 
                            (dataType == Schema.DisplayType.Reference) ? describeSObjectField.getRelationshipName() : null, 
                            dataType.name(), 
                            !describeSObjectField.isNillable(), 
                            describeSObjectField.getScale(), 
                            picklistElements
                        )
                    );
                }
            }
            
            return fieldMetadataList;
        } catch(Exception error) {
            System.debug(error.getStackTraceString());
            throw new AuraHandledException(error.getMessage());
        }
    }
    
    @auraEnabled
    public static List<sObject> getRowsApex(Id recordId, String sObjectName, String relationshipField, List<String> listOfFields) {
        try {
            Set<String> fieldToQuery = new Set<String>(listOfFields);
            fieldToQuery.add(relationshipField);
            return DatabaseRequesterWithSharing.getSelectFieldsFromSObjectFor(
                fieldToQuery, 
                sObjectName, 
                null, 
                relationshipField + ' = \'' + recordId + '\'', 
                null, 
                null, 
                null, 
                null, 
                null
            );
        } catch(Exception error) {
            System.debug(error.getStackTraceString());
            throw new AuraHandledException(error.getMessage());
        }
    }
    
    @auraEnabled
    public static String saveRowsApex(String rowsToInsertJSON, String rowsToUpdateJSON, String rowsToDeleteJSON) {
        try {
            List<sObject> rowsToInsert = (List<sObject>) JSON.deserialize(rowsToInsertJSON, List<sObject>.class);
            List<sObject> rowsToUpdate = (List<sObject>) JSON.deserialize(rowsToUpdateJSON, List<sObject>.class);
            List<sObject> rowsToDelete = (List<sObject>) JSON.deserialize(rowsToDeleteJSON, List<sObject>.class);
            
            insert rowsToInsert;
            update rowsToUpdate;
            delete rowsToDelete;
            
            return null;
        } catch(DmlException error) {
            System.debug(error.getStackTraceString());
            return error.getDmlMessage(0);
        } catch(Exception error) {
            System.debug(error.getStackTraceString());
            throw new AuraHandledException(error.getMessage());
        }
    }
}