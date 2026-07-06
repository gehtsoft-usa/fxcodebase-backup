# Larry's 2 day Signal

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61316  
> Forum: 17 · Topic 61316 · 2 post(s)


---

## Larry's 2 day Signal

**Apprentice** · Thu Oct 09, 2014 5:48 am

![Larry's 2 day Signal.png](images/96463/Larrys%202%20day%20Signal.png)



Based on the request
[viewtopic.php?f=27&t=61295](https://fxcodebase.com/code/viewtopic.php?f=27&t=61295)

TrueHigh = max(High, Close.1)
TrueLow = min(Low, Close.1)

if Close-TrueLow > Close.1-TrueLow.1
And TrueHigh-Close< TrueHigh.1 - Close.1
And Close<Close.1 and Close.1<close.2 then
Buy Signal ( at the High of Today)

 [Larry's 2 day Signal.lua](files/96463/Larrys%202%20day%20Signal.lua)

The indicator was revised and updated


---

## Re: Larry's 2 day Signal

**Apprentice** · Mon Jun 26, 2017 3:42 am

The indicator was revised and updated.
