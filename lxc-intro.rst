:title: 淺談 Linux Containers
:author: Shih-Yuan Lee (FourDollars)
:description: 介紹 lxc 與其它虛擬化技術的比較，探討 lxc 使用到的 Linux kernel 提供的功能，使用方法介紹，架構在 lxc 上的其它服務。
:css: lxc-intro.css

----

淺談 Linux Containers (LXC)
===========================

Shih-Yuan Lee (FourDollars)
---------------------------

@ COSCUP 2014.07.19
-------------------

.. note::
 OK, 謝謝 Penk 的介紹，那我們就開始吧。

----

:data-x: r0
:data-y: r-1080

自我介紹
========

自由軟體工作者，目前在 Canonical_ 公司服務，負責開發 `Ubuntu OEM`_ 衍生版本，平時會在台北參加 TOSSUG_ 以及 `Hacking Thursday`_ 的社群聚會。

.. _Canonical: http://www.canonical.com
.. _Ubuntu OEM: http://www.ubuntu.com
.. _TOSSUG: http://www.tossug.org
.. _Hacking Thursday: http://www.hackingthursday.org

.. note::
 簡單的自我介紹一下。（停頓三秒就跳過）

----

:data-x: r1920
:data-y: r0

Canonical 徵人
==============

英屬曼島商肯諾有限公司

台北 101 大樓 46-47F

- Director of Commercial Engineering
- Software Engineer - OEM/ODM Support
- QA Engineer

http://www.canonical.com/careers

.. note::
 敝公司現在還有在徵人，以上是職缺，如果有興趣的話，可以到上面的網址找這些職缺的詳細內容。

----

:data-x: r0
:data-y: r1080 

Linux 上的虛擬化技術
====================

Virtualization on Linux
=======================

.. note::
 這裡算是前情提要，首先簡單介紹一下 Linux 上面使用到的虛擬化技術，這邊講的以 x86 為主。

----

:data-x: r0
:data-y: r1080 

完全虛擬化
==========

利用 Intel Virtualization Technology (Intel VT) 與 AMD Virtualization (AMD-V) 等 CPU 虛擬化支援功能，將 PC 硬體上運作的 OS 直接拿到虛擬機器下執行。

Full virtualization
===================

Almost complete simulation of the actual hardware to allow software, which typically consists of a guest operating system, to run unmodified.

.. note::
 完全虛擬化就是模擬整個電腦，讓一般安裝在實體電腦上的 OS 也能夠安裝到虛擬環境裡面，不用做額外的修改，但是如果要跑得更順暢的話，
 就是要安裝額外的驅動程式，有在使用 VirtualBox 的人應該知道，在 VirtualBox 裡面安裝完一個 Linux 系統後需要再安裝一些驅動程式。

----

:data-x: r960
:data-y: r0 

.. image:: img/Hardware_Virtualization2.svg

http://commons.wikimedia.org/wiki/File:Hardware_Virtualization_(copy).svg

.. note::
 這是從 WikiPedia 上面找來的圖片，大概長得像是這樣，裡面每個 Guest OS 都有自己的虛擬硬體。

----

:data-x: r-960
:data-y: r1080 

半虛擬化
========

Guest OS 需要知道自己在虛擬化環境底下執行，Kernel 與驅動程式必須修正。半虛擬化方式的 guest OS 稱為 PV guest；半虛擬化方式的驅動程式稱為 PV driver。

Paravirtualization
==================

A hardware environment is not simulated; however, the guest programs are executed in their own isolated domains, as if they are running on a separate system. Guest programs need to be specifically modified to run in this environment.

.. note::
 而半虛擬化則是要安裝修改過的 Linux kernel 跟驅動程式，好吧。。。
 我目前不是熟這些東西，只是在這裡提出來有這樣的東西。

----

:data-x: r960
:data-y: r0 

.. image:: img/Xen_para-virtualization_architecture.png

http://docs.fedoraproject.org/en-US/Fedora/12/html/Virtualization_Guide/go01.html

.. note::
 這是從 Fedora 上面找來的圖片

----

:data-x: r-960
:data-y: r1080 

作業系統階層的虛擬化
====================

由作業系統提供的功能來隔離 guest OS 的執行環境，但是共用 Host OS 上面的 Kernel，在 guest OS 裡面看起來就像是一個獨立的環境。

Operating system-level virtualization
=====================================

The same OS kernel is used to implement the "guest" environments. Applications running in a given "guest" environment view it as a stand-alone system.

