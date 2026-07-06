# Bollinger Bands Convergence Divergence Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63430  
> Forum: 31 · Topic 63430 · 6 post(s)


---

## Bollinger Bands Convergence Divergence Strategy

**Apprentice** · Sun May 01, 2016 8:31 am

![EURUSD m5 (05-01-2016 1458).png](images/106015/EURUSD%20m5%20%2805-01-2016%201458%29.png)



Based on Bollinger Bands Convergence Divergence Indicator.
[viewtopic.php?f=17&t=63020](https://fxcodebase.com/code/viewtopic.php?f=17&t=63020)

 [Highly adaptable Bollinger Bands Convergence Divergence Strategy.lua](files/106015/Highly%20adaptable%20Bollinger%20Bands%20Convergence%20Divergence%20Strategy.lua)

The Strategy was revised and updated on December 18, 2018.


---

## Re: Bollinger Bands Convergence Divergence Strategy

**albertparis** · Thu Nov 17, 2016 11:09 am

Hello sorry for my English I am French
Can you add the "Number of periods to smooth" function to filter the signals

[viewtopic.php?f=17&t=63020](https://fxcodebase.com/code/viewtopic.php?f=17&t=63020)

Exemple [viewtopic.php?f=17&t=23335&hilit=BB+analyser](https://fxcodebase.com/code/viewtopic.php?f=17&t=23335&hilit=BB+analyser)

 thank you very much


---

## Re: Bollinger Bands Convergence Divergence Strategy

**Apprentice** · Sat Nov 26, 2016 7:44 am

You want to add an extra averaging of BB lines?


---

## Re: Bollinger Bands Convergence Divergence Strategy

**albertparis** · Thu Dec 15, 2016 5:28 am

Code: [Select all](https://fxcodebase.com/code/)
`Hello
No,
Possibility of taking the ATRSL indicator for the calculation of the bollinger bands

http://www.fxcodebase.com/code/viewtopic.php?f=17&t=514&p=53891#p53891 

BOLLINGER BANDS CONVERGENCE DIVERGENCE + ATRSL

Calcul
Number of périods : 20
Number of standard  deviation : 2
Number of périods to smooth ATR : 20

This will make it possible to see the ranges

Thank you for your work`


---

## Re: Bollinger Bands Convergence Divergence Strategy

**Apprentice** · Fri Dec 16, 2016 5:23 am

U want to add BB indicator to indicator ATRSL?


---

## Re: Bollinger Bands Convergence Divergence Strategy

**albertparis** · Fri Dec 16, 2016 7:03 am

Code: [Select all](https://fxcodebase.com/code/)
`Hello
Band of Bollinger formula:

The upper bound which corresponds to a moving average of the volatility to which is added a standard deviation

The upper boundary: MM + x * Standard deviation

 The lower bound that corresponds to a moving average of the volatility to which one standard deviation is subtracted.

The lower bound: MM - x * Standard deviation

Can modify the calculation formula :

Take the ATRMSL calculation to build bollinger high and low bollinger bands

Thank you for your work`
