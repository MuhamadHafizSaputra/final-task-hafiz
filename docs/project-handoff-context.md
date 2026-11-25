# Project Handoff — IoT Sheep Weighing

Updated 25 November 2026 · UGM undergraduate capstone · DIKE, FMIPA · Planning phase

## Problem and thesis boundary

Hafiz wants to address manual weighing and data entry, incomplete animal histories, and limited visibility into how measured weight relates to price. The thesis evaluates the operator's weighing and recording workflow. Traceable measurements can support a separate sheep marketplace later. The marketplace, buyer workflow, and transaction features are future work.

The prototype combines a gated IoT scale with the farmer's Expo/React Native sheep recording system. The app maintains sheep profiles, RFID assignments, and weight history, and displays saved weighing results. Growth tracking (PBBH, average daily weight gain) and any separate website need an explicit scope decision.

Sheep (domba) is the target species for the product and evaluation. Final Indonesian and English thesis titles are open. Both should reflect the RFID identity and delayed-upload focus.

## Ownership and component plan

| Owner | Responsibilities |
|---|---|
| Hafiz | Define the backend upload contract, implement ingestion and reconciliation, and develop the database, mobile app, identity correction, results and status UI, and software evaluation. Website work belongs to Hafiz, with scope still open. |
| Lutfi | Weighing platform, ESP32 acquisition, on-device filtering and stable-weight detection, RFID, presence sensing, local storage, LCD, and firmware. |
| Both | Agree on device messages, transport, database boundaries, replay behavior, operator feedback, and integration tests. |

Lutfi's hardware plan uses a Youta platform with a 300 kg load cell and HX711, an ESP32, a WL-134 RFID reader (134.2 kHz), an E3Z-T81 through-beam infrared sensor, a 20×4 display, a DS3231 battery-backed clock, and microSD. The plan assigns measurement to ESP32 Core 1 and networking to Core 0. The tare button is deferred. The display shows live weight during weighing and the final stable weight selected by the ESP32 after acceptance, including offline. The buzzer and indicator LEDs signal local weight acceptance or reweigh. The app shows pending sync when it knows an upload is incomplete.

Hafiz's software plan uses Expo/React Native, a Next.js backend/API, and Supabase/PostgreSQL. The ESP32 will upload samples and pass outcomes to **Supabase PostgREST over HTTPS**. Agree on device authentication, the ingestion endpoint and payloads, and how new or replayed data triggers backend reconciliation. The database schema is a design artifact. Agree on which tables the thesis will implement and test.

## Weighing and recording workflow

1. The operator starts a batch (**sesi**). When a sheep enters the platform, the ESP32 scans its RFID tag. A missing or ambiguous read loops back to scanning. A confirmed tag starts the weighing pass (**lintasan**). The device uses infrared and a weight threshold for presence. Full platform occupancy remains a separate stability requirement to validate.
2. After the successful RFID read, the ESP32 starts numbering and timestamping weighing samples at 10 samples/s, buffers the pass on microSD, and displays live weight. The ESP32 filters samples and checks successive windows while the sheep is on the platform.
3. **Temporary values for the flow diagram:** Use a 2 s stability window (20 consecutive samples) and a 10 s retry interval. If no window qualifies by the end of an interval, notify the operator with the buzzer or indicator LEDs and automatically keep sampling within the same pass. Keep the sample sequence and raw readings across retries. Validate these timings on the scale before fixing them. The filter and stability threshold remain open.
4. A qualifying stable window is the sole end condition for the current ESP32 flow. Keep the pass active and continue checking new windows until one qualifies. Then show the final local weight, signal acceptance, and queue the completed pass for upload.
5. After reconnection, replay the full buffered pass and deduplicate by pass ID and sample number. Retain all received raw samples and pass outcomes for the thesis evaluation, including rejected and timed-out attempts. For this prototype, the backend adds an official weight only when the measurement is valid and the currently active tag has one matching assignment at capture time. Store passes with a replaced tag, ambiguous identity, or unreliable capture time without publishing a weight. Identity confirmation in the app is deferred.

## RFID replacement and late uploads

