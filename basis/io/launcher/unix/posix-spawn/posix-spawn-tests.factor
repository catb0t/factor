! Copyright (C) 2022 Cat Stevens.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations inspector io.launcher
io.launcher.unix.posix-spawn
io.launcher.unix.posix-spawn.private kernel literals namespaces
system tools.test unix.process unix.process.posix-spawn
unix.scheduler ;
IN: io.launcher.unix.posix-spawn.tests

SYMBOL: old-os

! need to stop priority scheduler tests from running on macosx?

! REQUIRES GNU TO PASS
! are we doing GNU support on Linux or not?
! +lowest-priority+ should be SCHED_IDLE on Linux, so priority must be 0
{
    flags{ POSIX_SPAWN_SETSCHEDULER }
    $[ SCHED_IDLE ]
    0
} [
    os macosx? [ flags{ POSIX_SPAWN_SETSCHEDULER } SCHED_IDLE 0 ] [

        <posix-spawnattr> dup flags{ }
        T{ process { priority +lowest-priority+ } }

        os old-os set
        linux \ os set-global
        [ setup-scheduler ]
        [ old-os get \ os set-global ] finally

        swap
        [ attr-get-schedpolicy ]
        [ attr-get-schedparam sched_priority>> ] bi

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

        os old-os set
        freebsd \ os set-global
        [ setup-scheduler ]
        [ old-os get \ os set-global ] finally

        swap
        [ attr-get-schedpolicy dup ]
        [   ! this branch reaches under into the other branch's output
            attr-get-schedparam sched_priority>>
            [ sched_get_priority_min ] dip =
        ] bi

    ] if ! macosx?
] unit-test
