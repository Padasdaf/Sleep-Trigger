# Sleep-Trigger

Lightweight, on-device sleep detection on Apple Watch that triggers your chosen Shortcut on iPhone (and mirrors to Mac/iPad via iCloud KVS). Includes widgets/complications, a macOS menu-bar companion, and a small DSP core (Swift + C/C++/Obj-C/Obj-C++/ASM/Metal) for efficiency.

**Status:** v1.0 – complete and stable  
**Platforms:** iOS 18+, watchOS 11+, macOS 15+  
**Xcode:** 16.x

---

## Features

- **Sleep detection on Apple Watch** with HR + motion heuristics and low-overhead filters.
- **Instant automation**: runs your chosen iOS Shortcut when onset is detected.
- **History & charts** (iOS): view recent onsets; export CSV; share logs.
- **Widgets/Complications**: armed state + last onset at a glance.
- **macOS menu bar app**: mirrors onsets via iCloud KVS; optional media/pause actions.
- **Robust connectivity**: WatchConnectivity (live + background transfer) with App Group persistence.
- **Mixed-language performance core**: Swift + C/C++ + Obj-C(++), a tiny NEON ASM kernel, and a Metal shader for spectral demo.

---

## Project Structure

- **SleepTrigger (iOS app)** – UI, automations, history, widgets data source.
- **SleepTriggerWatchOS Watch App** – sensor pipeline, detection, WC send.
- **SleepTriggerWidgets** – iOS widgets + watch complications (simple timeline).
- **SleepTriggerMac (macOS)** – menu bar companion (status + quick actions).
- **Core/** – shared utilities (filters, DSP, ring buffer/logging, export, etc.).
- **Data/** – SQLite DAO and history persistence.
- **System/** – capabilities glue (App Group IDs, notifications, permissions).

---

## Requirements & Capabilities

Enable the following in Xcode (already configured in this repo):

- **App Groups**: `group.com.danielhu.sleeptrigger` (shared across iOS/watchOS/widgets/macOS)
- **HealthKit**: read Heart Rate + Sleep Analysis (iOS app / Watch app)
- **Background Modes** (watchOS): Workout processing
- **iCloud KVS**: NSUbiquitousKeyValueStore for mirroring last onset time
- **Notifications**: local notifications on iOS/macOS

---

## Build & Run

1. Open `SleepTrigger.xcodeproj` in Xcode 16.x.
2. **Watch flow**  
   - Run **SleepTriggerWatchOS Watch App** on a paired simulator/device.  
   - Start monitoring from the watch app; it reports onset via WC.
3. **iOS app**  
   - Run **SleepTrigger**.  
   - In *Settings/Automations*, set your Shortcut name.  
   - Use *Diagnostics → Simulate Sleep Now* if you want to demo without the watch.
4. **macOS companion**  
   - Run **SleepTriggerMac** to get the 🌙 menu-bar item that mirrors onsets and offers quick actions.
5. **Widgets/Complications**  
   - Add the widget/complication; it reads `lastOnset` + `armed` from the App Group.

---

## How it works (high level)

- Watch samples HR & motion → smoothed via IIR/Kalman/ring buffer → simple state machine (`awake/drowsy/asleep`).
- On **asleep**, the watch persists `lastOnset` to App Group and sends a WC message.
- iOS receives → **SleepEventBridge** applies gates (armed, time-window, lockout) → **opens Shortcuts** with your routine.
- Onset is **persisted** (SQLite/JSON) for history, **widgets** refresh, and **iCloud KVS** mirrors the timestamp for mac/iPad.

---

## Tests & CI

- Unit tests target detection heuristics, history DAO, export, and rule engine.
- UI tests smoke-launch the iOS app.
- GitHub Actions workflow builds iOS/watchOS/macOS (no code signing).

---

## Privacy

- No analytics or network calls.  
- Only the **epoch timestamp** of last onset is mirrored via iCloud KVS.  
- Health data is read-only and stays on device.

---

## Building blocks (tech highlights)

- **Swift** for app/UI/logic.
- **C/C++ & Obj-C(++)** for filters, ring buffers, and wrappers.
- **NEON ASM** micro-kernel (guarded; skipped on incompatible sims).
- **Metal** shader for spectral demo (optional path, compile-guarded).
