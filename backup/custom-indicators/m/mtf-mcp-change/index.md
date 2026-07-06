# MTF MCP Change

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=59338  
> Forum: 17 · Topic 59338 · 19 post(s)


---

## MTF MCP Change

**Apprentice** · Wed Aug 28, 2013 6:41 am

![MTF MCP Change.png](images/88978/MTF%20MCP%20Change.png)



The indicator will show Change
as Absolute or Relative Change
Change / ATR Ratio
Change / Standard Deviation Ratio
Average Candle for Average Period

for all the selected time frames and all available currency pairs.

 [MTF MCP Change.lua](files/88978/MTF%20MCP%20Change.lua)

 

![MTF MCP Change Heat Map.png](images/88978/MTF%20MCP%20Change%20Heat%20Map.png)



 [MTF MCP Change Heat Map.lua](files/88978/MTF%20MCP%20Change%20Heat%20Map.lua)

 

![XAUUSD H1 (03-18-2024 1205).png](images/88978/XAUUSD%20H1%20%2803-18-2024%201205%29.png)



 [MTF MCP MI Change Heat Map.lua](files/88978/MTF%20MCP%20MI%20Change%20Heat%20Map.lua)


---

## Re: MTF MCP Change

**speakinmymind** · Wed Aug 28, 2013 7:00 pm

Can you please create a moving average based off of this?


---

## Re: MTF MCP Change

**Apprentice** · Thu Aug 29, 2013 1:33 am

Can you give more details in your request.
Manner of presentation, Line or list.
As you know I use a number of different algorithms.
Moving average of which data set.


---

## Re: MTF MCP Change

**speakinmymind** · Thu Aug 29, 2013 7:22 am

The data used would be the distance from last close, that data stream displayed as a MVA line.

The idea is to capture the average candle size in MVA format


---

## Re: MTF MCP Change

**Apprentice** · Fri Aug 30, 2013 3:55 am

Your request is added to the development list.


---

## Re: MTF MCP Change

**Apprentice** · Fri Aug 30, 2013 4:18 am

Average candle algorithm added.


---

## Re: MTF MCP Change

**speakinmymind** · Fri Aug 30, 2013 9:23 am

Thank you for the data stream of average candle. Could you please create a moving average off this in order to retain past data and for trending purposes? Thanks.


---

## Re: MTF MCP Change

**Apprentice** · Fri Oct 04, 2013 5:24 am

Update


---

## Re: MTF MCP Change

**speakinmymind** · Tue Feb 04, 2014 9:22 am

Can you please update this so that the color of the data is a range (grean to red) red for the lowest value and green for the highest value.

Instead of color change being reflected as changes relevant to last data, could you please make it based off of the other currency pairs listed in the same timeframe?

The theory is to create a heat map, telling you which currency pairs are going through the most extreme change for each time frame, Thanks!


---

## Re: MTF MCP Change

**speakinmymind** · Tue Feb 04, 2014 1:00 pm

This is another heat map that I am hoping for.

Can you create this?

This is using negative numbers to shade red and positive to shade green, zero would shade grey.


---

## Re: MTF MCP Change

**Apprentice** · Thu Feb 06, 2014 3:26 am

Your request is added to the development list.


---

## Re: MTF MCP Change

**Apprentice** · Mon Feb 10, 2014 4:17 am

MTF MCP Change Heat Map Added.


---

## Re: MTF MCP Change

**speakinmymind** · Mon Feb 10, 2014 2:39 pm

I'm sorry but I was not trying to ask for a heat map for suggested entry points.

What I was envisioning was a heat map similar to stock heat maps ([http://finviz.com/map.ashx](http://finviz.com/map.ashx)).

The objective is to create a map that has all currency pairs and all time frames listed.

This will create a bunch of boxes for data output

Then, based off color, one could quickly spot the most active /profitable currency pairs.

The color would be based off the original MTF MCP Change formulas (I prefer Average Candle).

If a number is higher than its previous value it should be light green, and if it is less it should be light red.

***What I have described is basically what the MTF MCP Change already does, I am asking that instead of the numbers changing color, each number be put in a box that changes color. This will make the data easier to read a a glance.

*****As a bonus, if the box is already green, and the number increases more, that box should shade darker green. If it is already red, and it decreases, that box should shade darker red. Also, I would prefer the numerical data to still be inside the boxes, however it should be able to be turned off.

Thanks!!


---

## Re: MTF MCP Change

**speakinmymind** · Mon Feb 10, 2014 3:31 pm

Can you create a simple strategy off the heat map you created?

When say 5m, 15m, and 1h all are green, enter long. When all are red enter short.

The user should be able to select how many timeframes are relevant, and which timeframes are relevant.

Thanks.


---

## Re: MTF MCP Change

**Apprentice** · Tue Feb 11, 2014 3:28 am

Your request is added to the development list.


---

## Re: MTF MCP Change

**Apprentice** · Fri Apr 13, 2018 9:19 am

The indicator was revised and updated.


---

## Re: MTF MCP Change

**speakinmymind** · Sat Mar 16, 2024 9:41 am

Would it be possible to make this heat map to work with any indicator?


---

## Re: MTF MCP Change

**Apprentice** · Sat Mar 16, 2024 9:46 am

We have added your request to the development list.
Development reference 223


---

## Re: MTF MCP Change

**Apprentice** · Mon Mar 18, 2024 6:07 am

MTF MCP MI Change Heat Map.lua added.
