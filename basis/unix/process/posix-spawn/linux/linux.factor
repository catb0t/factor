USING: ;

IN: unix.process
! Linux-specific constants should appear here
! the key difference on Linux is that the SETSID and USE_VFORK flags are available,
! but these are *only* available when _GNU_SOURCE is defined
! supporting those effectively turns Linux into two sub-platforms (GNU and non-GNU libc etc)
! which makes the implementation even more complex

! NOTE: uncomment the next lines when nixos and/or musl libc support is added
! SYMBOLS: POSIX_SPAWN_USEVFORK POSIX_SPAWN_SETSID ;
! os [ linux? ] [ nixos? not ] bi and [ "unix.process.posix-spawn.linux.non-nixos" require ] when

! these are added for now but may be rolled back

! NOTE: feature test macro: "__USE_GNU"
CONSTANT: POSIX_SPAWN_SETSID 0x80
CONSTANT: POSIX_SPAWN_USEVFORK 0x40
! end feature test macro "__USE_GNU"

! Note: Feature "Process Scheduling"
CONSTANT: POSIX_SPAWN_SETSCHEDPARAM 0x10
CONSTANT: POSIX_SPAWN_SETSCHEDULER 0x20
! end feature
