# Gain probability index

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=64656  
> Forum: 17 · Topic 64656 · 2 post(s)


---

## Gain probability index

**Apprentice** · Mon May 15, 2017 4:33 pm

![GBPUSD m1 (05-15-2017 2138).png](images/112435/GBPUSD%20m1%20%2805-15-2017%202138%29.png)



As described in article Gain Probability Index by Mike B. Siroky, MD ,
June 2017 edition of the S & C magazine
GPI = 100 * [(number up bars) / (number up bars + number down bars)]

 [Gain probability index.lua](files/112435/Gain%20probability%20index.lua)

The indicator was revised and updated


---

## Payoff odds

**Apprentice** · Mon May 15, 2017 5:01 pm

![GBPUSD H1 (05-15-2017 2232).png](images/112436/GBPUSD%20H1%20%2805-15-2017%202232%29.png)



As described in article Gain Probability Index by Mike B. Siroky, MD ,
June 2017 edition of the S & C magazine
Payoff odds = [UP/DN] * [d/u]

UP = sum of up price changes and
 u = number of up bars.
DN = sum of down price changes and
d = number of down bars.

 [Payoff odds.lua](files/112436/Payoff%20odds.lua)
