# Smoothed RSI Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=74691  
> Forum: 31 · Topic 74691 · 4 post(s)


---

## Smoothed RSI Strategy

**Apprentice** · Fri Mar 15, 2024 8:16 am

![EURUSD H1 (03-15-2024 1412).png](images/154674/EURUSD%20H1%20%2803-15-2024%201412%29.png)



Based on Smoothed RSI
[https://fxcodebase.com/code/viewtopic.php?f=17&t=2675](https://fxcodebase.com/code/viewtopic.php?f=17&t=2675)
Open Long on Buy Level CrossOver (50)
Close Long on Buy Exit Level CrossUnder (70)
Vice versa for Short

 [Smoothed RSI Strategy.lua](files/154674/Smoothed%20RSI%20Strategy.lua)


---

## Re: Smoothed RSI Strategy

**foxbat** · Fri Sep 13, 2024 8:34 am

Hello. The strategy works fine when I run an optimization, but when I set it to trade the message in the screenshot appears. (I have attached this). Please assist with advice on how to resolve this. Thanks, David


---

## Re: Smoothed RSI Strategy

**Apprentice** · Sat Sep 14, 2024 4:18 am

We have added your request to the development list.
Development reference 724


---

## Re: Smoothed RSI Strategy

**Apprentice** · Thu Oct 31, 2024 8:05 am

![EURUSD H1 (10-31-2024 1407).png](images/157109/EURUSD%20H1%20%2810-31-2024%201407%29.png)



It’s a bug in FXTS2. core.host:execute ("attachTextToChart", "Long") fails when you create an indicator from a strategy

Try this version.

 [SMOOTHED RSI.lua](files/157109/SMOOTHED%20RSI.lua)

 [Smoothed_RSI_Strategy.lua](files/157109/Smoothed_RSI_Strategy.lua)
