# CCI BB Signal with SAR targets

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=73650  
> Forum: 17 · Topic 73650 · 3 post(s)


---

## CCI BB Signal with SAR targets

**Apprentice** · Fri Apr 28, 2023 1:22 pm

![EURUSD H8 (04-28-2023 2015).png](images/150606/EURUSD%20H8%20%2804-28-2023%202015%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.php?f=17&t=72999](https://fxcodebase.com/code/viewtopic.php?f=17&t=72999)

BUY Signal:
CCI crosses BELOW oversold, buy signal prints when a candle crosses ABOVE the LOWER Bollinger Band

Sell Signal:
CCI crosses ABOVE overbought, sell signal prints when a candle crosses BELOW the UPPER Bollinger band.

 [CCI BB Signal with SAR targets.lua](files/150606/CCI%20BB%20Signal%20with%20SAR%20targets.lua)


---

## Re: CCI BB Signal with SAR targets

**jrichardson83** · Mon Sep 25, 2023 8:20 pm

> **Apprentice wrote:**
>
>
> EURUSD H8 (04-28-2023 2015).png
>
>
> Based on the request.
> [https://fxcodebase.com/code/viewtopic.php?f=17&t=72999](https://fxcodebase.com/code/viewtopic.php?f=17&t=72999)
>
> BUY Signal:
> CCI crosses BELOW oversold, buy signal prints when a candle crosses ABOVE the LOWER Bollinger Band
>
> Sell Signal:
> CCI crosses ABOVE overbought, sell signal prints when a candle crosses BELOW the UPPER Bollinger band.
>
>
>
> CCI BB Signal with SAR targets.lua

Just noticed that this one got done. Thanks a million.

One issue, though. I didn't want to use the actual SAR in the calculation, just the "Entry/Target" algorithm you guys coded for the previous "SAR w/Price Tgargets" indicator. So if you could just remove the SAR in the calculation, but leave the Entry/Targets component, we're all good.


---

## Re: CCI BB Signal with SAR targets

**Apprentice** · Sat Sep 30, 2023 3:21 am

We have added your request to the development list.
Development reference 889.
