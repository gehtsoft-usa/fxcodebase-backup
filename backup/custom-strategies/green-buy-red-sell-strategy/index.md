# Green Buy Red Sell Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=74255  
> Forum: 31 · Topic 74255 · 10 post(s)


---

## Green Buy Red Sell Strategy

**Apprentice** · Mon Oct 16, 2023 9:11 am

![EURUSD W1 (10-16-2023 1612).png](images/152932/EURUSD%20W1%20%2810-16-2023%201612%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.php?f=27&p=152341](https://fxcodebase.com/code/viewtopic.php?f=27&p=152341)

Open Long
Previous Candle is Up
Current Candle is greater than moving average

Exit Long
Close is under the previous candle low

Vice versa for Short

 [Green Buy Red Sell Strategy.lua](files/152932/Green%20Buy%20Red%20Sell%20Strategy.lua)


---

## Re: Green Buy Red Sell Strategy

**mangonel** · Tue Oct 17, 2023 2:45 pm

Apprentice, thank you for your hard work.

Can you please check the code because the strategy does not close the position at the end of each period and constantly opens new positions that do not close at the end of each turn, accumulating positions. This is probably my mistake if I didn't explain something clearly.

The general idea is to have one position at a time and to secure profits with a mandatory closing if the trade is going in my favor. All other parameters, such as Direct/Reverse, time frame, and moving averages, seem to be correct.


---

## Re: Green Buy Red Sell Strategy

**Apprentice** · Tue Oct 24, 2023 3:17 am

I can’t find any errors. It looks like it works as expected.

As it is will close the trade if the price crossunder/crossover the previous cradle low/high.
If you initial specification you have a classic stop, as well this algo.
The classic stop is placed at the X pips prom open level.

Currently, the trade will continue if the market moves in your direction,
do not crossunder/crossover the previous cradle low/high.

As I understand you want to close the trade at the end of the candle, regardless.


---

## Re: Green Buy Red Sell Strategy

**mangonel** · Wed Oct 25, 2023 2:17 pm

So, can we start all over again a Green Buy, Red Sell Version 2 (GBRS_V2) ? I think it's simple.

If one candle close green, at the next candle Enter Long at the open and mandatory close the Long position at the end of the period. So if the time frame set at Daily, if one candle ends Green, at the next candle Buy at the open, mandatory close the Long position at the end of the day. If the time frame set at 1 hour, if one candle end Green, at the next candle Buy at the open, mandatory close the Long position at the end of 1 hour. The Stop will set at the Low of the previous candle.
Vise versa for the short positions. If one candle end red, at the next candle Enter Short at the open and mandatory close the position at the end of this candle period. The Stop will set at the high of the previous candle.
As you see at the image, let's start the example with the cande 1.
The candle 1 end Green, so at the open of candle 2 Enter Long and mandatory close at the end of candle 2. The stop will be set at the low of candle 1 in case the trade goes bad. End of auction.
The candle 2 end Green, so at the open of candle 3 Enter Long and mandatory close the position at the end of the candle, the stop will be set at the low of candle 2 for this auction.
The candle 3 end Green, so at the open of candle 4 Enter Long and mandatory close the position at the end of candle 4, the stop for this auction will be set at the low of candle 3.
The candle 4 end Green so at the open of candle 5 Enter Long and mandatory close at the end of the period, the stop for this auction will be set at the Low of candle 4, which will be trigger and the trade ends with a loss.
The candle 5 end Red so at the open of the next candle Enter Short mandatory close at the end of the candle and the stop will be set at the high of candle 5.
....and the trades goes on the same way.

The general idea for this, is the probability that when you see an up or down day, it is probably that the next day will continue the run and you may probably catch a trend from the start, were you lock your profits, candle by candle. No complex indicators, no "heavy" equations,no nothing. Is it as simple as it hears. Day 1 up, set the stop at the low of day 1, buy at the open of day 2, close the position with a mandatory close at the end of day 2, end of story or Day 1 down, set the stop at the top of day 1, short the open of day 2, close the position with a mandatory close at the end of day 2, end of story.

Parameters
Price type : Bid,Ask
Time frame : m1,m5,m15,m30,H1,H2,H3,H4,H6,H8,D1,W1,M1
Allow strategy to trade : Yes,No
Trade ammount in lots : 1,2,3,4,.....
Type of signal : Direct/Reverse

If you can add a moving average filter like you did at version 1, it will be perfect


---

## Re: Green Buy Red Sell Strategy

**Apprentice** · Thu Oct 26, 2023 2:11 am

We have added your request to the development list.
Development reference 959


---

## Re: Green Buy Red Sell Strategy

**Apprentice** · Thu Oct 26, 2023 1:56 pm

Try this version.

 [Green_Buy_Red_Sell_Strategy.lua](files/153098/Green_Buy_Red_Sell_Strategy.lua)


---

## Re: Green Buy Red Sell Strategy

**mangonel** · Thu Oct 26, 2023 4:55 pm

I backtest the strategy. As you see at the image, the candle 1 ends Red, so the code performe well and at the open of candle 2 create a short position. So far, so good. Now the code must close the short position mandatory at the end of candle 2.(but the code didn't close the position).While the sort position for candle 2 are runing the stop for this trade is the high of candle 1.

As you see, because the candle 2 ends Red the candle 3 didn't crate any short potition.

The candle 3 ends Red, so the candle 4 must create a short position at his open (with stop at the high of candle 3) and mandatory close this short position when the candle ends at the end of his time frame.

The candle 4 ends Red, so at the open of candle 5 the code must crate a short position and mandatory close this short position at the end of his time frame.The stop for this auction will be set at the high of candle 4.

The candle 5 ends Red, so at the open of candle 6 must create a short position and this position will mandatory close at the end of his time frame. The stop for this trade will be set at the high of candle 5, which will be triger at this specific trade and will end with a loss.

The candle 6 ends Red, so at the open of candle 7 must create a short position and mandatory close this position at the end of his time frame. The stop for this trade will be set at the High of candle 6.

The candle 7 ends Red, so at the open of candle 8 must create a short position and mandatory close this short position at the ends of his time frame. The stop for this trade will be set at the top of candle 7, which will be triger at this specific trade and end with a loss.

The candle 8 ends Green, so at the open of candle 9 the code must create a Long position (who did it) and mandatory close this long position at the end of his time frame for candle 9 (that he didn't)

As you see at the image with the Green candles, the previous of candle 1 was Green. So at the open of candle 1, the code must open a Long position (who did it) and mandatory close this Long position at the ends of candle 1 time frame period (that he didn't).
The candle 1 ends Green, so at the open of candle 2 the code must open a Long position (that he didn't) and mandatory close this Long position at the end of his time period (that he didn't) The stop while the Long position of candle 2 is runing is the Low of candle 1.

Similar, as you see at the image with the Red candles, the previous of candle 1 was Red. So at the open of candle 1, the code must open a Short position (who did it) and mandatory close this Short position at the ends of candle 1 time frame period (that he didn't). The candle 1 ends Red, so at the open of candle 2 the code must open a Short position (that he didn't) and mandatory close this Short position at the end of his time period (that he didn't) The stop while the Short position of candle 2 is runing is the High of candle 1.

Once again, Day 1 up, set the stop at the low of day 1, buy at the open of day 2, close the position with a mandatory close at the end of day 2, end of story or Day 1 down, set the stop at the top of day 1, short the open of day 2, close the position with a mandatory close at the end of day 2, end of story.

It's candle treated separately. Like you are blind for the rest of the chart.
For daily charts goes like this :
A candle ends Green ? Buy at the next open, close position at the same day, at the close of the market.
A candle ends Red ? Short at the next open, close position at the same day, at the close of the market.

Parameters the same as version 1 with the filter of Moving Average will be very good


---

## Re: Green Buy Red Sell Strategy

**Apprentice** · Fri Oct 27, 2023 11:35 am

We have added your request to the development list.
Development reference 974


---

## Re: Green Buy Red Sell Strategy

**mangonel** · Tue Nov 21, 2023 5:38 pm

Apprentice, please keep me in mind when you have a moment. I firmly believe that with careful portfolio management, this endeavor can be successful.


---

## Re: Green Buy Red Sell Strategy

**mangonel** · Thu Dec 14, 2023 2:26 pm

Apprentice,

Apologies for the second post. I understand you're quite busy, and I appreciate your time and consideration. Would you be able to spare a moment to respond to my previous message or share any insights you might have? I'm eager to learn from your expertise.

Thank you for your time and patience.
