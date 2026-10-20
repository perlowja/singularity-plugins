# Singularity Plugins

> [!IMPORTANT]
> Report bugs and request features in the
> [Singularity Desktop tracker](https://github.com/singularityos-lab/singularity-desktop/issues/new/choose).

libpeas plugins for the Singularity Desktop shell (tray icons, clipboard
history, media controls, weather, workspaces indicator, docks and more).

Each plugin builds a shared module installed under
`lib/singularity/plugins/<name>/`.

## Deprecated plugins

- `clipboard-history` is deprecated. The desktop now keeps the clipboard
  history itself: press Super+V, or open Settings, Clipboard, to search, pin
  and paste entries. The plugin is still built and loadable for now, but it is
  hidden from Settings, Plugins, and the desktop removes it from
  `enabled-plugins` once, turning on the built-in history for users who had it
  enabled. The plugin kept its entries in memory only, so there is no stored
  history or pinned item to carry over. It will be removed in a later release.

## App plugin catalog

Apps such as Edit load their own plugins, separate from the shell plugins above. The Store reads `index.json` from this repository and shows, for every app you have installed, the plugins written for it. Turning a plugin on or off happens in Settings, under Plugins.

### How the catalog works

- `index.json` lists every plugin with the app it extends, its version and one bundle per architecture.
- `index.json.sig` is an Ed25519 signature of `index.json`. The Store refuses the whole catalog when the signature does not match the key it ships with.
- Each bundle entry carries a SHA-256 checksum. The Store refuses a download whose checksum differs from the catalog.
- Bundles are `.tar.gz` archives with the plugin's `.plugin` file and its module at the top level. The Store unpacks them into `~/.local/share/singularity/app-plugins/<app>/<plugin>/`.

### Writing a plugin

Plugins are [libpeas](https://gitlab.gnome.org/GNOME/libpeas) modules written in Vala or C against the app's plugin API. For Edit, that API is `singularity-edit-1` (pkg-config and Vala bindings ship with Edit): a plugin implements `Singularity.Edit.Plugin` and receives a `Host` with every open window, its workbench (side bar, inspector, bottom panel, status bar, command palette) and its documents.

`examples/edit-html-preview` is a complete plugin that adds a live HTML preview to Edit. Build it from its folder with:

```sh
meson setup build
ninja -C build
```

The `.plugin` file names the module and the apps that host it:

```ini
[Plugin]
Module=html-preview
Name=HTML Preview
Description=A live preview of HTML files next to the editor
X-Singularity-Host=dev.sinty.edit
```

### Publishing

1. Build the bundle for each architecture you support and attach it to a release of your own repository.
2. Open a pull request that adds your entry to `index.json`:

```json
{
  "id": "html-preview",
  "module": "html-preview",
  "name": "HTML Preview",
  "summary": "A live preview of HTML files next to the editor",
  "author": "Singularity",
  "app": "dev.sinty.edit",
  "host_dir": "edit",
  "version": "1.0.0",
  "icon": "text-html",
  "bundles": {
    "x86_64": { "url": "https://…/html-preview-1.0.0-x86_64.tar.gz", "sha256": "…" }
  }
}
```

3. After review, a maintainer signs the new catalog with `tools/sign-index.sh` and merges it.

`app` is the application id the plugin extends, `host_dir` the folder name that app reads plugins from (`edit` for Edit), and `module` must match `Module=` in the `.plugin` file.

## Requirements

- GTK4, libgee-0.8, libpeas-2
- [libsingularity](https://github.com/singularityos-lab/libsingularity)

## License

GPL-3.0-only - see [LICENSE](LICENSE).

## Use of Generative AI

Maintainers may use generative AI tools as assistants while working on singularity-plugins. Non-trivial assisted commits disclose the tool, model, and scope of the work.

AI tools may assist with code comments, documentation, repetitive code, and issue triage. Maintainers make project decisions and review every assisted change before it is merged.

Use these trailers for non-trivial assisted commits:

```plain
Assisted-by: <tool>:<model-version>
AI-Scope: <what the tool generated and the prompt or a short prompt summary>
```

Single-line completions, renames, and formatting changes do not need trailers.

Coding agents must also follow [AGENTS.md](AGENTS.md) before changing files,
creating commits, or opening pull requests.
