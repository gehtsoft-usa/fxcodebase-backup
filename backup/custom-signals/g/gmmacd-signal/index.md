# GMMACD Signal

> Source: https://fxcodebase.com/code/viewtopic.php?f=29&t=1281  
> Forum: 29 · Topic 1281 · 10 post(s)


---

## GMMACD Signal

**Apprentice** · Tue Jun 08, 2010 1:27 pm

![GMMACD Signal.png](images/2442/GMMACD%20Signal.png)

*GMMACD Signal*



 [GMMACD Signal.lua](files/2442/GMMACD%20Signal.lua)

Signal in generated when GMMACD crosses Over/Under the zero line

To work, please install GMMACD Indicator.
[viewtopic.php?f=17&t=412&p=4681&hilit=gmma#p4681](https://fxcodebase.com/code/viewtopic.php?f=17&t=412&p=4681&hilit=gmma#p4681)


---

## Re: GMMACD Signal

**Jigit Jigit** · Tue Aug 31, 2010 2:42 pm

Thanks a lot for this one.

Can someone, please please, explain in detail how to interprete these signals?
I'm a beginner demo trader, you see.

I'm not sure if I use it properly. What I do is:
1. I go to "Strategies" in the TSii and add your GMMACD Signal
2. in "Manage Strategies" I modify the properties (I adjust the Currency pair and timeframe I want to use it for, I put "show alert" to "yes", "Play Sound" to "yes" - I locate and open an appropriate sound file)
3. Click "Apply"
Then nothing happens.

Should I always run it in the "Backtest" mode?
When I do it I have difficulties with interpreting the signals, as the "buy" and "sell" allerts show in the same colour regardless of how I modify them in the settings.

Please do help me with these guys.
Cheers


---

## Re: GMMACD Signal

**Nikolay.Gekht** · Thu Sep 02, 2010 12:05 pm

A running signal and/or strategy works on the new prices only. So, nothing will happen immediately. The signal appears only when GMMACD indicator applied on the chosen instrument of chosen time frame crosses zero line AFTER the signal applied. To see when signal happened IN PAST or to see when the signal happend on the chart you must use the "showsignal" indicator.


---

## Re: GMMACD Signal

**Jigit Jigit** · Fri Sep 03, 2010 8:25 am

Thanks Nikolay.
You're the man.
I've got it now.


---

## Re: GMMACD Signal

**Apprentice** · Tue Sep 21, 2010 4:24 pm

Email Feature added.


---

## Re: GMMACD Signal

**mulligan** · Wed Jun 03, 2015 8:47 am

Could you please add the style option of recurrent sound when you get time.

Thanks very much


---

## Re: GMMACD Signal

**Apprentice** · Fri Jun 05, 2015 4:23 am

Recurrent sound option added.
Unfortunately Strategys / Signal do not offer styling options.


---

## Re: GMMACD Signal

**mulligan** · Fri Jun 05, 2015 11:16 am

Thank you for adding the recurring sound option. Now I don't have to stick by the computer nearly as much. My mistake for referring to it as a style option. What you do is invaluable to traders.

Thanks again


---

## Re: GMMACD Signal

**Marie441** · Tue Nov 10, 2015 2:00 am

Could you please add the style option of recurrent sound when you get time.


---

## Re: GMMACD Signal

**Apprentice** · Fri Nov 13, 2015 6:42 am

style option, in not a option for signals or/and strategys.
