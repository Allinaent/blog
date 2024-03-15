+++
title = "mesa 中的概念和代码介绍"
date = 2024-01-11T10:00:00+08:00
lastmod = 2024-03-16T00:51:08+08:00
categories = ["graphic"]
draft = false
toc = true
image = "ox-hugo/img_20240119_171126.jpg"
+++

## mesa 中的一些基本概念 {#mesa-中的一些基本概念}

mesa 这个项目是图形系统中的重要的一层。

-   mesa 的 3d 库有哪些？

Mesa 提供了多个 3D 图形库，用于实现不同的图形 API。以下是 Mesa 中一些常见的 3D 图形库：

OpenGL: Mesa 提供了 OpenGL 的实现，包括 OpenGL 2.1、OpenGL 3.x 和 OpenGL 4.x 等版本。这些实现包括了 OpenGL 渲染器、顶点/像素处理器、纹理映射器、帧缓冲等功能。

Vulkan: Mesa 提供了 Vulkan 的实现，用于支持 Vulkan API。Vulkan 是一个底层的、跨平台的图形 API
，能够提供更好的性能和更细粒度的控制。

OpenCL: Mesa 提供了 OpenCL 的实现，用于支持 OpenCL API。OpenCL 是一个用于并行计算的开放标准，可以在不同的硬件上执行通用计算任务。

EGL: Mesa 提供了 EGL（Embedded System Graphics Library）的实现，它是一个用于在嵌入式系统中管理图形资源的库。EGL 提供了与窗口系统的交互、创建和管理 OpenGL ES 上下文等功能。

除了以上列举的 3D 图形库，Mesa 还有其他一些辅助库，用于支持特定的功能或硬件，比如 GBM
（Generic Buffer Manager）用于管理基于硬件的缓冲区对象，以及 Gallium3D 驱动架构用于简化图形驱动程序的开发等。

请注意，Mesa 的具体库和功能取决于编译时的配置和选项，可能会有一些变化。你可以根据自己的需求选择合适的库进行编译和使用。

-   为什么起名为 gallium3d，镓这个名字是从何而来？

Gallium3D 的名字来源于元素周期表中的镓（Gallium），这是一个化学元素符号为 Ga 的金属元素。
Gallium3D 项目最初由 Brian Paul 发起，他选择以镓作为项目的命名灵感来自于镓这个元素的特性和应用。

镓是一种具有特殊性质和广泛应用的金属元素。它的特点之一是与其他元素形成合金时，可以改变合金的性能。同样，Gallium3D 项目的目标是提供一个可扩展的图形驱动架构，使开发人员能够根据需要针对不同的图形硬件进行优化和定制。

另外，镓还具有低熔点、低毒性等特性，这使得它在电子设备和半导体行业中有广泛的应用。类似地，Gallium3D
项目旨在提供一个灵活易用的图形驱动框架，可以用于各种嵌入式系统和图形应用。

因此，Gallium3D 名称的选取是一种象征，代表了该项目的灵活性、适应性和广泛的应用范围，类似于镓在化学和工业领域的特性和应用。

关于取名，国内国外都讲究什么信达雅之类的东西。我只是觉得拗口无趣，名字取的怪好的，心思都花在这个上面，对于是否适合理解这种基本的需求反而弱化了。语言的本质还是为了交流的，对于我这种缺少耐心的人，根本就是讨厌这种乱七八糟起名字的行为。略略略。

-   chromium 流览器的名字也是这么来的吗？

不，Chromium 浏览器的名字并不是来源于镓元素。Chromium 是谷歌公司开发的开源浏览器项目，它的名字来自于铬（Chromium）这个化学元素。

铬是一个化学元素，其符号为 Cr。它与铁类似，具有良好的耐腐蚀性能和高温稳定性。因此，谷歌选择了铬作为项目名称，以体现 Chromium 浏览器的稳定性和安全性。

Chromium 浏览器是基于开源项目开发的，其代码库也称为 Chromium。谷歌将其作为 Google Chrome 浏览器的基础，并与全球开发者社区合作进行开发和改进。Chromium 浏览器的开源性质使得其他浏览器如 Opera、Brave
等也可以基于 Chromium 项目进行开发。

总而言之，Chromium 浏览器的名字来自于铬元素，强调了该浏览器的稳定性和安全性。而 Gallium3D 项目的命名则是基于镓元素，代表了该项目的灵活性和广泛应用的特点。

