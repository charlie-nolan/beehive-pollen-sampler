# Design history

*An archive of the design work done before this repository existed (2026-11-09 to 2026-11-11). It records every idea, how each one changed, what was dropped and why. Nothing here has been built yet; bench tests come next.*

**Summary.** It started on 2026-11-09 as a solar hive sensor (sound, temperature, humidity, traffic, hive size into SQLite) with a side idea to drop pollen pellets onto a microscope slide and identify them with a tiny local AI model. It is now a "smart bottom board" whose core is a pollen robot that catches, skewers, slices and smears each pellet onto a sealed tape cassette that doubles as a DNA-ready lab archive, with every sensor added afterwards and a forager experiment designed around it. What changed most is how a pellet becomes a readable sample (squash → tape lift → rolled print → cut on tape → skewer-and-swing, v2), and the shift from "a monitoring gadget" to "an instrument built around a research question."

## How to read this

- All dates are 2026, in UTC. The whole design came together over about two days of focused work.
- I worked the design through with an AI assistant as a sounding board and reference. The direction, the constraints and the key calls listed below are mine; it filled in reference facts and numbers, which I'll check on the bench.
- People, labs and places are described generically on purpose.
- Every idea in section 2 uses the same five headings: **Origin, Versions, Why it changed, Status, Options considered and rejected.**

## Contents

