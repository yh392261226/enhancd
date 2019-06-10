__enhancd::flag::config()
{
    local -a configs
    configs=(
    "$ENHANCD_ROOT/flag.ltsv"
    "$ENHANCD_DIR/flag.ltsv"
    )

    local config
    for config in "${configs[@]}"
    do
        if [[ -f ${config} ]]; then
            cat "${config}"
        fi
    done
}

__enhancd::flag::get()
{
    local opt="${1:?value of key short or long required}" key="${2}"
    __enhancd::flag::config \
        | __enhancd::filter::exclude_commented \
        | __enhancd::ltsv::parse \
        -v opt="${opt}" \
        -v key="${key}" \
        -q 'ltsv("short")==opt||ltsv("long")==opt{print key=="" ? $0 : ltsv(key)}'
}

__enhancd::flag::parse()
{
    local opt="$1" arg="$2" func

    func="$(__enhancd::flag::get "${opt}" "func")"
    cond="$(__enhancd::flag::get "${opt}" "condition")"

    if ! __enhancd::command::run "${cond}"; then
        echo "${opt}: defined but require '${cond}'" >&2
        return 1
    fi

    if [[ -z ${func} ]]; then
        echo "${opt}: no such option" >&2
        return 1
    fi

    if __enhancd::command::which ${func}; then
        ${func} "${arg}"
    else
        echo "${func}: no such function defined" >&2
        return 1
    fi
}

__enhancd::flag::is_default()
{
    local opt=$1
    case $SHELL in
        *bash)
            case "$opt" in
                "-P" | "-L" | "-e" | "-@")
                    return 0
                    ;;
            esac
            ;;
        *zsh)
            case "$opt" in
                "-q" | "-s" | "-L" | "-P")
                    return 0
                    ;;
            esac
            ;;
    esac
    return 1
}

__enhancd::flag::print_help()
{
    __enhancd::flag::config \
        | __enhancd::command::awk -f "$ENHANCD_ROOT/lib/help.awk"
    return $?
}

__enhancd::flag::edit()
{
    local config
    config="$ENHANCD_DIR/flag.ltsv"
    if [[ ! -f ${config} ]]; then
        echo "short:	long:--YOURS	desc:YOUR FUNCTION DESCRIPTION	func:__enhancd::sources::YOURS	condition:true" >"${config}"
    fi
    $EDITOR "${config}" < /dev/tty > /dev/tty
    printf "\0"
}
