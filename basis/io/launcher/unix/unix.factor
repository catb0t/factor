! Copyright (C) 2007, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data assocs combinators
continuations environment fry io.backend io.backend.unix
io.files.private io.files.unix io.launcher io.launcher.private
io.launcher.unix.posix-spawn io.pathnames io.ports kernel libc math
namespaces sequences simple-tokenizer strings system unix
unix.ffi unix.process ;
QUALIFIED-WITH: unix.signals sig
IN: io.launcher.unix

M: unix (current-process) getpid ;

M: unix (run-process)
    spawn-process ;

M: unix (kill-process)
    [ handle>> SIGTERM ] [ group>> ] bi {
        { +same-group+ [ kill ] }
        { +new-group+ [ killpg ] }
        { +new-session+ [ killpg ] }
    } case io-error ;

: find-process ( handle -- process )
    processes get keys [ handle>> = ] with find nip ;

: code>status ( code -- obj )
    dup WIFSIGNALED [ WTERMSIG sig:signal boa ] [ WEXITSTATUS ] if ;

M: unix (wait-for-processes)
    { int } [ -1 swap WNOHANG waitpid ] with-out-parameters
    swap dup 0 <= [
        2drop t
    ] [
        find-process dup
        [ swap code>status notify-exit f ] [ 2drop f ] if
    ] if ;
