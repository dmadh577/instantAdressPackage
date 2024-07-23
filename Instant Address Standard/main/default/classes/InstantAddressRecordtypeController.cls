public class InstantAddressRecordtypeController {
    public static Map<Id, String> recordtypemap {get;set;}
    
   @AuraEnabled        
    public static List<String> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = Account.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        
        system.debug('recordtypes');
        system.debug(recordtypes);
        
        for(RecordTypeInfo rt : recordtypes){
           // if(rt.getName() != 'Master')
            recordtypemap.put(rt.getRecordTypeId(), rt.getName());
        }        
        return recordtypemap.values();
    }
    
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId(); 
        
       string recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
        
        system.debug('RecordType');
        system.debug(recordtypeid);
        return recordtypeid;
    } 
}