! Copyright (C) 2020, 2022 Cat Stevens and Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data alien.destructors
alien.strings alien.syntax arrays classes.struct combinators
destructors environment generalizations io.encodings.utf8 kernel
layouts libc literals math strings system unix.ffi unix.process
unix.types unix.utilities unix.signals vocabs vocabs.loader words ;

FROM: alien.c-types => short ;
QUALIFIED: sequences

IN: unix.process.posix-spawn


CONSTANT: POSIX_SPAWN_RESETIDS 0x1
CONSTANT: POSIX_SPAWN_SETPGROUP 0x2

CONSTANT: POSIX_SPAWN_SETSIGDEF 0x4
CONSTANT: POSIX_SPAWN_SETSIGMASK 0x8

! Note: Feature "Process Scheduling"
CONSTANT: POSIX_SPAWN_SETSCHEDPARAM 0x10
CONSTANT: POSIX_SPAWN_SETSCHEDULER 0x20
! end feature

<< {
  { [ os linux? ] [ "unix.process.posix-spawn.linux" require ] }
  { [ os macosx? ] [ "unix.process.posix-spawn.macosx" require ] }
} cond >>

FUNCTION: int posix_spawn ( pid_t* pid, c-string path, posix_spawn_file_actions_t* file_actions, posix_spawnattr_t* attrp, c-string argv[], c-string envp[] )
FUNCTION: int posix_spawnp ( pid_t* pid, c-string file, posix_spawn_file_actions_t* file_actions, posix_spawnattr_t* attrp, c-string argv[], c-string envp[] )

! on Linux, not calling _destroy leaks memory
! it's implementation-defined whether the _init will allocate memory (since the object is an out parameter, it could just stack-allocate the struct)
FUNCTION: int posix_spawn_file_actions_init ( posix_spawn_file_actions_t* file_actions )
FUNCTION: int posix_spawn_file_actions_destroy ( posix_spawn_file_actions_t* file_actions )
DESTRUCTOR: posix_spawn_file_actions_destroy

FUNCTION: int posix_spawn_file_actions_addopen ( posix_spawn_file_actions_t* file_actions, int fd, c-string path, int oflag, mode_t mode )
FUNCTION: int posix_spawn_file_actions_addclose ( posix_spawn_file_actions_t* file_actions, int fd )
FUNCTION: int posix_spawn_file_actions_adddup2 ( posix_spawn_file_actions_t* file_actions, int fd, int newfd )

! on Linux, not calling _destroy leaks memory
! it's implementation-defined whether the _init will allocate memory
FUNCTION: int posix_spawnattr_init ( posix_spawnattr_t* attr )
FUNCTION: int posix_spawnattr_destroy ( posix_spawnattr_t* attr )
DESTRUCTOR: posix_spawnattr_destroy

FUNCTION: int posix_spawnattr_getflags ( posix_spawnattr_t* attr, short* flags )
FUNCTION: int posix_spawnattr_setflags ( posix_spawnattr_t* attr, short flags )

FUNCTION: int posix_spawnattr_getpgroup ( posix_spawnattr_t* attr, pid_t* pgroup )
FUNCTION: int posix_spawnattr_setpgroup ( posix_spawnattr_t* attr, pid_t pgroup )

FUNCTION: int posix_spawnattr_getsigdefault ( posix_spawnattr_t* attr, sigset_t* sigdefault )
FUNCTION: int posix_spawnattr_setsigdefault ( posix_spawnattr_t* attr, sigset_t* sigdefault )

FUNCTION: int posix_spawnattr_getsigmask ( posix_spawnattr_t* attr, sigset_t* sigmask )
FUNCTION: int posix_spawnattr_setsigmask ( posix_spawnattr_t* attr, sigset_t* sigmask )

! NOTE: feature "Process Scheduling"
FUNCTION: int posix_spawnattr_getschedparam ( posix_spawnattr_t* attr, sched_param* schedparam )
FUNCTION: int posix_spawnattr_setschedparam ( posix_spawnattr_t* attr, sched_param* schedparam )

FUNCTION: int posix_spawnattr_getschedpolicy ( posix_spawnattr_t* attr, int* schedpolicy )
FUNCTION: int posix_spawnattr_setschedpolicy ( posix_spawnattr_t* attr, int schedpolicy )
! end feature

<PRIVATE
HOOK: (posix-spawn-file-actions-new) os ( -- file-actions )

M: freebsd (posix-spawn-file-actions-new)
    f posix_spawn_file_actions_t <ref> ;

M: linux (posix-spawn-file-actions-new)
    posix_spawn_file_actions_t <struct> ;

M: macosx (posix-spawn-file-actions-new)
    f posix_spawn_file_actions_t <ref> ;
PRIVATE>

: <posix-spawn-file-actions> ( -- file-actions )
    (posix-spawn-file-actions-new) [
        posix_spawn_file_actions_init check-posix
    ] keep ;

: actions-add-open ( file_actions: posix_spawn_file_actions_t fd: int path: string oflag: int mode: mode_t -- )
    [ utf8 string>alien ] 2dip posix_spawn_file_actions_addopen check-posix ;

: actions-add-close ( file_actions: posix_spawn_file_actions_t fd: int -- )
    posix_spawn_file_actions_addclose check-posix ;

