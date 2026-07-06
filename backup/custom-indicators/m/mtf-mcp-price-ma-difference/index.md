# MTF MCP Price MA Difference

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=37544  
> Forum: 17 · Topic 37544 · 10 post(s)


---

## MTF MCP Price MA Difference

**Apprentice** · Mon May 13, 2013 6:22 am

![MTF MCP Price MA Difference.png](images/62427/MTF%20MCP%20Price%20MA%20Difference.png)



The indicator will show the difference between the moving average and closing prices.
The value can be displayed as Pip or absolute value.
Color indicates that the difference is reduced (red) or increase (green).

 [MTF MCP Price MA Difference.lua](files/62427/MTF%20MCP%20Price%20MA%20Difference.lua)

MT4/Mq4 version.
[viewtopic.php?f=38&t=64777](https://fxcodebase.com/code/viewtopic.php?f=38&t=64777)


---

## Re: MTF MCP Price MA Difference

**Fx4mt.com** · Mon May 13, 2013 8:37 am

Thank you Apprentice, excellent work. I truly appreciate this


---

## Re: MTF MCP Price MA Difference

**jgras002** · Mon May 13, 2013 8:45 am

This is great! Thank you very much for doing this!


---

## Re: MTF MCP Price MA Difference

**Fx4mt.com** · Thu May 16, 2013 9:59 am

Upon further review, it does not appear that this indicator is calculating correctly. Not entirely sure what the data is being populated. Perhaps the averages are getting confused by different time frames? I've attached a screenshot of the erroneous values using 34 EMA.

Hoping for current Daily Price - Daily EMA Close, current 4h price - 4h EMA close, current 1h price - 1h EMA Close etc. The overall indicator layout is great, just hoping to get those values corrected.
Again I really appreciate your work on this, it's helping me greatly.

 Almost every indicator I use has been one of your designs and I am very, very grateful


---

## Re: MTF MCP Price MA Difference

**Fx4mt.com** · Thu May 16, 2013 10:12 am

Upon further examination I think I found my issue. Price is calculated off the current Daily Candle close? Would it be possible to do it off current price? i.e Current Price - Current Daily EMA Close etc?


---

## Re: MTF MCP Price MA Difference

**Apprentice** · Fri May 17, 2013 3:02 am

Current Daily Candle close and current price, will have same value?!


---

## Re: MTF MCP Price MA Difference

**Fx4mt.com** · Fri May 17, 2013 8:23 am

My apologies I made that a bit confusing. Just looking for current price - daily EMA, current price - 4h EMA etc. I confused things when I said time frames price. Only looking to use the current price, not the closing price. Greatly appreciated.


---

## Re: MTF MCP Price MA Difference

**speakinmymind** · Mon Jun 03, 2013 11:40 pm

Could you please convert the numerical values to pips for each pair? That would be very useful


---

## Re: MTF MCP Price MA Difference

**speakinmymind** · Tue Jun 04, 2013 9:56 pm

> **speakinmymind wrote:**
> Could you please convert the numerical values to pips for each pair? That would be very useful

I apologize, I didn't read the post before I posted... opps


---

## Re: MTF MCP Price MA Difference

**Apprentice** · Thu May 03, 2018 4:05 pm

The indicator was revised and updated.
