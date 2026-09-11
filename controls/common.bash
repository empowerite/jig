# common.bash - what every control shares: the argument shape, the refusal, the pass, and the summary sink
#
# Sourced by each control. A control takes `--all`, or `--changed` followed by files, or nothing when its subject is
# not a set of files; `scope` reads that into `mode` and `files`. `refuse` and `pass` print the same lines on a desk
# and on a runner, and append to the step summary where one exists.

summary=${GITHUB_STEP_SUMMARY:-/dev/null}

scope() {
  mode=${1:---all}
  if (( $# > 0 ))
  then
    shift
  fi
  files=("$@")
  case "${mode}" in
    (--all|--changed) ;;
    (*)
      echo "usage: ${0##*/} [--all | --changed <file>...]" >&2
      return 2
  esac
}

run_url() {
  if [[ -n "${GITHUB_RUN_ID:-}" ]]
  then
    printf '%s/%s/actions/runs/%s' "${GITHUB_SERVER_URL}" "${GITHUB_REPOSITORY}" "${GITHUB_RUN_ID}"
  else
    printf '#'
  fi
}

capitalized() {
  awk '{ print toupper(substr($0, 1, 1)) substr($0, 2) }' <<< "$1"
}

refuse() {
  echo "::error::$1"
  printf '### ❌ %s\n\n%s\n' "$(capitalized "$1")" "${remedy}"
  printf '### ❌ %s\n\n%s\n' "$(capitalized "$1")" "${remedy}" >> "${summary}"
  return 1
}

pass() {
  printf '✅ %s\n' "$1"
  printf '✅ %s\n' "$1" >> "${summary}"
}
