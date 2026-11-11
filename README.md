# Beehive pollen sampler

Open hardware for bee science: a solar-powered "smart bottom board" that sits under a beehive, logs how the
colony is doing, and samples, archives and (later) images the pollen the bees bring home. One cassette of tape
holds a whole experiment run and ships to a lab with a SQLite export, so any pellet can be traced to its time,
its context and its frame on the reel, and sent for DNA metabarcoding.

**Status: research and design phase.** Nothing here is built yet. This repo holds the design, the experiment
protocol, the data format and the bench-test plan, so the build can be checked against them as it happens.

## Why

Pollen trends only mean something next to the colony's state and what's in bloom. Labs that study floral
preference by DNA metabarcoding usually get pellets from entrance traps with little context. This device is
designed to hand a lab:

- a time-stamped, DNA-ready archive of individual pellets,
- the sampling effort and context for every pellet (weather, colony weight, brood temperature, sound, traffic),
- raw images and an open SQLite export.

It also carries a forager experiment that tests an alternative hypothesis with the same data: is a bee's
choice of flowers her own, or a decision the colony makes together? See [docs/experiment.md](docs/experiment.md).

## How it works (short version)

- **Telemetry:** load cells, temperature and humidity inside and out, a probe row across the frames for the
  winter cluster, an I2S microphone with on-device FFT, and IR entrance counters, logged to SQLite.
- **Pollen robot:** about once an hour a trap grid swings in briefly. One pellet is caught, photographed in
  white and 405 nm light, skewered and sliced. One half is archived whole on tape for DNA; the other is smeared
  for the microscope. Everything that touches pollen is single-use.
- **Fail-safe:** the trap grid fails open on fault, boot or brownout, so the colony is never trapped.
- **Power:** a 10 W panel and an 18650 pack; about 3 Wh/day in season and a telemetry-only winter mode.

Full design in [docs/design.md](docs/design.md).

## Repository layout

| Path | Contents |
|---|---|
| `docs/design.md` | Mechanism, enclosure zones, telemetry, compute, power, connectivity |
| `docs/experiment.md` | The forager crossover study, controls, sampling and contamination checks |
| `docs/bench-tests.md` | The first bench tests, each with what counts as a pass |
| `data/schema.sql` | Draft SQLite schema for the export a lab receives |
| `hardware/bom.csv` | Draft bill of materials |
| `firmware/` | Coming: ESP32-S3 hive node and motion controller |
| `docs/references.md` | Papers, methods and suppliers |

## Phases

1. **Pollen robot first:** slicing, the tape-reel archive and the microscope working on the bench, then on a hive.
2. **All sensors:** weight, temperature and humidity, sound, traffic, weather, CO₂, a varroa camera, LoRa bloom cameras.
3. **Tagged foragers:** a handful of marked bees and an entrance camera that reads their tags.
4. **Observation hive** with automatic waggle-dance decoding.

## Licenses

- Code: GPL-3.0 ([LICENSE](LICENSE))
- Hardware designs (CAD, wiring, BOM): CERN-OHL-S-2.0 ([LICENSE-HARDWARE](LICENSE-HARDWARE))
- Documentation and data: CC BY 4.0 ([LICENSE-DOCS](LICENSE-DOCS)). Please credit this project if you publish
  with it.

Built for science, not profit. If you run one on your own hives, or you're a lab that wants one, open an issue.
