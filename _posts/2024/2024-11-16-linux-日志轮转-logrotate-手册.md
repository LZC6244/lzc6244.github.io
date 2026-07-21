---
layout:         post
title:          linux 日志轮转 logrotate 手册
create_time:    2025-11-16 20:03
update_time:    
categories:     [Ubuntu]
---


# 描述

logrotate 旨在简化管理生成大量日志文件的系统。它允许自动轮换、压缩、删除和邮寄日志文件。每个日志文件可以按日、周、月处理，或者当它变得太大时。



通常，logrotate 作为每日 cron 作业运行。

可以查看 `/etc/cron.daily/logrotate` 文件来确认。

```bash
xxx@xxx:/mnt/data/xxxx$ cat /etc/anacrontab
# /etc/anacrontab: configuration file for anacron

# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
HOME=/root
LOGNAME=root

# These replace cron's entries
1       5       cron.daily      run-parts --report /etc/cron.daily
7       10      cron.weekly     run-parts --report /etc/cron.weekly
@monthly        15      cron.monthly    run-parts --report /etc/cron.monthly
```

除非该日志的依据是日志大小并且 logrotate 每天运行多次，

或者使用了-f 或--force 选项，否则它不会在一天内多次修改同一个日志。



命令行可以指定任意数量的配置文件。后续的配置文件可能会覆盖早期文件中给出的选项，因此列出日志轮转配置文件的顺序很重要。通常，应使用包含所需任何其他配置文件的单个配置文件。有关如何使用 include 指令来完成此操作的更多信息，请参阅下文。如果命令行中指定了目录，则该目录中的每个文件都被用作配置文件。

如果没有提供命令行参数，logrotate 将打印版本和版权信息，以及简短的用法摘要。如果在轮转日志时发生任何错误，logrotate 将以非零状态退出。





## 默认文件

默认状态文件：*/var/lib/logrotate.status*

默认配置文件：*/etc/logrotate.conf*





## 命令行选项

- -d, --debug

开启调试模式并暗示-v。在调试模式下，不会对日志或日志轮转状态文件进行更改。

- -f, --force 

强制告诉 logrotate 强制进行轮换，即使它认为这不必要。有时在添加新条目到 logrotate 配置文件后或手动删除旧日志文件后，这很有用，因为新文件将被创建，日志记录将继续正确进行。

- -m, --mail <command>

告诉 logrotate 在发送日志时使用哪个命令。此命令应接受两个参数：1）消息的主题，2）收件人。然后，该命令必须从标准输入读取一条消息并发送给收件人。默认的邮件命令是/bin/mail -s。

- -s, --state <statefile>

告诉 logrotate 使用一个替代状态文件。如果 logrotate 以不同用户身份为不同的日志文件集运行，这很有用。默认状态文件是/var/lib/logrotate.status。

- --?, --help

打印帮助信息。

- -v, --verbose

开启详细模式。





## 实例配置

logrotate 从命令行指定的配置文件中读取它应该处理的日志文件的所有信息。

每个配置文件可以设置全局选项（局部定义覆盖全局定义，后定义覆盖先定义）并指定要轮转的日志文件。

样例如下：

```bash
# sample logrotate configuration file
compress

/var/log/messages {
    rotate 5
    weekly
    postrotate
        /usr/bin/killall -HUP syslogd
    endscript
}

"/var/log/httpd/access.log" /var/log/httpd/error.log {
    rotate 5
    mail [www@my.org](mailto:www@my.org)
    size 100k
    sharedscripts
    postrotate
        /usr/bin/killall -HUP httpd
    endscript
}

/var/log/news/* {
    monthly
    rotate 2
    olddir /var/log/news/old
    missingok
    postrotate
        kill -HUP 'cat /var/run/inn.pid'
    endscript
    nocompress
}
```



样例配置解释：

