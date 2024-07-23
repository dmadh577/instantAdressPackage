public with sharing class InstantAddressPersonAccountExt {
    public InstantAddressRendererAltAdd Renderer { get; set; }
    
    public InstantAddressPersonAccountExt (ApexPages.StandardController stdController){
        boolean stopredirect = false;
        string jsonLayout = '', recordtypeid = '', recordid = '';
        try{
            stopredirect = (boolean.valueOf(ApexPages.currentPage().getParameters().get('StopRedirect')));
        } catch(Exception exc) {}
        
        if(stopredirect){
            try{
                recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
            } catch(Exception exc) {}
            
            if(recordtypeid == null ||recordtypeid == ''){
                recordid = ApexPages.currentPage().getParameters().get('id');
                Account acc = Database.query('select recordtypeid from Account where id = \''+ recordid  +'\' limit 1');
                recordtypeid = (string)acc.get('recordtypeid');
            }
            
            string nameid = 'ia.' + recordtypeid;
            string userId = UserInfo.getUserId();
            Instant_Address_Cache__c cache = Database.query('select Name, Value__c from Instant_Address_Cache__c where Name = \''+ nameid +'\' AND UserId__c =\''+ userId +'\' limit 1');
            
            jsonLayout = cache.Value__c;
        }
        
        this.Renderer = new InstantAddressRendererAltAdd (stdController, 'Account', jsonLayout);
    }
    
    public static PageReference redirectLayout(){
        string recordtypeid = '', sobjectname = '', recordid = '';
        boolean stopredirect = false;
        try{
            recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
        } catch(Exception exc) {}
        try{
            sobjectname = ApexPages.currentPage().getParameters().get('ent');
        } catch(Exception exc) {}
        try{
            stopredirect = (boolean.valueOf(ApexPages.currentPage().getParameters().get('StopRedirect')));
        } catch(Exception exc) {}
        
        if(recordtypeid == null ||recordtypeid == ''){
            recordid = ApexPages.currentPage().getParameters().get('id');
            Account acc = Database.query('select recordtypeid from Account where id = \''+ recordid  +'\' limit 1');
            recordtypeid = (string)acc.get('recordtypeid');
            sobjectname = 'Account';
        }
        
         try{
             string nameid = 'ia.' + recordtypeid;
             Instant_Address_Cache__c cache = [select Name, Value__c from Instant_Address_Cache__c where Name = :nameid limit 1];
             
        } catch(Exception exc) {}
        
       
        if(!stopredirect) {
            string nameid = 'returnurl.'+ recordtypeid;
            string userId = UserInfo.getUserId();
            
            List<Instant_Address_Cache__c> caches =[select Name, Value__c from Instant_Address_Cache__c where Name = :nameid AND UserId__c =:userId ]  ;
            delete caches;
            
            Instant_Address_Cache__c cache = new Instant_Address_Cache__c();
            cache.Name = 'returnurl.'+ recordtypeid;
            cache.Value__c = ApexPages.currentPage().getUrl();
            cache.SObject__c = 'Account';
            cache.UserId__c = userId;
            
            insert cache;
            
            PageReference retURL = new PageReference('/apex/InstantAddressRedirect?RecordType=' + recordtypeid + '&SObjectName=' + sobjectname);
            retURL.setRedirect(true);
            return retURL;
        }
        return null;
    } 
}