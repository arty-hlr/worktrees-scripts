#!/usr/bin/env bash
# Source: https://github.com/llimllib/personal_code/blob/master/homedir/.local/bin/rmtree

RED="\033[0;31m"
YELLOW="\033[0;33m"
CLEAR="\033[0m"
VERBOSE=

function usage {
    cat <<"EOF"
Usage: wtremove [-vh] WORKTREE_NAME
Removes a worktree and its branch.

FLAGS:
  -h, --help    Print this help
  -v, --verbose Verbose mode   
EOF
    exit 1
}

function die {
    # if verbose was set, and we're exiting early, make sure that we set +x to
    # stop the shell echoing verbosely
    if [ -n "$VERBOSE" ]; then
        set +x
    fi
    printf '%b%s%b\n' "$RED" "$1" "$CLEAR"
    exit 1
}

function err {
    printf '%b%s%b\n' "$YELLOW" "$1" "$CLEAR"
}

function warn {
    printf '%b%s%b\n' "$YELLOW" "$1" "$CLEAR"
}

# rmtree <dir> will remove a worktree
# and delete the branch
function rmtree {
    if [ -n "$VERBOSE" ]; then
        set -x
    fi

    if [ -z "$1" ]; then
        die "You must provide a directory name that is a worktree to remove"
    fi
    worktreename="${1%/}"

    warn "removing $1"

    branchname=$(git worktree list | grep "/$worktreename\s" | sed 's/.*\[\(.*\)\]/\1/')
    if [ -z "$branchname" ]; then
        err "Worktree $worktreename doesn't exist"
    fi
    git worktree remove "$worktreename" && git branch -D "$branchname"
}

while true; do
    case $1 in
        help | -h | --help)
            usage
            ;;
        -v | --verbose)
            VERBOSE=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

rmtree "$@"
