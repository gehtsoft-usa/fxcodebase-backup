# Alternative OBV

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=67069  
> Forum: 48 · Topic 67069 · 1 post(s)


---

## Alternative OBV

**Alexander.Gettinger** · Fri Dec 07, 2018 1:15 pm

The classic formula
Close > previousClose
OBV = OBVprevious + VOLUME
Close < previousClose
OBV = OBVprevious - VOLUME
IF Close = previousClose
OBV = previousOBV

1. Alternative
(Close > Open)
OBV = previousOBV + (Volume* (Close-Open) / (High-Low));
(Close < Open)
OBV = previousOBV - (Volume * (Open-Close) / (High-Low));

2. Alternative
OBV= previousOBV + (Volume * (High-Open) / (High-Low)) - (Volume * (Open-Low) / (High-Low)).

 

![Alternative OBV.PNG](images/122578/Alternative%20OBV.PNG)



Download:

 [Alternative OBV_JS.jsl](files/122578/Alternative%20OBV_JS.jsl)
