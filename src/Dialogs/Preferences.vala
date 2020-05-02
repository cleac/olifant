using Gtk;

public class Tootle.Dialogs.Preferences : Dialog {

    private static Preferences dialog;

    private SettingsSwitch switch_notifications;
    private SettingsSwitch switch_watcher;
    private SettingsSwitch switch_stream;
    private SettingsSwitch switch_stream_public;
    private Grid grid;

    public Preferences () {
        border_width = 6;
        deletable = false;
        resizable = false;
        title = _("Settings");
        transient_for = window;

        int i = 0;
        grid = new Grid ();

        switch_watcher = new SettingsSwitch ("always-online");
        switch_notifications = new SettingsSwitch ("notifications");
        switch_notifications.state_set.connect (state => {
            switch_watcher.sensitive = state;
            return false;
        });
        switch_stream = new SettingsSwitch ("live-updates");
        switch_stream_public = new SettingsSwitch ("live-updates-public");
        switch_stream.state_set.connect (state => {
            switch_stream_public.sensitive = state;
            return false;
        });

        grid.attach (new Granite.HeaderLabel (_("Appearance")), 0, i++, 2, 1);
        grid.attach (new SettingsLabel (_("Dark theme:")), 0, i);
        grid.attach (new SettingsSwitch ("dark-theme"), 1, i++);

        grid.attach (new Granite.HeaderLabel (_("Timelines")), 0, i++, 2, 1);
        grid.attach (new SettingsLabel (_("Real-time updates:")), 0, i);
        grid.attach (switch_stream, 1, i++);
        grid.attach (new SettingsLabel (_("Update public timelines:")), 0, i);
        grid.attach (switch_stream_public, 1, i++);

        // grid.attach (new Granite.HeaderLabel (_("Caching")), 0, i++, 2, 1);
        // grid.attach (new SettingsLabel (_("Use cache:")), 0, i);
        // grid.attach (new SettingsSwitch ("cache"), 1, i++);
        // grid.attach (new SettingsLabel (_("Max cache size (MB):")), 0, i);
        // var cache_size = new SpinButton.with_range (16, 256, 1);
        // settings.schema.bind ("cache-size", cache_size, "value", SettingsBindFlags.DEFAULT);
        // grid.attach (cache_size, 1, i++);

        grid.attach (new Granite.HeaderLabel (_("Notifications")), 0, i++, 2, 1);
        grid.attach (new SettingsLabel (_("Display notifications:")), 0, i);
        grid.attach (switch_notifications, 1, i++);
        grid.attach (new SettingsLabel (_("Always receive notifications:")), 0, i);
        grid.attach (switch_watcher, 1, i++);
        grid.attach (new SettingsLabel (_("Clear notifications:")), 0, i);
        var cleanNotifications=new Button.with_label (_("Clear"));
        cleanNotifications.clicked.connect (() => {
            var url = "%s/api/v1/notifications/clear".printf (accounts.formal.instance);
            var msg = new Soup.Message ("POST", url);
            network.inject (msg, Network.INJECT_TOKEN);
            network.queue (msg, (sess, mess) => {
                //update notifications tab
                Tootle.window.notifications.on_refresh();
            }, (status, reason) => {
                open_link_fallback (url, reason);
            });

        });
        grid.attach (cleanNotifications, 1, i++);


        var content = get_content_area () as Box;
        content.pack_start (grid, false, false, 0);

        var close = add_button (_("_Close"), ResponseType.CLOSE) as Button;
        close.clicked.connect (() => {
            destroy ();
            dialog = null;
        });

        show_all ();
    }

    public static void open () {
        if (dialog == null)
            dialog = new Preferences ();
    }

    protected class SettingsLabel : Label {
        public SettingsLabel (string text) {
            label = text;
            halign = Align.END;
            margin_start = 12;
            margin_end = 12;
        }
    }

    protected class SettingsSwitch : Switch {
        public SettingsSwitch (string setting) {
            halign = Align.START;
            valign = Align.CENTER;
            margin_bottom = 6;
            settings.schema.bind (setting, this, "active", SettingsBindFlags.DEFAULT);
        }
    }
    public bool open_link_fallback (string url, string reason) {
        warning ("Can't resolve url: " + url);
        warning ("Reason: " + reason);

        var toast = window.toast;
        toast.title = reason;
        toast.set_default_action (_("Open in Browser"));
        ulong signal_id = 0;
        signal_id = toast.default_action.connect (() => {
            Desktop.open_uri (url);
            toast.disconnect (signal_id);
        });
        toast.send_notification ();
        return true;
    }

}