.. note::
 現在這個就是今天要講的主題，也就是它不屬於完全虛擬化跟半驅擬化，
 它只是創建了一個特別的容器，而這個容器裡面所使用的 Linux Kernel 跟外面是同一個，
 只是系統環境被 Linux kernel 所提供的一些功能給隔開了。

----

:data-x: 5760
:data-y: 0

Linux Containers
================

官方網站 https://linuxcontainers.org

"LXC is often considered as something in the middle between a chroot on steroids and a full fledged virtual machine. The goal of LXC is to create an environment as close as possible as a standard Linux installation but without the need for a separate kernel."

“LXC 往往被視為在加強版的 Chroot 環境和一個完全成熟的虛擬機器之間的某種存在。LXC 的目標是創造一個盡可能接近標準的 Linux 安裝環境，但是不需要額外的系統內核。”

.. note::
 現在講到今天的主題 Linux Container，上面的敘述是從官方網站引述的。（照著中文唸一遍）

----

:data-x: r0
:data-y: r1080

開發者
======

根據 2014.07.16 的統計資料 by ``git shortlog -sne``

::

   551  Stéphane Graber <stgraber [at] ubuntu.com>
   529  Serge Hallyn <serge.hallyn [at] ubuntu.com>
   243  Dwight Engen <dwight.engen [at] oracle.com>
   200  Daniel Lezcano <daniel.lezcano [at] free.fr>
   190  dlezcano <dlezcano>
   140  Daniel Lezcano <dlezcano [at] fr.ibm.com>
   116  Michel Normand <normand [at] fr.ibm.com>
    80  KATOH Yasufumi <karma [at] jazz.email.ne.jp>
    77  S.Çağlar Onur <caglar [at] 10ur.org>
    65  Christian Seiler <christian [at] iwakd.de>
    59  Natanael Copa <ncopa [at] alpinelinux.org>
    47  Serge Hallyn <serge.hallyn [at] canonical.com>
    29  Michael H. Warfield <mhw [at] WittsEnd.com>
    26  Qiang Huang <h.huangqiang [at] huawei.com>
    ...

.. note::
 我們先來看一下開發者成員，上面在 2014.07.16 在 git repository 上面執行後面那段指令之後的輸出結果。

----

:data-x: r0
:data-y: r1080

開發者
======

合併重覆之後的前五名

::

   576  Serge Hallyn <serge.hallyn [at] ubuntu.com>
   551  Stéphane Graber <stgraber [at] ubuntu.com>
   530  Daniel Lezcano <dlezcano [at] fr.ibm.com>
   243  Dwight Engen <dwight.engen [at] oracle.com>
   116  Michel Normand <normand [at] fr.ibm.com>

原作者 Daniel Lezcano 來自 IBM

主要的商業公司支援來自 **Canonical**, **IBM**, **Oracle**

.. note::
 接著我們把重覆的部份合併，就可以發現主要是這三間公司聘請全職的開發人員在做貢獻。
 為什麼 Canonical 也就是敝公司會投入 lxc 的開發呢？

----

:data-x: r0
:data-y: r1080

Ubuntu 相關的應用
=================

- `Ubuntu Juju`_ - automate your cloud infrastructure
   - Using Juju with the local LXC provider [video_]

- `Ubuntu Touch`_ - for smartphones and tablet computers.
   - Ubuntu Touch Internals [pdf_]

.. _Ubuntu Juju: https://juju.ubuntu.com
.. _video: http://youtu.be/O_6gI-woE9s
.. _Ubuntu Touch: http://en.wikipedia.org/wiki/Ubuntu_Touch
.. _pdf: http://events.linuxfoundation.org/sites/events/files/slides/Ubuntu%20Touch%20Internals_1.pdf

.. note::
 當然是因為要應用到自己的產品上面啦，

 首先是 Ubuntu Juju 

 Ubuntu Juju 是一個雲端快速建構的工具跟平台，目標是讓使用者輕鬆無痛地建立起網站，
 如果是你是在本機上安裝使用它，就是會使用到 LXC，
 這裡有一段 YouTube 的影片大家會後可以看一下，不過我們先來看一下 Demo

 接下來再來看一下 Ubuntu Touch

 Ubuntu Touch 是 Canonical 為了手機與平板所開發的一套系統，它與一般的 Ubuntu 共用所有的軟體套件，
 但是額外新增了一些軟體散布的機制，我們來快速看一下 Ubuntu Touch 內部設計的文件，看哪裡有用到 LXC。

