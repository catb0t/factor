USING: alien alien.c-types alien.data alien.syntax
classes.struct generalizations io.encodings.utf8 kernel layouts
libc literals math strings system unix.types unix.utilities ;
QUALIFIED: sequences
IN: unix.process.posix-spawn

CONSTANT: POSIX_SPAWN_RESETIDS 0x1
CONSTANT: POSIX_SPAWN_SETPGROUP 0x2

CONSTANT: POSIX_SPAWN_SETSIGDEF 0x4
CONSTANT: POSIX_SPAWN_SETSIGMASK 0x8

! NOTE: feature "Process Scheduling"
CONSTANT: POSIX_SPAWN_SETSCHEDPARAM 0x10
CONSTANT: POSIX_SPAWN_SETSCHEDULER 0x20
! end feature

! NOTE: feature test macro: "__USE_GNU"
! NOTE: uncomment the conditional when nixos support is merged, as nixos does not
! use a GNU toolchain
! << os [ linux? ] [ nixos? not ] bi and [
CONSTANT: POSIX_SPAWN_USEVFORK 0x40
CONSTANT: POSIX_SPAWN_SETSID 0x80
! ] [ SYMBOLS: POSIX_SPAWN_USEVFORK POSIX_SPAWN_SETSID ; ] if >>

! temporary opaque definitions

! POSIX says these are opaque structs and have no reliable members
! linux's <spawn.h> defines them as structs, macos does not
! sigset from <bits/types/sigset_t.h>
! sched_param from <bits/types/struct_sched_param.h>
<< os linux? [
    STRUCT: _close_action { fd int } ;
    STRUCT: _dup2_action { fd int } { newfd int } ;
    STRUCT: _open_action { fd int } { path c-string } { oflag int } { mode mode_t } ;
    STRUCT: _chdir_action { path c-string } ;
    STRUCT: _fchdir_action { fd int } ;
    UNION-STRUCT: _spawn_action_action
        { close _close_action }
        { dup2_action _dup2_action }
        { open_action _open_action }
        { chdir_action _chdir_action }
        { fchdir_action _fchdir_action } ;
    ENUM: _spawn_action_tag
        spawn_do_close
        spawn_do_dup2
        spawn_do_open
        spawn_do_chdir
        spawn_do_fchdir ;
    STRUCT: spawn_action
        { tag _spawn_action_tag }
        { action _spawn_action_action } ;
    STRUCT: sched_param
        { sched_priority int } ;
    CONSTANT: SIGSET_NUM_WORDS $[ 1024 1 cells 8 * / ]
    STRUCT: sigset_t { val ulong* } ;
    STRUCT: posix_spawnattr_t
        { flags short }
        { pgrp pid_t }
        { sd sigset_t }
        { ss sigset_t }
        ! struct sched_param __sp;
        { sp sched_param }
        { policy int } ;
        ! int __pad[16];
        ! { (pad) int* read-only initial: $[ 16 0 <repetition> B{ } like int <ref> ] } ;

    STRUCT: posix_spawn_file_actions_t
        { allocated int }
        { used int }
        ! struct spawn_action *__actions;
        { actions spawn_action* } ;
        ! int __pad[16];
        ! { (pad) int* read-only initial: $[ 16 0 <repetition> B{ } like int <ref> ] } ;
] [
    C-TYPE: sched_param
    C-TYPE: sigset_t
    C-TYPE: posix_spawn_file_actions_t
    C-TYPE: posix_spawnattr_t
] if >>

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
FUNCTION: int posix_spawnattr_setsigmask ( posix_spawnattr_t* attr, sigset_t* signask )

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


: <posix-spawn-file-actions> ( -- return file-actions )
    { pointer: posix_spawn_file_actions_t } [ posix_spawn_file_actions_init ] with-out-parameters ;

: <posix-spawnattr> ( -- return attrp )
    { pointer: posix_spawnattr_t } [ posix_spawnattr_init ] with-out-parameters ;

: posix-spawn-args-with-path ( seq -- int )
    [ sequences:first f f ] keep f posix-spawnp ;