```bash
uos@guolongji:~/gg/mesa$ tree -A -d -L 3
.
├── bin
├── build-support
├── debian
│   ├── local
│   ├── patches
│   ├── source
│   └── upstream
├── docs
│   ├── relnotes
│   └── specs
│       └── OLD
├── doxygen
├── include
│   ├── c11
│   ├── CL
│   ├── D3D9
│   ├── d3dadapter
│   ├── drm-uapi
│   ├── EGL
│   ├── GL
│   │   └── internal
│   ├── GLES
│   ├── GLES2
│   ├── GLES3
│   ├── HaikuGL
│   ├── KHR
│   ├── pci_ids
│   └── vulkan
├── m4
├── scons
└── src
    ├── amd
    │   ├── addrlib
    │   ├── common
    │   └── vulkan
    ├── broadcom
    │   ├── cle
    │   ├── clif
    │   ├── common
    │   ├── compiler
    │   └── qpu
    ├── compiler
    │   ├── glsl
    │   ├── nir
    │   └── spirv
    ├── egl
    │   ├── drivers
    │   ├── generate
    │   ├── main
    │   └── wayland
    ├── gallium
    │   ├── auxiliary
    │   ├── docs
    │   ├── drivers
    │   ├── include
    │   ├── state_trackers
    │   ├── targets
    │   ├── tests
    │   ├── tools
    │   └── winsys
    ├── gbm
    │   ├── backends
    │   └── main
    ├── getopt
    ├── glx
    │   ├── apple
    │   ├── tests
    │   └── windows
    ├── gtest
    │   ├── include
    │   └── src
    ├── hgl
    ├── intel
    │   ├── blorp
    │   ├── common
    │   ├── compiler
    │   ├── dev
    │   ├── genxml
    │   ├── isl
    │   ├── tools
    │   └── vulkan
    ├── loader
    ├── mapi
    │   ├── es1api
    │   ├── es2api
    │   ├── glapi
    │   └── shared-glapi
    ├── mesa
    │   ├── drivers
    │   ├── main
    │   ├── math
    │   ├── program
    │   ├── sparc
    │   ├── state_tracker
    │   ├── swrast
    │   ├── swrast_setup
    │   ├── tnl
    │   ├── tnl_dd
    │   ├── vbo
    │   ├── x86
    │   └── x86-64
    ├── util
    │   ├── sha1
    │   ├── tests
    │   └── xmlpool
    └── vulkan
        ├── registry
        ├── util
        └── wsi
```

gpt 是一个聪明的机器，他知道很多事情，就是不能像人一样做实验，否则我应该就被淘汰了。

-   mesa 最外层的 include 目录是干什么用的？

Mesa 是一个开源的图形库，用于实现图形渲染和加速功能。最外层的 include 目录在 Mesa 中扮演着重要的角色。

include 目录包含了 Mesa 图形库的公共头文件。这些头文件定义了 Mesa 库提供的函数、数据结构和常量等，以及与图形渲染相关的其他信息。通过包含这些头文件，开发人员可以在自己的项目中使用 Mesa 库提供的功能，并进行图形渲染的操作。

最外层的 include 目录通常是作为 Mesa 库的公共接口，供外部应用程序或其他库使用。开发人员可以直接引用这些头文件，以访问 Mesa 库的功能，并在自己的代码中进行图形渲染和加速的操作。

总结来说，Mesa 最外层的 include 目录中的头文件提供了 Mesa 库的公共接口，允许开发人员在自己的项目中使用 Mesa 库的功能和特性，从而实现图形渲染和加速的需求。

-   这个 include 目录为什么不写在 src 目录里面呢？

将 include 目录放在 Mesa 的最外层而不是 src 目录中，是为了将公共头文件与实现代码分开，以提高代码的可维护性和可重用性。

这种组织方式有几个好处：

**清晰的分离**: 将公共头文件放在 include 目录中可以使开发人员清晰地区分哪些文件是用于公共接口的声明，哪些是用于内部实现的代码。这种分离有助于提高代码结构的清晰度，并使项目更易于理解和维护。

**可重用性**: 通过将公共头文件放在 include 目录中，其他开发人员可以轻松地包含这些头文件并使用 Mesa 库的功能。这提供了一种重用代码的机制，允许其他项目或库依赖于 Mesa 的功能，而无需访问实现细节。

**编译隔离**: 将公共头文件放在 include 目录中，可以确保只有需要访问 Mesa 公共接口的代码才能引用这些头文件。这样，可以避免将实现细节暴露给外部代码，同时保护代码的安全性和稳定性。

总之，将 include 目录放在 Mesa 的最外层而不是 src 目录中，是一种常见的组织代码的方式，有助于提高代码的可维护性、可重用性和安全性。

-   mesa 中的 src/compiler 目录是什么？

