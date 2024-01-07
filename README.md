# 基于紫光同创 FPGA 和 YOLO 模型的多路视频采集与识别系统
2023集创赛紫光同创杯一等奖项目
* 单板方案使用 HDMI，双目 OV5640 作为输入，使用 HDMI，PCIe，以太网作为输出
* FPGA 使用双线性插值算法对输入视频进行缩放，使用 AXI 仲裁架构实现四路视频的缓存
* 上位机基于紫光同创 Linux PCIe 驱动进行开发，使用 gtk，ffmpeg，能够接收 PCIe、以太网视频，同时能调用YOLO模型识别视频
* 部分代码使用了小眼睛半导体和正点原子的例程（如 IIC, RGMII2GMII 等），FPGA，上位机和模型部分由我的队友完成，有问题发 issue
  
突然发现上位机的代码在台式机里面，所以只传了FPGA设计上来，等我开学回学校再传吧（欢迎来b站一键三连+关注，[演示demo](https://www.bilibili.com/video/BV1am4y1H7hp)
