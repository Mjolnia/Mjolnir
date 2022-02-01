global with sharing class RelatedListManagerController {
    class FieldMetadata {
        @auraEnabled public String name;
        @auraEnabled public String label;
        @auraEnabled public String childRelationshipLabel;
        @auraEnabled public String dataType;
        @auraEnabled public Boolean isRequired;
        @auraEnabled public Boolean isReadOnly;
        @auraEnabled public String increment;
        @auraEnabled public List<Map<String,String>> options;
        
        public FieldMetadata(
            String name, 
            String label, 
            String childRelationshipLabel, 
            String dataType, 
            Boolean isRequired, 
            Boolean isReadOnly, 
            Integer scale, 
            List<Map<String,String>> options
        ) {
            this.name = name;
            this.label = label;
            this.childRelationshipLabel = childRelationshipLabel;
            this.dataType = dataType;
            this.isRequired = isRequired;
            this.isReadOnly = isReadOnly;
            if(scale != null) {
                this.increment = '0.' + ''.leftPad(scale - 1, '0') + '1';
            }
            
            this.options = options;
        }
    }
    
    @auraEnabled(cacheable=true)
    global static List<Object> getFieldMetadataApex(String sObjectName, List<String> listOfFields, String emptyPicklistLabel) {
        try {
            List<FieldMetadata> fieldMetadataList = new List<FieldMetadata>();

            Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            
            Schema.DescribeSObjectResult sObjectDescribe = globalDescribe.get(sObjectName).getDescribe();
            Map<String,Schema.SObjectField> sObjectFieldsMap = sObjectDescribe.fields.getMap();
            
            for(String fieldAPIName: listOfFields) {
                if(sObjectFieldsMap.containsKey(fieldAPIName)) {
                    Schema.DescribeFieldResult describeSObjectField = sObjectFieldsMap.get(fieldAPIName).getDescribe();
                    
                    if(describeSObjectField.isAccessible()) {
                        Schema.DisplayType dataType = describeSObjectField.getType();
                        List<Map<String,String>> options;
                        Boolean isRequired = !describeSObjectField.isNillable();
    
                        if(dataType == Schema.DisplayType.Picklist || dataType == Schema.DisplayType.MultiPicklist) {
                            options = new List<Map<String,String>>();
                            if(!isRequired) {
                                options.add(new Map<String,String>{'value' => '', 'label' => emptyPicklistLabel});
                            }
                            for(Schema.PicklistEntry row: describeSObjectField.getPickListValues()) {
                                if(row.isActive()) {
                                    options.add(new Map<String,String>{'value' => row.getValue(), 'label' => row.getLabel()});
                                }
                            }
                        } else if(dataType == Schema.DisplayType.Reference) {
                            if(!describeSObjectField.isNamePointing()) {
                                options = new List<Map<String,String>>();
                                if(!isRequired) {
                                    options.add(new Map<String,String>{'' => emptyPicklistLabel});
                                }
                                for(sObject row: 
                                    Database.query(
                                        RequestBuilder.getSOQLQuerySimple(
                                            new List<String>{'Id', 'Name'}, 
                                            describeSObjectField.getReferenceTo()[0].getDescribe().getLocalName(), 
                                            null, 
                                            null, 
                                            '100', 
                                            null
                                        )
                                    )
                                ) {
                                    options.add(new Map<String,String>{'value' => (String) row.get('Id'), 'label' => (String) row.get('Name')});
                                }
                            }
                        }
                        
                        fieldMetadataList.add(
                            new FieldMetadata(
                                describeSObjectField.getLocalName(), 
                                describeSObjectField.getLabel(), 
                                (dataType == Schema.DisplayType.Reference) ? describeSObjectField.getRelationshipName() : null, 
                                dataType.name(), 
                                isRequired, 
                                !describeSObjectField.isCreateable() || !describeSObjectField.isUpdateable(),
                                describeSObjectField.getScale(), 
                                options
                            )
                        );
                    }
                }
            }
            
            return fieldMetadataList;
        } catch(Exception error) {
            System.debug(error.getStackTraceString());
            throw new AuraHandledException(error.getMessage());
        }
    }

    @auraEnabled
    public static List<sObject> getDataApex(List<String> fieldAPINames, String sObjectName, String whereClause) {
        try {
            return Database.query(
                RequestBuilder.getSOQLQuerySimple(
                    fieldAPINames, 
                    sObjectName, 
                    whereClause, 
                    null, 
                    null, 
                    null
                )
            );
        } catch(Exception error) {
            System.debug(error.getStackTraceString());
            System.debug(error.getMessage());
            throw new AuraHandledException(error.getMessage());
        }
    }
    
    @auraEnabled
    global static String saveRowsApex(String rowsToInsertJSON, String rowsToUpdateJSON, String rowsToDeleteJSON) {
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
            System.debug(error.getDmlMessage(0));
            return error.getDmlMessage(0);
        } catch(Exception error) {
            System.debug(error.getStackTraceString());
            System.debug(error.getMessage());
            throw new AuraHandledException(error.getMessage());
        }
    }
}