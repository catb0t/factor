! Copyright 2022 Doug Coleman and Cat Stevens.
IN: unix.process

! See <https://opensource.apple.com/source/xnu/xnu-7195.81.3/bsd/sys/spawn_internal.h.auto.html>

! XNU's posix_spawn has a lot of extra features like "port action" and "coalition"
! and "MAC Policy Extensions" which are far too confusing to implement until they
! are absolutely needed

! these are Darwin specific:

CONSTANT:	POSIX_SPAWN_SETEXEC         0x0040
CONSTANT: POSIX_SPAWN_START_SUSPENDED 0x0080

! macosx does not support the POSIX Process Scheduling feature
! however, we do define the names so that scheduling code for "unix"
! platforms does not fail to compile on macosx

CONSTANT: POSIX_SPAWN_SETSCHEDULER     f
CONSTANT: POSIX_SPAWN_SETSCHEDPARAM    f
