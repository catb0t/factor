! Copyright (C) 2011 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.syntax assocs
classes.struct io kernel math namespaces sequences system
threads unix.process unix.types ;
IN: unix.signals

FUNCTION: int sigemptyset ( sigset_t* set )
FUNCTION: int sigfillset ( sigset_t* set )
FUNCTION: int sigaddset ( sigset_t* set, int signum )
FUNCTION: int sigdelset ( sigset_t* set, int signum )
FUNCTION: int sigismember ( sigset_t* set, int signum )

<PRIVATE
HOOK: (sigset-new) os ( -- set )

M: freebsd (sigset-new)
    0 sigset_t <ref> ;

M: macos (sigset-new)
    0 sigset_t <ref> ;

M: linux (sigset-new)
    sigset_t <struct> ;
PRIVATE>

: <sigset> ( -- set )
    (sigset-new) [ sigemptyset check-posix ] keep ;

CONSTANT: signal-names
{
    "SIGHUP" "SIGINT" "SIGQUIT" "SIGILL" "SIGTRAP" "SIGABRT"
    "SIGEMT" "SIGFPE" "SIGKILL" "SIGBUS" "SIGSEGV" "SIGSYS"
    "SIGPIPE" "SIGALRM" "SIGTERM" "SIGURG" "SIGSTOP" "SIGTSIP"
    "SIGCONT" "SIGCHLD" "SIGTTIN" "SIGTTOU" "SIGIO" "SIGXCPU"
    "SIGXFSZ" "SIGVTALRM" "SIGPROF" "SIGWINCH" "SIGINFO"
    "SIGUSR1" "SIGUSR2"
}

TUPLE: signal n ;

GENERIC: signal-name ( obj -- str/f )

M: signal signal-name n>> signal-name ;

M: integer signal-name 1 - signal-names ?nth ;

: signal-name. ( n -- )
    signal-name [ " (" ")" surround write ] when* ;

<PRIVATE

SYMBOL: signal-handlers

signal-handlers [ H{ } ] initialize

: dispatch-signal ( sig -- )
    signal-handlers get-global at [ in-thread ] each ;

PRIVATE>

: add-signal-handler ( handler: ( -- ) sig -- )
    signal-handlers get-global push-at ;

: remove-signal-handler ( handler sig -- )
    signal-handlers get-global at [ remove-eq! ] when* drop ;

SYMBOL: dispatch-signal-hook

[ dispatch-signal ] dispatch-signal-hook set-global
