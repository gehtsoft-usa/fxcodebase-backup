# Vetrivel System Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63218  
> Forum: 31 · Topic 63218 · 2 post(s)


---

## Vetrivel System Strategy

**Apprentice** · Fri Mar 04, 2016 1:38 pm

![EURUSD H1 (03-04-2016 1902).png](images/105123/EURUSD%20H1%20%2803-04-2016%201902%29.png)



Vetrivel systems by Gomu Vetrivel
As described in the article November 2005 issue of Technical Analysis of STOCKS & COMMODITIES magazine.

Base System
var:x(0);
x=absvalue(c-c[1]);
if c>average(c,10) and c[1]<average(c,10)[1] then buy at c;
if c<average(c,10) and c[1]>average(c,10)[1] then sell at c;

Hypothesis 1
x=absvalue(c-c[1]);
if x>x[1] and c>average(c,10) and c[1]<average(c,10)[1] then buy at c;
if x>x[1] and c<average(c,10) and c[1]>average(c,10)[1] then sell at c;

Hypothesis 2
x=absvalue(c-c[1]);
if x<x[1] and c>average(c,10) and c[1]<average(c,10)[1] then buy at c;
if x<x[1] and c<average(c,10) and c[1]>average(c,10)[1] then sell at c;

Exit (all three systems)
if marketposition=-1 and c>average(c,5) then exitshort at c;
if marketposition=1 and c<average(c,5) then exitlong at c;

 [Vetrivel System Strategy.lua](files/105123/Vetrivel%20System%20Strategy.lua)

The Strategy was revised and updated on January 21, 2019.


---

## Re: Vetrivel System Strategy

**Apprentice** · Sat Dec 23, 2017 12:55 pm

The strategy was revised and updated.