1. [Timeline of turning points](#1-timeline-of-turning-points)
2. [Idea-by-idea breakdown](#2-idea-by-idea-breakdown): A. the pollen robot, B. sensors, C. hardware, software and data, D. experiment and research, E. evolution summaries
3. [Dead ends and lessons](#3-dead-ends-and-lessons)
4. [Key decisions](#4-key-decisions)
5. [Open questions](#5-open-questions)

## My key calls

The decisions and catches that shaped the design most:

1. **The tape reel is the lab archive.** Every sample stays on a dated, sealed reel a lab can re-check or DNA-test, so no machine ID has to be taken on trust.
2. **Sample small and often, not everything at once.** Typical pollen trapping takes the whole intake for a day or two, which may change what the colony forages for. One pellet at a time, about hourly, over weeks and tied to hive telemetry gives better data.
3. **A nightly blank gap on the tape** as a day marker, with a longer gap on Sundays as a checksum, so the reel can be dated without software.
4. **UV autofluorescence as the first stage of identification**: pollen or not, then coarse groups, before any model runs.
5. **Ask a colony-level question.** Studies look at single bees or random pellets; I want to know whether hive state drives how bees mix pollen.
6. **A crossover experiment for focal bees.** Each bee is compared with herself (every trip vs every 4th trip, order swapped), which also offsets age.
7. **Catch the pellet in the funnel throat, skewer it, cut it and pivot.** The cutting force goes into the frame, not the tape, and four parts drop out of the design.
8. **Two catches that killed earlier versions:** the outside of the pellet is pollen too, so nothing reused may touch it; and tape adhesive fails in peel when a pellet tips under a cutting wire.
9. **Treat the machine as a micro-PLC problem**: a fixed step sequence with permissives, interlocks and a fail-open fault state, running on a microcontroller.
10. **Handle pellet variability like engine fuel trims**: measure, pick a recipe, check the result, log everything.
11. **Every sensor is part of the experiment**, not an extra, and the hardest part (the pollen robot) gets built first.

---

## 1. Timeline of turning points

| Date (UTC) | Stage | What changed | Why |
|---|---|---|---|
| 11-09 21:02 | Concept | Solar ESP32 hive sensor + base-station computer; pollen ID as an add-on. | Starting idea after a beekeeper friend described pollen-preference studies. |
| 11-09 21:04 | Pollen handling | Funnel → "pellet squisher" → slide. Slide swapped for a clear tape reel. | Changing glass slides robotically is fiddly; a reel gives hundreds of samples and nothing to clean. |
| 11-09 21:07 | Archive | The reel becomes a timestamped physical archive a lab can re-check. | Lab verification of every machine ID. |
| 11-09 21:09 | Form factor | Not inside the hive → smart bottom board under the hive. | Bees fill gaps over ~9 mm with comb and glue smaller ones with propolis; it's ~35 °C and humid inside. |
| 11-09 21:10 | Trap | Trap grid deploys by servo for a short time about hourly. | Beekeeper friend: colonies get upset when pollen is taken. bulk 1-2 day trapping may itself change foraging; long-term random single samples tied to telemetry are better data. |
| 11-09 21:18 | Compute | Self-contained on device: ESP32-S3 Plus node power-gates a Pi Zero 2 W. | Avoid streaming to a desktop; power-gating makes solar feasible (~0.5 Wh/day). |
| 11-09 21:29 | ID / optics | Borrowed microscope objective; 405 nm UV autofluorescence as the first stage of the ID tree. | Cheap prototype optics; UV separates pollen from debris and gives a coarse grouping. |
| 11-09 21:40 | Robot v1 | Singulator disc, UV pellet camera, one-press "squish and pick" onto a carrier tape + clear sample tape, sprocketed film-leader cover. | First full mechanism pass. |
| 11-09 22:18 | Scope | MVP = automated collection onto the cassette; microscope + ID built in as a later stage. | De-risk: the collector is useful on its own for home or lab microscopy. |
| 11-09 22:20 | Dating | Blank tape gap every night as a day marker. | Only the cassette's start and end dates then matter. |
| 11-09 22:51 | Research target | A university pollen lab doing DNA metabarcoding is the intended data user; no contact until it works on a hive. | Design to maximise data useful to them. |
| 11-09 22:57 | Experiment | Colony-level hypothesis + focal-bee sampling alongside random hourly pellets. | Existing studies look at single bees or random pellets; hive-level state may drive pollen mixing. |
| 11-09 23:02 | Phasing | Three research phases: robot + telemetry → tagged focal bees → observation hive with dance decoding. | Dance video needs a glass observation hive; tagging needs a camera. |
| 11-09 23:41 | Sensors / power | Extra sensors and LoRa bloom nodes added; entrance camera moved to phase 2. | All extras together cost less power than the entrance camera alone (~3 vs 12-18 Wh/day). |
| 11-09 23:51 | Site | Public, cloudy, wet-winter site: 10 W panel, winter mode, tamper-proofing. | Low winter sun; public access. |
| 11-09 23:53 | Intent | Open hardware, code and data, for science. | The goal was always science; science grants could fund building units for labs. |
| 11-10 00:01 | Connectivity | Stream results and thumbnails only; SIM/LTE-M as fallback; device dials out. | Raw focus stacks are far too big for cellular power and data budgets. |
| 11-10 01:30 | Prep + control | Grinding rejected; the machine framed as a micro-PLC problem: PLC-style sequential automation on a microcontroller. | Pellet glue is sugar: grinding smears and breaks grains. |
| 11-10 01:47 | Experiment | Crossover design for focal bees: every-4th-trip vs every-trip, order swapped per bee. | Compare each bee with herself; offset age. |
| 11-10 01:52 | Prep v2 | "Rolled print": wet pellet rolled along the tape, then squashed into a disc. | Keep the whole pellet for DNA while still getting a thin layer for imaging. |
| 11-10 01:57 | Cassette | 4-6 week cassette = one experiment run ≈ one forager cohort's life. | Matches bee lifespan; one physical + SQLite package per run. |
| 11-10 02:03 | Process control | Pellet variability handled by measure → recipe → check → log (a problem I raised). | Fresh vs stored pellets and different flowers behave differently. |
| 11-10 02:07 | Prep | Centre-cut idea → optional "split mode" with spooled stainless wire. | Pellet centre is cleaner and may show layering. |
| 11-10 02:49 | Size check | Real size estimate (unit ~15 × 12 × 6 cm), bigger than I pictured. | Schematic exaggerated size; listed shrink levers. |
| 11-10 03:24 | External review | Pasted handoff doc reviewed: index-matched mounting fluid, draw-cut, bifilar wire, pre-wet tape adopted; wrong numbers rejected. | Some upgrades were real; some numbers would snap wire or crush grains. |
| 11-10 03:39 | Prep | Cut horizontally on the tape + wire acts as a stop to drag the half; suction nozzle dropped. | the dome is pollen too, so a reused nozzle contaminates. |
| 11-10 04:47 | Prep | tape adhesive too weak to resist slicing. | Tipping moment puts the adhesive in peel. |
| 11-10 05:02 | **Robot v2** | Catch in funnel throat, horizontal skewer, vertical draw-cut, free half drops as archive, arm pivots 90° to smear. | Cutting force goes into the frame, not the tape; removes singulator, liner, pump, rolling drive. |
| 11-10 06:24 | Build order | Robot (slicing + reel + microscope) first, then all sensors at once. | Every sensor matters to the thing being studied. |
| 11-10 06:32 | Archive | Archive half stays dry; desiccant in the cassette. | Keep fluid only under the smears; prevent mould. |
| 11-10 06:51 | Model | Pretrain on regional (Pacific Northwest) plant pollen, then shrink to fit the boards. | Narrow class list keeps the model tiny. |
| 11-10 17:14 | Contamination | Throat carryover handled by PTFE surfaces + blank cycles + lab threshold. | Archive half still touches the throat walls. |
| 11-10 21:15 | Model | Train from scratch is realistic; v0 = Python features + random forest (my "presorting"). | Narrow task; data, not compute, is the limit. |
| 11-11 (approx.) | Documentation | De-identified project page and a design repo created (from vault commit history). | Prepare for open release. |

---

## 2. Idea-by-idea breakdown

Every section uses the same five headings. Ideas are grouped: **A. Where it lives and the pollen robot**, **B. Sensors**, **C. Hardware, software and data**, **D. Experiment and research**, **E. Hardware and software evolution (summaries)**.

## A. Where it lives and the pollen robot

### A1. Form factor: the smart bottom board

**Origin:** I asked (11-09 21:08) whether the whole microscope/squisher/tape rig could fit inside an active hive under the entrance.

**Versions:**
1. 11-09 21:03 – Hive-mounted sensor node plus a separate base station with better power.
2. 11-09 21:08 – Rig inside the hive, under the entrance.
3. 11-09 21:09 – **Current:** smart bottom board. Hive sits on it; bees walk over the trap grid; pellets fall through bee-proof mesh into the mechanism; load cells and entrance counter in the same base.

**Why it changed:** Bees build comb in gaps over ~9 mm and propolise smaller ones, and the inside is ~35 °C and humid. Beekeepers also need to pull frames freely.

**Status:** Kept.

**Options considered and rejected:**
- Inside the hive: would be glued up and coated within weeks.
- Separate base-station SBC for all the heavy work: replaced by the on-device plan (see C1).

---

### A2. Pollen trap (sampling grid)

**Origin:** A permanent trap takes too much colony protein, and a beekeeper friend said colonies "get upset when the pollen gets taken."

**Versions:**
1. 11-09 21:05 – Standard pollen trap knocks pellets off continuously.
2. 11-09 21:09 – Servo slides the grid in for ~10 minutes every few hours.
3. 11-09 21:10 – **Current:** servo deploys briefly about hourly. Retract after 1-3 pellets, skip low-traffic or cold hours, fail open, log every deployment.
4. 11-09 21:40 – Fail-open hardware: gravity/spring holds grid out, servo parks open on boot, supercap parks it on brownout.

**Why it changed:**
- Beekeeper feedback on colony stress, plus "only take what you need": a sample needs only a pellet or two.
- Sampling bias: typical pollen-trap studies take everything the hive brings in for a day or two, with no discretion. That can itself change what the colony forages for, and it gives only a short snapshot. Small random samples, one pellet at a time, spread over weeks and tied to the hive telemetry, should give better data.

**Status:** Kept.

**Options considered and rejected:**
- Always-on trap, or the usual "collect everything for 1-2 days": stresses the colony, may shift its foraging, wastes tape, and gives a short snapshot instead of a long record matched to telemetry.
- Deployment without logging: rejected because effort data is needed to turn catches into rates (see C4).

---

### A3. Getting one pellet into position (singulation → funnel catch)

**Origin:** My first idea: "a funnel that leads to a robotic pollen sac squisher" (11-09 21:04).

**Versions:**
1. 11-09 21:04 – Plain funnel.
2. 11-09 21:05 – Vibrating chute or seed-planter-style rotating disc with pellet pockets: a plain funnel clogs.
3. 11-09 21:40 – Singulator disc with 3.5 mm pockets carries a pellet under the pellet camera; rejects go to a tray.
4. 11-10 02:12 – PET liner tape run through the singulator pocket, advanced per sample (applying my "shoe-cover dispenser" idea).
5. 11-10 05:02 – **Current (v2):** pellet stops in the funnel **throat** (~4.5 mm) on a gate flap; a break-beam confirms it. The throat is the fixture (my "catch it at the funnel" idea).

**Why it changed:** v2 needed the pellet held mechanically for cutting; the throat already locates it, so the disc and its liner spool became unnecessary.

**Status:** Changed (disc dropped, throat kept).

**Options considered and rejected:**
- Cutting inside the falling funnel (11-10 02:11): pellet still bouncing, position unknown, wires catch debris.
- "Tape as the singulator" (drop straight onto tape, camera rejects doubles): offered as a size lever, not pursued.
- Open question: whether one throat size holds all 2-4 mm pellets centred or needs a V shape.

---

### A4. Turning a pellet into a readable sample (the core mechanism)

**Origin:** My "robotic pollen sac squisher which falls onto a microscope slide" (11-09 21:04). This idea changed more than any other.

**Versions:**
1. 11-09 21:04 – Squash the pellet onto a slide.
2. 11-09 21:05 – Tape lift (press clear tape on the pellet) or wet drop in a well; slides replaced by tape.
3. 11-09 21:40 – **v1 "squish and pick":** one press flattens the pellet on a sticky-up carrier tape while lifting a thin grain layer onto a low-tack clear sample tape; carrier keeps the bulk pellet for DNA.
4. 11-10 01:30 – Crushing/grinding + cleaning considered. Replaced by a wet disaggregation cell as an alternative to dry lift.
5. 11-10 01:45 – "Damp lift": non-contact 1-2 µL drop of water + ~20% ethanol from a syringe pump, then press.
6. 11-10 01:52 – **Rolled print**: pellet rolled forward along the tape in 20-30% ethanol/water between tape and cover film, leaving a heavy-to-light gradient; then squashed into a disc. One tape instead of two; whole pellet archived.
7. 11-10 02:01 – Try **dry** rolling first with a thin-coat, high-tack tape ("maybe we can forgo the water").
8. 11-10 02:07 – Optional **split mode** (my centre-cut idea): spooled stainless cheese-wire cut, stamp cut faces, roll one half.
9. 11-10 02:11 – Twin parallel wires cut a centre slab; one wire reeved round a pulley for two spans.
10. 11-10 03:24 – From the external handoff: index-matched PG/glycerin + alcohol clearing fluid, moving "draw-cut" wire, bifilar wire, pre-wet tape.
11. 11-10 03:30 – Suction cup picks a coverslip to drag the half cut-face-down → instead, cut horizontally **on the tape**, push the top half along cut-face-down.
12. 11-10 03:38 – wire as a "holding stop" that drags the half through a felt-tip PG/ethanol streak, then lifts. Merged: one fresh wire span cuts, stops and drags.
13. 11-10 04:54 – vertical **skewer** wire pins the top half while a horizontal wire cuts; skewer stamps smears, then is snipped into a bin.
14. 11-10 05:02 – **Current, v2 (my funnel-catch + pivot):** throat holds pellet → horizontal skewer pins one side (stops 0.5 mm short of centre) → vertical wire draw-cuts at the centre → gate opens, free half drops on **dry** tape as the archive → arm pivots 90° so the cut face is parallel to the tape → 2-3 stamp-and-drag smears on a PG/ethanol streak → arm swings over the cassette waste bin, solenoid snips clean wire, fresh wire feeds → cover film + soft pinch squash the archive half into a disc.
15. 11-10 06:32 – Archive half fully dry; fluid only under the smears with a dry border and ≥3 mm gap.

**Why it changed (problem → fix):**
- A squashed whole pellet is an opaque mat (>100,000 grains) → need a thin layer.
- Pellet glue is sugar, so grinding smears and breaks grains → dissolve or soften instead.
- Full dissolving needs ~1 mL dilution and aliquoting (a pipetting robot) → damp lift, then rolled print.
- Wanting the whole pellet for DNA → rolled print, later "archive half".
- Pellet surface carries trap dust and the last flowers visited → cut to expose the clean interior.
- Air around grains causes dark halos → index-matched fluid under the smear.
- Tape can't hold a pellet against a wire (tipping turns the grip into peel) → hold it mechanically (skewer + throat).
- Reused contact surfaces carry pollen between samples, and the outside of the pellet is pollen too → fresh wire per run.

**Status:** Changed many times; v2 is current, pending bench tests (needle-skewer hand test first).

**Options considered and rejected:**
- Dry grinding: smears the sugar binder, breaks grains, leaves residue.
- Full wet dissolve in the field: grain density forces dilution, waste liquid and a reusable mixing chamber.
- Separate carrier tape + sample tape (v1): replaced by rolled print, then by v2.
- Suction-cup glass coverslips: dome-to-smear contamination, a stack of 500-1,000 fragile slips, vacuum hardware.
- Syringe-vacuum suction arm as the pusher: nozzle touches every dome, which is pollen.
- Cut on the tape: adhesive fails in peel.
- Discarding the pellet "caps" (from the handoff): loses archive material; v2 discards only the skewered half and archives the other half plus smears.
- Hot-wire cutting: heat caramelises sugar and can damage grains and DNA.
- Shearing inside the bonded laminating nip: films can't run at different speeds once bonded.
- Wire lasso/noose (11-10 03:38): hard to form reliably; a straight span does the same job.

---

### A5. Contamination control (contact map)

**Origin:** I asked (11-10 01:30) for a cleaning mechanism to prevent cross-contamination.

**Versions:**
1. 11-10 01:30 – Design so nothing needs cleaning: single-use contact surfaces plus periodic **blank cycles** to measure carryover.
2. 11-10 02:09 – Singulator pocket flagged as a reused contact point → PTFE lining.
3. 11-10 02:12 – My "shoe-cover dispenser" principle → disposable liner tape; a contact map listing every surface that touches pollen.
4. 11-10 03:38 – Reused suction nozzle dropped (the dome is pollen).
5. 11-10 05:02 – **Current:** fresh wire per run, tape = archive, waste bin inside the cassette; funnel/throat/gate are the only reused contacts.
6. 11-10 17:14 – Throat handled by smooth PTFE surfaces, blank cycles sent to the lab, and a lab-side detection threshold. Escalation path: an advancing PTFE strip over the gate.

**Why it changed:** Each new mechanism created new contact points; DNA metabarcoding is sensitive enough to pick up a few carried-over grains.

**Status:** Kept as a design rule.

**Options considered and rejected:**
- A cleaning/rinse station: adds liquid, waste and a reused surface; blanks give a measured number instead.
- Downdraft fan to de-dust pellets (from the handoff): spreads loose grains through the whole box.

---

### A6. Tape and cassette archive

**Origin:** Tape reel instead of slides (11-09 21:05); I then made the reel a lab-verifiable timeline archive (11-09 21:07).

**Versions:**
1. 11-09 21:06 – Cassette-sized reel, 12 mm tape, ~5 mm per sample, ~2,000 samples per 10 m, cover film laminated on.
2. 11-09 21:11 – Tape options: office crystal-clear tape → forensic lifting tape → PET + home-made adhesive (the airborne pollen-trap recipe).
3. 11-09 21:40 – One swappable cassette holding all consumables, with desiccant and a QR ID; 16 mm clear film leader as sprocketed cover film.
4. 11-09 22:24 – 3-month cassette (~10 m, ~52 mm spools) recommended.
5. 11-10 01:57 – **4-6 week cassette = one experiment run**; ships with a SQLite export keyed by cassette ID + frame.
6. 11-10 02:12 – One shell, several spools (tape, cover film, cutter wire, liner); VHS-style guide posts.
7. 11-10 05:02 – **Current (v2):** sample tape, cover film, archive take-up, cut wire supply + used spool, skewer wire, felt-tip PG/ethanol cartridge, waste bin, desiccant, QR run ID. ~23 mm (3 sprocket frames) per sample.
8. 11-10 06:32 – Desiccant + humidity indicator card behind a window (my desiccant idea).

**Why it changed:** Frames per sample grew (1 → 2 → 3) as the prep changed, so capacity shrank; the experiment design then set the run length (one cohort's foraging life).

**Status:** Kept; length and contents changed.

**Options considered and rejected:**
- Glass slides: fiddly for a robot.
- Full-season (6-month) cassette: big spools; a damaged cassette loses the whole season; lab gets samples late.
- Matte tape, rubber-adhesive tape, packing/masking/duct tape, Kapton, tinted tape: fail on clarity, ageing, fluorescence or creep.
- Separate cartridges per consumable: easier to design, but run out at different times and get mismatched.

---

### A7. Dating and indexing the tape

**Origin:** Traceable frames (11-09 21:07), then my nightly blank gap (11-09 22:19).

**Versions:**
1. 11-09 21:06 – Printed index dots + IR sensor, or sprocketed tape.
2. 11-09 21:07 – Cassette ID + frame number on every SQLite row; optional printed code per frame.
3. 11-09 22:19 – Blank gap each night so only start/end date matter.
4. 11-09 22:20 – **Current:** 3 blank frames every night (even with no samples), 6 on Sundays as a weekly checksum; the ESP32 log stays the precise record.

**Why it changed:** A short gap could be confused with an empty frame (rain, rejected pellet); a missed gap could silently shift every later date.

**Status:** Kept.

**Options considered and rejected:** Gaps only on sampling days (gap count would stop matching day count).

---

### A8. Microscope and optics

**Origin:** The original plan used my USB microscope; cheap "1000x" USB scopes turned out to be too weak (11-09 21:05).

**Versions:**
1. 11-09 21:04 – USB microscope (my starting idea).
2. 11-09 21:05 – OpenFlexure-style open-source microscope.
3. 11-09 21:26 – ~1 µm resolution target: 20x/0.4 objective + lensless Pi camera; budget option = reversed Pi camera lens; flexure focus + focus stacking; tape motion replaces the XY stage.
4. 11-09 21:28 – Borrow an objective from my desktop microscope; 160 mm objective + ~150 mm printed tube for the bench.
5. 11-09 21:40 – Folded flat with a 45° mirror to fit the base; 28BYJ-48 + M3 screw flexure Z; 10-15 slice stacks; permanent yellow long-pass filter.
6. 11-09 22:18 – Staged: Phase 2 desktop cassette reader first, then docked into the hive unit.
7. 11-10 03:24 – ~0.17 mm COC cover film to match #1.5 coverslip optics; ≥120 µm compliant optical gap so large grains aren't crushed.
8. 11-10 06:24 – **Current:** microscope is part of the first build (with slicing and reel), per my build order.

**Why it changed:** Resolution needs (NA ~0.4), box height, and the cover-film thickness the objective expects.

**Status:** Kept; build order moved it earlier.

**Options considered and rejected:**
- USB "1000x" microscopes: ~50-200x real magnification, not enough to separate grains.
- 40x objective for the prototype: suffers more from cover-thickness mismatch than 20x.
- Motorised XY stage: unnecessary because the tape moves.
- 30-50 µm optical gap (from the handoff): crushes grains of 100 µm or more.

---

### A9. UV autofluorescence (405 nm)

**Origin:** Started as an optional extra channel (11-09 21:26); I made it the **first stage of the ID tree** (11-09 21:28).

**Versions:**
1. 11-09 21:26 – Optional 405 nm LED + long-pass filter.
2. 11-09 21:28 – Pollen-or-not gate + coarse grouping.
3. 11-09 21:40 – Also on the pellet camera (white + 405 nm through yellow gel) as a prefilter before the microscope.
4. 11-09 21:39 – UV frame used to find grain masks (segmentation), not just to gate.
5. 11-10 21:20 – **Current:** UV colour ratios computed in Python and fed to the feature model or as CNN input channels.

**Why it changed:** Using UV for segmentation gets grain masks "almost for free"; a published 2025 study identified pellet floral origin from autofluorescence, backing the idea.

**Status:** Kept.

**Options considered and rejected:**
- 365 nm LED: ordinary objective glass passes 405 nm much better.
- UV/fluorescent dye to mark focal bees (11-09 22:57): would rub onto pellets and confuse the 405 nm stage.

---

## B. Sensors

### B1. Hive scale (weight)

**Origin:** The best proxy for "approximate hive size" from my original brief (11-09 21:03).

**Versions:**
1. 11-09 21:03 – Load cells + HX711 under the hive.
2. 11-09 21:09 – Built into the smart bottom board.
3. 11-09 21:40 – **Current:** separate scale frame under the base, 4 × 50 kg load cells, ant-moat feet, base tared out.
4. 11-09 23:47 – "Ideal" version: NAU7802/ADS1232 ADC + load-cell temperature logging for drift compensation.

**Why it changed:** Weighing only the hive (not the base) and handling temperature drift, the classic hive-scale problem.

**Status:** Kept. Installed in the "all sensors at once" stage.

**Options considered and rejected:** Counting bees as the size measure: weight also shows nectar flow, stores and swarms.

### B2. Temperature and humidity

**Origin:** My original brief.

**Versions:**
1. 11-09 21:03 – SHT45 inside the brood area + one outside; DS18B20 row across frames to map the winter cluster.
2. 11-09 21:40 – Outdoor SHT45 in a small shield under the base.
3. 11-10 02:01 – **Current:** also log drawer humidity per sample, because pellet stickiness varies with humidity.

**Why it changed:** The pellet-variability problem (A4) made humidity a process variable, not just colony data.

**Status:** Kept.

**Options considered and rejected:** None recorded.

### B3. Sound and vibration

**Origin:** My original brief (sound).

**Versions:**
1. 11-09 21:03 – INMP441 I2S mic, FFT on the ESP32, log band energies not raw audio.
2. 11-09 21:39 – Swarm/queenless classifier later, once labelled events exist from inspection notes.
3. 11-09 23:02 – Mic or frame accelerometer as a possible **dance-activity proxy** (follows from the experiment, D2).
4. 11-09 23:34 – **Current:** extra 200-500 Hz band energies from mic + piezo disc on a frame; treated as an experiment.

**Why it changed:** The colony-communication hypothesis (D2) needed a cheap dance signal in a normal hive.

**Status:** Kept; dance proxy is experimental.

**Options considered and rejected:** Raw audio storage (size and power).

### B4. Forager counting (entrance traffic)

**Origin:** My original brief ("in/out volume").

**Versions:**
1. 11-09 21:03 – IR break-beam gates (proven, low power) vs a camera with a tiny model.
2. 11-09 23:36 – Entrance camera proposed instead (counts traffic, spots pollen carriers, drones, wasps; reads tags).
3. 11-09 23:41 – **Current:** break-beams in the first sensor stage; entrance camera arrives with the tagged-forager stage.

**Why it changed:** The camera costs 12-18 Wh/day vs ~0.8 Wh/day for the gates, so it waits until the experiment needs it for tags.

**Status:** Changed (staged).

**Options considered and rejected:** Camera from day one: forces a 30-40 W panel and ~100 Wh battery early.

### B5. Additional sensors (varroa, weather, lid, CO₂, VOC)

**Origin:** I asked (11-09 23:36) what other telemetry sensors could be used.

**Versions:**
1. 11-09 23:36 – Proposed: varroa sticky-board camera, wind/rain/light/pressure, lid reed switch, CO₂ (SCD41), frame accelerometer, VOC (BME688).
2. 11-09 23:41 – Power check: all together ~0.5 Wh/day; varroa camera on the pollen Pi via a camera multiplexer.
3. 11-10 06:24 – **Current:** no longer "extras". All sensors go in together after the robot works, because each one matters to what's studied.

**Why it changed:** I reframed the sensors as part of the experiment (pollen only means something next to colony state, weather and bloom).

**Status:** Kept, promoted from optional to core.

**Options considered and rejected:** None; GPIO limits on the hive node noted (I/O expander or move weather to the motion ESP32).

### B6. Bloom monitoring (LoRa camera nodes)

**Origin:** A daily phenocam photo (11-09 23:36), then my LoRa/Meshtastic camera nodes (11-09 23:38).

**Versions:**
1. 11-09 23:36 – One landscape "phenocam" photo a day.
2. 11-09 23:38 – Camera node per forage patch; send a ~20-byte bloom index over LoRa, keep photos on SD.
3. 11-09 23:41 – **Current:** ESP32-S3 Sense + SX1262 + small solar + 18650; fixed exposure/white balance + colour card; hive node listens at scheduled times.
4. 11-10 21:20 – Bloom timing also used as a prior in the pollen classifier (see C3).

**Why it changed:** LoRa can't carry photos; bloom data turned out to help ID as well as the "availability vs choice" question.

**Status:** Kept.

**Options considered and rejected:**
- Sending photos over Meshtastic: ~200-byte packets, clogs the mesh.
- A commercial orchard bloom-tracking service (11-09 23:43): tractor-mounted, paid, no public model, trained on fruit-tree rows.

---

## C. Hardware, software and data

### C1. Compute and boards

**Origin:** I wanted it self-contained on the device rather than streamed to a desktop (11-09 21:18).

**Versions:**
1. 11-09 21:03 – ESP32-S3 hive node + base-station SBC (Pi 5 class).
2. 11-09 21:18 – **XIAO ESP32-S3 Plus** as always-on hive node; **Pi Zero 2 W** power-gated per sample.
3. 11-09 21:23 – Second ESP32-S3 as motion controller (servos, steppers, LEDs) over UART, using hardware I already own.
4. 11-09 23:34 – Tag reading (phase 2): second Pi Zero 2 W + global-shutter camera. Dance decoding (phase 3): Pi 5 or a used mini PC, cheaper than an Orange Pi 5.
5. 11-09 23:44 – My original Jetson Nano → phase 3 dance decoding and bench work (mains power), not the solar unit.
6. 11-09 23:47 – "Ideal" non-prototype: custom PCB (ESP32-S3 + RP2350 motion coprocessor), CM4 with eMMC, Pi HQ + global-shutter cameras, MPPT + LiFePO4.
7. **Current:** prototype = 2 × ESP32-S3 (Plus) + Pi Zero 2 W in the hive; Jetson Nano on the bench and for phase 3.

**Why it changed:** Power (an SBC can't idle on solar), use of owned hardware, and new research phases adding vision jobs.

**Status:** Kept for prototype; ideal version parked.

**Options considered and rejected:**
- ESP32-P4 for microscope vision: stronger but young tooling, still a stretch.
- Jetson Nano in the hive: 2-3 Wh/day power-gated and runs warm; only if the Zero is too slow.
- Porting the Nano to modern JetPack: JetPack 5/6 doesn't support it; mainline kernels lose CUDA.
- Pi 4, RK3566 NPU boards, Coral for phase 3: slower, weak CPU, or ageing toolchain.
- Handoff doc's board roles (S3 Plus as lighting controller): conflicts with its always-on hive-node role.

### C2. Machine control (PLC-style firmware)

**Origin:** My note (11-10 01:30): "I think I'm leaning into PLC thinking here." A real PLC was never the plan: "PLC" was my way of linking the two ideas. The machine is a micro-PLC problem: a fixed sequence of steps, permissives and interlocks, run on a microcontroller.

**Versions:**
1. 11-09 21:40 – Motion ESP32 with TMC2209 drivers, commanded by the Pi over UART.
2. 11-10 01:30 – Framed as fixed sequential automation, not a robot: scan loop, step sequence, permissives, interlocks, timeouts, FAULT = grid open.
3. 11-10 01:33 – **Current:** real firmware in C++ structured like a PLC program; the same sequence in OpenPLC (ladder) on a spare ESP32-S3 as a side lab.

**Why it changed:** It didn't change direction so much as get a name. Seeing the mechanism as a micro-PLC problem gave it a proven structure (scan loop, step sequence, interlocks, fault state) while keeping the microcontroller's deep sleep, radio and motion control. For the record, an industrial 24 V PLC would idle at several watts, and ladder logic alone can't do deep sleep, Wi-Fi, FFT or easy stepper pulses.

**Status:** Kept.

**Options considered and rejected:** All-OpenPLC firmware (loses sleep, radio and motion); kept OpenPLC only as a side lab. (An industrial PLC was never on the table; see Origin.)

### C3. Pollen identification model (software)

**Origin:** My original brief: "a local super light pollen ID AI."

**Versions:**
1. 11-09 21:03 – Pellet colour sorting first, grain-level ID later; public datasets.
2. 11-09 21:24 – Two tiny models: pollen-vs-debris gate, then a MobileNetV3-Small int8 classifier on the Zero; local plants only; own tape reference set; "unknown" flags frames for the lab (I asked for "only pollen, super tiny").
3. 11-09 21:39 – Single classifier with UV channels; model version on every row; desktop retraining loop.
4. 11-10 06:51 – Pretrain on regional (Pacific Northwest) plant pollen, then shrink as far as possible. Plan: desktop teacher → distil to student → smaller crops → prune → int8 QAT; optional ESP32-S3 pollen gate to decide whether to wake the Pi.
5. 11-10 21:15 – Train from scratch is realistic. **Current path:** v0 Python hand-made features (size, shape, pores, texture, UV colour) + random forest (my "presorting") → v1 small CNN from scratch → v2 hybrid.
6. 11-10 21:20 – **Current:** UV and bloom-timing prior both in Python on the Pi; look-alike groups reported as "types" (e.g. Rubus type, fruit-tree Rosaceae, dandelion type).

**Why it changed:** My preference for squeezing models onto weak hardware; light-microscope physics (~1 µm resolution) can't split some close relatives; published reference slides are chemically treated and look unlike fresh pellets.

**Status:** Kept and refined.

**Options considered and rejected:**
- Big detector on full frames: too heavy for the Zero 2 W; crop-then-classify instead.
- Training only on public atlas slides: domain mismatch with fresh tape grains.
- Expecting species-level ID everywhere: some sister species overlap at this resolution; DNA testing of archived samples covers those.

### C4. Data storage and export (SQLite)

**Origin:** My original brief: log into SQLite and graph over time.

**Versions:**
1. 11-09 21:03 – SQLite + graphs on a base station.
2. 11-09 21:07 – Cassette ID + frame on every row; low-confidence frames flagged; lab labels fed back as training data.
3. 11-09 21:39 – SQLite master copy on the Pi; ESP buffers telemetry in flash; desktop syncs for real graphs (Grafana/Datasette); field "wake button" hotspot chart page.
4. 11-09 22:53 – Research data spec for a pollen lab: per-pellet mixed-taxa shares, sampling-effort log per trap window, context, raw focus stacks, UTC, CSV/Parquet export, `bee_id` hook.
5. 11-10 01:57 – **Current:** each cassette ships with a SQLite export (telemetry, focal-bee trips, per-pellet rows); new tables for weather, inspections, varroa, gas and bloom; per-frame recipe, hardness, humidity and quality.

**Why it changed:** The data user shifted from "us and a dashboard" to "a lab re-analysing it."

**Status:** Kept and expanded.

**Options considered and rejected:** Storing only model labels (not re-analysable).

### C5. Connectivity

**Origin:** My note (11-10 00:01): "Could I use a SIM card and just stream it to my PC?"

**Versions:**
1. 11-09 21:03 – Wi-Fi or LoRa to a base station.
2. 11-09 21:39 – Walk-up sync or LoRa if no Wi-Fi.
3. 11-10 00:01 – **Current:** send results and small thumbnails only; Wi-Fi if available, LTE-M SIM as fallback; device connects out over WireGuard/Tailscale; full stacks collected in bulk.

**Why it changed:** Focus stacks (10-25 MB each) would cost 5-10 GB/month and more power than the whole unit.

**Status:** Kept.

**Options considered and rejected:** Streaming raw images; exposing the device to inbound connections.

### C6. Power

**Origin:** My original brief: solar powered.

**Versions:**
1. 11-09 21:18 – ESP32 power-gates the Pi (~0.5 Wh/day for imaging).
2. 11-09 21:40 – Budget ~2.5 Wh/day; 2 × 18650; charger with cold-charge cutoff; 6 W panel on its own stake.
3. 11-09 23:41 – Entrance camera needs 30-40 W + ~100 Wh LiFePO4 → separate battery box later.
4. 11-09 23:51 – **Current:** 10 W panel; winter mode Nov-Feb (~0.5 Wh/day); entrance camera seasonal only.

**Why it changed:** Very low winter sun at the site; experiment phases add big loads.

**Status:** Kept.

**Options considered and rejected:** Panel on the hive lid (lifted at every inspection); sealed lead-acid (heavy, sulphates over winter).

### C7. Enclosure

**Origin:** Followed from the bottom-board decision (11-09 21:40).

**Versions:**
1. 11-09 21:09 – Sealed electronics/optics compartment with desiccant.
2. 11-09 21:40 – **Current:** three zones (bee zone in wood/ASA/PETG; gasketed mechanism zone with lens heater; IP65 electronics drawer sliding out the back); cassette also slides out the back.
3. 11-09 23:51 – Tamper-proofing for a public site (security screws, cable lock, panel high on post).
4. 11-10 02:49 – Size estimate ~15 × 12 × 6 cm pollen unit; I expected smaller.

**Why it changed:** Public site; condensation is the top risk.

**Status:** Kept; hive type and stand height still unknown.

**Options considered and rejected:** PLA (sags in summer heat); printed electronics box (a bought IP65 box is more reliable).

---

## D. Experiment and research design

### D1. Who the data is for

**Origin:** A beekeeper friend described pollen-preference studies; I later picked a specific university lab doing pollen DNA metabarcoding.

**Versions:**
1. 11-09 21:02 – A beekeeper friend's description of pollen-preference studies; first audience is the friend and their hives.
2. 11-09 22:51 – A specific university lab (floral fidelity, fee-for-service metabarcoding), reachable through the beekeeper friend.
3. 11-09 22:52 – **Current:** no contact until it works on a hive; design to maximise data useful to them.

**Why it changed:** I want something working to show first.

**Status:** Kept.

**Options considered and rejected:** Other regional labs (scent/vision, native bees, pollen nutrition) judged less directly matched.

### D2. The research question

**Origin:** My note (11-09 22:57): "maybe there's a link between pollen mixing and hive telemetry that they're missing by measuring singular bees."

**Versions:**
1. 11-09 21:02 – Original: which plants hives prefer and when, against telemetry and season.
2. 11-09 22:31 – Bee age/size per pellet: do novice or veteran foragers mix more?
3. 11-09 22:57 – **Current:** is single-flower vs mixed foraging an individual choice or a collective colony decision (brood, dearth, dances)?

**Why it changed:** Size is uniform in honey bees and every forager is 2-3+ weeks old, so age became novice vs veteran; I then widened it to colony-level control.

**Status:** Kept.

**Options considered and rejected:** Bee size as a variable (honey bee workers are very uniform).

### D3. Focal-bee sampling and the crossover experiment

**Origin:** I proposed (11-09 22:57) marking one bee and taking its pollen every entry, with hourly random samples as the colony baseline.

**Versions:**
1. 11-09 22:57 – One UV-dye-marked bee, pollen taken every entry; tape gaps mark its samples.
2. 11-09 22:57 – Printed tags instead of dye; one-bee lane trap; strip every 3rd-4th trip, photograph every trip; 3-5 bees.
3. 11-09 23:01 – ~5 tagged focal bees + random hourly pellets + hive telemetry.
4. 11-10 01:43 – I asked how often to strip, whether bees eat or are shunned for missing loads → ~10 trips/day, no shunning, colony-level pollen regulation; sample every 4th trip.
5. 11-10 01:47 – **Crossover:** one bee every-4th → every-trip, another the reverse, switching on the same day to offset age.
6. 11-10 01:47 – **Current:** ≥3 bees per order, same-age cohort, 3-4 day periods, 1-2 day washout, never-stripped control bees, every trip observed in all conditions; its own campaign cassette.
7. 11-10 06:29 – Restated for the public summary: every entry vs every 4th, roles swapped, control, whole-hive random samples compared to telemetry.

**Why it changed:** n=2 is an anecdote; carryover between periods; foragers live 1-3 weeks; observation must stay constant so only removal differs.

**Status:** Kept.

**Options considered and rejected:**
- UV dye as the trigger mark: contaminates pellets and the UV stage.
- One focal bee: sample of one.
- Stripping every trip as the only condition: may change the behaviour being measured.
- Parallel-groups design: needs many more bees to beat individual variation.

### D4. Marking bees

**Origin:** I asked whether tagging could be automatic (11-09 22:43), e.g. a paint tag during pollen collection.

**Versions:**
1. 11-09 22:43 – Automatic paint/powder marking at the trap.
2. 11-09 22:44 – Powder group-marking is possible but grooms off and contaminates pellets; precise automatic paint dots are an unsolved robotics problem.
3. 11-09 22:58 – **Current:** hand-tag newly emerged bees with printed tags; the device only **reads** tags.

**Why it changed:** Safety for bees and contamination of samples.

**Status:** Automatic tagging dropped; manual tagging kept.

**Options considered and rejected:** Recognising unmarked bees by appearance (unreliable across days).

### D5. Observation hive and dance decoding

**Origin:** My note (11-09 23:01): store video before sampling to see if dances precede single-flower or mixed trips.

**Versions:**
1. 11-09 23:01 – 30 minutes of video before each sample.
2. 11-09 23:02 – **Current:** separate glass observation hive with IR light; decode dances live, store dance records not video.
3. 11-09 23:44 – Runs on the Jetson Nano (mains power).

**Why it changed:** Dances can't be seen inside a normal hive; video volume.

**Status:** Parked as phase 3.

**Options considered and rejected:** Saving raw video buffers.

### D6. Sample handling for lab validation

**Origin:** Follows from my lab-archive idea (11-09 21:07, 22:53).

**Versions:**
1. 11-09 21:07 – Lab checks flagged frames; labels feed back into training.
2. 11-09 22:53 – DNA-ready archive, blanks, mixed-taxa shares.
3. 11-10 02:03 – Transfer-bias study: lab fully dissolves archived discs on a subset to get per-type correction factors.
4. 11-10 17:14 – **Current:** blank cycles sent to the lab set the contamination threshold.

**Why it changed:** Lab trust needs measured error, not promises.

**Status:** Kept.

**Options considered and rejected:** None recorded.

### D7. Pellet variability (process control)

**Origin:** My note (11-10 02:03): fresh pellets, different flowers and seasons will behave differently from stored or dropped pellets.

**Versions:**
1. 11-10 02:03 – **Current:** bench tests bracket the range; spring commissioning with fresh pellets; feedforward (humidity, size, colour, squish-hardness from stepper steps); 2-3 recipes; closed-loop quality check; log everything per frame.
2. 11-10 21:13 – Bench stock: rehydrate dry pellets in a ~75% RH salt box; frozen pellets preferred.

**Why it changed:** A new issue I raised; handled like engine fuel trims.

**Status:** Kept.

**Options considered and rejected:** Chilling/pre-drying pellets (handoff): Peltier power too high for solar.

### D8. Build order and phases

**Origin:** My scope note (11-09 22:18) and build order (11-10 06:24).

**Versions:**
1. 11-09 22:18 – P1 collector + cassette → P1.5 pellet camera → P2 desktop microscope reader → P3 optics docked in the hive.
2. 11-09 23:02 – Research phases: robot + telemetry → tagged foragers → observation hive.
3. 11-10 06:24 – **Current:** working pollen robot (slicing + reel archive + microscope) first → then all sensors at once → tagged foragers → observation hive.

**Why it changed:** Sensors aren't optional extras; the robot is the hardest, most novel part.

**Status:** Kept. (The older phase list may still appear in some private notes.)

**Options considered and rejected:** Telemetry first with the robot as an add-on (original framing).

### D9. Openness

**Origin:** My note (11-09 23:53): "I'd be doing it for science."

**Versions:**
1. 11-09 23:53 – **Current:** open hardware, code and data; build units at cost for labs, ideally funded by science grants; methods paper with a partner.
2. 11-11 (approx.) – De-identified public page and a design repo set up (from vault commit history).

**Why:** My motivation from the start is science, not money. Open release also avoids ownership questions with a university partner.

**Status:** Kept.

**Options considered and rejected:** None; it was open from the start.

---

## E. Hardware and software evolution (summaries)

### E1. Hardware evolution

| Stage | Hardware picture | Driver |
|---|---|---|
| 11-09 21:03 | ESP32-S3 node on hive + base-station SBC | Starting idea |
| 11-09 21:23 | S3 Plus node + S3 motion controller + power-gated Zero 2 W, all on the hive | Self-contained, owned hardware, solar |
| 11-09 21:40 | v1 robot: 2 servos, 3 steppers, vibration motor; singulator, press, carrier tape | First mechanism |
| 11-10 01:45 | + syringe pump for damp lift | Wet prep |
| 11-10 02:12 | + cutter wire spool, liner spool; 4-spool cassette | Split mode, contamination |
| 11-10 05:02 | v2: ~10 small actuators (grid servo, vibration, gate, cut arm + wire feed, skewer pivot + feed, snip solenoid, felt-tip servo, capstan, focus) | Hold pellet mechanically |
| 11-09 23:41 | Phase 2: + entrance global-shutter camera, 30-40 W panel, separate battery box | Tag reading |
| 11-09 23:44 | Phase 3: Jetson Nano on mains | Dance decoding |
| Parked | Custom PCB with RP2350, CM4 eMMC, MPPT + LiFePO4 | Field reliability |

**Removed by v2:** singulator disc, liner spool, syringe pump, differential rolling drive, twin-wire bridge.

### E2. Software evolution

| Stage | Software picture | Driver |
|---|---|---|
| 11-09 21:24 | Two tiny CNNs (gate + classifier) | "Only pollen, super tiny" |
| 11-09 21:39 | OpenCV crop + one int8 MobileNet with UV channels; model version per row; desktop retrain loop | Simpler to maintain |
| 11-10 01:30 | PLC-style C++ firmware (scan loop, step sequence, interlocks); OpenPLC side lab | Sequential machine |
| 11-10 02:03 | Recipe table + closed-loop quality check, logged per frame | Pellet variability |
| 11-10 06:51 | Teacher → distilled student → int8; optional ESP32 pollen gate | Pretrain-then-shrink |
| 11-10 21:15 | v0 Python features + random forest → v1 CNN from scratch → v2 hybrid; Bayesian bloom prior | Train it myself, explainable |

### E3. How the experiment drove hardware and software

| Experiment change | Hardware / software consequence |
|---|---|
| Whole pellet must stay DNA-ready (D1, D6) | Archive half on dry tape; single-use contact surfaces; desiccant; blanks (A4, A5, A6) |
| Lab must date every sample without software (D6) | Nightly blank gap + Sunday checksum (A7) |
| Focal bees need tag reading (D3) | Entrance global-shutter camera, second Zero 2 W, 30-40 W solar + battery box (B4, C1, C6) |
| One-bee lane, sample every 4th trip (D3) | Second lane servo fired by the motion ESP32 (C1) |
| Cohort lifespan 1-3 weeks of foraging (D3) | 4-6 week cassette = one run; tag ~3 weeks before loading (A6) |
| Every-trip stripping uses ~4× frames (D3) | Separate campaign cassette (A6) |
| Colony-level hypothesis (D2) | All sensors become core; dance-band vibration logging (B3, B5) |
| "Availability vs choice" (D2) | LoRa bloom nodes; bloom prior in the classifier (B6, C3) |
| Sampling effort needed for rates (C4) | Log every grid deployment, window and skip reason (A2) |
| Dance decoding (D5) | Observation hive + Jetson Nano (C1) |

---

## 3. Dead ends and lessons

| Idea that didn't survive | Why it died | Lesson |
|---|---|---|
| Rig inside the hive | Bees comb over and propolise everything | Check the biology of the environment before the mechanism. |
| Glass slides | Hard to handle robotically | Consumables on a reel beat discrete parts for automation. |
| Cheap USB "1000x" microscope | Real magnification far below label | Size optics from required resolution (NA), not marketing. |
| Always-on trap | Stresses the colony | The subject's welfare is a design constraint, and a data-quality one. |
| Dry grinding the pellet | Sugar binder smears, grains break | Pick a separation method by what holds the material together. |
| Full wet dissolve in the field | Grain density forces dilution → pipetting robot | Run the numbers (grain counts, volumes) before committing. |
| Carrier tape + sample tape press (v1) | Replaced by simpler single-tape ideas | Fewer webs, fewer failure points. |
| Syringe-pump damp lift | Removed by v2 (dry archive, felt-tip streak) | Passive dispensing beats active pumps when volumes are tiny. |
| Rolled print | Superseded by cutting to reach the clean interior | A cleaner sample can be worth an extra cut. |
| Twin-wire / reeved loop / 0.6 mm bridge | Dirty wire reaches the second span; pellet won't balance | Trace every consumable's path for re-use. |
| Suction cup + glass coverslips | Dome-to-smear contamination; fragile magazine | Draw the contact map; anything touching the outside can't touch the clean part. |
| Reused suction nozzle | The dome is pollen too | "Outside surface" is still sample material. |
| Cutting on the tape | Adhesive fails in peel when the pellet tips | Check moments, not just forces; route loads into the frame. |
| Hot-wire cutter | Caramelises sugar, may harm DNA | Process heat is a sample-integrity question. |
| Wet fluid under the archive half | Weakens grip; weeps on the spool | Keep wet and dry zones separate, with a gasket border. |
| Handoff's 15-30 N wire tension, 30-50 µm gap, 15T/17T gears | Snaps wire, crushes grains, runs film the wrong way | Re-calculate confident-looking documents. |
| UV dye to mark focal bees | Contaminates pellets and the UV stage | A marker must not interfere with the measurement. |
| Automatic paint/powder tagging | Unsafe for bees; grooms off | Automate the reading, not the handling of live animals. |
| Streaming images over SIM | Data and power cost | Send results, keep raw data local. |
| Commercial bloom-tracking service | Closed, wrong crop, expensive | Own simple index first, own model later. |
| Upgrading the Jetson Nano's JetPack | Not supported; loses CUDA | Check vendor support limits before planning around old hardware. |

---

## 4. Key decisions

Each line can become its own decision record later.

- **D1** – 11-09: Mount everything in a smart bottom board under the hive, never inside it.
- **D2** – 11-09: Trap grid servo-deployed briefly about hourly, fail-open, every deployment logged.
- **D3** – 11-09: Clear tape reel in a swappable cassette instead of glass slides; the reel is the lab archive.
- **D4** – 11-09: Frame traceability via sprocket frame count + cassette ID; nightly 3-frame blank gap, 6 on Sundays.
- **D5** – 11-09: Self-contained on-device compute: ESP32-S3 Plus hive node power-gates a Pi Zero 2 W; desktop only for training and re-analysis.
- **D6** – 11-09: Separate ESP32-S3 motion controller over UART.
- **D7** – 11-09: 405 nm autofluorescence as the first stage of the ID pipeline (gate, segmentation, coarse grouping).
- **D8** – 11-09: Microscope from a 20x/0.4 RMS objective + lensless Pi camera, flexure focus, focus stacking, tape as the X axis.
- **D9** – 11-09: Staged scope: collection + cassette is a useful MVP on its own.
- **D10** – 11-09: Open hardware, code and data, for science; grant-funded builds for labs.
- **D11** – 11-09: Entrance camera deferred to the tagged-forager phase; break-beams first.
- **D12** – 11-09: 10 W panel on its own post, cold-charge cutoff, winter telemetry-only mode Nov-Feb.
- **D13** – 11-10: Uplink sends results and thumbnails only; Wi-Fi first, LTE-M fallback; device dials out.
- **D14** – 11-10: Firmware written PLC-style in C++ (scan loop, step sequence, interlocks, timeouts, FAULT = grid open).
- **D15** – 11-10: Every pollen-contact surface single-use where possible; blank cycles measure the rest.
- **D16** – 11-10: 4-6 week cassette = one experiment run, shipped with a SQLite export keyed by cassette + frame.
- **D17** – 11-10: Pollen robot v2: throat catch, skewer, centre draw-cut, archive half dropped, 90° pivot, 2-3 smears.
- **D18** – 11-10: Archive half stays dry; PG/ethanol only under smears, sealed by a dry border; desiccant in the cassette.
- **D19** – 11-10: Index-matched PG/glycerin + ethanol clearing fluid for smears (pending swelling and seal tests).
- **D20** – 11-10: Build order: pollen robot (slicing, reel, microscope) → all sensors → tagged foragers → observation hive.
- **D21** – 11-10: All sensors are core to the study, not extras.
- **D22** – 11-10: Focal-bee crossover design with washout, ≥3 bees per order, never-stripped controls, every trip observed.
- **D23** – 11-09: Bees tagged by hand; the device only reads tags.
- **D24** – 11-10: Pellet variability handled by feedforward logging + recipe table + quality check, all logged per frame.
- **D25** – 11-10: ID model: regional reference set on own optics; v0 features + random forest → small CNN from scratch → hybrid; int8; "type" labels for look-alikes; UV + bloom prior in Python.
- **D26** – 11-10: Model version, UTC timestamps and raw focus stacks kept for re-analysis; CSV/Parquet export.
- **D27** – 11-09: No contact with the intended research lab until the device works on a real hive.

---

## 5. Open questions

**Bench tests that decide the design**
1. Needle-skewer hand test: does ~1 mm of skewer hold through a thread cut? Is the hole visible on the cut face?
2. Throat fit: one size for 2-4 mm pellets, or a V shape?
3. Smear quality at 400x: PG/ethanol streak vs dry tape. Halos? Length of single layer?
4. Clearing fluid: grain swelling at day 0, 7, 30; dry-border seal on a wound spool.
5. Blanks: how much carries over through the funnel and throat? Is a disposable gate strip needed?
6. Sample tape choice: crystal-clear office tape vs forensic lifting tape (clarity, blushing, UV glow, creep).
7. Cut wire: 35 vs 38 AWG, tension, stationary vs moving.
8. Does pellet quality track humidity enough to need a damp step or recipes?

**Hardware and site**
- Hive type (8 or 10 frame?) and stand height, which set the footprint.
- Wi-Fi availability at the apiary; landowner approval for on-site hardware.
- Real deep-sleep and Pi boot currents to confirm the power budget.
- Is the Pi Zero 2 W fast enough on real images, or does the hive unit need more compute?
- Which Pi camera versions are on hand (affects Jetson Nano use).
- Real pellet size distribution (measure ~50 against a ruler).

**Science**
- Which local plants actually separate with UV + shape, and which stay "type" level?
- Transfer bias between powdery and oily pollen types: what correction factors?
- Does being stripped more often change where a bee forages?
- Does the 200-500 Hz band track dance activity at all?
- What data format and fields does the target lab actually want (to be asked once it works)?
