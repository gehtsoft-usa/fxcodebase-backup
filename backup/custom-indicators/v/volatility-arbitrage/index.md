# Volatility Arbitrage

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61720  
> Forum: 17 · Topic 61720 · 3 post(s)

---

## Volatility Arbitrage

**Apprentice** · Thu Jan 15, 2015 4:12 am

![Volatility Arbitrage.png](images/98159/Volatility%20Arbitrage.png)

Based on the request.
[viewtopic.php?f=27&t=61718](https://fxcodebase.com/code/viewtopic.php?f=27&t=61718)

```
Middle = roc(source,1)
Upper = stdev(Middle,Period)*NumStdDev
Lower = Upper*-1
```

 [Volatility Arbitrage.lua](files/98159/Volatility%20Arbitrage.lua)

---

## Re: Volatility Arbitrage

**Alexander.Gettinger** · Mon Feb 23, 2015 11:12 am

MQL4 version of Volatility Arbitrage oscillator: [viewtopic.php?f=38&t=61858](https://fxcodebase.com/code/viewtopic.php?f=38&t=61858).

---

## Re: Volatility Arbitrage

**Apprentice** · Mon Oct 08, 2018 5:53 am

The indicator was revised and updated.
