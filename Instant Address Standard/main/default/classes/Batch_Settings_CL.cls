public class Batch_Settings_CL 
{
    //Properties
    public list<DefaulTFormat> DefaulTFormatList{get;set;}  
    public list<objectClass> selectedObjList{get;set;}   
    public list<objectClass> standardObjList{get;set;}    
 
    public FINAL integer numberOfObject;
    public set<string> objectSet{get;set;}
    //This is a variable to check if we're done with the Iteration.
    public string isIterationDone{get;set;}
    public  Parameter__c CurrentParameters{get;set;}
    //Constructor.
    public Batch_Settings_CL(){
         
        //initializing the lists. 
        
        standardObjList = new list<objectClass> ();
        
       objectSet= new set<string>();
       list<schema.sObjectType> allObjects = Schema.getGlobalDescribe().Values();
        //get number of objects available for iteration.
       numberOfObject = allObjects.size();
       isIterationDone = 'No';
        ObjectList();
        
       //initializing the parameters. 
       LoadParameters();
        
        // Load settings
       LoadDataSetformatsDefaul();
   
   }
    
    //Event Handler    
    public void SyncData(){
        try{
            Communication.DataSetsResponse  respDataSet=  Communication.DataSets(this.CurrentParameters);
            Communication.FormatsResponse respFormats = Communication.Formats();
             Communication.DownloadFlagsResponse respFlags = Communication.DownloadFlags();
            
            
            
            // Sync Dataset 
          List<PostalData__c>  LstPostal = [select id from PostalData__c];
            delete LstPostal;
        
           LstPostal.clear();        
        
                for(Communication.DataSetsItem obj : respDataSet.data){
                    String id = Batch_Helpers.NewGuid();
                       PostalData__c pref = new PostalData__c(Id__c = id,Name =  obj.name,Iso_2__c = obj.iso_2,iso_3__c = obj.iso_3    );
                       LstPostal.add(pref) ;        
                }
        
          insert LstPostal;    
 
            // sync Format
           
       
        
        List<Format__c>  LstFormats = [select id from Format__c];
        delete LstFormats;        
        LstFormats.clear();        
        
        for(Communication.FormatsItem obj : respFormats.data){
            //String id = Batch_Helpers.NewGuid();
               Format__c pref = new Format__c(Id__c = obj.formatid ,FormatName__c =obj.name   );
               LstFormats.add(pref) ;        
        }
        
       insert LstFormats; 
               
      //
     system.debug(' LstFalg ');
     List<Flag__c>  LstFalgs = [select id from Flag__c];
            
        system.debug(LstFalgs);
       delete LstFalgs;        
       LstFalgs.clear(); 
             
       for(Communication.FlagItem obj : respFlags.data){            
            Flag__c pref = new Flag__c(FlagId__c = obj.RowKey ,Name = obj.Name, FlagLevel__c =obj.PartitionKey, Description__c =obj.Description, Value__c = obj.Value );
            LstFalgs.add(pref) ;        
        }
        
       insert LstFalgs; 
            
      //complete
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Data synced'));
        }
        catch(exception e){ ExceptionHelper.LogError(e,'SyncData');}
    }
    public void SaveDefaultformat(){
        try{
            
        List<FormatsDefault__c>  Lst = [select id from FormatsDefault__c];
        delete Lst;
        Lst.clear();
            for( DefaulTFormat   c: DefaulTFormatList){
                FormatsDefault__c pref = new FormatsDefault__c(DatasetId__c = c.Id, BatchFormatId__c= c.DefaultFormatBatch , RealtimeFormatId__c= c.DefaultFormatRealTime  );                 
                Lst.add(pref) ;  
            }
           insert Lst;  
           //LoadDataSetformatsDefaul();
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Saved'));
        }          
        catch(exception e){ ExceptionHelper.LogError(e,'SaveDefaultformat');}
    }
    public void SaveParameters(){        
      IF(ValidateParameters()){     
         CurrentParameters.USERNAME__c ='';
         CurrentParameters.PASSWORD__c ='';
         CurrentParameters.LICENSEKEY__c ='';
         CurrentParameters.FORMATID__c ='';
      }    
    }
    public void SavePrefObjects(){    
        getSelected();
        List<PreferObject__c>  Lst = [select id from PreferObject__c];
        delete Lst;
        
        Lst.clear(); 
        for(objectClass obj : selectedObjList){
               PreferObject__c pref = new PreferObject__c(Label__c =obj.label,apiName__c=obj.apiName, Id__c = obj.Id,objectType__c =obj.objectType );
                Lst.add(pref) ;        
        }
       insert Lst; 
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Saved'));
    }    
    public pagereference Cancel(){    
       return new pagereference('/apex/Batch_NewSession_UI'); 
    }    
    public PageReference getSelected(){
        selectedObjList = new list<objectClass> ();
        //selectedObjList.clear();
        for(objectClass obj : standardObjList)
        if(obj.selected == true)
        selectedObjList.add(obj);
        return null;
    }
  
    //Private   
   
    private void LoadDataSetformatsDefaul(){
        DefaulTFormatList = new List<DefaulTFormat>();
       List<PostalData__c>  Lst = [select id,iso_3__c,Name from PostalData__c];
       List<FormatsDefault__c>  defaults;
        integer total =   [SELECT count() FROM FormatsDefault__c];  
 
        if(total >0){
            defaults= [SELECT  DatasetId__c, BatchFormatId__c, RealtimeFormatId__c  FROM FormatsDefault__c];
        }       
        else{
            defaults = new List<FormatsDefault__c> ();
        }
        for(PostalData__c c : Lst) {
            
           DefaulTFormat t = new DefaulTFormat();
            t.Id= c.iso_3__c;
            t.Name = c.Name;   
             
            for(FormatsDefault__c format : defaults) {
                if(t.Id == format.DatasetId__c){
                  t.DefaultFormatBatch = format.BatchFormatId__c;
                  t.DefaultFormatRealTime  =   format.RealtimeFormatId__c ;        
 
                }              
            } 
           DefaulTFormatList.Add(t);
        }
       
    }
    private void  LoadDataSets( Parameter__c p){
        
        Communication.DataSetsResponse  resp=  Communication.DataSets(p);
        
        List<PostalData__c>  Lst = [select id from PostalData__c];
        delete Lst;
        
        Lst.clear();
        
        
        for(Communication.DataSetsItem obj : resp.data){
            String id = Batch_Helpers.NewGuid();
               PostalData__c pref = new PostalData__c(Id__c = id,Name =  obj.name,Iso_2__c = obj.iso_2,iso_3__c = obj.iso_3    );
               Lst.add(pref) ;        
        }
        
       insert Lst;    

    } 
    private Boolean ValidateParameters(){
        //VALIDATE MANDATORY DATA

        Boolean v1 = true;
        if(!string.isNotEmpty(CurrentParameters.USERNAME__c) ){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Missing user name!'));
            v1 = false;
        }
        if(!string.isNotEmpty(CurrentParameters.PASSWORD__c)  ){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Missing password!'));
            v1 = false;
        }
        if(!string.isNotEmpty(CurrentParameters.LICENSEKEY__c)){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Missing license key!'));
            v1 = false;
        }
        if(!string.isNotEmpty(CurrentParameters.FORMATID__c)){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Missing format id!'));
            v1 = false;
        }
        if( v1){
             
           Parameter__c tParameter = CurrentParameters.clone();
          
           tParameter.LICENSEKEY__c =Batch_Helpers.Encrypt(tParameter.LICENSEKEY__c);
         
           Communication.ValidateLicenseResponse resp=  Communication.ValidateLicense(tParameter);
            
            if(resp.statusCode ==200){
                
                CurrentParameters.LICENSEKEY__c = tParameter.LICENSEKEY__c;
                CurrentParameters.ENVIRONMENT__c = resp.environment;
                CurrentParameters.TOKEN__c = resp.token;
                CurrentParameters.TOKEN_EXPIRATION__c = Batch_Helpers.Encrypt(resp.expiration) ;
                
                   LoadDataSets(CurrentParameters);
                
                if(!Test.isRunningTest()){
                    IF(CurrentParameters.PARAMETERID__c == 'null'){            
                       CurrentParameters.PARAMETERID__c=  Batch_Helpers.NewGuid();
                         insert CurrentParameters; 
                        }
                     else{
                         update CurrentParameters;
                     }
                    }
            
                  
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Saved'));
                
                return true;
            }
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,resp.message));
        }       
        
        return false;
    }
    private void LoadParameters(){
        
    integer total = [SELECT count() FROM Parameter__c];
        
        if(total < 1){
             this.CurrentParameters = new Parameter__c( PARAMETERID__c = 'null');  
        } 
        else{
           this.CurrentParameters = [select PARAMETERID__c, USERNAME__c, PASSWORD__c,LICENSEKEY__c,ENVIRONMENT__c,TOKEN_EXPIRATION__c,TOKEN__c,FORMATID__c  from Parameter__c limit 1 ];      
       
        //CurrentParameters.USERNAME__c ='';
        //CurrentParameters.PASSWORD__c ='';
        this.CurrentParameters.LICENSEKEY__c = Batch_Helpers.Decrypt(this.CurrentParameters.LICENSEKEY__c);
		//CurrentParameters.FORMATID__c='';
        }   
    }
    private Boolean IsPrefer(List<PreferObject__c> customObjects,string val){
        for(PreferObject__c c : customObjects){
            if(c.Id__c == val ){
                return true;
            }
        }
        return false;
    }    
    //Public 
    public  void ObjectList(){
        
        List<PreferObject__c> customObjects = [select Id__c, Label__c from PreferObject__c]; 
        // check if we have all the objects added in the list
        if(( standardObjList.size())<numberOfObject){
            integer i=0;
            for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){       
                   // if(!objectSet.contains(objTyp.getDescribe().getName()) && objTyp.getDescribe().getKeyPrefix() != null && objTyp.getDescribe().getKeyPrefix() != ''){
                       // i++;                 
                                               
                       // objectSet.add(objTyp.getDescribe().getName());
                        
                        Boolean checked = IsPrefer(customObjects,objTyp.getDescribe().getName());
                if(( standardObjList.size())<1000 ){                    
                      //check if its a custom or standard object.
                        if(objTyp.getDescribe().isCustom()){
                            standardObjList.add(new objectClass(objTyp.getDescribe().getName(),objTyp.getDescribe().getLabel(), objTyp.getDescribe().getName(),'Custom',checked));
                        }else{
                            standardObjList.add(new objectClass(objTyp.getDescribe().getName(),objTyp.getDescribe().getLabel(), objTyp.getDescribe().getName(),'Standard',checked));                        
                        }
                   }
                    //}
              /*  }else{
                    break;
                }*/
            }
             standardObjList.sort();
        }else{
            isIterationDone = 'Yes';
        }
    }      
    //class 
    public class objectClass implements Comparable{
        public string Id{get;set;}
        public string label{get;set;}
        public string apiName{get;set;}
        public string objectType{get;set;}
        public Boolean selected {get; set;}
        
        //Contructor
        public objectClass(string key,  string lab, string api , string oType,Boolean ck){
             this.Id =key;
            this.label = lab;
            this.apiName = api;   
            this.selected = ck;
            this.objectType = oType;
        }
        //Implement
        public Integer compareTo(Object compareTo) {
          objectClass obj = (objectClass)compareTo;
           if (label == obj.label) return 0;
           if (label > obj.label) return 1;
             return -1; 
           }
    } 
    public class DefaulTFormat {
       private string pId;
        
        public string Id{get{
            return pid;
        }set{
            pid = value;
           Formats = getFormats(pid); 
        }}
      public string Name{get;set;}
      public string DefaultFormatBatch{get;set;}   
      public string DefaultFormatRealTime{get;set;}  
      public List<SelectOption>  Formats {get;set;}   
      private   List<SelectOption>  getFormats( string dataset  ){
        List<SelectOption> toReturn  = new List<SelectOption>();
        integer total =   [SELECT count() FROM Format__c];    
        if(total > 0){
          List<Format__c > data =  [SELECT Id__c, FormatName__c,DatasetId__c  FROM Format__c];  // where dataset  TBD  
            
            for(Format__c c :data){                  
               toReturn.add(new SelectOption(c.Id__c , c.FormatName__c));
            }            
        }       
        
        return toReturn;
    }
        
    }
    
}