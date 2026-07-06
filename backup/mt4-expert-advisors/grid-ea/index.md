# Grid_EA

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=70546  
> Forum: 38 · Topic 70546 · 3 post(s)


---

## Grid_EA

**Apprentice** · Mon Oct 19, 2020 5:50 am

Based on request.
[viewtopic.php?f=27&t=69688](https://fxcodebase.com/code/viewtopic.php?f=27&t=69688)

 [Grid_EA.mq4](files/138338/Grid_EA.mq4)


---

## Re: Grid_EA

**cuancux** · Thu Feb 23, 2023 10:56 am

Hello Admin Apprentice

Can you please make this Grid version

1) define "Median Price" => can be selected manual input or automatic by look back number of n candles HiLo/2 of certain timeframe (i.e HiLo of 90 candles of weekly/monthly timeframe)
2) only allow BUY on the price BELOW "Median Price"
4) only allow SELL on the price ABOVE "Median Price"
5) calculate grid step automatically by account balance & lot size
6) each grid has ultimate TP value, but equipped with trailing start, step & stop to enjoy the retracement
BUY trade TP ultimate value is Highest Candles of level stated on point (1)
SELL trade TP ultimate value is Lowest Candles of level stated on point (1)
7) any order closed automatic open new one with same price (pending order), lot and take profit

my presumable
a) market always retrace
b) EA need to make sure account safe by automatically calculate max trade & grid distance allowed based on balance
c) instead of expecting market follow our entry,
just let it floating minus & ride on it by put the opposite direction and individually take profit of each grid and repeat it.

5k++ capital 0.01 lot, gold
$10 grid step

2100 sell only
^^
^^
1830 sell only
1820 sell only
1810 sell only
1800 MEDIAN
1790 buy only
1780 buy only
1770 buy only
vv
vv
1500 buy only

thank you


---

## Re: Grid_EA

**Apprentice** · Tue Feb 28, 2023 4:18 am

We have added your request to the development list.
Development reference 193.