在 Mesa 图形库中，src/compiler 目录包含了与编译器相关的代码和实现。这个目录中的文件主要用于处理 OpenGL 和 Vulkan 等图形 API 的着色器代码的编译和优化。

具体来说，src/compiler 目录包含以下内容：

**GLSL 编译器**: 这个目录下包含了用于编译 OpenGL 着色器语言（GLSL）代码的相关功能和算法。GLSL 编译器负责将 GLSL 代码转换成低级的图形硬件能够理解的形式，并进行一些优化操作。

\*SPIR-V 编译器\*：SPIR-V 是一种用于表示着色器代码的中间语言，它可以在不同的图形 API 之间进行转换和交流。src/compiler 目录中的文件包含了与 SPIR-V 编译器相关的功能和算法，负责将 GLSL 代码或其他输入转换为 SPIR-V 形式。

**优化器和分析器**: src/compiler 目录还包含了一些优化器和分析器的实现，用于对着色器代码进行性能优化和分析。这些组件可以帮助提高着色器的执行效率，并生成更高质量的图形渲染结果。

总之，src/compiler 目录是 Mesa 图形库中用于处理 OpenGL 和 Vulkan 着色器代码编译和优化的部分。它包含了 GLSL 编译器、SPIR-V 编译器以及一些优化器和分析器的实现。这些功能和算法的存在可以帮助开发人员更好地管理和优化图形渲染过程。

-   mesa 中的 src/egl 目录是什么？

在 Mesa 图形库中，src/egl 目录包含了与 EGL（Embedded System Graphics Library）相关的代码和实现。EGL 是一个用于管理图形渲染上下文、表面和设备之间交互的 API。

具体来说，src/egl 目录包含以下内容：

**EGL 实现**: 这个目录下包含了 EGL API 的实现，包括函数调用的处理和与底层图形系统的交互。这些代码负责创建和管理 EGL 上下文，并提供与 OpenGL 和其他图形 API 之间的交互。

**平台特定的 EGL 驱动**: src/egl 目录还包含了一些特定平台的 EGL 驱动程序，用于与不同的操作系统和硬件平台进行交互。这些驱动程序负责与底层图形系统进行通信，并提供相应的功能和接口。

**扩展支持**: Mesa 的 EGL 实现还支持一些扩展，用于提供额外的功能或与特定平台进行交互。这些扩展的实现也可以在 src/egl 目录中找到。

总之，src/egl 目录是 Mesa 图形库中用于实现 EGL API 和与底层图形系统交互的部分。它包含了 EGL 的实现、平台特定的 EGL 驱动程序以及一些扩展支持。这些功能和接口的存在可以帮助开发人员在嵌入式系统中更方便地管理图形渲染上下文、表面和设备之间的交互。

-   GLSL 语言是什么？

GLSL（OpenGL Shading Language）是一种用于编写着色器程序的高级编程语言。它是 OpenGL 图形 API 的一部分，用于控制图形渲染管线中的顶点和像素处理阶段。

GLSL 提供了一种编写可在 GPU 上执行的着色器程序的方式。着色器程序是一组特殊的函数，用于对图形数据进行处理和计算。在 OpenGL 中，顶点着色器（Vertex Shader）用于处理输入顶点数据，而片段着色器（Fragment Shader）用于处理每个像素的颜色。

GLSL 具有类 C 语言的语法结构，但它专门设计用于图形渲染任务，并包含了一些与图形处理相关的特性。
GLSL 语言支持向量和矩阵操作、条件语句、循环控制等常见的编程语言特性，并提供了丰富的内置函数和变量来方便编写着色器程序。

通过编写 GLSL 代码，开发人员可以自定义图形渲染管线中的顶点和像素处理过程，实现各种图形效果和计算任务。GLSL 着色器程序可以在 GPU 上并行执行，充分利用 GPU 的计算能力，从而实现高性能的图形渲染和计算任务。

总之，GLSL 是 OpenGL Shading Language 的缩写，它是一种用于编写着色器程序的高级编程语言。

-   mesa 中的 src/gbm 目录是什么？

在 Mesa 图形库中，src/gbm 目录是一个与 GBM（Generic Buffer Manager）相关的代码和实现。GBM 是一个用于管理显存缓冲区的 API，它可以帮助开发人员在不同的图形系统之间共享显存缓冲区。

具体来说，src/gbm 目录包含以下内容：

**GBM 实现**: 这个目录下包含了 GBM API 的实现，包括函数调用的处理和与底层图形系统的交互。这些代码负责创建和管理 GBM 缓冲区对象，并提供与 EGL 和其他图形 API 之间的交互。

