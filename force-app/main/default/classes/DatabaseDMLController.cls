global with sharing class DatabaseDMLController {
    @auraEnabled
    global static String insertSObjectsApex(String rowsToInsertJSON) {
        try {
            List<sObject> rowsToInsert = (List<sObject>) JSON.deserialize(rowsToInsertJSON, List<sObject>.class);
            
            insert rowsToInsert;
            
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

    @auraEnabled
    global static String updateSObjectsApex(String rowsToUpdateJSON) {
        try {
            List<sObject> rowsToUpdate = (List<sObject>) JSON.deserialize(rowsToUpdateJSON, List<sObject>.class);
            
            update rowsToUpdate;
            
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

    @auraEnabled
    global static String deleteSObjectsApex(String rowsToDeleteJSON) {
        try {
            List<sObject> rowsToDelete = (List<sObject>) JSON.deserialize(rowsToDeleteJSON, List<sObject>.class);
            
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