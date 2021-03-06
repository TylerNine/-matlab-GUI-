# -matlab-GUI-Flame identification
  本项目可以检测出图片或者视频中的火焰，通过火焰圆形度来进行识别检测

# 本项目选题的依据与意义：
  火灾是最常见的严重灾害之一，往往给人们的生命财产造成巨大的危害。基于视频检测火焰技术在近几年得到了深入的研究，国外的Yamagishi学者曾经提出一种彩色图像的火焰检测算。国内，中国科技大学的火灾科学国家重点实验室研制出的LA-100型双波段大空间早期火灾智能探测系统，利用红外摄像机和特制的感烟红外阵列器材，来实现图像型的火灾火焰和烟雾的探测，其核心内容都是根据火焰的特征来识别火焰,火焰的主要特征有颜色特性、平均灰度方差、跳动的频率、尖角、面积变化率、面积增长特性、质心的移动特性、圆形度、图像的形状相似性、矩特性、相对稳定性等等。采取不同的方法，涉及的软件算法各有差异，检测的特征一般较多较杂。 本设计不利用任何的传感器，只基于视频的实时图像釆集，来重点研究火焰的尖角、面积增长特性、和圆形度特征，利用Matlab强大的图像处理功能作为分析工具，并且在算法上有所变化，在确保检测精度的基础上，缩短了检测的时间，提高了检测精度。

# 研究的基本内容：
<p>1、对检测图像的抽样分割过程。</p>
<p>2、将图像转换为二进制图像并去除图像中的大部分信息而只保留关键特征的过程。</p>
<p>3、使用中值滤波算法对图像进行平滑处理。</p>
<p>4、基于计算外焰圆度对图像进行轮廓特征识别。</p>
<i>拟解决的主要问题：从像素过多的图像中来抽取有效信息；对图像进行从RGB到HSI的转换分割；将图像转换为二进制图像并保留关键信息；通过MATLAB编写程序实现算法。</i>

# 检测步骤：
<p>1、基于MATLAB，实现对特定文件夹内的图像的进行读取并保存。</p>
<p>2、基于MATLAB，实现火焰特征检测，对图像进行火焰特征提取。</p>
<p>3、基于MATLAB，实现图像二值化转变，进行图像平滑处理。</p>
<p>4、基于MATLAB，实现图像对颜色分析，当RGB分量中R分量数值大于190即可判定为疑似有火焰出现，继续进行一下步骤。当图片中R分量数值无大于190的数字，即判定没有火焰，并检测完毕。</p>
<p>5、基于MATLAB，编写圆形度计算程序，对实现图片圆形度进行观察分析。由圆度的计算公式可得，当圆度为1时，图形即为圆形。正方形的圆度为约为0.79,等边三角形的圆度约为0.60。圆度越小，图形与圆形之间的差异也越大，图形也越不规律。若图像的上部分存在大圆度小于0.60的部分，图像以下存在一块巨大的、圆度远小于0.60的部分，则可以认为存在火焰。