----

:data-x: r1920
:data-y: 0

Linux kernel 提供的功能
=======================

`man lxc`

::

    ...
        * General setup
          * Control Group support
            -> Namespace cgroup subsystem
            -> Freezer cgroup subsystem
            -> Cpuset support
            -> Simple CPU accounting cgroup subsystem
            -> Resource counters
              -> Memory resource controllers for Control Groups
          * Group CPU scheduler
            -> Basis for grouping tasks (Control Groups)
          * Namespaces support
            -> UTS namespace
            -> IPC namespace
            -> User namespace
            -> Pid namespace
            -> Network namespace
        * Device Drivers
          * Character devices
            -> Support multiple instances of devpts
          * Network device support
            -> MAC-VLAN support
            -> Virtual ethernet pair device
        * Networking
          * Networking options
            -> 802.1d Ethernet Bridging
        * Security options
          -> File POSIX Capabilities
    ...

.. note::
 我們來看 Linux kernel 裡面提供了哪些功能，如果你去 man lxc 這個指令，
 你就會看到裡面有一段 Linux kernel 編譯選項的敘述，
 如果去 Linux kernel source tree 裡面去找這些編譯選項的說明就會看到接下來的東西。

----

:data-x: r0
:data-y: r1080

CONFIG_CGROUPS
==============

Control Group support
---------------------

This option adds support for grouping sets of processes together, for
use with process control subsystems such as Cpusets, CFS, memory
controls or device isolation.

See::

      - Documentation/scheduler/sched-design-CFS.txt   (CFS)
      - Documentation/cgroups/ (features for grouping, isolation
                                and resource control)

.. note::
 Control Group 又稱為 cgroup 是主要的功能選項，接下來許多 cgroup subsystem 又稱為 controller 都是依賴在這個選項之下。

 cgroup 的功能是讓 process 能夠分開在不同的 group 裡面，然後我們可以對每個 group 透過 controller 做不同的操作。

----

:data-x: r0
:data-y: r1080

CONFIG_CGROUP_NS
================

Namespace cgroup subsystem
--------------------------

Provides a simple namespace cgroup subsystem to provide hierarchical naming of sets of namespaces, for instance virtual servers and checkpoint/restart jobs.

2.6.24–2.6.39

.. note::
  Namespace controller 是讓 cgroup 去使用到 namespace 功能。

  namespace 是另外一個主要的功能，等一下會做比較詳細的說明，這裡先跳過。

----

:data-x: r0
:data-y: r1080

CONFIG_CGROUP_FREEZER
=====================

Freezer cgroup subsystem
------------------------

Provides a way to freeze and unfreeze all tasks in a cgroup.

.. note::
  看一下大概就知道這是用來凍結所有 process 的東西。

----

:data-x: r0
:data-y: r1080

CONFIG_CPUSETS
==============

Cpuset support
--------------

This option will let you create and manage CPUSETs which       
allow dynamically partitioning a system into sets of CPUs and  
Memory Nodes and assigning tasks to run only within those sets.
This is primarily useful on large SMP or NUMA systems.         

.. note::
  簡單說就是指定 process 能夠跑在哪一個 CPU 上面。

----

:data-x: r0
:data-y: r1080

CONFIG_CGROUP_CPUACCT
=====================

Simple CPU accounting cgroup subsystem
--------------------------------------

Provides a simple Resource Controller for monitoring the 
total CPU consumed by the tasks in a cgroup.             

.. note::
  統計每個 process 的 CPU 使用量。

----

:data-x: r0
:data-y: r1080

CONFIG_RESOURCE_COUNTERS
========================

Resource counters
-----------------

This option enables controller independent resource accounting 
infrastructure that works with cgroups.                        

.. note::
  提供一些共通的機制去計算各種資源的使用量。

----

:data-x: r0
:data-y: r1080

CONFIG_MEMCG
============

Memory resource controllers for Control Groups
----------------------------------------------

Provides a memory resource controller that manages both anonymous  
memory and page cache. (See Documentation/cgroups/memory.txt)      
                                                                   
Note that setting this option increases fixed memory overhead      
associated with each page of memory in the system. By this,        
8(16)bytes/PAGE_SIZE on 32(64)bit system will be occupied by memory
usage tracking struct at boot. Total amount of this is printed out 
at boot.                                                           
                                                                   
