# Consensus of Five

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=27184  
> Forum: 17 · Topic 27184 · 22 post(s)

---

## Consensus of Five

**Apprentice** · Thu Nov 29, 2012 10:32 am

![Consensus of Five.png](images/47338/Consensus%20of%20Five.png)

This indication is obtained as Consensus of all selected (five) indicators.

green color:
1. cci > buy level
2. macd > buy level
3. adx > entry level and adx < exit level
4. dmi positive > dmi negative
5. stochastic k> stochastic d and d< ob level

red color:
1. cci < sell level
2. macd < sell level
3. adx > entry level and adx < exit level
4. dmi positive < dmi negative
5, stochastic k< d and d > os level

else
blue

 [Consensus of Five.lua](files/47338/Consensus%20of%20Five.lua)

 

![EURUSD D1 (03-11-2016 2034).png](images/47338/EURUSD%20D1%20%2803-11-2016%202034%29.png)

 [MTF MCP Consensus of Five.lua](files/47338/MTF%20MCP%20Consensus%20of%20Five.lua)

MT4 version is available here.
[viewtopic.php?f=38&t=61082&p=107618#p107618](http://www.fxcodebase.com/code/viewtopic.php?f=38&t=61082&p=107618#p107618)

---

## Re: Consensus of Five

**evgeniyn** · Fri Jan 11, 2013 7:45 am

Thank you for indicator. Could you please create strategy according to scenario - buy on start of green color and sell start of red color.

---

## Re: Consensus of Five

**Apprentice** · Fri Jan 11, 2013 8:29 am

Requested can be found here.
[viewtopic.php?f=31&t=29545](https://fxcodebase.com/code/viewtopic.php?f=31&t=29545)

---

## Re: Consensus of Five

**zoltanh** · Tue Aug 26, 2014 2:36 pm

hi,

i think the ADX was given the other way around for the signal of opening short deals - it still should be above 20 and below 40 as it was given for the long positions.

```lua
if ONE == nil   and  TWO == nil  and THREE_B == nil  and THREE_S == nil and FOUR_B== nil and FOUR_S== nil and FIVE_B== nil  and FIVE_S== nil  then
      open:setColor(period, instance.parameters.No);      
      elseif (ONE == true or ONE == nil) 
      and (TWO  == true  or TWO == nil) 
      and (THREE_B  == true  or THREE_B == nil)
      and (FOUR_B == true   or FOUR_B == nil) 
      and (FIVE_B == true   or FIVE_B == nil)
      then      
      open:setColor(period, instance.parameters.Up);
        elseif(ONE == false or ONE == nil)
      and  (TWO == true or TWO == nil)
      and (THREE_S == false or THREE_S == nil)   
      and (FOUR_S == false or FOUR_S == nil) 
      and (FIVE_S  == false or FIVE_S == nil) 
      then
      open:setColor(period, instance.parameters.Dn);
      else
```

---

## Re: Consensus of Five

**Apprentice** · Wed Aug 27, 2014 2:14 am

Fixed.
Please Re-Download.

---

## Re: Consensus of Five

**zoltanh** · Wed Aug 27, 2014 9:14 am

Thanks Apprentice!
Do you think this indicator could be combined with a pivot strategy?
I mean if a candle closes above a resistance/below a support level, it would open a long position if indicator shows green and go for short if the indicator shows red.
This would be a great help!

Thanks,
Zoltan

---

## Re: Consensus of Five

**jay1994** · Wed Aug 27, 2014 2:02 pm

Hi Apprentice, is there a MQ4L version of this indicator?

If not can one be made??

Thankss!

---

## Re: Consensus of Five

**Apprentice** · Thu Aug 28, 2014 5:22 am

Your request is added to the development list.

---

## Re: Consensus of Five

**Apprentice** · Thu Aug 28, 2014 12:17 pm

Requested can be found here.
[viewtopic.php?f=38&t=61082](https://fxcodebase.com/code/viewtopic.php?f=38&t=61082)

---

## Re: Consensus of Five

**Lnst3797** · Sun Dec 21, 2014 2:45 pm

EWO oscillator strategy works well in combination of Consensus of five indicator>

Would it be possible to add it to this Consensus of five Strategy.
buy when EWO crossover 0 line or bottom and consensus of five is green
sell when EWO crossunder 0 line or top and consensus of five is red

Thanks in advance

---

## Re: Consensus of Five

**Apprentice** · Tue Dec 23, 2014 3:23 am

Your request is added to the development list.

---

## Re: Consensus of Five

**superleo** · Fri Mar 11, 2016 10:58 am

hi apprendice ,

may i request a mtf mcp list consensus of five indicator.

upper arrow ; for up trend
down arrow: for down trend
blue dot; for neutral trend

if the indicator look is like mtf mcp alternative ichimoku it will be good
[viewtopic.php?f=17&t=63193](http://www.fxcodebase.com/code/viewtopic.php?f=17&t=63193)

---

## Re: Consensus of Five

**Apprentice** · Fri Mar 11, 2016 3:08 pm

MTF MCP Consensus of Five Added.

---

## Re: Consensus of Five

**Apprentice** · Sun Sep 23, 2018 7:13 am

The indicator was revised and updated.

---

## Re: Consensus of Five

**jonas_sp** · Sun Mar 01, 2020 2:32 am

Hello, I know this is an old post, but I liked this tool, you did a great job!
 I noticed that the first bar is always more accurate when we have direction bars (buy or sell) on chart.
 Is it possible to add arrows to Buy (send Buffer 0) and Sell (send buffer 1) to the first bar in their row? I mean, to buy/sell the first in the row, and then buy/sell the next signal again only after a grey bar.

 If it isn't possible, just to have the arrows to buy and sell with buffers would be awesome.
 I intent to donate money to support you guys if you can help with that.
 Thank you so much!

p.s. I have attached an image with the explanation, buy/sell arrow (with buffer) only on the first sinal of the row.

---

## Re: Consensus of Five

**Apprentice** · Sun Mar 01, 2020 4:02 pm

Your request is added to the development list.
Development reference 793.

---

## Re: Consensus of Five

**Apprentice** · Mon Mar 02, 2020 2:35 pm

![AUDJPY M1 (03-02-2020 1843).png](images/131636/AUDJPY%20M1%20%2803-02-2020%201843%29.png)

Try this version.

 [Consensus of Five.lua](files/131636/Consensus%20of%20Five.lua)

---

## Re: Consensus of Five

**jonas_sp** · Wed Mar 04, 2020 7:54 pm

Sorry, I only know how to open/compile .mql4 files... Can you please send as .mql4?
thanks so much!!

---

## Re: Consensus of Five

**jonas_sp** · Wed Mar 04, 2020 10:32 pm

Looking to the picture it seems like it's getting the alert to the second candle after the consensus, is this the best or only way to enter? I am saying because the first candle is more assertive, it would be great to anticipate that, but is looking good, thank you

---

## Re: Consensus of Five

**Apprentice** · Thu Mar 05, 2020 6:06 am

Your request is added to the development list.
Development reference 822.

---

## Re: Consensus of Five

**Apprentice** · Fri Mar 06, 2020 6:58 am

MT4/MQ4 version.
[viewtopic.php?f=38&t=69508](https://fxcodebase.com/code/viewtopic.php?f=38&t=69508)

---

## Re: Consensus of Five

**jonas_sp** · Fri Mar 06, 2020 2:18 pm

Thanks! What's the buffer to buy and sell? 0 and 1?
