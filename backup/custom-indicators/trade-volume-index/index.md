# Trade Volume Index

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=60565  
> Forum: 17 · Topic 60565 · 5 post(s)


---

## Trade Volume Index

**Apprentice** · Tue Apr 22, 2014 4:39 am

![Trade Volume Index.png](images/93623/Trade%20Volume%20Index.png)



The Trade Volume Index ("TVI") shows whether a security is being accumulated (purchased) or distributed (sold).
Page 338 of Technical analysis from A to Z by Steven B. Achelis.

 [Trade Volume Index.lua](files/93623/Trade%20Volume%20Index.lua)

The indicator was revised and updated


---

## Re: Trade Volume Index

**Alexander.Gettinger** · Wed Jun 04, 2014 1:10 pm

MQL4 version of Trade Volume Index: [viewtopic.php?f=38&t=60766](https://fxcodebase.com/code/viewtopic.php?f=38&t=60766).


---

## Re: Trade Volume Index

**Apprentice** · Thu Jun 22, 2017 7:11 am

The indicator was revised and updated.


---

## Re: Trade Volume Index

**fxlion** · Thu Jun 22, 2017 8:02 am

HI APPRENDICE ,

CAN YOU CREATE A STRATEGY BASED ON THIS INDICATOR WITH EMA

STRATEGY NAME :**EMA TRADE VOLUME INDEX STRATEGY**

**INDICATORS:**

**1. TVI WITH DEFAULT PARAMETERS
2.TMVA: MVA(EMA)-( DATA SOURCE-TVI)- PERIOD:50
3. LMVA:MVA(EMA)- ( DATA SOURCE- PRICE-LOW)
4.HMVA:MVA(EMA)-(DATA SOURCE- PRICE - HIGH)**

**TIME FRAME:M15 OR MORE**

BUY: TVI> TMVA AND PRICE CROSS OVER LMVA
SELL: TVI< TMVA AND PRICE CROSS UNDER HMVA

THANKS IN ADVANCE


---

## Re: Trade Volume Index

**Apprentice** · Fri Jun 23, 2017 5:39 am

Try this version.
[viewtopic.php?f=31&t=64824](https://fxcodebase.com/code/viewtopic.php?f=31&t=64824)
