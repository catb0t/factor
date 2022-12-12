USING: ;

IN: unix.process
! FreeBSD specific stuff should appear here

! Note: Feature "Process Scheduling"
CONSTANT: POSIX_SPAWN_SETSCHEDPARAM 0x10
CONSTANT: POSIX_SPAWN_SETSCHEDULER 0x20
! end feature
