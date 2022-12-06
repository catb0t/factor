! Copyright (C) 2020 Cat Stevens and Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: environment help help.markup help.syntax strings unix.ffi
unix.process unix.process.posix-spawn
unix.process.posix-spawn.private unix.types ;
IN: unix.process.posix-spawn

ABOUT: "unix.process.posix-spawn"

ARTICLE: "unix.process.posix-spawn" "Launching processes with posix_spawn"

"The " { $vocab-link "unix.process.posix-spawn" } " vocabulary provides low-level wrappers for " { $snippet "posix_spawn(3)" } " and similar functions from " { $snippet "spawn.h" } " on systems with POSIX compatibility."
$nl

{ $snippet "posix_spawn()" } " spawns a new process by executing the file found at the pathname given in its first parameter. With " { $snippet "posix_spawnp()" } ", the system will search for the file in the " { $snippet "PATH" } " environment variable, just like " { $link execvp } "."
$nl

{ $snippet "posix_spawn(3)" } " uses much less memory than " { $snippet "fork(2)" } " because it does not copy the parent process' memory, and is more logical when the forked process memory is often going to be overwritten by an immediate call to the " { $snippet "exec(3)" } " family of functions anyway."
$nl

"Refer to " { $snippet "man 3 posix_spawn" } ", etc for complete POSIX feature documentation."
$nl

"Ease-of-use words with the current " { $link (os-envs) } " and no other configuration:"
{ $subsections
    posix-spawn-args-with-path
    posix-spawn-args-by-file
}

"Wrappers that call destructors on their " { $snippet "file_actions" } " and " { $snippet "spawnattr" } " inputs:"
{ $subsections
    posix-spawn
    posix-spawnp
}

"Wrappers that don't call destructors. These will leak memory quickly if the input " { $snippet "spawnattr" } " and " { $snippet "file_actions" } " objects are not properly disposed (" { $link "destructors" } "). " $nl " They are provided so that the input objects can be reused between calls:"
{ $subsections
    posix-spawn*
    posix-spawnp*
}

"File descriptor control for the new process launched by " { $snippet "posix_spawn()" } " or " { $snippet "posix_spawnp()" } " is configured by the " { $snippet "file_actions" } " parameter:"
{ $subsections
    <posix-spawn-file-actions>
    actions-add-open
    actions-add-close
    actions-add-dup2
}

"Process control for the new process is configured by the " { $snippet "spawnattr" } " parameter:"
{ $subsections
    <posix-spawnattr>

    attr-get-flags
    attr-set-flags

    attr-get-pgroup
    attr-set-pgroup

    attr-get-sigdefault
    attr-set-sigdefault

    attr-get-sigmask
    attr-set-sigmask

    attr-get-schedparam
    attr-set-schedparam

    attr-get-schedpolicy
    attr-set-schedpolicy
}

"Relevant values and types are provided:"
{ $subsections
    POSIX_SPAWN_RESETIDS
    POSIX_SPAWN_SETPGROUP
    POSIX_SPAWN_SETSIGDEF
    POSIX_SPAWN_SETSIGMASK
    POSIX_SPAWN_SETSCHEDPARAM
    POSIX_SPAWN_SETSCHEDULER

} { $subsections
    posix_spawn_file_actions_t
    posix_spawnattr_t
    sched_param
} ;

HELP: posix-spawn
    { $inputs
        { "path" string } { "file_actions" posix_spawn_file_actions_t }
        { "attr" posix_spawnattr_t } { "argv" { $sequence string } }
        { "envp" { $sequence string } }
    }
    { $outputs { "pid" pid_t } }

    { $description
      "Common implementation for " { $link posix-spawn } " and " { $link posix-spawnp } "."
    } ;
