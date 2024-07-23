public class Mappings {
    
    public Mappings(){
       
       This.Mapping_ID = Batch_Helpers.NewGuid() ;
       This.Mappings = new List<Mapping>();
    }
    
    public List<Mapping> Mappings{set;get;}
    public String Mapping_ID {set;get;}    
}