public with sharing class Redirect {
    public ApexPages.StandardController stdController { get; set; }
    public string recordtypeid { get; set; }
    public string sobjectname { get; set; }
    public string sessionid { get{
        return UserInfo.getSessionId();
    } private set;}
    public string themeid{ get{
        return UserInfo.getUiThemeDisplayed(); 
    } private set;}
    public string jsonLayout {get; set;}
    /*
    public static string isLightningExperience() {
            boolean isLightningExperience = false;
            string id = UserInfo.getUserId();
            for (User u: [SELECT Id, UserPreferencesLightningExperiencePreferred FROM User WHERE Id =: id LIMIT 1])
            {
                isLightningExperience = u.UserPreferencesLightningExperiencePreferred;
            }
            return string.valueOf(isLightningExperience);
     }
    */
    public Redirect(){
        recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
        sobjectname = ApexPages.currentPage().getParameters().get('SObjectName');
        
      
    }
    
    public PageReference RedirectBack(){      
        string idn = 'ia.' + recordtypeid;
          string userId = UserInfo.getUserId();
        
        
        
       List<Instant_Address_Cache__c> caches= [select Name, Value__c from Instant_Address_Cache__c where Name = :idn AND UserId__c =:userId  ];
        delete caches;
          
        jsonLayout = Apexpages.currentPage().getParameters().get('jsonLayout');
        Instant_Address_Cache__c cache = new Instant_Address_Cache__c();
        cache.Name = 'ia.' + recordtypeid;
        cache.Value__c = jsonLayout;
        cache.SObject__c = this.sobjectname;
        cache.UserId__c = userId;
        insert cache;        
        
        string idname = 'returnurl.' + recordtypeid;
        Instant_Address_Cache__c cacheurl = [select Name, Value__c from Instant_Address_Cache__c where Name = :idname AND UserId__c =:userId  limit 1];
 
        PageReference retURL = new PageReference(cacheurl.Value__c + '&StopRedirect=true');
 
         retURL.setRedirect(true);
        return retURL;
        //return null;
       
    }
}