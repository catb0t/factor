USING: alien alien.c-types alien.data alien.syntax
environment.unix generalizations inspector io io.encodings.utf8
kernel layouts libc math math.functions math.order sequences
simple-tokenizer strings system unix unix.types unix.utilities ;
IN: unix.process

! Low-level Unix process launching utilities. These are used
! to implement io.launcher on Unix. User code should use
! io.launcher instead.

FUNCTION: pid_t fork ( )

: call-fork ( -- pid ) [ fork ] unix-system-call ;

FUNCTION: int execv ( c-string path, c-string* argv )
FUNCTION: int execvp ( c-string path, c-string* argv )
FUNCTION: int execve ( c-string path, c-string* argv, c-string* envp )

: exec ( pathname argv -- int )
    [ utf8 malloc-string ] [ utf8 strings>alien ] bi* execv ;

: exec-with-path ( filename argv -- int )
    [ utf8 malloc-string ] [ utf8 strings>alien ] bi* execvp ;

: exec-with-env ( filename argv envp -- int )
    [ utf8 malloc-string ]
    [ utf8 strings>alien ]
    [ utf8 strings>alien ] tri* execve ;

: exec-args ( seq -- int )
    [ first ] keep exec ;

: exec-args-with-path ( seq -- int )
    [ first ] keep exec-with-path ;

: exec-args-with-env  ( seq seq -- int )
    [ [ first ] keep ] dip exec-with-env ;

: with-fork ( child parent -- )
    [ call-fork ] 2dip if-zero ; inline

FUNCTION: int kill ( pid_t pid, int sig )
FUNCTION: int raise ( int sig )

CONSTANT: PRIO_PROCESS 0
CONSTANT: PRIO_PGRP 1
CONSTANT: PRIO_USER 2

CONSTANT: PRIO_MIN -20
CONSTANT: PRIO_MAX 20

! which/who = 0 for current process
FUNCTION: int getpriority ( int which, int who )
FUNCTION: int setpriority ( int which, int who, int prio )

: set-priority ( n -- )
    [ 0 0 ] dip setpriority io-error ;

! Flags for waitpid

CONSTANT: WNOHANG   1
CONSTANT: WUNTRACED 2

CONSTANT: WSTOPPED   2
CONSTANT: WEXITED    4
CONSTANT: WCONTINUED 8
CONSTANT: WNOWAIT    0x1000000

! Examining status

: WTERMSIG ( status -- value )
    0x7f bitand ; inline

: WIFEXITED ( status -- ? )
    WTERMSIG 0 = ; inline

: WEXITSTATUS ( status -- value )
    0xff00 bitand -8 shift ; inline

: WIFSIGNALED ( status -- ? )
    0x7f bitand 1 + -1 shift 0 > ; inline

: WCOREFLAG ( -- value )
    0x80 ; inline

: WCOREDUMP ( status -- ? )
    WCOREFLAG bitand 0 = not ; inline

: WIFSTOPPED ( status -- ? )
    0xff bitand 0x7f = ; inline

: WSTOPSIG ( status -- value )
    WEXITSTATUS ; inline

FUNCTION: pid_t wait ( int* status )
FUNCTION: pid_t waitpid ( pid_t wpid, int* status, int options )

: check-posix ( n -- )
    [ (throw-errno) ] unless-zero ;

: with-check-posix ( ..a quot: ( ..a -- n ) -- b.. )
    dup [ call ] dip swap [ drop ] [
        [ "Checked POSIX quotation failed" print nl describe ] dip
        (throw-errno)
    ] if-zero ; inline

<PRIVATE
HOOK: (pid-limit) os ( -- max-pid )

! PIDs are strictly less than PID_MAX on macosx
M: macosx (pid-limit)
    99,998 ;

! PIDs may include PID_MAX on freebsd
M: freebsd (pid-limit)
    99,999 ;

! PIDS are limited to 2^15 on linux32, and 2^22 on linux64
M: linux (pid-limit)
    2 64bit? 22 15 ? ^ ;

PRIVATE>

: valid-pid? ( pid -- ? )
    1 (pid-limit) between? ;
