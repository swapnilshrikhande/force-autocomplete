public class AutoComplete {
	
	public static Map<String, Schema.SObjectType> GLOBAL_DESCRIBE_MAP = Schema.getGlobalDescribe();
	
    public AutoComplete () {}
    public AutoComplete (ApexPages.StandardController controller) {}
    
    @RemoteAction
    public static SObject[] findSObjects(  String objectName
    								     , String searchKey
    								     , String searchField
    								     , String addFields
    								     , String profilename) 
    {
        /* Check whether the object passed is valid */
        Schema.SObjectType sobjectType = GLOBAL_DESCRIBE_MAP.get(objectName);
        if (sobjectType == null) 
        {
            return null;
        }
        
        /* Creating the filter text */
        String filter = ' like \'' + String.escapeSingleQuotes(searchKey) + '%\'';
        
        /* Begin building the dynamic soql query */
        String soql = 'SELECT '+ searchField;
        
        /* If any additional field was passed, adding it to the soql */
        /* More than one field can be passed in the addFields parameter
           Split it into an array for later use */
        List<String> fieldList=new List<String>();
        
        if (addFields != '')  {
        	fieldList = addFields.split(',');
        }
        
        if (fieldList.size()>0) 
        {
            for (String fieldName : fieldList) 
            {
                soql += ', ' + fieldName;
            }
        }
        
        /* Adding the object and filter by name to the soql */
        soql += ' FROM ' + objectName + ' WHERE '+ searchField + filter;
        
        if(profilename!='')
        {
            //profile name and the System Administrator are allowed
            soql += ' and Profile.Name like \'%' + String.escapeSingleQuotes(profilename) + '%\'';
            system.debug('Profile:'+profilename+' and SOQL:'+soql);
        }
        
        soql += ' ORDER BY Name limit 20';
        
        system.debug('searchKey: '+soql);
        
        List<sObject> resultList = new List<sObject>();
        try 
        {
            resultList = Database.query(soql);
        }
        catch (QueryException queryException) 
        {
            system.debug('Query Exception:'+queryException.getMessage());
            return null;
        }
        return resultList;
   }
}
