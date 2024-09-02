set shell := ["bash", "-uc"]

just_dir := canonicalize(justfile_directory())
invoc_dir := canonicalize(invocation_directory())
envrc := '''
  watch_file **/*.nix
  use_flake %s#developer --option sandbox false
'''

bootstrap:
    printf '{{ envrc }}' {{ if just_dir == invoc_dir { "." } else { just_dir } }} > {{ invoc_dir }}/.envrc

default:
    @just --choose \
    --chooser="\
    just --list --list-heading '' | \
    grep -v -e '^\s*default$' -e '^\s*exit$' | \
    sort | \
    { echo 'exit'; cat; } | \
    fzf --no-sort \
    || :"

exit:
    @exit 0
