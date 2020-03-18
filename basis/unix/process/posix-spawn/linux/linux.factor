USING: alien.c-types alien.syntax classes.struct kernel layouts
literals math math.functions math.order multiline unix.types ;

IN: unix.process
! NOTE: uncomment these lines when nixos support is merged, as nixos does not
! use a GNU toolchain
! SYMBOLS: POSIX_SPAWN_USEVFORK POSIX_SPAWN_SETSID ;
! os [ linux? ] [ nixos? not ] bi and [ "unix.process.posix-spawn.linux.non-nixos" require ] when
! NOTE: feature test macro: "__USE_GNU"
CONSTANT: POSIX_SPAWN_SETSID 0x80
CONSTANT: POSIX_SPAWN_USEVFORK 0x40
! end feature test macro
