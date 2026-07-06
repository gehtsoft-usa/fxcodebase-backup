# Comparative Moving Average Convergence/Divergence

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=35469  
> Forum: 17 · Topic 35469 · 4 post(s)


---

## Comparative Moving Average Convergence/Divergence

**Apprentice** · Thu Apr 25, 2013 6:18 am

![Comparative MACD.png](images/60003/Comparative%20MACD.png)



Allows you to select up to five currency pairs.
MACD is calculated for all of them.
Average MACD of all selected pairs is drawn also.

I presented a Relativ MACD algorithm.
In this way, a comparison of different currency pairs is possible.

 [Comparative MACD.lua](files/60003/Comparative%20MACD.lua)

The indicator was revised and updated


---

## Re: Comparative Moving Average Convergence/Divergence

**Obsestric** · Thu Apr 25, 2013 5:54 pm

Thanks for being so prompt with the creation! This seems to work right with a regular macd setting (12,26,9), but if I try to change the number to say 5,13,8 the indicator gives me an error message.

I was also wondering what is the main difference between the relative and absolute setting?


---

## Re: Comparative Moving Average Convergence/Divergence

**Apprentice** · Fri Apr 26, 2013 6:10 am

Small Bug caused this issue.
I have fix it.

Relative - a percentage based MACD
For use, if we have different currencies,
 if it is impossible to compare them on same scale
Absolute - standard MACD


---

## Re: Comparative Moving Average Convergence/Divergence

**Apprentice** · Tue May 23, 2017 9:51 am

Indicator was revised and updated.
