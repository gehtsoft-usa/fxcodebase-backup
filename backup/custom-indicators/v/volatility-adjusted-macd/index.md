# volatility adjusted - macd

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=69389  
> Forum: 17 · Topic 69389 · 4 post(s)


---

## volatility adjusted - macd

**Apprentice** · Thu Feb 06, 2020 8:56 am

![EURUSD H1 (02-06-2020 1304).png](images/131132/EURUSD%20H1%20%2802-06-2020%201304%29.png)



Based on request.
[viewtopic.php?f=27&t=69381](https://fxcodebase.com/code/viewtopic.php?f=27&t=69381)

 [volatility adjusted - macd.lua](files/131132/volatility%20adjusted%20-%20macd.lua)


---

## Re: volatility adjusted - macd

**bartwas1** · Tue Feb 11, 2020 9:07 am

Hi Apprentice

Thanks for this oscillator. Really appreciate your work.
I have a question in regards to this macd. Why do I get different results when I compare meta trader 4's version with yours - the settings are exactly the same - (tested against bid and ask price)? I've checked GBPUSD and EURUSD on 15m and 30m time frames. And it seems like marketscope's version is lagging.
If you find time do you mind to have look into it?

Bart


---

## Re: volatility adjusted - macd

**Apprentice** · Wed Feb 12, 2020 1:23 pm

Can you provide the charts, info about time frames and currency used.


---

## Re: volatility adjusted - macd

**bartwas1** · Tue Feb 25, 2020 6:59 am

Hi Apprentice

There is no point in uploading any charts. I will explain why. I did my due diligence and checked EURUSD and GBPUSD charts across three time frames 5, 15 and 30m. There were differences between metatrader's 4 and trading station. Then I looked into built-in MACD oscillators - and noticed the same thing.
When I mentioned that there was a problem with volatility adjusted MACD I just assumed that MT4 and TS will calculate price identically. Now when I've seen differences in built-in oscillators I believe price calculation will be close match, but not identical.

kind regards B.
