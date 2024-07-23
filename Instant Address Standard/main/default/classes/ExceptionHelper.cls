public class ExceptionHelper {
    //Private 
   
    private static void LogLocalException(ExceptionLog e){
        Error_Log__c ex = new Error_Log__c();
        ex.FuncitonName__c = e.functionName ;         
        ex.Message__c =e.Message;
        ex.SourceModule__c =e.SourceModule;
        ex.StackTraceString__c =e.StackTrace;
        ex.UserId__c =e.UserId;
      
        insert ex;
    }
    private static void  LogErrorInPortal(ExceptionLog e){
        //TBD
        
    }
    private static void  LogErrorInPortalDirect(ExceptionLog e){
        //TBD
        try{
            
        }
        catch( Exception ex ){
            NotifyByEmail(e);
        }
    }
    private static void NotifyByEmail(ExceptionLog e){
        
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'instantaddressoperations@initiumsoftware.com'});
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('Salesforce Support');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setHtmlBody('<h3>Instant Address Salesforce Error</h3><p><b>Client: </b>'+ UserInfo.getOrganizationName() +' ('+ UserInfo.getOrganizationId() +')</p><p><b>User: </b>'+ UserInfo.getName() +'</p><p><b>User email: </b>'+ UserInfo.getUserEmail() +'</p><p><b>Error:</b></p><p>'+ e.Message +'</p>');
        Messaging.sendEmail(new Messaging.Email[] { mail });
    }
    
    
    //Public 
    
    public static void LogError(Exception ex,string FunctionName, string ModuleName ){
      
        ExceptionLog  log = new ExceptionLog(ex,FunctionName,ModuleName );   
        try{                     
            LogLocalException(log);
            LogErrorInPortal(log);
        }
        catch(Exception e){
            LogErrorInPortalDirect(log);            
        }
      //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'An error ocurred while processing your request.'));        
    }
    public static void LogError(Exception ex,string FunctionName ){
        
            
        LogError(ex,FunctionName,'IA Salesforce' );        
    }
  
    public class ExceptionLog{
        public  string Id {get;set;}
        public  string ErrorRef {get;set;}
        public  string Message {get;set;}
        public  string StackTrace {get;set;}
        public  string LineNumber {get;set;}
        public string functionName {get;set;}
        public string SoruceApp{get;set;}   
        public string SourceModule{get;set;}
        public string UserId{get;set;}
  
        //Contrutor
        public   ExceptionLog(Exception ex,string Function_Name, string ModuleName){
            This.Id =Batch_Helpers.NewGuid();
            This.Message = ex.getMessage();
            This.StackTrace = ex.getMessage();
            This.LineNumber= '#'+ex.getLineNumber();
            This.functionName =Function_Name ;
            This.SoruceApp ='IA Salesforce';
            This.SourceModule = ModuleName;
            UserId =UserInfo.getUserId();
        }
     
    }
}