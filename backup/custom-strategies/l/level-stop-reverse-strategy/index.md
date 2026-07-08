# Level Stop Reverse Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=22850  
> Forum: 31 · Topic 22850 · 8 post(s)

---

## Level Stop Reverse Strategy

**Apprentice** · Fri Aug 31, 2012 4:37 am

![LRS Strategy.png](images/39423/LRS%20Strategy.png)

Buy
Crose / LSR CrossOver
Sell
Crose / LSR CrossUnder

 [LSR Strategy.lua](files/39423/LSR%20Strategy.lua)

For this strategy, you have to install Level Stop Reverse Indicator.
You can find it here.
[viewtopic.php?f=17&t=18031](https://fxcodebase.com/code/viewtopic.php?f=17&t=18031)

The Strategy was revised and updated on December 18, 2018.

---

## Re: Level Stop Reverse Strategy

**Silver23** · Mon Apr 04, 2016 11:00 am

Hi Apprentice,

Thank you for this strategy.First, could you please explain what the pip distance does? In other words what is its function? Secondly, it seems to ignore the sell signal given. I have changed the ATR period, multiplier, smoothed period and smoothed multiplier parameters. Could this be the cause? Third question, will it automatically close the first trade if opposite trade is initiated? The reason I'm asking is that I don't see " Close on opposite side" parameter. Nevertheless, it initiates the trade on the second candle after price crossed LSR nicely. Thank you for your previous responses.

---

## Re: Level Stop Reverse Strategy

**Apprentice** · Wed Apr 06, 2016 11:46 am

1.
Pip distance is used in Level Stop Reverse Indicator calculazion as Delta (in pips)

```lua
if  source.close[period] > LSR[period-1] then
LSR[period]=source.close[period]- Delta;
else
LSR[period]=source.close[period]+ Delta;
end
```

2.
As my tests show, with default settings Long and Short positions were opened.

3. Yes

---

## Re: Level Stop Reverse Strategy

**Apprentice** · Wed Apr 06, 2016 12:02 pm

Major Update.

---

## Re: Level Stop Reverse Strategy

**Silver23** · Mon Apr 11, 2016 6:58 am

Hi Apprentice,

Thank you for the answers provided. Thanks for the superb work done, it's a great indicator!

---

## Re: Level Stop Reverse Strategy

**taoyanzc** · Sun Jun 19, 2016 4:08 pm

Hello, thank you for your sharing. My English is not good, hope you can understand the meaning of the message below. "LSR STRATEGY" this strategy, I found that I can only run the default parameters, I modify the parameters after, does not take effect, is still in accordance with the default parameters. I want to know why. thank you！

---

## Re: Level Stop Reverse Strategy

**Apprentice** · Mon Jun 20, 2016 3:07 am

Fixed.

---

## Re: Level Stop Reverse Strategy

**Apprentice** · Sat Dec 17, 2016 8:51 am

Strategy was revised and updated.
