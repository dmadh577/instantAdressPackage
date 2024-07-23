public class Response {
	public List<Detail> details { get; set; }
    public DateTime timestamp { get; set; }
    public string token { get; set; }
    public Formattedaddress formattedaddress { get; set; }
    public InputAddress inputaddress { get; set; }
    public string responseflag { get; set; }
    public string verificationflag { get; set; }
    public integer totalrecords { get; set; }
    public string errordata { get; set; }
    public string additionaldata { get; set; }
    public string addresschangeflags { get; set; }
    public string reference { get; set; }
}