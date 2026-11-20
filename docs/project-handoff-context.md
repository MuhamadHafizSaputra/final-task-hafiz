# Project Handoff Context — IoT Goat Weighing System
*Generated: 2026-11-20 | Purpose: Transferable context for another LLM or new chat session*

---

## 1. What This Project Is

An undergraduate capstone thesis (Skripsi — Inovasi Produk) at **Universitas Gadjah Mada (UGM), Departemen Ilmu Komputer dan Elektronika (DIKE), FMIPA**.

The project is a **collaborative thesis between two students**:
- **Hafiz (the user):** Responsible for — Backend (data processing), Mobile App (React Native/Expo), Website.
- **Lutfi (the partner):** Responsible for — IoT hardware (ESP32, HX711 load cell, RFID reader, microSD logger, LCD display).
- **Both:** The integration layer between IoT and Software (data contracts, communication protocol, database design).

Working title:
- **Indonesian:** Rancang Bangun Timbangan Kambing Berbasis IoT dengan Deteksi Bobot Stabil dan Sinkronisasi Offline-First
- **English:** Design and Development of an MQTT-Based IoT Goat Weighing Scale with Stable-Weight Detection

> **Note:** The species used in test data may be Kambing (Goat), Domba (Sheep), or both. This has not been finalized and must be confirmed before writing the thesis introduction.

**Status:** Planning phase. No code has been written yet. All files in this repository are documentation, LaTeX thesis templates, and design artifacts.

---

## 2. The Physical Hardware (Lutfi's Side)

| Component | Purpose |
|---|---|
| Load Cell (300 kg capacity) + Platform Youta | Physical weighing floor |
| HX711 amplifier | Converts load cell analog signal → digital |
| ESP32 (dual-core microcontroller) | The IoT brain. Runs Core 0 (networking) and Core 1 (measurement) simultaneously |
| RFID Reader (WL-134, 134.2 kHz) | Reads animal's electronic ear tag while on the platform |
| Infrared sensor (E3Z-T81 through-beam) | Detects when an animal enters/exits the weighing chute |
| LCD 20×4 | Displays live weight and weighing result to the cage operator |
| LEDs + Buzzer | Status indicators (like a standard commercial scale — does NOT show final weight; just standard beep/light confirmation) |
| RTC DS3231 (battery-backed clock) | Keeps accurate time even when internet is down |
| MicroSD card | Saves all raw sensor readings + completed weighing records locally (offline-first fallback) |
| Tare Button | Re-zero the scale. **Deferred — not a priority in current planning phase.** |

**Sampling rate:** 10 SPS (samples per second) from the HX711.

**Weighing flow on the cage:**
1. Animal walks into the chute (detected by infrared beam + weight threshold crossing).
2. ESP32 Core 1 starts reading raw samples at 10 SPS.
3. RFID reader scans the ear tag.
4. ESP32 sends raw samples to the backend in real time (via MQTT or HTTP — TBD, see Section 5).
5. The LCD shows the current live weight reading (like a standard scale display).
6. The buzzer/LED confirms when the weighing session is accepted by the backend.
7. Animal exits the chute.
8. If offline: all raw readings are saved to microSD first, then replayed to the backend when internet is restored.

---

## 3. Data Processing Architecture (Decided)

**Who does what:**

| Processing Step | Decided Owner |
|---|---|
| Read raw load-cell samples at 10 SPS | ESP32 Core 1 |
| Send raw samples to cloud/backend | ESP32 Core 0 |
| **Kalman filter** (noise reduction on raw readings) | **Backend (server-side)** |
| **WSTD — Windowed Stable-Weight Detection** (after Kalman) | **Backend (server-side)** |
| Final weight calculation (median of stable window) | **Backend (server-side)** |
| Store raw + filtered samples permanently | **Cloud database** — every individual 10 SPS reading as one row in `weighing_samples`, tagged with `session_id` and `sample_number` |
| Save raw samples if offline | **MicroSD on ESP32** |
| Display current live weight to cage operator | **LCD on ESP32** (live raw reading only — no backend-confirmed "final weight" on LCD) |
| Buzzer / LED confirmation | **Optional / deferred** — will be reconsidered as the project progresses |
| Live weight preview on Mobile App | **Mandatory** — farmer's phone MUST show live weight while animal is on scale |

