# Object Capturer

使用RealityKit的Object Capture从若干图像生成物体的3D模型。

## 概要

- 注意: 该项目基于Apple的一个实例项目完成，可参考 WWDC21 session [10076: Create 3D Models with Object Capture](https://developer.apple.com/wwdc21/10076/).
- 这是一个可以从图像生成3D模型的macOS应用程序。未来，我希望我能将苹果提供的特别的拍照iOS App集成到这个项目中，以便于在iPhone上完成拍摄。

## 要求

### 操作系统

- macOS Monterey 12.0.1 或更高

### 设备

- 所有搭载Apple Silicon的Mac
- 配备16G或以上RAM的英特尔Mac且配备4G VRAM或更多的AMD显卡。

## 如何使用

### 照相

使用包括iPhone、iPad或数码相机在内的任何设备拍摄一个物体的若干照片。

如果您的设备有LiDAR激光雷达将会更好。

建议照片的数量在20到200之间。

隔空投送或通过其他方式将所有照片传输到Mac上的一个文件夹中。

更多详细信息，请访问https://developer.apple.com/documentation/realitykit/capturing_photographs_for_realitykit_object_capture

### 支持的格式

Heif/Heic (推荐), Jpg, Png等。

不需要您按任何特定顺序拍摄图像或以特定方式命名图像。

### 建模

打开应用程序

选择源路径：包含上述图像的文件夹

选择目标路径

输出文件名：如果为空，输出文件名将为 output.usdz。（你不需要在末尾添加“.usdz”）

开始

等待完成，并希望不会发生错误。

可以直接打开输出的文件。全部完成。