: actions-add-dup2 ( file_actions: posix_spawn_file_actions_t fd: int newfd: int -- )
    posix_spawn_file_actions_adddup2 check-posix ;

<PRIVATE
HOOK: (posix-spawnattr-new) os ( -- attr )

M: freebsd (posix-spawnattr-new)
    f posix_spawnattr_t <ref> ;

M: macosx (posix-spawnattr-new)
    f posix_spawnattr_t <ref> ;

M: linux (posix-spawnattr-new)
    posix_spawnattr_t <struct> ;
PRIVATE>

: <posix-spawnattr> ( -- attr )
    (posix-spawnattr-new) [
        posix_spawnattr_init check-posix
    ] keep ;

: attr-get-flags ( attr: posix_spawnattr_t -- flags: short )
    0 short <ref> [
        posix_spawnattr_getflags check-posix
    ] keep short deref ;

: attr-set-flags ( attr: posix_spawnattr_t flags: short -- )
    posix_spawnattr_setflags check-posix ;

: attr-get-pgroup ( attr: posix_spawnattr_t -- pgroup: pid_t )
    0 pid_t <ref> [
        posix_spawnattr_getpgroup check-posix
    ] keep pid_t deref ;

: attr-set-pgroup ( attr: posix_spawnattr_t pgroup: pid_t -- )
    posix_spawnattr_setpgroup check-posix ;

: attr-get-sigdefault ( attr: posix_spawnattr_t -- sigdefault: sigset_t )
    <sigset> [
        posix_spawnattr_getsigdefault check-posix
    ] keep ;

: attr-set-sigdefault ( attr: posix_spawnattr_t sigdefault: sigset_t -- )
    posix_spawnattr_setsigdefault check-posix ;

: attr-get-sigmask ( attr: posix_spawnattr_t -- sigmask: sigset_t )
    <sigset> [
        posix_spawnattr_getsigmask check-posix
    ] keep ;

: attr-set-sigmask ( attr: posix_spawnattr_t sigmask: sigset_t -- )
    posix_spawnattr_setsigmask check-posix ;

! NOTE: feature "Process Scheduling"
: attr-get-schedparam ( attr: posix_spawnattr_t -- schedparam: sched_param )
    sched_param <struct> [
        posix_spawnattr_getschedparam check-posix
    ] keep ;

: attr-set-schedparam ( attr: posix_spawnattr_t schedparam: sched_param -- )
    posix_spawnattr_setschedparam check-posix ;

: attr-get-schedpolicy ( attr: posix_spawnattr_t -- schedpolicy: int )
    0 int <ref> [
        posix_spawnattr_getschedpolicy check-posix
    ] keep int deref ;

: attr-set-schedpolicy ( attr: posix_spawnattr_t schedpolicy: int -- )
    posix_spawnattr_setschedpolicy check-posix ;
! end feature

<PRIVATE

: (posix-spawn) ( path: string file_actions: posix_spawn_file_actions_t attrp: posix_spawnattr_t argv envp func: word -- pid: pid_t )
    [
      [ [ 0 pid_t <ref> ] dip utf8 string>alien ] 4dip
      [ utf8 strings>alien ] bi@
    ] dip
    [
        execute( pid file fa sa argv env -- e )
        check-posix
    ] 7 nkeep 6 ndrop pid_t deref ; inline

: (posix-spawn-with-destructors) ( path: string file_actions: posix_spawn_file_actions_t attrp: posix_spawnattr_t argv envp func: word -- pid: pid_t )
    [
      [
        [
            [ dup [ &posix_spawn_file_actions_destroy ] when ]
            [ dup [ &posix_spawnattr_destroy ] when ] bi*
            [ [ 0 pid_t <ref> ] dip utf8 string>alien ] 2dip
        ] 2dip
        [ utf8 strings>alien ] bi@
      ] dip
      [
          execute( pid file fa sa argv env -- e )
          check-posix
      ] 7 nkeep 6 ndrop pid_t deref
    ] with-destructors ; inline

: (setup-spawn-args) ( args -- target actions attr args envp )
    [ sequences:first f f ] keep (os-envs) ; inline

PRIVATE>

: posix-spawn* ( path: string file_actions: posix_spawn_file_actions_t attrp: posix_spawnattr_t argv envp -- pid_t )
    \ posix_spawn (posix-spawn) ;

: posix-spawnp* ( file: string file_actions: posix_spawn_file_actions_t attrp: posix_spawnattr_t argv envp -- pid_t )
    \ posix_spawnp (posix-spawn) ;

: posix-spawn ( path: string file_actions: posix_spawn_file_actions_t attrp: posix_spawnattr_t argv envp -- pid_t )
    \ posix_spawn (posix-spawn-with-destructors) ;

: posix-spawnp ( file: string file_actions: posix_spawn_file_actions_t attrp: posix_spawnattr_t argv envp -- pid_t )
    \ posix_spawnp (posix-spawn-with-destructors) ;


: posix-spawn-args-by-file ( args -- pid )
    (setup-spawn-args) posix-spawn ;

: posix-spawn-args-with-path ( args -- pid )
    (setup-spawn-args) posix-spawnp ;