**平台特定的 GBM 驱动**: src/gbm 目录还包含了一些特定平台的 GBM 驱动程序，用于与不同的操作系统和硬件平台进行交互。这些驱动程序负责与底层图形系统进行通信，并提供相应的功能和接口。

**扩展支持**: Mesa 的 GBM 实现还支持一些扩展，用于提供额外的功能或与特定平台进行交互。这些扩展的实现也可以在 src/gbm 目录中找到。

总之，src/gbm 目录是 Mesa 图形库中用于实现 GBM API 和与底层图形系统交互的部分。它包含了 GBM 的实现、平台特定的 GBM 驱动程序以及一些扩展支持。这些功能和接口的存在可以帮助开发人员在不同的图形系统之间共享显存缓冲区，从而提高图形渲染的效率。

-   mesa 中的 src/glx 目录是什么？

在 Mesa 图形库中，src/glx 目录包含与 GLX（OpenGL Extension to the X Window System）相关的代码和实现。GLX 是在 X Window System 上使用 OpenGL 的扩展，它提供了 OpenGL 渲染上下文的创建、管理和交互的功能。

具体来说，src/glx 目录包含以下内容：

**GLX 实现**: 这个目录下包含了 GLX API 的实现，包括函数调用的处理和与底层 X Window System 的交互。这些代码负责创建和管理 GLX 渲染上下文，并提供与 X Window System 和 OpenGL 之间的交互。

**GLX 扩展支持**: Mesa 的 GLX 实现还支持一些扩展，用于提供额外的功能或与特定平台进行交互。这些扩展的实现也可以在 src/glx 目录中找到。

**平台特定的 GLX 驱动**: src/glx 目录还包含了一些特定平台的 GLX 驱动程序，用于与不同的操作系统和硬件平台进行交互。这些驱动程序负责与底层 X Window System 进行通信，并提供相应的功能和接口。

总之，src/glx 目录是 Mesa 图形库中用于实现 GLX API 和与底层 X Window System 交互的部分。它包含了 GLX 的实现、扩展支持以及平台特定的 GLX 驱动程序。这些功能和接口的存在可以帮助开发人员在 X Window System 上使用 OpenGL 进行图形渲染，并提供与 X Window System 和其他图形 API
之间的交互。

简单来说就是 opengl 对 X11 实现的支持部分。

-   src/hgl 目录是干什么的？haiku 这个操作系统是干什么的？

Haiku 是一个开源的操作系统，旨在提供简单、高效和现代化的计算环境。它最初是为了取代 BeOS 而开发的，因此继承了 BeOS 的一些设计理念和特性。

Haiku 的目标是提供用户友好的界面和稳定的系统性能。它专注于桌面计算，并致力于提供一种简洁而富有创意的用户体验。Haiku 的设计理念强调响应速度、可靠性和一致性。

Haiku 具有以下特点：

**轻量级**: Haiku 采用精简的设计和优化的代码，使其在资源消耗上非常高效。这使得它适合在较低配置的硬件上运行。

**响应速度**: Haiku 旨在提供快速且即时的用户体验。它使用了一个基于消息传递的体系结构，以确保系统对用户输入的响应迅速而及时。

**多任务处理**: Haiku 支持多任务处理，允许用户同时运行多个应用程序，并通过窗口管理器进行管理。

**多媒体功能**: Haiku 内置了各种多媒体功能，包括音频和视频播放、图像处理和其他多媒体工具。

**开放源代码**: Haiku 是一个开源项目，这意味着任何人都可以访问、使用和贡献代码。

总之，Haiku 是一个专注于桌面计算的开源操作系统，旨在提供简洁、高效和稳定的用户体验。它具有轻量级、响应速度快以及多媒体功能丰富等特点。

所以这个是为了技术派支持添加的一个操作系统。他们很厉害，BeOS 在当时也是很先进的。商业不成功但是技术成功。真是一件悲哀的事。

-   mesa 演进的一个说明

<https://blog.csdn.net/HaoBBNuanMM/article/details/109054106>

Gallium3D 对比非 Gallium3D 架构，Vendor 和平台相关的实现移到了 HW Vendor Driver 和 WinSys 模块的具体实现中，libmesa_dri_drivers 面向 Gallium3D 提供的接口实现 EGL 和 GLES 的调用，实现了 API OS HW 的三层分离。

也就是说，做了一个软件架构的重构和抽取。

-   src/mapi 和 src/mesa 这两个文件夹的区别是什么？

src/mapi 文件夹是 Mesa 图形库中的一个子目录，它包含了与图形 API 接口相关的代码。这些代码主要负责处理与图形 API 的交互，将 API 调用转发给底层的图形驱动程序或其他模块。src/mapi 中的代码提供了对图形功能的抽象和封装。

