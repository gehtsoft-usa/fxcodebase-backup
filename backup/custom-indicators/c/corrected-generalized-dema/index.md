# Corrected generalized DEMA

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=72358  
> Forum: 17 · Topic 72358 · 1 post(s)


---

## Corrected generalized DEMA

**Apprentice** · Tue Jun 07, 2022 12:40 pm

![USDCHF H1 (06-07-2022 1939).png](images/146312/USDCHF%20H1%20%2806-07-2022%201939%29.png)



DEMA average is a double Exponential Moving Average. It was created to reduce the amount of lag time found in traditional moving averages. It was first released in the February 1994 TASC magazine.

This version embeds the corrected function, it measures deviations of the DEMA values, if the changes are not significant, then the value is “flattened”.

It also includes the floating-level functionality (2 levels based on the recent highest high and lowest low of the corrected curve).

 [Corrected generalized DEMA.lua](files/146312/Corrected%20generalized%20DEMA.lua)

DEMA.lua
[https://fxcodebase.com/code/viewtopic.php?f=17&t=1052](https://fxcodebase.com/code/viewtopic.php?f=17&t=1052)
