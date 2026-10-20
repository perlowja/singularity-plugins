project('edit-html-preview', ['vala', 'c'], version: '1.0.0')
add_project_arguments('-DGETTEXT_PACKAGE="edit-html-preview"', language: 'c')

shared_module('html-preview',
  files('html_preview.vala'),
  dependencies: [
    dependency('singularity-edit-1'),
    dependency('libpeas-2'),
    dependency('webkitgtk-6.0'),
  ],
  install: true,
  install_dir: get_option('libdir') / 'singularity' / 'app-plugins' / 'edit' / 'html-preview',
)
install_data('html-preview.plugin',
  install_dir: get_option('libdir') / 'singularity' / 'app-plugins' / 'edit' / 'html-preview')
