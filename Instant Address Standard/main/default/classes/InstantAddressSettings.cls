public class InstantAddressSettings {
    public InstantAddressBatch batch { get; set; }
    public InstantAddressSettings(){
        batch = new InstantAddressBatch();
    }
}