```Plain Text
第一行设置全局选项；在示例中，日志在轮换后会被压缩。
注意，只要配置文件中行的第一个非空白字符是#，注释就可以出现在任何位置。


下一部分配置文件定义了如何处理日志文件 /var/log/messages。
日志文件将在被删除之前进行五次每周轮换。
在日志文件轮换之后（但在旧版日志被压缩之前），将执行命令 /sbin/killall -HUP syslogd。


下一节定义了/var/log/httpd/access.log 和/var/log/httpd/error.log 的参数
当它们的大小超过 100k 时，它们会被轮换。
旧的日志文件在经过 5 次轮换后（而不是被删除）通过邮件（未压缩）发送到 www@my.org。
sharedscripts 意味着 postrotate 脚本只会在旧日志被压缩后运行一次（而不是每个被轮换的日志运行一次）。
注意，本节开头第一个文件名周围的引号允许 logrotate 轮换具有空格名称的日志。
正常 shell 引号规则适用，支持', "和字符。


最后一节定义了/var/log/news 中所有文件的参数。
每个文件每月进行一次轮换。
这被视为一个单独的轮换指令，如果多个文件发生错误，则不会压缩日志文件。


请谨慎使用通配符。如果您指定了*，logrotate 将轮转所有文件，包括之前已轮转的文件。
一种解决方案是使用 olddir 指令或更精确的通配符（如*.log）。
```









logrotate  默认配置文件 *`/etc/logrotate.conf`** 中定义了 **`include /etc/logrotate.d`** *

故上述配置文件也可以写成多个配置文件保存至 *`/etc/logrotate.d`*





### 实例配置参数

