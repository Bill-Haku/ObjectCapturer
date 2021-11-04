# Object Capturer

Generate 3D objects from images using RealityKit Object Capture.

## Overview

- Note: This project is based on a sample project from Apple associated with WWDC21 session [10076: Create 3D Models with Object Capture](https://developer.apple.com/wwdc21/10076/).
- This is a macOS App that can generate 3D objects from images. In the future I hope I can integrate the app provided by Apple to facilitate shooting on iPhone into this project.

## Requirments

### OS

- macOS Monterey 12.0.1 or above

### Device

- All Macs with Apple Silicon.
- Intel Macs with 16G RAM or above and AMD GPU with 4G VRAM or above.

## How to Use it

### Take Photos

Use any device including iPhone, iPad or camera to take photos of one object.

It would be better if you use devices with LiDAR.

The number of the photo is suggested to be between 20 and 200.

AirDrop of copy all the photos into a folder on your Mac

For details, you can see at https://developer.apple.com/documentation/realitykit/capturing_photographs_for_realitykit_object_capture

### Supported formats

Heif/Heic (recommended), Jpg, Png, etc.

It doesn’t require you to take images in any specific order or name them in a specific way.

### Generate the Model

Open the app

Choose the source path: the folder of the images

Choose the destination path

Output file name: if it is empty, the output file name will be output.usdz. (You don't need to write a ".usdz" at the end)

Start

Wait for it and hope no error will happen.

You can open the output file directly. All done.

