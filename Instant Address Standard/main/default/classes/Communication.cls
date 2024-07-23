public class Communication {
    //private 
    private static  Parameter__c GetParameters(){
      Parameter__c r = [select PARAMETERID__c, USERNAME__c, PASSWORD__c,LICENSEKEY__c,ENVIRONMENT__c,TOKEN_EXPIRATION__c,TOKEN__c,FORMATID__c  from Parameter__c limit 1 ];   
      return r;
    }
    private static void UpdateLicenseData(Parameter__c p){
        try{     
          ValidateLicenseResponse resp =  ValidateLicense(p);     
         
          p.ENVIRONMENT__c = resp.environment;
          p.TOKEN__c = resp.token;
          p.TOKEN_EXPIRATION__c = Batch_Helpers.Encrypt(resp.expiration) ;
        
          update  p; 
        }
        catch(exception  e){
            //ignore
        }   
    }     
    private static boolean IsTokenValid(){
        Parameter__c p = GetParameters();
        return IsTokenValid(1 ,p);
    }
    private static boolean IsTokenValid(integer invocation){
        Parameter__c p = GetParameters();
        return IsTokenValid(invocation ,p);
    }
    private static boolean IsTokenValid(integer invocation, Parameter__c p){        
        
        string tokenDateEncripString = p.TOKEN_EXPIRATION__c;
        if(!string.isNotEmpty(tokenDateEncripString))
            return false;
        
      
        String tokenDateString = Batch_Helpers.Decrypt(tokenDateEncripString);
      
         
        Datetime dt  ;
        
        try{
           dt = datetime.valueOf(tokenDateString); 
             
        }
        catch(exception  e){
            dt = datetime.now();            
        }
         
        
        if(dt <= Batch_Helpers.getUTCDateTime(  12) ){
            
           UpdateLicenseData(p);
            
            if(invocation <= 3){
              return  IsTokenValid(invocation +1,p);
            }
            else{
                return false;
            }                      
        }        
        return true;
    }    
    //public 
    public static ValidateLicenseResponse ValidateLicense(Parameter__c parameters){
        
            Blob headerValue = Blob.valueOf(parameters.USERNAME__c + ':' + parameters.PASSWORD__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            
           String jsonBody = '';       
        
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://auth.initiumsoftware.com/api/authentication/authenticate' );
            req.setMethod('POST');
            req.setCompressed(false);
            req.setHeader('Encoding','utf-8');
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(jsonBody);
            req.setHeader('Content-length',string.valueOf(jsonBody.length()));
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('licensekey', parameters.LICENSEKEY__c); //parameters.LICENSEKEY__c);
            HttpResponse res = new http().send(req);    
            
           ValidateLicenseResponse t =  (ValidateLicenseResponse)System.JSON.deserialize(res.getBody(), ValidateLicenseResponse.class);
           t.statusCode = res.getStatusCode();
        
        return t;
    }
    public static DataSetsResponse DataSets(Parameter__c parameters){
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(parameters.ENVIRONMENT__c+'api/provision/datasets');
            req.setMethod('GET');
            req.setCompressed(false);
            req.setHeader('Encoding','utf-8');
            req.setHeader('token', parameters.TOKEN__c);      
        
        
           HttpResponse res = new http().send(req);
        
        DataSetsResponse toReturn = new DataSetsResponse();
        if(res.getStatusCode() == 200){
            toReturn = new DataSetsResponse();
            List<DataSetsItem> t =  (List<DataSetsItem>)System.JSON.deserialize(res.getBody(), List<DataSetsItem>.class);
           toReturn.statusCode = res.getStatusCode();
            toReturn.data   = t;
        }
        else{
          toReturn =  (DataSetsResponse)System.JSON.deserialize(res.getBody(), DataSetsResponse.class);
        }
        
        return toReturn;
    }  
    public static StartBatchSessionResponse StartBatchSession(String name, String description,String country, string jsonBody){        
       
        StartBatchSessionResponse toReturn = new StartBatchSessionResponse();
         
        if(!IsTokenValid()){
            system.debug('invalid license');
            toReturn.message ='invalid license';
            toReturn.code = 401;
            return toReturn;
        }
        Parameter__c p = GetParameters();
       
        HttpRequest req = new HttpRequest();
        //  req.setEndpoint(parameters.ENVIRONMENT__c+'api/provision/datasets');
        req.setEndpoint(P.ENVIRONMENT__c+ 'api/validation/StartBatchSession?name='+name+'&description='+description+'&country='+country);
        req.setMethod('POST');
        req.setCompressed(false);
        req.setHeader('Encoding','utf-8');
        req.setHeader('token', p.TOKEN__c);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonBody);
        req.setHeader('Content-length',string.valueOf(jsonBody.length()));
        req.setTimeout(60000);
        HttpResponse res = new http().send(req);
                    
        toReturn =  (StartBatchSessionResponse)System.JSON.deserialize(res.getBody(), StartBatchSessionResponse.class);                  
        toReturn.statusCode = res.getStatusCode();
          
        return toReturn;       
        
    }
    public static GetBatchSessionStateResponse GetBatchSessionState( string batchId ){    
            
       GetBatchSessionStateResponse toReturn = new GetBatchSessionStateResponse();
        if(!IsTokenValid()){
            system.debug('invalid license');
            toReturn.message ='invalid license';
            toReturn.code = 401;
            return toReturn;
        }         
        Parameter__c p = GetParameters();
         
         HttpRequest req = new HttpRequest();
            //req.setEndpoint('https://stagingbatchservices.initiumsoftware.com/api/service/GetBatchSessionState?batchid=' + batchresponse.batchid);
            req.setEndpoint(P.ENVIRONMENT__c+ 'api/validation/GetBatchSessionState?batchid='+batchId );
            req.setMethod('GET');
            req.setCompressed(false);
            req.setHeader('Encoding','utf-8');
            req.setHeader('token', p.TOKEN__c);
            
            HttpResponse res = new http().send(req);
       
        
        toReturn.statusCode = res.getStatusCode();
        if(toReturn.statusCode  == 200){            
            InstantAddressBatchProcessResponse t =  (InstantAddressBatchProcessResponse)System.JSON.deserialize(res.getBody(), InstantAddressBatchProcessResponse.class);           
            toReturn.data   = t;
        }
        else{
          toReturn =  (GetBatchSessionStateResponse)System.JSON.deserialize(res.getBody(), GetBatchSessionStateResponse.class);
        }        
         system.debug(system.now());
        return toReturn;       
        
    }
    public static SessionResultsResponse SessionResults( string batchId,string formatId  ){        
       SessionResultsResponse toReturn = new SessionResultsResponse();
        if(!IsTokenValid()){
            system.debug('invalid license');
            toReturn.message ='invalid license';
            toReturn.code = 401;
            return toReturn;
        }         
        Parameter__c p = GetParameters();
         
        HttpRequest req = new HttpRequest();        
        // req.setEndpoint(P.ENVIRONMENT__c+ 'api/validation/SessionResults?batchid='+batchId+'&formatid='+formatId+'&onlyformatted=false');
        req.setEndpoint(P.ENVIRONMENT__c+ 'api/validation/SessionResults?batchid='+batchId+'&formatid='+p.FORMATID__c+'&onlyformatted=false');
        req.setMethod('GET');
        req.setCompressed(false);
        req.setHeader('Encoding','utf-8');
        req.setHeader('token', p.TOKEN__c);
        req.setTimeout(60000);
        HttpResponse res = new http().send(req);     
   
        toReturn.statusCode = res.getStatusCode();
        if(toReturn.statusCode  == 200){            
                
            string responsebody2 = res.getBody();
 
            List<Response> t =  (List<Response>)System.JSON.deserialize(responsebody2, List<Response>.class);           
            toReturn.data   = t;          
 
        }
        else{
          toReturn =  (SessionResultsResponse)System.JSON.deserialize(res.getBody(), SessionResultsResponse.class);
        }        
        
        return toReturn;       
        
    }
    public static FormatsResponse Formats(){
        
      FormatsResponse toReturn = new FormatsResponse();
        if(!IsTokenValid()){
            system.debug('invalid license');
            toReturn.message ='invalid license';
            toReturn.code = 401;
            return toReturn;
        }         
        Parameter__c p = GetParameters();        
            
         HttpRequest req = new HttpRequest();
         req.setEndpoint(p.ENVIRONMENT__c + 'api/provision/formats');
         req.setMethod('GET');
         req.setCompressed(false);
         req.setHeader('Encoding','utf-8');
         req.setHeader('token', p.TOKEN__c);   
        
        
         HttpResponse res = new http().send(req);
        
        if(res.getStatusCode() == 200){
            toReturn = new FormatsResponse();
            List<FormatsItem> t =  (List<FormatsItem>)System.JSON.deserialize(res.getBody(), List<FormatsItem>.class);
           toReturn.statusCode = res.getStatusCode();
            toReturn.data   = t;
        }
        else{
          toReturn =  (FormatsResponse)System.JSON.deserialize(res.getBody(), FormatsResponse.class);
        }
        
        return toReturn;
    }  
    public static DownloadFlagsResponse DownloadFlags(){
        
      DownloadFlagsResponse toReturn = new DownloadFlagsResponse();
        if(!IsTokenValid()){
            system.debug('invalid license');
            toReturn.message ='invalid license';
            toReturn.code = 401;
            return toReturn;
        }    
        
        Parameter__c p = GetParameters();        
            
         HttpRequest req = new HttpRequest();
         req.setEndpoint(p.ENVIRONMENT__c + 'api/validation/DownloadFlags');
         req.setMethod('GET');
         req.setCompressed(false);
         req.setHeader('Encoding','utf-8');
         req.setHeader('token', p.TOKEN__c);   
        
         HttpResponse res = new http().send(req);
        System.debug(res);
        if(res.getStatusCode() == 200){
           toReturn = new DownloadFlagsResponse();
           List<FlagItem> t =  (List<FlagItem>)System.JSON.deserialize(res.getBody(), List<FlagItem>.class);
           toReturn.statusCode = res.getStatusCode();
           toReturn.data   = t;
        }
        else{
          toReturn =  (DownloadFlagsResponse)System.JSON.deserialize(res.getBody(), DownloadFlagsResponse.class);
        }
        
        return toReturn;
    }  
    ///classes
    public class DownloadFlagsResponse extends BaseResponse {
     public list<FlagItem> data {set;get;}
    } 
    public class FlagItem {
      public string   Name {set;get;}
      public string   Description {set;get; }
      public string   Value {set;get; }
      public string   PartitionKey {set;get; }
      public string   RowKey {set;get; }
      public string   Timestamp {set;get; }
      public string   ETag {set;get; }
    }
    public class FormatsResponse extends BaseResponse {
     public list<FormatsItem> data {set;get;}
    }    
    public class FormatsItem {
    public string   formatid {set;get;}
      public string   name {set;get; }
    }
    public class SessionResultsResponse extends BaseResponse{
       Public  List<Response>  data {set;get;}
      }
    public class GetBatchSessionStateResponse extends BaseResponse{
       Public  InstantAddressBatchProcessResponse  data {set;get;}
      }
    public class StartBatchSessionResponse extends BaseResponse{
        public string batchid { get; set; }
        public string completed { get; set; }
        public List<string> errors { get; set; }
        public string totalreceived { get; set; }
        public string totalsent { get; set; }
        public string message { get; set; }
    }
    public class DataSetsResponse extends BaseResponse{
       Public List<DataSetsItem> data {set;get;}
            }
    public class DataSetsItem{
        Public string  expiration{set;get;}
        Public string name{set;get;}
        Public string iso_2{set;get;}
        Public string iso_3{set;get;}
    }    
    public class ValidateLicenseResponse extends BaseResponse{
         Public string token{set;get;}
         Public string  expiration{set;get;}
         Public string environment{set;get;}
    }   
    ///classes Abstract
    abstract class BaseResponse extends  ErrorMessage {
        Public integer statusCode{set;get;}
        public Boolean IsValid{get{ return  statusCode ==200;}}
    }    
    abstract class ErrorMessage{
        Public string message{set;get;}
        Public Integer code {set;get;}
    }
}