Keep a permanent animal ID and a dated history of RFID tag assignments. Any signed-in app user with access to the sheep's profile can record a replacement. Record who made the change and when, and check that the new tag is available for assignment.

**New-tag scan.** From the sheep's profile, the operator selects a scale and taps *Pindai tag baru*. The backend creates an expiring scan request for that ESP32. The ESP32 checks for the request over HTTPS and enters tag-scan mode when idle. In this mode it reads one tag and returns its ID with the scan request ID without starting a weighing pass. The backend makes the result available to the app, which displays the scanned ID. On *Simpan*, the backend rechecks tag availability and updates the old and new assignments together. If the scan expires or is cancelled, the profile is unchanged and the scale returns to its normal weighing mode. The exact request timing and endpoint design remain open.

A tag can be reused once its active assignment has ended. For a sold sheep, record when its tag was detached and keep the historical assignment. Before attaching the tag to another sheep, check that it has no active assignment. Hold delayed uploads from the old assignment outside official weight history so they cannot be attributed to the new sheep.

1. The ESP32 captures a valid weighing under tag A and buffers the pass during an outage.
2. In the app, the farmer scans tag B with the ESP32 reader and saves it on the same sheep profile. The backend closes the assignment for A and records the start of the assignment for B.
3. The old pass uploads with the original tag A and capture time. The backend preserves the old tag, the original capture time, and the stored pass for later reconciliation.
4. The old pass stays out of official weight history in the current prototype. The farmer confirmation workflow is deferred. Replaying an identical upload preserves the stored pass.

## Backend upload contract

Hafiz defines the ingestion contract and Lutfi implements it on the ESP32. Use a stable pass ID and numbered samples. The proposed payload includes the device and batch IDs, original RFID tag, capture time and clock status, sample bounds and raw readings, local acceptance or reweigh outcome, and the selected window, result, and rule version when available.

The ESP32 keeps the buffered copy until the backend acknowledges that it has durably stored the complete pass and its samples. This acknowledgement can arrive even when the pass is stored without an official weight. The backend treats identical retries as the same pass and flags conflicting contents for review.

## Thesis contribution and evaluation

**The thesis combines IoT weighing with a sheep recording system.** Evaluate the full path from a sheep's RFID scan and local weighing through its saved profile and weight history. The delayed-upload test checks that a valid weighing captured under an old tag still reaches the same profile after replacement. A permanent animal ID ties together weights and tag assignments. Replaying the same pass should produce at most one official weighing. [Validation plan](capstone-todo.md) · [Flow comparison](flow-comparison-and-novelty.txt) · [Editable workflow diagrams](sheep-weighing-flow.drawio)

- **Primary evaluation:** Compare the prototype with the farm's current identification and recording workflow. Capture a pass on the old tag, replace the tag, record a pass on the new tag, then upload and replay the old pass. Verify that the new-tag weight reaches the existing sheep profile, the delayed old-tag pass is retained without creating an official weight, and replay creates no duplicate record. Include uncertain capture times, partial uploads, duplicate retries, and conflicting tag assignments in integration tests.
- **Weighing evaluation:** Use a reference scale to measure weighing error and report how many passes yielded an accepted weight. Include unstable passes and steady readings from partial platform loading. Use the same calibration, filter settings, sample order, stability rule, and rounding when comparing interrupted and complete records.
- **Earlier research direction:** The 22 November design retrieved missing sample ranges until it could reproduce the first valid stable window from a complete pass. Full replay, requesting all gaps once, and staged recovery remain possible comparisons if useful for the reconciliation evaluation.
- **Novelty and field evidence:** Tag replacement, connected scales, and weight histories have precedents. The proposed contribution is the tested workflow that preserves identity across a tag change and reconciles delayed or duplicate uploads. Confirm the partner farm's actual replacement procedure and the supervisor's novelty criterion. The historical-weight filter kfino remains an optional research comparison.

## Open decisions

