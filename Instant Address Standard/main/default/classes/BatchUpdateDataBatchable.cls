public class BatchUpdateDataBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts{
   public boolean BatchComplete {set;get;}    
   public string Soql{set;get;}  
   public List<Batch_NewSession_CL.MappingItem> SourceMapping {set;get;}  
   public string MappingId {set;get;}  
   public String SelectedObject {get;set;}
    public String SelectedObjectName {get;set;}
   public string TransactionId {set;get;}  
    
    @TestVisible  boolean bypass  = false;
   // Private
   
   private Schema.sObjectType GetByName( string val){
      list<schema.sObjectType> allObjects = Schema.getGlobalDescribe().Values();
        for(schema.sObjectType c : allObjects){
            if( c.getDescribe().getName() == val ){
                return c;
            }
        }
        return null;
      }
   private string QueryBuilderForList(  ){
      string base ='SELECT {0} FROM {1}';
       
      schema.sObjectType tmp = GetByName(SelectedObject);
      String oName = tmp.getDescribe().getName();
      
      List<string> columnsList = new List<String>();
        
      Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(oName).getDescribe().fields.getMap();
        
      string selectitems = '';
      for(Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            columnsList.add(dfield.getName());            
        }
                
       String columnsString = String.join(columnsList, ','); 
       List<String> fillers = new String[]{columnsString,oName};     
       String formatted = String.format(base, fillers); 
               
       formatted = formatted+' WHERE ID = :Ids ';
       formatted = formatted+ ' ORDER BY ID';
       
       return formatted;
    } 
 
  @TestVisible  
   private void UpdateFieldByName(sObject obj, string fiel, object value){      
       try {
           Map<String, Schema.SObjectField> M;
            schema.sObjectType so = GetByName(SelectedObject);
            m= so.getDescribe().fields.getMap() ;
            
           Schema.SObjectField field = m.get(fiel);
           //Schema.DisplayType FldType = field.getDescribe().getType();
           //string t = Batch_Helpers.schemaDisplayTypeCompatibility(field);
           string t = Batch_Helpers.schemaDisplayTypeCompatibility(field);
           if(t=='DateTime'){
               obj.put(fiel, DateTime.valueOf(value));  
           }
           else if(t=='Date'){
               obj.put(fiel, Date.valueOf(value));  
           }
            else if(t=='Integer'){
               obj.put(fiel, Integer.valueOf(value));  
           }
           else if(t=='Boolean'){
               obj.put(fiel, Boolean.valueOf(value));  
           } else {
               try {
                   obj.put(fiel, String.valueOf(value)); 
               } catch(Exception e){
                   //Batch_Helpers.LogError('(Else) Valor: ' + value + ', fiel: ' + fiel);
                  // Batch_Helpers.LogError(e);
               }
           }
      //obj.put(fiel, value); 
       } catch(exception e){
           //Batch_Helpers.LogError('Valor: ' + value + ', fiel: ' + fiel);
           //Batch_Helpers.LogError(e);
       }
    } 
   private object GetFieldValue(String name, sObject data){        
 
       if(!string.isNotEmpty(name)) {
            return 'null';
        }
       
       try {
           return data.get(name);
       }
       catch (exception e) {
           //system.debug(e.getMessage());
           Batch_Helpers.LogError(e);
           return '';
       }  
    }
   private string GetId(sObject data ){
        return (String)data.get('id'); 
    } 
   private List<sObject>  GetObjectBatch(List<ServiceOutput__c> scope){
    
       SET<string>Ids = new SET<string>();
       
       for(ServiceOutput__c s:scope)  {
          Ids.add(s.IA_Reference1__c); 
       }
       string soql =QueryBuilderForList();
       if( bypass){
          return  new List<sObject>();
       }
       
       List<sObject> data = Database.query(soql);      
       
       return data;
    }
   private sObject getObjectFromList( List<sObject> data, string id){
        for(sObject o:data){
            string objid =(String)o.get('id'); 
            
            if(objid ==id){
                return o;
            }            
        }
       return null;
    }
   private void UpdateTotalUpdated(integer c){
     Service_Maste_Transaction__c  tran = [SELECT Id,Name, TransactionId__c,Total_Addresses__c FROM Service_Maste_Transaction__c WHERE TransactionId__c =:TransactionId LIMIT 1];
       
       integer CurrentTotal = integer.valueOf(tran.Total_Addresses__c);
        tran.Total_Addresses__c = CurrentTotal + c ;
         update tran;
    } 
    
   //public
   public void TransactionCleanUp(){
        // ServiceOutput__c
          DeleteServiceOutputBatchable delbatch2 = new DeleteServiceOutputBatchable();  
          delbatch2.Filters  ='WHERE TransactionId__c =  \'' +TransactionId +'\'' ; 
           if(!bypass){
                 Database.executeBatch(delbatch2,2000);
           }         
        // Service_Maste_Transaction_Batches__c
        List<Service_Maste_Transaction_Batches__c> t =[SELECT ID,NAME,batchIdentifier__c FROM Service_Maste_Transaction_Batches__c 	WHERE TransactionId__c =:TransactionId ];
        List<string> batchTodelete = new List<string> ();
        
        for(Service_Maste_Transaction_Batches__c b: t){
            batchTodelete.add(b.batchIdentifier__c);
        }
        if(!bypass){
              DELETE t;
           }
      
        // Service_Master__c
         List<Service_Master__c> r =[SELECT ID,NAME  FROM Service_Master__c  WHERE BatchID__c IN :batchTodelete];
         DELETE r;
        // Service_Maste_Transaction__c
         List<Service_Maste_Transaction__c> d =[SELECT ID,NAME  FROM Service_Maste_Transaction__c  WHERE TransactionId__c =:TransactionId];
        if(!bypass){
              DELETE d;
           }        
    }
   public Database.QueryLocator start(Database.BatchableContext BC){    
      
        return Database.getQueryLocator(Soql); 
    }    
   public void execute(Database.BatchableContext BC,List<ServiceOutput__c> scope){
     try{
         
         List<sObject> toReturn =  GetObjectBatch(scope);
         
         for(ServiceOutput__c o:scope){
           
           sObject item =null; 
           //tring soql = QueryBuilder(o.IA_Reference1__c); //Id
           String mappingId = o.IA_Reference2__c ; //map                         
           //sObject  sobj = Database.query(soql);
            sObject  sobj = getObjectFromList(toReturn, o.IA_Reference1__c);
        
            for(Batch_NewSession_CL.MappingItem mapping:SourceMapping){
             if(mapping.Id == mappingId){
               integer addressIndex = 0;
              for(Batch_NewSession_CL.MappingField mp:mapping.MappingsList)   {           
                  try{
                       object tmpValue;
                      if(mp.MapField != 'not_mapped'){
                         if(string.isEmpty(mp.type) || mp.type == 'INPUT'){
                          if(mp.MapField == 'Country'){
                         tmpValue = GetFieldValue('FR_Country__c',o );  
                      }
                          else if(mp.MapField == 'Zipcode'){
                          tmpValue = GetFieldValue('FR_Zipcode__c',o );  
                        }
                          else if(mp.MapField == 'State'){
                         tmpValue = GetFieldValue('FR_State__c',o );  
                      }
                          else if(mp.MapField == 'City'){
                         tmpValue = GetFieldValue('FR_City__c',o );  
                      }   
                          else if(mp.MapField == 'Address'){
                             addressIndex ++;                          
                             tmpValue = GetFieldValue('FR_Address' + addressIndex + '__c',o );
                            } 
                          else if(mp.MapField == 'lvl1_verification_flag'){                         
                           tmpValue = GetFieldValue( 'verificationFlag__c',o );
                              } 
                          else if(mp.MapField == 'lvl2_response_flag'){                                          
                           tmpValue = GetFieldValue( 'ResponseFlag__c',o );
                             } 
                          else if(mp.MapField == 'lvl3_change_flag'){                                                
                            tmpValue = GetFieldValue( 'AddressChangeFlags__c',o );
                            } 
                          else if(mp.MapField == 'verification_date'){
                              DateTime dT = System.now();
                              Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());                              
                              tmpValue =  myDate;
                          } 
                          else{
                           tmpValue = GetFieldValue(''+mp.MapField+'__c' ,o);                       
                          }
                      
                          UpdateFieldByName(sobj,mp.Field,tmpValue);  
                         }
                          if(mp.type == 'OUTPUT'){
                           tmpValue = GetFieldValue(''+mp.MapField+'__c' ,o);                        
                            UpdateFieldByName(sobj,mp.Field,tmpValue);   
                         }  
                      }                  
                  }
                  catch(exception e){
                      
                      //ignore
                      //Batch_Helpers.LogError(e);
                  }                
                }                
              }   
            }
            //toReturn.add(sobj);
          }   
         if(!bypass){
              update   toReturn; 
             UpdateTotalUpdated(toReturn.size());
           }
         
        }
        catch(exception e){
           ExceptionHelper.LogError(e,'execute');
        }      
      } 
   public void finish(Database.BatchableContext BC){ 
       try{ 
         TransactionCleanUp();
           }
        catch(exception e){
           ExceptionHelper.LogError(e,'finish');
        }
   }
}