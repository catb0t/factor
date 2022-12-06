! Copyright (C) 2007, 2010, 2022 Slava Pestov and Cat Stevens.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data classes.struct
combinators continuations debugger environment fry inspector
io.backend io.backend.unix io.files.private io.files.unix
io.launcher io.launcher.private io.pathnames io.ports kernel
libc literals math namespaces sequences simple-tokenizer strings
summary system unix unix.ffi unix.process
unix.process.posix-spawn unix.scheduler unix.types ;
QUALIFIED-WITH: unix.signals sig
IN: io.launcher.unix.posix-spawn

<PRIVATE
ERROR: spawn-new-session-impossible attr process group ;
M: spawn-new-session-impossible summary
    drop "requested group +new-session+ is impossible in the posix-spawn API\nPOSIX does not provide a way to create a new session ID for a spawned process.\nUse setsid in the child process, or fork-process instead of spawn-process." ;

M: spawn-new-session-impossible error.
    describe ;

CONSTANT: middle-priorities { +low-priority+ +high-priority+ +highest-priority+ }

: get-arguments ( process -- target argv )
    command>> dup string? [ tokenize ] when [ first ] keep ;

: do-new-group ( spawnattr: posix_spawnattr_t flags -- flags )
    [ 0 attr-set-pgroup ]
    [ POSIX_SPAWN_SETPGROUP bitor ] bi* ; inline

! NOTE when documenting: Unimplemented: SETPGROUP and attr_setpgroup(n != 0)
! "the child's process group shall be as specified in the spawn-pgroup"
: setup-process-group ( spawnattr: posix_spawnattr_t flags process -- flags )
    dup group>> {
        { +same-group+  [ drop nip ] }
        { +new-group+   [ drop do-new-group ] }
        { +new-session+ [ spawn-new-session-impossible ] }
    } case ;

HOOK: setup-scheduler os ( spawnattr: posix_spawnattr_t flags process -- flags )

! TODO: mirror POSIX-style priority scheduling for <process> on macosx
! since we are not in the forked process, we can't really do much
! unless we wait until after the child is posix_spawn'd, and then nice(2)
! its pid, but that isn't terribly robust and nice (affinity) is not
! the same as priority

! this is currently a no-op
M: macosx setup-scheduler
    [ 3drop ] keepd ;

: use-fifo-policy? ( priority -- ? )
    { +highest-priority+ +realtime-priority+ } member? ; inline foldable flushable

HOOK: use-round-robin-policy? os ( priority -- ? )

M: linux use-round-robin-policy?
    { +high-priority+ +low-priority+ } member? ; inline foldable flushable

M: freebsd use-round-robin-policy?
    { +high-priority+ +low-priority+ +lowest-priority+ } member? ; inline foldable flushable

: ?edge-priority ( priority -- index/f )
    { +realtime-priority+ +lowest-priority+ } index ; inline foldable flushable

! edge priorities will give the max or min from the range, respectively
! otherwise evenly divide the range of valid values, and give a value based
! on desired priority
: segment-priority-in-range ( priority high low -- priority-integer )
    pick ?edge-priority [ zero? -rot ? nip ] [
        - middle-priorities [ length /i swap ] keep index 1 + *
    ] if* ; foldable flushable

! see man 7 sched
! select a scheduler policy and priority based on the desired priority slot
! note that CPU affinity as set by nice(2) is distinct from process priority
! and process priority is in the range [1,99] on Linux, but should be found with
! sched_get_priority_{min,max} (i.e. max is 127 on FreeBSD)

! +realtime-priority+ and +highest-priority+ will result in a FIFO Scheduler
! Policy, because that is the most aggressive

! +high-priority+ and +low-priority+ are kind of middling on either side
! of +normal-priority+, and we give them the Round Robin scheduler to remain fair
! to other similar processes in their priority list

! +lowest-priority+ will be SCHED_IDLE on Linux, and SCHED_RR with minimum priority
! on FreeBSD, as there is no SCHED_IDLE on FreeBSD.

