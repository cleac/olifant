/**
 * This is the class for translating Mastodon API Preferences JSON objects.
 */

public class Olifant.API.Preferences {

    public string posting_default_visibility;
    public bool posting_default_sensitive;
    public string? posting_default_language;
    public string reading_expand_media;
    public bool reading_expand_spoilers;

    public Preferences () {/* TODO? */}

    public static Preferences parse (Json.Object obj) {
        var prefs = new Preferences ();

        prefs.posting_default_visibility = obj.get_string_member ("posting:default:visibility");
        prefs.posting_default_sensitive = obj.get_boolean_member ("posting:default:sensitive");
        prefs.reading_expand_media = obj.get_string_member ("reading:expand:media");
        prefs.reading_expand_spoilers = obj.get_boolean_member ("reading:expand:spoilers");

        if (obj.has_member ("posting:default:language"))
            prefs.posting_default_language = obj.get_string_member ("posting:default:language");

        return prefs;
    }

    public Json.Node? serialize () {
        var builder = new Json.Builder ();
        builder.begin_object ();

        builder.set_member_name ("posting:default:visibility");
        builder.add_string_value (posting_default_visibility);
        builder.set_member_name ("posting:default:sensitive");
        builder.add_boolean_value (posting_default_sensitive);
        builder.set_member_name ("reading:expand:media");
        builder.add_string_value (reading_expand_media);
        builder.set_member_name ("reading:expand:spoilers");
        builder.add_boolean_value (reading_expand_spoilers);

        if (posting_default_language != null) {
            builder.set_member_name ("posting:default:language");
            builder.add_string_value (posting_default_language);
        }

        builder.end_object ();
        return builder.get_root ();
    }
}

/* TODO: put this where it goes
var msg = new Soup.Message ("GET", "%s/api/v1/preferences".printf (accounts.formal.instance));
network.inject (msg, Network.INJECT_TOKEN);
network.queue (msg, (sess, mess) => {
    var root = network.parse (mess);
    preferences = API.Preferences.parse (root);
}, (status, reason) => {
    network.on_show_error (status, reason);
});
*/
