# MAMA convergence divergence

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=64239  
> Forum: 17 · Topic 64239 · 7 post(s)


---

## MAMA convergence divergence

**Apprentice** · Thu Dec 22, 2016 12:49 pm

![EURUSD H1 (12-22-2016 1803).png](images/110205/EURUSD%20H1%20%2812-22-2016%201803%29.png)



 [MAMA convergence divergence.lua](files/110205/MAMA%20convergence%20divergence.lua)

MAMA is available here.
[viewtopic.php?f=17&t=23283&p=40098&hilit=MAMA.lua#p40098](https://fxcodebase.com/code/viewtopic.php?f=17&t=23283&p=40098&hilit=MAMA.lua#p40098)

The indicator was revised and updated


---

## Re: MAMA convergence divergence

**DAXonly** · Sun Dec 25, 2016 5:59 am

Thanks a lot for this quick development


---

## Re: MAMA convergence divergence

**DAXonly** · Sun Dec 25, 2016 6:19 am

However you introduced a "period" in this indicator which (apparently) doesn't exist in the mama.lua I have implemented long time ago: could you tell me which "standard period" is hidden in mama.lua
I thank you in advance
Laurent


---

## Re: MAMA convergence divergence

**Apprentice** · Sun Dec 25, 2016 6:25 am

MAMACD is difference between two MAMA lines
Signal line is SMA/MVA of MACD
Histogram is MAMACD Signal line difference

Period is used in Signal line calculation.


---

## Re: MAMA convergence divergence

**DAXonly** · Sun Dec 25, 2016 7:09 am

Well... could you explain which "idea" is behind this indicator - because I don't understand it clearly.
Furthermore could you just add mama and fama lines to the list of moving averages available in your MA_difference.lua ?
Thanks
Laurent


---

## Re: MAMA convergence divergence

**DAXonly** · Fri Dec 30, 2016 5:02 am

Hi Apprentice,
Coud you please give me some news...
Thanks in advance
Laurent


---

## Re: MAMA convergence divergence

**Apprentice** · Fri Dec 30, 2016 5:10 am

MAMACD is difference between two MAMA lines, this was requested.
As a bonus, I have introduced a moving average of such differences,
Similar to MACD.
For the moving average, I use period.
