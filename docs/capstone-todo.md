# Capstone to-do list

Add new questions here as they come up. When a decision is made, check off the item and record what was decided and why.

## Hafiz’s shortlist of optional farmer-app features — 23 November 2026

1. **Body-condition prompt at weighing.** Use an identified ewe’s weight history to flag a hands-on condition check while she is still at the scale.
2. **Indonesian voice notes.** Attach a spoken observation and a farmer-confirmed follow-up to the current weighing.
3. **Camera reading of the printed ear tag.** If RFID misses, suggest the visible ID for the operator to verify.

These three came from the first round. [Research evidence and evaluation ideas](sheep-ai-opportunities.md)

- [ ] **Compare the voice-note idea with AgriWebb Farm Diary.** Its AI turns typed or dictated notes into draft farm records. Its guide lists location and age class for animal selection and excludes electronic and visual IDs from that selection. Ask the farmer to record an Indonesian observation while a specific sheep is on the scale. Compare time and correct animal assignment against the current method. [AgriWebb Farm Diary FAQ](https://help.agriwebb.com/en/articles/16062695-agriwebb-farm-diary)

Hafiz also shortlisted ideas 1, 2 and 4 from the [additional farm-feature research](sheep-farm-feature-research.md).

- **Feed cost per kilogram gained by a pen.** Match feed issued and its cost to the total weight gained by the same animals over the same period.
  - [ ] Reconstruct one completed pen period with the farmer. Compare automatic matching of scale records and feed issues with manually entering group gain and feed cost in a calculator. [Commercial comparisons](sheep-farm-feature-research.md#1-how-much-did-the-feed-cost-for-each-kilogram-this-pen-gained)
  - [ ] Ask for the last time a pen’s feed cost per kg looked unusually high. Check its feed invoices, pen roster and weighing times relative to feeding. Establish whether different weighing conditions or a price change could have changed the farmer’s decision. [Indonesian precedents and candidate tests](sheep-farm-feature-research.md#indonesian-precedents-and-a-candidate-use-of-the-scale-data)
- **Age-aware comparison at weaning.** Show each lamb’s age and comparable peers alongside its measured weight so the breeder can interpret size differences.
- **Weight-history continuity after tag replacement.** Link a verified replacement tag to the existing animal profile and retain earlier weights and tag assignments.

- [ ] **Check the shortlisted problems at the partner visit.** Ask to see a dated pen feed record and its matching weights, a recent weaning comparison, or the last tag replacement, depending on the farm’s work.
- [ ] **Investigate quick profile lookup in the pen.** Ask the operator to demonstrate the last lookup away from the scale. Compare the current method, phone-camera reading of a visible tag, and facial matching on the partner’s species. Enrol animals against verified RFID identities and test on a different day, including unreadable tags and animals outside the enrolled group. Time the complete lookup and count correct profiles, wrong profiles and unresolved attempts. Facial lookup is an open candidate. A sheep Android prototype already displays the recognised ID. [LSR-YOLO, Fig. 14](https://www.mdpi.com/2076-2615/13/11/1824) · [SheepFaceRec field study](https://doi.org/10.1016/j.atech.2025.101362) · [Goat identification study](https://pmc.ncbi.nlm.nih.gov/articles/PMC11640667/)

## Current priority — Validate the selected contribution

- [x] **Confirm the capstone focus (24 November 2026).** Keep sheep weight histories linked after RFID tag replacement and reconcile delayed weighing uploads. Use sheep for the product and evaluation, and send device data over HTTPS REST to Supabase. [Thesis contribution and evaluation](project-handoff-context.md#thesis-contribution-and-evaluation)
- [ ] **Test tag replacement during delayed upload.** Capture a pass on the old tag, replace the tag, capture a pass on the new tag, then upload and replay the old pass. Verify that the valid new-tag weight appears on the existing sheep profile, the old-tag pass stays stored with its original evidence, and retries create no duplicates. Defer publishing old-tag weights until the identity workflow is defined. [Evaluation cases](project-handoff-context.md#thesis-contribution-and-evaluation)

- [ ] **Check training images before committing to muzzle recognition.** The University of Mysore sheep subset includes 402 indexed animals, 1,608 face photos and 402 face videos under CC BY 4.0. Inspect frontal images across subjects for usable muzzle detail and annotate crops. Keep all frames from the same video together. Validate on RFID-confirmed animals from the partner farm across days. [Sheep archive 1](https://data.mendeley.com/datasets/rb2z9mhkjj/1) · [Archive 2](https://doi.org/10.17632/5fmpw9zndf.1) · [Archive 3](https://doi.org/10.17632/ghjc8dvkgk.1)

- [ ] **Pilot sheep muzzle identification on a phone.** Enrol RFID-verified sheep, compare muzzle-only and whole-face matching on a later visit, and include unenrolled sheep. Measure capture failures, wrong profiles opened and total lookup time against the operator’s usual method. [Sheep muzzle-print precedent](https://uniqueforensics.com/wp-content/uploads/2018/11/Ridgeology-Muzzleprints.pdf) · [Indonesian cattle muzzle study](https://www.sciencedirect.com/science/article/pii/S0168169913002093)

- [ ] **Test fast lookup and identity recovery in the pen.** Compare a phone-scannable animal QR with a pen QR opening a local photo roster. Ask about wrong-animal scans and dam–lamb mix-ups before choosing a direction. Indonesian cattle research already shows lost RFID tag replacement in Figure 7. [Aisuwarya et al. (2019)](https://hilirisasi.lppm.unand.ac.id/index.php/hilirisasi/article/download/225/72)

- [ ] **Validate ESP32 weight confirmation with Lutfi.** At 10 samples/s, process stable, moving and partial-platform passes on the actual ESP32 while microSD writes, RFID and Wi-Fi reconnection are active. Measure missed samples, weight error against a reference scale, agreement with an independent replay of the same samples, and time to operator feedback. Check that scanning one RFID tag starts the pass and the display shows the final stable weight after local acceptance. [Weighing workflow](project-handoff-context.md#weighing-and-recording-workflow)

- [ ] **Measure scale-to-record integration at the partner farm.** Observe how a measured weight reaches one sheep’s history today. Compare the current procedure with Lutfi’s scale and the app on manual entries, time to a saved result, and correct animal assignment. For a claim about recovery, also compare an interrupted pass with its complete recording. [Verified scale-to-record precedents](sheep-farm-feature-research.md#which-comparisons-demonstrate-scale-to-record-transfer)

- [ ] **Validate the sheep register as a farmer-facing contribution.** Follow one animal from the scale to a later health, breeding or growth decision. Record the tools the partner can access, duplicate entry and time to retrieve the correct history. Compare with Sheepin and Gembala Apps when describing the prior art. [Research and schema comparison](sheep-farm-feature-research.md#whole-flock-records-and-replacement-rfid-tags--23-november-2026)
- [ ] **Verify the actual replacement procedure with Lutfi and the operator.** Check same-number versus different-number replacements, how identity is established when both tags are missing, and what original tag evidence survives a delayed weighing upload. Test duplicate-tag rejection and identity confirmation before changing an animal’s profile. [Commercial workflows and test cases](sheep-farm-feature-research.md#whole-flock-records-and-replacement-rfid-tags--23-november-2026)

- [x] **Record the accepted proposal author's explanation (23 November 2026).** He described user need and lack of access to a suitable product as the basis for his product-innovation proposal. Use this as a working interpretation for discussion with the capstone supervisor.
- [ ] **Establish the partner farm's need.** Ask the operator to show the last weighing record and how it was created and used. Record what equipment and software the partner already has, which step they want improved, and how they would judge success.

- [x] **Confirm the thesis boundary.** Hafiz plans to build the sheep marketplace separately. Evaluate the capstone through the operator’s weighing and recording workflow. Buyer, listing, and delivery ideas in earlier reviews belong to the later product.

- [ ] **Choose a practical comparison.** Describe how existing products handle the partner's task in the related-work review. Evaluate the prototype against the partner's current process using an outcome that matters to the operator.

- [ ] **Apply the supervisor’s novelty criterion.** Hafiz will provide the wording. Then reassess the selected concept and any required sources or comparisons before treating the novelty claim as final.
- [x] **Record the earlier sample-recovery direction (22 November 2026).** Recover the missing samples needed to reproduce the first valid stable weight from an interrupted pass. Keep selective recovery as a possible comparison for the current reconciliation work. [Evaluation and earlier direction](project-handoff-context.md#thesis-contribution-and-evaluation)
- [x] **Compare prior art (22 November 2026).** Published sources already describe numeric stability tests, RFID warnings, operator retries, SD plus server storage, and retransmission in animal weighing. The review identifies the closest disclosures and scopes the remaining novelty hypothesis.
  - Tru-Test documents an operator-triggered retry that replaces the previous weight. [Tru-Test indicator manual, “Reweigh Key” (HTML copy)](https://manualzz.com/doc/4156090/tru-test-xr3000-sr3000-id3000-jr3000-user-manual)
  - iLivestock combines stable-weight indication, animal identification, an operator-triggered retry, and mobile recording. [iLivestock weighing guide, steps 5–9](https://help.ilivestock.com/en/articles/12942259-weighing-with-eweigh-eweighds-or-a-compatible-digital-weigh-head)
  - Amrulloh et al. describe sending a goat’s weight after the display settles. Wardhana et al. field-tested automated goat weight recording in a mobile app. [Amrulloh et al. (2024), §3.4](https://www.ojs.stmikplk.ac.id/index.php/saintekom/article/download/595/204/4207), [Wardhana et al. (2026)](https://journal.uinjkt.ac.id/index.php/ti/article/view/50110)
- [ ] **Check whether selective recovery matters at the farm.** Observe how often connectivity interrupts a pass, what the operator currently does, and how long a result can wait after the sheep leaves. If full replay meets the farm’s need, reconsider the complexity.
- [ ] **Test the proposed comparison.** Measure actual pass length, encoded bytes per block, and link round-trip time. Replay the same traces with controlled gaps. Compare full replay, a single request for all gaps processed as each block arrives, and staged requests through the first qualifying window. Check exact decision agreement, time to result, and total traffic. Compare the cost of calculating the weight on the device.

## App and IoT upgrades to compare

- [x] **Compare four weighing-workflow improvements (22 November 2026).** The [upgrade review](sheep-weighing-upgrades.md) documents Indonesian research, industry precedents, existing app behavior, and a baseline for each candidate.
- [ ] **Observe one pen from entry to release.** Compare the expected roster, actual crossings, and unique animals with accepted weights. Record any untagged, ambiguous, repeated, or partial crossing and whether the operator could resolve it before releasing the group.
- [ ] **Follow a weight record from the scale to the farmer’s app.** Observe how the operator obtains and checks the final record, including any manual corrections or repeated work.
- [ ] **Review the chosen contribution with Lutfi and the supervisor.** Compare the observed frequency and consequences of identity errors with the cost of collecting independent reference data. Confirm the division of work and novelty criterion before revising the proposal.

## AI opportunity to discuss with the farm and supervisor

- [x] **Research optional AI features for farm work (23 November 2026).** The [farmer-app follow-up](sheep-ai-opportunities.md) compares body-condition checks, Indonesian voice notes, visual tag reading, and feed-leftover scoring. It distinguishes sheep field evidence, commercial features, and evidence transferred from cattle.
- [ ] **Observe a weighing and ask about the next farm decision.** Establish whether the partner breeds or fattens sheep, who checks body condition, what observations are written down, and how often an unread tag causes manual entry. If feeding records matter, watch one trough check. Choose a candidate only when its reference data and a simpler comparison are available.

- [x] **Explore AI beyond selecting animals to weigh (22 November 2026).** The planned buying system is for sheep. Farmer uptake of the earlier recommendation is uncertain. The [four sheep AI candidates and their precedents](sheep-ai-opportunities.md) cover the scale, dispatch support, order identity, and flock management.
- [ ] **Ask the operator for recent examples.** Find an actual weighing or recording problem and record what happened, the action taken, and how often it occurs.
- [ ] **Check which candidate can be tested independently.** With Lutfi and the operator, identify which reference weights, pass records, or repeat visits can be collected for the observed farm workflow.
- [x] **Review AI precedents (22 November 2026).** Compared kidding-date estimates, labor alerts, growth forecasts, health screening, and selection of animals to weigh. The [AI review and source register](ai-novelty-review.md) records a candidate for evaluation.
- [ ] **Verify the farmer's decision.** Observe how animals are chosen for weighing. Record the liveweight target, how many animals can be handled, whether an operator can fetch named goats, and the consequences of a wrong decision. Identify whether the farmer wants accurate status across the herd or wants to find qualifying animals quickly.
- [ ] **Check the available histories.** Count goats, distinct dates per goat, intervals between visits, and opportunities to verify all eligible animals on evaluation dates. For a breeding farm, separately count confirmed pregnancies with mating dates, birth dates or times, and pre-birth weights. Identify which decisions an earlier estimate would change.
- [ ] **Test the simplest alternative.** At equal handling effort, compare the farmer's selection and a daily-gain rule with a learned ranking. Measure wrong target-weight decisions across all eligible goats. Test whether adding prior weighing quality improves the list.
- [ ] **Review the AI candidate with Lutfi and the supervisor.** Evaluate the field need and available data before considering it as an optional feature. Agree on ownership, deliverables, and test data before expanding the scope.

## Weighing workflow and validation

- [ ] **Validate automatic weighing retries.** Verify that the ESP32 signals each unstable interval and keeps the pass active until a window qualifies. Include a case where the reading is steady but the sheep is only partly on the platform. [Editable workflow diagrams](sheep-weighing-flow.drawio)
- [ ] **Verify replay and failed-pass retention.** Replay the full buffered pass and verify deduplication by pass ID and sample number. Check that received raw samples, outcomes and rejection reasons are retained. Verify that a pass closed without stable weight stays out of the official weight history.
- [ ] **Plan the prototype tests.** Confirm access to sheep, a suitable reference scale, and an operator. Set acceptance criteria for measurement error and the end-to-end workflow. Include normal weighing, unstable attempts, and recovery through a successful reweigh.
- [ ] **Define what happens when the connection drops.** Decide what the operator sees if an interruption prevents the backend from finalizing a weighing. Specify how duplicate, late, or missing samples affect a pass sent through HTTPS REST and test those cases.

## Scope and collaboration

- [ ] **Confirm scope and handoff with Lutfi.** Use the [project handoff](project-handoff-context.md) to review the weighing workflow and test criteria. Record the agreed component boundaries, ownership, and integration tests in the handoff.
- [ ] **Validate the backend upload contract with Lutfi.** Verify that the ESP32 can identify a closed pass, distinguish capture gaps from delivery gaps, replay a full pass, and retain its buffer until the backend confirms durable storage. Verify handling of duplicate and conflicting uploads. [Backend upload contract](project-handoff-context.md#backend-upload-contract)
- [ ] **Align the project guidance with Chapter 4.** The repository's `AGENTS.md` still describes *Skripsi Inovasi Produk*. Bring the project guidance and report outline into line with [Chapter 4 of the UGM guide](../examples/pedoman_ta.pdf), including the division of work and the work breakdown structure.
