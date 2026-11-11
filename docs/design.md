# Design

Status: design phase. Numbers are targets, not measurements.

## Where it lives

- **Not inside the hive.** Bees build comb in any gap over about 9 mm, propolise anything smaller, and it's 35 °C and humid in there.
- **A smart bottom board under the hive.** Bees walk in over the trap grid; pellets fall through bee-proof mesh into the mechanism.
- **Three zones:**
  1. a bee zone at the front (wood, ASA or PETG; no PLA),
  2. a sealed mechanism zone (gasket, silica gel, lens heater),
  3. an off-the-shelf IP65 electronics box that slides out the back like a drawer. The cassette slides out the back too.
- **Tamper-proofing** for hives in public places: security screws, cable lock, panel high on its post.
- Condensation is the biggest risk.

## Telemetry

| Signal | Sensor | Why |
|---|---|---|
| Weight | 4 load cells + HX711 on a separate scale frame with ant moats | Best proxy for colony size, nectar flow and swarms |
| Temperature and humidity | SHT45 in the brood box and one outside | Brood health, ventilation |
| Winter cluster | DS18B20 row across the frames | Maps where the cluster sits |
| Sound | INMP441 I2S mic, FFT on the ESP32 | Logs band energies, not raw audio; 200-500 Hz dance-vibration experiment. Swarm and queenless classifier later, once labelled events exist |
| Traffic | IR break-beam tunnels (phase 1), entrance camera (phase 2) | Foraging effort |

Extras later: LoRa bloom camera nodes at forage patches (send a bloom index, not photos), varroa sticky-board
camera, weather (wind, rain, light, pressure), lid and inspection switch, CO₂ (SCD41), frame vibration.

## Pollen trap: be kind to the bees

- Colonies get upset when pollen is taken, so the grid is **servo-deployed only briefly, about hourly**.
- Retract once a pellet lands; skip runs when few bees are flying; log every deployment.
- **Fail open:** gravity or a spring holds the grid out, the servo parks it open on boot, and a supercap parks it on brownout.

## Pollen robot: catch, skewer, slice, swing, smear

Tape adhesive can't hold a pellet against a cutting wire (it tips and peels), so the funnel throat and a skewer
hold the pellet and no cutting force goes through the tape. One sample takes 1-2 minutes, once an hour.

1. **Funnel and throat:** vibration feeds a PTFE-coated funnel; a ~4.5 mm throat holds one pellet on a gate flap;
   a break-beam confirms it. The pellet camera (white + 405 nm) logs colour, size and UV, and sets the skewer depth.
2. **Skewer:** a horizontal wire feeds into one side, stopping 0.5 mm short of the cut plane (no carry-in contamination).
3. **Cut:** a vertical wire draw-cuts down the centre line, feeding while it cuts.
4. **Drop:** the gate opens and the free half lands on dry high-tack tape. That's the **archive half**, kept whole for DNA.
5. **Pre-wet:** a felt tip lays a short propylene glycol (or glycerin) + ethanol streak ahead of the stamp point,
   index-matched so grains image without dark halos.
6. **Swing and smear:** the arm pivots 90° so the cut face points down, then stamps 2-3 smears at different
   pressures. That gives a density gradient; software picks the best single-layer region.
7. **Discard:** the arm swings over a waste bin inside the cassette, a solenoid snips clean wire above the pellet,
   fresh wire feeds.
8. **Laminate:** cover film (0.13-0.17 mm, COC ideal) plus a compliant pinch squashes the archive half into a disc.
9. **Microscope** (phase 2) scans the smear; a capstan meters tape by sprocket count.

Rules:
- **Everything that touches pollen is single-use:** fresh wire, fresh tape, and a bin that leaves with the cassette.
- **Blank cycles** (full cycles with no pellet) measure funnel and throat carryover.
- **Tape layout:** archive disc (~5 mm) + smear zone (~10 mm) ≈ 23 mm = 3 sprocket frames per sample. A blank
  gap of 3 frames each night (6 on Sundays) marks the days, so only the cassette's start and end dates matter.
