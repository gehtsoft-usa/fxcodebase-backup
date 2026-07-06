# Engulfing pattern Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=72949  
> Forum: 31 · Topic 72949 · 1 post(s)


---

## Engulfing pattern Strategy

**Apprentice** · Tue Nov 15, 2022 6:44 am

![CHN50 m1 (11-15-2022 1243).png](images/148356/CHN50%20m1%20%2811-15-2022%201243%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.php?f=27&t=72768](https://fxcodebase.com/code/viewtopic.php?f=27&t=72768)

Open Long
Lower Time Frame
1. MA cross-over 2. MA
Higher Time Frame
Engulfing Up Pattern

Vice versa for Short

 [Engulfing pattern Strategy.lua](files/148356/Engulfing%20pattern%20Strategy.lua)

Bullish Engulfing Pattern (Theoretical)
Close[1]< Open[1]
Close[0]> Open[0]
Open[0]<Close[-1]
Close[0]>Open[-1]

Bullish Engulfing Pattern (Used)
Close[1]< Open[1]
Close[0]> Open[0]
Open[0]<=Close[-1]
Close[0]>=Open[-1]