Only enable when you're ok with these trade offs and really        
sure you need the memory resource controller. Even when you enable 
this, you can set "cgroup_disable=memory" at your boot option to   
disable memory resource controller and you can avoid overheads.    
(and lose benefits of memory resource controller)                  
                                                                   
This config option also selects MM_OWNER config option, which      
could in turn add some fork/exit overhead.                         

.. note::
  控制記憶體資源的使用量。

----

:data-x: r0
:data-y: r1080

CONFIG_CGROUP_SCHED
===================

Group CPU scheduler
-------------------

This feature lets CPU scheduler recognize task groups and control CPU
bandwidth allocation to such task groups. It uses cgroups to group   
tasks.                                                               

.. note::
  Process 的 CPU 排程的控制。

----

:data-x: r0
:data-y: r1080

CONFIG_NAMESPACES
=================

Namespaces support
------------------

Provides the way to make tasks work with different objects using
the same id. For example same IPC id may refer to different objects
or same user id or pid may refer to different tasks when used in
different namespaces.

.. note::
  讓容器裡面可以使用跟容器外面一樣的 ID ，例如 Process ID / User ID / IPC ID，

  至少在容器裡面看起來是跟外面一樣的，實際上當然不會一樣，只是容器以為是獨立的環境。

  例如，容器內有 init 它的 PID 是 1，容器外面也有 init 它的 PID 也是 1，
  但是容器裡面的 init 從容器外面來看就不是 1 了，而是其它的數字。

  來實際看一下 init 的例子。

----

:data-x: r0
:data-y: r1080

CONFIG_UTS_NS
=============
                                                            
UTS namespace
-------------

In this namespace tasks see different info provided with the
uname() system call                                         

.. note::
  讓容器內的 uname 跑出不一樣的結果。（以 sudo lxc-start -n wheezy-sh4 裡面的 uname -m 為例）

----

:data-x: r0
:data-y: r1080

CONFIG_IPC_NS
=============

IPC namespace
-------------
                                                             
In this namespace tasks work with IPC ids which correspond to
different IPC objects in different namespaces.               

.. note::
  讓 IPC ID 在容器內獨立。

----

:data-x: r0
:data-y: r1080

CONFIG_USER_NS
==============

User namespace
--------------
                                                              
This allows containers, i.e. vservers, to use user namespaces 
to provide different user info for different servers.         
                                                              
When user namespaces are enabled in the kernel it is          
recommended that the MEMCG and MEMCG_KMEM options also be     
enabled and that user-space use the memory control groups to  
limit the amount of memory a memory unprivileged users can    
use.                                                          

.. note::
  讓 User ID 在容器內獨立，並且可以讓一般的 User ID 受到某些記憶體使用量的限制。

----

:data-x: r0
:data-y: r1080

CONFIG_PID_NS
=============

Pid namespace
-------------
                                                            
Support process id namespaces.  This allows having multiple 
processes with the same pid as long as they are in different
pid namespaces.  This is a building block of containers.    

.. note::
  讓 Process ID 在容器內獨立。

----

:data-x: r0
:data-y: r1080

CONFIG_NET_NS
=============

Network namespace
-----------------
                                                               
Allow user space to create what appear to be multiple instances
of the network stack.                                          

.. note::
  允許用戶空間可以建立多個網路實體，就很多 Ethernet interface 的樣子。

----

:data-x: r0
:data-y: r1080

CONFIG_DEVPTS_MULTIPLE_INSTANCES
================================

Support multiple instances of devpts
------------------------------------
                                                                
Enable support for multiple instances of devpts filesystem.     
If you want to have isolated PTY namespaces (eg: in containers),
say Y here.  Otherwise, say N. If enabled, each mount of devpts 
filesystem with the '-o newinstance' option will create an      
independent PTY namespace.                                      

.. note::
   在容器內建立 /dev/tty1 之類的東西，等一下會提到 lxc-console
   這個指令會使用到這個功能。

----

:data-x: r0
:data-y: r1080

CONFIG_MACVLAN
==============

MAC-VLAN support
----------------
                                                                   
This allows one to create virtual interfaces that map packets to   
or from specific MAC addresses to a particular interface.          
                                                                   
Macvlan devices can be added using the "ip" command from the       
iproute2 package starting with the iproute2-2.6.23 release:        
                                                                   
"ip link add link <real dev> [ address MAC ] [ NAME ] type macvlan"
                                                                   
To compile this driver as a module, choose M here: the module      
will be called macvlan.                                            

.. note::
  這應該是將網路切成許多不同的區域網路空間，彼此獨立互相不會受到影響。