而 src/mesa 文件夹是 Mesa 图形库的另一个子目录，它包含了 Mesa 图形库的核心实现，主要集中在图形渲染管线的各个阶段。这些阶段包括顶点处理、图元装配、光栅化、片段处理等。src/mesa 中的代码实现了渲染管线的功能，以及相关的状态管理和优化算法。

简单来说，src/mapi 中的代码处理与图形 API 的交互，而 src/mesa 中的代码实现了渲染管线的各个阶段。

-   src/mapi 的 api 包含哪些功能？

src/mapi 目录中的 API 主要包含了与 OpenGL 和其他图形 API 相关的功能。下面是一些常见的功能：

**OpenGL 函数调用**: Mesa 实现了 OpenGL 标准规范中的核心函数和扩展函数。这些函数可以在应用程序中调用，以执行各种图形操作，例如顶点处理、着色器程序设置、纹理操作、帧缓冲操作等。

**Gallium3D 接口**: Gallium3D 是 Mesa 中的一个模块化图形驱动架构，它提供了一套通用的 API 接口，用于处理图形硬件功能。src/mapi 目录中的代码实现了与 Gallium3D 接口的交互，以便各个驱动程序能够利用 Gallium3D 提供的功能。

**其他图形 API 支持**: 除了 OpenGL，Mesa 还支持其他图形 API，如 OpenCL、Vulkan 等。src/mapi 目录中的代码也包括这些 API 的实现和相关功能。

**状态管理**: Mesa 中有许多图形状态需要进行管理和跟踪，例如着色器程序、纹理对象、帧缓冲等。src/mapi 目录中的代码负责维护和管理这些状态，并提供对它们的访问和操作接口。

总的来说，src/mapi 目录中的 API 提供了与 OpenGL 和其他图形 API 的交互功能，包括函数调用、状态管理以及对特定图形 API 的支持。这些 API 使得应用程序能够通过 Mesa 库与底层的图形硬件进行交互和操作。

-   src/mesa 的目录的作用是什么？

在 Mesa 图形库中，src/mesa 目录包含了与图形渲染管线和图形处理相关的代码。这个目录下的代码实现了 Mesa 图形库的核心功能，包括：

图形渲染管线: Mesa 实现了图形渲染管线的各个阶段，包括顶点处理、图元装配、光栅化、片段处理等。src/mesa 目录中的代码实现了这些阶段的功能，并提供了对 OpenGL API 的支持。

状态管理: Mesa 中有许多图形状态需要进行管理和跟踪，例如着色器程序、纹理对象、帧缓冲等。src/mesa 目录中的代码负责维护和管理这些状态，并提供对它们的访问和操作接口。

图形算法和优化: Mesa 中的一些图形算法和优化技术也是在 src/mesa 目录下实现的。例如，三角形剔除、深度测试、多重采样等功能都在这个目录的代码中。

总的来说，src/mesa 目录包含了 Mesa 图形库的核心功能实现，包括图形渲染管线的各个阶段、状态管理以及一些图形算法和优化。与之相对应，src/mapi 目录则包含了与 API 接口相关的代码，实现了与 OpenGL 和其他图形 API 的交互。这样的划分可以使得 Mesa 的代码结构更加清晰和模块化。

总的来说 mapi 是和底层打交道比较多的部分；而 mesa 目录是渲染流程的处理。

小知识，儒释道的产生几乎算是同时期出现的，但是道教是从西汉的黄老之说到从东汉时期正式产生。

1、相当于中国的春秋末期或者说是东周或者说是诸侯争霸（春秋五霸）的时代；

2、历史上的佛陀，也就是乔达摩悉达多，生于公元前 563 圆寂于公元前 483 年另有释迦牟尼生于公元前 565 年，灭于公元前 486 年说。但是年代大致不会差很多，一定在中国东周时期这个范围内；

3、和孔子（前 551——479）生活在几乎同一个时代；

4、公元前 770 到公元前 476 年左右（田氏代齐、三家分晋）等相当于中国历史上的春秋时期，司马光的《资治通鉴》就是以三家分晋开始写战国历史的，所以佛陀是春秋时代的人，和中国诸子百家齐争鸣同在一个时代。

所以春秋时期才是思想刚刚出现的朴素时期。那个时代人类的想像力和社会实践有了空前的发展。后面二千年的封建王朝时间，好像社会发展了，但是真的发展的比较慢。只到 1650 年左右，又过了将近 1700 年，人类才走向了自然科学发展的黄金时期，或许，人类的发展就是这样。时快时慢的，大的突破需要很多代人，才能产生一个天之骄子，带领人类走向文明新的阶段。

