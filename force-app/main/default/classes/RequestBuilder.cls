/**
 * Class that is building the string of a query.
 
 * @author Davy LAURENT
 * @version 1.0
 */
global class RequestBuilder {
    global static String getSOQLQuery(
        List<String> fieldNameList,
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
        String query = 
            'SELECT ' + String.join(fieldNameList, ', ') + ' ' + 
            'FROM ' + sObjectName + ' ' + 
            ((String.isBlank(usingScopeClause)) ? '' : 'USING SCOPE ' + usingScopeClause) + ' ' + 
            ((String.isBlank(whereClause)) ? '' : 'WHERE ' + whereClause) + ' ' + 
            ((String.isBlank(withClause)) ? '' : 'WITH ' + withClause) + ' ' + 
            ((String.isBlank(groupByClause)) ? '' : 'GROUP BY ' + groupByClause) + ' ' + 
            ((String.isBlank(havingClause)) ? '' : 'HAVING ' + havingClause) + ' ' + 
            ((String.isBlank(orderByClause)) ? '' : 'ORDER BY ' + orderByClause) + ' ' + 
            ((String.isBlank(limitClause)) ? '' : 'LIMIT ' + limitClause) + ' ' + 
            ((String.isBlank(offsetClause)) ? '' : 'OFFSET ' + offsetClause) + ' ' + 
            ((String.isBlank(forClause)) ? '' : 'FOR ' + forClause) + ' ' + 
            ((String.isBlank(updateClause)) ? '' : 'UPDATE ' + updateClause);
        System.debug('SOQL query: \n' + query);
        return query;
    }

    global static String getSOQLQueryGroupBy(
        List<String> fieldNameList,
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
        return getSOQLQuery(
            fieldNameList,
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
        );
    }

    global static String getSOQLQueryFor(
        List<String> fieldNameList,
        String sObjectName,
        String usingScopeClause, 
        String whereClause,
        String withClause,
        String orderByClause,
        String limitClause,
        String offsetClause,
        String forClause
    ) {
        return getSOQLQuery(
            fieldNameList,
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
        );
    }

    global static String getSOQLQuerySimple(
        List<String> fieldNameList,
        String sObjectName,
        String whereClause,
        String orderByClause,
        String limitClause,
        String offsetClause
    ) {
        return getSOQLQuery(
            fieldNameList,
            sObjectName,
            null, 
            whereClause,
            null,
            null,
            null,
            orderByClause,
            limitClause,
            offsetClause,
            null,
            null
        );
    }

    global static String getSOQLInnerQuery(
        List<String> fieldNameList,
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
        return '(' + getSOQLQuery(
            fieldNameList,
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
        ) + ')';
    }

    global static String getSOQLInnerQueryGroupBy(
        List<String> fieldNameList,
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
        return '(' + getSOQLQuery(
            fieldNameList,
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
        ) + ')';
    }

    global static String getSOQLInnerQueryFor(
        List<String> fieldNameList,
        String sObjectName,
        String usingScopeClause, 
        String whereClause,
        String withClause,
        String orderByClause,
        String limitClause,
        String offsetClause,
        String forClause
    ) {
        return '(' + getSOQLQuery(
            fieldNameList,
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
        ) + ')';
    }

    global static String getSOQLInnerQuerySimple(
        List<String> fieldNameList,
        String sObjectName,
        String whereClause,
        String orderByClause,
        String limitClause,
        String offsetClause
    ) {
        return '(' + getSOQLQuery(
            fieldNameList,
            sObjectName,
            null, 
            whereClause,
            null,
            null,
            null,
            orderByClause,
            limitClause,
            offsetClause,
            null,
            null
        ) + ')';
    }
    
    global static String getSOSLQuery(
        String searchString, 
        String inClause, 
        String returningClause, 
        List<String> withClauses,
        String limitClause, 
        String updateClause
    ) {
        String query = 
            'FIND \'' + String.escapeSingleQuotes(searchString) + '\' ' + 
            ((String.isBlank(inClause)) ? '' : 'IN ' + inClause) + ' ' + 
            ((String.isBlank(returningClause)) ? '' : 'RETURNING ' + returningClause) + ' ' + 
            ((withClauses == null || withClauses.size() == 0) ? '' : 'WITH ' + String.join(withClauses, ' WITH ')) + ' ' + 
            ((String.isBlank(limitClause)) ? '' : 'LIMIT ' + limitClause) + ' ' + 
            ((String.isBlank(updateClause)) ? '' : 'UPDATE ' + updateClause);
        System.debug('SOSL query: \n' + query);
        return query;
    }
    
    public static List<sObject> testIfListNotNull(List<sObject> result) {
        return ((result == null) ? new List<sObject>() : result);
    }
}