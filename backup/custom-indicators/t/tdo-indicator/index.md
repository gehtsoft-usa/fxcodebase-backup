# TDO indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=70899  
> Forum: 17 · Topic 70899 · 1 post(s)


---

## TDO indicator

**richardtao** · Tue Feb 09, 2021 1:56 am

The TDO indicator is applying to Trading Station II.
Technical Analysis Office simple tool for contrarian trader.
This indicator is including five subset oscillators.
CDV is standard deviation compare with average range. The parameter "L:Level" defines the multiplier of atr. The parameter "CK:check " defines the reverse sensitivity by atr.
PVG is slow k divergent. The parameter "L:Level" defines the swing extreme level.
SWK is sine wave skip as the new phase. The parameter "L:Level" defines the swing extreme level. The parameter "CK:check " defines the maximum span for skip.
MFH is volume weighting. The parameter "L:Level" defines the swing extreme level. The parameter "CK:check " equal to 1 display calculated by direction force else by time window.
CRF is correlation compare with fluctuation. The parameter "L:Level" defines the correlation base level which normally is 0. Cross base level as the new phase.

 [TDO.lua](files/140611/TDO.lua)
