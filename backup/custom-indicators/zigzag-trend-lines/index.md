# ZigZag Trend Lines

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=70840  
> Forum: 17 · Topic 70840 · 11 post(s)


---

## ZigZag Trend Lines

**Apprentice** · Tue Jan 19, 2021 7:14 am

![EURUSD m5 (01-19-2021 1314).png](images/140283/EURUSD%20m5%20%2801-19-2021%201314%29.png)



Based on the request.
[viewtopic.php?f=27&t=70832](https://fxcodebase.com/code/viewtopic.php?f=27&t=70832)

 [ZigZag Trend Lines.lua](files/140283/ZigZag%20Trend%20Lines.lua)


---

## Re: ZigZag Trend Lines

**arfs9090** · Wed Jan 20, 2021 9:48 am

Hi Apprentice,
 Great Job and thanks for the quick turnaround found a few issues if this can be looked into

1.	Seems to not taking data from the request points as stated in the request on the this task
Point A is the 2nd candle b4 the high /low, and B &C is the 1st candle to closed past A
 The downswings have not been taken from the **ASK** price or upswings from the **BID** price

For new up zigzag printed use BID price
A= the close 2nd seller’s candle b4 zigzag on BID price
B= the open 1st buyer’s after zigzag closed above point A
C= the close 1st buyer’s after zigzag closed above point A

For new down zigzag printed use ASK price
A= the close of 2nd buyer’s candle b4 zigzag on ASK price
B= the open of 1st seller’s after zigzag closed below point A
C= the close 1st seller’s after zigzag closed below point A

2.	Like the idea you have incorporated when structure is broken then that candle data is used,
The breakout data to be on end of turn
3.	Still need to show the historical data as well please as in the original request
4.	Need colour and line option for the upswing and downswings Breakout and historical.
The line extension to continue with the line not change back to dash as can get confusing
5.	When use the number if that can use number of last swings when put on 4 would expect to show last 4 swing this is not what it shows
6.	Show the last would have option to show 4 upswings /downswings show last 2 breakouts and show last 4 historical have individual show last
7.	The lower time frames seem to work ok but seems to be a glitch when changing from bid to ask and also randomly will delete indicator data, have to go into indicator setting and apply again tends to happen on 1min wen new patterns happening quickly

Thanks
Arfs


---

## Re: ZigZag Trend Lines

**Apprentice** · Thu Jan 21, 2021 3:05 pm

Your request is added to the development list.
Development reference 106.


---

## Re: ZigZag Trend Lines

**Apprentice** · Mon Jan 25, 2021 4:54 am

Can you show the difference between 2nd seller’s candle and 2nd buyer’s candle on example?
Now it is coded as 2nd candle before zig zag.
All these addons complicate coding.


---

## Re: ZigZag Trend Lines

**arfs9090** · Tue Jan 26, 2021 8:51 am

Hi Apprentice & Team
The conditions were outlined in the first post request my bad for not showing the upswing and downswing screenshots. It is still the 2nd candle b4 the swing high or low just depends if zigzag is printed upswing or downswing and the sorry forgot to add line and colour options to define if historical current or the new breakout what you have incorporated, below are the conditions for both upswing and downswings have attached both upswing and downswing screenshot

For new up zigzag printed use BID price
A= the close 2nd seller’s candle b4 zigzag on BID price
B= the open 1st buyer’s after zigzag closed above point A
C= the close 1st buyer’s after zigzag closed above point A

For new down zigzag printed use ASK price
A= the close of 2nd buyer’s candle b4 zigzag on ASK price
B= the open of 1st seller’s after zigzag closed below point A
C= the close 1st seller’s after zigzag closed below point A

Thanks in adavance
Arfs

 

![ASK ZZ trend lines.jpeg](images/140361/ASK%20ZZ%20trend%20lines.jpeg)



 

![BID ZZ trendline.jpeg](images/140361/BID%20ZZ%20trendline.jpeg)


---

## Re: ZigZag Trend Lines

**Apprentice** · Wed Jan 27, 2021 3:23 am

seller’s candle is down candle?
2nd seller’s candle is the second down candle before the zigzag top.


---

## Re: ZigZag Trend Lines

**arfs9090** · Wed Jan 27, 2021 7:05 am

> **Apprentice wrote:**
> seller’s candle is down candle?
> 2nd seller’s candle is the second down candle before the zigzag top.

Hi Apprentice
The screenshot of the historical light line not the best example as only a 3 candle swing,

On downswing A = buyers candle close B & C = sellers candle open /close
On upswing A = sellers candle close B & C = buyers candle open /close

For new printed upswing use BID price A is 2nd Sellers candle b4 the low of zigzag B is the open of 1st buyers candle to close above A and C is the close of the1st candle that closed above A

For new printed downswing use ASK price A is 2nd Buyers candle b4 the high of zigzag B is the open of 1st sellers candle to close below A and C is the close of the 1st candle that closed below A

Thanks hope this clarifies
Arfs


---

## Re: ZigZag Trend Lines

**arfs9090** · Tue Feb 16, 2021 3:40 am

HI Apprentice,
Has there been any update on the task?
Arfs


---

## Re: ZigZag Trend Lines

**Apprentice** · Fri May 07, 2021 4:35 am

I don't understand how it is related to ZigZag Trend Lines.lua


---

## Re: ZigZag Trend Lines

**arfs9090** · Thu May 27, 2021 5:53 am

> **Apprentice wrote:**
> I don't understand how it is related to ZigZag Trend Lines.lua

Hi Apprentice ,
The references of A,B and C is to show where the data is taken from to draw the Zigzag trend lines as they vary from the upswing to the down swings and uses the buyers and sellers candles vary if the start of a potential reversal
On downswing A = buyers candle close B & C = sellers candle open /close
On upswing A = sellers candle close B & C = buyers candle open /close

For new printed upswing use BID price A is 2nd Sellers candle b4 the low of zigzag B is the open of 1st buyers candle to close above A and C is the close of the1st candle that closed above A

For new printed downswing use ASK price A is 2nd Buyers candle b4 the high of zigzag B is the open of 1st sellers candle to close below A and C is the close of the 1st candle that closed below A
hope you understand the request
Arfs


---

## Re: ZigZag Trend Lines

**Apprentice** · Sun May 30, 2021 7:09 am

Your request is added to the development list.
Development reference 539.
