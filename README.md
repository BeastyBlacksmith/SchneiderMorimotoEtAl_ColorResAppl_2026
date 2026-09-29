# PhotoSim — physiologically relevant display reproduction metrics

MATLAB toolbox for quantifying how faithfully a display reproduces the **α‑opic
quintuplet** — the signals of the L‑, M‑, and S‑cones, the rods, and the
melanopsin‑containing ipRGCs — from real‑world light. It implements:

- **PSRM** (Photoreceptor Signal Reproduction Metric): the fraction of real‑world
  α‑opic quintuplets a display can reproduce without distortion.
- **PSDM** (Photoreceptor Signal Distortion Metric): the distortion introduced
  when a display with fewer than five primaries reproduces a quintuplet.
- **Equal‑luminance photoreceptor excitation diagram**: an extension of the
  MacLeod–Boynton chromaticity diagram to all five photoreceptor signals.

## Requirements

- MATLAB with the **Statistics and Machine Learning Toolbox** (`normpdf`,
  `prctile`, `boxplot`) and the **Image Processing Toolbox** (`rgb2xyz`).
- `data/data.mat`, the consolidated data store bundled with the repository.

The few [Psychtoolbox](http://psychtoolbox.org/) colour utilities the code uses
(`SplineSpd`, `GenerateCIEDay`, and dependencies) are bundled with attribution
under [`src/functions/psychtoolbox/`](src/functions/psychtoolbox/) (see its
[`NOTICE.md`](src/functions/psychtoolbox/NOTICE.md)); no separate Psychtoolbox
install is needed.

### Tested environments

| Operating system | MATLAB |
|---|---|
| macOS 26.5.1 | R2025b |
| Ubuntu 24.04 | R2026a |

## Quick start

From the repository root, in MATLAB:

```matlab
main                % rebuild all databases + metrics, then redraw every figure
main(false)         % reuse existing results/*.mat, only redraw the figures
main(true, true)    % also rerun the supporting (Table) analyses (slow)
```

`main` adds `src/` to the path, builds the reference database, computes the
metrics at infinite, 12‑, 10‑, and 8‑bit display resolution (written to
`results/`), and redraws every paper figure into `figs/`. The default run
takes on the order of minutes on a modern laptop.

## Reproducing the results

- **What to run.** `main` from the repository root. The regenerated figure
  files are listed as the manifest in [`codecheck.yml`](codecheck.yml).
- **`data/data.mat` is an input, not an output.** Do not run the data‑preparation
  scripts that overwrite it (`build_data_mat`, `build_main_illuminants`,
  `run_asano_cie2006`); `main` does not call them.
- **The SpectroSense dataset is not required.** The ~25 GB download (see
  *External data*) is used only for a supplementary robustness check.

## Reference set

The main analyses use 183 illuminants — 65 CIE daylight phases (4000–20000 K)
plus 118 measured real‑world illuminants passing a fidelity screen (ANSI/IES
TM‑30‑18 `Rf ≥ 85`, `Rg ≥ 90`) — combined with the 99 IES TM‑30 reflectances,
giving 18,117 radiance spectra. Any collection of real‑world spectra can be
supplied instead.

## Repository layout

```
main.m                     one‑click wrapper (regenerate everything)
data/
  data.mat                 consolidated data store (loaded via load_data)
  28176839/                SpectroSense measured spectra (external, see below)
src/
  functions/               core reusable functions (get_psrm, get_psdm, ...)
    tm30/                   pure‑MATLAB ANSI/IES TM‑30‑18 implementation
    psychtoolbox/           bundled Psychtoolbox colour utilities
  analysis/                pipeline & analysis scripts (run_all_photosim, ...)
  plotting/                plot_figure1 … plot_figure9
results/                   generated metric/reference databases (not tracked)
figs/                      generated figures (not tracked)
```

## External data

The **SpectroSense** spectra used for the robustness check are not bundled
(>25 GB). Download them from figshare
(https://doi.org/10.6084/m9.figshare.28176839) and place the resulting
`28176839` folder directly under `data/`, so the spectra end up at
`data/28176839/SpectroSense Dataset`. Source: Lazar et al., *Regulation of
pupil size in natural vision across the human lifespan*, R. Soc. Open Sci.
**11**(6), 191613 (2024).

## Citing

If you use this toolbox, please cite the paper. The preprint is:

> A. C. Schneider, T. Morimoto, H. E. Smithson, and M. Spitschan, "Beyond colour
> gamuts: Novel metrics for the reproduction of photoreceptor signals," bioRxiv
> (2021). https://doi.org/10.1101/2021.02.27.433203

## Contributions

The PhotoSim toolbox was first developed by Allie C. Schneider and modified by
Takuma Morimoto.

## License

Released under the MIT License. See [LICENSE](LICENSE).
