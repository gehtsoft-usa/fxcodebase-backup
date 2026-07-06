# Dinapoli Preferred Stochastic Center Of Gravity Oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=66628  
> Forum: 17 · Topic 66628 · 2 post(s)


---

## Dinapoli Preferred Stochastic Center Of Gravity Oscillator

**Apprentice** · Fri Sep 07, 2018 5:03 am

![EURUSD m5 (09-07-2018 1005).png](images/121006/EURUSD%20m5%20%2809-07-2018%201005%29.png)



Based on request.
[viewtopic.php?f=27&t=66626](https://fxcodebase.com/code/viewtopic.php?f=27&t=66626)

F
(K) in Dinapoli Preferred Stochastic > (D)
AND
(CG) in Center Of Gravity Oscillator by John Ehlers (Upd: Jun 08) > (SIG)
THEN
Color Green (+1)

IF
(K) in Dinapoli Preferred Stochastic < (D)
AND
(CG) in Center Of Gravity Oscillator by John Ehlers (Upd: Jun 08) < (SIG)
THEN
Color Red (-1)

ELSE
ZERO

 [Dinapoli Preferred Stochastic Center Of Gravity Oscillator.lua](files/121006/Dinapoli%20Preferred%20Stochastic%20Center%20Of%20Gravity%20Oscillator.lua)

Center Of Gravity Oscillator
[viewtopic.php?f=17&t=366](https://fxcodebase.com/code/viewtopic.php?f=17&t=366)
Dinapoli Preferred Stochastic
[viewtopic.php?f=17&t=1874](https://fxcodebase.com/code/viewtopic.php?f=17&t=1874)


---

## Re: Dinapoli Preferred Stochastic Center Of Gravity Oscillat

**Apprentice** · Tue Nov 05, 2019 6:24 am

![EURUSD D1 (11-05-2019 1029).png](images/129573/EURUSD%20D1%20%2811-05-2019%201029%29.png)



IF
(K) in Dinapoli Preferred Stochastic > (D)
AND
(CG) in Center Of Gravity Oscillator by John Ehlers (Upd: Jun 08) > (SIG)
AND
CCI MA Difference > EMA(CCI MA Difference, x)
AND
standard indicator Kairi KRI > EMA(KRI, x)
THEN
Color Green (+1)

IF
(K) in Dinapoli Preferred Stochastic < (D)
AND
(CG) in Center Of Gravity Oscillator by John Ehlers (Upd: Jun 08) < (SIG)
AND
CCI MA Difference < EMA(CCI MA Difference, x)
AND
standard indicator Kairi KRI < EMA(KRI, x)
THEN
Color Red (-1)

ELSE
ZERO

 [Modified Dinapoli_Preferred_Stochastic_Center_Of_Gravity_Oscillator.lua](files/129573/Modified%20Dinapoli_Preferred_Stochastic_Center_Of_Gravity_Oscillator.lua)

CCI MA Difference:
[viewtopic.php?f=17&t=65046](https://fxcodebase.com/code/viewtopic.php?f=17&t=65046)
Center Of Gravity Oscillator
[viewtopic.php?f=17&t=366](https://fxcodebase.com/code/viewtopic.php?f=17&t=366)
Dinapoli Preferred Stochastic
[viewtopic.php?f=17&t=1874](https://fxcodebase.com/code/viewtopic.php?f=17&t=1874)