壮哉，我的大人类。“一群小土豆也妄想窥视宇宙的真理”，是啊，人类的妄想。这个世界真是神奇的过了头了。


## 如何看 mesa 代码 {#如何看-mesa-代码}

-   看 mesa 的代码要从顺着哪条线来看呢？

要理解 Mesa 的代码，可以按照以下线索来进行阅读：

**入口点** ：从 src/loader，这是程序的入口点，提供了 Mesa 库的初始化和主要功能。

**平台相关代码** ：在 src/mesa/main 和 src/mesa/drivers 中，可以找到与特定图形 API 和平台相关的代码。例如，src/mesa/main/context.c 包含了与 OpenGL 上下文相关的功能，而 src/mesa/drivers/dri/common 则包含了与 Direct Rendering Infrastructure (DRI) 相关的代码。

**核心实现** ：进入 src/mesa 目录，从 main 子目录开始，逐步深入各个子目录，如 arrayobj、shader、texobj 等。这些子目录包含了实现 Mesa 图形库核心功能的代码，涵盖了渲染管线中的各个阶段。

**驱动程序** ：如果对特定的图形硬件感兴趣，可以查看 src/mesa/drivers 目录中的子目录。不同的子目录代表了不同的图形驱动程序，例如 gallium 子目录包含了 Gallium3D 驱动程序。

**可选模块** ：在 src/mesa/program 目录中，可以找到与 GPU 程序编译和链接相关的代码。这些代码用于处理和优化 GPU 程序，并将其与其他 Mesa 组件集成。

阅读 Mesa 的代码可以根据个人的兴趣和需求来选择特定的模块和功能进行深入研究。同时，了解 OpenGL、Vulkan 和其他相关图形 API 的基本原理也会有助于更好地理解 Mesa 的实现。


## mesa 完整流程的顺序是什么样子的？ {#mesa-完整流程的顺序是什么样子的}

Mesa 的完整流程可以大致分为以下几个步骤：

**初始化** ：在程序的入口点（如 src/main 或 src/gallium/main）进行 Mesa 库的初始化，包括创建上下文、加载图形驱动程序等。

**上下文管理** ：在 src/mesa/main/context.c 中，处理与 OpenGL 上下文相关的操作，包括上下文的创建、切换和销毁等。它还负责上下文属性的设置，如渲染器类型、版本号、纹理单元数量等。

**顶点数据处理** ：在 src/mesa/main/vertexarray.c 和 src/mesa/main/varray.c 中，对顶点数据进行处理。这包括对顶点属性的解析、组装和格式转换，以及对顶点缓冲区的管理。

**顶点着色器** ：在 src/mesa/main/program/\* 目录中，进行顶点着色器的编译、链接和优化。这些代码负责将顶点着色器源代码转换为可执行的 GPU 程序。

**图元装配和剪裁** ：在 src/mesa/main/imports.c 和 src/mesa/main/clip.c 中，根据绘制命令将顶点数据装配成图元，并进行视锥体剪裁来确定可见图元。

**几何着色器（可选）** ：如果使用了几何着色器，相关的代码位于 src/mesa/main/program/geometry.c 中。几何着色器对输入图元进行变换和生成新的图元。

**图元装订** ：在 src/mesa/main/vbo/vbo_exec_draw.c 中，对图元进行装订操作，包括应用变换矩阵、执行光栅化等。

**片段着色器** ：在 src/mesa/main/program/\* 目录中，进行片段着色器的编译、链接和优化。这些代码将片段着色器源代码转换为可执行的 GPU 程序。

**光栅化和片段处理** ：在 src/mesa/main/rastpos.c 和 src/mesa/main/drawpix.c 中，进行图元的光栅化和片段处理。这包括插值、纹理采样、深度测试、颜色混合等操作。

**帧缓冲操作** ：在 src/mesa/main/fbobject.c 中，对帧缓冲对象进行管理和操作。包括渲染目标的绑定、解绑，以及帧缓冲的读写操作。

**输出到显示设备** ：在 src/mesa/drivers/\*/context.c 中，将渲染结果输出到显示设备上。这涉及到与硬件和平台相关的操作，如通过 DRI 进行 Direct Rendering。

以上是 Mesa 的大致流程，不同的功能和模块可能有一些细微的差异。此外，Mesa 还涉及到其他方面的功能，如纹理处理、着色器编译和链接、缓存管理等。具体实现的细节会因各个子模块的不同而有所变化。


## 现在看代码 {#现在看代码}

之前明哥分享过 mesa 的库的调用，我看了之前的 ppt ，温故知新（实际上之前根本没记住，都没有什么印象了）。


### mesa 的初始化 {#mesa-的初始化}

