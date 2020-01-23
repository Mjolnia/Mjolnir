/**
 * Class that is building the string of a query.
 
 * @author Davy LAURENT
 * @version 1.0
 */
public class RequestBuilder {
    public static String getSOQLQuery(
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
    
    public static String getSOSLQuery(
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