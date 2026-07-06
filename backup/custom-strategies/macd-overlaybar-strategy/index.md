# MACD OverlayBar Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=70424  
> Forum: 31 · Topic 70424 · 20 post(s)


---

## MACD OverlayBar Strategy

**Apprentice** · Fri Sep 11, 2020 3:45 am

![EURUSD m1 (09-11-2020 1041).png](images/137550/EURUSD%20m1%20%2809-11-2020%201041%29.png)



MACD Overlay.lua
[viewtopic.php?f=17&t=9806](https://fxcodebase.com/code/viewtopic.php?f=17&t=9806)

Open Long on Up in Up Trend
Open Short on Down in Down Trend

Exit (Optinal)
Close Long on Down in Up Trend
Close Short on Up in Down Trend

 [MACD OverlayBar Strategy.lua](files/137550/MACD%20OverlayBar%20Strategy.lua)

 [MACD OverlayBar Adaptable Strategy.lua](files/137550/MACD%20OverlayBar%20Adaptable%20Strategy.lua)


---

## Re: MACD OverlayBar Strategy

**chai88888** · Fri Sep 11, 2020 5:32 am

hi there i dont understand maybe am doing something wrong on the setting because it taking bunch of trades here a pic of my settings and the trades

thanks


---

## Re: MACD OverlayBar Strategy

**chai88888** · Tue Sep 15, 2020 2:22 am

my optional exit is false


---

## Re: MACD OverlayBar Strategy

**chai88888** · Fri Sep 18, 2020 1:49 am

can you share what settings did you use on the test above thanks


---

## Re: MACD OverlayBar Strategy

**Apprentice** · Fri Sep 18, 2020 3:00 am

I have used default parameters.


---

## Re: MACD OverlayBar Strategy

**chai88888** · Fri Sep 18, 2020 5:09 am

theres a delay on closing the trade its run 5 candles red before it closes. it not follow the color of the trade


---

## Re: MACD OverlayBar Strategy

**chai88888** · Fri Sep 18, 2020 5:12 am

from long to short there a delay in closing and taking trades

but short to long there no problem


---

## Re: MACD OverlayBar Strategy

**chai88888** · Fri Sep 18, 2020 5:16 am

dealy in closing from long to short


---

## Re: MACD OverlayBar Strategy

**Apprentice** · Mon Sep 21, 2020 11:37 am

Your request is added to the development list.
Development reference 2074.


---

## Re: MACD OverlayBar Strategy

**Apprentice** · Tue Sep 22, 2020 3:07 am

Try it now.


---

## Re: MACD OverlayBar Strategy

**chai88888** · Tue Sep 22, 2020 4:01 am

it will not open a long trade


---

## Re: MACD OverlayBar Strategy

**Apprentice** · Wed Sep 23, 2020 2:26 am

Your request is added to the development list.
Development reference 2090.


---

## Re: MACD OverlayBar Strategy

**Apprentice** · Thu Sep 24, 2020 2:48 am

Fixed.


---

## Re: MACD OverlayBar Strategy

**chai88888** · Sun Dec 06, 2020 8:23 pm

hi there can you make this strategy highly adaptable
you can choose on what to do

Up in Up Trend wheter to buy ,sell ,close ,or nothing
Down in Down Trend wheter to buy ,sell ,close ,or nothing
Down in Up Trend wheter to buy ,sell ,close ,or nothing
Up in Down Trend wheter to buy ,sell ,close ,or nothing

thanks


---

## Re: MACD OverlayBar Strategy

**chai88888** · Mon Dec 07, 2020 3:14 am

addition put a stop loss on the -1 candle on the highest high for sell and lowest blow for buy thabks


---

## Re: MACD OverlayBar Strategy

**Apprentice** · Tue Dec 08, 2020 3:09 pm

Your request is added to the development list.
Development reference 2427.


---

## Re: MACD OverlayBar Strategy

**Apprentice** · Thu Dec 10, 2020 8:16 am

MACD OverlayBar Adaptable Strategy.lua added.


---

## Re: MACD OverlayBar Strategy

**chai88888** · Thu Dec 10, 2020 5:57 pm

it only has two option

it should have 4 for:
**Up in Up Trend**= wheter to buy ,sell ,close ,or nothing
**Down in Down Trend**= wheter to buy ,sell ,close ,or nothing
**Down in Up Trend**= wheter to buy ,sell ,close ,or nothing
**Up in Down Trend**=wheter to buy ,sell ,close ,or nothing

thanks


---

## Re: MACD OverlayBar Strategy

**Apprentice** · Sat Dec 12, 2020 7:19 am

Your request is added to the development list.
Development reference 2452.


---

## Re: MACD OverlayBar Strategy

**Apprentice** · Sun Dec 13, 2020 2:36 pm

[MACD OverlayBar Adaptable Strategy.lua](files/139530/MACD%20OverlayBar%20Adaptable%20Strategy.lua)

Try this version.