! +normal-priority+ will be SCHED_OTHER, which is the default on Linux + BSD
! SCHED_IDLE and SCHED_OTHER (and all non-realtime policies) require
! sched_param->priority to be 0, because the priority will be fully determined
! by the Kernel scheduler

! this sets the schedpolicy field of spawnattr to the policy we picked given
! the input priority,
! and sets spawnattr->sched_param->sched_priority to either 0 (non-realtime policy)
! or the integer priority as determined by segment-priority-in-range

! the POSIX_SPAWN_SETSCHEDULER flag is set on the output flags in all cases,
! which causes us to implement only those POSIX behaviours that are supported
! by the io.launcher / <process> APIs.

! if priority is f, nothing is done and you are at the will of the scheduler.
M: unix setup-scheduler
    priority>> [
        swap [
            dup {
                { [ dup use-fifo-policy? ]        [ drop SCHED_FIFO ] }
                { [ dup +normal-priority+ = ]     [ drop SCHED_OTHER ] }
                { [ dup use-round-robin-policy? ] [ drop SCHED_RR ] }
                { [ dup +lowest-priority+ = ]     [ drop MOST_IDLE_SCHED_POLICY ] }
            } cond
            [ nip attr-set-schedpolicy ] [
                dup priority-allowed? [
                    policy-priority-range segment-priority-in-range
                ] [ 2drop 0 ] if
                sched_param <struct-boa> attr-set-schedparam
            ] 3bi
        ] [
            POSIX_SPAWN_SETSCHEDULER bitor
        ] bi*
    ] [ nip ] if* ;

: reset-fd ( fd -- )
    [ F_SETFL 0 fcntl io-error ] [ F_SETFD 0 fcntl io-error ] bi ;

: redirect-fd ( oldfd fd -- )
    2dup = [ 2drop ] [ dup2 io-error ] if ;

: redirect-file ( obj mode fd -- )
    [ [ normalize-path ] dip file-mode open-file ] dip redirect-fd ;

: redirect-file-append ( obj mode fd -- )
    [ drop path>> normalize-path open-append ] dip redirect-fd ;

: redirect-closed ( obj mode fd -- )
    [ drop "/dev/null" ] 2dip redirect-file ;

: redirect ( obj mode fd -- )
    {
        { [ pick not ] [ 3drop ] }
        { [ pick string? ] [ redirect-file ] }
        { [ pick appender? ] [ redirect-file-append ] }
        { [ pick +closed+ eq? ] [ redirect-closed ] }
        { [ pick fd? ] [ [ drop fd>> dup reset-fd ] dip redirect-fd ] }
        [ [ underlying-handle ] 2dip redirect ]
    } cond ;

: ?closed ( obj -- obj' )
    dup +closed+ eq? [ drop "/dev/null" ] when ;

: setup-redirection ( process -- process )
    dup stdin>> ?closed read-flags 0 redirect
    dup stdout>> ?closed write-flags 1 redirect
    dup stderr>> dup +stdout+ eq? [
        drop 1 2 dup2 io-error
    ] [
        ?closed write-flags 2 redirect
    ] if ;

: setup-environment ( spawnattr flags process -- flags )
    dup pass-environment? [
        dup get-environment
    ] when ;

: setup-spawnattr ( process -- spawnattr )
    [ <posix-spawnattr> flags{ } ] dip
    [ setup-process-group ] 3keep nip swapd
    [ setup-scheduler ] 3keep 2drop swap
    [ attr-set-flags ] keepd ;

: setup-file-actions ( process -- file-actions )
    [ <posix-spawn-file-actions> ] dip ;

PRIVATE>

:: spawn-process ( process: process -- pid: pid_t )
    process get-arguments :> ( target argv )
    process setup-spawnattr :> spawnattr
    process setup-file-actions :> file-actions
    process setup-environment :> envp

    target
    spawnattr file-actions
    argv envp
    posix-spawnp ;

!     [ setup-redirection ] [ 4drop 251 _exit ] recover
