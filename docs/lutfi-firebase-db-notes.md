# Lutfi's Database Design Notes (Firebase Realtime Database)

Date: 2026-11-19
Source: Reconstructed from `Flowchart_Bacth1.pdf` and `Konsep_Batch1.pdf`

> **Note:** Lutfi's planning documents do not contain a formal ERD or SQL schema. Because his design uses **Firebase Realtime Database (NoSQL JSON tree)** in `asia-southeast1` (Singapore), the structure below is reconstructed directly from the JSON paths, REST operations, and mobile app flows shown in his diagrams.

---

## 1. The 5 Main JSON Paths in Firebase Realtime Database

### 1.1 `perangkat/{id_perangkat}/`
*(Example: `perangkat/LOET01/`)*

Stores device registration metadata, periodic health heartbeats, and temporary live weighing previews.

* **`info`**: Initial device info and startup status sent on boot (`PUT perangkat/LOET01/info`).
* **`status`** (Sent via `PUT` every 30 seconds):
  * `t_alat`: Local device timestamp from the DS3231 RTC clock.
  * `t_server`: Firebase server timestamp.
  * `rssi_dbm`: Wi-Fi signal strength (dBm).
  * `heap_min_b`: Minimum free heap memory on the ESP32 (bytes).
  * `antrean`: Count of unsent records remaining in the local microSD queue.
  * `sesi_aktif`: Currently active batch session ID (e.g., `S0001-20261120`).
  * *(Mobile App check: Device is considered Online / `Daring` if `status.t_server` age `< 90 s`.)*
* **`live`** (Overwritten via `PUT` at max 1 Hz / every 1 second when new live data is available):
  * `hadir`: Boolean indicating whether an animal is currently detected on the scale.
  * `bobot_kg`: Live current weight reading in kilograms.
  * `stabil`: Boolean indicating whether the live reading is currently stable.
  * `id_sementara`: Temporary RFID tag ID detected while the animal is standing on the scale.

### 1.2 `sesi/{id_perangkat}/{id_sesi}`
*(Example: `sesi/LOET01/S0001-20261120`)*

Represents one weighing batch session (started by pressing the Tare button when the platform is empty; closed by holding Tare for `>= 3 s`).

* `status`: `"BERJALAN"` (Running), `"SELESAI"` (Finished), or `"TERPUTUS"` (Interrupted if an open session is found on boot after unexpected power loss).
* `t_mulai`: Session start timestamp.
* `t_selesai`: Session end timestamp.

### 1.3 `lintasan/{id_perangkat}/{id_lintasan}`
*(Example: `lintasan/LOET01/S0001-20261120_017`)*

Represents one individual animal weighing pass ("lintasan"). Uploaded from the microSD queue via `PUT` (1 record) or `PATCH` (batch of 2–10 records), keyed by `id_lintasan`.

* `id_lintasan`: Primary key string (`{id_sesi}_{sequence}`, e.g., `S0001-20261120_017`).
* `id_sesi`: Parent batch session ID.
* `status_id`: RFID identification outcome:
  * `"OK"`: Exactly 1 tag confirmed by WSTD during `HADIR` (`id_tag` populated).
  * `"TIDAK_TERBACA"`: 0 tags confirmed (`id_tag` empty).
  * `"GANDA"`: 2 or more tags confirmed (`id_kandidat` + `p rata-rata` recorded).
* `id_tag`: Confirmed RFID ear-tag ID (when `status_id = OK`).
* `id_kandidat` + `p rata-rata`: Candidate tag IDs and average detection confidence/probability (only when `status_id = GANDA`).
* `bobot_kg`: Final weight in kg (median of stable window if available; otherwise median of the entire `HADIR` period).
* `bobot_stabil`: Boolean (`true` if a stable weight window was detected, `false` if fallback median of all `HADIR` readings was used).
* `bobot_sd`: Standard deviation of the selected readings.
* `t_keluar`: Timestamp when the animal exited the scale (from the ESP32 RTC clock).
* `t_server`: Server timestamp populated using `{".sv": "timestamp"}`.

### 1.4 `ternak/{id_tag}`
*(Example: `ternak/TAG001`)*

