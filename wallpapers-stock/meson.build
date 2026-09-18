shared_module('wallpapers-stock',
  'wallpapers_stock.vala',
  dependencies: [
    dependency('gtk4'),
    libsingularity_dep,
    dependency('libpeas-2'),
    dependency('json-glib-1.0'),
    dependency('gee-0.8'),
  ],
  c_args: ['-DGETTEXT_PACKAGE="singularity-desktop"'],
  install: true,
  install_dir: get_option('libdir') / 'singularity/plugins/wallpapers-stock'
)

configure_file(
  input: 'wallpapers-stock.plugin',
  output: 'wallpapers-stock.plugin',
  copy: true,
  install: true,
  install_dir: get_option('libdir') / 'singularity/plugins/wallpapers-stock'
)
