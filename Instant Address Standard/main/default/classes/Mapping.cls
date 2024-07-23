public class Mapping {
    
    public Mapping(string label, string name,string map_Object, integer index, string type){
        This.Name = name;
        This.Map_Object = map_Object;
        This.Index = index;
        This.Type = type;
        this.Label = label;
    }
  public String Type {set;get;}  
  public String Name {set;get;} 
  public String Label {set;get;} 
  public String Map_Object {set;get;} 
  public Integer Index {set;get;} 
      
}