----

:data-x: r0
:data-y: r1080

CONFIG_VETH
===========

Virtual ethernet pair device
----------------------------
                                                                     
This device is a local ethernet tunnel. Devices are created in pairs.
When one end receives the packet it appears on its pair and vice     
versa.                                                               

.. note::
  將 Linux Container 裡面的網路跟外面的網路連接在一起，有點像是虛擬網路線對接。

----

:data-x: r0
:data-y: r1080

CONFIG_BRIDGE
=============

802.1d Ethernet Bridging
------------------------
                                                                     
If you say Y here, then your Linux box will be able to act as an     
Ethernet bridge, which means that the different Ethernet segments it 
is connected to will appear as one Ethernet to the participants.     
Several such bridges can work together to create even larger         
networks of Ethernets using the IEEE 802.1 spanning tree algorithm.  
As this is a standard, Linux bridges will cooperate properly with    
other third party bridge products.                                   
                                                                     
In order to use the Ethernet bridge, you'll need the bridge          
configuration tools; see <file:Documentation/networking/bridge.txt>  
for location. Please read the Bridge mini-HOWTO for more             
information.                                                         
                                                                     
If you enable iptables support along with the bridge support then you
turn your bridge into a bridging IP firewall.                        
iptables will then see the IP packets being bridged, so you need to  
take this into account when setting up your firewall rules.          
Enabling arptables support when bridging will let arptables see      
bridged ARP traffic in the arptables FORWARD chain.                  

.. note::
  將一個 Ethernet 當成好多不同的 Ethernet 使用，但是實際上是同一個 Ethernet 實體裝置。

----

:data-x: r0
:data-y: r1080

CONFIG_SECURITY_FILE_CAPABILITIES
=================================

File POSIX Capabilities
-----------------------

This enables filesystem capabilities, allowing you to give
binaries a subset of root's powers without using setuid 0.

(Removed from linux kernel 2.6.33 and above versions.)

.. note::
  某些檔案系統權限的功能，不過後來這個選項已經被移掉不用了。

----

:data-x: r1920
:data-y: 0

以 Ubuntu 14.04 為例
====================

安裝 lxc
--------

$ sudo apt-get install lxc lxc-templates

.. note::
  接下來簡單介紹幾個 lxc 的指令，首先當然要先安裝到系統上面才可以使用。

----

:data-x: r0
:data-y: r1080 

簡查一下系統是否支援 LXC
========================

::

  $ lxc-checkconfig 
  Kernel configuration not found at /proc/config.gz; searching...
  Kernel configuration found at /boot/config-3.13.0-32-generic
  --- Namespaces ---
  Namespaces: enabled
  Utsname namespace: enabled
  Ipc namespace: enabled
  Pid namespace: enabled
  User namespace: enabled
  Network namespace: enabled
  Multiple /dev/pts instances: enabled
  
  --- Control groups ---
  Cgroup: enabled
  Cgroup clone_children flag: enabled
  Cgroup device: enabled
  Cgroup sched: enabled
  Cgroup cpu account: enabled
  Cgroup memory controller: enabled
  Cgroup cpuset: enabled
  
  --- Misc ---
  Veth pair device: enabled
  Macvlan: enabled
  Vlan: enabled
  File capabilities: enabled
  
  Note : Before booting a new kernel, you can check its configuration
  usage : CONFIG=/path/to/config /usr/bin/lxc-checkconfig

----

:data-x: r0
:data-y: r1080 

查看有哪些 Templates 可以使用
=============================

::

    $ tree /usr/share/lxc/templates
    /usr/share/lxc/templates
    ├── lxc-alpine
    ├── lxc-altlinux
    ├── lxc-archlinux
    ├── lxc-busybox
    ├── lxc-centos
    ├── lxc-cirros
    ├── lxc-debian
    ├── lxc-download
    ├── lxc-fedora
    ├── lxc-gentoo
    ├── lxc-openmandriva
    ├── lxc-opensuse
    ├── lxc-oracle
    ├── lxc-plamo
    ├── lxc-sshd
    ├── lxc-ubuntu
    └── lxc-ubuntu-cloud
    
    0 directories, 17 files

----

:data-x: r0
:data-y: r1080 

產生 Debian sid (amd64) 為例
============================

每個 Template 都有自己的使用說明
--------------------------------

$ sudo lxc-create -t debian -h

產生 Create
-----------

$ sudo lxc-create -t debian -n sid -- -r sid -a amd64

