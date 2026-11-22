# Capstone to-do list

Add new questions here as they come up. When a decision is made, check off the item and record what was decided and why.

## Current priority — Validate the selected contribution

- [ ] **Test the novelty argument against the closest existing product.** From the comparison with the WAF proposal, distinguish an original implementation from a claim that the capability is new. Identify the strongest existing sheep product or farm workaround, describe one task it already handles, and compare operator outcomes on that same task. Confirm with the supervisor what evidence counts for the capstone.

- [ ] **Apply the supervisor’s novelty criterion.** Hafiz will provide the wording. Then reassess the selected concept and any required sources or comparisons before treating the novelty claim as final.
- [x] **Select the capstone direction (22 November 2026).** Recover the missing samples needed to reproduce the first valid stable weight from an interrupted animal pass. The narrower contribution is the rule for deciding which evidence to retrieve before issuing a result. [Research and candidate comparison](capstone-novelty-review.md)
- [x] **Compare prior art (22 November 2026).** Published sources already describe numeric stability tests, RFID warnings, operator retries, SD plus server storage, and retransmission in animal weighing. The review identifies the closest disclosures and scopes the remaining novelty hypothesis.
  - Tru-Test documents an operator-triggered retry that replaces the previous weight. [Tru-Test indicator manual, “Reweigh Key” (HTML copy)](https://manualzz.com/doc/4156090/tru-test-xr3000-sr3000-id3000-jr3000-user-manual)
  - iLivestock combines stable-weight indication, animal identification, an operator-triggered retry, and mobile recording. [iLivestock weighing guide, steps 5–9](https://help.ilivestock.com/en/articles/12942259-weighing-with-eweigh-eweighds-or-a-compatible-digital-weigh-head)
  - Amrulloh et al. describe sending a goat’s weight after the display settles. Wardhana et al. field-tested automated goat weight recording in a mobile app. [Amrulloh et al. (2024), §3.4](https://www.ojs.stmikplk.ac.id/index.php/saintekom/article/download/595/204/4207), [Wardhana et al. (2026)](https://journal.uinjkt.ac.id/index.php/ti/article/view/50110)
- [ ] **Check whether recovery matters at the farm.** Confirm species and observe how often connectivity interrupts a pass, what the operator currently does, and how long a result can wait after the goat leaves. If full replay already meets the farm’s need, reconsider the complexity.
- [ ] **Test the proposed comparison.** Measure actual pass length, encoded bytes per block, and link round-trip time. Replay the same traces with controlled gaps. Compare full replay, a single request for all gaps processed as each block arrives, and staged requests through the first qualifying window. Check exact decision agreement, time to result, and total traffic. Compare the cost of calculating the weight on the device.

## App and IoT upgrades to compare

- [x] **Compare four weighing-workflow improvements (22 November 2026).** The [upgrade review](sheep-weighing-upgrades.md) documents Indonesian research, industry precedents, existing app behavior, and a baseline for each candidate.
- [ ] **Observe one pen from entry to release.** Compare the expected roster, actual crossings, and unique animals with accepted weights. Record any untagged, ambiguous, repeated, or partial crossing and whether the operator could resolve it before releasing the group.
- [ ] **Follow a weight record beyond the scale.** Check whether the operator uploads files, combines live and replayed results, or needs both attempts from one day. Obtain a representative export if the farm uses one. Inspect a sale listing to see whether the partner sells by individual or lot and what happens when the listed animals change.
- [ ] **Choose one measurable improvement with Lutfi and the supervisor.** Compare the verified problem frequency and consequences with the cost of collecting independent reference data. Confirm species, division of work, and novelty criterion before revising the project scope.

## AI opportunity to discuss with the farm and supervisor

- [x] **Explore AI beyond selecting animals to weigh (22 November 2026).** The planned buying system is for sheep. Farmer uptake of the earlier recommendation is uncertain. The [four sheep AI candidates and their precedents](sheep-ai-opportunities.md) cover the scale, dispatch support, order identity, and flock management.
- [ ] **Ask the partner for recent examples.** Has a failed scale check affected earlier records? Have buyers reported a difference in pickup weight or difficulty identifying a sheep? Has a pen average changed after sales? Record the action taken and how often the problem occurs.
- [ ] **Check which candidate can be tested independently.** With Lutfi, verify whether the device can retain unloaded readings and known-mass checks. With the seller, check access to paired dispatch and pickup weights, independently identified phone photos, or dated pen rosters and repeat weights. Choose the relevant data only after establishing the workflow.
- [x] **Review AI precedents (22 November 2026).** Compared kidding-date estimates, labor alerts, growth forecasts, health screening, and selection of animals to weigh. The [AI review and source register](ai-novelty-review.md) records a candidate for evaluation.
- [ ] **Verify the farmer's decision.** Observe how animals are chosen for weighing. Record the liveweight target, how many animals can be handled, whether an operator can fetch named goats, and the consequences of a wrong decision. Identify whether the farmer wants accurate status across the herd or wants to find qualifying animals quickly.
- [ ] **Check the available histories.** Count goats, distinct dates per goat, intervals between visits, and opportunities to verify all eligible animals on evaluation dates. For a breeding farm, separately count confirmed pregnancies with mating dates, birth dates or times, and pre-birth weights. Identify which decisions an earlier estimate would change.
- [ ] **Test the simplest alternative.** At equal handling effort, compare the farmer's selection and a daily-gain rule with a learned ranking. Measure wrong target-weight decisions across all eligible goats. Test whether adding prior weighing quality improves the list.
- [ ] **Decide the scope with Lutfi and the supervisor.** After checking the field need, data, and novelty criterion, choose whether to pursue this AI candidate or keep the interrupted-weighing contribution as the capstone focus. Agree on ownership, deliverables, and test data before changing the specifications.

## Weighing workflow and validation

- [ ] **Define a weighing attempt.** Specify how the operator selects the goat, how the attempt starts and ends, what qualifies as stable, when to ask for a reweigh, and what the operator sees. Include a case where the reading is steady but the goat is only partly on the platform.
- [ ] **Decide what to keep for failed attempts.** The original session lifecycle writes samples and quality data after acceptance. Decide which outcome, reason, and supporting evidence to retain without creating a final weighing record for a failed attempt.
- [ ] **Plan the prototype tests.** Confirm access to goats, a suitable reference scale, and an operator. Set acceptance criteria for measurement error and the end-to-end workflow. Include normal weighing, unstable attempts, and recovery through a successful reweigh.
- [ ] **Define what happens when the connection drops.** Decide what the operator sees if an interruption prevents the backend from finalizing a weighing. If the scope claims reliable MQTT ingestion, specify how duplicate, late, or missing samples affect the session and test those cases.

## Scope and collaboration

- [ ] **Reconcile the scope and handoff with Lutfi.** Use the agreed weighing workflow and test criteria to review [the original scope](project-context.md) alongside [the collaboration handoff](project-handoff-context.md). Record the agreed component boundaries, ownership, and integration tests before updating either specification.
- [ ] **Check the proposed device interface with Lutfi.** Verify that the ESP32 can identify a closed pass, distinguish capture gaps from delivery gaps, and serve numbered ranges from microSD. Agree on pass-wide validity flags, calibration version, and the status of an unstable fallback median.
- [ ] **Align the project guidance with Chapter 4.** The repository's `AGENTS.md` still describes *Skripsi Inovasi Produk*. Bring the project guidance and report outline into line with [Chapter 4 of the UGM guide](../examples/pedoman_ta.pdf), including the division of work and the work breakdown structure.
