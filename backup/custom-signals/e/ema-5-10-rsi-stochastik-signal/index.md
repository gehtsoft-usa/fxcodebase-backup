# EMA 5/10, RSI, Stochastik Signal

> Source: https://fxcodebase.com/code/viewtopic.php?f=29&t=892  
> Forum: 29 · Topic 892 · 18 post(s)


---

## EMA 5/10, RSI, Stochastik Signal

**Apprentice** · Fri Apr 30, 2010 9:03 am

![EMA RSI STO Signal.png](images/1632/EMA%20RSI%20STO%20Signal.png)

*EMA 5/10; RSI, Stochastik*



**Buy**
EMA5>EMA10
RSI >50
RSI <70
K%>D%
K%< 80

**Sell**
EMA5>EMA10
RSI <50
RSI >30
K%<D%
K%> 20

 [EMA RSI STO Signal.lua](files/1632/EMA%20RSI%20STO%20Signal.lua)

MT4/MQ4 version.
[viewtopic.php?f=38&t=69128](https://fxcodebase.com/code/viewtopic.php?f=38&t=69128)


---

## Re: EMA 5/10, RSI, Stochastik Signal

**cmasters** · Tue Jul 20, 2010 7:36 am

Hi, thanks for the signal I think its exactly what I am looking for!

Quick question, does the long/short signal go off when any one of the parameters is met or only when all of the parameters are met?

I am using a system at the minute that uses 5/10 EMA Cross, 9 period RSI above/below 50 and 10,3,3 Stochastic between 80/20. Once this combination of signals comes together it validates entry but without one signal its not ok with the system to enter.


---

## Re: EMA 5/10, RSI, Stochastik Signal

**Apprentice** · Tue Jul 20, 2010 11:04 am

Signal is generated only when all of the parameters are met.


---

## Re: EMA 5/10, RSI, Stochastik Signal

**one2share** · Fri Jul 23, 2010 4:02 am

Hi,
 I use the rsi and ema line in same window. Are you able to amend the signal where it alerts me when the rsi simply crosses the ema line? I also use the atr with this, are you able to amend signal where when it alerts of cross(buy for crossed up and sell when crosses down) and that atr value is displayed? I use this signal all the way thru the day chart. thanks


---

## Re: EMA 5/10, RSI, Stochastik Signal

**gulabgang** · Tue Dec 30, 2014 4:07 am

when openning the Method window it displays 6 possible selections :
"GrossPL", "Balance", "Equity", "GrossPL", "Balance"and "DayPL"
Is it right ?


---

## Re: EMA 5/10, RSI, Stochastik Signal

**Apprentice** · Fri Jan 02, 2015 2:57 am

5/10 EMA, RSI, stochastics is signal only.
It will not make any trades.


---

## Re: EMA 5/10, RSI, Stochastik Signal

**brunoyork** · Fri Mar 06, 2015 1:44 am

Hi, Apprentice
Tks for the signal, but i try to run a backtest on the Marketscope V2, it warns

> Message	Time
> ...works\FXTS2\Strategies\Custom\EMA RSI STO Signal.lua:109: Index is out of range	2015/03/06 01:47:53
> Backtesting started	2015/03/06 01:47:53

Would you please advise how to do with it. I simply check the 109 line, i found there are some space in front of the "then", which i deleted and try again, the the warning remains.

Thanks~
Bruno


---

## Re: EMA 5/10, RSI, Stochastik Signal

**Apprentice** · Fri Mar 06, 2015 2:39 am

Fixed.


---

## Re: EMA 5/10, RSI, Stochastik Signal

**brunoyork** · Fri Mar 06, 2015 3:04 am

> **Apprentice wrote:**
> Fixed.

it works. tks.


---

## Re: EMA 5/10, RSI, Stochastik Signal

**Fen888** · Mon Aug 03, 2015 1:17 pm

Hi there

First of all, please excuse my nil knowledge of programming and English skill
I found this is very close to what i was looking for! So, I would like to change some and remake it based on this fantastic one.

I would like to make signal when
1.EMA1(period5) crossover EMA2(period14) and EMA3(period26)
at the same time RSI value is moving above 70,
make BUY signal.

2.EMA1(period5) crossunder EMA2(period14) and EMA3(period26)
at the same tume RSI value is moving under 30,
make SELL signal.

I don't need Stochastik.

The signal comes in multiple time frame with sound alert and pop-up message ("BUY" or "SELL" word, time, pair name, price and on which time frame).
I don't want arrows on chart.

Could you fix my horrible work?
I think i should pay if it is made..

Cheers


---

## Re: EMA 5/10, RSI, Stochastik Signal

**Kyriakos** · Tue Aug 04, 2015 1:32 pm

Hi,

Can you make this a strategy with the standard parameters plus

Trading hours
Close on opposite
Maximum positions limit

Thanks


---

## Re: EMA 5/10, RSI, Stochastik Signal

**Apprentice** · Thu Aug 27, 2015 8:04 am

Strategy can be found here.
[viewtopic.php?f=31&t=62595](https://fxcodebase.com/code/viewtopic.php?f=31&t=62595)


---

## Re: EMA 5/10, RSI, Stochastik Signal alert

**joshcook_18** · Thu Jun 20, 2019 5:37 am

Hello,

I was wondering if you could adjust this exact signal using the 'EMA, RSI and Stochstik', and add the parameter option to send email alerts.

I've seen the updated stratergy but I do not want to include the MACD in my stratergy, I much prefer how this signal works instead.

thanks
-josh


---

## Re: EMA 5/10, RSI, Stochastik Signal

**Apprentice** · Sun Jun 30, 2019 6:10 pm

Your request is added to the development list under Id Number 4759


---

## Re: EMA 5/10, RSI, Stochastik Signal

**Apprentice** · Mon Jul 01, 2019 12:39 pm

Try it now.


---

## Re: EMA 5/10, RSI, Stochastik Signal

**trillionairemac** · Mon Nov 11, 2019 12:20 am

Ex4 or mq4 file please


---

## Re: EMA 5/10, RSI, Stochastik Signal

**Apprentice** · Wed Nov 13, 2019 3:34 pm

Your request is added to the development list.
Development reference 312.


---

## Re: EMA 5/10, RSI, Stochastik Signal

**Apprentice** · Thu Nov 14, 2019 11:31 am

MT4/MQ4 version.
[viewtopic.php?f=38&t=69128](https://fxcodebase.com/code/viewtopic.php?f=38&t=69128)
