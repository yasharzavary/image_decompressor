![NoC](https://people.ece.cornell.edu/land/courses/ece5760/FinalProjects/f2009/jl589_jbw48/jl589_jbw48/dataflow.png)

# Hardware Implementation of an Image Decompressor
![Repo Size](https://img.shields.io/github/repo-size/yasharzavary/image_decompressor)
![Last Commit](https://img.shields.io/github/last-commit/yasharzavary/image_decompressor)
![Issues](https://img.shields.io/github/issues/yasharzavary/image_decompressor)
![Pull Requests](https://img.shields.io/github/issues-pr/yasharzavary/image_decompressor)
![Stars](https://img.shields.io/github/stars/yasharzavary/image_decompressor)
![License](https://img.shields.io/github/license/yasharzavary/image_decompressor)
![VHDL](https://img.shields.io/badge/HDL-VHDL-blue)
![FPGA](https://img.shields.io/badge/Hardware-FPGA-blue)
![RTL Design](https://img.shields.io/badge/Design-RTL-green)
![Digital Design](https://img.shields.io/badge/Domain-Digital%20Design-orange)
![Quartus Prime](https://img.shields.io/badge/Tool-Quartus%20Prime-00599C)
![Intel FPGA](https://img.shields.io/badge/FPGA-Intel-blue)
![Image Decompression](https://img.shields.io/badge/Application-Image%20Decompression-red)
![DSP](https://img.shields.io/badge/Field-DSP-green)
![Hardware Acceleration](https://img.shields.io/badge/Type-Hardware%20Accelerated-purple)
![Release](https://img.shields.io/github/v/release/yasharzavary/image_decompressor)
![Release Date](https://img.shields.io/github/release-date/yasharzavary/image_decompressor)

⭐ Star on GitHub — your support motivates us a lot! 🙏😊

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Follow-blue?logo=linkedin)](https://www.linkedin.com/in/yashar-zavary-rezaie/)
[![Telegram](https://img.shields.io/badge/Telegram-Join-blue?logo=telegram)](https://t.me/YZR_Computer)


## Table of content
1. [Project Description](#Project-Description)
    - Input RGB image
        - colorspace conversion
        - downsampling
        - signal transform
        - quantization
        - lossless coding
        - add header and hardware ID
    - output RGB image
        - Future plan
2. [Hardware Description](#Hardware-Description)
    - RAM


## Project Description
In this project, we will implement a custom image decompressor revision 11 specified in hardware.  
Compressed data for a 320x240 pixel image will be delivered to the Altera DE2 board via the Universal Asynchronous Receiver/Transmitter (UART) interface from a personal computer (PC) and stored in the external static random access memory (SRAM). The image decoding circuitry will read the compressed data, recover the image using a custom digital circuit, and store it back in the SRAM, from where the Video Graphics Array (VGA) controller will read it and display it on the monitor.

### Input RGB Image
In this part, the image is input to the circuit, and the FPGA performs these steps on it:

#### Colorspace Conversion
In this step, the RGB image will be converted to a YUV image using this matrix.  
The conversion from RGB to YUV can be expressed as:


$$
\begin{aligned}
\begin{bmatrix}
Y \\
U \\
V
\end{bmatrix}
&=
\begin{bmatrix}
0.257 & 0.504 & 0.098 \\
-0.148 & -0.291 & 0.439 \\
0.439 & -0.368 & -0.071
\end{bmatrix}
\begin{bmatrix}
R \\
G \\
B
\end{bmatrix}
+
\begin{bmatrix}
16 \\
128 \\
128
\end{bmatrix}
\end{aligned}
$$


#### Downsampling
We know that in an image, Y (brightness) is the main component that the human eye can detect, while U and V chroma components are less perceptible. Therefore, we downsample the U and V chroma matrices by 2 (horizontal downsampling, not vertical, because vertical downsampling would change the image height). In the end, only 2/3 of the total data remains.

#### Signal Transform
In this part, we use DCT to reduce high-frequency signals so that the image can be compressed without dramatically affecting the overall quality of the image.

$$
C_{i,j} = \alpha(i)\cos\left(\frac{\pi}{8} i \left(j + \tfrac{1}{2}\right)\right)
$$

$$
\text{where } 
\alpha(i) =
\begin{cases}
\sqrt{\tfrac{1}{8}} & i = 0 \\
\sqrt{\tfrac{2}{8}} & i > 0
\end{cases}
$$

#### Quantization
After DCT, we quantize the image. It is done by simply dividing our 8x8 block by the quantization matrix:

$$
Q_0 =
\begin{bmatrix}
8 & 4 & 8 & 8 & 16 & 16 & 32 & 32 \\
4 & 8 & 8 & 16 & 16 & 32 & 32 & 64 \\
8 & 8 & 16 & 16 & 32 & 32 & 64 & 64 \\
8 & 16 & 16 & 32 & 32 & 64 & 64 & 64 \\
16 & 16 & 32 & 32 & 64 & 64 & 64 & 64 \\
16 & 32 & 32 & 64 & 64 & 64 & 64 & 64 \\
32 & 32 & 64 & 64 & 64 & 64 & 64 & 64 \\
32 & 64 & 64 & 64 & 64 & 64 & 64 & 64
\end{bmatrix}
$$

or

$$
Q_1 =
\begin{bmatrix}
8 & 2 & 2 & 2 & 4 & 4 & 8 & 8 \\
2 & 2 & 2 & 4 & 4 & 8 & 8 & 16 \\
2 & 2 & 4 & 4 & 8 & 8 & 16 & 16 \\
2 & 4 & 4 & 8 & 8 & 16 & 16 & 16 \\
4 & 4 & 8 & 8 & 16 & 16 & 16 & 32 \\
4 & 8 & 8 & 16 & 16 & 16 & 32 & 32 \\
8 & 8 & 16 & 16 & 16 & 32 & 32 & 32 \\
8 & 16 & 16 & 16 & 32 & 32 & 32 & 32
\end{bmatrix}
$$

with the following formula:

$$
Z = round(S' / Q_0)
$$

$$
[Z]_{i,j} = round([S']_{i,j} / [Q_0]_{i,j})
$$

#### Lossless Coding
Now we can scan our matrix and use a lossless coding algorithm to get the final image.

For scanning, we will use this scan pattern:


$$
\text{ZigZag Order} =
[\
0, 1, 8, 16, 9, 2, 3, 10,\
17, 24, 32, 25, 18, 11, 4, ...
]
$$

For the matrix:


$$
\begin{bmatrix}
0 & 1 & 2 & 3 & 4 & 5 & 6 & 7 \\
8 & 9 & 10 & 11 & 12 & 13 & 14 & 15 \\
16 & 17 & 18 & 19 & 20 & 21 & 22 & 23 \\
24 & 25 & 26 & 27 & 28 & 29 & 30 & 31 \\
32 & 33 & 34 & 35 & 36 & 37 & 38 & 39 \\
40 & 41 & 42 & 43 & 44 & 45 & 46 & 47 \\
48 & 49 & 50 & 51 & 52 & 53 & 54 & 55 \\
56 & 57 & 58 & 59 & 60 & 61 & 62 & 63
\end{bmatrix}
$$


After this, we use the following algorithm to get the final compressed image:

1. **Only zeros remain in the block**: `ZEROS_TO_END` header (bits `111`)
2. **A run of zeros exists but some nonzero coefficients still remain in the block**: output the `ZERO_RUN` header (bits `110`) and then:
   - If the run of zeros is 8 or more in length, output `000` (3 bits) and repeat step 2 if necessary.
   - If the run of zeros is less than 8, output a 3-bit unsigned number indicating the length of the run.
3. **A run of ones exists**: output `POSITIVE_ONE_RUN` header (bits `101`) and then:
   - If the run of ones is 4 or more in length, output `00` (2 bits) and repeat step 3 if necessary.
   - If the run of ones is less than 4, output a 2-bit unsigned number indicating the length.
4. Repeat step 3 for **runs of -1** with `NEGATIVE_ONE_RUN` header (bits `100`).
5. **The value is between -8 and 7 (excluding -1, 0, 1)**: output `4_BIT` header (bits `01`) followed by the 4-bit signed value.
6. **The value is between -256 and 255 (excluding -8 to 7)**: output `9_BIT` header (bits `00`) followed by the 9-bit signed value.

For example, for this matrix:


$$
\begin{bmatrix}
127 & -1 & 0 & 0 & 0 & 0 & 0 & 0 \\
-2 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 0
\end{bmatrix}
$$


After scanning, we will have:


$$
127, -1, -2, 0, 0, 0, ...
$$


- **127**: step 6 → `00` (header) + `001111111` → `00001111111`
- **-1**: negative one run (step 4) → `100` (header) + `01` (run length indicator) → `10001`
- **-2**: value between -8 and 7 (step 5) → `01` (header) + `1110` → `011110`
- **zeros**: zero-to-end (step 1) → `111`

In the end, our code for the matrix will be:
0000111111110001011110111


Now we can repeat this for other blocks, add the header and hardware ID, and store it.

#### Add Header and Hardware ID
After the lossless coding step, we should add the `.mic` identifier (4-byte hex value **DEADBEEF**), one bit to identify the quantization matrix, followed by 15 bits for width and 16 bits for height identifiers.  
After this, our data will be stored in the memory.

you can check flowchart of image compressing from [draw.io](https://drive.google.com/file/d/1hQkjxFl8IbY9iDqIVWa1vJVeeCghfYez/view?usp=sharing)


## Hardware Description
👉 [RAM](section_readmes/Ram.md)

### RGB2YUV conversion

After loading the data, we should convert it to YUV. For this, we create a circuit that counts from 0 to 76799 and converts each data sample to YUV. The circuit used for this operation is shown in the picture.

Our formula for converting each component is as follows:

$$
Y = 0.257R + 0.504G + 0.098B + 16\\
U = (-0.148)R + (-0.291)G + 0.439B + 128\\
V = 0.439R + (-0.368)G + (-0.071)B + 128
$$

However, we know that **floating-point operations are difficult to implement in hardware**, so we use **scaling and bit shifting to obtain a hardware-friendly form**, resulting in:

$$
Y = (66R + 129G + 25B + 4096) \gg 8\\
U = (-38R - 74G + 112B + 32768) \gg 8\\
V = (112R - 94G - 18B + 32768) \gg 8
$$

> **NOTE:** Each coefficient is multiplied by 256, and after performing the operations, we shift the result by 8 bits (divide by 256).

When the start bit becomes 1, the counter resets to zero and the operation begins. After the counter reaches 76799, the conversion must stop. For this, we `AND` the start bit with a `done_bit`, so when the operation is completed, it sets the operation bit to zero, indicating that the conversion is finished. After this, it produces a signal named `DS_bit`, which starts the downsampling operation.

> **NOTE:** For multiplication, we decompose constants as follows:

$$
66R = (64 + 2)R = (R << 6) + (R << 1)
$$

So we implement it as:

$$
Y =
((R << 6) + (R << 1)) +
((G << 7) + G) +\\
((B << 4) + (B << 3) + B) +
4096
\gg 8
$$

$$
U =
-((R << 5) + (R << 1) + R) -\\
((G << 6) + (G << 3) + (G << 2) + G) +\\
((B << 6) + (B << 5) + (B << 4)) +
32768
\gg 8
$$

$$
V =
((R << 6) + (R << 5) + (R << 4)) -\\
((G << 6) + (G << 4) + (G << 3) + (G << 2) + (G << 1))\\
- ((B << 4) + (B << 1)) +
32768
\gg 8
$$

For example, for the `red conversion of Y`, we design a circuit like this:

- Main circuit  
![red_conversion_of_Y](pictures/red_conversion_of_Y.jpg)

- increase_to_16 function  
![increase_16](pictures/increase_16.jpg)

- shift by 4  
![shift_4](pictures/shift_4.jpg)

The full Y conversion circuit is shown below:  
![Y_conversion](pictures/Y_conversion.jpg)

now we connect Y & U & v conversion in the main circuit, we add connections to `RAM` and start and load bits for it.

The main system is like this:
