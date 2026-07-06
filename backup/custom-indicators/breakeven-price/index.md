# BREAKEVEN_PRICE

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=69123  
> Forum: 17 · Topic 69123 · 5 post(s)


---

## BREAKEVEN_PRICE

**Apprentice** · Wed Nov 13, 2019 2:05 pm

![NAS100 H1 (11-13-2019 1813).png](images/129731/NAS100%20H1%20%2811-13-2019%201813%29.png)



Will draw four lines.
1. Breakeven level for the Long positions
2. Breakeven level for the Short positions
3. Breakeven level for the All positions
4. Margin call level
(Simplified method, will only work on account with trades in one instrument.)
Will take into account Marker and Entry positions.

 [BREAKEVEN_PRICE.lua](files/129731/BREAKEVEN_PRICE.lua)


---

## Re: BREAKEVEN_PRICE

**Silverthorn** · Wed Sep 16, 2020 9:58 pm

Hi Apprentice. Could you please check this indicator for me. I believe it is plotting the Margin Liquidation line for long positions. (Plots the same long or short)


---

## Re: BREAKEVEN_PRICE

**Apprentice** · Thu Sep 17, 2020 2:08 am

Your request is added to the development list.
Development reference 2043.


---

## Re: BREAKEVEN_PRICE

**Apprentice** · Fri Sep 18, 2020 7:32 am

The margin call level can't be separated for long and short.
It's a level where all positions will be closed - long and short


---

## Re: BREAKEVEN_PRICE

**Silverthorn** · Sun Sep 20, 2020 8:54 pm

Hi Apprentice. I understand that but for a short position the Margin Liquidation line if plotted on the profit side of the entry position not on the loss side as it should be.
