public class InstantAddress_Lead_Ext {
	public InstantAddressRenderer Renderer { get; set; }
    
    public InstantAddress_Lead_Ext(ApexPages.StandardController stdController){
		this.Renderer = new InstantAddressRenderer(stdController, 'Lead');
    }
}