摧毀 Destroy
------------

$ sudo lxc-destroy -n sid

----

:data-x: r0
:data-y: r1080 

操作 Linux Container
====================

啟動 Start
----------

$ sudo lxc-start -d -n sid

凍結 Freeze
-----------

$ sudo lxc-freeze -n sid

解凍 Unfreeze
-------------

$ sudo lxc-unfreeze -n sid

停止 Stop
---------

$ sudo lxc-stop -n sid

----

:data-x: r0
:data-y: r1080 

查詢 Linux Container
====================

所有容器清單
------------

::

    $ sudo lxc-ls -f
    NAME            STATE    IPV4       IPV6  AUTOSTART  
    ---------------------------------------------------
    sid             FROZEN   10.0.3.56  -     NO         

個別容器的資訊
--------------

::

    $ sudo lxc-info -n sid
    Name:           sid
    State:          FROZEN
    PID:            13843
    IP:             10.0.3.56
    CPU use:        0.59 seconds
    Memory use:     24.69 MiB
    KMem use:       0 bytes
    Link:           vethL2RL9Y
     TX bytes:      2.49 KiB
     RX bytes:      24.61 KiB
     Total bytes:   27.09 KiB

----

:data-x: r0
:data-y: r1080 

進入 Linux Container
====================

$ sudo lxc-console -n sid

.. note::
  這裡就是前面有提到的一個 devpts 的 Linux kernel 編譯選項，
  這邊就是模擬純 console 環境的 tty1，
  你可以重複執行這個指令來取得 tty2, tty3 以此類推。

----

:data-x: r0
:data-y: r1080 

強力建議閱讀
============

https://www.stgraber.org/2013/12/20/lxc-1-0-blog-post-series/

- LXC 1.0: Your first Ubuntu container [1/10]
- LXC 1.0: Your second container [2/10]
- LXC 1.0: Advanced container usage [3/10]
- LXC 1.0: Some more advanced container usage [4/10]
- LXC 1.0: Container storage [5/10]
- LXC 1.0: Security features [6/10]
- LXC 1.0: Unprivileged containers [7/10]
- LXC 1.0: Scripting with the API [8/10]
- LXC 1.0: GUI in containers [9/10]
- LXC 1.0: Troubleshooting and debugging [10/10]

----

:data-x: r1920
:data-y: 0

介紹一些架構在 LXC 上的應用
===========================

----

:data-x: r0
:data-y: r1080 

Steam for Linux
===============

http://steamcommunity.com/linux

Running in a LXC container on Ubuntu
------------------------------------

在 Ubuntu 12.04 上面的 Demo http://youtu.be/IorxJsw09vY

::

  sudo apt-add-repository ppa:ubuntu-lxc/stable
  sudo apt-get update
  sudo apt-get install steam-lxc
  sudo mkdir -p /var/lib/lxc /var/cache/lxc
  sudo steam-lxc create
  sudo steam-lxc run

----

:data-x: r0
:data-y: r1080 

LXC Web Panel
=============

https://lxc-webpanel.github.io/screenshots.html

----

:data-x: r0
:data-y: r1080 

LXC provider for Vagrant
========================

https://github.com/fgrehm/vagrant-lxc

----

:data-x: r0
:data-y: r1080 

Docker
======

https://www.docker.com/whatisdocker/

----

:data-x: r0
:data-y: r1080 

Docker running under Juju
=========================

https://github.com/bcsaller/juju-docker

----

:data-x: r0
:data-y: r1080 

Project Atomic
==============

http://www.projectatomic.io/

----

:data-x: r1920
:data-y: 0

參考資料
========

- http://en.wikipedia.org/wiki/Virtualization
- http://technet.microsoft.com/zh-tw/magazine/hh802393.aspx
- http://www.ibm.com/developerworks/cn/linux/l-lxc-containers/
- http://www.cs.ucsb.edu/~rich/class/cs290-cloud/papers/lxc-namespace.pdf
- Linux Kernel Hacks, ISBN 978-986-347-014-4

----

:data-x: r1920
:data-y: 0

投影片授權
==========

姓名標示 4.0 國際 (`CC BY 4.0`_)

.. _CC BY 4.0: http://creativecommons.org/licenses/by/4.0/

http://fourdollars.github.io/lxc-intro/

http://bit.ly/lxc-intro

投影片是用 Hovercraft_ 製作的

.. _Hovercraft: https://github.com/regebro/hovercraft