- **Wires:** cut wire 35-38 AWG stainless at 2-7 N, ~25 mm per run; skewer 0.3-0.4 mm spring stainless in a guide tube.
- **Control:** PLC-style firmware on the motion ESP32: scan loop, step sequence, interlocks, timeouts, and
  FAULT = grid open.
- Pellet stickiness varies with humidity: log drawer RH, pellet size and press "hardness" per frame, with 2-3
  recipes, like fuel trims.

Dropped along the way: singulator disc, masking carrier tape, rolled print, syringe pump, twin-wire bridge,
suction arm. Dry grinding is out (the sugar binder smears and grains break).

## Cassette

- **One cassette = one experiment run = 4-6 weeks**, about one tagged cohort's foraging life.
- Ships to a lab with a **SQLite export** keyed by cassette ID and frame (see `data/schema.sql`).
- Contents: sample tape, cover film, archive take-up, cut-wire supply and used spool, skewer wire, felt-tip
  cartridge, waste bin, desiccant, QR run ID.
- Tape: start with 12 mm glossy acrylic-adhesive tape, then forensic lifting tape. Cover: 16 mm clear polyester
  film leader (sprocket indexing). Under $10 a season in consumables.
- Size estimate: pollen unit ~15 × 12 × 6 cm, cassette ~13 × 8 × 2.5 cm, microscope bay ~12 × 4 × 4 cm.

## Microscope (phase 2)

- About 1 µm resolution: a 20x/0.4 RMS objective, a tube lens and a lensless Pi camera (OpenFlexure-style),
  laid flat with a 45° mirror.
- Depth of field ~3 µm: a printed flexure Z stage (28BYJ-48 + M3 screw) and 10-15 slice focus stacks. Tape
  advance does the X scan.
- Brightfield LED below, oblique LEDs for texture, 405 nm for autofluorescence, a permanent yellow long-pass filter.
- Could first be a desktop cassette reader before it's docked into the hive unit.

## Compute

- **ESP32-S3 (hive node):** always on, mostly asleep. Sensors, FFT, DS3231 RTC (time master), battery gauge,
  LoRa receive windows for bloom nodes; buffers readings and switches the Pi.
- **ESP32-S3 (motion controller):** servos, steppers (TMC2209), LEDs; talks to the Pi over UART.
- **Raspberry Pi Zero 2 W (imager and record keeper):** power-gated per sample. SQLite master copy; read-only
  root plus a data partition; power is cut only after a "halted" GPIO. Raw focus stacks kept (~10-25 GB a season).
- **Connectivity:** results and thumbnails only, over Wi-Fi with an LTE-M fallback; the device dials out over an
  encrypted tunnel.
- Later: a second Pi + global-shutter camera for tags (phase 2); a custom PCB (ESP32-S3 + RP2350 motion
  coprocessor), CM4, LiFePO4 + MPPT.

## Pollen ID model

- The UV frame finds grain masks almost for free; UV brightness and size gate out debris.
- One MobileNetV3-Small int8 model on the best-focus crop plus UV channels; a few seconds per sample on the Zero 2 W.
- Pretrain on public datasets, fine-tune on a reference set of local flowers on the same tape.
- Count per pellet with a "mixed" flag; labels as a tree (family > genus > type); unknowns flagged for the lab.
- Model version stored on every row.

## Power

- ~3 Wh/day in season; ~0.5 Wh/day in **winter mode** (Nov-Feb): sensors every 15 min, counter and pollen robot
  off, one sync a day.
- 2× 18650 (~20 Wh), bq24074 charger with NTC (**no charging below 0 °C**), MAX17048 fuel gauge.
- **10 W panel** on its own post with a GX12 plug. The post doubles as the mount for a phase 2 battery box.
