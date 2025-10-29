use data
xtset id year
*******Table 3. Descriptive statistical results.******
sum lnjust lndig lngdp lnpop lntrade lnind lnhci lnfd
*******Table 4. Results of the correlation check.******
pwcorr  lnjust lndig lngdp lnpop lntrade lnind lnhci lnfd, sig star (0.05)
********Table 5. Estimated results of the impact of the digital economy on just transition.*****
reg lnjust lndig lngdp lnpop lntrade lnind

xtgls lnjust lndig lngdp lnpop lntrade lnind, panels(iid) corr(ar1) igls
xttest3

xtserial lnjust lndig lngdp lnpop lntrade lnind, output 
tab id, gen (id)
xtserial lnjust lndig lngdp lnpop lntrade lnind id2-id72 year

qui xtreg lnjust lndig lngdp lnpop lntrade lnind year, fe
xtcsd, pes

xtdpdsys lnjust lndig lngdp lnpop lntrade lnind, lags(1) maxldep (4) twostep
estat abond
estat sargan
******Table 6. Estimated results of the impact of the digital economy on distributional, procedural, and restorative justice.****
xtdpdsys lnjust1 lndig lngdp lnpop lntrade , lags(1) maxldep (7) twostep
estat abond
estat sargan

xtdpdsys lnjust2 lndig lngdp lnpop lntrade lnind, lags(1) maxldep (8) twostep
estat abond
estat sargan

xtdpdsys lnjust3 lndig lngdp lnpop lntrade lnind, lags(1) maxldep (4) twostep
estat abond
estat sargan
*****Table 7. Estimated results of the impact of three aspects of the digital economy on just transition.*****
xtdpdsys lnjust lndig1 lngdp lnpop lntrade lnind, lags(1) maxldep (1) twostep
estat abond
estat sargan

xtdpdsys lnjust lndig2 lngdp lnpop lntrade lnind, lags(1) maxldep (4) twostep
estat abond
estat sargan

xtdpdsys lnjust lndig3 lngdp lnpop lntrade lnind, lags(1) maxldep (2) twostep
estat abond
estat sargan
******Table 8. Estimated results of the robustness check.******
xtdpdsys lnjust lndig lnpgdp lnpop lntrade lnind, lags(1) maxldep (4) twostep
estat abond
estat sargan

ivreg2h lnjust lndig lngdp lnpop lntrade lnind (lndig= ),small robust gmm2s

xtdpdsys lnjust lndigf lngdp lnpop lntrade lnind, lags(1) maxldep (4) twostep
estat abond
estat sargan

******Table 9. Estimated results of the mediating effects.*****
sgmediation lnjust, mv(lnhci) iv(lndig) cv(lngdp lnpop lntrade lnind)
sgmediation lnjust, mv(lnfd) iv(lndig) cv(lngdp lnpop lntrade lnind)

