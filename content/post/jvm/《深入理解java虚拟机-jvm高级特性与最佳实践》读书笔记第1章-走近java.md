---

date :  "2017-05-21T23:36:24+08:00"

title : "深入理解Java虚拟机--第1章 走近java"

---

第1部分 走近Java
================

第1章 走近java
--------------

-   JDK(java development
    kit)java开发工具，包括java程序设计语言，api类库，Java虚拟机
-   JRE(java runtime environment)：java se api和java虚拟机称为JRE
-   Java体系的四个平台
    -   Java Card:支持小内存设备的应用：智能卡等
    -   Java ME(java micro Edition):支持面向移动终端的应用：手机，平板等
    -   Java SE(java Standard Edition):支持面向桌面级应用：windows应用
    -   Java EE(java Enterprise
        Edition):支持多层架构的企业级应用：erp,crm

### java虚拟机发展史

-   Sun Classic
    VM是世界上第一款商用Java虚拟机（1996年1月23）;后续被Exact VM取代；
-   Exact
    VM：准确式内存管理，拥有两级即时编译器、编译器与解释器混合工作模式等
-   HotSpot VM:是Sun
    JDK和OpenJDK中所带的虚拟机，目前使用范围最广，不是Sun公司开发的，而是Longview
    Technologies小公司设计，后被Sun收购；
    -   HotSpot:热点代码探测技术
-   JRockit
    VM:由BEA公司研发，曾经号称“世界上速度最快的Java虚拟机”，JRockit的垃圾收集器和MissionControl服务套件等部分的实现处于领先水平
-   J9 VM: IBM研发的用于IBM产品和AIX、z/OS这些平台

