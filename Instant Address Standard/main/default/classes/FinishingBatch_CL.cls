public class FinishingBatch_CL {
    //Properties    
    public string TransactionId{set;get;}
    public PageSource source{set;get;}
    public Batch_SentDataBatchable baSendata{set;get;} 
    //Contructor
    public FinishingBatch_CL (){
        try{
            
            source= new PageSource();
           string tran = ApexPages.currentPage().getParameters().get('TransactionId'); 
        
             
            if(string.isNotEmpty(tran)){
               TransactionId = tran; //ApexPages.currentPage().getParameters().get('TransactionId');    
                SentNextBatch();
            }   
          
        }
        catch(Exception e){
            Batch_Helpers.LogError(e );
        }    
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
      
    private pagereference SentNextBatch(){
       
       integer transcount = database.countQuery('SELECT COUNT() FROM Service_Maste_Transaction__c WHERE TransactionId__c = \''+TransactionId +'\' ');
        if(transcount == 0){
            
            return  new pagereference('/apex/Batch_NewSession_UI?finishmessage=true&total='+source.BatchTotalCount);
        }
        else{ 
            Service_Maste_Transaction__c  dt = [SELECT TransactionId__c,Data__c, Total_Addresses__c  FROM Service_Maste_Transaction__c WHERE TransactionId__c =:TransactionId LIMIT 1];
             baSendata = (Batch_SentDataBatchable)System.JSON.deserialize(dt.Data__c, Batch_SentDataBatchable.class); 
            
            
           source.BatchTotalCount  = baSendata.TotalBatchCount;   
            source.BatchTotalDownloaded= integer.valueOf(dt.Total_Addresses__c);     
            if(source.BatchTotalCount > 0) {
                source.BatchTotalDownloadedPrecentage = String.valueOf((integer)(source.BatchTotalDownloaded * 100 / source.BatchTotalCount));
            }
        }
        return null;
         
    }
    //Public 

    //Class
    public class PageSource{
        public string  TransactionId{get;set;}       
        public string  TransactionOverallStatus{get;set;}
        public integer BatchTotalDownloaded{get;set;}
        public integer BatchTotalCount{get;set;}
        public string  BatchTotalDownloadedPrecentage{get;set;}
    }
}