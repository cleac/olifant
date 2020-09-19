using GLib;

public class Olifant.Accounts : Object {

    private string dir_path;
    private string file_path;

    public signal void switched (API.Account? account);
    public signal void updated (GenericArray<InstanceAccount> accounts);

    public GenericArray<InstanceAccount> saved_accounts = new GenericArray<InstanceAccount> ();
    public GenericArray<API.Instance?> instance_data = new GenericArray<API.Instance> ();
    public InstanceAccount? formal {get; private set;}
    public API.Account? current {get; private set;}
    public API.Instance? currentInstance {
        get { return instance_data.@get (settings.current_account); }
    }

    public Accounts () {
        dir_path = "%s/%s".printf (GLib.Environment.get_user_config_dir (), app.application_id);
        file_path = "%s/%s".printf (dir_path, "accounts.json");
    }

    public void switch_account (int id) {
        info ("Switching to #%i", id);
        settings.current_account = id;
        formal = saved_accounts.@get (id);

        var msg = new Soup.Message ("GET", "%s/api/v1/accounts/verify_credentials".printf (accounts.formal.instance));
        network.inject (msg, Network.INJECT_TOKEN);
        network.queue (msg, (sess, mess) => {
                var root = network.parse (mess);
                current = API.Account.parse (root);
                switched (current);
                updated (saved_accounts);
            },
            network.on_show_error);
    }

    public void add (InstanceAccount account) {
        info ("Adding account for %s at %s", account.username, account.instance);
        saved_accounts.add (account);
        save ();
        load_instances_info (saved_accounts);
        updated (saved_accounts);
        switch_account (saved_accounts.length - 1);
        account.start_notificator ();
    }

    public void remove (int i) {
        var account = saved_accounts.@get (i);
        account.close_notificator ();

        saved_accounts.remove_index (i);
        if (saved_accounts.length < 1){
            formal=null;
            current=null;
            //currentInstance=null;
            switched (null);
        }
        else {
            var id = settings.current_account - 1;
            if (id > saved_accounts.length - 1)
                id = saved_accounts.length - 1;
            else if (id < saved_accounts.length - 1)
                id = 0;
            switch_account (id);
        }
        save ();
        load_instances_info (saved_accounts);
        updated (saved_accounts);

        if (is_empty ()) {
            window.destroy ();           
            window=null;
            Dialogs.NewAccount.open ();
        }
    }

    public bool is_empty () {
        return saved_accounts.length == 0;
    }

    public void init () {
        save (false);
        load ();

        if (saved_accounts.length < 1)
            Dialogs.NewAccount.open ();
        else
            switch_account (settings.current_account);
    }

    protected void load_instances_info (GenericArray<InstanceAccount> saved_accounts) {
        info ("Reloading instances info");
        instance_data = new GenericArray<API.Instance?> ();
        for (var curId = 0; curId < saved_accounts.length; curId++) {
            // Kind of a dirty hack, if no value added, but if array size
            // specified in constructor, value gets deconstructed as long
            // as it leaves load_single_instance function
            instance_data.add (null);
            load_single_instance.begin (curId);
        }
    }

    protected async void load_single_instance(int current_id) {
        var cur_acc = this.saved_accounts.@get (current_id);
        var cur_instance = cur_acc.instance;
        info ("Getting information for %s for #%i", cur_instance, current_id);
        var instMsg = new Soup.Message ("GET", "%s/api/v1/instance".printf (cur_instance));
        network.queue_noauth (instMsg, (sess, mess) => {
                var root = network.parse (mess);
                var instance = API.Instance.parse (root);
                instance_data.@set (current_id, instance);
                info ("DONE: Getting information of %s for #%i", cur_instance, current_id);
            },
            network.on_show_error);
    }

    public void save (bool overwrite = true) {
        try {
            var dir = File.new_for_path (dir_path);
            if (!dir.query_exists ())
                dir.make_directory ();

            var file = File.new_for_path (file_path);
            if (file.query_exists () && !overwrite)
                return;

            var builder = new Json.Builder ();
            builder.begin_array ();
            saved_accounts.foreach ((acc) => {
                var node = acc.serialize ();
                builder.add_value (node);
            });
            builder.end_array ();

            var generator = new Json.Generator ();
            generator.set_root (builder.get_root ());
            var data = generator.to_data (null);

            if (file.query_exists ())
                file.@delete ();

            FileOutputStream stream = file.create (FileCreateFlags.PRIVATE);
            stream.write (data.data);
        }
        catch (GLib.Error e){
            warning (e.message);
        }
    }

    private void load () {
        try {
            uint8[] data;
            string etag;
            var file = File.new_for_path (file_path);
            file.load_contents (null, out data, out etag);
            var contents = (string) data;

            var parser = new Json.Parser ();
            parser.load_from_data (contents, -1);
            var array = parser.get_root ().get_array ();

            saved_accounts = new GenericArray<InstanceAccount> ();
            array.foreach_element ((_arr, _i, node) => {
                var obj = node.get_object ();
                var account = InstanceAccount.parse (obj);
                if (account != null) {
                    saved_accounts.add (account);
                    account.start_notificator ();
                }
            });
            debug ("Loaded %i saved accounts", saved_accounts.length);
            load_instances_info (saved_accounts);
            updated (saved_accounts);
        }
        catch (GLib.Error e){
            warning (e.message);
        }
    }

}
