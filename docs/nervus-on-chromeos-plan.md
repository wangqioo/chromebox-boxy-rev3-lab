# Nervus on ChromeOS Plan

This plan adapts `nervus-v1` to the Boxy Rev3 Chromebox without treating the Chromebox as a heavy AI inference box.

The target is an AI-native ChromeOS appliance:

- ChromeOS host remains the hardware and recovery control plane.
- Crostini `penguin` runs the Nervus platform layer.
- Model inference defaults to cloud or remote model servers.
- Risky host actions stay behind explicit confirmation.

## Fit Assessment

The Chromebox is a good Nervus shell and control device, not a good primary LLM server.

| Area | Device reality | Decision |
| --- | --- | --- |
| CPU | Intel Celeron N4500, 2 cores | OK for control plane and light services |
| RAM | 7.6 GiB | Run a small service set only |
| Storage | 28.9 GB eMMC, about 20 GB stateful | Avoid model files and large media stores |
| GPU | Intel Jasper Lake UHD, no CUDA | Do not rely on local GPU inference |
| OS shape | ChromeOS host + Crostini Debian | Keep host minimal, run services in Crostini |
| Network | LAN-first, SSH recovery needed after reboot | Plan controlled local access first |

Conclusion: deploy a Nervus Lite profile in Crostini. Use the browser or iOS shell as the interaction layer, and use Arbor as the AI-native coordinator.

## Target Architecture

```text
iPhone / Chrome browser
  |
  | HTTP(S)
  v
Nervus frontend / Caddy
  |
  v
Arbor Core in Crostini
  - app registry
  - model gateway
  - event bus integration
  - knowledge API
  - flow router
  |
  +--> lightweight Nervus apps
  |     - file-manager
  |     - status-sense
  |     - personal-notes
  |     - reminder
  |     - workflow-viewer
  |     - chromebox-control
  |
  +--> Postgres / Redis / NATS
  |
  +--> cloud or remote model endpoints

ChromeOS host
  - chromeboxctl
  - SSH recovery
  - hardware and network inspection
```

## Service Profile

Start with a small profile. Add services only after the baseline is stable.

### Phase A: Minimum Viable Nervus

Run:

- `arbor-core`
- `caddy`
- `postgres`
- `redis`
- `nats`
- `app-status-sense`
- `app-file-manager`
- `app-workflow-viewer`
- `app-chromebox-control`

Do not run:

- `whisper`
- `app-video-transcriber`
- `app-photo-scanner`
- local `llama.cpp` inside the Chromebox
- every demo app by default

### Phase B: Useful Personal Layer

Add after Phase A is healthy:

- `app-personal-notes`
- `app-reminder`
- `app-calendar`
- `app-rss-reader`
- `app-knowledge-base`

### Phase C: Offloaded AI Workloads

Add only when model endpoints are available:

- model-manager connected to cloud models
- image or audio features backed by remote services
- remote `llama.cpp` on Jetson, desktop GPU, or VPS

## Model Strategy

The Chromebox should not be the default model runtime.

Recommended order:

1. Cloud model API through Nervus Model Platform.
2. Remote local model server on Jetson or GPU desktop.
3. Tiny CPU model on Chromebox only for experiments.

Recommended `.env` shape:

```sh
DEEPSEEK_API_KEY=
ZHIPUAI_API_KEY=
DASHSCOPE_API_KEY=
ANTHROPIC_API_KEY=
OPENAI_API_KEY=

LLAMA_URL=http://<remote-model-host>:8080
NERVUS_FALLBACK_MODEL=deepseek-chat
```

Keep model files off the Chromebox eMMC unless explicitly testing a tiny model.

## Deployment Layout

In Crostini:

```text
~/nervus/
  docker-compose.yml
  docker-compose.chromebox-lite.yml
  .env
  frontend/
  core/
  apps/
  config/
```

The lab repository stays separate:

```text
~/chromebox-boxy-rev3-lab/
  scripts/chromeboxctl
  docs/
  snapshots/
```

Nervus calls into this lab repository through the `chromebox-control` app. Do not merge the repositories unless the ownership boundary changes later.

## Compose Strategy

Create a Nervus override file in `nervus-v1`, not in this lab repository:

```text
docker-compose.chromebox-lite.yml
```

It should:

