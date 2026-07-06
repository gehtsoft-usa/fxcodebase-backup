# Line Cross Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=20142  
> Forum: 31 · Topic 20142 · 23 post(s)


---

## Line Cross Strategy

**Apprentice** · Tue Jun 12, 2012 4:44 am

![Line Cross Strategy.png](images/35409/Line%20Cross%20Strategy.png)



With this strategy, you can define up to 4 lines.
And trading action, that the TS should take, on Cross Over / Under of this lines.

 [Line Cross Strategy.lua](files/35409/Line%20Cross%20Strategy.lua)

The Strategy was revised and updated on January 19, 2019.


---

## Re: Line Cross Strategy

**[email protected]** · Wed Jun 13, 2012 12:24 am

Thank you for your help.
Request on Cross Over / Under of this lines The multiplication of the number of automated trading For example:1*2*4*8*16....

The strategy has been set (strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100);)
If the first time to buy Amount 1.Close. Second new sell Amount Is the first to buy the number of times .The third Close after the The new opening is the second number 2 times.
This has been doubled continuous ....
How to set and the style of writing.
For example:Allow Trade Amount 1*2*4*8*16........

The petitions understanding the expression of my English is not good .
Thank you for your help.
Salute


---

## Re: Line Cross Strategy

**[email protected]** · Wed Jul 18, 2012 11:58 pm

Request the development of MP4 expert consultants?Thank.


---

## Re: Line Cross Strategy

**Knowledgeseekers** · Thu Jul 26, 2012 6:55 am

this is a very good instrument ,However, if each line is able to select different time frame would be more perfect!
I tried but can not be performed using two line cross strategy.
How do I overcome this situation!
thanks!


---

## Re: Line Cross Strategy

**[email protected]** · Thu Jul 26, 2012 10:46 am

I practice that pyramid. Training asc feasibility of high . I have been studying this content , but has not been answered . Time to prove everything . The direction of the trend is finally understood . Profitable extremely high . Please forgive my poor English . Lua programmer can e - mail I jointly argument .


---

## Re: Line Cross Strategy

**[email protected]** · Sun Aug 05, 2012 2:02 am

Hello , the administrator request to change this strategy .

I started the test .This is a good tool .Specified time to the specified entry point .As specified horizontal value daily 00:00:00 's closing price .

For example:TF:m1.Trading hours:daily Trading hours 20:30:00 closing price Offer value as a horizontal line .

dangsheng LI


---

## Re: Line Cross Strategy

**luigipg** · Wed Oct 10, 2012 11:06 am

Hi everyone, I would be happy if someone could add to this strategy the "magic number" so that it can run multiple times with the same currency pair. Can anyone do it? I believe it's that simple. Thanks to all also for your work. Luigi!!!


---

## Re: Line Cross Strategy

**Apprentice** · Wed Oct 10, 2012 11:25 am

Your request is added to the development list.


---

## Re: Line Cross Strategy

**123lundy** · Tue Dec 09, 2014 8:36 pm

Hello, Please add an action "cancel all orders this symbol". This is useful in so many ways. Please make sure it cancels all orders for that symbol even ones it didn't initiate, . I can use this as an assist for my manual trading... and also for orders placed by the strategy. much appreciated.

Also I'm wondering if the Buy and Sell are market orders and if so, does the settings in trade settings regarding the slippage amount in affect?

Great tool, thanks.


---

## Re: Line Cross Strategy

**MC. Trend Trader** · Mon Jun 27, 2016 7:47 am

Hi,

Is it possibble to add "Custom Identifier) to this Strategy?

Best Regards


---

## Re: Line Cross Strategy

**JOKER83** · Thu Jul 28, 2016 6:17 pm

can you make a Indicator for this strategy?


---

## Re: Line Cross Strategy

**Apprentice** · Mon Aug 08, 2016 6:28 am

I'm not sure why it would be opportune.
Can you explain.


---

## Re: Line Cross Strategy

**Apprentice** · Sat Dec 17, 2016 8:05 am

Strategy was revised and updated.


---

## Re: Line Cross Strategy

**MC. Trend Trader** · Mon Jan 02, 2017 12:38 am

Hi,

Can you change the strategy to automatically use 3 lines of high, low, and close of the last candle as a level?

Best Regards

MC Trend Trader


---

## Re: Line Cross Strategy

**Apprentice** · Sun Jan 08, 2017 6:24 am

high, low, and close of previous candle?


---

## Re: Line Cross Strategy

**MC. Trend Trader** · Sun Jan 08, 2017 7:58 am

Yes


---

## Re: Line Cross Strategy

**MC. Trend Trader** · Wed Jan 11, 2017 5:41 am

Hi,

Yes with high, low, and close of previous candle.

Please with new Strategy template.

Best Regards

MC. Trend Trader


---

## Re: Line Cross Strategy

**Apprentice** · Thu Jan 12, 2017 6:20 am

Try this version.
[viewtopic.php?f=31&t=64285](https://fxcodebase.com/code/viewtopic.php?f=31&t=64285)


---

## Re: Line Cross Strategy

**spinemaligna** · Wed Oct 21, 2020 10:42 am

Hi there,
I may be barking up the wrong tree but is it possible to include trend lines as well as S&R lines. If so then please take this as a request or does such a thing exist elsewhere.
Yours in anticipation
Ross


---

## Re: Line Cross Strategy

**Apprentice** · Thu Oct 22, 2020 2:02 am

trend lines as well as S&R?
Can you provide a bit more information?
How the trend line, S&R will be calculated?
Added to Line Cross Strategy?
Can you provide logic for it?


---

## Re: Line Cross Strategy

**spinemaligna** · Thu Oct 22, 2020 5:56 am

Apprentice,

Thanks for the prompt reply.
I would like to be able to draw a trend line and when price comes down to it (for a buy position) and retraces to a parallel line a set number of pips above it to open a position on either a cross or close above. The ability to add a stop order at or below a set number of pips below the original line and a risk %age of usable margin calculated position size is also required.
For example if using a pitchfork as a guide in a buy situation the first trendline would be the slope of the bottom median, the second line would be a set distance from the bottom median and the stop would be a set distance below the bottom median. To absolutely gild the lily a predetermined take profit line, again parallel to the slope would be fantastic.
Having written this down I expect it will need a new strategy so could you take this as an official request.

Many thanks


---

## Re: Line Cross Strategy

**Apprentice** · Fri Oct 23, 2020 6:05 am

Your request is added to the development list.
Development reference 2215.


---

## Re: Line Cross Strategy

**Apprentice** · Sun Oct 25, 2020 4:48 am

Try this version.
[viewtopic.php?f=17&t=70558&p=138437#p138437](https://fxcodebase.com/code/viewtopic.php?f=17&t=70558&p=138437#p138437)
