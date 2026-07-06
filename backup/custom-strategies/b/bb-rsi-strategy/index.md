# BB RSI Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=25331  
> Forum: 31 · Topic 25331 · 17 post(s)


---

## BB RSI Strategy

**Apprentice** · Fri Nov 02, 2012 1:04 pm

![BB RSI Strategy.png](images/43549/BB%20RSI%20Strategy.png)



Buy signal
Price / Bottom Bollinger Touch and
RSI < Buy Level (30)
Sell signal
Price / Top Bollinger Touch
RSI > Sell Level (70)

 [BB RSI Strategy.lua](files/43549/BB%20RSI%20Strategy.lua)

The Strategy was revised and updated on December 11, 2018.


---

## Re: BB RSI Strategy

**amazon1a** · Sat Nov 03, 2012 8:30 am

Hi Apprentice, This looks great. Can you code it for MT4? Bob


---

## Re: BB RSI Strategy

**Apprentice** · Sun Nov 04, 2012 7:40 am

Unfortunately I am not expert in writing the Strategy for MT4.
I hope that Alex will find the time.


---

## Re: BB RSI Strategy

**amazon1a** · Sun Nov 04, 2012 11:28 am

Thanks Apprentice, Hope that Alex can help me. Bob


---

## Re: BB RSI Strategy

**DiMaKe** · Sat Jan 19, 2013 12:30 pm

Hy guys, may you please modify this script to be able to trade with microlots....the min ammount for trading is between 1 and 100 and I want to be able to set it for ex 0.1

Thank you in advance


---

## Re: BB RSI Strategy

**Apprentice** · Sat Jan 19, 2013 5:32 pm

Unfortunately Trading Server will not allow this.
Is you are using Standard account type swich to Microlot.
[http://www.forexmicrolot.com/](http://www.forexmicrolot.com/)


---

## Re: BB RSI Strategy

**CHECEZAR** · Thu Oct 09, 2014 8:14 am

Hi Apprentice

Could you please add to this strategy as follows:

1) An option where indicated the maximum number of entries in the same currency.

2) That instead of going directly to market operations, is introduced rather an entry order; for it is a field where you specify the number of pips either up or down more obtenia signal must exist. That is + pips or -pips.

Thanks for your help


---

## Re: BB RSI Strategy

**Apprentice** · Tue Oct 14, 2014 3:55 am

Your request is added to the development list.


---

## Re: BB RSI Strategy

**Daydreaminblue** · Mon Nov 03, 2014 1:51 pm

How does the exit strategy work on this if there are no limits set? Does it wait until the opposite action?


---

## Re: BB RSI Strategy

**Apprentice** · Wed Nov 05, 2014 3:55 am

The strategy was revised, Some new features are added.
Exactly, Position will be open until position with opposite direction is opened.


---

## Re: BB RSI Strategy

**CHECEZAR** · Sat Jan 31, 2015 10:37 am

> **Apprentice wrote:**
> The strategy was revised, Some new features are added.
> Exactly, Position will be open until position with opposite direction is opened.

Hi Apprentice
Could you please add to this strategy the "Entry order" function? I mean that the strategy instead of operate directly puts an order for example 10 pips upper or lower than the Price the signal says. Attached you can find a strategy that does exactly that. Thanks a lot for your attention, I would really appreciate if you can help me with that


---

## Re: BB RSI Strategy

**Apprentice** · Sun Dec 11, 2016 1:39 pm

Strategy was revised and updated.


---

## Re: BB RSI Strategy

**Alexander.Gettinger** · Fri Dec 21, 2018 4:19 pm

> **amazon1a wrote:**
> Hi Apprentice, This looks great. Can you code it for MT4? Bob

Please try this MT4 strategy:

 [BB_RSI_Str.mq4](files/122993/BB_RSI_Str.mq4)


---

## Re: BB RSI Strategy

**ASTONIX91** · Thu Jul 29, 2021 3:13 am

Hello
Could you code it in MQL5 Thanks in advance for your work


---

## Re: BB RSI Strategy

**Apprentice** · Thu Jul 29, 2021 3:37 am

Your request is added to the development list.
Development reference 694.


---

## Re: BB RSI Strategy

**Apprentice** · Fri Jul 30, 2021 1:13 pm

[BB_RSI_Str.mq5](files/143039/BB_RSI_Str.mq5)

Try this version.


---

## Re: BB RSI Strategy

**ASTONIX91** · Tue Aug 24, 2021 7:20 am

Hello
thank you for your files, thank you for your work.
can reverse all buy and sell orders in the original file
