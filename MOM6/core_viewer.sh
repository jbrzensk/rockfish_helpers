#!/usr/bin/env bash
# Group user processes by the physical core on which their main thread last ran.

set -euo pipefail
export LC_ALL=C

declare -A cpu_socket cpu_core

# WRAP_WIDTH can override terminal detection, including when output is redirected.
if [[ -n ${WRAP_WIDTH:-} ]]; then
    columns=$WRAP_WIDTH
elif [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    columns=$(tput cols 2>/dev/null || :)
else
    columns=${COLUMNS:-80}
fi
[[ $columns =~ ^[0-9]+$ ]] || columns=80
((columns >= 20)) || columns=20

for cpu_dir in /sys/devices/system/cpu/cpu[0-9]*; do
    [[ -r "$cpu_dir/topology/physical_package_id" &&
       -r "$cpu_dir/topology/core_id" ]] || continue

    cpu=${cpu_dir##*/cpu}
    IFS= read -r cpu_socket["$cpu"] < "$cpu_dir/topology/physical_package_id"
    IFS= read -r cpu_core["$cpu"] < "$cpu_dir/topology/core_id"
done

if ((${#cpu_core[@]} == 0)); then
    printf 'Cannot read CPU topology from /sys/devices/system/cpu.\n' >&2
    exit 1
fi

# PSR is the logical CPU on which the process last executed. Its socket and
# core together identify a physical core; SMT siblings share those two IDs.
ps -e -o pid= -o user:32= -o psr= -o pcpu= -o args= -ww |
while read -r pid user psr pcpu command; do
    [[ $user == root || $user == ceph ]] && continue
    [[ $pid =~ ^[0-9]+$ ]] || continue

    if [[ $psr =~ ^[0-9]+$ && -n ${cpu_core[$psr]+present} ]]; then
        socket=${cpu_socket[$psr]}
        core=${cpu_core[$psr]}
    else
        # Never assign an unknown CPU to a real core.
        socket=-1
        core=-1
    fi

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$socket" "$core" "$pid" "$user" "$psr" "$pcpu" "$command"
done |
sort -t $'\t' -k1,1n -k2,2n -k3,3n |
while IFS=$'\t' read -r socket core pid user psr pcpu command; do
    if [[ ${last_socket-} != "$socket" || ${last_core-} != "$core" ]]; then
        if [[ $socket == -1 ]]; then
            printf '\n=== Unknown core ===\n'
        else
            printf '\n=== Socket %s, physical core %s ===\n' "$socket" "$core"
        fi
        if ((columns >= 60)); then
            printf '  %-8s %-16s %-6s %-8s %s\n' \
                PID USER '%CPU' LAST_CPU COMMAND
        fi
        last_socket=$socket
        last_core=$core
    fi

    printf -v prefix '  %-8s %-16s %-6s %-8s ' \
        "$pid" "$user" "$pcpu" "$psr"

    if ((${#prefix} + 16 > columns)); then
        # On narrow terminals, put the command beneath the process details.
        printf '  PID %s  USER %s  %%CPU %s  last CPU %s\n' \
            "$pid" "$user" "$pcpu" "$psr" | fold -s -w "$columns"
        prefix='    CMD '
    fi

    printf -v indent '%*s' "${#prefix}" ''
    command_width=$((columns - ${#prefix}))
    while IFS= read -r line; do
        printf '%s%s\n' "$prefix" "$line"
        prefix=$indent
    done < <(printf '%s\n' "$command" | fold -s -w "$command_width")
done

