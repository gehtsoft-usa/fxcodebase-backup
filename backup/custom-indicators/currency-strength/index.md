# Currency Strength

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=59550  
> Forum: 17 · Topic 59550 · 2 post(s)


---

## Currency Strength

**Apprentice** · Sat Sep 21, 2013 6:46 pm

![Currency Strength.png](images/89608/Currency%20Strength.png)



1. Calculate (B-L)/(H-L)
B = current bid price
H = Period high
L = Period low
2. The result from step 1 resolves itself into a value between 0 and 1
3. Re-scale into a value between 1 and 10.
4. If the currency is YYY,
For XXX/YYY pairs
Subtracted 3
For YYY/XXX pairs
Add 3

5. Average

 [Currency Strength.lua](files/89608/Currency%20Strength.lua)


---

## Re: Currency Strength

**Apprentice** · Wed Aug 01, 2018 10:12 am

The Indicator was revised and updated.
