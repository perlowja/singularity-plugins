using GLib;
using Gtk;
using Gee;
using Singularity;
using Peas;

[ModuleInit]
public void peas_register_types(TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type(typeof(Singularity.Plugin), typeof(WallpapersStockPlugin));
}

namespace WallpapersStock {

    /**
     * Searchable stock-photo wallpapers (Openverse, Unsplash). Each network
     * requires its own external helper (`ncz-wallpaper-openverse` /
     * `ncz-wallpaper-unsplash`), not shipped by plain Singularity -- this
     * plugin is disabled by default.
     */
    public class Provider : WallpaperHelperProvider, WallpaperProvider {
        private string provider_id;
        public string id { get { return provider_id; } }
        public string display_name {
            owned get { return provider_id == "openverse" ? _("Openverse") : _("Unsplash"); }
        }
        public bool requires_credentials { get { return provider_id == "unsplash"; } }
        public bool supports_search { get { return true; } }
        public Provider(string id, string helper_path) {
            base(helper_path);
            provider_id = id;
        }
        public async ArrayList<WallpaperProviderChoice> choices(string index, Cancellable? cancel) throws Error {
            return new ArrayList<WallpaperProviderChoice>();
        }
        public async WallpaperProviderResult browse(string choice, string query, int page,
                bool refresh, Cancellable? cancel) throws Error {
            string[] argv = {helper, "search", query, "--page", page.to_string()};
            if (refresh) argv += "--refresh";
            string data = yield command(argv, cancel, 90);
            var response = WallpaperOcs.document(data);
            var result = new WallpaperProviderResult();
            result.items = WallpaperOpenverse.items(data, provider_id);
            var pages = response.get_member("page_count");
            if (pages == null || pages.get_value_type() != typeof(int64))
                throw new WallpaperOcsError.INVALID("Invalid stock photo page count");
            result.page_count = (int) pages.get_int();
            var stale = response.get_member("stale");
            result.stale = stale != null && stale.get_value_type() == typeof(bool) && stale.get_boolean();
            return result;
        }
        public async string import_item(WallpaperItem item, Cancellable? cancel) throws Error {
            return yield command({helper, "import", item.id}, cancel, 600);
        }
    }
}

public class WallpapersStockPlugin : Object, Singularity.Plugin {
    private PluginContext context;
    private WallpapersStock.Provider? openverse;
    private WallpapersStock.Provider? unsplash;

    public void activate(PluginContext ctx) {
        this.context = ctx;
        openverse = new WallpapersStock.Provider("openverse", "/usr/local/bin/ncz-wallpaper-openverse");
        unsplash = new WallpapersStock.Provider("unsplash", "/usr/local/bin/ncz-wallpaper-unsplash");
        context.add_wallpaper_provider(openverse);
        context.add_wallpaper_provider(unsplash);
    }

    public void deactivate() {
        if (openverse != null) {
            context.remove_wallpaper_provider(openverse);
            openverse = null;
        }
        if (unsplash != null) {
            context.remove_wallpaper_provider(unsplash);
            unsplash = null;
        }
    }

    public Gtk.Widget? get_settings_widget() {
        var box = new Box(Orientation.VERTICAL, 8);
        var lbl = new Label(_("Adds searchable Openverse and Unsplash wallpapers to the wallpaper browser. Requires the ncz-wallpaper-openverse and ncz-wallpaper-unsplash helpers."));
        lbl.wrap = true;
        lbl.xalign = 0;
        box.append(lbl);
        return box;
    }
}
