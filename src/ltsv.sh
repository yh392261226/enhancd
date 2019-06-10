__enhancd::ltsv::parse()
{
    local -a args
    local query
    while (( $# > 0 ))
    do
        case "$1" in
            -q)
                query="$2"
                shift
                ;;
            -v)
                args+=("-v" "$2")
                shift
                ;;
            -f)
                args+=("-f" "$ENHANCD_ROOT/lib/ltsv.awk")
                args+=("-f" "$2")
                query=""
                shift
                ;;
        esac
        shift
    done

    local default_query='{print $0}'
    local ltsv_script="$(cat "$ENHANCD_ROOT/lib/ltsv.awk")"
    local awk_scripts="${ltsv_script} ${query:-$default_query}"

    __enhancd::command::awk ${args[@]} "${awk_scripts}"
}
