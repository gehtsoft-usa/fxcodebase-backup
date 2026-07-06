# Spread Oscillator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=36328  
> Forum: 17 · Topic 36328 · 18 post(s)


---

## Spread Oscillator

**Apprentice** · Fri May 03, 2013 4:14 am

![Spread Oscillator.png](images/60970/Spread%20Oscillator.png)



Ratio = (First Instrument / Second Instrument)*100
Spread Oscillator = Long MA of Ratio - Short MA of Ratio

 [Spread Oscillator.lua](files/60970/Spread%20Oscillator.lua)

 [Spread Oscillator with Normalization.lua](files/60970/Spread%20Oscillator%20with%20Normalization.lua)

MT4/Mq4 version.
[viewtopic.php?f=38&t=64942&p=113699#p113699](https://fxcodebase.com/code/viewtopic.php?f=38&t=64942&p=113699#p113699)


---

## Re: Spread Oscillator

**Apprentice** · Tue May 07, 2013 5:00 am

Zero line Added.


---

## Re: Spread Oscillator

**Jeffreyvnlk** · Tue May 07, 2013 7:13 am

> **Apprentice wrote:**
> Zero line Added.

Thanks


---

## Normalization

**Jeffreyvnlk** · Thu May 23, 2013 3:55 pm

Is there a way for normalization this Spread Oscilator for 3 year ? Like constructing of COT index
Subtracting by exponential moving averages is appreciated


---

## Re: Spread Oscillator

**Apprentice** · Fri May 24, 2013 3:31 am

Normalization algorithm is as follows.
Subtract exponential moving of spread from the spread?


---

## Re: Spread Oscillator

**Jeffreyvnlk** · Wed May 29, 2013 12:49 pm

> **Apprentice wrote:**
> Normalization algorithm is as follows.
> Subtract exponential moving of spread from the spread?

Thank
Spread Oscillator = Long EMA of Ratio - Short EMA of Ratio


---

## Re: Spread Oscillator

**Jeffreyvnlk** · Wed May 29, 2013 12:54 pm

Just like an orginal request, using EMA appreciated. And adding Zero line , please

> **Jeffreyvnlk wrote:**
> It was appreciated if you could make this indicator called Spread Oscillator (SO):
>
> A. Modified spread: dividing 1 instrument by 2rd and then multiplying by 100
> B- Subtract a 5-period exponential moving average of A from a 15- period exponential moving average of A as well
>
> Long and short 1st instrument when SO crossing above or below Zero line
>
> Thanks in advance


---

## Re: Spread Oscillator

**Apprentice** · Mon Jun 03, 2013 11:25 am

Normalization option added.


---

## Re: Spread Oscillator

**Jeffreyvnlk** · Tue Jun 04, 2013 6:30 am

Perfect, you save me


---

## Re: Spread Oscillator

**Jeffreyvnlk** · Sat Jul 06, 2013 3:08 am

> **Apprentice wrote:**
>
>
> Spread Oscillator.png
>
>
> Ratio = (First Instrument / Second Instrument)*100
> Spread Oscillator = Long MA of Ratio - Short MA of Ratio
>
>
> Spread Oscillator.lua
>
>
>
>
> Spread Oscillator with Normalization.lua

Your Spread Oscillator based on moving average was great.
 May I propose another method which based on percentage change movements as following:
===============
Input: Length(20)
Value1(( C/C[Length])- C Data2/C[Length] Data2))*100;
===================
I called it as Spread Momentum (SM) and it could be easier to use for trading. Use 2 levels for extremes and Zero line. It would be fantastic if you could paint the price bars when SM reaching extremes
Thanks


---

## Re: Spread Oscillator

**Apprentice** · Sat Jul 06, 2013 11:13 am

Is this correct formula
Value1 = (( Close[period]/Close[period- Length])- Data[Period]/Data[period-Length] ))*100;


---

## Re: Spread Oscillator

**Jeffreyvnlk** · Sat Jul 06, 2013 11:33 am

> **Apprentice wrote:**
> Is this correct formula
> Value1 = (( Close[period]/Close[period- Length])- Data[Period]/Data[period-Length] ))*100;

Thank but may I move back to express by language literally

A.Dividing the price of Instrument 1 to that of Instrument 2
B. Doing the same but for a period (length) looking back
C. A minus B and divide to 100
D. Plot on the chart as an Oscillator with over/under value levels and Zero line

Strategy for trading: it advisable to wait the Oscillator from extreme levels (over/under value btw 2 instruments) crossing Zero line in order to long/short accordingly
Not only for trading but using for analysis. Right now XAU still overvalue to Bond so XAU would go lower, even go down faster because bond also in a down trend. Regarding USD cycles, XAU could go to 800$

Thank you for helping


---

## Re: Spread Oscillator

**Apprentice** · Sat Jul 06, 2013 11:37 am

Can you revise your formula.


---

## Re: Spread Oscillator

**Jeffreyvnlk** · Tue Jul 09, 2013 2:48 am

> **Apprentice wrote:**
> Is this correct formula
> Value1 = (( Close[period]/Close[period- Length])- Data[Period]/Data[period-Length] ))*100;

I think this is correct


---

## Re: Spread Oscillator

**Apprentice** · Tue Jul 09, 2013 4:26 am

![Spread Oscillator.png](images/74724/Spread%20Oscillator.png)



Try this version
Spread Oscillator=((Close[period]/Close[period- Length])- Data[Period]/Data[period-Length]))*100;

 [Spread Oscillator.lua](files/74724/Spread%20Oscillator.lua)


---

## Re: Spread Oscillator

**Jeffreyvnlk** · Sat Jul 20, 2013 7:25 am

Thank you

May I come back to OP ? I see your indicator great potential
Larry Williams suggest all instruments comparing to gold. Over a century,always 1 ounce of gold can buy you a nice suit ! So in term of currencies index he suggested the currency will be against 3 other stuff: gold, T-bond and USD index

I don't know here we have currencies indexes or not but let tweak this spread oscillator more.For example, under EUR/USD chart, instead of 3 underneath windows for 3 oscillators (EUR/USD vs. Gold/Bund/FXCM's USD index) , there would be just 1 window for all 3 ? Thanks

Larry W said about the concept of valuation. It different from oversold/overbought. Sometime the instrument oversold but not yet under valuation, shorting not recommended. In practice,when you see EUR over valuated to gold and USDindex (2 out of 3), preparing to short EUR.


---

## Re: Spread Oscillator

**Apprentice** · Fri Jun 22, 2018 8:15 am

The indicator was revised and updated.


---

## Re: Spread Oscillator

**Emma_202** · Tue Aug 25, 2020 11:55 am

> **Jeffreyvnlk wrote:**
> Thank you
>
> May I come back to OP ? I see your indicator great potential
> Larry Williams suggest all instruments comparing to gold. Over a century,always 1 ounce of gold can buy you a nice suit ! So in term of currencies index he suggested the currency will be against 3 other stuff: gold, T-bond and USD index
>
> I don't know here we have currencies indexes or not but let tweak this spread oscillator more.For example, under EUR/USD chart, instead of 3 underneath windows for 3 oscillators (EUR/USD vs. Gold/Bund/FXCM's USD index) , there would be just 1 window for all 3 ? Thanks
>
> Larry W said about the concept of valuation. It different from oversold/overbought. Sometime the instrument oversold but not yet under valuation, shorting not recommended. In practice,when you see EUR over valuated to gold and USDindex (2 out of 3), preparing to short EUR.

Has anyone tested this indicator to see how well it performs?

The Williams Valuation concept should in theory be relevant to understand how an economy, and by proxy its currency, is valued by investors.
