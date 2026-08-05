% ─────────────────────────────────────────────────────────────────────────────
%  Vendored from Psychtoolbox-3, version 3.0.18 (PsychRadiometric).
%  Original file: PsychRadiometric/EnergyToQuanta.m
%  Source:    https://github.com/Psychtoolbox-3/Psychtoolbox-3
%  Copyright: (c) 1996-2018 David Brainard and the Psychtoolbox core developers.
%  License:   MIT (Psychtoolbox-3 default license). See psychtoolbox/NOTICE.md.
%
%  Included verbatim so that this toolbox runs without a Psychtoolbox install.
%  The code below is unmodified from the original; only this header was added.
% ─────────────────────────────────────────────────────────────────────────────

function quanta = EnergyToQuanta(wls,energy)
% quanta = EnergyToQuanta(wls,energy)
%
% Convert energy units (energy or power per unit wavelength)
% to quantal units (quanta or quanta/sec per unit wavelength).
%
% Constants are set up so that we have energy in joules or
% power in watts.  Wavelengths should be passed in nanometers.
%
% The routine is set up to convert spectra.  These are
% passed as the columns of the matrix energy.  The
% wavelengths corresponding to each row are passed in
% the column vector wls.
%
% 7/29/96  dhb  Wrote it.
% 8/16/96  dhb, abp  Modified interface.

wls = MakeItWls(wls);
h = 6.626e-34;
c = 2.998e8;
[n,m] = size(energy);
quanta = (energy/(h*c)) .* (1e-9 * wls(:,ones(1,m)));
