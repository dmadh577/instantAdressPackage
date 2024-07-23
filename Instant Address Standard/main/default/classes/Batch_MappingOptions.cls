public   class Batch_MappingOptions {
   //Private
    private static  SelectOption[] getOptions(){
         SelectOption[] tmp= new SelectOption[]{};   
             tmp.add(new SelectOption('not_mapped','Not Mapped'));
        	 tmp.add(new SelectOption('Address','Address'));
        	 tmp.add(new SelectOption('City','City'));
             tmp.add(new SelectOption('State','State'));
             tmp.add(new SelectOption('Zipcode','Zipcode'));
             //tmp.add(new SelectOption('Reference','Reference'));
             tmp.add(new SelectOption('Country','Country'));
             tmp.add(new SelectOption('lvl1_verification_flag','Verification Flag'));
             tmp.add(new SelectOption('lvl2_response_flag','Response Flag'));
        	 tmp.add(new SelectOption('lvl3_change_flag','Address Change Flags'));
         tmp.add(new SelectOption('verification_date','Validation Date'));//
            // tmp.add(new SelectOption('verification_date','date validated on'));//Validation Date
        return tmp;
    } 
    
   private static  SelectOption[] getOutputOptions(){
       SelectOption[] tmp= new SelectOption[]{};   
       tmp.add(new SelectOption('FR_Address1','Address 1'));
       tmp.add(new SelectOption('FR_Address2','Address 2'));
       tmp.add(new SelectOption('FR_Address3','Address 3'));
       tmp.add(new SelectOption('FR_Address4','Address 4'));
       tmp.add(new SelectOption('FR_Address5','Address 5'));
       tmp.add(new SelectOption('FR_City','City'));
       tmp.add(new SelectOption('FR_State','State'));
       tmp.add(new SelectOption('FR_Zipcode','Zipcode'));
       tmp.add(new SelectOption('FR_Country','Country'));
       tmp.add(new SelectOption('Building','Building'));
       tmp.add(new SelectOption('BaseAlterNameCodeFlag','Base Alter Name Code Flag'));
       tmp.add(new SelectOption('CarrierRouteFlag','Carrier Route Flag'));
       tmp.add(new SelectOption('CarrierRouteID','Carrier Route ID'));
       tmp.add(new SelectOption('CityDeliveryFlag','City Delivery Flag'));
       tmp.add(new SelectOption('CityStateKey','City State Key'));
       tmp.add(new SelectOption('CityName','City Name'));
       tmp.add(new SelectOption('CongressionalDistrictID','Congressional District ID'));
       tmp.add(new SelectOption('CountryID','Country ID'));
       tmp.add(new SelectOption('CountryName','Country Name'));
       tmp.add(new SelectOption('CountyID','County ID'));
       tmp.add(new SelectOption('CountyName','County Name'));
       tmp.add(new SelectOption('FinancialNumber','Financial Number'));
       tmp.add(new SelectOption('GovernmentFlag','Government Flag'));
       tmp.add(new SelectOption('LACSFlag','LACS Flag'));
       tmp.add(new SelectOption('Latitude','Latitude'));
       tmp.add(new SelectOption('Longitude','Longitude'));
       tmp.add(new SelectOption('MunicipalityKey','Municipality Key'));
       tmp.add(new SelectOption('PreferredCityName','Preferred City Name'));
       tmp.add(new SelectOption('RecordKey','Record Key'));
       tmp.add(new SelectOption('RecordType','Record Type'));
       tmp.add(new SelectOption('StateAbbrev','State Abbrev'));
       tmp.add(new SelectOption('StateID','State ID'));
       tmp.add(new SelectOption('StateName','State Name'));
       tmp.add(new SelectOption('Street','Street'));
       tmp.add(new SelectOption('UrbanizationKey','UrbanizationKey'));
       tmp.add(new SelectOption('Urbanization','Urbanization'));
       tmp.add(new SelectOption('CMRA','CMRA'));
       tmp.add(new SelectOption('DPV','DPV'));
       tmp.add(new SelectOption('DPC','DPC'));
       tmp.add(new SelectOption('DPCD','DPCD'));
       tmp.add(new SelectOption('DPVF','DPVF'));
       tmp.add(new SelectOption('eLOTCode','eLOTCode'));
       tmp.add(new SelectOption('eLOTNumber','eLOTNumber'));
       tmp.add(new SelectOption('FIPS','FIPS'));
       tmp.add(new SelectOption('RDI','RDI'));
       tmp.add(new SelectOption('csa','Combined Statistical Area Code'));
       tmp.add(new SelectOption('cbsa','Core Based Statistical Area Code'));
       tmp.add(new SelectOption('pmsa','Primary Metropolitan Statistical Areas'));
       tmp.add(new SelectOption('mesa','Metropolitan Statistical Area'));
       tmp.add(new SelectOption('misa','Micropolitan Statitstical Area'));
       return Batch_Helpers.SortSelectOptionList(tmp);
    } 
   //public 
    public static String Getverification_date {
        get{
            return 'verification_date';
        }
    }
    public static String Getlvl1 {
        get{
            return 'lvl1_verification_flag';
        }
    }
    public static String Getlvl2 {
        get{
            return 'lvl2_response_flag';
        }
    }
    public static String Getlvl3 {
        get{
            return 'lvl3_change_flag';
        }
    }
    public static SelectOption[] ddlList {
        public get {     
          
             return getOptions();   
        }  
                              
     }
    public static SelectOption[] ddlListOutput {
        public get {     
          
             return getOutputOptions();   
        }  
                              
     }
}