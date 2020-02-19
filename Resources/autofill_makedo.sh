#!/usr/bin/expect
set root_password [lindex $argv 0]
spawn make do
expect "root@localhost's password: "
send -- "$root_password\r"
expect "root@localhost's password: "
send -- "$root_password\r"
expect eof
