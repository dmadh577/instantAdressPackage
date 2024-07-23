public class BatchTransactionCounter implements Database.Batchable<SObject>,Database.Stateful {
   
    public string SoqlCount{set;get;}  
    public string Soql{set;get;}  
    public  Integer total  =0; 
    public String  TransactionId {set;get;}  
    public  Integer BatchCount {set;get;} 
    public Batch_SentDataBatchable baSendata{set;get;}   
    
     public Database.QueryLocator start(Database.BatchableContext context) {
         string tsql = Soql.replace('COUNT()', 'Id');
            return Database.getQueryLocator(tsql);
        }
     public void execute(Database.BatchableContext BC,List<sObject> scope) {            
       total += scope.size();                 
     }
     public void finish(Database.BatchableContext context) {           
       baSendata.TotalBatchCount =total;
        Database.executeBatch(baSendata,BatchCount);        
     }
}