# X-RSIOMA Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=70738  
> Forum: 31 · Topic 70738 · 18 post(s)


---

## X-RSIOMA Strategy

**Apprentice** · Sun Dec 20, 2020 9:23 am

![EURUSD m5 (12-20-2020 1528).png](images/139700/EURUSD%20m5%20%2812-20-2020%201528%29.png)



BUY
RSI crosses above MA buy signal
SELL
RSI crosses below MA sell signal

 [X-RSIOMA.lua](files/139700/X-RSIOMA.lua)

X-RSIOMA Strategy

 [X-RSIOMA Strategy.lua](files/139700/X-RSIOMA%20Strategy.lua)


---

## Re: X-RSIOMA Strategy

**arfs9090** · Sun Sep 12, 2021 8:08 am

HI Apprentice
Can you make some adjustments to the strategy and also recode the indicator to print the overbought level, oversold level and mid-level on the oscillator

**Request 1**

To ONLY take signal on the following conditions
**LONG =**When RSI has been in oversold area and crossed above the oversold level and RSI crossed above MA enter long
**LONG =** ONLY if the previous crossover had come from the oversold area, and RSI crossed above the MA and above or crossed above the mid-level 50% prior the signal then enter long and is the 1st crossover prior the one from the oversold area
**SHORT =** When RSI has been in overbought area and crossed below the overbought level and RSI crossed below MA enter short
**SHORT=** ONLY if the previous crossover had come from the overbought area, and RSI crossed below MA and below or crossed below the mid-level 50% prior the signal then enter short and is the 1st crossover prior the one from the overbought area

**Request 2**
Can you re code the X-RSIOMA indicator to print the horizontal overbought level /oversold level and a mid-level on the oscillator
To have line and colour options for all 3 levels and be able to adjust in parameters settings
Thanks in advance
Arf


---

## Re: X-RSIOMA Strategy

**Apprentice** · Mon Sep 13, 2021 11:43 am

Your request is added to the development list.
Development reference 819.


---

## Re: X-RSIOMA Strategy

**arfs9090** · Wed Sep 15, 2021 11:50 pm

Hi Apprentice
thanks ob/ os levels are great, can you add the 50% mid level line and also add line and colour options to all 3 levels
thanks Arfs


---

## Re: X-RSIOMA Strategy

**arfs9090** · Fri Sep 17, 2021 1:21 am

Hi Apprentice ,
thanks for adding the 50% mid level sorry to be a pain the levels are the same colour as my charts so u dont see the levels can you either add line and colour option or 0B @ 80 in red 0S @ 20 in blue and mid 50% in white dotted line please
thanks
Arfs


---

## Re: X-RSIOMA Strategy

**Apprentice** · Fri Sep 17, 2021 8:37 am

[X-RSIOMA.lua](files/143643/X-RSIOMA.lua)

Try it now.


---

## Re: X-RSIOMA Strategy

**arfs9090** · Sat Sep 18, 2021 2:13 am

Hi Apprentice ,
thanks looks great 1 last thing can you add averages with alerts as option to use for the RSI so when crosses ma changes colour
Thanks
Arfs


---

## Re: X-RSIOMA Strategy

**Apprentice** · Sun Sep 19, 2021 5:04 am

Your request is added to the development list.
Development reference 849.


---

## Re: X-RSIOMA Strategy

**Apprentice** · Mon Sep 20, 2021 8:51 am

I don't understand what need to be done. What line need to change color?
With what line we should compare that MA?

Can you show this on an example?


---

## Re: X-RSIOMA Strategy

**arfs9090** · Tue Sep 21, 2021 12:04 am

HI Apprentice
Averages ma with alert to replace the current rsi line so when rsi crosses the ma will change colour. averages ma to have all ma selections in options
Thanks
Arf

 

![av erages ma on rsi.jpeg](images/143686/av%20erages%20ma%20on%20rsi.jpeg)


---

## Re: X-RSIOMA Strategy

**Apprentice** · Wed Sep 22, 2021 3:52 am

[X-RSIOMA.lua](files/143704/X-RSIOMA.lua)

Try this version.


---

## Re: X-RSIOMA Strategy

**minifire18** · Wed Oct 13, 2021 2:43 am

TSV & X-RSIOMA zero line cross

Hey Apprentice & team

Can you do a strategy using the X-RSIOMA and Time Segmented Volume using the Zero Line histogram, when both indicators just crossed above zero line enter long and when both indicators just crossed below zero line enter short
Thanks in advance
Minifire


---

## Re: X-RSIOMA Strategy

**Apprentice** · Sat Oct 16, 2021 5:36 am

Your request is added to the development list.
Development reference 917.


---

## Re: X-RSIOMA Strategy

**Apprentice** · Sat Oct 16, 2021 6:12 am

Try this version.
[https://fxcodebase.com/code/viewtopic.php?f=31&t=71577](https://fxcodebase.com/code/viewtopic.php?f=31&t=71577)


---

## Re: X-RSIOMA Strategy

**Kelly123** · Tue Oct 26, 2021 1:25 am

hey guys

Can you add lwma to filter trend direction to X-RSIOMA.lua strategy
For Buys to be above lwma on price chart and RSI to cross MA at oversold
For Sells to be below lwma on price chart and RSI to cross MA at overbought
Thanks K


---

## Re: X-RSIOMA Strategy

**Apprentice** · Tue Oct 26, 2021 4:04 am

Your request is added to the development list.
Development reference 932.


---

## Re: X-RSIOMA Strategy

**Apprentice** · Wed Oct 27, 2021 10:53 am

[X-RSIOMA.lua](files/144056/X-RSIOMA.lua)

Try this version.


---

## Re: X-RSIOMA Strategy

**Kelly123** · Thu Oct 28, 2021 11:33 pm

Hey Apprentice & Team,
Works fine but the request was for the X-RSIOMA Strategy if you add to strategy
thanks K
