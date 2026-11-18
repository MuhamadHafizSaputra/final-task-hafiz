# Project Context: IoT Goat Weighing System

*Last updated: 2026-11-18*

## Working Title
- **Indonesian:** Rancang Bangun Timbangan Kambing Berbasis IoT dengan Deteksi Bobot Stabil dan Pemrosesan Data Berbasis MQTT
- **English:** Design and Development of an MQTT-Based IoT Goat Weighing Scale with Stable-Weight Detection

## Background and Problems
- **Problems:** Manual data collection, lack of detailed records, lack of price transparency.
- **Evidence:** Body weight strongly correlates with goat price (Rianto et al., 2026). Traditional estimation deviates ~8.5-8.7% (Septyan et al., 2023 - on cattle). Manual weighing is laborious (Amrulloh et al., 2024).

## Scope
- **In Scope:**
    - Gated IoT weighing platform.
    - ESP32 acquisition device that sends load-cell samples through MQTT.
    - MQTT broker and backend consumer for sample ingestion, stable-weight processing, and data persistence.
    - Native mobile app (Expo/React Native) for authenticated viewing, recording support, and result display.
    - Backend/database (Next.js/Supabase/PostgreSQL).
    - Evaluation against reference scale.
- **Out of Scope:** Marketplace dashboard and a fully tested offline-first weighing path.

## Proposed Contributions (Novelty)
1. **Stable-weight detection:** Backend processing of continuous timestamped load-cell samples using a defined stable-window rule, median reporting, and re-weigh rejection. Validation against reference scale.
2. **Data-quality layer:** Per-session quality metrics, including stability statistics and rejection reasons; kfino remains an optional post-processing comparison.
3. **Reliable MQTT ingestion:** Idempotent MQTT sample ingestion with session boundaries, duplicate handling, ordering by source timestamp/sample number, and complete measurement audit data.

## System Design
- **Hardware:** ESP32, load cell + amplifier, gated platform, potential RFID, and farm Wi-Fi or cellular internet connection.
- **Transport:** ESP32 publishes timestamped load-cell samples to an authenticated MQTT broker. MQTT is transport, not permanent storage.
- **Backend:** Backend consumer subscribes to MQTT, validates and deduplicates samples, processes stable-weight detection, then writes finalized data to Supabase/PostgreSQL through Next.js/backend services.
- **App:** Expo/React Native app displays session status and finalized results through an authenticated API or realtime channel. It does not calculate final IoT weight.
- **Future marketplace:** Responsive web app/PWA using the shared backend and database.

## Related Work Notes

### Closest Related Systems

- **Amrulloh et al. (2024):** Published in *Jurnal Saintekom*, 14(2). Developed an IoT goat scale using Arduino Uno, load cell, and RFID; integrated Laravel web and React Native mobile applications through a REST API for a goat investment platform. Data was sent when the monitor number stopped rising or falling drastically, which defined stability qualitatively. The study reported black-box functionality testing, with 8 of 11 items passing. Weighing accuracy was not tested against a reference scale. **Verification level: read in full.**
- **Sholicha, Irfandi, and Turawan (2023):** Published in *Jurnal Ilmu Komputer dan Agri-Informatika*, 10(1). Developed the Smart Goat recording application for goat-fattening programs, using RFID, a digital scale, and pen-environment monitoring. **Verification level: abstract only.**
- **Sumiharto and Malik (2026):** Published in *Jurnal Teknologi Informasi dan Komunikasi*, 19(1). Developed web-based livestock weight monitoring using ESP32, RFID, load cell, Next.js, and Supabase. The reported system was stable up to 90 requests per second. **Verification level: abstract only.**
- **Rahayu et al. (2023):** Developed an IoT livestock-weighing system for the Caribi marketplace and the Maro livestock-investment scheme. **Verification level: abstract only; details require confirmation.**
- **Kushartadi, Laagu, and Asvial (2023):** Published in *International Journal on Advanced Science, Engineering and Information Technology*, 13(4). Developed IoT smart weighing with BLE animal tags, ESP32, load cell, and MQTT for remote livestock monitoring. **Verification level: abstract only.**

### Related Weight-Estimation and Offline Applications

