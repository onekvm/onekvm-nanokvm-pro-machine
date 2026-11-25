# onekvm-nanokvm-pro-machine

[English](README.md) | 简体中文

Sipeed NanoKVM Pro（AX630C）的机型文件，由 `onekvm-distro` 的 `meta-sipeed/meta-nanokvm-pro` 构建。

| 路径 | 内容 |
| --- | --- |
| `edid/` | Pro 安装的 256 字节 EDID 预设；出厂预设和 1080p60 由 Core 安装，各机型共用 |
| `src/onekvm-machine-nanokvm-pro-edid` | 采集芯片初始化 hook（`20-pro-chip-info`）：把 LT6911 驱动的芯片信息链接到 `/run/onekvm/lt6911_info` |
| `src/onekvm-capture-chip-init`、`systemd/onekvm-capture-chip-init.service` | 在 Core 启动前按顺序运行初始化 hook |
| `systemd/onekvm-machine-nanokvm-pro-ethernet.service` | 启动开始时拉起 `eth0`，让千兆协商与其余启动过程重叠 |
| `tools/generate-pro-edid.py`、`tools/edid_modes.py` | 按 CTA/DMT 时序重新生成 `edid/` |
| `tools/pack-pro-emmc.py` | 把系统镜像打包成原厂 Pro eMMC 裸布局 |

`make test` 检查 EDID 预设、eMMC 打包工具和采集芯片初始化。

## EDID

`factory.edid.bin`（默认 1920×1080 @ 60 Hz）和 `1080p60.edid.bin` 由 Core 安装，
所有机型共用。从 `edid/` 安装的预设包括：

- `2160p30.edid.bin` — 首选 3840×2160 @ 30 Hz
- `1440p30.edid.bin` — 2560×1440 @ 30 Hz
- `1440p60.edid.bin` — 2560×1440 @ 59.95 Hz（标称 60 Hz）
- `720p60.edid.bin` — 1280×720 @ 60 Hz
- `1080p120.edid.bin` — 首选 1920×1080 @ 120 Hz，保留 1080p60 / 720p60 回退模式

独立分辨率预设声明对应首选时序及带宽更低的回退模式，并保留 BIOS 基础时序和双声道
LPCM 音频。Pro 采集最高支持 4K30，需要选择独立的 2160p30 预设；
默认 1080p60 预设不声明 4K 模式。
独立的 1080p120 预设用于高刷新率输入；编码仍服从目标帧率，Pro 已验证
120 Hz 输入、60 FPS 串流。连接环出显示器时，它也需要支持该输入模式。
HDMI 一分二向主机
提供所选采集端 EDID 与环出显示器共有的模式；环出显示器也支持 4K30 时，
主机才能选择该模式。仅停止 SoC 取帧不会关闭采集桥片，也不会将采集端
EDID 从协商中移除。使用
`python3 tools/generate-pro-edid.py` 可重新生成；SG200x 的预设由其机型仓库维护。

Pro 机型包附带 2160p30 等 EDID 预设，供网页 EDID 设置选择。开机不写入桥片
EDID，桥片保留原有 EDID，用户可在网页上更改。Pro 的 `20-pro-chip-info` hook
只把 `/run/onekvm/lt6911_info` 链接到驱动的 `/proc/lt6911_info`，与 SG2002 MMF
诊断缓存使用相同的查找路径；驱动不存在时不视为初始化失败。

UXC 和 D 的永久 EDID 写入桥片 Flash，D 使用独立的 Flash 时序。C 支持受保护的
手动 EDID 管理，其 Pro 擦除范围仍需实机验证。UXC 临时 RAM 应用属于后端可选模式，
不改动 Flash；不支持 Shadow 只关闭临时模式。Pro Shadow 仍待实机验收。
