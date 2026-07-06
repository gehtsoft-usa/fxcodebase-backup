# Close price breakout

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=64137  
> Forum: 17 · Topic 64137 · 1 post(s)


---

## Close price breakout

**Apprentice** · Thu Nov 24, 2016 6:28 am

![EURUSD m1 (11-24-2016 1141).png](images/109194/EURUSD%20m1%20%2811-24-2016%201141%29.png)



Based on request.
[viewtopic.php?f=27&t=64135](https://fxcodebase.com/code/viewtopic.php?f=27&t=64135)

peak = ref(C,-2)
 if ref(C,-2) = max C during 5 day
trough = ref(c,-2)
if ref(C,-2) = min C during 5 day
n=20

Alert when:
C cross peak and C >= EMA(n)
trough cross C and C <= EMA(n)

 [Close price breakout.lua](files/109194/Close%20price%20breakout.lua)

Alert when:
C cross peak and C >= EMA
trough cross C and C <= EMA
Effectively Close price breakout.lua with MA Cross Period set to zero.

 [Close price breakout modification.lua](files/109194/Close%20price%20breakout%20modification.lua)

The indicator was revised and updated
