# Bid Ask Median

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63487  
> Forum: 17 · Topic 63487 · 8 post(s)


---

## Bid Ask Median

**Apprentice** · Mon May 16, 2016 10:20 am

![EURUSD t1 (05-17-2016 1730).png](images/106294/EURUSD%20t1%20%2805-17-2016%201730%29.png)



Based on request.
[viewtopic.php?f=27&t=63486&p=106295#p106295](https://fxcodebase.com/code/viewtopic.php?f=27&t=63486&p=106295#p106295)
Median=(Bid + Ask)/2;

 [Bid Ask Median.lua](files/106294/Bid%20Ask%20Median.lua)


---

## Re: Bid Ask Median

**Cactus** · Tue May 17, 2016 10:48 am

Looks good thanks.
However on your screenshot chart it does not appear correctly, I think it should always fall in between the blue and pink line, and the green line on your screenshot doesn't?

Also, can I request for additional two things to this now.
I'd like it to behave like normal price, so it would be cool to add a horizontal line with price tag that follows the bid ask median line, just like normal price. And also a value in top right corner that tells the current value of the bid ask median line, accurate to every pip according to symbol please?


---

## Re: Bid Ask Median

**Apprentice** · Tue May 17, 2016 11:03 am

Fixed.


---

## Re: Bid Ask Median

**Cactus** · Tue May 17, 2016 11:08 am

Great. And actually those two requests aren't needed anymore. I managed to achieve the result I want by adding the non-lag-ma (3,0,1) on the bid ask median which is accurate in telling the price and also highlights the up/down movements cheers for your work

Also the price line, I added that using "axis label" indicator downloaded from this forum


---

## Re: Bid Ask Median

**Apprentice** · Mon Mar 05, 2018 10:54 am

The indicator was revised and updated.


---

## Re: Bid Ask Median

**lumanauw** · Sat Sep 28, 2019 10:21 am

Hi,

Could this MT4 indicator modified to LUA indicator? It is for counting bid ask (Iike inside one M15 candle) and draw line chart of it. Ask is pulling buy (up) while Bid is pulling down (sell)


---

## Re: Bid Ask Median

**Apprentice** · Sat Sep 28, 2019 3:27 pm

Your request is added to the development list.
Development reference 134.


---

## Re: Bid Ask Median

**lumanauw** · Sun Sep 29, 2019 4:44 am

Hi, Apprentice

I found the indicator, it is made by you
[viewtopic.php?f=17&t=61127&p=95834&hilit=tick+volume.lua#p95834](https://fxcodebase.com/code/viewtopic.php?f=17&t=61127&p=95834&hilit=tick+volume.lua#p95834)
I think the idea is the same
Could the display mode is linechart instead of histogram, and the data of the current bar is continuation from the previous bar ( line[0]=line[1]+current data ) ?

Thank you
