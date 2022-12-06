! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.launcher
io.launcher.unix.posix-spawn.private kernel math unix.types ;
IN: io.launcher.unix.posix-spawn

HELP: setup-process-group
{ $values
    { "spawnattr" posix_spawnattr_t }
    { "flags" integer }
    { "process" process }
}
{ $description "TODO:: SETPGROUP and attr_setpgroup(n != 0) - the child's process group shall be as specified in the spawn-pgroup" } ;

HELP: segment-priority-in-range
{ $values { "priority" object } { "high" integer } { "low" integer } { "priority-integer" integer } }
{ $description
    "Select a concrete priority value within the range (inclusive), based on the provided symbolic priority (such as " { $link +low-priority+ } "."
    $nl
    "'Edge' priorities, (those at the edge of the range like " { $link +highest-priority+ } ") will give the maximum or minimum from the range, respectively. Otherwise, the output will be a valid value somewhere between " { $snippet "low" } " and " { $snippet "high" } ", scaled to match the input priority." }
;

HELP: setup-scheduler
{ $values { "spawnattr" posix_spawnattr_t } { "flags" integer } { "process" process } }
{ $contract " " }
;

HELP: spawn-process
{ $values
    { "process" process }
    { "pid" pid_t }
}
{ $description "" } ;

ARTICLE: "io.launcher.unix.posix-spawn" "io.launcher.unix.posix-spawn"
{ $vocab-link "io.launcher.unix.posix-spawn" }
;

ABOUT: "io.launcher.unix.posix-spawn"
