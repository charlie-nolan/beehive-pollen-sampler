# Experiment design

Status: protocol draft. Sample sizes are for a pilot hive; a lab running this would set its own.

## The question

When foragers settle on one flower type or several, is that each bee's own choice, or a decision the colony
makes together?

- If tagged bees' choices track the colony's state (brood, dearth, dances) more than their own past choices, it's
  a collective decision.
- If each bee stays loyal to her own flowers whatever the hive is doing, it's personal.

Working hypothesis: colony state drives how mixed the pellets are, not just individual preference.

## Two data streams

1. **Whole-hive sample:** random pellets about hourly from untagged bees show what the colony is bringing in.
   These are laid against the telemetry: weight, brood temperature, sound and dances.
2. **Tagged foragers (phase 2):** about 5 marked bees and an entrance camera that reads their tags.

## Forager crossover design

- **Two sampling rates, swapped per bee.** Each tagged bee spends a few days with her pollen collected on every
  trip and a few days on every fourth trip.
- **Counterbalanced order.** Half the bees start on each rate, then they swap, with a washout of a day or two in
  between. At least 3 bees per order.
- **Within-bee comparison.** Each bee is compared with herself, and the swap shows whether being sampled more
  often changes where she forages.
- **Controls.** Tagged bees that are never stripped, so the camera shows normal foraging.
- **Every trip logged.** The camera records every trip for every tagged bee, sampled or not, so the only thing that
  differs between groups is pollen removal.
- **Cohort timing.** Tag the cohort about 3 weeks before loading a cassette, so one cassette (4-6 weeks) covers
  that cohort's foraging life.

## Contamination and traceability

- Single-use wire, tape and waste bin for anything that touches pollen.
- Blank cycles with no pellet to measure carryover between samples.
- The skewer stops short of the cut plane so it can't drag material across.
- Every pellet row records cassette ID, frame, time, trap deployment, images and model version.
- The archive half stays whole and dry for DNA work, so the lab can check the microscope's IDs.

## Known limits (pilot)

- One hive and about 5 tagged bees is a pilot. Results describe that colony, not bees in general. Colony-level
  claims need several hives so colony and season aren't confounded.
- The microscope ID model needs validating against DNA results on a subset of pellets to get its error rate.
- Tagging may change behaviour, so compare tagged bees with untagged traffic.
- Pellet removal itself is the treatment in the crossover; the hourly whole-hive sampling is kept brief for the
  same reason.
