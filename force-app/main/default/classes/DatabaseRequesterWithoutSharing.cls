/**
 * Class that is doing the query.
 
 * @author Davy LAURENT
 * @version 1.0
 */

global without sharing class DatabaseRequesterWithoutSharing {
    private class SObjectDoesNotExistException extends Exception {}
    
    global static List<SObject> getSelectStarFromSObject(
        String sObjectName,
        String usingScopeClause, 
        String whereClause,
        String withClause,
        String orderByClause,
        String limitClause,
        String offsetClause,
        String forClause
    ) {
        Map<String,Schema.SObjectType> allSObjectTypesMap = Schema.getGlobalDescribe();
        if(String.isBlank(sObjectName) || !allSObjectTypesMap.containsKey(sObjectName)) {
            throw new SObjectDoesNotExistException('The sObject type ' + String.valueOf(sObjectName) + ' does not exists.');
        }
        
        return RequestBuilder.testIfListNotNull(
            Database.query(
                RequestBuilder.getSOQLQuery(
                    new List<String>(allSObjectTypesMap.get(sObjectName).getDescribe().fields.getMap().keySet()),
                    sObjectName,
                    usingScopeClause, 
                    whereClause,
                    withClause,
                    null,
                    null,
                    orderByClause,
                    limitClause,
                    offsetClause,
                    forClause, 
                    null
                )
            )
        );
    }
    
    global static List<SObject> getSelectFieldsFromSObject(
        Set<String> fieldNameSet,
        String sObjectName,
        String usingScopeClause, 
        String whereClause,
        String withClause,
        String groupByClause,
        String havingClause,
        String orderByClause,
        String limitClause,
        String offsetClause,
        String forClause,
        String updateClause
    ) {
        Map<String,Schema.SObjectType> allSObjectTypesMap = Schema.getGlobalDescribe();
        if(String.isBlank(sObjectName) || !allSObjectTypesMap.containsKey(sObjectName)) {
            throw new SObjectDoesNotExistException('The sObject type ' + String.valueOf(sObjectName) + ' does not exists.');
        }
        
        return RequestBuilder.testIfListNotNull(
            Database.query(
                RequestBuilder.getSOQLQuery(
                    new List<String>(fieldNameSet),
                    sObjectName,
                    usingScopeClause, 
                    whereClause,
                    withClause,
                    groupByClause,
                    havingClause,
                    orderByClause,
                    limitClause,
                    offsetClause,
                    forClause, 
                    updateClause
                )
            )
        );
    }
    
    global static List<SObject> getSelectFieldsFromSObjectGroupBy(
        Set<String> fieldNameSet,
        String sObjectName,
        String usingScopeClause, 
        String whereClause,
        String withClause,
        String groupByClause,
        String havingClause,
        String orderByClause,
        String limitClause,
        String offsetClause
    ) {
        Map<String,Schema.SObjectType> allSObjectTypesMap = Schema.getGlobalDescribe();
        if(String.isBlank(sObjectName) || !allSObjectTypesMap.containsKey(sObjectName)) {
            throw new SObjectDoesNotExistException('The sObject type ' + String.valueOf(sObjectName) + ' does not exists.');
        }
        
        return RequestBuilder.testIfListNotNull(
            Database.query(
                RequestBuilder.getSOQLQuery(
                    new List<String>(fieldNameSet),
                    sObjectName,
                    usingScopeClause, 
                    whereClause,
                    withClause,
                    groupByClause,
                    havingClause,
                    orderByClause,
                    limitClause,
                    offsetClause,
                    null, 
                    null
                )
            )
        );
    }
    
    global static List<SObject> getSelectFieldsFromSObjectFor(
        Set<String> fieldNameSet,
        String sObjectName,
        String usingScopeClause, 
        String whereClause,
        String withClause,
        String orderByClause,
        String limitClause,
        String offsetClause,
        String forClause
    ) {
        Map<String,Schema.SObjectType> allSObjectTypesMap = Schema.getGlobalDescribe();
        if(String.isBlank(sObjectName) || !allSObjectTypesMap.containsKey(sObjectName)) {
            throw new SObjectDoesNotExistException('The sObject type ' + String.valueOf(sObjectName) + ' does not exists.');
        }
        
        return RequestBuilder.testIfListNotNull(
            Database.query(
                RequestBuilder.getSOQLQuery(
                    new List<String>(fieldNameSet),
                    sObjectName,
                    usingScopeClause, 
                    whereClause,
                    withClause,
                    null,
                    null,
                    orderByClause,
                    limitClause,
                    offsetClause,
                    forClause, 
                    null
                )
            )
        );
    }
    
    global static List<List<SObject>> searchInSObjects(
        String searchString, 
        String inClause, 
        String returningClause, 
        List<String> withClauses,
        String limitClause, 
        String updateClause
    ) {
        return Search.query(
            RequestBuilder.getSOSLQuery(
                searchString, 
                inClause, 
                returningClause, 
                withClauses,
                limitClause, 
                updateClause
            )
        );
    }
    
    global static List<List<SObject>> searchInSObjects(
        String searchString, 
        String inClause, 
        String returningClause, 
        List<String> withClauses,
        String limitClause
    ) {
        return Search.query(
            RequestBuilder.getSOSLQuery(
                searchString, 
                inClause, 
                returningClause, 
                withClauses,
                limitClause, 
                null
            )
        );
    }
}