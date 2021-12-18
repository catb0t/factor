! Copyright (C) 2020 Cat Stevens and Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data alien.syntax
classes.struct combinators generalizations io.encodings.utf8
kernel layouts libc literals math strings system unix.ffi
unix.process unix.types unix.utilities vocabs vocabs.loader ;

QUALIFIED: sequences

IN: unix.process.posix-spawn

TYPEDEF: void* posix_spawn_file_actions_t
TYPEDEF: void* posix_spawnattr_t

CONSTANT: POSIX_SPAWN_RESETIDS 0x1
CONSTANT: POSIX_SPAWN_SETPGROUP 0x2

CONSTANT: POSIX_SPAWN_SETSIGDEF 0x4
CONSTANT: POSIX_SPAWN_SETSIGMASK 0x8

! NOTE: feature "Process Scheduling"
CONSTANT: POSIX_SPAWN_SETSCHEDPARAM 0x10
CONSTANT: POSIX_SPAWN_SETSCHEDULER 0x20
! end feature

! NOTE: nixos is handled by .linux
<< {
  { [ os linux? ] [ "unix.process.posix-spawn.linux" require ] }
  { [ os macosx? ] [ "unix.process.posix-spawn.macosx" require ] }
} cond >>
! if you remove the following line, the word has not been loaded otherwise. why??
! it is defined in unix.process, provided by unix.process.posix-spawn.linux's "IN: unix.process" declaration and should be in scope already
FROM: unix.process => sigset_t ;

FUNCTION: int posix_spawn ( pid_t* pid, c-string path, posix_spawn_file_actions_t* file_actions, posix_spawnattr_t* attrp, c-string argv[], c-string envp[] )
FUNCTION: int posix_spawn_file_actions_addclose ( posix_spawn_file_actions_t* file_actions, int fd )
FUNCTION: int posix_spawn_file_actions_adddup2 ( posix_spawn_file_actions_t* file_actions, int fd, int newfd )
FUNCTION: int posix_spawn_file_actions_addopen ( posix_spawn_file_actions_t* file_actions, int fd, c-string path, int oflag, mode_t mode )


FUNCTION: int posix_spawn_file_actions_destroy ( posix_spawn_file_actions_t* file_actions )
FUNCTION: int posix_spawn_file_actions_init ( posix_spawn_file_actions_t* file_actions )
FUNCTION: int posix_spawnattr_destroy ( posix_spawnattr_t* attr )
FUNCTION: int posix_spawnattr_getflags ( posix_spawnattr_t* attr, short* flags )
FUNCTION: int posix_spawnattr_getpgroup ( posix_spawnattr_t* attr, pid_t* pgroup )
! NOTE: feature "Process Scheduling"
FUNCTION: int posix_spawnattr_getschedparam ( posix_spawnattr_t* attr, sched_param* schedparam )
FUNCTION: int posix_spawnattr_getschedpolicy ( posix_spawnattr_t* attr, int* schedpolicy )
! end feature


FUNCTION: int posix_spawnattr_getsigdefault ( posix_spawnattr_t* attr, sigset_t* sigdefault )
FUNCTION: int posix_spawnattr_getsigmask ( posix_spawnattr_t* attr, sigset_t* sigmask )
FUNCTION: int posix_spawnattr_init ( posix_spawnattr_t* attr )
FUNCTION: int posix_spawnattr_setflags ( posix_spawnattr_t* attr, short flags )
FUNCTION: int posix_spawnattr_setpgroup ( posix_spawnattr_t* attr, pid_t pgroup )


! NOTE: feature "Process Scheduling"
FUNCTION: int posix_spawnattr_setschedparam ( posix_spawnattr_t* attr, sched_param* schedparam )
FUNCTION: int posix_spawnattr_setschedpolicy ( posix_spawnattr_t* attr, int schedpolicy )
! end feature
FUNCTION: int posix_spawnattr_setsigdefault ( posix_spawnattr_t* attr, sigset_t* sigdefault )
FUNCTION: int posix_spawnattr_setsigmask ( posix_spawnattr_t* attr, sigset_t* sigmask )

FUNCTION: int posix_spawnp ( pid_t* pid, c-string file, posix_spawn_file_actions_t* file_actions, posix_spawnattr_t* attrp, c-string argv[], c-string envp[] )


: posix-spawn ( path: string file_actions: posix_spawn_file_actions_t attrp: posix_spawnattr_t argv envp -- pid_t )
   [ [ 0 pid_t <ref> ] dip utf8 malloc-string ] 4dip
   [ utf8 strings>alien ] bi@
   [
       posix_spawn dup 0 = [ drop ] [ throw-errno ] if
   ] 6 nkeep 5drop pid_t deref ;

: posix-spawnp ( file: string file_actions: posix_spawn_file_actions_t attrp: posix_spawnattr_t argv envp -- pid_t )
    [ [ 0 pid_t <ref> ] dip utf8 malloc-string ] 4dip
    [ utf8 strings>alien ] bi@
    [
        posix_spawnp dup 0 = [ drop ] [ throw-errno ] if
    ] 6 nkeep 5drop pid_t deref ;


: <posix-spawn-file-actions> ( -- file-actions )
    { pointer: posix_spawn_file_actions_t } [
      posix_spawn_file_actions_init
    ] with-out-parameters [ [ throw-errno ] unless-zero ] dip ;

: <posix-spawnattr> ( -- attrp )
    { pointer: posix_spawnattr_t } [
      posix_spawnattr_init
    ] with-out-parameters [ [ throw-errno ] unless-zero ] dip ;

: posix-spawn-args-with-path ( seq -- int )
    [ sequences:first f f ] keep f posix-spawnp ;


: set-file-actions ( actions -- )
    [
      1 "/tmp/foo-log" utf8 malloc-string ! leaks
      flags{ O_WRONLY O_CREAT O_TRUNC } 0o644

      posix_spawn_file_actions_addopen

      [ throw-errno ] unless-zero
    ] keep

    1 2 posix_spawn_file_actions_adddup2
    [ throw-errno ] unless-zero
    ;


: test-posix-spawn ( -- x )
    "/usr/bin/atom"                 ! filename path
    <posix-spawn-file-actions>      ! file actions struct
    [ set-file-actions ] keep       ! configuration
    f                               ! NULL pointer for spawnattr
    { "/home/cat/projects/git/om" } ! argv
    f                               ! envp
    posix_spawnp
    ;
