shared_module('wallpapers-ocs',
  'wallpapers_ocs.vala',
  dependencies: [
    dependency('gtk4'),
    libsingularity_dep,
    dependency('libpeas-2'),
    dependency('json-glib-1.0'),
    dependency('gee-0.8'),
  ],
  c_args: ['-DGETTEXT_PACKAGE="singularity-desktop"'],
  install: true,
  install_dir: get_option('libdir') / 'singularity/plugins/wallpapers-ocs'
)

configure_file(
  input: 'wallpapers-ocs.plugin',
  output: 'wallpapers-ocs.plugin',
  copy: true,
  install: true,
  install_dir: get_option('libdir') / 'singularity/plugins/wallpapers-ocs'
)
