USING: alien alien.c-types alien.data alien.syntax generalizations
strings unix.types ;
QUALIFIED: sequences
IN: unix.process.posix-spawn

LIBRARY: spawn

CONSTANT: POSIX_SPAWN_RESETIDS 0x1
CONSTANT: POSIX_SPAWN_SETPGROUP 0x2

CONSTANT: POSIX_SPAWN_SETSIGDEF 0x4
CONSTANT: POSIX_SPAWN_SETSIGMASK 0x8

! NOTE: feature "Process Scheduling"
CONSTANT: POSIX_SPAWN_SETSCHEDPARAM 0x10
CONSTANT: POSIX_SPAWN_SETSCHEDULER 0x20
! end feature

! POSIX says these are opaque structs and have no reliable members
C-TYPE: posix_spawn_file_actions_t
C-TYPE: posix_spawnattr_t
! temporary opaque definitions
C-TYPE: sched_param
C-TYPE: sigset_t

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

: posix-spawn ( path: string file_actions: posix_spawn_file_actions_t attrp: posix_spawnattr_t argv: sequences:sequence envp: sequences:sequence -- return: int pid: pid_t )
    ! { pointer: pid_t } [ posix_spawn ] with-out-parameters ;
    [ 0 pid_t <ref> ] 5 ndip [ posix_spawn ] 5 nkeep pid_t deref ;

: posix-spawnp ( file: string file_actions: posix_spawn_file_actions_t attrp: posix_spawnattr_t argv: sequences:sequence envp: sequences:sequence -- return: int pid: pid_t )
    ! { pointer: pid_t } [ posix_spawnp ] with-out-parameters ;
    [ 0 pid_t <ref> ] 5 ndip [ posix_spawnp ] 5 nkeep pid_t deref ;

: <posix-spawn-file-actions> ( -- return )
    { pointer: posix_spawn_file_actions_t } [ posix_spawn_file_actions_init ] with-out-parameters ;

: <posix-spawnattr> ( -- return )
    { pointer: posix_spawnattr_t } [ posix_spawnattr_init ] with-out-parameters ;
