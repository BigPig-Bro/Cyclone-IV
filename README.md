# Cyclone_IV

**描述**：Cyclone IV是FPGA入门里面个人认为最经典的一款，本目录下所有工程均基于Cyclone IV及Quartus 20.1 lite开发，其中大部分工程为EP4CE6/10F17C8、EP4CE6/10E22C8。绝大部分工程没有使用到IP核，可以适用于黑金、正点原子、小梅哥、野火等开发板。

**分类** ：由于个人主要涉及图像处理，所以所示工程分为图像处理以及其他，其中图像处理分为了直插LCD类工程（包含480x272、800x480）以及视频接口类（包含VGA、HDMI从480P到1080P），二者工程可能存在较大交叉（比如同一工程使用LCD or VGA/HDMI）。Others为其他电机、传感器等控制内容。



**主要目录**：

+ Code_LCD 					# 主要是直插型LCD
+ Code_VGA_HDMI         #主要是VGA\ HDMI 工程
+ Code_Others                 #主要是传感器及其他控制类
