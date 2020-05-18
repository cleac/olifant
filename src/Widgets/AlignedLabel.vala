using Gtk;

public class Olifant.Widgets.AlignedLabel : Label {

    public AlignedLabel (string text) {
        label = text;
        halign = Align.END;
        //margin_start = 12;
    }

}