- **Shuvo et al. (2026):** Published in *Smart Agricultural Technology*. Developed Smart-Herbo, an offline PWA that estimates cattle weight from photographs and body measurements. The study reported MAE of 7.52 kg on five cattle and an SUS usability score of 82.25. It used a certified electronic scale as the reference, but it estimated rather than directly measured weight. **Verification level: read in full.**
- **Kulesz (2026):** Presented DigiZiege, a PWA for goat farmers with photo-based weight assessment that works offline. This supports the feasibility of offline livestock applications, but the PWA is not a direct-weighing system. **Verification level: conference-talk information; details require confirmation.**
- **Efendi et al. (2025):** Collected weekly weights from 15 sheep over six months using Arduino and ESP32, then applied simple linear regression to model growth. **Verification level: details require confirmation.**
- **Farooq et al. (2022):** Surveyed IoT and smart-livestock applications. **Verification level: title only; claims require confirmation.**

### Livestock Marketing Applications

- **Waluyo et al. (2018):** Developed an Android-based m-commerce application for goat information and sales, connecting buyers with farmers.
- **Oktaviani et al. (2023):** Designed an e-marketplace for goat farmer groups, supporting sales, auctions, and livestock profit sharing.

These marketing systems are relevant to the long-term motivation for transparent, measured livestock data, but the marketplace is outside the current final-task scope.

### Commercial Reference Products

- **Gallagher and Tru-Test:** Commercial livestock scales and phone applications provide features such as electronic identification (EID) linking and weight lock-on for moving animals. These products are practical references for weighing workflows and product features, not automatically evidence of academic novelty. Specific product models and claims require verification before citation.

### Data-Quality Filtering

- **Gonzalez-Garcia et al. (2025):** Published in *Smart Agricultural Technology*. Validated the kfino algorithm (Kalman filter with impulse noisy outliers) on walk-over-weighing data. The author list and exact bibliographic details still require verification. Kfino addresses outliers in a series of weights recorded over time for an animal; it does not solve motion noise inside one weighing and requires enough historical readings. Therefore, it is an optional post-processing comparison, not the core stable-weight detection method.

### Evidence and Novelty Limits

- Existing systems already combine IoT livestock scales with web or mobile applications. The proposed contribution is therefore not the general architecture.
- The current novelty hypothesis is that no located study has jointly tested goat-weighing accuracy against a reference scale, per-reading data-quality control, and MQTT-based stable-weight processing. This claim is based on a limited literature search and must not be stated as definitive until the literature review is expanded.
- Do not transfer cattle findings directly to goats. The 8.5--8.7\% deviation reported by Septyan et al. (2023) concerns body-measurement formulas tested on Bali cattle, not goats.
- Do not treat MQTT use, a native mobile app, or a PWA as novelty claims. These are architecture choices.
- Stable readings and measurement accuracy are separate claims. Stability concerns spread in readings during one session; accuracy requires validation against a reference scale.

## Future Marketplace Plan

The marketplace is a planned second-stage product. It is not part of the current final-task implementation, but the current data model should preserve enough information to support it later.

### Product Structure

Use one shared platform with separate user interfaces:

- **Responsive web marketplace:** Accessible directly through a URL. Buyers do not need to install or open the farmer mobile application first. Farmers can also use the web interface to create manual listings.
- **Farmer data-capture application:** Native mobile application for repeated field data entry, animal identification, and viewing MQTT-processed weighing results.
- **Shared backend and database:** One API and database serve the farmer application and future marketplace while enforcing role-based access and publication controls.

This is one platform, not two disconnected products. The interfaces remain separate because their workflows differ: farmers collect data in the field, while buyers browse and compare listings.

### Marketplace Data-Entry Paths

#### Manual web path

1. Farmer opens the marketplace website.
2. Farmer creates an account or signs in.
3. Farmer creates a goat profile or enters listing data manually.
4. Farmer enters weight, sex, age, measurements, photos, notes for private use, price, and availability.
5. The system marks manually entered measurements as `self-reported`.
6. Farmer reviews and publishes the listing.

#### Automatic IoT path

