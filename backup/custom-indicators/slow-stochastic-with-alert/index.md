# Slow stochastic with alert

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=65635  
> Forum: 17 · Topic 65635 · 3 post(s)


---

## Slow stochastic with alert

**Apprentice** · Tue Jan 16, 2018 5:41 am

![USDSEK H2 (01-16-2018 0952).png](images/117070/USDSEK%20H2%20%2801-16-2018%200952%29.png)



Based on the request.
[viewtopic.php?f=27&t=65001](https://fxcodebase.com/code/viewtopic.php?f=27&t=65001)

 [Slow stochastic with alert.arfs9090.lua](files/117070/Slow%20stochastic%20with%20alert.arfs9090.lua)


---

## Re: Slow stochastic with alert

**Stevie Love** · Mon May 28, 2018 8:20 am

Hi, Great alerting indicator, thanks! I've just noticed a minor bug however. When the OB Level is set to 100 the line disappears completely. Any chance we could get a fix?

Many thanks.


---

## Re: Slow stochastic with alert

**Apprentice** · Wed May 30, 2018 2:31 pm

100 / 0 are max/min lines.
It will be drawn over user lines.
The alert bit will work.