|参数名|描述|
|---|---|
|**compress**|旧版本的日志文件默认使用 [gzip(1)](https://linux.die.net/man/1/gzip) 进行压缩。另见 **nocompress** 。|
|**compresscmd**|要使用哪个命令来压缩日志文件。默认是 gzip 。另请参阅 **compress** 。|
|**uncompresscmd**|指定用于解压缩日志文件的命令。默认为 gunzip 。|
|**compressext**|指定在启用压缩的情况下，压缩日志文件应使用哪个扩展名。默认值遵循配置的压缩命令。|
|**compressoptions**|命令行选项可以传递给压缩程序，如果正在使用的话。对于 [gzip(1)](https://linux.die.net/man/1/gzip) ，默认是 "-9" （最大压缩）。|
|**copy**|创建日志文件的副本，但不要更改原始文件。此选项可用于，例如，创建当前日志文件的快照，或者当某些其他实用程序需要截断或解析文件时。当使用此选项时，创建选项将没有效果，因为旧日志文件将保持原位。|
|**copytruncate**<br>|在创建副本后就地截断原始日志文件，而不是移动旧日志文件并可选地创建一个新文件。当某些程序无法被告知关闭其日志文件，因此可能会继续写入（追加）到之前的日志文件时，可以使用此功能。请注意，在复制文件和截断文件之间存在一个非常小的时间间隔，因此可能会丢失一些日志数据。当使用此选项时，创建选项将没有效果，因为旧日志文件将保留在原位。|
|**create** mode owner group<br>|立即在轮转后（在运行 **postrotate** 脚本之前）创建日志文件（与刚刚轮转的日志文件同名）。mode 指定日志文件的八进制模式（与 [chmod(2)](https://linux.die.net/man/2/chmod) 相同），owner 指定将拥有日志文件的用户名，group 指定日志文件所属的组。可以省略任何日志文件属性，在这种情况下，省略的属性将使用原始日志文件的同名属性。可以使用 nocreate 选项禁用此选项。<br>如：create 777 nobody nobody|
|**daily**|日志文件每天轮换。|
|**dateext**|归档旧版本的日志文件时，添加每日扩展名如 YYYYMMDD ，而不是简单地添加数字。扩展名可以通过 dateformat 选项进行配置。|
|**dateformat**|指定 **dateext** 的扩展名，使用类似于 [strftime(3)](https://linux.die.net/man/3/strftime) 函数的表示法。仅允许使用 %Y %m %d 和 %s 指定符。默认值为-%Y%m%d。请注意，分隔日志名称和扩展名的字符也是日期格式字符串的一部分。系统时钟必须设置在 2001 年 9 月 9 日之后，以便%s 能够正确工作。请注意，由该格式生成的日期戳必须是按字典顺序可排序的（即，首先是年份，然后是月份，然后是日期。例如，2001/12/01 是正确的，但 01/12/2001 是不正确的，因为 01/11/2002 会按字典顺序排在后面，而实际上它更晚）。这是因为当使用 **rotate **选项时，logrotate 会将所有已轮转的文件名排序，以找出哪些日志文件较旧并应该被删除。|
|**delaycompress**|推迟上一个日志文件的压缩到下一个轮转周期。这仅在结合使用 **compress** 时才有效。当某些程序无法被告知关闭其日志文件，因此可能会在一段时间内继续写入上一个日志文件时，可以使用它。|
|**extension**|日志文件具有 ext 扩展名可以在轮换后保留。如果使用压缩，压缩扩展名（通常是.gz）将出现在 ext 之后。例如，您有一个名为 mylog.foo 的日志文件，想要将其轮换为 mylog.1.foo.gz 而不是 mylog.foo.1.gz 。|
|**ifempty**|即使日志文件为空，也要轮转日志文件，覆盖 **notifempty** 选项（ifempty 是默认值）。|
|**include** file_or_directory|读取作为参数给出的文件，就像它被包含在 include 指令出现的地方一样。如果给出一个目录，则在处理包含的文件之前，该目录中的大多数文件将按字母顺序读取。唯一被忽略的文件是那些不是常规文件（如目录和命名管道）以及名称以某些禁忌扩展名结尾的文件，这些扩展名由 **tabooext** 指令指定。**include** 指令不能出现在日志文件定义中。|
|**mail** address|当日志被删除时，它会被邮寄到地址。如果某个日志不应该生成邮件，可以使用 **nomail** 指令。|
|**mailfirst**|当使用 **mail** 命令时，请发送刚刚轮转的文件，而不是即将过期的文件。|
|**maillast**|当使用 **mail** 命令时，请发送即将过期的文件，而不是刚刚轮转的文件（这是默认设置）。|
|**maxage** count|删除超过天的轮转日志。只有在需要轮转日志文件时才会检查其年龄。如果已配置 **maillast** 和 **mail**，则文件将被发送到配置的地址。|
|**minsize** size|日志文件在大小超过指定字节数时进行轮转，但不会早于额外指定的间隔时间 ( **daily**, **weekly**, **monthly**, **yearly **) 。相关的 **size** 选项类似，但与时间间隔选项互斥，并且它会导致日志文件轮转，不考虑上次轮转时间。当使用 **minsize** 时，会考虑日志文件的大小和时间戳。|
|**missingok**|如果日志文件缺失，则继续下一个，不发出错误消息。另见 **nomissingok **。|
|**monthly**|日志文件在每月第一次运行 **logrotate** 时进行轮转（这通常在每月的第一天）。|
|**nocompress**|旧版本的日志文件未压缩。另见 **compress** 。|
|**nocopy**|不要复制原始日志文件并保留在原位。（此操作将覆盖 **copy** 选项）。|
|**nocopytruncate**|不要在创建副本后原地截断原始日志文件（这覆盖了 **copytruncate** 选项）。|
|**nocreate**|新日志文件未创建（这将覆盖 **create** 选项）。|
|**nodelaycompress**|不要推迟上一个日志文件的压缩到下一个轮转周期（这覆盖了 **delaycompress** 选项）。|
|**nodateext**|不要存档带有日期扩展名的旧日志文件（这会覆盖 **dateext** 选项）。|
|**nomail**|不要将旧日志文件邮寄到任何地址。|
|**nomissingok**|如果日志文件不存在，则报错。这是默认设置。|
|**noolddir**|日志在日志通常所在的目录中进行轮转（这会覆盖 olddir 选项）。|
|**nosharedscripts**|运行每个被轮转的日志文件的 **prerotate** 和 **postrotate** 脚本（这是默认设置，并覆盖了 sharedscripts 选项）。日志文件的绝对路径作为脚本的第一个参数传递。如果脚本以错误退出，则仅对受影响的日志不执行剩余操作。|
|**noshred**|不要在删除旧日志文件时使用 **shred **。另见 **shred **。|
|**notifempty**|不要在日志为空时轮转日志（这覆盖了 **ifempty** 选项）|
|**olddir** directory<br>|日志被移动到目录中进行轮换。该目录必须与正在轮换的日志文件位于同一物理设备上，并且假定相对于包含日志文件的目录，除非指定了绝对路径名。当使用此选项时，所有旧的日志版本都会出现在目录中。此选项可能被 noolddir 选项覆盖。|
|**postrotate/endscript**|在 **postrotate** 和 **endscript**（这两者都必须单独占一行）之间的行（使用 /bin/sh 执行）在日志文件被轮换之后执行。这些指令只能出现在日志文件定义内部。通常，日志文件的绝对路径作为脚本的第一个参数传递。如果指定了 sharedscripts ，则整个模式传递给脚本。另请参阅 **prerotate** 。有关错误处理，请参阅 **sharedscripts** 和 **nosharedscripts** 。|
|**prerotate/endscript**|这些位于 **prerotate** 和 **endscript**（两者都必须单独占一行）之间的行会在日志文件被轮转之前执行（使用 **/bin/sh**），并且只有当日志实际上会被轮转时才会执行。这些指令只能出现在日志文件定义内部。通常，日志文件的绝对路径作为脚本的第一个参数传递。如果指定了 **sharedscripts** ，则整个模式传递给脚本。另请参阅 **postrotate** 。有关错误处理，请参阅 **sharedscripts** 和 **nosharedscripts** 。|
|**firstaction/endscript**|第一行到 **firstaction** 和 **endscript**（这两者都必须单独占一行）之间的行将在所有匹配通配符模式的日志文件被轮换之前执行（使用 **/bin/sh** ），在运行 prerotate 脚本之前，并且只有当至少有一个日志文件实际上会被轮换时才会执行。这些指令只能出现在日志文件定义内部。整个模式作为第一个参数传递给脚本。如果脚本以错误退出，则不再进行进一步处理。另请参阅 **lastaction** 。|
|**lastaction/endscript**<br>|在 **lastaction** 和 **endscript**（这两个都必须单独占一行）之间的行（使用 **/bin/sh** 执行）在所有匹配通配符模式的日志文件轮换后、运行 **postrotate** 脚本之后且至少有一个日志被轮换后执行一次。这些指令只能出现在日志文件定义内部。整个模式作为第一个参数传递给脚本。如果脚本以错误退出，则只显示错误消息（因为这将是最后一个动作）。另请参阅 **firstaction** 。|
|**rotate** count|日志文件在删除或发送到 **mail** 指令中指定的地址之前会被轮转 count 次。如果 count 为 0，则删除旧版本而不是轮转。|
|**size** size<br>|日志文件只有在大小超过指定字节数时才会被轮转。如果大小后面跟着 k，则假定大小是以千字节为单位。如果使用 M，则大小以兆字节为单位，如果使用 G，则大小以千兆字节为单位。因此，**size** 100、**size **100k、**size** 100M 和 **size **100G 都是有效的。|
|**sharedscripts**|通常，对于每个被轮转的日志，都会运行 **prerotate** 和 **postrotate** 脚本，并将日志文件的绝对路径作为脚本的第一个参数传递。这意味着单个脚本可能会为匹配多个文件（如 /var/log/news/* 示例）的日志条目运行多次。如果指定了 **sharedscripts **，则无论匹配通配符模式的日志有多少，脚本都只会运行一次，并将整个模式传递给它们。然而，如果模式中的任何日志都不需要轮转，则脚本根本不会运行。如果脚本以错误退出，则不会为任何日志执行剩余的操作。此选项覆盖 **nosharedscripts** 选项，并暗示 **create** 选项。|
|**shred**|使用 **shred** -u 代替 unlink() 删除日志文件。这应该确保在计划删除后日志不可读；默认情况下是关闭的。另请参阅 **noshred **。|
|**shredcycles** *count*|询问 GNU [shred(1)](https://linux.die.net/man/1/shred) 在删除前覆盖日志文件次数。如果没有此选项，将使用 **shred** 的默认设置。|
|**start** *count*|这是用作轮转基础的数字。例如，如果您指定 0，则日志将使用.0 扩展名创建，因为它们从原始日志文件中轮转。如果您指定 9，则日志文件将使用.9 扩展名创建，跳过 0-8。文件仍将根据 count 指令指定的次数进行轮转。|
|**tabooext** [+] *list*<br>|当前禁忌扩展列表已更改（有关禁忌扩展的信息，请参阅包含指令）。如果列表前有一个加号+，则当前禁忌扩展列表将被扩展，否则将被替换。在启动时，禁忌扩展列表包含 .rpmorig、.rpmsave、,v、.swp、.rpmnew、~、.cfsaved 和 .rhn-cfg-tmp-* 。|
|**weekly**|日志文件会在当前星期小于上次轮转的星期或自上次轮转以来超过一周时进行轮转。这通常等同于在每周的第一天轮转日志，但如果不是每天晚上都运行 logrotate，效果会更好。|
|**yearly**|日志文件会在当前年份与上次轮转年份不同时进行轮转。|





## 验证

手动指定刚才 logrotate 实例配置文件进行轮转

参考：`Usage: logrotate [OPTION...] <configfile>`



示例命令：`logrotate -f <configfile>`

通过 `-f` 进行强制轮转



# 参考文档

- https://linux.die.net/man/8/logrotate

- `man logrotate` 命令