{{< figure src="https://r2.guolongji.xyz/img_20240117_102358.jpg" >}}


### opengl 除了 mesa 外还有其它的开源实现吗？ {#opengl-除了-mesa-外还有其它的开源实现吗}

<https://blog.51cto.com/u_6725876/5135511>

好像是没有了， <https://www.khronos.org/> ，科纳斯集团，这个是一个几个大公司成立在美国的一个组织，pervasive ， widespread 。这个组织就是图形，机器学习相关的各种重要领域的接口标准和开源实现。这个组织就是搞这么一件事的。


### opengl 是怎么实现的 {#opengl-是怎么实现的}

是通过状态机实现的：

<https://blog.csdn.net/weixin_44478077/article/details/123985055>

比如，我先设置好一个上下文，然后再调用 glRectf 来进行绘制。

学习 opengl 编程可以看这里：<https://learnopengl-cn.github.io/>

opengl 当中各种库的命名和功能：

-   GLFW: Graphics Library Framework

是配合 OpenGL 使用的轻量级工具程序库，缩写自 Graphics Library Framework（图形库框架）。GLFW 的主要功能是创建并管理窗口和 OpenGL 上下文，同时还提供了处理手柄、键盘、鼠标输入的功能。

-   GLU:

<!--listend-->

-   GLUT: OpenGL Utility Toolkit

GLUT（英文全写：OpenGL Utility Toolkit）是一个处理 OpenGL 程序的工具库，负责处理和底层操作系统的调用以及 I/O，并包括了以下常见的功能：

定义以及控制视窗。

侦测并处理键盘及鼠标的事件。

以一个函数调用绘制某些常用的立体图形，例如长方体、球、以及犹他茶壶（实心或只有骨架，如 glutWireTeapot()）。

提供了简单菜单列的实现。

-   SDL: Simple DirectMedia Layer

SDL（英语：Simple DirectMedia Layer）是一套开放源代码的跨平台多媒体开发函式库，使用 C 语言写成。
SDL 提供了数种控制图像、声音、输出入的函数，让开发者只要用相同或是相似的代码就可以开发出跨多个平台（Linux、Windows、Mac OS X 等）的应用软件。目前 SDL 多用于开发游戏、模拟器、媒体播放器等多媒体应用领域。


### mesa 的模块划分 {#mesa-的模块划分}

{{< figure src="https://r2.guolongji.xyz/img_20240204_101056.jpg" alt="mesa-module" caption="<span class=\"figure-number\">Figure 1: </span>mesa categories" >}}

{{< figure src="https://r2.guolongji.xyz/img_20240204_101412.jpg" >}}

{{< figure src="https://r2.guolongji.xyz/img_20240204_101721.jpg" alt="mesa-module" caption="<span class=\"figure-number\">Figure 2: </span>_mesa-module_" width="900" >}}

{{< figure src="/ox-hugo/mesa-module.png" alt="mesa-module" caption="<span class=\"figure-number\">Figure 3: </span>_mesa-module_" width="900" >}}

-   OpenGL 能做什么？渲染 Render
    -   为什么需要渲染?
        -   OpengGL 的描述的物体在 3D 空间，3D 坐标

        -   显示设备是 2D 平面的

        -   Render ：{X, Y, Z}   ------------&gt;     {a, b}

    -   管线 pipeline
        -   一堆原始图形数据途经一个输送管道，期间经过各种变化处理最终出现在屏幕的过程

        -   两步：
            -   3D 坐标          2D 坐标

            -   2D 坐标          有颜色的像素

    -   着色器 shader
        -   在管线中每阶段的处理，据说一个 shader

        -   shader 就是 GPU 运行的 GLSL 描述的程序

{{< figure src="/ox-hugo/mesa-header.png" alt="mesa 的头文件" caption="<span class=\"figure-number\">Figure 4: </span>_mesa 的头文件_" >}}

{{< figure src="/ox-hugo/mesa-libs.png" alt="mesa 的库文件" caption="<span class=\"figure-number\">Figure 5: </span>_mesa 的库文件_" >}}

用 GLX 设置上下文，用 GL 来做渲染。

{{< figure src="/ox-hugo/mesa-module-2.png" alt="mesa 的库文件" caption="<span class=\"figure-number\">Figure 6: </span>_mesa 的库文件_" width="900" >}}


### Mesa3D 的作用 {#mesa3d-的作用}

-   Mesa 用作 Xorg 开源硬件 DRI 驱动的核心

-   完全实现 OpenGL，一个系统中没有其它 OpenGL 实现只使用 mesa 即可完成功能

-   使用 Mesa 渲染来验证硬件驱动

-   测试新的渲染技术