1. Farmer registers a goat in the farmer application.
2. The IoT scale captures timestamped load-cell samples.
3. ESP32 publishes samples through MQTT.
4. Backend consumer groups samples into a weighing session, applies stable-weight detection, and performs data-quality checks.
5. Backend stores samples, final weight, quality result, and processing metadata in Supabase/PostgreSQL.
6. Farmer reviews the result in the native mobile application and explicitly chooses whether to publish a marketplace listing.
7. The marketplace displays the approved measurement as `device-measured` or `verified measurement`, according to the defined quality threshold.

Synchronization must not automatically publish a goat. A weighing record and a marketplace listing are separate objects.

### Trust Labels

Data source must be visible to buyers:

- `Self-reported`: value entered manually by the seller; no device measurement was validated.
- `Device-measured`: weight originated from a linked IoT scale.
- `Verified measurement`: device measurement passed the defined stable-weight and quality rules.

Manual mobile-app input remains `self-reported`; entering a value through an application does not make it an IoT measurement.

### Shared Data Model

Keep these entities separate:

- **Goat profile:** goat ID, owner/farmer ID, sex, age, breed, body measurements, photos, and private notes.
- **Weighing session:** goat ID, device ID, MQTT session identifier, source timestamped samples, processing state, message-delivery audit data, and finalization state.
- **Weighing record:** goat ID, final weight, measurement time, source (`manual` or `IoT`), device ID when applicable, stable-weight result, quality score, and audit metadata.
- **Weighing session lifecycle:** MQTT consumer groups incoming samples into a `weighing_sessions` row (`collecting` → `processing` → `accepted` / `rejected` / `timeout`). Only after a stable window is accepted does the backend write a `weighings` row, `weighing_samples`, and `weighing_quality` in one transaction.
- **Marketplace listing:** goat ID, asking price, public photos, location area, availability, seller contact method, approved public fields, publication time, and listing status.

A goat can have many weighing records. A listing can be drafted, published, paused, reserved, sold, or archived without deleting private animal or weighing history.

Suggested listing states:

```text
draft | active | reserved | sold | archived
```

Suggested measurement-source values:

```text
manual | IoT
```

The marketplace must expose only farmer-approved fields. Private notes, private farm information, device credentials, synchronization metadata, and unrestricted weighing history must not become public by default.

### Future Marketplace Architecture

```text
Buyer
  -> Responsive web marketplace
  -> Public listing API
  -> Shared backend and database

Farmer without IoT application
  -> Responsive web marketplace
  -> Manual listing form
  -> Shared backend and database

Farmer with IoT application
  -> IoT scale
  -> MQTT broker
  -> Backend consumer and stable-weight processor
  -> Shared backend and database
  -> Native farmer mobile application
  -> Farmer approval and publication control
  -> Public listing API
  -> Responsive web marketplace
```

The marketplace web interface should support listing search, filtering, listing detail pages, latest published weight, measurement-source labels, photos, price, approximate location, availability, and a seller contact method. A first marketplace version should avoid payments, delivery, escrow, auctions, and full transaction management unless later scope explicitly includes them. Buyer contact through a seller-selected channel is the simpler initial transaction model.

### Future Marketplace Boundaries

- Marketplace UI is outside the current final-task scope.
- The current final task should focus on reliable weighing, MQTT sample ingestion, backend stable-weight processing, result display, and an extensible backend data model.
- The web marketplace may be developed later without requiring buyers to use the farmer application.
- The current thesis should describe marketplace integration as future work or a design consideration, not as an implemented feature.
- Farmer data-capture app uses Expo/React Native (native mobile app); marketplace remains web-based.

## Open Decisions
- Hardware finalization: RFID, load-cell capacity and specifications, platform dimensions, and enclosure details.
- Backend implementation details and authentication model.
- Kfino implementation detail and whether it will be included as an optional comparison.
- Testing scale, goat breed, sample size, test sessions, and reference-scale specifications.
- Marketplace publication fields and seller contact method.
- Whether future marketplace transactions will remain contact-based or later include payments, delivery, escrow, or auctions.

## Final Decision (2026-11-12)
- Farmer data-capture app: native mobile app (Expo/React Native).
- Current capture/transport: MQTT broker + backend consumer + Supabase/PostgreSQL.
- Stable-weight processing: backend service using full sample stream.
- Offline-first weighing path: not yet confirmed under current Option C; requires ESP32 buffering or gateway replay design before it is declared implemented.
