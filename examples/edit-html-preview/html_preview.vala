using Gtk;
using Singularity.Edit;

namespace HtmlPreview {

    public class Plugin : Object, Singularity.Edit.Plugin {
        private Host? host;
        private GenericArray<Preview> previews = new GenericArray<Preview> ();

        public void activate (Host host) {
            this.host = host;
            foreach (var ws in host.workspaces ()) previews.add (new Preview (ws));
            host.workspace_added.connect (on_added);
        }

        public void deactivate () {
            if (host != null) host.workspace_added.disconnect (on_added);
            foreach (var p in previews.data) p.dispose_all ();
            previews = new GenericArray<Preview> ();
        }

        private void on_added (Workspace ws) {
            previews.add (new Preview (ws));
        }
    }

    public class Preview : Object {
        private unowned Workspace workspace;
        private WebKit.WebView web;
        private uint timer;
        private ulong buffer_handler;
        private Document? current;

        public Preview (Workspace ws) {
            workspace = ws;
            web = new WebKit.WebView ();
            web.vexpand = true;
            ws.get_workbench ().register_view (new WorkbenchView ("html-preview", _("Preview"), WorkbenchRegion.INSPECTOR, web, 20));
            ws.active_document_changed.connect (track);
            track ();
        }

        public void dispose_all () {
            workspace.active_document_changed.disconnect (track);
            if (current != null) current.get_buffer ().disconnect (buffer_handler);
            workspace.get_workbench ().unregister_view ("html-preview");
        }

        private void track () {
            if (current != null) current.get_buffer ().disconnect (buffer_handler);
            current = workspace.get_active_document ();
            if (current == null || current.get_language_id () != "html") {
                current = null;
                return;
            }
            buffer_handler = current.get_buffer ().changed.connect (schedule);
            render ();
            workspace.get_workbench ().show_view ("html-preview");
        }

        private void schedule () {
            if (timer != 0) Source.remove (timer);
            timer = Timeout.add (300, () => {
                timer = 0;
                render ();
                return Source.REMOVE;
            });
        }

        private void render () {
            if (current == null) return;
            Gtk.TextIter s, e;
            current.get_buffer ().get_bounds (out s, out e);
            var file = current.get_file ();
            web.load_html (current.get_buffer ().get_text (s, e, false), file != null ? file.get_uri () : null);
        }
    }
}

[ModuleInit]
public void peas_register_types (TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Singularity.Edit.Plugin), typeof (HtmlPreview.Plugin));
}
