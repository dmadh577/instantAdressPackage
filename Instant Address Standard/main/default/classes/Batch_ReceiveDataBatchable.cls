public class Batch_ReceiveDataBatchable implements Database.Batchable<sObject>,  Database.AllowsCallouts {

   public boolean BatchComplete {set;get;}    
   public string Soql{set;get;}   
   public  Integer total = 0;
    public integer totalAddresses = 0;
   public  Integer MaxRetry = 0;
   public String  TransactionIndex {set;get;}
   public string FormatId {set;get;}
   public Map<string, integer> FlagsAndCounts{get;set;}
   @TestVisible  boolean bypass  = false;
    //Privates  
 
    @TestVisible
   private List<ServiceOutput__c> parseList(List<Response> responselist){
        List<ServiceOutput__c> outputlist = new List<ServiceOutput__c>();
        for(Response response : responselist){
            try
            {
                ServiceOutput__c output = new ServiceOutput__c();
                output.TransactionId__c = TransactionIndex;
                output.recordkey__c = response.details[0].recordkey;
                output.recordtype__c = response.details[0].recordtype;
                output.carrierrouteid__c = response.details[0].carrierrouteid;
                output.streetpredirectionalabbrev__c = response.details[0].streetpredirectionalabbrev;
                output.streetpredirectionalname__c = response.details[0].streetpredirectionalname;
                output.streetprefixabbrev__c = response.details[0].streetprefixabbrev;
                output.streetprefixname__c = response.details[0].streetprefixname;
                output.street__c = response.details[0].street;
                output.privatemailbox__c = response.details[0].privatemailbox;
                output.privatemailboxnumber__c = response.details[0].privatemailboxnumber;
                output.pobox__c = response.details[0].pobox;
                output.poboxnumber__c = response.details[0].poboxnumber;
                output.streetsuffixabbrev__c = response.details[0].streetsuffixabbrev;
                output.streetsuffixname__c = response.details[0].streetsuffixname;
                output.streetpostfixabbrev__c = response.details[0].streetpostfixabbrev;
                output.streetpostfixname__c = response.details[0].streetpostfixname;
                output.zipcode__c = response.details[0].zipcode;
                output.zip4__c = response.details[0].zip4;
                output.zip4low__c = response.details[0].zip4low;
                output.zip4high__c = response.details[0].zip4high;
                output.housenumberlow__c = response.details[0].housenumberlow;
                output.housenumberhigh__c = response.details[0].housenumberhigh;
                output.housenumberparity__c = response.details[0].housenumberparity;
                output.building__c = response.details[0].building;
                output.secondaryunitabbrev__c = response.details[0].secondaryunitabbrev;
                output.secondaryunitname__c = response.details[0].secondaryunitname;
                output.secondaryunitlow__c = response.details[0].secondaryunitlow;
                output.secondaryunithigh__c = response.details[0].secondaryunithigh;
                output.secondaryunitparity__c = response.details[0].secondaryunitparity;
                output.stateabbrev__c = response.details[0].stateabbrev;
                output.statename__c = response.details[0].statename;
                output.stateid__c = response.details[0].stateid;
                output.congressionaldistrictid__c = response.details[0].congressionaldistrictid;
                output.municipalitykey__c = response.details[0].municipalitykey;
                output.urbanizationkey__c = response.details[0].urbanizationkey;
                output.basealternamecodeflag__c = response.details[0].basealternamecodeflag;
                output.lacsflag__c = response.details[0].lacsflag;
                output.governmentflag__c = response.details[0].governmentflag;
                output.housenumber__c = response.details[0].housenumber;
                output.secondaryunit__c = response.details[0].secondaryunit;
                output.citystatekey__c = response.details[0].citystatekey;
                output.cityname__c = response.details[0].cityname;
                output.preferredcityname__c = response.details[0].preferredcityname;
                output.citydeliveryflag__c = response.details[0].citydeliveryflag;
                output.carrierrouteflag__c = response.details[0].carrierrouteflag;
                output.financialnumber__c = response.details[0].financialnumber;
                output.countyid__c = response.details[0].countyid;
                output.countyname__c = response.details[0].countyname;
                output.dpv__c = response.details[0].dpv;
                output.dpc__c = response.details[0].dpc;
                output.dpcd__c = response.details[0].dpcd;
                output.dpvf__c = response.details[0].dpvf;
                //output.mailstopcode__c = response.details[0].mailstopcode;
                output.dataretentionelement1__c = response.details[0].dataretentionelement1;
                output.dataretentionelement2__c = response.details[0].dataretentionelement2;
                output.datapostretentionelement__c = response.details[0].datapostretentionelement;
                output.countryname__c = response.details[0].countryname;
                output.countryid__c = response.details[0].countryid;
                output.latitude__c = response.details[0].latitude;
                output.longitude__c = response.details[0].longitude;
                output.cmra__c = response.details[0].cmra;
                output.rdi__c = response.details[0].rdi;
                output.elotcode__c = response.details[0].elotcode;
                output.elotnumber__c = response.details[0].elotnumber;
                //output.verifiedOn__c = response.details[0].verifiedOn;
                output.fips__c = response.details[0].fips;
                //output.geoflag__c = response.details[0].geoflag;
                output.augmentedBuilding__c = response.details[0].augmentedBuilding;
                output.urbanization__c = response.details[0].urbanization;
                output.timestamp__c = response.timestamp;
                output.verificationFlag__c = response.verificationflag;
                output.responseflag__c = response.responseflag;
                if(response.responseflag != null && response.responseflag != ''){
                    this.CountFlag(response.responseflag);
                }
                output.addresschangeflags__c = response.addresschangeflags;
                output.ErrorData__c = response.errordata;
                output.FR_Country__c =  response.formattedaddress.Country;
                output.FR_Address1__c = response.formattedaddress.Address1;
                output.FR_Address2__c = response.formattedaddress.Address2;
                output.FR_Address3__c = response.formattedaddress.Address3;
                output.FR_Address4__c = response.formattedaddress.Address4;
                output.FR_Address5__c = response.formattedaddress.Address5;
                output.FR_City__c =     response.formattedaddress.City;
                output.FR_State__c =    response.formattedaddress.State;
                output.FR_Zipcode__c =  response.formattedaddress.Zipcode;
                output.IA_Address1__c = response.inputaddress.street1;
                output.IA_Address2__c = response.inputaddress.street2;
                output.IA_Address3__c = response.inputaddress.street3;
                output.IA_Address4__c = response.inputaddress.street4;
                output.IA_Address5__c = response.inputaddress.street5;
                output.IA_City__c = response.inputaddress.city;
                output.IA_State__c = response.inputaddress.state;
                output.IA_Zipcode__c = response.inputaddress.zipcode;
                output.IA_Zip4__c = response.inputaddress.zip4;
                output.IA_Reference1__c = response.inputaddress.Reference1;
                output.IA_Reference2__c = response.inputaddress.Reference2;
                output.IA_Reference3__c = response.inputaddress.Reference3;
                output.IA_Reference4__c = response.inputaddress.Reference4;
                output.IA_Reference5__c = response.inputaddress.Reference5;
                outputlist.add(output);
            }
            catch(exception e){ ExceptionHelper.LogError(e,'parseList-Batch_receiveDataBatchable');}
        }
        return outputlist;
    }
   @TestVisible
    private Boolean IsBatchReadyToDownload(Service_Maste_Transaction_Batches__c batch){
     Batch_SentDataBatchable.batchItem toReturn = null;        
      Communication.GetBatchSessionStateResponse  res ;
        if(!bypass ){
            res =Communication.GetBatchSessionState(batch.BatchId__c);
        }
        
        if(bypass ||res.data.completed == 'true' ){
            return  true;
            }    
               
     return false;
    }    
  @TestVisible
    private void CountFlag(string flag){
        try{
            if(this.FlagsAndCounts == null){
                this.FlagsAndCounts = new Map<string, integer>();
            }
            if(this.FlagsAndCounts.containsKey(flag)){
                integer c = this.FlagsAndCounts.get(flag);
                this.FlagsAndCounts.put(flag, (c + 1));
            } else {
                this.FlagsAndCounts.put(flag, 1);
            }
        } catch(Exception e){
            Error_Log__c error = new Error_Log__c();
            error.Message__c = e.getMessage();
            insert error;
        }
    }
   @TestVisible
   private Map<string, integer> UpdateMap(Map<string, integer> prev){
        for (string flag : prev.keySet()) {
            if(this.FlagsAndCounts.containsKey(flag)){
                integer c = this.FlagsAndCounts.get(flag);
                prev.put(flag, (c + prev.get(flag)));
            }
        }
        for (string flag : this.FlagsAndCounts.keySet()) {
            if(!prev.containsKey(flag)){
                prev.put(flag, this.FlagsAndCounts.get(flag));
            }
        }
        
        return prev;
    }
   @TestVisible
   public  void DownloadBatches(Service_Maste_Transaction_Batches__c batch){
     system.debug('DownloadBatches');
      string batchId = batch.BatchId__c;
      Communication.SessionResultsResponse  res ;  
         system.debug(res);
       if(!bypass){
           res = Communication.SessionResults(batchId,FormatId); 
       }
       else{
           res = new Communication.SessionResultsResponse();
           res.data=new  List<Response>();
       }
      
      if(res.IsValid ){ 
           
       
         List<ServiceOutput__c> toInsert = parseList(res.data);
         if(toInsert != null && toInsert.size() > 0){
             //totalAddresses = toInsert.size();
             Service_Maste_Transaction__c  tran = [SELECT Id,Name, TransactionId__c,Data__c,Total_Addresses__c,Response_Flag_Metrics__c FROM Service_Maste_Transaction__c WHERE TransactionId__c =:TransactionIndex LIMIT 1];
             if(tran.Response_Flag_Metrics__c != null && tran.Response_Flag_Metrics__c != '' && !bypass){
                 tran.Response_Flag_Metrics__c = JSON.serialize(UpdateMap((Map<string, integer>)JSON.deserialize(tran.Response_Flag_Metrics__c, Map<string, integer>.class)));
             } else {
                 tran.Response_Flag_Metrics__c = JSON.serialize(this.FlagsAndCounts);
             }
             if(tran.Total_Addresses__c != null){
                 tran.Total_Addresses__c += toInsert.size();
             } else {
                 tran.Total_Addresses__c = toInsert.size();
             }
              if(!bypass){
                  
                  try{
                       update tran; 
                       insert toInsert;
                      }
                    catch(exception e){
                       Batch_Helpers.LogError(e);           
                    } 
                              
              }            
        }  
      }
       if(!res.IsValid){
        batch.HasError__c = true;
        batch.Message__c = res.message;      
       }
       
     // Update Batch Status   
        batch.downloaded__c = true;
       if(!bypass){
           update batch;
       }
 
    }
    // public impletemtation 
   public Database.QueryLocator start(Database.BatchableContext BC){  
        try{
            total = 0;
           totalAddresses = 0;
           this.FlagsAndCounts = new Map<string, integer>();
        }
        catch(exception e){ ExceptionHelper.LogError(e,'start');}
        
        return Database.getQueryLocator(Soql); 
    }    
   public void execute(Database.BatchableContext BC,List<Service_Maste_Transaction_Batches__c> scope){
        try{
             for(Service_Maste_Transaction_Batches__c c:scope){
                if(IsBatchReadyToDownload(c) == true){
                  DownloadBatches(c);            
                  total+= scope.size(); 
                }               
            }
           
        }
        catch(exception e){
           ExceptionHelper.LogError(e,'receive execute');
        }      
      } 
   public void finish(Database.BatchableContext BC){       
   try{
      integer count = database.countQuery('SELECT  COUNT()  FROM Service_Maste_Transaction_Batches__c WHERE TransactionId__c = \''+TransactionIndex +'\' AND downloaded__c = false');
     
       if(count > 0){
          
           Batch_ReceiveDataBatchable receiveBatch= new Batch_ReceiveDataBatchable();
           receiveBatch.TransactionIndex =TransactionIndex;
           receiveBatch.Soql =  'SELECT Name,TransactionId__c,BatchId__c,downloaded__c,Uploaded__c  FROM Service_Maste_Transaction_Batches__c WHERE TransactionId__c = \''+TransactionIndex +'\' AND downloaded__c = false' ;   
           Database.executeBatch(receiveBatch,1);  
           return;
       }        
        if(!bypass){
      
      Service_Maste_Transaction__c  tran = [SELECT Id,Name, TransactionId__c,Data__c,Total_Addresses__c FROM Service_Maste_Transaction__c WHERE TransactionId__c =:TransactionIndex LIMIT 1]; 
    
     
       Batch_SentDataBatchable tranbatch  = (Batch_SentDataBatchable)System.JSON.deserialize(tran.Data__c, Batch_SentDataBatchable.class);
       tranbatch.BatchComplete = true;       
       tran.Data__c  =  JSON.serialize(tranbatch);
       tran.IsAllCopied__c = true;  
       tran.IsAllDownloaded__c = true;
       tran.Status__c  = 'Processed'; 
       tran.Total_Addresses__c = total;
      update tran;  
       }    
        }
        catch(exception e){
           ExceptionHelper.LogError(e,'finish');           
        }           
    } 
}