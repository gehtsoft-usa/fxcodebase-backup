# ADR

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=68468  
> Forum: 17 · Topic 68468 · 5 post(s)


---

## ADR

**Apprentice** · Thu May 16, 2019 5:55 am

![EURUSD m5 (05-16-2019 1100).png](images/126363/EURUSD%20m5%20%2805-16-2019%201100%29.png)



Based on request.
[viewtopic.php?f=27&t=68459](https://fxcodebase.com/code/viewtopic.php?f=27&t=68459)

 [ADR.lua](files/126363/ADR.lua)


---

## Re: ADR

**7510109079** · Fri May 17, 2019 6:42 am

Nicely done Apprentice!

Can I ask how is the ADR % calculated?
i.e. what is it a percentage of?

thx


---

## Re: ADR

**Apprentice** · Fri May 17, 2019 8:00 am

ADR is the average of Range
The range is calculated as high -low


---

## Re: ADR

**7510109079** · Fri May 17, 2019 9:07 am

But the actual percentage amount at the beginning. How is that calculated?
Am i correct saying it is the percentage of the current days move compared to the 20 period ADR?


---

## Re: ADR

**Apprentice** · Sun May 19, 2019 4:13 am

rate = val * d1_source:pipSize() / ((day10_value + day20_value) / 2);