Animal master profile read and edited by the Mobile App (`baca ternak/`, `tulis ternak/{id_tag}`).

* Supports livestock listing, animal detail view, historical weight records, growth chart, and **PBBH** (*Pertambahan Bobot Badan Harian* / Average Daily Gain).

### 1.5 `koreksi/{id_perangkat}/{id_lintasan}`
*(Example: `koreksi/LOET01/S0001-20261120_017`)*

Manual animal ID override written by the Mobile App (`tulis koreksi/LOET01/{id_lintasan}`) whenever a weighing pass has `status_id != OK` (i.e., `TIDAK_TERBACA` or `GANDA`).

---

## 2. Supporting Auth / User Path

From `Flowchart_Bacth1.pdf` (Page 4, Mobile App flow):

* **`pengguna/{uid}`**: Checked immediately after Firebase Auth email/password login.
  * If `pengguna/{uid}` exists: User proceeds to select device (`perangkat/`).
  * If `pengguna/{uid}` does not exist: App shows `"Akun belum aktif"` (*"minta admin mendaftarkan UID"*).

---

## 3. Example Firebase JSON Tree Structure

```json
{
  "pengguna": {
    "uid_user_123": {
      "nama": "Operator Kandang",
      "peran": "operator"
    }
  },
  "perangkat": {
    "LOET01": {
      "info": {
        "nama": "Timbangan LOET01",
        "versi_fw": "1.0.0"
      },
      "status": {
        "t_alat": 1763600000,
        "t_server": 1763600001,
        "rssi_dbm": -65,
        "heap_min_b": 142000,
        "antrean": 0,
        "sesi_aktif": "S0001-20261120"
      },
      "live": {
        "hadir": true,
        "bobot_kg": 24.5,
        "stabil": false,
        "id_sementara": "TAG001"
      }
    }
  },
  "sesi": {
    "LOET01": {
      "S0001-20261120": {
        "status": "BERJALAN",
        "t_mulai": 1763599800,
        "t_selesai": null
      }
    }
  },
  "lintasan": {
    "LOET01": {
      "S0001-20261120_017": {
        "id_lintasan": "S0001-20261120_017",
        "id_sesi": "S0001-20261120",
        "status_id": "OK",
        "id_tag": "TAG001",
        "bobot_kg": 24.8,
        "bobot_stabil": true,
        "bobot_sd": 0.04,
        "t_keluar": 1763600000,
        "t_server": 1763600002
      }
    }
  },
  "ternak": {
    "TAG001": {
      "nama": "Kambing 01",
      "jenis_kelamin": "jantan"
    }
  },
  "koreksi": {
    "LOET01": {
      "S0001-20261120_018": {
        "id_tag_koreksi": "TAG002"
      }
    }
  }
}
```

---

## 4. Local MicroSD Storage Layout (ESP32 Hardware)

The microSD card serves as the primary offline data recorder (*catatan utama penelitian*):

1. **Continuous Raw Sensor Log**: Records raw readings (`~3.46 MB/hour`).
2. **`lintasan.csv`**: Persistent CSV table storing completed weighing passes (`lintasan`), flushed immediately after each pass.
3. **Unsent Queue (`antrean belum terkirim`)**: Tracks pending records using an index/sent marker (`tanda belum terkirim`). Core 0 requests up to 10 oldest records via a FreeRTOS queue and advances the microSD index only after receiving `HTTP 200` from Firebase.

---

## 5. Planning Caveats & Open Questions to Confirm with Lutfi

1. **Exact JSON Schema & Formula for `id_kandidat` and `p rata-rata`**:
   * The diagrams mention `id_kandidat + p rata-rata` when `status_id = GANDA`, and refer to `Middleware WSTD` (`epoch 0,5 s`), but do not specify the exact JSON key names, array/object format, full meaning of `WSTD`, or exact mathematical formula for `p rata-rata`.
2. **Exact Stable-Window Prerequisites & Thresholds**:
   * `Flowchart_Bacth1.pdf` includes the check `"Ada jendela bobot stabil?"` with `10 SPS` HX711 sampling and `bobot_sd`, but does not document the minimum window duration, minimum sample count, or maximum allowed standard deviation/dispersion threshold.
