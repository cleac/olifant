using Gtk;

public class Tootle.Dialogs.NewAccount : Dialog {

    private static NewAccount dialog;

    private Grid grid;
    private Button button_done;
    private Image logo;
    private Entry instance_entry;
    private Label instance_register;
    private Label code_name;
    private Label url_hint;
    private Entry code_entry;

    private string? instance;
    private string? client_id;
    private string? client_secret;
    private string? code;
    private string? token;
    private string? username;
    private int64? instance_status_char_limit;

    private const int64 DEFAULT_INSTANCE_STATUS_CHAR_LIMIT = 500;

    public NewAccount () {
        border_width = 6;
        deletable = true;
        resizable = false;
        title = _("New Account");
        transient_for = window;

        logo = new Image.from_resource ("/me/cleac/tootle/logo128");
        logo.halign = Align.CENTER;
        logo.hexpand = true;
        logo.margin_bottom = 24;

        instance_entry = new Entry ();
        instance_entry.width_chars = 30;

        instance_register = new Label ("<a href=\"https://joinmastodon.org/\">%s</a>".printf (_("What's an instance?")));
        instance_register.halign = Align.END;
        instance_register.set_use_markup (true);

        code_name = new Widgets.AlignedLabel (_("Code:"));

        code_entry = new Entry ();
        code_entry.secondary_icon_name = "dialog-question-symbolic";
        code_entry.secondary_icon_tooltip_text = _("Paste your instance authorization code here");
        code_entry.secondary_icon_activatable = false;

        button_done = new Button.with_label (_("Add Account"));
        button_done.clicked.connect (on_done_clicked);
        button_done.halign = Align.END;
        button_done.margin_top = 24;

        url_hint = new Label("test");
        url_hint.halign = Align.END;
        url_hint.set_use_markup (true);

        grid = new Grid ();
        grid.column_spacing = 12;
        grid.row_spacing = 6;
        grid.hexpand = true;
        grid.halign = Align.CENTER;
        grid.attach (logo, 0, 0, 2, 1);
        grid.attach (new Widgets.AlignedLabel (_("Instance:")), 0, 1);
        grid.attach (instance_entry, 1, 1);
        grid.attach (code_name, 0, 3);
        grid.attach (code_entry, 1, 3);
        grid.attach (url_hint, 1, 4);
        grid.attach (instance_register, 1, 5);
        grid.attach (button_done, 1, 10);

        var content = get_content_area () as Box;
        content.pack_start (grid, false, false, 0);

        destroy.connect (() => {
            dialog = null;

            if (accounts.is_empty ())
                app.remove_window (window_dummy);
        });

        show_all ();
        clear ();
    }

    private void clear () {
        code_name.hide ();
        code_entry.hide ();
        url_hint.hide ();
        code_entry.text = "";
        client_id = client_secret = code = token = null;
    }

    private void on_done_clicked () {
        instance = "https://" + instance_entry.text
            .replace ("/", "")
            .replace (":", "")
            .replace ("https", "")
            .replace ("http", "");
        code = code_entry.text;

        request_instance_status_charlimit();

        if (client_id == null || client_secret == null) {
            request_client_tokens ();
            return;
        }

        if (code == "")
            app.error (_("Error"), _("Please paste valid instance authorization code"));
        else
            try_auth (code);
    }

    private void request_instance_status_charlimit () {
        var instance_query = new Soup.Message("GET", "%s/api/v1/instance".printf(instance));
        network.queue(instance_query, (sess, msg) => {
            var root = network.parse (msg);
            instance_status_char_limit = root.get_int_member ("max_toot_chars");
            if (instance_status_char_limit > 0) {
                info ("Got new instance status character limit: %s".printf(instance_status_char_limit.to_string()));
            } else {
                instance_status_char_limit = DEFAULT_INSTANCE_STATUS_CHAR_LIMIT;
                warning ("Could not determine maximum status length, falling back to 500");
            }
        }, (_, __) => {
            instance_status_char_limit = DEFAULT_INSTANCE_STATUS_CHAR_LIMIT;
            warning ("Could not determine maximum status length, falling back to 500");
        });
    }

    private void request_client_tokens (){
        var pars = "?client_name=Tootle%20Fork";
        pars += "&redirect_uris=urn:ietf:wg:oauth:2.0:oob";
        pars += "&website=https://github.com/cleac/tootle";
        pars += "&scopes=read%20write%20follow";

        grid.sensitive = false;
        var message = new Soup.Message ("POST", "%s/api/v1/apps%s".printf (instance, pars));
        network.queue (message, (sess, msg) => {
            grid.sensitive = true;

            var root = network.parse (msg);
            var id = root.get_string_member ("client_id");
            var secret = root.get_string_member ("client_secret");
            client_id = id;
            client_secret = secret;

            info ("Received tokens from %s", instance);
            request_auth_code ();
            code_name.show ();
            code_entry.show ();
            url_hint.show ();
            url_hint.set_markup ("Browser did not open? Try <a href=\"%s\">link</a>".printf (GLib.Markup.escape_text (generate_auth_url ())));
        }, (status, reason) => {
            network.on_show_error (status, reason);
        });
    }

    private string generate_auth_url () {
        var pars = "?scope=read%20write%20follow";
        pars += "&response_type=code";
        pars += "&redirect_uri=urn:ietf:wg:oauth:2.0:oob";
        pars += "&client_id=" + client_id;

        return "%s/oauth/authorize%s".printf (instance, pars);
    }

    private void request_auth_code (){
        info ("Requesting auth token");
        Desktop.open_uri (generate_auth_url ());
    }

    private void try_auth (string code){
        var pars = "?client_id=" + client_id;
        pars += "&client_secret=" + client_secret;
        pars += "&redirect_uri=urn:ietf:wg:oauth:2.0:oob";
        pars += "&grant_type=authorization_code";
        pars += "&code=" + code;

        var message = new Soup.Message ("POST", "%s/oauth/token%s".printf (instance, pars));
        network.queue (message, (sess, msg) => {
                var root = network.parse (msg);
                token = root.get_string_member ("access_token");

                info ("Got access token");
                get_username ();
        }, (status, reason) => {
            network.on_show_error (status, reason);
        });
    }

    private void get_username () {
        var message = new Soup.Message("GET", "%s/api/v1/accounts/verify_credentials".printf (instance));
        message.request_headers.append ("Authorization", "Bearer " + token);
        network.queue (message, (sess, msg) => {
                var root = network.parse (msg);
                username = root.get_string_member ("username");
                add_account ();
                window.show ();
                window.present ();
                destroy ();
            }, (status, reason) => {
                network.on_show_error (status, reason);
            });
    }

    private void add_account () {
        var account = new InstanceAccount ();
        account.username = username;
        account.instance = instance;
        account.client_id = client_id;
        account.client_secret = client_secret;
        account.token = token;
        account.status_char_limit = instance_status_char_limit;
        accounts.add (account);
        app.activate ();
    }

    public static void open () {
        if (dialog == null)
            dialog = new NewAccount ();
    }

}