- disable heavy services by omission
- publish only required local ports
- mount `frontend/`, `config/`, and selected data volumes
- keep Postgres, Redis, and NATS persistent
- point `LLAMA_URL` at a remote endpoint
- avoid binding host port `443` until LAN access is proven

Start with:

```sh
docker compose -f docker-compose.yml -f docker-compose.chromebox-lite.yml up -d \
  arbor-core caddy postgres redis nats app-status-sense app-file-manager app-workflow-viewer
```

Then add `app-chromebox-control` when implemented.

## Browser and iOS Shell

For ChromeOS browser:

- Use the Crostini-forwarded port first.
- Prefer `http://localhost:8900` or the ChromeOS-provided Linux port forwarding address.
- Add HTTPS later only if the iOS shell requires it.

For iOS:

- Use LAN access only after the service is stable.
- Point `ios/capacitor.config.*` at the LAN URL or tunnel URL.
- Do not expose Arbor or host SSH directly to the public internet.

## ChromeOS Control Integration

`chromebox-control` should wrap `scripts/chromeboxctl` as a Nervus app.

Read-only endpoints can run without extra confirmation:

- `GET /health`
- `GET /snapshot`
- `GET /status`
- `GET /network`
- `GET /storage`
- `GET /hardware`
- `GET /devmode`
- `GET /vm`

Write or recovery endpoints require an explicit confirmation token:

- `POST /restore-ssh`

The app should emit events into Nervus:

- `system.chromeos.snapshot`
- `system.chromeos.health`
- `system.chromeos.storage.warning`
- `system.chromeos.crostini.warning`
- `system.chromeos.ssh.warning`

See [chromebox-control-app-spec.md](chromebox-control-app-spec.md).

## AI-native UX Mapping

The Nervus five-direction shell maps cleanly to this device:

| Direction | ChromeOS appliance use |
| --- | --- |
| Home | current system card, last health result, model route, quick actions |
| Up | sensing panel: ChromeOS, Crostini, network, storage, services |
| Left | chat: model gateway plus system context |
| Right | files: Crostini file transfer and selected lab snapshots |
| Down | app center: registered tools and control apps |

The key idea is that every UI surface should reflect real device state, not just generic app links.

## Safety Model

Default allowed:

- read snapshots
- query health
- inspect services
- read local logs
- call cloud model APIs
- write inside Crostini app data volumes

Confirmation required:

- restarting ChromeOS host services
- restoring host SSH
- changing firewall rules
- changing tunnel settings
- installing packages on the ChromeOS host
- deleting app data or snapshots
- exposing any service outside the LAN

Blocked by default:

- firmware changes
- Developer Mode changes
- public host SSH
- root filesystem modification attempts
- storing API keys or private keys in Git

## Resource Guardrails

Keep the first deployment below these rough limits:

- total containers: 8 to 10
- idle memory: under 3 GiB
- persistent data: under 5 GiB
- no local model files
- no background video/audio transcription
- no broad file indexing until storage behavior is measured

If the machine becomes sluggish, disable apps before tuning internals.

## Implementation Sequence

1. Create `docker-compose.chromebox-lite.yml` in `nervus-v1`.
2. Add a `.env.chromebox.example` that defaults to remote/cloud models.
3. Bring up infrastructure only: Postgres, Redis, NATS, Arbor, Caddy.
4. Add `status-sense`, `file-manager`, and `workflow-viewer`.
5. Implement `chromebox-control` as a Nervus app.
6. Feed `chromeboxctl snapshot` into Nervus events.
7. Make the home screen show live ChromeOS appliance status.
8. Add a remote-access plan only after LAN use is stable.

## Success Criteria

The deployment is working when:

- ChromeOS browser opens the Nervus shell.
- Arbor reports healthy infrastructure and registered apps.
- The sensing panel shows ChromeOS host and Crostini status.
- Chat works through at least one cloud or remote model.
- File manager works inside Crostini without touching host internals.
- A snapshot event appears in the Nervus event stream.
- Reboot recovery is documented and repeatable.

## Non-goals

- Running the full original `nervus-v1` stack on day one.
- Running Qwen-class local models on the Chromebox CPU as the normal path.
- Using the ChromeOS host as a general Linux server.
- Exposing host SSH or Arbor admin APIs to the public internet.
- Replacing ChromeOS firmware or boot flow.
