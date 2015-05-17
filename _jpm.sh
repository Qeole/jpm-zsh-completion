#compdef jpm
# vim:se syn=zsh ts=2 sts=2 sw=2 et cc=80:

emulate -LR zsh

# main function
_jpm() {
  local cmd
  integer i=2
  # look for commands
  while (( i < $#words ))
  do
    case "$words[$i]" in
      -*)
        # skip option
        (( i++ ))
        continue
        ;;
    esac
    if [[ -z "$cmd" ]]
    then
      cmd="$words[$i]"
      words[$i]=()
      (( CURRENT-- ))
    fi
    (( i++ ))
  done

  # no command found: list command (or complete global options)
  if [[ -z "$cmd" ]]
  then
    _arguments -s -w : $_jpm_global_opts \
      ':jpm command:_jpm_commands'
    return
  fi

  curcontext="${curcontext%:*:*}:jpm-${cmd}:"

  # if command found, run corresponding completion
  if (( $+functions[_jpm-${cmd}] ))
  then
    _jpm-${cmd} \
    && return 0
  else
    # complete unknown commands normally
    _arguments -s -w : $_jpm_global_opts \
      '*:files:_files' \
      && return 0
  fi

  return 1
}

# listing available commands
_jpm_commands() {
  (( $#_jpm_cmd_list )) || _jpm_get_commands
  _describe -t commands 'jpm commands' _jpm_cmd_list
}

# call jpm help and parse to get list & description for commands
_jpm_get_commands() {
  typeset -ga _jpm_cmd_list
  local hline cmd

  _call_program jpm jpm -h 2>/dev/null \
    | sed -n "/^  Commands:$/,/^  Options:$/s#^ *\([a-z]\+\) *\(.*\)#\1:\2#p" \
    | while read -A hline
  do
    cmd=$hline
    _jpm_cmd_list+=($cmd)
  done
}

_jpm-docs() {
  _arguments : $_jpm_global_opts
}

_jpm-xpi() {
  _arguments : $_jpm_global_opts \
    '(--verbose -v)'{-v,--verbose}'[More verbose logging to stdout.]'
}

_jpm-post() {
  _arguments : $_jpm_global_opts \
    '(--verbose -v)'{-v,--verbose}'[More verbose logging to stdout.]' \
    '--post-url[A url to post a xpi of your extension]:URL:(http\:// http\://localhost\: http\://localhost\:8888)'
}

_jpm-watchpost() {
  _arguments : $_jpm_global_opts \
    '(--verbose -v)'{-v,--verbose}'[More verbose logging to stdout.]' \
    '--post-url[A url to post a xpi of your extension]:URL:(http\:// http\://localhost\: http\://localhost\:8888)'
}

_jpm-test() {
  _arguments : $_jpm_global_opts $_jpm_opts_testandrun \
    '(--filter -f)'{-f,--filter}'[--filter FILENAME[:TESTNAME\] only run tests whose filenames match FILENAME and optionally match TESTNAME, both regexps]:regex:_jpm_filter' \
    '--stop-on-error[Stop running tests after the first failure]' \
    '--tbpl[Print test output in TBPL format]' \
    '--times[Number of times to run tests]:Number of times to run tests:_nothing' \
    '--no-copy[Do not copy the profile.  Use with caution!]'
}

_jpm-init() {
  _arguments : $_jpm_global_opts
}

_jpm-run() {
  _arguments : $_jpm_global_opts $_jpm_opts_testandrun
}

# for --filter: regex1:regex2 with regex1 based on files, regex2 for test names
_jpm_filter() {
  _files
}

# for --binary-args: forwards completion to _mozilla function to get options
_jpm_firefox() {
  _dispatch "mozilla" "firefox"
}

# for --binary (select a Firefox binary)
_jpm_get_binary() {
  # search for main binary on system
  compadd $(which firefox)
  _files
}

# for --profile: get names of Firefox profiles from profiles.ini
_jpm_get_profile() {
  local -a profiles text profiledir
  case "$OSTYPE" in
  darwin*) profiledir=~/"Library/Application Support/Firefox" ;;
  *)       profiledir=~/.mozilla/firefox/ ;;
  esac
  profiles=(${(f)"$(< ${profiledir}/profiles.ini)"})
  profiles=(${(M)${profiles}:#(\[Profile|(Path|Name)=)*})
  text=${(F)profiles}
  profiles=(${(f)text//(#b)\[Profile([0-9]##)\]
Name=([^
]##|)
Path=([^
]##|)/$match[2]})
  profiles=(${profiles%:})
  _alternative \
    'names:profile name:compadd $profiles' \
    'files:path:_path_files -/'
}

# these options may be called anywhere, with any function
_jpm_global_opts=(
    '(--help -h)'{-h,--help}'[output usage information]'
    '(--version -V)'{-V,--version}'[output the version number]'
)
# this is a list of options used both with jpm run and jpm test
_jpm_opts_testandrun=(
    '(--verbose -v)'{-v,--verbose}'[More verbose logging to stdout.]'
    '(--binary -b)'{-b,--binary}'[Path of Firefox binary to use.]:binary:_jpm_get_binary'
    '--binary-args[Pass additional arguments into Firefox.]:Firefox option:_jpm_firefox'
    '--debug[Enable the add-on debugger when running the add-on]'
    '(--overload -o)'{-o,--overload}'[Overloads the built-in Firefox SDK modules with a local copy located at environment variable `JETPACK_ROOT` or `path` if supplied. Used for development on the SDK itself.]::path:_files'
    '(--profile -p)'{-p,--profile}'[Path or name of Firefox profile to use.]:profile:_jpm_get_profile' \
      \
    '--no-copy[Do not copy the profile.  Use with caution!]'
    '--prefs[Custom set user preferences (path to a json file)]:file:_file'
    '--check-memory[Enable leaked tracker that attempts to report compartments leaked]'
    '--profile-memory[Enable profiling of memory usage]'
    '--retro[In development flag for transitioning to new style addons; forces the lack of install.rdf/bootstrap.js creation regardless of what engine versions are running]'
)

_jpm "$@"
