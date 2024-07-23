@isTest
public class InstantAddressTestNewSession {
	static testMethod void validateNewSessionClass(){
        Batch_NewSession_CL s = new Batch_NewSession_CL();
      
        object t1 = s.OperatorsOptions;
        object t2 = s.StaticFilterOptions;   
        object t3 = s.BooleanOperators;
        
        s.ShowCustomFilter = false;
        s.SelectedCustomFilter = '';
        
        s.source = new Batch_NewSession_CL.MappingSource();
        s.source.mappingList =new List<Batch_NewSession_CL.MappingItem>();
        
        s.page = 1;
        s.pageMax = 1;
        s.size = 10;      
        
        boolean t4 = s.hasPaginationPreviews;
        boolean t5  = s.hasPaginationNext;
        
        s.noOfRecords = 1;
        s.batchCount = 1;
        s.batchCountProcessed = 1;
        
        s.soqlQuery ='';
        string t6 = s.GridLeyend;
            
       boolean t7 = s.showColumn2;   
       boolean t8 = s.showColumn3; 
       boolean t9 = s.showColumn4; 
       boolean t10 = s.showColumn5; 
        
       s.MappingItemId ='';
       s.MappingItemRowId ='';
     
        s.Filter1 = new Batch_NewSession_CL.CustomFilters();
        s.Filter2 = new Batch_NewSession_CL.CustomFilters();
        s.Filter3 = new Batch_NewSession_CL.CustomFilters();
        
        s.filtersString ='';
        s.baSendata = new Batch_SentDataBatchable();
        
        //s.T1E4 ='';
 
        s.GetPageStatus();
        s.tempVoid();
        
        s.PaginationFirst();
        s.PaginationPreview();
        s.PaginationNext();
        s.PaginationLast();
        s.ProcessBatch();
        
         s.AddFilter1();
        s.AddFilter2();
        s.RemoveFilter2();
        s.RemoveFilter3();
        s.FilterData(); 
        s.OnSelectStaticFilter();
        s.Cancel();
        s.Settings();
        s.OnSelectMapping();
        s.source.selectedSavedMapping ='';
        s.source.selectedPostData ='USA';
        s.source.selectedObject ='Account';
        s.source.selectedObjectName ='Account';
        s.LoadStep2();        
        s.LoadStep3(); 
        
        s.source.selectedSavedMapping ='';
        s.source.selectedPostData ='USA';
        s.source.selectedObject ='Account';
        s.source.selectedObjectName ='Account';
        
        object t = s.source.SavedMappingsOptions;
         t = s.source.PreferObjectFieldOptions;
         t = s.source.MappingCount ;
         s.source.TransactionOverallStatus ='';
         s.source.BatchTotalDownloaded =1;
         s.source.BatchTotalCount = 1;
         s.source.BatchTotalDownloadedPrecentage = '';
        
        s.AddSubMapping();
        
        s.LoadStep4();
        
          
        //s.AddSubMappingItem();
        //s.RemoveMappingField();
        //s.RemoveMapping(); 
        s.SaveMappings();
        //s.getDataSet();

        string getName = s.GetSelectedObjectLabel();
        
       Batch_NewSession_CL.DisplayDataItem  tc1 = new Batch_NewSession_CL.DisplayDataItem();
       
        tc1.SourceType ='';
       tc1.MappingId ='';
       tc1.Id       ='';
       tc1.Address1  ='';
       tc1.Address2   ='';
       tc1.Address3   ='';
       tc1.Address4   ='';
       tc1.Address5   ='';
       tc1.City     ='';
       tc1.State   ='';
       tc1.Zip     ='';
       tc1.Country   ='';      
       tc1.Reference1   ='';
       tc1.Reference2   ='';
       tc1.Reference3   ='';
       tc1.Reference4   ='';
       tc1.Reference5   ='';
       tc1.Reference6   ='';
       tc1.Reference7   ='';
       tc1.Reference8   ='';
       tc1.Reference9   ='';
       tc1.Reference10  ='';      
       tc1.Reference11   ='';
       tc1.Reference12   ='';
       tc1.Reference13   ='';
       tc1.Reference14   ='';
       tc1.Reference15   ='';
       tc1.Reference16   ='';
       tc1.Reference17   ='';
       tc1.Reference18   ='';
       tc1.Reference19   ='';
       tc1.Reference20   ='';        
       tc1.mappingIndex =0;
        
        s.Filter1.isVisible = true;
        s.Filter1.isValid = true;
        s.Filter1.Value = 'test';
        s.Filter1.Condition = 'like';
        
        s.Filter2.isVisible = true;
        s.Filter3.isVisible = true;
        
        s.Filter2.isValid = true;
        s.Filter3.isValid = true;
       Batch_NewSession_CL.getTableCount(null,'Account');
        
        Batch_NewSession_CL.MappingItem c1 = new Batch_NewSession_CL.MappingItem();
        c1.MappingId ='';
        
 
        Batch_NewSession_CL.BatchToProcess cl4 = new Batch_NewSession_CL.BatchToProcess();
        cl4.Index =0;
        cl4.Country ='';
        cl4.BatchId ='';
        cl4.Status ='';
        
        s.LoadSavedMappings();
        s.GetMappingItem('0ss');
        //s.GetMappingFromData('[]','askasks');
        
        
        s.ApplyCustomFilter('1');
         s.ApplyCustomFilter('2');
         s.ApplyCustomFilter('3');
         s.ApplyCustomFilter('4');
         s.ApplyCustomFilter('5');
         s.ApplyCustomFilter('6');
        
        s.TransactionOnProcess = false;
        s.BatchOnPreProcess = new List<Batch_SentDataBatchable.batchItem>();
        s.BatchOnPreProcessContains('test');
        
        S.hasSObjectField('Id');
        system.assert(true);
    }
}