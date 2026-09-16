shared_module('sensors',
  'sensors.vala',
  dependencies: [dependency('gtk4'), libsingularity_dep, system_dep, dependency('libpeas-2'), meson.get_compiler('c').find_library('m')],
  c_args: ['-DGETTEXT_PACKAGE="singularity-desktop"'],
  install: true,
  install_dir: get_option('libdir') / 'singularity/plugins/sensors'
)

configure_file(
  input: 'sensors.plugin',
  output: 'sensors.plugin',
  copy: true,
  install: true,
  install_dir: get_option('libdir') / 'singularity/plugins/sensors'
)
