# 基于紫光同创FPGA和YOLO模型的多路视频采集与识别系统
## 2023集创赛紫光同创杯一等奖项目
## 单板方案使用HDMI、双目OV564O作为输入，提供HDMI、PCIe、以太网进行输出
## 上位机基于紫光同创Linux PCIe驱动进行开发，使用该gtk、ffmpeg、能够接收PCIe、以太网视频，同时能调用YOLO模型识别视频
## 部分代码使用了小眼睛半导体和正点原子的例程（如IIC,RGMII2GMII等），FPGA、上位机和模型部分由我的队友完成，有问题可以b站私信：在天上飞的TTTTT
  突然发现上位机的代码在台式机里面，所以只传了FPGA设计上来，等我开学回学校再传吧（
  欢迎来b站一键三连+关注，演示demo:https://www.bilibili.com/video/BV1am4y1H7hp/

