# ChromeOS / ChromiumOS Device Lab

这是一个 ChromeOS / ChromiumOS 设备实验仓库。当前主设备是一台 Google ChromeOS Chromebox，设备代号为 `boxy-rev3`，板级为 `dedede`。

本仓库负责三件事：

- 记录这台 Chromebox 的 bring-up、硬件清单、系统状态和操作模型
- 提供受控的 ChromeOS 主机检查脚本 `scripts/chromeboxctl`
- 维护面向 Nervus 的 ChromeOS 专用集成代码

通用 Agent OS runtime 不放在这里，而是在 `nervus-v1`。本仓库只保存和这台 ChromeOS 设备有关的逻辑。

## 当前设备状态

这台设备已经完成：

- ChromeOS Developer Mode
- ChromeOS host 局域网 SSH 访问
- Crostini Linux 容器访问
- 硬件、系统、网络、存储、虚拟化基线记录

敏感信息不会提交到仓库，包括账号密码、Google 账号、SSH 私钥、代理凭据和本地密钥。

## 访问方式

在最初用于配置的 Mac 上：

```sh
ssh chromebox
```

连接 ChromeOS host，用户为 `chronos`。

```sh
ssh penguinbox
```

通过 ChromeOS 进入 Crostini Linux 容器 `penguin`。

这些 SSH alias 位于本地 `~/.ssh/config`，属于机器本地配置，不提交到仓库。

## 设备快照

| 字段 | 值 |
| --- | --- |
| ChromeOS device code | `boxy-rev3` |
| ChromeOS board | `dedede-signed-mp-v58keys` |
| Hardware ID | `BOXY-GLMX C3W-C2D-B3B-A6C-A9E` |
| Firmware ID | `Google_Boxy.13606.594.0` |
| CPU | Intel Celeron N4500，2 核 |
| RAM | 7.6 GiB |
| Storage | 28.9 GB eMMC |
| Wi-Fi | Intel Wi-Fi 6 AX201 |
| Ethernet | Realtek RTL8111/8168/8211/8411 Gigabit Ethernet |
| GPU | Intel Jasper Lake UHD Graphics |
| ChromeOS version | `16640.40.0` |
| Chrome milestone | `148` |
| Channel | `stable-channel` |
| Kernel | `6.1.161-17590-gf0e6dabf73de` |
| Developer Mode | enabled |

## 仓库结构

```text
docs/
  ai-native-os-plan.md        AI-native OS 实验规划
  board-notes/                ChromiumOS-like 系统与板卡路线笔记
  bringup.md                  从零配置到 SSH 访问的过程记录
  chromebox-control-app-spec.md ChromeOS 控制集成规格
  device-inventory.md         硬件、系统、存储、网络、虚拟化清单
  exploration-roadmap.md      后续探索路线图
  nervus-on-chromeos-plan.md  Nervus on ChromeOS 方案
  operating-model.md          ChromeOS host 与 Crostini 的分工
integrations/
  nervus/                     Chromebox 专用 Nervus Widget 与安装说明
scripts/
  chromeboxctl                受控 ChromeOS host 检查入口
  install-nervus-integration.sh 把本仓库的 Nervus 集成安装到本地 Nervus checkout
  restore-ssh.sh              ChromeOS host SSH 恢复脚本模板
notes/
  next-steps.md               后续工作
snapshots/                    本地诊断输出，默认不提交
```

## 操作原则

ChromeOS host 是设备控制面，用来做：

- 硬件检查
- ChromeOS 网络检查
- Developer Mode / firmware 状态检查
- Crostini VM 状态检查
- SSH 恢复

Crostini Linux 容器是开发层，用来做：

- Git 仓库
- Python / Node / Rust / Go 项目
- Nervus / Arbor Core
- 本地 Web 服务
- 可回滚的实验

不要把 ChromeOS host 当普通 Linux 服务器使用。安装包、跑服务、写应用都优先放在 Crostini。

## 受控 AI 接口

当前最小安全控制面是：

```sh
scripts/chromeboxctl doctor
scripts/chromeboxctl status
scripts/chromeboxctl health
scripts/chromeboxctl snapshot
```

更多命令见：

- [docs/chromeboxctl.md](docs/chromeboxctl.md)
- [docs/ai-native-os-plan.md](docs/ai-native-os-plan.md)

高风险操作必须显式确认，包括：

- `restore-ssh`
- `sudo`
- 防火墙规则变更
- 修改 ChromeOS host 文件
- 暴露服务到公网
- 删除数据
- firmware / Developer Mode 变更

## Nervus on ChromeOS

本仓库维护 ChromeOS 专用的 Nervus 集成，源码在：

```text
integrations/nervus/
```

它提供一个 `ChromeboxWidget`，把 `scripts/chromeboxctl` 包装成 Nervus Widget。这样 Nervus 可以读取这台 ChromeOS 设备的状态，但 ChromeOS 专用代码仍然归属于本仓库。

安装到本地 Nervus checkout：

```sh
cd ~/chromebox-boxy-rev3-lab
scripts/install-nervus-integration.sh ../nervus-v1
```

运行 Nervus 时指定控制脚本：

```sh
cd ~/nervus-v1/core/arbor
export CHROMEBOX_CTL=../../../chromebox-boxy-rev3-lab/scripts/chromeboxctl
export CHROMEBOX_HOST=chromebox
python main.py
```

安装后可用接口示例：

```text
GET  /api/widgets/chromebox/state
GET  /api/widgets/chromebox/health
GET  /api/widgets/chromebox/snapshot
GET  /api/widgets/chromebox/network
GET  /api/widgets/chromebox/storage
GET  /api/widgets/chromebox/hardware
GET  /api/widgets/chromebox/devmode
GET  /api/widgets/chromebox/vm
POST /api/widgets/chromebox/restore-ssh
```

`restore-ssh` 必须带确认字段：

```json
{
  "confirm": "restore-ssh"
}
```

## 和 nervus-v1 的边界

- `nervus-v1`：通用 Agent OS runtime
- `chromebox-boxy-rev3-lab`：ChromeOS 设备资料、控制脚本、Nervus Chromebox 集成

也就是说，ChromeOS 专用应用放在本仓库；Nervus 只是运行时。

## 探索路线

详细路线见 [docs/exploration-roadmap.md](docs/exploration-roadmap.md)。当前优先级：

1. 稳定 `chromeboxctl` 快照和 health 检查
2. 把 Chromebox Widget 安装到 Nervus 并跑通
3. 在 Nervus 中展示 ChromeOS / Crostini / 存储 / 网络状态
4. 设计受控远程访问方案
5. 继续整理 ChromiumOS-like 板卡路线

## 板卡笔记

通用 ChromiumOS / ChromeOS Flex / openFyde / FydeOS / Rockchip / Raspberry Pi 调研在：

```text
docs/board-notes/README.md
```

这些笔记用于判断其他设备是否适合跑 ChromiumOS-like 系统。真正的设备实验记录仍然放在本仓库对应文档中。