**Key reasoning behind "backend does filtering and stability":**
- The LCD showing a live reading is simpler and doesn't need a backend-computed final weight.
- Having the backend do Kalman + WSTD means algorithm parameters can be tuned on the server without flashing new ESP32 firmware.
- Raw samples are stored in the database for academic reproducibility (the thesis can cite the exact raw data, filtered data, and stability decision for every weighing).

**Raw sample storage detail:**
- Storage model: one database row per 10 SPS reading, tagged with `session_id` and `sample_number`.
- Expected volume: ~300 rows/animal × 50 animals/session = ~15,000 rows/session, ~450,000 rows/month.
- Table must be indexed on `(session_id, sample_number)`. Partitioning or archiving is a future concern beyond thesis scope.

**Algorithm pipeline:**
```
Raw 10 SPS readings
  → Kalman filter (backend) → filtered readings
  → WSTD / Sliding Window (backend) → stable window found?
      YES → median of stable window = final weight, bobot_stabil = true
      NO  → fallback: median of all readings during animal presence, bobot_stabil = false
```

> **OPEN CRITICAL ISSUE (not yet decided):** See Section 7.1 — the Kalman filter + WSTD pipeline on the backend has a fundamental problem with the ESP32 offline fallback that must be resolved.

---

## 4. Session & Data Hierarchy (Decided)

Adopted Lutfi's 2-level hierarchy:

```
Batch Session (Sesi)
└── Animal Pass (Lintasan) × N animals
    └── Raw Samples × M readings per animal
```

| Concept | Description | Example ID |
|---|---|---|
| **Sesi (Batch Session)** | One operator-initiated weighing run. Contains N animals. Created when operator starts the scale. | `S0001-20261120` |
| **Lintasan (Animal Pass)** | One individual animal's weighing event inside a session. | `S0001-20261120_017` |
| **Raw Sample** | One 10 SPS load-cell reading within a lintasan. | `{session_id, sample_number, raw_weight_kg, recorded_at}` |

**RFID identity states per Lintasan:**
| `status_id` | Meaning | Action |
|---|---|---|
| `OK` | Exactly 1 RFID ear tag confirmed | Auto-linked to animal |
| `TIDAK_TERBACA` | 0 tags read (tag missed by antenna) | Operator manually enters animal ID in Mobile App |
| `GANDA` | 2+ tags read (another animal near antenna) | Mobile App shows candidate IDs; operator selects the correct one |

**When RFID fails:** The Mobile App provides a manual correction flow (`koreksi`). This is Hafiz's (mobile app developer's) responsibility to implement in the UI.

---

## 5. Communication Protocol (OPEN — Not Yet Decided)

**Current state of Hafiz's docs:** Specifies **MQTT broker** (architecture-notes.txt still says "Option C: MQTT/broker real-time cloud").

**Current state of Lutfi's docs (Konsep_Batch1.pdf + Flowchart_Bacth1.pdf):** Specifies **HTTPS REST (PUT/PATCH)** directly to Firebase Realtime Database. No MQTT at all.

**This is the single most important unresolved technical decision.**

