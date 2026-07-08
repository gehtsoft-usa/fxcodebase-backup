# TREND ADVISOR Overlay

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=13772  
> Forum: 17 · Topic 13772 · 2 post(s)

---

## TREND ADVISOR Overlay

**Apprentice** · Tue Feb 21, 2012 4:47 pm

![TRENDADVISOR  Overlay.png](images/26521/TRENDADVISOR%20Overlay.png)

```
if Close > MA(Close, 50)AND NOT(Close > MA(Close, 200))AND NOT(MA(Close, 50) > MA(Close, 200)); then  Cond = 1;
if Close > MA(Close, 50)AND Close > MA(Close, 200)AND NOT(MA(Close, 50) > MA(Close, 200)); then Cond = 2;
if Close > MA(Close, 50)AND Close > MA(Close, 200)AND MA(Close, 50) > MA(Close, 200); then Cond = 3;
if  NOT(Close > MA(Close, 50))AND Close > MA(Close, 200)AND MA(Close, 50) > MA(Close, 200); then Cond = 4;
if NOT(Close > MA(Close, 50))AND NOT(Close > MA(Close, 200))AND MA(Close, 50) > MA(Close, 200); then Cond = 5;
if NOT(Close > MA(Close, 50))AND NOT(Close > MA(Close, 200))AND NOT(MA(Close, 50) > MA(Close, 200));  then Cond = 6;

LONG  Cond < 4 else SHORT
```

 [TRENDADVISOR Overlay.lua](files/26521/TRENDADVISOR%20Overlay.lua)

This is a direct translation of Ami broker indicators.
Some things do not make sense.
If someone knows the language better, you can double check my work.

The original code, the request can be found here.
[viewtopic.php?f=27&t=13749&p=26520#p26520](https://fxcodebase.com/code/viewtopic.php?f=27&t=13749&p=26520#p26520)

---

## Re: TREND ADVISOR Overlay

**Apprentice** · Mon Mar 05, 2018 1:54 pm

The Indicator was revised and updated.
