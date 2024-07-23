public class Batch_NewSession_CL {
   //Properties
     static final Integer BatchSize = 500;
   //pagination section
    //public List<SelectOption> paginationSizeOptions{get;set;}
    public List<SelectOption> OperatorsOptions{get{
        return Batch_Helpers.Operators;
    }}
    public List<SelectOption>  StaticFilterOptions{get{
        return Batch_Helpers.BatchStaticDataFilter;
    }}
    public List<SelectOption>  BooleanOperators{get{
        return Batch_Helpers.BooleanOperators;
    }} 
    
    Public Boolean ShowCustomFilter{get; set;}
    Public String SelectedCustomFilter{get; set;}
    public MappingSource source  {get; set;}
    //pag
    Public Integer page{get;set;} 
    Public Integer pageMax{get;set;} 
    Public Integer size{get;set;}     
     
    public Boolean hasPaginationPreviews{get{return page >= 1 ;}}
    public Boolean hasPaginationNext{get{return page < pageMax && pageMax > 1 ;}}    
    Public Integer noOfRecords{get; set;} 
    Public Decimal batchCount{get; set;} 
    
    Public Decimal batchCountProcessed{get; set;}    
  
    Public String  soqlQuery {get;set;} 
    Public String  GridLeyend {get{
        string text;
        if(noOfRecords >0){
            if(((page+1) * size)>noOfRecords){
                text = ((((page+1) * size)+1) - size) + ' - ' +  noOfRecords  +' of '+ noOfRecords;
            }
            else{
                 text = ((((page+1) * size)+1) - size) + ' - ' +  ((page+1) * size)  +' of ' + noOfRecords ;
            }    
             if(noOfRecords>2000)
             text =text + '      '+ 'The tool only allow  to navigate up to 2000 objects';
        }
        else{
            text ='   no address records';
        }
         
        return text ;
    }} 
    //  end pagination   
    //data grid  section
    Public Boolean showColumn2{get; set;}
    Public Boolean showColumn3{get; set;}
    Public Boolean showColumn4{get; set;}
    Public Boolean showColumn5{get; set;}
    //end data grid
    //Buttom Params
    public String MappingItemId { public get; public set;  } 
    public String MappingItemRowId {   get;   set;  }
    
    //Custom Filters
    public CustomFilters Filter1{set;get;}
    public CustomFilters Filter2{set;get;}
    public CustomFilters Filter3{set;get;}
    
    public string filtersString{get;set;}
    public Batch_SentDataBatchable baSendata{set;get;}     
        
    //Contructor
    public Batch_NewSession_CL() {    
    try{    
         string successmessage = ApexPages.currentPage().getParameters().get('finishmessage');
         if(successmessage == 'true'){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your batch finished successfully.'));
         }
         source = new MappingSource();
         LoadContries();
         LoadPrefer();    
         UpdateMappingIndex(); 
         source.showBlock1 = true;
        
        Filter1 = new CustomFilters();
 
       }
      catch(exception e){ ExceptionHelper.LogError(e,'Batch_NewSession_CL');}
    }
   
    //Event 
    //
    /*Tmp function */
  
    public pagereference tempVoid(){ 
       
        
       /*List<Error_Log__c>  errolist=[SELECT Id,Name FROM Error_Log__c Limit 1];
        delete errolist; */
     
          return  null;
    }
    
    public void OnChangeFieldFilter1(){
      try
        {
         String t=  GetMappingFieldOption(Filter1.Field);
            Filter1.ShowFilterDatePicker = false;
            Filter1.ShowFilterDropdown = true;
            if(t=='lvl1_verification_flag') {
                Filter1.DropdownValues = GetFlags(Batch_Helpers.FlagLevel1);
            }
            else if(t=='lvl2_response_flag'){
                 Filter1.DropdownValues = GetFlags(Batch_Helpers.FlagLevel2);
            }
            else if(t=='lvl3_change_flag'){
                 Filter1.DropdownValues =  GetFlags(Batch_Helpers.FlagLevel3);
            }
            else{
                if(Filter1.ShowFilterDropdown == true)
                   Filter1.Value = '';                
                Filter1.ShowFilterDropdown = false;
                if(GetFieldType(Filter1.Field) == 'Date' ||  GetFieldType(Filter1.Field) == 'DateTime' ){
                     Filter1.ShowFilterDatePicker = true;
                }
            }
        }
        catch(exception e){ ExceptionHelper.LogError(e,'OnChangeFieldFilter1');} 
    }  
    public void OnChangeFieldFilter2(){
      try
        {
         String t=  GetMappingFieldOption(Filter2.Field);
              
            Filter2.ShowFilterDropdown = true;
            if(t=='lvl1_verification_flag') {
                Filter2.DropdownValues = GetFlags(Batch_Helpers.FlagLevel1);
            }
            else if(t=='lvl2_response_flag'){
                 Filter2.DropdownValues = GetFlags(Batch_Helpers.FlagLevel2);
            }
            else if(t=='lvl3_change_flag'){
                 Filter2.DropdownValues =  GetFlags(Batch_Helpers.FlagLevel3);
            }
            else{
            if(Filter2.ShowFilterDropdown == true)
                   Filter2.Value = '';                
                Filter2.ShowFilterDropdown = false;
                if(GetFieldType(Filter2.Field) == 'Date' ||  GetFieldType(Filter2.Field) == 'DateTime' ){
                     Filter2.ShowFilterDatePicker = true;
                }
            }
        }
        catch(exception e){ ExceptionHelper.LogError(e,'OnChangeFieldFilter2');} 
    }
    public void OnChangeFieldFilter3(){
      try
        {
         String t=  GetMappingFieldOption(Filter3.Field);
              
            Filter3.ShowFilterDropdown = true;
            if(t=='lvl1_verification_flag') {
                Filter3.DropdownValues = GetFlags(Batch_Helpers.FlagLevel1);
            }
            else if(t=='lvl2_response_flag'){
                 Filter3.DropdownValues = GetFlags(Batch_Helpers.FlagLevel2);
            }
            else if(t=='lvl3_change_flag'){
                 Filter3.DropdownValues =  GetFlags(Batch_Helpers.FlagLevel3);
            }
            else{
              if(Filter3.ShowFilterDropdown == true)
                   Filter3.Value = '';                
                Filter3.ShowFilterDropdown = false;
                if(GetFieldType(Filter3.Field) == 'Date' ||  GetFieldType(Filter3.Field) == 'DateTime' ){
                     Filter3.ShowFilterDatePicker = true;
                }
            }
        }
        catch(exception e){ ExceptionHelper.LogError(e,'OnSelectDataSet');} 
    }    
    public void OnSelectDataSet(){
      try
        {
         source.PostalDataOptions = new SelectOption[]{};  
           List<PostalData__c> data = [select Id__c,Iso_3__c, Name from PostalData__c ];
           for(PostalData__c c : data)
           {
               if( string.isBlank(source.selectedPostData)){
                   source.selectedPostData = c.Iso_3__c;
               }
              source.PostalDataOptions.add(new SelectOption(c.Iso_3__c ,c.Name )); 
           }
    
        }
        catch(exception e){ ExceptionHelper.LogError(e,'OnSelectDataSet');} 
    }
    public pagereference GetPageStatus(){
    try{
       string userId = UserInfo.getUserId();
    
       integer total = [SELECT count() FROM Service_Maste_Transaction__c WHERE UserId__c =:userId AND Status__c != 'Done' ];        
        if( total> 0){
         Service_Maste_Transaction__c  dt = [SELECT TransactionId__c,Data__c,Status__c FROM Service_Maste_Transaction__c WHERE UserId__c =:userId AND Status__c != 'Done' LIMIT 1]; 
 
          if(dt.Status__c == 'Processed'){
             
               pagereference summaryredirect = new pagereference('/apex/Batch_GetBatches');
               summaryredirect.getParameters().put('TransactionId', dt.TransactionId__c); 
               summaryredirect.setRedirect(true);
               return summaryredirect;
          }
        else if(dt.Status__c == 'Submitting'){
               pagereference summaryredirect = new pagereference('/apex/FinishingBatch');
               summaryredirect.getParameters().put('TransactionId', dt.TransactionId__c ); 
               summaryredirect.setRedirect(true);
                return summaryredirect;   
            }
          else{
               pagereference summaryredirect = new pagereference('/apex/ProcessingBatch');
               summaryredirect.getParameters().put('TransactionId', dt.TransactionId__c); 
               summaryredirect.setRedirect(true);
               return summaryredirect;
          }
        }
     List<AggregateResult> result  = [select count(Id) total from PreferObject__c];      
     integer count = (integer)result[0].get('total');      
       if(count < 1){
          LoadDefaulsObjects();   
           pagereference summaryredirect = new pagereference('/apex/Batch_NewSession_UI');             
           summaryredirect.setRedirect(true);
           return summaryredirect;
       }
    }
      catch(exception e){ ExceptionHelper.LogError(e,'GetPageStatus');}
         return null;    
    }    
    public void PaginationFirst(){
     try{
        page =0;  
        }
        catch(exception e){ ExceptionHelper.LogError(e,'PaginationFirst');}            
    }
    public void PaginationPreview(){
        try{
        page--;  
        }
        catch(exception e){ ExceptionHelper.LogError(e,'PaginationPreview');} 
    }
    public void PaginationNext(){
        try{
        page ++;  
        }
        catch(exception e){ ExceptionHelper.LogError(e,'PaginationNext');}  
    }
    public void PaginationLast(){
        try{
        page = pageMax - 1;  
        }
        catch(exception e){ ExceptionHelper.LogError(e,'PaginationLast');}                  
    }
    //Custom Filters  
    public void ProcessBatch(){
     try{
       
       }
       catch(exception e){ ExceptionHelper.LogError(e,'');}
    } 
    public void AddFilter1(){
      try{
         if(! Filter ()){ return; }       
         
            Filter1.isEditable = false;
            Filter1.hasCommands = false;
        
            Filter2.isVisible = true;
            Filter2.isEditable = true;
            Filter2.hasCommands = true;
        }
        catch(exception e){ ExceptionHelper.LogError(e,'AddFilter1'); }
     } 
    public void AddFilter2(){    
     try{
         if(! Filter ()){return;}  
            Filter2.isEditable = false;
            Filter2.hasCommands = false;
        
            Filter3.isVisible = true;
            Filter3.isEditable = true;
            Filter3.hasCommands = true;
        }
        catch(exception e){ ExceptionHelper.LogError(e,'AddFilter2');} 
    } 
    public void RemoveFilter2(){          
        Filter1.isEditable = true;
        Filter1.hasCommands = true;
        Filter2 = new CustomFilters();
       Filter ();
    }
    public void RemoveFilter3(){
     try{
        Filter2.isEditable = true;
        Filter2.hasCommands = true;
        Filter3 = new CustomFilters(); 
        Filter ();
        }
        catch(exception e){ ExceptionHelper.LogError(e,'RemoveFilter3');} 
    }
    public void FilterData(){
      try{
        Filter();
        }
        catch(exception e){ ExceptionHelper.LogError(e,'FilterData');} 
    }     
    public void OnSelectStaticFilter(){   
      try{
        ShowCustomFilter =  (SelectedCustomFilter == '6');
        ApplyCustomFilter(SelectedCustomFilter);
        }
        catch(exception e){ ExceptionHelper.LogError(e,'OnSelectStaticFilter');}
      }   
    public pagereference Cancel(){ 
    try{
          source = null;
          source = new MappingSource();
          source.showBlock1 = true;
          LoadContries();
          LoadPrefer();    
          UpdateMappingIndex(); 
          filtersString = null;
        }
        catch(exception e){ ExceptionHelper.LogError(e,'Cancel');} 
       return  new pagereference('/apex/Batch_NewSession_UI'); 
    }
    public pagereference Settings(){ 
        
          return new pagereference('/apex/Batch_Settings_UI'); 
    }
    public void OnSelectMapping(){  
     try{
        LoadSelectedMapping();
        }
        catch(exception e){ ExceptionHelper.LogError(e,'OnSelectMapping');}       
    }    
    @TestVisible
    private string GetSelectedObjectLabel(){
        if(source.selectedObject != null && source.selectedObject != ''){
            for(SelectOption so : source.preferObjectsOptions){
                if(so.getValue() == source.selectedObject){
                    return so.getLabel();
                }
            }
        }
        return '';
    }
    public void LoadStep2(){
       try{
             if(source.selectedObject != null && source.selectedObject != ''){
                LoadObjectFields();
                
                source.isObjectLoaded = true;
                source.isSavedMapping = false;
                source.MappingName='';
                source.selectedSavedMapping = '';
                source.selectedObjectName = GetSelectedObjectLabel();
                
                LoadSavedMappings();
                
                LoadNewMapping();
                
                source.showBlock1 = false; 
                source.showBlock2 = true;      
                source.showBlock3 = false;  
                source.showBlock4 = false;
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select an object first'));
            }
        }
        catch(exception e){ ExceptionHelper.LogError(e,'LoadStep2');} 
    }
    public void LoadStep3(){
     try{
          if(source.selectedSavedMapping != null && source.selectedSavedMapping != ''){
            if(source.selectedSavedMapping != 'NEW' || (source.MappingName != null && source.MappingName != '')){
                boolean isMappingComplete = true;
                for(MappingItem Imap: source.mappingList){
                    //String data = GetmappingData(Imap);
                    for(MappingField f : Imap.InputMappingsList){
                        if(f.Field == null || f.Field == ''){
                            isMappingComplete = false;
                            break;
                        }
                    }
                }
                
                if(isMappingComplete){
                    if(source.selectedSavedMapping == 'NEW'){
                        SaveMappings();
                    }
                    page  = 0;
                    size = 20;
                    noOfRecords= 0;
                    
                    source.showBlock1 = false; 
                    source.showBlock2 = false;      
                    source.showBlock3 = true;  
                    source.showBlock4 = false; 
                    
                    SelectedCustomFilter = '';
                    filtersString = null;  
                    
                    Filter1 = new CustomFilters();
                    Filter2 = new CustomFilters();
                    Filter3 = new CustomFilters();
                } else {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please map all the fields'));
                }
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select a batch name'));
            }
        } 
          else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select a batch option first'));
        }
        }
        catch(exception e){ ExceptionHelper.LogError(e,'LoadStep3');} 
    }
    public pagereference LoadStep4(){
     try{
             source.showBlock1 = false; 
             source.showBlock2 = false;      
             source.showBlock3 = false;  
             source.showBlock4 = true; 
                
              return StartBatchProcess();
        }
        catch(exception e){ ExceptionHelper.LogError(e,'LoadStep4');}  
     return null;
    } 
    public void AddSubMapping(){
    try{
          source.mappingList.add(new MappingItem());  
          UpdateMappingIndex();
        }
        catch(exception e){ ExceptionHelper.LogError(e,'AddSubMapping');} 
    }    
    public void AddSubMappingItem(){
    try{
         MappingItem mItem  =GetMappingItem(MappingItemId);
         mItem.MappingsList.add(new MappingField());
        }
        catch(exception e){ ExceptionHelper.LogError(e,'AddSubMappingItem');} 
    }       
    public void RemoveMappingField(){      
     try{
           MappingItem mItem  =GetMappingItem(MappingItemId);
          //MappingsList     
            Integer j = 0;
            while (j < mItem.MappingsList.size())
            {
              if(mItem.MappingsList.get(j).Id == MappingItemRowId)
              {
                mItem.MappingsList.remove(j);
              }else
              {
                j++;
              }
            }  
        }
        catch(exception e){ ExceptionHelper.LogError(e,'RemoveMappingField');} 
    }
    public void RemoveMapping (){   
      try{
           Integer j = 0;
            while (j < source.mappingList.size())
            {
              if(source.mappingList.get(j).Id == MappingItemId)
              {
                source.mappingList.remove(j);
              }else
              {
                j++;
              }
            }
        UpdateMappingIndex();
        }
        catch(exception e){ ExceptionHelper.LogError(e,'RemoveMapping');} 
    }    
    public void SaveMappings(){
     try{
        
         if(!string.isNotEmpty(source.MappingName)){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Missing mapping name!'));
              return;
           }
        
         String idNew  = Batch_Helpers.NewGuid() ;
         
        Mapping__c  mapping = new Mapping__c(Id__c= idNew, Name=source.MappingName, UserId__c= UserInfo.getUserId(),ObjectId__c=source.selectedObject);
        
        if(!Test.isRunningTest()){
              insert mapping;
            }     
      
        List<Mapping_Detail__c> details =  new List<Mapping_Detail__c>();
        for(MappingItem Imap: source.mappingList){
            String idMappingItem  = Batch_Helpers.NewGuid() ;
            Mapping_Detail__c mapDetail = new Mapping_Detail__c();
            
            String data = GetmappingData(Imap);
            
            mapDetail.Id__c = idMappingItem;
            mapDetail.MappingId__c = mapping.Id__c;
            mapDetail.Data__c =data;
            details.add(mapDetail);            
         } 
      if(!Test.isRunningTest()){
       insert details;
            }
          
        
     source.selectedSavedMapping =mapping.Id__c ;
     LoadSavedMappings(); 
     LoadSelectedMapping();
         
        }
        catch(exception e){ ExceptionHelper.LogError(e,'SaveMappings');}
     }    
    //public   
  
     // Initialize setCon and return a list of record  
    public List<DisplayDataItem> getDataSet() {
      try{
         return getDataSet(null);
        }
        catch(exception e){ ExceptionHelper.LogError(e,'getDataSet');}
        return  null ;
    }  
    public List<DisplayDataItem> getDataSet(List<Temp_Mapping_Detail__c> mappings ) {        
    try{
                // set defaults
                showColumn2 = false;
                showColumn3 = false;
                showColumn4 = false;
                showColumn5 = false;
                
                List<sObject> tData =   GetData;      
                noOfRecords =   GetDataCount ; 
                
                //PAGINATION
                Decimal toround ;
                if(noOfRecords > 2000){
                    //toround = (2000 / size);
                    toround = ((decimal)(2000)).divide((decimal)(size), 2);
                }
                else{
                  //toround =  (noOfRecords / size);
                  toround = ((decimal)(noOfRecords)).divide((decimal)(size), 2);
                }
                 pageMax = (integer)(toRound.setScale(0, RoundingMode.CEILING));
         
                 
                List<DisplayDataItem> toReturnData =  new  List<DisplayDataItem>();    
                
                for(sObject tRow : tData){
                    integer mapIndex = 0;
                  for(MappingItem tfield : source.mappingList){
                        DisplayDataItem d = new DisplayDataItem();
                        d.Country  = GetFieldValue('Country',tRow, tfield);
                        d.Zip   = GetFieldValue('Zipcode',tRow, tfield);
                        d.State = GetFieldValue('State',tRow, tfield);
                        d.City  = GetFieldValue('City',tRow, tfield);
                        d.Address1  = GetFieldValue('Address',tRow, tfield,1);
                        d.Address2  = GetFieldValue('Address',tRow, tfield,2);
                        d.Address3  = GetFieldValue('Address',tRow, tfield,3);
                        d.Address4  = GetFieldValue('Address',tRow, tfield,4 );
                        d.Address5  = GetFieldValue('Address',tRow, tfield,5); 
                        
                        d.SourceType = GetFieldLabel('Address', tfield);
                      
                        d.mappingIndex = mapIndex;
                        
                      if(mappings != null){
                        d.MappingId = mappings[mapIndex].Mapping_Id__c; 
                        d.Id = GetId(tRow);
                      }
                       
                      if(String.isNotEmpty(d.Country) || String.isNotEmpty(d.Zip) || String.isNotEmpty(d.State)  || String.isNotEmpty(d.City)|| String.isNotEmpty(d.Address1) ){
                          if(string.isNotEmpty(d.Address2))  
                              showColumn2 = true;
                          if(string.isNotEmpty(d.Address3))  
                              showColumn3 = true; 
                          if(string.isNotEmpty(d.Address4))  
                              showColumn4 = true;
                          if(string.isNotEmpty(d.Address5))  
                              showColumn5 = true;
                         
                         toReturnData.add(d); 
                      }
                       mapIndex ++;
                    }    
                 }   
                
                //noOfBatchRecords =toReturnData.size();
                return toReturnData;
        
           }
        catch(exception e){ ExceptionHelper.LogError(e,'');}
    return null;
        }   
    //Private 
    private string GetFieldType ( string field){
          Map<String, Schema.SObjectField> m;
           schema.sObjectType so = Batch_Helpers.GetsObjectTypeByName(source.selectedObject);
            m= so.getDescribe().fields.getMap() ;            
           Schema.SObjectField sfield = m.get(field);     
           string t = Batch_Helpers.schemaDisplayType(sfield);   
        return t;
    }
    private  List<SelectOption> GetFlags(string id){
        List<SelectOption> ToReturn = new List<SelectOption>();
         List<Flag__c> data = [Select Value__c,Name,Description__c from Flag__c WHERE FlagLevel__c =: id ];
            for(Flag__c a :data){
                string name;
                if( id== Batch_Helpers.FlagLevel3)               
                name = a.Description__c;
                else
                name = a.Name;
                
               ToReturn.add(new SelectOption(a.Value__c , name))  ;  
             }  
        ToReturn.sort();
        return ToReturn;
    }
    private string GetMappingFieldOption(string name){
     string fieldsName =null;
        for (MappingItem mapping: source.mappingList){
           for(MappingField tfield : mapping.MappingsList){               
             if(tfield.Field  == name ){                  
                     fieldsName = tfield.MapField ;                       
                }       
             } 
        }       
        return fieldsName;
            
    }
    private integer  GetDataCount {get{ 
        string sq = QueryBuilder(filtersString );
         
        if(soqlQuery ==sq){
            return noOfRecords;
        }       
        soqlQuery =sq;
        //regen query with new page;       
        integer count;
        try{
           count = database.countQuery( QueryToCount(sq));   
        }
        catch(exception e){
            
            // break over 50000;
            count =2000;
        }
       
        return count;
    }}
    private List<sObject> GetData {get{     
        String soql = QueryBuilder(filtersString );    
        system.debug(soql);
         List<sObject> sobjList = Database.query(soql);        
        return sobjList;
    }}
    private pagereference StartBatchProcess(){      
        
        string tTransactionId = Batch_Helpers.NewGuid();
        baSendata= new Batch_SentDataBatchable();
        baSendata.Soql =   QueryBuilderforBatch(filtersString );    
        baSendata.MappingName = source.MappingName;
        baSendata.SourceMapping = source.mappingList;
        baSendata.TransactionIndex =tTransactionId;
        baSendata.MappingId = source.selectedSavedMapping;
        baSendata.PostData = source.selectedPostData;
        baSendata.SelectedObject = source.selectedObject;
        baSendata.SelectedObjectName = source.selectedObjectName;
        baSendata.UserId= UserInfo.getUserId();
        baSendata.FormatId = source.SelectFormat;       
        //baSendata.Total =   getTableCount(filtersString,source.selectedObjectName);
        decimal c_p = ((decimal)(BatchSize)).divide(source.mappingList.size(), 0);
        integer d_p = (integer)(c_p.setScale(0, RoundingMode.FLOOR));
        
         string sq = QueryBuilder(filtersString );
        
            
            
        if(!Test.isRunningTest()){
            BatchTransactionCounter counter = new BatchTransactionCounter();
            counter.Soql =baSendata.Soql;
            counter.SoqlCount =QueryToCount(sq);
            counter.baSendata = baSendata;
            counter.BatchCount =d_p;
            
           Database.executeBatch(counter,2000);   
        }
       
        
        source.BatchList = null;      
        /*retryDelay = 5000;
        pendingBatch = true;*/
        
        pagereference summaryredirect = new pagereference('/apex/ProcessingBatch');
        summaryredirect.getParameters().put('TransactionId', baSendata.TransactionIndex ); 
        summaryredirect.setRedirect(true);
        return summaryredirect;     
        
    }  
    public boolean TransactionOnProcess{set;get;}    
    public List<Batch_SentDataBatchable.batchItem> BatchOnPreProcess{set;get;} 
    public boolean BatchOnPreProcessContains( string id){               
        for(Batch_SentDataBatchable.batchItem b :BatchOnPreProcess){
            if( b.batchId == id) {
                return true;
            }
        }
        return false;
     }       
    private void CleanTransactionData( ){
        //TODO delete useless data
    } 
    private void GetNextBatch(){
        
    }
    
    ///MBV
    @RemoteAction
    @readOnly
    public static integer getTableCount(string filter, string obj){
        if(string.isNotEmpty(filter)){
            return database.countQuery('SELECT COUNT() FROM '+ obj + ' WHERE ' + filter);
        }
        return database.countQuery('SELECT COUNT() FROM '+ obj);
        
        //String count = 'SELECT COUNT() FROM '+ obj;
        //Integer recCount = 0;
        //if(string.isNotEmpty(filter)){
        //    for(AggregateResult result :['SELECT COUNT(Id) total FROM '+ obj + ' WHERE ' + filter])
    	//		recCount+=(Integer)result.get('total');
        //    
        //    return recCount;
       // }
        //else
       // {
        //    for(AggregateResult result :['SELECT COUNT(Id) total FROM '+ obj])
    	//		recCount+=(Integer)result.get('total');
         //   
         //   return recCount; 
       // }
        
       
		
        
        //return database.countQuery('SELECT COUNT() FROM '+ obj);
    }
    private boolean  Filter (){
        page =0;
        String FillQuery =null;
        // Filter 1        
        if(Filter1.isVisible){
                Filter1 = ValidateQuery(Filter1);
                if(Filter1.isValid){
                    FillQuery = ' ( '+Filter1.Query+' ) ';  
                }
                else{
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Error applying the filter!'));
                 return false;
                } 
        }
        //Filter 2
         if(Filter2.isVisible){
                     
                Filter2 = ValidateQuery(Filter2);
                if(Filter2.isValid && Filter2.isVisible){
                    FillQuery =Filter1.Query;
                    if(Filter2.Operator == 'AND'){
                           FillQuery = ' ( ' + Filter1.Query + '  '+ Filter2.Operator +'  '+  Filter2.Query + ' ) ';
                    }
                    else{
                        FillQuery = ' ( ' + Filter1.Query + ' ) '+ Filter2.Operator +' ( '+  Filter2.Query + ' ) ';
                    }                   
              
                }
                else{
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Error applying the filter!'));
                 return false;
                }             
            
        }
            //Filter 3
         if(Filter3.isVisible){            
            Filter3 = ValidateQuery(Filter3);
             if(Filter3.isValid && Filter3.isVisible){
                 
                 if(Filter2.Operator == Filter3.Operator){
                      FillQuery = ' ( ' + Filter1.Query + '  '+ Filter2.Operator +'  '+  Filter2.Query + Filter3.Operator +'  '+  Filter3.Query + ' ) ';                     
                 }
                 else{                     
                     if(Filter2.Operator == 'AND'){
                        FillQuery = ' ( ' + Filter1.Query + '  '+ Filter2.Operator +'  '+  Filter2.Query + ' )' +Filter3.Operator +' ( '+  Filter3.Query + ' ) ';  
                     }
                     else{
                         FillQuery = ' ( ' + Filter1.Query + ' ) '+ Filter2.Operator +' ( '+  Filter2.Query   +Filter3.Operator +  Filter3.Query + ' ) ';   
                     }
                 } 
             }
               else{
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Error applying the filter!'));
                 return false;
                }
           
        }
                
        filtersString = ' ' + FillQuery  + ' ';
        return true;
    } 
    private CustomFilters ValidateQuery ( CustomFilters f){        
        
          string value;             
          if(string.isEmpty(f.Field)){
               f.isValid = false;
               f.Query = '';
                return f;                
            }
    
            if(string.isNotEmpty(f.Value.trim())){
                f.Value.trim();
            }
            else{
                f.Value=' ';
            }
         
            if(f.Condition == 'like'){
                value = '%'+f.Value.trim().replaceAll(' ', '%') + '%';
            } 
            else{
                value =  f.Value.trim() ; 
            }
        
        
          string fieldtype = GetFieldType(f.Field) ;
        
          system.debug('type:' + fieldtype);
        
          if(GetFieldType(f.Field) == 'String'){
                   try{            
                        f.Query  = ' ' + f.Field  + ' ' + f.Condition + ' ' + '\'' + value + '\' '   ;
                        ExecuteSampleQuery(f.Query);
                        f.isValid = true;            
                        return f; 
                    }
                    catch( exception  e ){             
                        System.debug(e.getMessage()) ;
                    }
                }  
         ///MBV Boolean update
         if(GetFieldType(f.Field) == 'Boolean'){
                   try{            
                        f.Query  = ' ' + f.Field  + ' ' + f.Condition + ' ' +  value + ' '    ;
                        ExecuteSampleQuery(f.Query);
                        f.isValid = true;            
                        return f; 
                    }
                    catch( exception  e ){             
                        System.debug(e.getMessage()) ;
                    }
                } 
         if(GetFieldType(f.Field) == 'Decimal') {
           try{           
             
               Decimal intValue = Decimal.valueof(value);
                    f.Query =  ' ' + f.Field +' ' + f.Condition + ' ' + intValue+ ' '  ;
                    ExecuteSampleQuery(f.Query);
                    f.isValid = true;             
                    return f;  
                }
                catch( exception  e ){                   
                    System.debug(e.getMessage()) ;
                }   
            }
         if( GetFieldType(f.Field) == 'Integer'  ){
           try{           
             
               Integer intValue = Integer.valueof(value);
                    f.Query =  ' ' + f.Field +' ' + f.Condition + ' ' + intValue+ ' '  ;
                    ExecuteSampleQuery(f.Query);
                    f.isValid = true;             
                    return f;  
                }
                catch( exception  e ){                   
                    System.debug(e.getMessage()) ;
                }   
            }
  
         if(  GetFieldType(f.Field) == 'Date'   ){
           try{             
              string[] tmpdate = value.replaceAll('%','').Split('/');
               
                system.debug('date:' + value);
               Date x = Date.valueOf( tmpdate[2] + '-'+tmpdate[0]  + '-'+  tmpdate[1]  );
               DateTime dt = datetime.newInstance(x, Time.newInstance(01,01,01,01));
               String dateTimeFormat =dt.format ('yyyy-MM-dd'); //dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); //dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');//'
                 system.debug('date:' + dateTimeFormat);
                 
                    f.Query =  ' ' + f.Field +' ' + f.Condition + ' ' + dateTimeFormat + ' '  ;
                    ExecuteSampleQuery(f.Query);
                    f.isValid = true;             
                    return f;  
                }
                catch( exception  e ){                    
                    System.debug(e.getMessage()) ;
                }   
            }
         if(  GetFieldType(f.Field) == 'DateTime'  ){
           try{             
              string[] tmpdate = value.replaceAll('%','').Split('/');
              
                Date x = Date.valueOf( tmpdate[2] + '-'+tmpdate[0]  + '-'+  tmpdate[1]  );
               DateTime dt = datetime.newInstance(x, Time.newInstance(01,01,01,01));
               String dateTimeFormat =dt.format ('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); //dt.format(); //dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');//'
                 system.debug('date:' + dateTimeFormat);
                 
                    f.Query =  ' ' + f.Field +' ' + f.Condition + ' ' + dateTimeFormat + ' '  ;
                    ExecuteSampleQuery(f.Query);
                    f.isValid = true;             
                    return f;  
                }
                catch( exception  e ){                    
                    System.debug(e.getMessage()) ;
                }   
            }
        f.isValid = false;
        f.Query = '';
        return f; 
    }
    private void ExecuteSampleQuery(String soql){
        
        integer backupsize = size;
        
        size=1;
       
        string sql = QueryBuilder(filtersString );
        if(string.isNotEmpty(filtersString)){
         sql = sql.replace(filtersString,soql);   
        }        
        
        size=backupsize;
        List<sObject> sobjList = Database.query(sql); 
        
        sql= null;
        sobjList = null;
    }
 	@TestVisible 
    private void ApplyCustomFilter(string f){
        page  = 0;
        if(f=='1'){
          filtersString = null;            
        }
        else if(f=='2'){
          //  created in past 30 days
          Date dtoday = system.today();
          dtoday =dtoday.addDays(-1);           
         //  SOQLQuery = QueryBuilder(' mailingcountry =  \'USA\'  ');  //WHERE mailingcountry =   \'\' USA \'\' 
         filtersString = '(CreatedDate >  LAST_N_DAYS:30  )' ;    
         // 
         // mailingcountry = ''USA''
        }
        else if(f=='3'){
         //Address not verified
         LoadStaticFilter3();
            return;
        }
        else if(f=='4'){
         //  Address not processed in last 90 days  
           LoadStaticFilter4();
        }
        else if(f=='5'){
         //  All unmached address not processed in 90 days
          LoadStaticFilter5();
        }
        else if(f=='6'){
            Filter1 = new CustomFilters();
            Filter1.isVisible = true;
            Filter1.isEditable = true;
            Filter1.hasCommands = true;
            
            Filter2 = new CustomFilters();
            Filter3 = new CustomFilters();
            
        }
        
        Batch_Helpers.LogError(filtersString);
    }
    @TestVisible  
    public  boolean hasSObjectField(String fieldName ){
         schema.sObjectType so = GetByName(source.selectedObject);
         return so.getDescribe().fields.getMap().keySet().contains(fieldName);
       }
    private void LoadStaticFilter3(){
      //Address not verified
      List<string>  fieldsName =  GetMappingField(Batch_MappingOptions.Getlvl1);
        
        if(fieldsName.size()< 0){
          filtersString = null; 
            return;
        }     
        List<string> filter = new List<string>();
        
        for(string c:fieldsName){
            filter.add(' '+ c + ' = ' +'\'\'');
            filter.add( ' ' + c + ' != ' +'\'V\' ');             
        }
        String outputString = String.join(filter, ' OR ');
        
         filtersString =outputString ; 
    }
    private void LoadStaticFilter4(){
      //  Address not processed in last 90 days  
      List<string>  fieldsName =  GetMappingField(Batch_MappingOptions.Getverification_date);
        
        if(fieldsName.size()< 0){
          filtersString = null; 
            return;
        }     
        List<string> filter = new List<string>();
       
        for(string c:fieldsName){   
            //(CreatedDate >  LAST_N_DAYS:30  )'
            filter.add( ' (' + c + ' > ' +' LAST_N_DAYS:90)');             
        }
        
        String outputString = String.join(filter, ' OR ');
        
       filtersString =outputString ; 
    }
    private void LoadStaticFilter5(){
      //  All unmached address not processed in 90 days
      
      List<string>  fieldsName =  GetMappingField(Batch_MappingOptions.Getlvl2);
      List<string>  fieldsDateName =  GetMappingField(Batch_MappingOptions.Getverification_date);
        
        if(fieldsName.size()< 0 && fieldsDateName.size()< 0 ){
          filtersString = null; 
            return;
        }    
        
        List<string> filter = new List<string>();
       
       integer index = 0;
        for(string c:fieldsName){
             
            filter.add( ' (' + c + ' IN ' +'(\'U\',\'N\')  AND ' + fieldsDateName[index] + ' > ' +' LAST_N_DAYS:90 )');
             index++;
        }
        String outputString = String.join(filter, ' OR ');
        
         filtersString =outputString ; 
    }
    private List<string> GetMappingField(String name ){
      List<string>  fieldsName = new List<string>();
        for (MappingItem mapping: source.mappingList){
           for(MappingField tfield : mapping.MappingsList){               
             if(tfield.MapField == name ){                  
                     fieldsName.add(tfield.Field) ;                       
                }       
             } 
        }       
        return fieldsName;
    }
    private string GetId(sObject data ){
        return (String)data.get('id'); 
    }
    private string GetFieldLabel(String name,  MappingItem mapping ){
        
        String fieldName;
         
         for(MappingField tfield : mapping.MappingsList){               
             if(tfield.MapField == name ){               
                  return tfield.Field.replaceAll('street', '');
             }
         }
        return '';   
      }
    private string GetFieldValue(String name, sObject data, MappingItem mapping ){
        return GetFieldValue(name,data,mapping,1);
    }
    private string GetFieldValue(String name, sObject data, MappingItem mapping, integer index){
        
      String fieldName;
      integer i = 1;
       for(MappingField tfield : mapping.MappingsList){               
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
            	// //MBV add support for Boolean types. Checkbox issue returning value cast not valid for all types
                //return (String)data.get(fieldName) ;
                return string.valueOf(data.get(fieldName));
            }
            Catch (exception e) {   
                  system.debug(e.getMessage());
                  return 'invalid data'  ;
            }  
    }
    public static List<SelectOption> SortSelectOptionList(List<SelectOption> source){
        List<string> sortable = new  LIst<string>();
        for(SelectOption so: source)
        {
            // replace blank with '_!' so we know the final split will have two components
            sortable.Add((string.isblank(so.getLabel())?'_!':so.getLabel()) + '@!@' + (string.isblank(so.getValue())?'_!':so.getValue()));
        }
        // sort the list
        sortable.sort();
        List<SelectOption> targetList = new  List<SelectOption>();
        // split the value/name components and re create the list
        for(string s: sortable)
        {
                targetList.Add(new  SelectOption(s.split('@!@')[1].replace('_!',''), s.split('@!@')[0].replace('_!','')));
         
        }
        return targetList;
    }
    private void LoadObjectFields(){
      source.PreferObjectFieldOptions = new SelectOption[]{};
      schema.sObjectType tmp = GetByName(source.selectedObject);
           Schema.DescribeSObjectResult a_desc = tmp.getDescribe(); 
        //for the Account object, you can replace that with any object you have, standard or custom
        Map<String, Schema.SObjectField> a_fields = a_desc.fields.getMap();
        
        for(String fld : a_fields.keySet()){ 
            //DescribeFieldResult describe = fld.getDescribe();
            // String label = describe.getLabel();
            // String tkey = fld.keySet();
            string flabel = a_fields.get(fld).getDescribe().getLabel();
            Schema.DisplayType fieldtype = a_fields.get(fld).getDescribe().getType();
            if(fld != 'Id' && fieldtype != Schema.DisplayType.ADDRESS && fieldtype != Schema.DisplayType.SOBJECT
              && fieldtype != Schema.DisplayType.BASE64 
               //MBV add support for Boolean types
              //&& fieldtype != Schema.DisplayType.BOOLEAN
              && fieldtype != Schema.DisplayType.CURRENCY && fieldtype != Schema.DisplayType.DATACATEGORYGROUPREFERENCE
              && fieldtype != Schema.DisplayType.MULTIPICKLIST && fieldtype != Schema.DisplayType.REFERENCE
              && fieldtype != Schema.DisplayType.URL && fieldtype != Schema.DisplayType.PHONE
              /*&& fieldtype != Schema.DisplayType.PICKLIST*/){
              source.PreferObjectFieldOptions.add(new SelectOption(fld , flabel));   
            }            
        }
        
        source.PreferObjectFieldOptions = SortSelectOptionList(source.PreferObjectFieldOptions);
        source.PreferObjectFieldOptions.add(0, new SelectOption('' ,'select...'));
    }
    private string QueryToCount(string query){
      
        string newQuery =  query.replace(' ORDER BY ID  LIMIT ' + size + ' OFFSET ' + (size  * (page)), '');     
        string cols = newQuery.substring(0,newQuery.indexOf('FROM'));
        newQuery =  (newQuery.replace(cols , ' SELECT COUNT() '))   ;
        return newQuery + 'LIMIT 2000';
    }
    private string QueryToCountNoLimit(string query){
      
        string newQuery =  query.replace(' ORDER BY ID  LIMIT ' + size + ' OFFSET ' + (size  * (page)), '');     
        string cols = newQuery.substring(0,newQuery.indexOf('FROM'));
        newQuery =  (newQuery.replace(cols , ' SELECT COUNT() '))   ;
        return newQuery;
    } 
    private string QueryBuilder( ){
        filtersString = null;
        return QueryBuilder(null);
    }
    private string QueryBuilder(string filters){
      string base ='SELECT {0} FROM {1}'; 
        
      // filtersString = filters;
        
     set<string> columnsListSet = new set<String>();
  
         for(MappingItem mapping : source.mappingList){
           for(MappingField tfield : mapping.MappingsList){               
                  if(!columnsListSet.contains(tfield.Field)){
                      columnsListSet.add(tfield.Field);
                  }         
              }          
            }  
             
        schema.sObjectType tmp = GetByName(source.selectedObject);
        String oName = tmp.getDescribe().getName();
        
       List<string> columnsList  = new List<String>(columnsListSet);  
        
       String columnsString = String.join(columnsList, ','); 
        List<String> fillers = new String[]{columnsString,oName};     
       String formatted = String.format(base, fillers); 
             
        if(string.isNotEmpty(filters) ){          
           formatted = formatted+' WHERE ' + filters;
        }        
         formatted = formatted+' ORDER BY ID  LIMIT ' + size + ' OFFSET ' + (size * (page));
       
       return formatted;
    }   
    private string QueryBuilderforBatch(string filters){
      string base ='SELECT {0} FROM {1}';       
      // filtersString = filters;
        
     set<string> columnsListSet = new set<String>();
  
         for(MappingItem mapping : source.mappingList){
           for(MappingField tfield : mapping.MappingsList){               
                  if(!columnsListSet.contains(tfield.Field)){
                      columnsListSet.add(tfield.Field);
                  }         
              }          
            }  
             
        schema.sObjectType tmp = GetByName(source.selectedObject);
        String oName = tmp.getDescribe().getName();
        
       List<string> columnsList  = new List<String>(columnsListSet);  
        
       String columnsString = String.join(columnsList, ','); 
        List<String> fillers = new String[]{columnsString,oName};     
       String formatted = String.format(base, fillers); 
             
        if(string.isNotEmpty(filters) ){          
           formatted = formatted+' WHERE ' + filters;
        }        
         formatted = formatted+' ORDER BY ID ';
        system.debug('batch');
        system.debug(formatted);
       return formatted;
    }   
    private void LoadNewMapping(){
     source.mappingList.Clear();
     source.mappingList = new List<MappingItem>(); 
     source.mappingList.add(new MappingItem());
    }
    private void LoadSelectedMapping(){    
        if(source.selectedSavedMapping != null && source.selectedSavedMapping != ''){
           source.mappingList.Clear();
            
            if(source.selectedSavedMapping == 'New'){
             source.isObjectLoaded = true;
             source.isSavedMapping = false;
             source.MappingName='';
             source.selectedSavedMapping = 'New';       
            LoadNewMapping();
                      
            }
            else{
                 string mId=  source.selectedSavedMapping ;
                  Mapping__c tmap = [select Id__c, ObjectId__c, Name from Mapping__c  where Id__c = :mId  LIMIT 1] ;           
                  source.MappingName = tmap.Name;
                  List<Mapping_Detail__c> tmapDetList = [select Id__c,MappingId__c, Data__c from Mapping_Detail__c  where MappingId__c = :tmap.Id__c] ;
                
                  for(Mapping_Detail__c Iitem : tmapDetList){
                      
                                       
                    source.mappingList.Add(GetMappingFromData(Iitem.Data__c,Iitem.Id__c ));
                    
                  }           
                  
                 source.isSavedMapping = true;
              // source.objectLoaded = false;        
            
            }  
        } else {
            source.isObjectLoaded = true;
            source.isSavedMapping = false;
        }
    } 
    @TestVisible 
    private MappingItem GetMappingFromData(string data, string id ){
    MappingItem toReturn = new MappingItem();
    toReturn.MappingsList = new List<MappingField>(); 
    toReturn.Id = id;
 
     Mappings tt =   (Mappings)JSON.deserialize(data, Mappings.class);
     
        for(Mapping Iitem : tt.Mappings){
        
            MappingField item = new MappingField(Iitem.Name,  Iitem.Map_Object, Iitem.Index,Iitem.type, source.selectedObject); 
            toReturn.MappingsList.add(item);
            
        }
        
      
        return toReturn;
    }
    private string GetmappingData(MappingItem Imap ){
        Mappings vmap = new  Mappings();
           integer i =0;
            for(MappingField Iitem : Imap.MappingsList){
                
              Mapping item = new Mapping(Iitem.Label, Iitem.Field,Iitem.MapField,i,Iitem.type );
                
              vmap.Mappings.add(item);
                
               i++; 
            }   
             
            return  JSON.serialize(vmap);
    }
    @TestVisible 
    private void LoadSavedMappings(){
      source.SavedMappingsOptions = new SelectOption[]{};
      source.SavedMappingsOptions.add(new SelectOption( '' ,'Select...'));
      source.SavedMappingsOptions.add(new SelectOption( 'New' ,'Create new batch')); 
          
      List<Mapping__c> customObjects = [select Id__c, Name from Mapping__c  where ObjectId__c = :source.selectedObject];
       for(Mapping__c c : customObjects)
       source.SavedMappingsOptions.add(new SelectOption(c.Id__c ,c.Name )); 
    }      
    private void UpdateMappingIndex(){
              Integer j = 0;
            while (j < source.mappingList.size())
            {
                source.mappingList.get(j).Index = j+1;             
                j++;               
            }
    }
    @TestVisible 
    private MappingItem GetMappingItem( string val){
        for(MappingItem obj : source.mappingList){
            if(obj.Id ==val ){
                return obj;
            }   
        }
        return null; 
    }
    private Schema.sObjectType GetByName( string val){
      list<schema.sObjectType> allObjects = Schema.getGlobalDescribe().Values();
        for(schema.sObjectType c : allObjects){
            if( c.getDescribe().getName() == val ){
                return c;
            }
        }
        return null;
      }
    private void LoadContries(){
       source.PostalDataOptions = new SelectOption[]{};  
       List<PostalData__c> data = [select Id__c,Iso_3__c, Name from PostalData__c ];
       for(PostalData__c c : data)
       {
           if( string.isBlank(source.selectedPostData)){
               source.selectedPostData = c.Iso_3__c;
           }
          source.PostalDataOptions.add(new SelectOption(c.Iso_3__c ,c.Name )); 
       }
    
      
    }    
    private void LoadDefaulsObjects(){  
     List<PreferObject__c> Lst   = new List<PreferObject__c>();  
     for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){       
      string id = objTyp.getDescribe().getName();
         if(id =='Account' ||id =='Contact'||id =='Contract'||id =='Lead'){
          PreferObject__c pref = new PreferObject__c(Id__c = Id,Label__c = objTyp.getDescribe().getLabel(),apiName__c = objTyp.getDescribe().getName(),objectType__c ='Standard'  );
             system.debug(pref);  
             Lst.add(pref) ;            
         }        
       }
     insert Lst;
    }
    private void LoadPrefer(){
     source.preferObjectsOptions = new SelectOption[]{};
     SelectOption[] tmp = new SelectOption[]{};
     source.preferObjectsOptions.add(new SelectOption('' , 'Select...')); 
     
     List<PreferObject__c> customObjects = [select Id__c, Label__c from PreferObject__c];
        for(PreferObject__c c : customObjects){
         tmp.add(new SelectOption(c.Id__c ,c.Label__c ));  
        }
     tmp = Batch_Helpers.SortSelectOptionList(tmp);
        
      for(SelectOption i :tmp)  
        source.preferObjectsOptions.add(i);
        
    }       
    public class MappingSource{        
      //Properties
      //page blocks
      public boolean showBlock1 {   get;  set;  }
      public boolean showBlock2 {   get;  set;  }
      public boolean showBlock3 {   get;  set;  }
      public boolean showBlock4 {   get;  set;  }
       // page 
      public boolean isObjectLoaded {   get;  set;  }
      public Boolean isSavedMapping {   get;  set;  }
       // data
      public String MappingName {   get;   set;  } 
        
      public String selectedPostData { public get; public set;  } 
      public String SelectFormat { public get; public set;  } 
      public String selectedObject { public get; public set;  }
      public String selectedObjectName { public get; public set;  }
      public String selectedSavedMapping { public get; public set;  } 

      public SelectOption[] PostalDataOptions {public get; private set;}
      public SelectOption[] preferObjectsOptions {public get; private set;}
      public SelectOption[] SavedMappingsOptions {public get; private set;}   
      public SelectOption[] PreferObjectFieldOptions {get;set; } 
        
      public List<SelectOption> FormatsOptions {get {
            
            if(string.isBlank(selectedPostData)){
                return null;
            }
            else{                 
                FormatsDefault__c defaultFormat = [select BatchFormatId__c from FormatsDefault__c WHERE DatasetId__c = :selectedPostData ];
                if(defaultFormat != null)
                    SelectFormat = defaultFormat.BatchFormatId__c;
                     
                List<SelectOption> toReturn = new List<SelectOption>();                  
                
                integer total = [SELECT count() FROM Format__c];// WHERE  DatasetId__c = :selectedPostData ];
                
                if(total > 0) {
                  List<Format__c> data = [select Id__c,FormatName__c, Name from Format__c ];// WHERE  DatasetId__c = :selectedPostData ORDER BY FormatName__c ];  
                    
                  for(Format__c c :data)  
                      toReturn.add(new SelectOption(c.Id__c ,c.FormatName__c));   
                }
               
              return toReturn;
            }
            
            //return null;
        }}
      public SelectOption[] FieldMappingOptions {get;set;}
        
      public List<MappingItem> mappingList {get;set;} 
      public List<BatchToProcess> BatchList {get;set;}
      public string TransactionOverallStatus{get;set;}
      public integer BatchTotalDownloaded{get;set;}
      public integer BatchTotalCount{get;set;}
      public string BatchTotalDownloadedPrecentage{get;set;}
        
      public integer MappingCount {get{ return mappingList.size(); }}
       //Contructor
      public MappingSource() { 
         FieldMappingOptions = Batch_MappingOptions.ddlList;
          
         mappingList = new List<MappingItem>();
         BatchList =new List<BatchToProcess>();
         //mappingList.add(new MappingItem());
          
        }
      //Public Functions
      //public  GetDataColumns 
    }
    public class MappingItem{        
        //Properties
         public String Id {get;set;} 
         public String MappingId {get;set;} 
         public List<MappingField> MappingsList {get;set;} 
         public Integer index {get;set;}
         //ReadOnly
        public List<MappingField> InputMappingsList {get {
            List<MappingField> t = new List<MappingField> ();                       
            for(MappingField i:MappingsList){
                if(i.type == 'INPUT' ){
                    t.add(i);
                }               
            }
           return t;            
        }} 
        public List<MappingField> OutputMappingsList {get {
            List<MappingField> t = new List<MappingField> ();                       
            for(MappingField i:MappingsList){
                if(i.type == 'OUTPUT'){
                    t.add(i);
                }               
            }
           return t;            
        }} 
        //Contructor
        public MappingItem() {
            Id =Batch_Helpers.NewGuid();
            MappingsList = new List<MappingField>();
            MappingsList.Add(new MappingField('Address'));
            MappingsList.Add(new MappingField('City'));
            MappingsList.Add(new MappingField('State'));
            MappingsList.Add(new MappingField('Zipcode'));
            MappingsList.Add(new MappingField('Country'));
            MappingsList.Add(new MappingField('lvl1_verification_flag'));
            MappingsList.Add(new MappingField('lvl2_response_flag'));
            MappingsList.Add(new MappingField('lvl3_change_flag'));
            MappingsList.Add(new MappingField('verification_date'));
        }
        
    }
    public class MappingField{        
        //Properties 
         public String Id {get;set;}
         public String Label { get{
             try{
               schema.sObjectType tmp = this.GetByName(this.SelectedObject);
             Schema.DescribeSObjectResult a_desc = tmp.getDescribe();
             Map<String, Schema.SObjectField> a_fields = a_desc.fields.getMap();
              
            string toReturn = a_fields.get(this.Field).getDescribe().getLabel();
               Integer charLength =toReturn.length();
                 if(charLength  > 25){
                     return toReturn.abbreviate(25) ;
                 }
             return toReturn;
             }
             catch(exception e){
                 return this.Field;
             }        
         }}
         public String Field {get;set;} 
        public String MapFieldLabel {get{
            for(SelectOption a: Batch_MappingOptions.ddlList){
                if(this.MapField ==  a.getValue())
                    return a.getLabel();                
            }
            
            return this.MapField;
        }}         
         public String MapField {get;set;}
         public Integer index {get;set;} 
         public String type {get;set;}
         public String SelectedObject {get;set;}
        public boolean HideRemove{get; set;}
        //Contructor
      
        private Schema.sObjectType GetByName( string val){
          list<schema.sObjectType> allObjects = Schema.getGlobalDescribe().Values();
            for(schema.sObjectType c : allObjects){
                if( c.getDescribe().getName() == val ){
                    return c;
                }
            }
            return null;
          } 
 
       public MappingField(String field,String mapField,Integer inx,String type, string SelectedObject) {
           This.Field = field;
           This.MapField = mapField;
           This.index = inx; 
           Id =Batch_Helpers.NewGuid();
           This.type =  type;
           this.SelectedObject = SelectedObject;
        }
       public MappingField(string pType, string SelectedObject) {
           Id =Batch_Helpers.NewGuid();
           type = pType;
           this.SelectedObject = SelectedObject;
        }
        
        public MappingField(string mapField) {
           Id =Batch_Helpers.NewGuid();
           this.type = 'INPUT';
            this.mapField = mapField;
            this.HideRemove = true;
        }
        
        public MappingField() {
           Id =Batch_Helpers.NewGuid();
           this.type = 'INPUT';
        }
        
    }
    public class DisplayDataItem{
        
       //Properties    
       public String SourceType {get;set;}
       public String MappingId {get;set;}
       public String  Id {get;set;}
        
       public String Address1 {get;set;}
       public String Address2 {get;set;}
       public String Address3 {get;set;}
       public String Address4 {get;set;}
       public String Address5 {get;set;}
       public String City {get;set;}
       public String State {get;set;}
       public String Zip {get;set;}
       public String Country {get;set;}
       
       public String Reference1 {get;set;}
       public String Reference2 {get;set;}
       public String Reference3 {get;set;}
       public String Reference4 {get;set;}
       public String Reference5 {get;set;}
       public String Reference6 {get;set;}
       public String Reference7 {get;set;}
       public String Reference8 {get;set;}
       public String Reference9 {get;set;}
       public String Reference10 {get;set;}
       
       public String Reference11 {get;set;}
       public String Reference12 {get;set;}
       public String Reference13 {get;set;}
       public String Reference14 {get;set;}
       public String Reference15 {get;set;}
       public String Reference16 {get;set;}
       public String Reference17 {get;set;}
       public String Reference18 {get;set;}
       public String Reference19 {get;set;}
       public String Reference20 {get;set;}
        
       public Integer mappingIndex {get;set;}
        //Contructor
        public  DisplayDataItem(){
            
        }
        
    }    
    public class CustomFilters{
       public String Field {   get; set;  }
       public String Condition {   get;  set;  }
       public String Value {   get;  set;  }
        
       public String Operator {   get;  set;  }
       public Boolean isEditable {   get;  set;  }
       public Boolean isVisible {   get;  set;  }
       public Boolean hasCommands {   get;  set;  }
       
       //smart filter
       public boolean ShowFilterDropdown{get; set;}
       public boolean ShowFilterDatePicker{get; set;}
        
        
       public List<SelectOption>  DropdownValues{get; set;}
           
       public String Query {   get;  set;  }
       public Boolean isValid {   get;  set; }
        
        public CustomFilters (){
            isValid = false;
            Query = '';
            hasCommands = false;
            isVisible= false;
            isEditable = false;
            
            Operator =  '';
            Value =  '';
            Condition =  '';
            Field =  '';
        }
    }
    public class BatchToProcess{
        public integer Index{set;get;}
        public string Country{set;get;}
        public string BatchId{set;get;}
        public string Status{set;get;}
    }
 }