-   支持深色通道渲染：16bit 整型、32bit 浮点型

-   可调整渲染中数据的限制，如 lights、clip planes、texture size


### vlukan 相比 opengl 有哪些优势？ {#vlukan-相比-opengl-有哪些优势}

-   Vulkan 是一种新的图形 API，与 OpenGL 相比有以下几个优势：

-   更高的性能：Vulkan 具有更底层的硬件访问和更好的并发处理能力，可以更充分地利用多核 CPU 和

现代 GPU 的计算能力。Vulkan 还支持异步计算和多线程渲染，可以更好地处理大规模的数据和复杂的场景。

-   更低的 CPU 开销：Vulkan 通过显式地管理内存和资源，避免了 OpenGL 中常见的状态切换和错误检

查开销。这使得 Vulkan 在 CPU 上的开销更低，可以在更少的 CPU 资源下实现更高的性能。

-   更好的可扩展性：Vulkan 可以在多个设备上运行，并且具有更好的可扩展性。它可以更好地适应不同

的硬件架构和操作系统，同时支持更多的显式控制，使得开发者可以更好地控制渲染流程和资源管理。

-   更好的跨平台支持：Vulkan 的设计目标之一是在多个操作系统和硬件平台上运行，因此它提供了

比 OpenGL 更好的跨平台支持。例如，在 Windows、Linux 和 Android 等操作系统上都可以使用 Vulkan。

-   更好的图形质量：Vulkan 支持更高级别的反走样和其他图形技术，可以提供更高质量的图形效果。


### mesa 3D 的工作方式 {#mesa-3d-的工作方式}

1）stand alone 独立模式

mesa 的最初的实现，在 X Window 系统上，所有的渲染都是通过 Xlib API 实现

支持 GLX API，但是模拟的

不支持 GLX wire protocol，也没有 X server 可加载的 OpenGL 扩展

没有硬件加速

libGL.so 库包括了所有内容：编程 API、GLX 函数、render 的代码

2）DRI

Mesa 充当 DRI 硬件驱动的核心

libGL.so 库提供 GL、GLX API、GLX 协议的 encoder、设备驱动（这里是 UMD）的 loader

设备驱动模块（如 r200_dri.so）中包含了 Mesa 的核心代码功能

X server 加载 glx 模块，glx 模块解析传进来的 GLX protocol 数据，将命令分发到渲染模块。


## libglvnd {#libglvnd}

libglvnd 什么？

vendor 调度层

多 vendor 的 OpenGL API 调用的仲裁

vendor 这里是指 OpenGL 方法的实现库

libglvnd 作用？

多个 OpenGL 实现的共存

运行时选择 API 的实现

将 GLX、ELG、GL、GLES 统一在一个调度表

{{< figure src="https://r2.guolongji.xyz/img_20240204_145648.jpg" alt="mesa 的库文件" caption="<span class=\"figure-number\">Figure 7: </span>_mesa 的库文件_" width="900" >}}

stub 在不同情景下有不同的意思。从我的理解，stub 是泛指：系统 S 有某个依赖 D，但我用另外的模块 X 来代替 D。模块 X 就被称为一个 stub。在测试系统的过程中，X可以是用来模拟 D 的模块，因为 D 可能调用起来比较昂贵。

另一种情形是在系统开发中，可能程序 S 想要完成某个操作（比如读取某个文件），但其本身没有这个权限, 所以 S 必须调用一个模块 X。X 的作用是调用操作系统内核中用来读取文件的模块。所以编程语言中的系统调用也可以理解为一种 stub。

系统启动：

{{< figure src="https:r2.guolongji.xyz/img_20240204_153702.jpg" alt="mesa 的库文件" caption="<span class=\"figure-number\">Figure 8: </span>_mesa glvnd_" width="900" >}}

{{< figure src="https://r2.guolongji.xyz/img_20240204_153751.jpg" alt="mesa 的库文件" caption="<span class=\"figure-number\">Figure 9: </span>_mesa glvnd_" width="900" >}}


## 什么是 glxgears ？ {#什么是-glxgears}


## mesa 相关的编译命令 {#mesa-相关的编译命令}

sudo apt install devscripts

debuild -- clean # 清空所有的编译中间文件

sudo apt build-deb mesa # 下载 mesa 依赖的包，把 mesa 换成 . 也可以。

debuild -us -uc -nc # 这个命令是可以的，相比 dpkg-buildpackage -us -uc 有时候会报错，这个一般不报错。

禁用 mesa 的一个修改。

<https://cgit.freedesktop.org/mesa/mesa/commit/?id=1f31a216640f294ce310898773d9b42bda5d1d47>
