public class ProcessingBatch_CL {
    //Properties    
    public string TransactionId{set;get;}
    public PageSource source{set;get;}
    public Batch_SentDataBatchable baSendata{set;get;} 
    //Contructor
    public ProcessingBatch_CL (){
        try{
            source= new PageSource();
            string tran;
            
            if(!Test.isRunningTest()){
                 tran = ApexPages.currentPage().getParameters().get('TransactionId');  
            } 
            if(string.isNotEmpty(tran)){
               TransactionId = tran; //ApexPages.currentPage().getParameters().get('TransactionId');           
            }   
        }
        catch(Exception e){
            Batch_Helpers.LogError(e );
        }
           
       //// pageDataLoad(); 
    }
    //Events
    public pageReference NextBatch(){
        try{
        
        return SentNextBatch(); 
         
        }
        catch(exception e){
          Batch_Helpers.LogError(e); 
        } 
        return null;      
    }
    
   
    //Private
    private void  pageDataLoad(){
      integer total = [SELECT count() FROM Service_Maste_Transaction__c WHERE TransactionId__c =:TransactionId];   
         
        if( total> 0){ 
              Service_Maste_Transaction__c  dt = [SELECT TransactionId__c,Data__c,IsAllDownloaded__c FROM Service_Maste_Transaction__c WHERE TransactionId__c =:TransactionId LIMIT 1]; 
      baSendata = (Batch_SentDataBatchable)System.JSON.deserialize(dt.Data__c, Batch_SentDataBatchable.class); 
        }        
      
    } 
      
    private pagereference SentNextBatch(){
        
      if( baSendata == null){
         pageDataLoad(); 
         if( baSendata == null){ return null;}       
         }
      
       if(baSendata.BatchComplete != true){
           integer total = [SELECT count() FROM Service_Maste_Transaction__c WHERE TransactionId__c =:baSendata.TransactionIndex];       
      
            if( total> 0){ 
                 Service_Maste_Transaction__c  dt = [SELECT TransactionId__c,Data__c,IsAllDownloaded__c FROM Service_Maste_Transaction__c WHERE TransactionId__c =:baSendata.TransactionIndex LIMIT 1]; 
                 baSendata = (Batch_SentDataBatchable)System.JSON.deserialize(dt.Data__c, Batch_SentDataBatchable.class);
                 
                 if(dt.IsAllDownloaded__c == true){
 
                     source.TransactionOverallStatus = 'Done';                   
                      //System.PageReference.setRedirect(true);
                     pagereference summaryredirect = new pagereference('/apex/Batch_GetBatches');
                     
                     summaryredirect.getParameters().put('TransactionId', baSendata.TransactionIndex ); 
                     summaryredirect.setRedirect(true);
                     return summaryredirect;     
                    } 
                }       
         }
       
       List<Service_Maste_Transaction_Batches__c>   data;
       data = [SELECT   Name,batchIdentifier__c,TransactionId__c,Uploaded__c,downloaded__c,AddressesCount__c FROM Service_Maste_Transaction_Batches__c WHERE TransactionId__c  =:baSendata.TransactionIndex];
          
        integer ind = 0;
        integer totalDownloaded = 0;
        integer totalToDownload = 0;
        for(Service_Maste_Transaction_Batches__c d :data){
         ind++;
         totalToDownload += (integer)d.AddressesCount__c;
          
          if(d.downloaded__c == true){
                totalDownloaded += (integer)d.AddressesCount__c;
                source.TransactionOverallStatus = 'Downloading';                
            }
          else if(d.Uploaded__c == true && d.downloaded__c != true){
                if(source.TransactionOverallStatus != 'Downloading'){
                    source.TransactionOverallStatus = 'Uploading';
                    
                    source.BatchTotalUploadCount=baSendata.TotalBatchCount;     
                    source.BatchTotalUpload=baSendata.UploadedBatchCount;     
                    if(source.BatchTotalUploadCount > 0) {
                        source.BatchTotalUploadPrecentage = String.valueOf((integer)(source.BatchTotalUpload * 100 / source.BatchTotalUploadCount));
                    }
                    return null;                    
                }                
            }           
        } 
        source.BatchTotalCount = totalToDownload;
        source.BatchTotalDownloaded = totalDownloaded;
        if(source.BatchTotalCount > 0) {
            source.BatchTotalDownloadedPrecentage = String.valueOf((integer)(source.BatchTotalDownloaded * 100 / source.BatchTotalCount));
        }
        return null;
        
       
    }
    //Public 

    //Class
    public class PageSource{
        //BatchUpload 
        public integer BatchTotalUploadCount{get;set;}
        public integer BatchTotalUpload{get;set;}
        public string BatchTotalUploadPrecentage{get;set;}
        
        public boolean UploadProcessStart{
            get{
              return   BatchTotalUpload != null;              
            }
        }
        
        
        //source.BatchTotalUpload
        
        public string TransactionId{get;set;}       
        public string TransactionOverallStatus{get;set;}
        public integer BatchTotalDownloaded{get;set;}
        public integer BatchTotalCount{get;set;}
        public string BatchTotalDownloadedPrecentage{get;set;}
    }
}