3. **Merging `koreksi/` with `lintasan/` Without Cloud Functions**:
   * Push notifications when the app is closed are marked out of v1 because Cloud Functions require Firebase's paid Blaze plan. Without server-side triggers, the Mobile App must read both `lintasan/` and `koreksi/` and merge them on the client before displaying animal weight histories or calculating PBBH.
4. **Keying `ternak/` by Physical `id_tag`**:
   * Using `id_tag` directly as the key in `ternak/{id_tag}` creates a brittle dependency on a physical ear tag. If a tag falls off and is replaced, historical records under the old tag ID risk becoming orphaned from the new tag ID.

---

## 6. Critical Architecture & Integration Cautions

### 6.1 The Mid-Session Tare (Re-Zero) Vulnerability
* **The Issue:** During a batch weighing session of 20–50 goats, manure, mud, and urine inevitably accumulate on the weighing platform. If 0.5 kg of dirt builds up after goat #10, every subsequent goat will be recorded 0.5 kg heavier unless the scale is re-zeroed.
* **Flowchart Flaw:** In `Flowchart_Bacth1.pdf` (Page 2), the Tare calibration step only occurs *before* creating a new session. Inside the active loop, the button check only tests for ending the session (`>= 3 s`).
* **Required Fix:** A short button press while the platform is empty must trigger a mid-session Tare offset update without closing or splitting the current session ID.

### 6.2 Walk-Through (`Lintasan`) vs. Stationary Enclosure
* **The Issue:** Lutfi's design does not feature motorized gates; it relies on manual gates or an open walkthrough chute with an entrance optical beam (`E3Z-T81`).
* **Sampling Rate Constraint:** At 10 samples per second (10 SPS from the HX711), a goat walking through an open chute without stopping remains on the platform for only 1–2 seconds (yielding 10–20 raw readings). Achieving a valid stable-weight window with low standard deviation on an animal moving through is mathematically challenging.
* **Recommendation:** Clarify physical cage procedure: animals must be stopped manually inside the chute for 3–5 seconds to allow genuine weight stabilization.

### 6.3 Handling Unstable Readings (`bobot_stabil = false`) in Growth Tracking
* **The Issue:** If an animal jumps continuously, Lutfi's algorithm falls back to taking the median of all readings during presence (`median seluruh HADIR`) and sets `bobot_stabil = false`.
* **Data Integrity Risk:** If the Mobile App naively includes `bobot_stabil = false` records when calculating Average Daily Gain (ADG / PBBH) or session averages, corrupted outlier measurements will distort the animal's growth curve.
* **Recommendation:** Unstable records must be flagged with a warning in the app, marked as `unverified` / `needs_review`, and excluded from official PBBH calculations until verified by the farmer.

### 6.4 The Rural Barn Hotspot Dilemma (Offline Behavior)
* **The Issue:** In Lutfi's current architecture, the ESP32 uploads directly to Firebase in Singapore via a phone Wi-Fi hotspot (`ESP32 -> Hotspot -> Singapore Firebase -> Mobile App`).
* **Failure Mode:** If the barn is in a rural area with weak or absent 4G/cellular data, the phone and ESP32 cannot reach Firebase—even if the farmer is standing right next to the scale.
* **Consequence:** The mobile app will display `Luring` (Offline) and show zero live readings. The farmer can only view readings on the physical 20x4 LCD screen, while records accumulate in the ESP32's microSD queue.

### 6.5 Client-Side Joins and Query Limitations Without Cloud Functions
* **The Issue:** Because Firebase Cloud Functions are excluded (requiring a paid Blaze plan), there is no backend server trigger to merge manual RFID corrections from `koreksi/` back into `lintasan/`, or to update animal profiles in `ternak/`.
* **Consequence:** To display an animal's complete weight history with corrections applied, the mobile application must download both `lintasan/` and `koreksi/` nodes and execute relational joins in phone memory. While feasible for small herds, this pushes database responsibilities onto client hardware and complicates web marketplace querying.
