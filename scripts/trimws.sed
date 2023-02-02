#!/usr/bin/env -S sed -f

:a
/^\n*$/ {
    $d
    N
    ba
}

s/[[:space:]]\+$//
