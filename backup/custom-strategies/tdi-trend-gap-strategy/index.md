# TDI TREND GAP STRATEGY

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=13522  
> Forum: 31 · Topic 13522 · 11 post(s)


---

## TDI TREND GAP STRATEGY

**Apprentice** · Fri Feb 17, 2012 4:14 am

![TradersDynamicIndex(Old).png](images/26200/TradersDynamicIndex%28Old%29.png)



Buy
 buff 4 cross over buff 5
 and buff 4 < buff 2
 and buff 5>buy level 50

Sell
buff 4 cross under buff5
and buff4> buff2
 and buff5 < sell level 50

Exit Buy
 buff 4 cross under buff 5
 or buff 4 cross under buy level 50
Exit Sell
 buff 4 cross over buff 5
or buff 4 cross over sell level 50

 [TDI Trend Gap Strategy Old.lua](files/26200/TDI%20Trend%20Gap%20Strategy%20Old.lua)

 [TDI Trend Gap Strategy.lua](files/26200/TDI%20Trend%20Gap%20Strategy.lua)

I wrote a strategy for both versions of the TDI indicator.
Depending on the version of the strategy you use, install adequate indicators.

Indicator can be found here.
[viewtopic.php?f=17&t=2069](https://fxcodebase.com/code/viewtopic.php?f=17&t=2069)

The Strategy was revised and updated on January 22, 2019.


---

## Re: TDI TREND GAP STRATEGY

**luigipg** · Fri Feb 17, 2012 6:25 am

Apprentice Hi, I'm sorry but this strategy is not really correct. Should be corrected in this way:

Buy
buff 4 cross over buff 2 and (optional) is or became > 50

Sell
buff 4 cross under buff 2 and (optional) is or became < 50

Exit Buy
buff 4 cross under buff 1 (if it had crossed before)
or cross under buff 5 or (optional) cross under level 50

Exit Sell
buff 4 cross over buff 3 (if it had crossed before)
or cross over buff 5 or (optional) cross over level 50

If you do it I would be very grateful. Thanks a lot! Luigi!!!


---

## Re: TDI TREND GAP STRATEGY

**Apprentice** · Sat Feb 18, 2012 4:20 am

With these changes it is a completely different strategy.
When I find time I will come back to this one.


---

## Re: TDI TREND GAP STRATEGY

**fundiza** · Sun Feb 26, 2012 11:04 am

Apprentice, thanks for the strategy.

I added some parameters to select the entry and exit points.
(I don't understand buff? so refer to the lines as below)

Using a (Green) RSI cross of (Red) Trade line

Entry Buy -
1) Cross anywhere
2) Cross below BL (Buy Level - typically 32)
3) Cross below CL (Centre Level - 50)

Entry Sell -
1) Cross anywhere
2) Cross above SL (Sell Level - typically 68)
3) Cross above CL (Centre Level - 50)

Exit Buy -
1) Cross anywhere
2) Cross above SL (Sell Level - typically 68)
3) Cross above CL (Centre Level - 50)

Exit Sell -
1) Cross anywhere
2) Cross below BL (Buy Level - typically 32)
3) Cross below CL (Centre Level - 50)

You can now select any of these entry and exit points to suit your strategy.

The stop and limit I tested on H1 but as I am not an experienced programmer,
I couldn't get stop and limit to work on D1


---

## Re: TDI TREND GAP STRATEGY

**Apprentice** · Tue Feb 28, 2012 6:24 am

I believe that you have a bug.
Lines 374, 375

It should be like this?
 ExitBuyGRXSL = instance.parameters.ExitBuyGRXSL;
 ExitSellGRXBL = instance.parameters.ExitSellGRXBL;


---

## Re: TDI TREND GAP STRATEGY

**Apprentice** · Sun Dec 04, 2016 8:34 am

Bump up.


---

## Re: TDI TREND GAP STRATEGY

**jaricarr** · Sun Jan 01, 2017 8:55 pm

Hi Apprentice,

In regards to the TDI Multi strategy, can you please add "Vidya" as a smoothing method for the RSI price line and and trade signal lines ?


---

## Re: TDI TREND GAP STRATEGY

**Apprentice** · Sun Jan 08, 2017 6:29 am

Added to TDI Trend Gap Strategy.lua


---

## Re: TDI TREND GAP STRATEGY

**jaricarr** · Sun Jan 08, 2017 5:09 pm

Great, can you also add it to the TDI-Multi.Lua please ?


---

## Re: TDI TREND GAP STRATEGY

**Apprentice** · Thu Jan 12, 2017 4:54 am

Added.


---

## Re: TDI TREND GAP STRATEGY

**Apprentice** · Sat Jan 06, 2018 8:39 am

The strategy was revised and updated.
