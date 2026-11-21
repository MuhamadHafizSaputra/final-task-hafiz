# Capstone to-do list

Add new questions here as they come up. When a decision is made, check off the item and record what was decided and why.

## Current priority — What is the contribution?

- [ ] **Agree on the contribution claim.** The working hypothesis is that an explicit stability rule can accept a goat weighing or tell the operator why to try again. The proposed system records the outcome of each attempt and saves a final weight against the goat only after acceptance. Verify that this workflow addresses a real problem for the intended farm operator.
- [ ] **Compare the workflow with the closest alternatives.** For each source, note who decides to retry, whether a failed attempt is kept with a reason, how the accepted weight is linked to the animal, and what the authors or manufacturer actually tested.
  - Tru-Test documents an operator-triggered retry that replaces the previous weight. [Tru-Test indicator manual, “Reweigh Key” (HTML copy)](https://manualzz.com/doc/4156090/tru-test-xr3000-sr3000-id3000-jr3000-user-manual)
  - iLivestock combines stable-weight indication, animal identification, an operator-triggered retry, and mobile recording. [iLivestock weighing guide, steps 5–9](https://help.ilivestock.com/en/articles/12942259-weighing-with-eweigh-eweighds-or-a-compatible-digital-weigh-head)
  - Amrulloh et al. describe sending a goat’s weight after the display settles. Wardhana et al. field-tested automated goat weight recording in a mobile app. [Amrulloh et al. (2024), §3.4](https://www.ojs.stmikplk.ac.id/index.php/saintekom/article/download/595/204/4207), [Wardhana et al. (2026)](https://journal.uinjkt.ac.id/index.php/ti/article/view/50110)
- [ ] **Decide how to demonstrate the practical improvement.** Use the farm’s current workflow or another realistic baseline if making a comparative claim. Choose metrics that match the benefit you claim, such as error against the reference scale, first-attempt acceptance, time to a usable record, or correct goat-to-record matching. Keep any claim of novelty provisional until the comparison and tests support it.

## Weighing workflow and validation

- [ ] **Define a weighing attempt.** Specify how the operator selects the goat, how the attempt starts and ends, what qualifies as stable, when to ask for a reweigh, and what the operator sees. Include a case where the reading is steady but the goat is only partly on the platform.
- [ ] **Decide what to keep for failed attempts.** The original session lifecycle writes samples and quality data after acceptance. Decide which outcome, reason, and supporting evidence to retain without creating a final weighing record for a failed attempt.
- [ ] **Plan the prototype tests.** Confirm access to goats, a suitable reference scale, and an operator. Set acceptance criteria for measurement error and the end-to-end workflow. Include normal weighing, unstable attempts, and recovery through a successful reweigh.
- [ ] **Define what happens when the connection drops.** Decide what the operator sees if an interruption prevents the backend from finalizing a weighing. If the scope claims reliable MQTT ingestion, specify how duplicate, late, or missing samples affect the session and test those cases.

## Scope and collaboration

- [ ] **Reconcile the scope and handoff with Lutfi.** Use the agreed weighing workflow and test criteria to review [the original scope](project-context.md) alongside [the collaboration handoff](project-handoff-context.md). Record the agreed component boundaries, ownership, and integration tests before updating either specification.
- [ ] **Align the project guidance with Chapter 4.** The repository's `AGENTS.md` still describes *Skripsi Inovasi Produk*. Bring the project guidance and report outline into line with [Chapter 4 of the UGM guide](../examples/pedoman_ta.pdf), including the division of work and the work breakdown structure.
