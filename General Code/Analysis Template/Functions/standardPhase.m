function sta_phase = standardPhase(org_phase)
%G and S vales were scaled from -1 ~ +1 to 0 ~ (2^16-1), 32767.5 is 0;
sta_phase = (double(org_phase)-32767.5)/32767.5;
end