Options on the table:
1. **MQTT Broker:** ESP32 publishes raw samples to an MQTT topic → backend consumer subscribes → processes → stores in Supabase PostgreSQL.
2. **HTTPS REST to Supabase PostgREST:** ESP32 sends HTTPS POST/PATCH directly to a Supabase REST API (or Next.js API route). Same protocol Lutfi already knows (he used it with Firebase). Just a URL change.
3. **Firebase RTDB (Lutfi's original):** ESP32 sends HTTPS to Firebase → backend/mobile syncs to Supabase PostgreSQL.

---

## 6. Database Stack (Partially Decided)

**Hafiz's side:**
- **Supabase (PostgreSQL)** — full relational database designed in `docs/database.dbml` and `docs/schema.sql`.
- **Next.js** — backend/API layer.
- **React Native / Expo** — Mobile App.
- Hafiz has a 28-table schema designed already (`database.dbml`).

> **WARNING: The 28-table schema is likely over-scoped for the thesis.** Tables like `medications`, `treatments`, `breeding_events`, `feed_records`, `pasture_rotations`, `financial_records` belong in a full livestock ERP, not in a focused weighing system thesis. If these tables appear in Bab 3 (Kajian Ilmiah) or Bab 4 (Perancangan), the examiners will expect a fully implemented and tested UI for all 28 tables. Recommend trimming to 8–10 core tables.

**Lutfi's side:**
- **Firebase Realtime Database (NoSQL JSON)** — 5 main JSON nodes: `perangkat/`, `sesi/`, `lintasan/`, `ternak/`, `koreksi/`.
- **Firebase Auth** — user authentication.
- **No Cloud Functions** (explicitly excluded because they require the paid Blaze plan).

**Agreed database direction:** Not fully locked yet — depends on protocol decision in Section 5.

---

## 7. Critical Open Issues (Must Resolve Before Building Anything)

### 7.1 ⚠️ Offline Behavior — PARTIALLY RESOLVED

**What is decided:**
- Buzzer/LED confirmation is **optional / deferred**. Not a blocking issue.
- LCD shows live raw weight (like a standard scale). No backend-confirmed final weight on LCD.
- The cage works as a dumb scale when offline. The official result only appears in the Mobile App after the backend processes the replayed samples.

**What this means architecturally (accepted):**
This is NOT a true offline-first system for the *weighing confirmation* step. It is **offline-safe-storage + online-first-confirmation.** The microSD ensures no data is lost, but the farmer cannot know the official stable weight result until internet is restored and the backend processes the replay.

> This is an acceptable trade-off as long as the thesis does NOT claim "offline-first weighing with instant stable-weight feedback." The offline claim is limited to: *"raw data is not lost when internet is unavailable."*

### 7.2 Communication Protocol (Section 5 above — not yet decided)

**Why this matters immediately:** Every other technical decision (backend architecture, database schema, Lutfi's ESP32 code on Core 0) blocks on this choice.

> **Additional constraint from live preview decision:** Live preview is now **mandatory** (see 7.3 below). This means the ESP32 must push data at ~1 Hz to the mobile app while an animal is present. MQTT handles this more naturally than REST (MQTT is push; REST requires the app to poll). This is a significant argument in favor of MQTT for the live preview path at minimum.

### 7.3 `live` Preview — **DECIDED: Mandatory (Dual-Stream Architecture)**

**Decided:** Live preview (1 Hz current weight to mobile app) is **mandatory**. The farmer's phone must show the live weight reading while an animal is on the scale.

**Architecture: Two Separate Streams**
1. **Raw Sensor Stream (10 SPS):**
   - Transmitted from ESP32 to Backend.
   - Inserted into database (`weighing_samples`) for scientific record and auditability.
   - Backend runs Kalman Filter + WSTD algorithm on this stream to calculate the official final weight.
2. **Live Preview Stream (1 Hz / max 1 update per second):**
   - Transmitted only while an animal is present on the scale (`hadir == true`).
   - Ephemeral payload (e.g., `{hadir: true, weight_kg: 24.5, rfid_temp: "..."}`).
   - Delivered to the Mobile App's Live Panel via real-time push (MQTT topic or Supabase Realtime broadcast).
   - **Not** stored as individual rows in PostgreSQL (avoids database bloat).

**Implication for Protocol:**
- This strongly favors **MQTT** (or a real-time WebSocket / Supabase Realtime broadcast bridge), because polling REST endpoints every 1 second from a mobile app is inefficient and laggy.

### 7.4 Protocol from MicroSD Replay to Backend

When the ESP32 reconnects after being offline and replays stored samples from the microSD:
- Does it replay raw samples one-by-one (same as live), letting the backend re-run Kalman + WSTD?
- Or does it replay a compressed summary (pre-computed on ESP32)?
- How does the backend distinguish **replayed old data** from **live new data** (timestamp ordering, session boundaries)?
- What if the same session was partially uploaded live and then partially replayed? How do you handle duplicate prevention?

### 7.5 Species Alignment

**Lutfi's diagrams say `Domba` (Sheep). Hafiz's thesis says `Kambing` (Goat).**

This is not a software problem but a thesis validity problem. The title, literature review, all animal-specific constants (normal weight ranges, expected growth rates for PBBH, typical variance thresholds), and test data must all use the same species. Decide with Lutfi based on what animals are actually available at the test farm.

---

## 8. Agreed Integration Boundaries

| Boundary | Hafiz (Software) | Lutfi (IoT/Hardware) |
|---|---|---|
| Data producer | ← | ESP32 reads raw load-cell samples |
| Transport | TBD (MQTT or HTTPS REST) | TBD |
| Data consumer | Backend receives + processes raw samples | → |
| Kalman filter | Backend | — |
| WSTD / Stable window | Backend | — |
| Final weight decision | Backend | — |
| LCD display | — | ESP32 (live raw reading only) |
| Buzzer/LED confirmation | Optional / deferred | Hardware signal (optional) |
| Offline storage | — | MicroSD on ESP32 |
| Offline replay | Backend receives replayed samples | ESP32 replays from microSD |
| RFID error resolution (manual) | Mobile App (`koreksi` flow) | ESP32 flags `status_id` |
| Animal profile management | Mobile App + Backend + DB | — |
| Growth tracking (PBBH) | Backend + Mobile App | — |

---

## 9. Files in This Repository

| File | Contents |
|---|---|
| `docs/project-context.md` | High-level project background, related work, novelty claims, scope |
| `docs/architecture-notes.txt` | Architecture options A/B/C (note: MQTT decision is now being reconsidered) |
| `docs/full-flow-sample-to-supabase.txt` | Detailed step-by-step MQTT+Supabase flow (pre-Lutfi discussion; partially outdated) |
| `docs/database.dbml` | Full 28-table database schema (warning: likely over-scoped — see Section 7) |
| `docs/schema.sql` | SQL DDL generated from the DBML schema |
| `docs/pwa_vs_mobile_comparison.txt` | Decision: Native Mobile App (Expo/React Native) over PWA |
| `docs/lutfi-firebase-db-notes.md` | Reconstructed Firebase RTDB structure from Lutfi's PDFs + critical cautions |
| `Konsep_Batch1.pdf` | Lutfi's concept document (IoT hardware design, Firebase schema) |
| `Flowchart_Bacth1.pdf` | Lutfi's flowchart (ESP32 dual-core logic, Mobile App screens) |
| `template/proposal/` | LaTeX source for the thesis proposal |
| `template/skripsi/` | LaTeX source for the full thesis |
| `examples/pedoman_ta.pdf` | Official UGM thesis guidelines (highest authority) |
| `examples/contoh_proposal.pdf` | Example UGM thesis proposal |
| `examples/contoh_skripsi.pdf` | Example UGM full thesis |

---

## 10. What Has NOT Been Decided Yet (For the Next LLM to Help With)

1. **Communication protocol:** MQTT vs. HTTPS REST (and to Firebase or directly to Supabase)
2. **Offline behavior UX:** What does the farmer see/hear at the cage when internet is down and the backend cannot confirm stable weight?
3. **Database schema trimming:** Which of the 28 tables to keep for the actual thesis scope
4. **API contract (JSON payload):** Exact field names and types that Lutfi's ESP32 will send per sample, per session start, per session end
5. **Species:** Kambing or Domba?
6. **MicroSD replay protocol:** How offline-buffered samples are replayed and how duplicates are prevented
7. **Thesis scope boundary:** What features are "implemented and tested" in the thesis vs. "future work"

---

## 11. Important Project Rules (from AGENTS.md)

- The thesis follows **UGM Skripsi Inovasi Produk** structure (Bab 1–6 for skripsi, Bab 1–4 for proposal).
- Do NOT fabricate citations. Only cite sources actually in `references.bib`.
- Do NOT assume any "Open Decision" listed above is finalized.
- The official guidelines (`pedoman_ta.pdf`) override example files if there is any conflict.
- Language: Indonesian for the thesis body; English for abstract, technical terms, and code.

---

*End of handoff context. Last updated: 2026-11-20.*
