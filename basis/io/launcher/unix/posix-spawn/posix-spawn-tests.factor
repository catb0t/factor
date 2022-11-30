! Copyright (C) 2022 Cat Stevens.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io.launcher io.launcher.unix.posix-spawn
io.launcher.unix.posix-spawn.private kernel literals namespaces
system tools.test unix.process.posix-spawn unix.scheduler ;
IN: io.launcher.unix.posix-spawn.tests

! how do we stop priority scheduler tests from running on macosx?

! +lowest-priority+ should be SCHED_IDLE on Linux, so priority must be 0
{
    flags{ POSIX_SPAWN_SETSCHEDULER }
    $[ SCHED_IDLE ]
    0
} [
    os macosx? [ flags{ POSIX_SPAWN_SETSCHEDULER } SCHED_IDLE 0 ] [

    <posix-spawnattr> dup flags{ }
    T{ process { priority +lowest-priority+ } }

    linux \ os [
        setup-scheduler
    ] with-variable

    swap
    [ attr-get-schedpolicy ]
    [ attr-get-schedparam sched_priority>> ] bi

    CURRENT  PROBLEM TO SOLVE: lack of GNU_SOURCE, therefore no SCHED_IDLE


    ] if ! macosx?
] unit-test

! ...and +lowest-priority+ should give SCHED_RR policy with minimum priority on FreeBSD
{
    flags{ POSIX_SPAWN_SETSCHEDULER }
    $[ SCHED_RR ]
    t
} [
    os macosx? [ flags{ POSIX_SPAWN_SETSCHEDULER } SCHED_RR t ] [

    <posix-spawnattr> dup flags{ }
    T{ process { priority +lowest-priority+ } }

    freebsd \ os [
        setup-scheduler
    ] with-variable

    swap
    [ attr-get-schedpolicy dup ]
    [   ! this branch reaches under into the other branch's output
        attr-get-schedparam sched_priority>>
        [ sched_get_priority_min ] dip =
    ] bi

    ] if ! macosx?
] unit-test
