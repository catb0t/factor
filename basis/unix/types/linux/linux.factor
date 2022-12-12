USING: alien.c-types alien.syntax classes.struct ;
IN: unix.types

TYPEDEF: ulonglong __uquad_type
TYPEDEF: ulong     __ulongword_type
TYPEDEF: long      __sword_type
TYPEDEF: ulong     __uword_type
TYPEDEF: long      __slongword_type
TYPEDEF: uchar     __u8
TYPEDEF: ushort    __u16
TYPEDEF: uint      __u32
TYPEDEF: ulonglong __u64
TYPEDEF: char      __s8
TYPEDEF: short     __s16
TYPEDEF: int       __s32
TYPEDEF: longlong  __s64
TYPEDEF: uint      __u32_type
TYPEDEF: int       __s32_type

TYPEDEF: __uquad_type     dev_t
TYPEDEF: __ulongword_type ino_t
TYPEDEF: ino_t            __ino_t
TYPEDEF: __u32_type       mode_t
TYPEDEF: __uword_type     nlink_t
TYPEDEF: __u32_type       uid_t
TYPEDEF: __u32_type       gid_t
TYPEDEF: __slongword_type off_t
TYPEDEF: off_t            __off_t
TYPEDEF: __slongword_type blksize_t
TYPEDEF: __slongword_type blkcnt_t
TYPEDEF: __s32_type       pid_t
TYPEDEF: __slongword_type time_t
TYPEDEF: __slongword_type __time_t

TYPEDEF: ssize_t __SWORD_TYPE
TYPEDEF: ulonglong blkcnt64_t
TYPEDEF: ulonglong __fsblkcnt64_t
TYPEDEF: ulonglong __fsfilcnt64_t
TYPEDEF: ulonglong ino64_t
TYPEDEF: ulonglong off64_t

STRUCT: sigset_t
    { val uchar[128] } ;

! NOTE: feature "Process Scheduling"
! sched_param from <bits/types/struct_sched_param.h>
STRUCT: sched_param
    { sched_priority int } ;

! linux's <spawn.h> defines the following as structs, macos does not

! any other declaration causes crashes and bad pointers, so this is just void*
TYPEDEF: void* spawn_action

STRUCT: posix_spawn_file_actions_t
    { allocated int }
    { used int }
    ! struct spawn_action *__actions;
    { actions spawn_action }
    ! int __pad[16];
    { __pad int[16] } ;

STRUCT: posix_spawnattr_t
    { flags alien.c-types:short } ! flags
    { pgrp pid_t }  ! pgroup
    { sd sigset_t } ! sigdefault
    { ss sigset_t } ! sigmask
    ! struct sched_param __sp;
    { sp sched_param }
    { policy int }  ! schedpolicy
    ! int __pad[16];
    { __pad int[16] } ;
