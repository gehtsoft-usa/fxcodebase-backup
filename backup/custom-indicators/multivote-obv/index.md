# MultiVote OBV

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=24032  
> Forum: 17 · Topic 24032 · 3 post(s)


---

## MultiVote OBV

**Apprentice** · Wed Oct 03, 2012 3:52 am

![MV OVB.png](images/41344/MV%20OVB.png)



Original OBV only compares Closing Price.
MVOVB takes into account all price components.
This has resulted with higher sensitivity compared to the original.

if HIGH >previous HIGH then HIGHVOTE =1
if HIGH < previous HIGH then HIGHVOTE =-1

if LOW >previous LOW then LOWVOTE =1
if LOW < previous LOW then LOWVOTE =-1

if CLOSE>previous CLOSE then CLOSEVOTE=1
if CLOSE < previous CLOSE then CLOSEVOTE =-1

TOTALVOTE = HIGHVOTE + LOWVOTE + CLOSEVOTE
MVOBV = previousMVOBV + TOTALVOTE * Volume
MVOBV = previousMVOBV + TOTALVOTE * Volume

 [MV OVB.lua](files/41344/MV%20OVB.lua)

The indicator was revised and updated


---

## Re: MultiVote OBV

**Alexander.Gettinger** · Mon Oct 27, 2014 10:37 am

MQL4 version of MultiVote OBV oscillator: [viewtopic.php?f=38&t=61384](https://fxcodebase.com/code/viewtopic.php?f=38&t=61384).


---

## Re: MultiVote OBV

**Apprentice** · Thu Jun 29, 2017 6:07 am

The indicator was revised and updated.
