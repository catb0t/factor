! Copyright (C) 2022 Cat Stevens.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.launcher
io.launcher.unix.posix-spawn.private kernel math system
unix.process unix.process.posix-spawn unix.scheduler unix.types ;
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
    "'Edge' priorities, (those at the edge of the range like " { $link +highest-priority+ } ") will give the maximum or minimum from the range, respectively. Otherwise, the output will be a valid value somewhere between " { $snippet "low" } " and " { $snippet "high" } ", scaled to match the input priority."
}
;

HELP: setup-scheduler
{ $values { "spawnattr" posix_spawnattr_t } { "flags" integer } { "process" process } }
{ $contract "Set scheduler policy and priority values in " { $snippet "spawnattr" } " based on the " { $snippet "priority" } " slot of the given " { $snippet "process" } ". The " { $snippet "flags" } " value is updated based on the values chosen." }

{ $description
    "On " { $link linux } " and " { $link freebsd } ", the implementation sets the " { $snippet "policy" } " (schedpolicy) of the input " { $snippet "spawnattr" } " to the Scheduler Policy picked based on the input process priority. It also sets " { $snippet "spawnattr->sched_param->sched_priority" } " to either " { $snippet "0" } " (for non-realtime policies) or a concrete integer priority as found by " { $link segment-priority-in-range } "."
    $nl
    "Additionally on " { $link linux } " and " { $link freebsd } ", the " { $link POSIX_SPAWN_SETSCHEDULER } " flag is set on the output flags value in all cases, which causes us to implement only those POSIX behaviours that are supported by the " { $link "io.launcher" } " / " { $link <process> } " APIs."
    $nl
    "Finally, if the " { $snippet "priority" } " slot of " { $snippet "process" } " is " { $link POSTPONE: f } ", nothing will be done by the " { $link linux } " and " { $link freebsd } " implementation and you are at the will of the system's process scheduler."
    $nl
    "Note that CPU \"affinity\" for a process as set by " { $snippet "nice(2)" } " is distinct from process " { $emphasis "priority" } "."
    $nl
    "On " { $link linux } ", process priority is within the closed range " { $snippet "[1,99]" } ", but this range should be verified with the " { $link sched_get_priority_min } " and " { $link sched_get_priority_max } " functions from " { $vocab-link "unix.scheduler" } " (" { $snippet "<sched.h>" } ") (for example, the upper bound is " { $snippet "127" } " on " { $link freebsd } ")."
    $nl
    { $link +realtime-priority+ } " and " { $link +highest-priority+ } " will result in a FIFO Scheduler Policy, because that is the most aggressive policy." { $link +low-priority+ } " and " { $link +high-priority+ } " are middle-ish policies on either side of " { $link +normal-priority+ } ", and we give them the Round Robin Scheduler in order to remain fair to other similar processes in their priority list."
    $nl
    { $link +lowest-priority+ } " will give a value of " { $link SCHED_IDLE } " on Linux, and " { $link SCHED_RR } " with minimum priority on " { $link freebsd } ", as there is no " { $link SCHED_IDLE } " on FreeBSD."
    $nl
    { $link +normal-priority+ } " will be " { $link SCHED_OTHER } ", which is the default on Linux and BSD. " { $link SCHED_IDLE } ", " { $link SCHED_OTHER } ", and all non-realtime scheduler policies require " { $snippet "sched_param->priority" } "(i.e. " { $snippet "sched_param sched_priority>>" } ") to be " { $snippet "0" } " because the priority will be completely determined by the kernel scheduler in that case."
}
{ $warning { $link macosx } " does not implement POSIX Process Scheduling natively, but has similarly low-level APIs that can be used here instead." }
{ $side-effects "spawnattr" }
{ $notes
    "See also " { $snippet "man 7 sched" } "."
    $nl
    "On macOS, this word should use the existing Darwin-specific functions to provide similar behaviour to POSIX-style priority scheduling for " { $link <process> } "."
    $nl
    "Since the word does not execute in the spawned process, there is not much the caller can do without the same abilities that exist on Linux and other BSDs. The parent process needs to wait until the child process is posix_spawn'd, and then " { $snippet "nice(2)" } " its PID, but that isn't terribly robust (what if the parent needs to exist ASAP?), and " { $snippet "nice" } " (i.e. affinity) is not the same as process priority."
}
;

HELP: spawn-process
{ $values
    { "process" process }
    { "pid" pid_t }
}
{ $description "" } ;

ARTICLE: "io.launcher.unix.posix-spawn" "io.launcher.unix.posix-spawn"
"The " { $vocab-link "io.launcher.unix.posix-spawn" } " vocabulary implements the " { $snippet "posix_spawn(3)" } " backend for " { $vocab-link "io.launcher.unix" } "."
;

ABOUT: "io.launcher.unix.posix-spawn"
