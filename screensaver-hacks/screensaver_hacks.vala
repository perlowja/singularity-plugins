using GLib;
using Gtk;
using Gee;
using Singularity;
using Peas;

[ModuleInit]
public void peas_register_types(TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(Singularity.Plugin), typeof(ScreensaverHacksPlugin));
}

namespace ScreensaverHacks {

    /**
     * One installed hack, read from a `.hack` manifest (same INI shape as a
     * WallpaperCollections `.collection` file). Distro-neutral search roots
     * only -- a distro that wants hacks ships manifests + binaries under
     * these paths, nothing here names a specific downstream.
     */
    public class Hack : Object {
        public string id;
        public string name;
        public string binary;
        public Hack(string id, string name, string binary) {
            this.id = id; this.name = name; this.binary = binary;
        }
    }

    public ArrayList<Hack> scan(string dir) {
        var result = new ArrayList<Hack>();
        Dir d;
        try {
            d = Dir.open(dir, 0);
        } catch (Error e) {
            return result;
        }
        string? entry;
        while ((entry = d.read_name()) != null) {
            if (!entry.has_suffix(".hack")) continue;
            var kf = new KeyFile();
            try {
                kf.load_from_file(Path.build_filename(dir, entry), KeyFileFlags.NONE);
                string id = kf.get_string("Hack", "Id");
                string name = kf.get_string("Hack", "Name");
                string binary = kf.get_string("Hack", "Binary");
                if (id != "" && binary != "") result.add(new Hack(id, name != "" ? name : id, binary));
            } catch (Error e) {
                warning("screensaver-hacks: bad manifest %s: %s", entry, e.message);
            }
        }
        return result;
    }

    public ArrayList<Hack> default_search_roots() {
        var result = new ArrayList<Hack>();
        foreach (var dir in new string[] {
            "/usr/share/singularity/screensaver-hacks",
            Path.build_filename(Environment.get_user_data_dir(), "singularity", "screensaver-hacks"),
        }) {
            result.add_all(scan(dir));
        }
        return result;
    }
}

public class ScreensaverHacksPlugin : Object, Singularity.Plugin {
    private PluginContext context;
    private HackRunner? runner;
    private uint preview_timer = 0;

    public void activate(PluginContext ctx) {
        this.context = ctx;
    }

    public void deactivate() {
        stop_preview();
    }

    private void stop_preview() {
        if (preview_timer != 0) { Source.remove(preview_timer); preview_timer = 0; }
        if (runner != null) { runner.stop(); runner = null; }
    }

    /** Launches a hack fullscreen for `seconds`, then stops it. Used by both
      * the settings-page preview button and the idle-trigger daemon (with a
      * much longer/no ceiling for the real idle-triggered case). */
    public bool launch(ScreensaverHacks.Hack hack, uint seconds = 0) {
        stop_preview();
        runner = new HackRunner();
        bool started = runner.start(hack.binary, seconds);
        if (!started) { runner = null; }
        return started;
    }

    public void stop() {
        stop_preview();
    }

    public bool is_available() {
        return !ScreensaverHacks.default_search_roots().is_empty;
    }

    public Gtk.Widget? get_settings_widget() {
        var box = new Box(Orientation.VERTICAL, 8);
        var hacks = ScreensaverHacks.default_search_roots();
        if (hacks.is_empty) {
            var lbl = new Label(_("No screensaver hacks are installed."));
            lbl.xalign = 0;
            box.append(lbl);
            return box;
        }
        foreach (var hack in hacks) {
            var row = new Box(Orientation.HORIZONTAL, 8);
            var lbl = new Label(hack.name);
            lbl.xalign = 0;
            lbl.hexpand = true;
            var preview_btn = new Button.with_label(_("Preview"));
            preview_btn.clicked.connect(() => { launch(hack, 15); });
            row.append(lbl);
            row.append(preview_btn);
            box.append(row);
        }
        return box;
    }
}
