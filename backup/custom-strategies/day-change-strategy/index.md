# Day Change Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=17969  
> Forum: 31 · Topic 17969 · 14 post(s)


---

## Day Change Strategy

**Apprentice** · Tue May 08, 2012 10:57 am

![Day Change Strategy.png](images/32520/Day%20Change%20Strategy.png)



Buy
Indicator / (+)Level CrossOver
Sell
Indicator / (-)Level CrossOver

If Filter is On
Buy
Indicator / (+)Level CrossOver
Price > MA
Sell
Indicator / (-)Level CrossOver
Price < MA

 [Day Change Strategy.lua](files/32520/Day%20Change%20Strategy.lua)

Please install the Day_Change indicator.
[viewtopic.php?f=17&t=883](https://fxcodebase.com/code/viewtopic.php?f=17&t=883)

The Strategy was revised and updated on January 19, 2019.


---

## Re: Day Change Strategy

**Coondawg71** · Wed Feb 13, 2013 5:43 pm

Thanks for the revision of the Day Change indicator. Looks great.

Can we please request a version of the Day Change Strategy which will offer audible alerts upon crossing of selected levels which are offered within trading parameters by toggling ON or OFF.

Alerts would sound at the levels already implemented by the Day Change Indicator.

The idea is this: once a pair has crossed over level +.25 a trader can consider the pair has committed itself to going higher and open a position Long and could manage the position once the price has touched or closed at a particular level such as +1.00 Percent (vice versa applies of course in the opposite direction) or scale in additional lots upon each crossing.

thanks,

sjc


---

## Re: Day Change Strategy

**Apprentice** · Thu Feb 14, 2013 4:06 am

I'm not sure if I understand you.
You want alerts only, or a combination of both.
Strategy can already give Alert only.
Simply set trading permission to No.


---

## Re: Day Change Strategy

**ddrrbb** · Sun Jun 16, 2013 11:38 am

As mentioned above, is it possible to change the buy/sell level for this strategy from "crossing the zero line" to a certain percent change? For example, BUY when percent change is .25, SELL when percent change is -.25. Also, have option to set limit orders at certain percent levels (close position at +/- 1.0%, or trailing stop of .10%


---

## Re: Day Change Strategy

**Apprentice** · Mon Jun 17, 2013 5:35 am

Your request is added to the developmental list.


---

## Re: Day Change Strategy

**CHECEZAR** · Wed Dec 03, 2014 12:32 pm

> **Apprentice wrote:**
> Your request is added to the developmental list.

It would also be great if you could include a filter such as moving averages, which can be EMA or MVA, etc. Where signals are given if the sales price is below the EMA and that buying over the EMA. I join the request also ddrrbb. I think it would be very useful to include these features also.


---

## Re: Day Change Strategy

**Apprentice** · Thu Dec 04, 2014 4:21 am

MA Filter Added.


---

## Re: Day Change Strategy

**CHECEZAR** · Mon Dec 15, 2014 1:52 pm

> **Apprentice wrote:**
> MA Filter Added.

Hello, thank you very much for the filter.
But it does not work or I'm programming it wrong.
Might you please show me how to adjust the filter and in that time frame works best?


---

## Re: Day Change Strategy

**Apprentice** · Thu Dec 18, 2014 4:03 am

If ON.
It will only allow
Long Trades if Price is above the moving average.
Short Trades if Price is below the moving average.

Try to use Backtester / strategy optimizer to find the best settings.


---

## Re: Day Change Strategy

**CHECEZAR** · Sun Dec 21, 2014 9:45 am

> **Apprentice wrote:**
> If ON.
> It will only allow
> Long Trades if Price is above the moving average.
> Short Trades if Price is below the moving average.
>
> Try to use Backtester / strategy optimizer to find the best settings.

Hello Aprenticce.

Well let me tell you that I did everything you told me and the truth is it is not working.

Strategy started working on the same timeframes one with the filter and the other without the filter, and the signals were exactly alike.

I think it is better that the signal goes out only if the candle that is forming truly closes below the moving average if it is for selling and above the moving average if it is for buying.

Please can you make this to work that way in the the strategy. Thanks a lot for all your effort and your work, I am very thankful


---

## Re: Day Change Strategy

**CHECEZAR** · Wed Jan 14, 2015 8:55 am

Hello Apprentice.

I would like to know please if you managed to make the suggested changes.

I think it is better that the signal goes out only if the candle that is forming truly closes below the moving average if it is for selling and above the moving average if it is for buying.

Thanks a lot for all and your work, I am very thankful

> **Apprentice wrote:**
> If ON.
> It will only allow
> Long Trades if Price is above the moving average.
> Short Trades if Price is below the moving average.
>
> Try to use Backtester / strategy optimizer to find the best settings.


---

## Re: Day Change Strategy

**Apprentice** · Sun Dec 11, 2016 1:43 pm

Strategy was revised and updated.


---

## Re: Day Change Strategy

**daniel.herrera** · Tue Jan 17, 2017 2:41 pm

Hi Apprentice. How can I calculate and get the value of the opening price of the 1-day sailing in the strategy?

Thank you very much for your efforts and your response.


---

## Re: Day Change Strategy

**daniel.herrera** · Tue Jan 17, 2017 3:07 pm

Hi Learning. How can I calculate and get the value of the opening price of the 1-day sailing in the strategy?

Thank you very much for your efforts and your response.
