using Olifant.API;

public class Olifant.API.Instance {
    public string uri;
    public string email;
    public VersionInfo version;
    public string[] languages;
    public string title;

    public Instance (owned string _uri){
        uri = _uri;
    }

    public bool is_mastodon_v3 () {
        return this.version.major >= 3;
    }

    public static Instance parse(Json.Object obj) {
        var uri= obj.get_string_member ("uri");
        var instance = new Instance (uri);

        instance.title = obj.get_string_member ("title");
        instance.version = VersionInfo.parse (obj.get_string_member ("version"));
        instance.email = obj.get_string_member ("email");

        return instance;
    }
}
