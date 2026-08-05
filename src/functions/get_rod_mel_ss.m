function [rod, mel] = get_rod_mel_ss(wl, age, dlens_pct, dmac_pct, field_deg)
%GET_ROD_MEL_SS  Rod & melanopsin energy spectral sensitivities, SST-style.
%
% Reconstructs the rod and melanopsin fundamentals following the
% SilentSubstitutionToolbox (Spitschan, Aguirre & Brainard 2015; and the
% PsychColorimetricData DefaultPhotoreceptors 'LivingHumanRod' /
% 'LivingHumanMelanopsin' definitions):
%
%   photopigment  : Govardovskii et al. (2000) nomogram
%                     rod        lambda_max = 491 nm,  axial OD = 0.334
%                     melanopsin lambda_max = 480 nm,  axial OD = 0.015
%   pre-receptoral: CIE 2006 lens/ocular density (age + individual dlens%)
%                   applied to BOTH; CIE 2006 macular pigment density
%                   (field size + individual dmac%) applied to the ROD only.
%                   Melanopsin carries NO macular pigment, because the ipRGCs
%                   lie in front of most of the macular pigment (SST/PTB
%                   default; Vienot et al. 2012).
%
% The lens and macular densities use the SAME per-observer parameters as the
% Asano (2016) cone family (generate_cone_fund_family_asano_cie2006), so the
% pre-receptoral filtering is anatomically shared ("yoked") across all
% photoreceptors, as required to test the effect of pre-receptoral individual
% differences on the rod/melanopsin signals.
%
% Only the pre-receptoral filters vary across observers; the rod/melanopsin
% photopigments (lambda_max, optical density) are held at their standard values,
% because no population model of rod/ipRGC photopigment variation exists.
%
% INPUT
%   wl         column/row vector of wavelengths [nm] (e.g. 390:5:780)
%   age        observer age [years]
%   dlens_pct  individual lens-density deviation [%] (0 = population mean)
%   dmac_pct   individual macular-density deviation [%] (rod only)
%   field_deg  field size [deg] (drives macular peak density)
%
% OUTPUT
%   rod, mel   1 x numel(wl) energy sensitivities, each peak-normalised to 1
%
% Requires Psychtoolbox (GovardovskiiNomogram, WlsToS) — already a dependency.
% First developed by ACS, modified by TM.

    persistent P
    wl = wl(:);
    if isempty(P) || numel(P.wl) ~= numel(wl) || any(P.wl ~= wl)
        P = local_setup(wl);
    end

    % --- per-observer pre-receptoral optical densities (CIE 2006 / Asano) ---
    Docul = ocular_density_age(age, P.Docul1, P.Docul2) .* (1 + dlens_pct/100);
    Dmac  = (0.485*exp(-field_deg/6.132) * (1 + dmac_pct/100)) .* P.relMac;

    Tlens = 10.^(-Docul);      % lens/ocular transmittance
    Tmac  = 10.^(-Dmac);       % macular transmittance (rod only)

    % --- energy sensitivities (quantal absorptance * wl), peak-normalised ---
    rod = wl .* P.aRod .* Tlens .* Tmac;
    mel = wl .* P.aMel .* Tlens;            % melanopsin: lens only, no macular
    rod = (rod ./ max(rod))';
    mel = (mel ./ max(mel))';
end

% ---------------------------------------------------------------------------
function P = local_setup(wl)
% Wavelength-fixed pieces: photopigment absorptances (Govardovskii nomogram +
% axial optical density) and the CIE 2006 pre-receptoral density templates.
    data = load_data();

    relMac = max(interp1(data.cie2006_macular_density(:,1), data.cie2006_macular_density(:,2), wl, 'linear','extrap'), 0);
    Adoc   = data.cie2006_docul; Adoc = Adoc(all(~isnan(Adoc),2),:);
    Docul1 = max(interp1(Adoc(:,1), Adoc(:,2), wl, 'linear','extrap'), 0);
    Docul2 = max(interp1(Adoc(:,1), Adoc(:,3), wl, 'linear','extrap'), 0);

    % Govardovskii (2000) normalised quantal absorbance (peak 1)
    absRod = GovardovskiiNomogram(WlsToS(wl), 491)';   % nWls x 1
    absMel = GovardovskiiNomogram(WlsToS(wl), 480)';

    P.wl     = wl;
    P.relMac = relMac;
    P.Docul1 = Docul1;
    P.Docul2 = Docul2;
    % Beer-Lambert axial self-screening: absorptance = 1 - 10^(-OD*absorbance)
    P.aRod = 1 - 10.^(-0.334 * absRod);
    P.aMel = 1 - 10.^(-0.015 * absMel);
end

% Age-dependent CIE 2006/CIEPO06 ocular (lens) media density, identical to the
% function used inside generate_cone_fund_family_asano_cie2006.
function Docul_ave = ocular_density_age(age, Docul1, Docul2)
    if age <= 60
        Docul_ave = Docul1 .* (1 + 0.02*(age - 32)) + Docul2;
    else
        Docul_ave = Docul1 .* (1.56 + 0.0667*(age - 60)) + Docul2;
    end
    Docul_ave = max(Docul_ave, 0);
end
