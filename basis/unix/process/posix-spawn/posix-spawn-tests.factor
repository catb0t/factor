USING: accessors alien.data alien.strings classes.struct
environment formatting io io.encodings.utf8 io.files.temp
io.pathnames kernel libc literals math math.parser namespaces
sequences sets tools.destructors tools.test unix.ffi
unix.process unix.process.posix-spawn unix.signals unix.types ;
IN: unix.process.posix-spawn

: pid-ok? ( pid -- ? )
    [ "Spawn PID:  %d\n" printf ] keep
    valid-pid? ;

: set-file-actions ( actions -- )
    [
        [
            1
            current-directory get "posix-spawn-tests-log" append-path
            flags{ O_WRONLY O_CREAT O_TRUNC } 0o644

            actions-add-open
        ] with-temp-directory
    ] keep

    1 2 actions-add-dup2 ;

: set-spawnattr ( attr -- )
    flags{ POSIX_SPAWN_RESETIDS POSIX_SPAWN_SETPGROUP }
    [ attr-set-flags ] keepd
    1000
    [ attr-set-pgroup ] keepd
    20 sched_param <struct-boa>
    [ attr-set-schedparam ] keepd
    <sigset> [ sigfillset check-posix ] keep
    [ attr-set-sigdefault ] keepd
    <sigset> [ 11 sigaddset check-posix ] keep
    attr-set-sigmask ;

{ t } [

    flags{ POSIX_SPAWN_RESETIDS POSIX_SPAWN_SETPGROUP }
    <posix-spawnattr>

    over [ attr-set-flags ] keepd
    attr-get-flags

    =

] unit-test

{ t } [

    1000
    <posix-spawnattr>

    over [ attr-set-pgroup ] keepd
    attr-get-pgroup

    =

] unit-test


{ t } [

    20 sched_param <struct-boa>
    <posix-spawnattr>

    over [ attr-set-schedparam ] keepd
    attr-get-schedparam

    [ sched_priority>> ] bi@ =

] unit-test

{
    flags{ POSIX_SPAWN_RESETIDS POSIX_SPAWN_SETPGROUP }
    1000
    S{ sched_param f 20 }
} [
    <posix-spawnattr>
    [ set-spawnattr ] keep
    [ attr-get-flags ]
    [ attr-get-pgroup ]
    [ attr-get-schedparam ] tri
] unit-test

{ t } [

    "/bin/sh"                 ! filename path
    f                               ! NULL pointer for file_actions
    f                               ! NULL pointer for attr
    {
        "/bin/sh"
        "-c"
        "echo 2"
    }                               ! argv
    (os-envs)                       ! envp

    posix-spawn pid-ok?

] unit-test

{ t } [

    "/bin/sh"                 ! filename path
    <posix-spawn-file-actions>      ! file actions struct
    [ set-file-actions ] keep       ! configuration
    f                               ! NULL pointer for spawnattr
    {
        "/bin/sh"
        "-c"
        "echo 2"
    }                               ! argv
    (os-envs)                       ! envp

    posix-spawn pid-ok?

] unit-test

{ t } [
    "/bin/sh"                 ! filename path
    <posix-spawn-file-actions>      ! file actions struct
    [ set-file-actions ] keep       ! configuration
    f                               ! NULL pointer for spawnattr
    {
        "/bin/sh"
        "-c"
        "echo 2"
    }                               ! argv
    (os-envs)                       ! envp

    posix-spawn* pid-ok?
] unit-test

{ t } [
    { "/usr/bin/cat" "/tmp/posix-spawn-tests-log" }
    posix-spawn-args-by-file
    pid-ok?
] unit-test

{ t } [
    { "/bin/ls" "-al" }
    posix-spawn-args-by-file
    pid-ok?
] unit-test

[
    { "cat" "/tmp/posix-spawn-tests-log" }
    posix-spawn-args-by-file
    pid-ok?
] must-fail

{ t } [
    { "/usr/bin/cat" "/tmp/posix-spawn-tests-log" }
    posix-spawn-args-with-path
    pid-ok?
] unit-test

{ t } [
    { "ls" "-a" "-l" }
    posix-spawn-args-with-path
    pid-ok?
] unit-test
