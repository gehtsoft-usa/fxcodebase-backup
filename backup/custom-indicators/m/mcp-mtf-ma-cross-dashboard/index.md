# MCP MTF MA Cross Dashboard

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=73563  
> Forum: 17 · Topic 73563 · 5 post(s)


---

## MCP MTF MA Cross Dashboard

**Apprentice** · Wed Apr 05, 2023 7:27 am

![EURUSD H1 (04-05-2023 1425).png](images/150287/EURUSD%20H1%20%2804-05-2023%201425%29.png)



- Red arrow displayed if ShortMVA < MediumMVA < LongMVA
- Green arrow displayed if ShortMVA > MediumMVA > LongMVA

 [MCP MTF MA Cross Dashboard.lua](files/150287/MCP%20MTF%20MA%20Cross%20Dashboard.lua)


---

## Re: MCP MTF MA Cross Dashboard

**mtrptr** · Wed Apr 05, 2023 1:02 pm

By comparing the results from MCP MTF MA Cross Dashboard vs the results from MA Cross Dashboard ([viewtopic.php?f=17&t=70419](https://fxcodebase.com/code/viewtopic.php?f=17&t=70419)) I found some discrepancies. Maybe MCP MTF MA Cross Dashboard sees the EMAs "live" (current candle in progress) while MA Cross Dashboard sees them based on how they were when the previous candle closed?


---

## Re: MCP MTF MA Cross Dashboard

**Apprentice** · Wed Apr 12, 2023 4:15 am

All Dashboard signals are live.


---

## Re: MCP MTF MA Cross Dashboard

**mtrptr** · Sat Apr 29, 2023 9:29 am

Hello Apprentice,
Shouldn't these 2 indicators give the same results for the same parameters?
In most instances they give the same results but sometimes they don't.


---

## Re: MCP MTF MA Cross Dashboard

**Apprentice** · Wed May 24, 2023 7:34 am

They should.

MA Cross Dashboard
Compares only two moving averages.
Average Indicator is used for moving averages calculation,
may use a slightly different calculation method.
