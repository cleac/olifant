public class Tootle.API.Instance{

    public string uri;
    public string email;
    public string version;
    public string[] languages;
    public string title;

    public Instance (string _uri){
        uri = _uri;
    }

    public static Instance parse(Json.Object obj) {
        var uri= obj.get_string_member ("uri");
        var instance = new Instance (uri);

        instance.title = obj.get_string_member ("title");
        instance.version = obj.get_string_member ("version");
        instance.email = obj.get_string_member ("email");

        return instance;
    }
}
