! Copyright 2022 Doug Coleman and Cat Stevens.
IN: unix.process.posix-spawn

! See <https://github.com/apple-oss-distributions/xnu/blob/main/bsd/sys/spawn_internal.h>

! XNU's posix_spawn has a lot of extra features like "port action" and "coalition"
! and "MAC Policy Extensions" which are far too confusing to implement until they
! are absolutely needed

! these are Darwin specific:

CONSTANT:	POSIX_SPAWN_SETEXEC         0x0040
CONSTANT: POSIX_SPAWN_START_SUSPENDED 0x0080

! macos does not support the POSIX Process Scheduling feature
! however, we do define the names so that scheduling code for "unix"
! platforms does not fail to compile on macos

CONSTANT: POSIX_SPAWN_SETSCHEDULER     f
CONSTANT: POSIX_SPAWN_SETSCHEDPARAM    f
