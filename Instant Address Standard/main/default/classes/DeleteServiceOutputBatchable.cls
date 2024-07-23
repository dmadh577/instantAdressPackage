public class DeleteServiceOutputBatchable implements Database.Batchable<sObject>, Database.Stateful {
    
    public boolean BatchComplete {set;get;}
    public string Soql{set;get;}  
    public string Filters{set;get;}   
    private final string BasqSoql ='SELECT Id,OwnerId,IsDeleted,Name,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,verificationFlag__c,ResponseFlag__c,AddressChangeFlags__c,ErrorData__c,FR_Address1__c,FR_Address2__c,FR_Address3__c,FR_Address4__c,FR_Address5__c,FR_City__c,FR_State__c,FR_Zipcode__c,IA_Address1__c,IA_Address2__c,IA_Address3__c,IA_Address4__c,IA_Address5__c,IA_BatchID__c,IA_City__c,IA_Country__c,IA_Reference1__c,IA_Reference2__c,IA_Reference3__c,IA_Reference4__c,IA_Reference5__c,IA_State__c,IA_Zip4__c,IA_Zipcode__c,HouseNumber__c,HouseNumberHigh__c,HouseNumberLow__c,HouseNumberParity__c,SecondaryUnit__c,SecondaryUnitAbbrev__c,SecondaryUnitHigh__c,SecondaryUnitLow__c,SecondaryUnitName__c,SecondaryUnitParity__c,Building__c,BaseAlterNameCodeFlag__c,CarrierRouteFlag__c,CarrierRouteID__c,CityDeliveryFlag__c,CityStateKey__c,CityName__c,CongressionalDistrictID__c,CountryID__c,CountryName__c,CountyID__c,CountyName__c,FinancialNumber__c,GovernmentFlag__c,LACSFlag__c,Latitude__c,Longitude__c,MunicipalityKey__c,POBox__c,POBoxNumber__c,DataPostRetentionElement__c,DataRetentionElement1__c,DataRetentionElement2__c,PreferredCityName__c,PrivateMailbox__c,PrivateMailboxNumber__c,RecordKey__c,RecordType__c,StateAbbrev__c,StateID__c,StateName__c,Street__c,StreetPostfixAbbrev__c,StreetPostFixName__c,StreetPreDirectionalAbbrev__c,StreetPreDirectionalName__c,StreetPrefixName__c,StreetPrefixAbbrev__c,StreetSuffixAbbrev__c,StreetSuffixName__c,UrbanizationKey__c,Urbanization__c,Zip4High__c,Zip4Low__c,Zip4__c,Zipcode__c,AugmentedBuilding__c,CMRA__c,DPV__c,DPC__c,DPCD__c,DPVF__c,eLOTCode__c,eLOTNumber__c,FIPS__c,RDI__c,Timestamp__c,VerificationFlagDescription__c,ResponseFlagDescription__c,AddressChangeFlagsDescription__c,FR_Country__c FROM ServiceOutput__c ';
    private integer  total{set;get;} 
     // public impletemtation

    public Database.QueryLocator start(Database.BatchableContext BC){    
       try{
             total = 0;
            if(string.isNotEmpty(Soql)){
               return Database.getQueryLocator(Soql);   
            }
            if(string.isNotEmpty(Filters)){
                return Database.getQueryLocator( BasqSoql +' '+Filters) ;    
            }
        }
        catch(exception e){ ExceptionHelper.LogError(e,'start');}
       
        return Database.getQueryLocator(BasqSoql); 
    } 
    public void execute(Database.BatchableContext BC,List<ServiceOutput__c> scope){
        try{ 
           total +=scope.size();
           
            if(!Test.isRunningTest()){
                 delete scope;
            }            
        }
        catch(exception e){
            ExceptionHelper.LogError(e,'execute');
        }      
      } 
    public void finish(Database.BatchableContext BC){
        BatchComplete = true;         
    } 
}