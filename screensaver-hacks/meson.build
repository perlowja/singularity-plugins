shared_module('screensaver-hacks',
  'screensaver_hacks.vala',
  dependencies: [
    dependency('gtk4'),
    libsingularity_dep,
    dependency('libpeas-2'),
    dependency('gee-0.8'),
  ],
  c_args: ['-DGETTEXT_PACKAGE="singularity-desktop"'],
  install: true,
  install_dir: get_option('libdir') / 'singularity/plugins/screensaver-hacks'
)

configure_file(
  input: 'screensaver-hacks.plugin',
  output: 'screensaver-hacks.plugin',
  copy: true,
  install: true,
  install_dir: get_option('libdir') / 'singularity/plugins/screensaver-hacks'
)
