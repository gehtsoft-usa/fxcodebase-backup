# Overbought/Oversold Signal

> Source: https://fxcodebase.com/code/viewtopic.php?f=29&t=2998  
> Forum: 29 · Topic 2998 · 5 post(s)


---

## Overbought/Oversold Signal

**Apprentice** · Tue Dec 21, 2010 6:53 am

![Overbought Oversold.png](images/6904/Overbought%20Oversold.png)



The signal indicates when the market is located at the extreme overbought / oversold conditions,
When RSI is above / below the set Level,
Bar and is entirely above / below set EMA

There are two modes,
Single Signal and Signal Repetition

 [Overbought Oversold Signal.lua](files/6904/Overbought%20Oversold%20Signal.lua)


---

## Re: Overbought/Oversold Signal

**SuperTrader** · Tue Dec 17, 2013 8:04 am

Hi Apprentice This Signal (as it is now) triggers "Overbought" when (for example) RSI>70 AND BarClose>200 EMA (assuming we set values 70 for RSI and 200 for EMA) and "Oversold" when RSI<30 AND BarClose<200 EMA. That's absolutely **fine** and it is a pretty useful signal just as it is.

**BUT** I personally believe it would be even **more** useful if it gave "OB"/"OS" signals (with RSI>70/RSI<30) when Price is at the **"opposite side"** of the EMA (and I'll explain why): In other words if it gave "OB" when RSI>70 while BarClose**<200** EMA and "OS" when RSI<30 while BarClose**>200** EMA. This way a trader could take advantage of the counter-trend "pullbacks" in price, meaning **"buying bottoms in an uptrend"** OR **"selling tops in a downtrend"** (assuming a trend is "defined" by the 200-EMA or whatever EMA we set).

Please make this slight modification Apprentice, it would be simply **great** to have this new type of Signal, which will be a **"Pullbacks Hunter"** sort of thing. (I took a look at your LUA code, I believe it's a matter of "switching" the logic of a few "<" with ">", so hopefully it won't be too much trouble for you (I wish I had the time to sit down and learn LUA properly (starting from scratch), I'd really love to, I'll definitely do it in the near future). Thank you in advance for that.


---

## Re: Overbought/Oversold Signal

**Apprentice** · Wed Dec 18, 2013 3:19 pm

Try this modified version

 [Overbought Oversold Signal.lua](files/91596/Overbought%20Oversold%20Signal.lua)


---

## Re: Overbought/Oversold Signal

**zolz66** · Fri Jan 17, 2014 3:55 pm

Hello,

Can you think of any reason why this signal fails to send email alerts? My settings seem to be OK, and I get emails from other signals.

Thanks for checking this.


---

## Re: Overbought/Oversold Signal

**Apprentice** · Fri Jan 17, 2014 4:12 pm

Bug could be the reason.
Fixed.