| Topic | What needs a decision |
|---|---|
| Thesis titles | Select matching Indonesian and English titles for the sheep-weighing project that reflect the agreed contribution and offline behavior. |
| Pass boundaries and stable weight | Verify full platform occupancy and validate the provisional timing. Choose the filter, stability threshold, and selection rule using the same passes and reference weights. |
| Backend upload details | Hafiz specifies payload field names, schema version, and the format of the durable receipt for Lutfi's firmware. |
| Feedback signals | Define the acceptance and reweigh buzzer and LED patterns and how long to leave the final weight on the display. |
| Evaluation | Agree on calibration, reference scale, test sample size, and thresholds for weight error, reweigh rate, correct identity, and duplicate-free replay. Confirm the novelty criterion with the supervisor. |
| Optional mobile live preview | Decide whether to include a transient preview in the farmer app. If included, use up to 1 update/s while the sheep is present and the connection is available. Supabase Realtime broadcast is one option. |
| Implementation details | Finalize authentication, database tables, and component responsibilities with Lutfi. Confirm the scope of optional farmer-app features. |

## Background and prior-art notes

These are carried-forward research notes. Keep their source status when drafting the proposal.

- **Problem evidence:** Rianto et al. (2026) is a lead for the relationship between goat weight and price. Verify the source and exact claim before citing it. The reported 8.5–8.7% estimation deviation attributed to Septyan et al. (2023) concerns Bali cattle and body-measurement formulas. Use species-specific evidence for a sheep thesis. Amrulloh et al. (2024) is a lead for the labor of manual weighing.
- **Closest systems:** Previous notes record a full-text review of Amrulloh et al. (2024). The system used Arduino, RFID, a load cell, and a REST API for goat weighing, used a qualitative stability indication, and reported functional tests without a reference-scale accuracy test. The [local flow comparison](flow-comparison-and-novelty.txt) covers Wardhana et al. (2026), RFID replacement in Aisuwarya et al. (2019), and the Gallagher TSi 2 commercial workflow.
- **Abstract-only leads:** Sholicha, Irfandi, and Turawan (2023) for RFID-based goat recording. Sumiharto and Malik (2026) for ESP32/RFID/Next.js/Supabase monitoring. Rahayu et al. (2023) for an IoT weighing and marketplace concept. Kushartadi, Laagu, and Asvial (2023) for BLE animal tags and MQTT monitoring.
- **Additional leads:** The previous full-text notes describe Shuvo et al. (2026) as offline cattle weight estimation from photos and body measurements. DigiZiege (Kulesz, 2026) is a conference-talk lead about offline photo-based goat weight estimation. Efendi et al. (2025) and Farooq et al. (2022) need verification before use. Earlier notes also record Waluyo et al. (2018) and Oktaviani et al. (2023) as livestock marketplace leads, Gonzalez-Garcia et al. (2025) as a kfino lead with bibliographic details to verify, and Tru-Test as a commercial workflow comparison.

## Future marketplace

A responsive website and the farmer app can share a backend and database. Farmers may create sheep listings manually or choose to publish approved fields from a device measurement. Keep an animal profile, an individual pass and its evidence, a finalized weighing record, and a public listing distinct. Synchronization must never publish a listing automatically.

Show the measurement source to buyers as **self-reported**, **device-measured**, or **verified measurement** when the device result meets an agreed quality rule. Keep private notes, credentials, and unrestricted weighing history private. The first version can support search, filters, photos, published weight, price, approximate location, availability, and seller contact. Proposed listing states are draft, active, paused, reserved, sold, and archived. Payments, delivery, escrow, and auctions are later decisions.

## Repository references

- [Capstone to-do list](capstone-todo.md) and [sheep-farm feature research](sheep-farm-feature-research.md) cover field questions, tests, and optional features.
- [Architecture options](architecture-notes.txt) and [MQTT/Supabase flow](full-flow-sample-to-supabase.txt) record earlier designs. [Lutfi's Firebase notes](lutfi-firebase-db-notes.md), [concept](../Konsep_Batch1.pdf), and [flowchart](../Flowchart_Bacth1.pdf) record the hardware-side proposal.
- [Database model](database.dbml) and [SQL schema](schema.sql) are working designs.
- [Repository writing guidance](../AGENTS.md), the [official UGM guide](../examples/pedoman_ta.pdf), and the [proposal](../template/proposal/main.tex) and [skripsi](../template/skripsi/main.tex) sources govern thesis preparation. Follow the official guide when it differs from an example. Validate references before adding them to the bibliography.
