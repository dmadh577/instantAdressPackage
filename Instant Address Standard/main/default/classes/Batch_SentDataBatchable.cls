public class Batch_SentDataBatchable implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts{
   public boolean BatchComplete {set;get;}    
   public string Soql{set;get;}  
   public List<Batch_NewSession_CL.MappingItem> SourceMapping {set;get;}    
   public String  TransactionIndex {set;get;}   
   public  Integer Total = 0; 
   public  Integer TotalBatchCount {set;get;}
   public  Integer UploadedBatchCount {set;get;}
   public string MappingId {set;get;}
   public string MappingName {set;get;}
   public string PostData {set;get;}
   public String SelectedObject {get;set;}
   public String SelectedObjectName {get;set;}
   public String UserId{get;set;}
   public string FormatId {set;get;}
  
   @TestVisible boolean bypass  = false;    
    //Privates    
   @TestVisible  
   private string GetFieldLabel(String name,  Batch_NewSession_CL.MappingItem mapping ){
        
        String fieldName;
         
         for(Batch_NewSession_CL.MappingField tfield : mapping.MappingsList){               
             if(tfield.MapField == name ){               
                  return tfield.Field.replaceAll('street', '');
             }
         }
        return '';   
      }
   private string GetFieldValue(String name, sObject data, Batch_NewSession_CL.MappingItem mapping ){
        return GetFieldValue(name,data,mapping,1);
    }
   private string GetFieldValue(String name, sObject data, Batch_NewSession_CL.MappingItem mapping, integer index){
        
        String fieldName;
        integer i = 1;
         for(Batch_NewSession_CL.MappingField tfield : mapping.MappingsList){               
             if(tfield.MapField == name ){
                 if(index == i){
                     fieldName = tfield.Field;
                 }  
                 i++;
                }       
              }
        
       
        if(!string.isNotEmpty(fieldName)) {
            return null;
        }
        
        try {
                return (String)data.get(fieldName) ;
            }
            Catch (exception e) {
                //system.debug('error: ' + e.getMessage());
                  return 'invalid data'  ;
            }  
    }
   private string GetId(sObject data ){
        return (String)data.get('id'); 
    }
   private List<ServiceInput__c> Convert_Batch(List<sObject> tData  , string tBatchIndex) {                 
       //List<sObject> tData =   GetData;     
      
       List<ServiceInput__c> toReturnData =  new  List<ServiceInput__c>();    
        
        for(sObject tRow : tData){
            integer mapIndex = 0;
          for(Batch_NewSession_CL.MappingItem tfield : SourceMapping){
                ServiceInput__c d = new ServiceInput__c();
              
                d.Country__c   = GetFieldValue('Country',tRow, tfield);
                d.ZipCode__c   = GetFieldValue('Zipcode',tRow, tfield);
                d.State__c     = GetFieldValue('State',tRow, tfield);
                d.City__c      = GetFieldValue('City',tRow, tfield);
                d.Address1__c  = GetFieldValue('Address',tRow, tfield,1);
                d.Address2__c  = GetFieldValue('Address',tRow, tfield,2);
                d.Address3__c  = GetFieldValue('Address',tRow, tfield,3);
                d.Address4__c  = GetFieldValue('Address',tRow, tfield,4 );
                d.Address5__c  = GetFieldValue('Address',tRow, tfield,5); 
                 
                d.ClientRef1__c = GetId(tRow);
                d.ClientRef2__c = tfield.Id;
              
                d.BatchIndex__c=tBatchIndex;
                d.TransactionId__c=TransactionIndex;
              
                 toReturnData.add(d); 
              
               mapIndex ++;
            }    
         }   
        
        
        return toReturnData;
        } 
  @TestVisible
   private batchResonse UploadBatch(List<ServiceInput__c> tmpList){
       List<InputAddress> listtoreview = new List<InputAddress>();
       for(ServiceInput__c c : tmpList) {
                            InputAddress i = new InputAddress();
                            i.reference1 = c.ClientRef1__c;
                            i.reference2 = c.ClientRef2__c;           
                             
                            //i.country = c.Country__c;
                            if(string.isEmpty(c.Country__c))
                            {
                                   i.country = 'USA';
                            }
           					else if (c.Country__c.toUppercase() == 'CANADA')
                            {
                                i.country = 'CAN';
                            } 
                            else if (c.Country__c.toUppercase() == 'CA')
                            {
                                i.country = 'CAN';
                            }  
           					else if (c.Country__c.toUppercase() == 'CAN')
                            {
                                i.country = 'CAN';
                            }  
           					else
                            {
                                i.country = 'USA';
                            }
           
                            i.state = c.State__c;
                            i.city = c.City__c; 
                            i.zipcode = c.ZipCode__c; 
                            i.street1 = c.Address1__c; 
                            i.street2 = c.Address2__c;
                            i.street3 = c.Address3__c;
                            i.street4 = c.Address4__c;
                            i.street5 = c.Address5__c;
                              
                            listtoreview.add(i);                  
                        }      

     Communication.StartBatchSessionResponse  resp ;  
       
       if(bypass){
           resp = new  Communication.StartBatchSessionResponse();
           resp.batchid='sdasdasa';
       }
       if(!bypass){
            String jsonBody = json.serialize(listtoreview);
           
             resp  = Communication.StartBatchSession('Salesforce','Salesforce',PostData,jsonBody);          
           }
      
        
       Service_Master__c  smItem = new Service_Master__c();
       smItem.BatchID__c = resp.batchid;
       smItem.AddressCount__c = listtoreview.size();
       smItem.Country__c = PostData;
       smItem.Created__c = Batch_Helpers.getUTCDateTime();   //UserInfo.getUserId();
       
       if(!bypass){insert smItem;  }
        
       batchResonse resp2 =new batchResonse();
       if(!bypass){
           resp2.batchId = resp.batchid ;}
       resp2.processed = true;
       resp2.Message = '';   //resp.message      
 
       return resp2 ;
    }
    // public impletemtation 
   public Database.QueryLocator start(Database.BatchableContext BC){     
     
       try{
           UploadedBatchCount = 0;
           Service_Maste_Transaction__c  dt = new Service_Maste_Transaction__c() ;
           dt.Data__c =JSON.serialize(this);
           dt.TransactionId__c = TransactionIndex;
           dt.IsAllCopied__c = true;
           dt.UserId__c  = UserId;
           dt.Status__c  = 'Start';       
               if(!bypass){
                  insert dt;             
               }        
        }
        catch(exception e){ ExceptionHelper.LogError(e,'start');}        
        return Database.getQueryLocator(Soql); 
    }    
   public void execute(Database.BatchableContext BC,List<sObject> scope){
        
        try{         
            string tindex = Batch_Helpers.NewGuid();
            system.debug(scope);
            List<ServiceInput__c> dataList = Convert_Batch(scope,tindex); 
           batchResonse resp;
            if(!bypass){
                 
             resp =  UploadBatch(dataList); 
           
            }
            // send batch
            Service_Maste_Transaction_Batches__c  btch =  new Service_Maste_Transaction_Batches__c();
            btch.TransactionId__c = TransactionIndex;
            if(!bypass){
              btch.BatchId__c = resp.batchId;  
            }
            
            btch.Uploaded__c = true;
            btch.AddressesCount__c = dataList.size();
            
            if(!bypass){
               insert btch; 
                 Service_Maste_Transaction__c  tran = [SELECT Id,Name, TransactionId__c,Data__c FROM Service_Maste_Transaction__c WHERE TransactionId__c =:TransactionIndex LIMIT 1];
                 
                UploadedBatchCount += dataList.size();
                 tran.Data__c = JSON.serialize(this);
               update tran;
            }
             
        }
        catch(exception e){
             ExceptionHelper.LogError(e,'execute send');
        }      
      } 
   public void finish(Database.BatchableContext BC){    
       try{
               Batch_ReceiveDataBatchable receiveBatch= new Batch_ReceiveDataBatchable();
               receiveBatch.TransactionIndex =TransactionIndex;
               receiveBatch.FormatId =FormatId;
               receiveBatch.Soql =  'SELECT Name,TransactionId__c,BatchId__c,downloaded__c,Uploaded__c  FROM Service_Maste_Transaction_Batches__c WHERE TransactionId__c = \''+TransactionIndex +'\' AND downloaded__c = false' ;   
            
             if(!bypass){
                 Database.executeBatch(receiveBatch,1); 
               }
        }
        catch(exception e){ ExceptionHelper.LogError(e,'finish');} 
   }    
   public class batchResonse{
        public string batchId{set;get;}
        public boolean processed{set;get;}
        public string Message{set;get;}
    }
   public class batchItem {
        public integer index{set;get;}  
        public string batchId{set;get;}
        public boolean upload{set;get;}  
        public boolean isDeleted{set;get;}  
        public boolean isDownloaded{set;get;} 
    }
}