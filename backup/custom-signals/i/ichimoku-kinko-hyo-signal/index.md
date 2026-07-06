# Ichimoku Kinko Hyo Signal

> Source: https://fxcodebase.com/code/viewtopic.php?f=29&t=861  
> Forum: 29 · Topic 861 · 47 post(s)


---

## Ichimoku Kinko Hyo Signal

**Apprentice** · Wed Apr 28, 2010 3:49 am

![Ichimoku Kinko Hyo signal.png](images/1556/Ichimoku%20Kinko%20Hyo%20signal.png)

*Ichimoku Kinko Hyo Signal*



This version of Ichimoku Kinko Hyo Signal provides three types of signals.

**Tenkan-sen, Kijun-sen line crossesover**
Buy Signal - Positive Tenkan-sen, Kijun-sen line crossesover.
Sell signal- Negative Tenkan Kijun-sen-sen line crossesover.

**Crossesover of Closing price and Chinkou Span**
Buy signal-Positive crossesover of closing price and Chinkou Span.
Sell signal - Negative crossesover of closing price and Chinkou Span.

**Closing price Punching Below / Above the cloud, Senkou Span**
Buy signal-Positive closing price cloud Breakout.
Sell signal - Negative closing price cloud Breakout.

Like similar tools originating from Japan, gives better results for the Japanese Yen pairs.

 [Ichimoku Kinko Hyo signal.lua](files/1556/Ichimoku%20Kinko%20Hyo%20signal.lua)

MT4/MQ4 version.
[viewtopic.php?f=38&t=70246](https://fxcodebase.com/code/viewtopic.php?f=38&t=70246)


---

## Re: Ichimoku Kinko Hyo Signal

**smartfx** · Wed Apr 28, 2010 6:58 am

THANK YOU VERY MUCH!


---

## Re: Ichimoku Kinko Hyo Signal

**DS0167** · Mon Aug 09, 2010 2:25 pm

This signal could be very helpful (as I am a big fan of Ichimoku), but it doesn't work on my platform... Am I the only one with this problem ?

Thanks in advance for your return.

Regards,
DS0167


---

## Re: Ichimoku Kinko Hyo Signal

**DS0167** · Mon Aug 09, 2010 2:37 pm

when I try to load this signal in Marketscope, I have and "error" message... is it only me ?

Thanks for your return.

Kind regards,
DS0167


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Mon Aug 09, 2010 3:29 pm

I just I tried to load this signal. Works perfectly.

Read this manual on How to load the signal.
If this does not help let me know via private message.
[viewtopic.php?f=29&t=602#p1069](https://fxcodebase.com/code/viewtopic.php?f=29&t=602#p1069)

I think I'll redesign this indicator bit when I find time.


---

## Re: Ichimoku Kinko Hyo Signal

**DS0167** · Mon Aug 09, 2010 4:35 pm

Thanks and I confirm it works perfectly. I surely did a wrong manipulation the first time.

Big thank you !


---

## Re: Ichimoku Kinko Hyo Signal

**DS0167** · Tue May 31, 2011 2:40 pm

Apprentice,

Would be nice if each signal could work independently... I mean, if we could select whether we prefer a signal of :

**Tenkan-sen, Kijun-sen line crossesover**
or/and
**Crossesover of Closing price and Chinkou Span**
or/and
**Closing price Punching Below / Above the cloud, Senkou Span**

Is it feasible?

As usual, thank you in advance if yes

All the best,
Danielle


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Wed Jun 01, 2011 3:06 am

For you ...
Let me think ...
Yes


---

## Re: Ichimoku Kinko Hyo Signal

**DS0167** · Wed Jun 01, 2011 3:29 am

I knew you can't resist to a poor soul seeking for pips


---

## Re: Ichimoku Kinko Hyo Signal

**nookie** · Fri Jul 15, 2011 8:07 am

Hey,

Is it possible this signal to be turned out to a strategy with the option to trade and also "allow open multiple positions" in it ?

If some logic can be included for the 3 rules already there like - yes/no/and/or would be great

Cheers

Nookie


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Sat Jul 16, 2011 3:43 am

Your request has been added to our database.


---

## Re: Ichimoku Kinko Hyo Signal

**nazaar** · Fri Dec 02, 2011 11:29 pm

Apprentice, another excellent indicator.

I like using Ichimoku to help measure trend strength and to anticipate possible trend change. I am always counting back to see where the 9th and 26th bar is. Then, look to see within these ranges which bar(s) is being used as the highest high and lowest low.

Regarding the tenkan calculation, could you add a symbol to identify the 9th bar back? Simple symbol might be the # 9. Then within this range of 9 candlestick a further symbol to mark the highest high, i.e 9H or TH (tenkan high). And, a 9L or TL to mark the lowest low of the range?

Similarily, the same for the kijun calculation.

It would be ideal if the user could choose to display this information or not.

as always, thanks in advance.

Nazaar


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Sun Dec 04, 2011 4:49 am

Your request is added to the developmental cue.


---

## Re: Ichimoku Kinko Hyo Signal

**allisonmagic** · Mon Jan 28, 2013 9:29 pm

could you guys add a chikou alert, if chikou crosses the KUMO as well as price ?


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Wed Jan 30, 2013 5:30 am

Cloud and the Kumo are synonymous.
Current signal will give Cloud Crossover Alert.


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Wed Jan 30, 2013 6:09 am

nookie Here you can find a proposed strategy.
[viewtopic.php?f=31&t=31550](https://fxcodebase.com/code/viewtopic.php?f=31&t=31550)


---

## Re: Ichimoku Kinko Hyo Signal

**allisonmagic** · Wed Jan 30, 2013 4:10 pm

> **Apprentice wrote:**
> Cloud and the Kumo are synonymous.
> Current signal will give Cloud Crossover Alert.

it will give an alert when chikou crosses kumo ?


---

## Re: Ichimoku Kinko Hyo Signal

**allisonmagic** · Wed Jan 30, 2013 6:19 pm

did you ever figure out how to make an email alert for when chikou crosses above the kumo ?


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Thu Jan 31, 2013 5:38 am

You're right, the signal was given by Price / Cloud Cross,
not by chikou / Cloud cross, will add it.


---

## Re: Ichimoku Kinko Hyo Signal

**allisonmagic** · Thu Jan 31, 2013 6:07 am

awesome, thanks !


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Fri Feb 01, 2013 2:09 pm

CS / Cloud Crossover added to Highly adaptable Ichimoku Stategy
[viewtopic.php?f=31&t=31550&p=53988#p53988](https://fxcodebase.com/code/viewtopic.php?f=31&t=31550&p=53988#p53988)

CS / Price Cross Exist in earlier version.


---

## Re: Ichimoku Kinko Hyo Signal

**panos59** · Sun Jul 21, 2013 10:37 am

which option shall I use for the Tenkan-sen, Kijun-sen line crossesover ?


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Mon Jul 22, 2013 4:07 am

SL/TL Cross.


---

## Re: Ichimoku Kinko Hyo Signal

**rch05000** · Mon Jan 13, 2014 12:42 pm

Hello,
It is possible to add the timeframe in message of the indicator.
At present we have:
ICHIMOKUKINKOHTO SIGNAL:CS / Price CrossUnder ( USD / CHF )
By:
ICHIMOKUKINKOHYO SIGNAL:CS / Price CrossUnder (USD / CHF **(H1)**)

Sorry for my English
Thank you in advance


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Wed Jan 15, 2014 6:50 am

Better email formatting added.


---

## Re: Ichimoku Kinko Hyo Signal

**rch05000** · Wed Jan 15, 2014 11:16 am

Thank you Apprentice.

Which one works?
I installed:
Ichimoku Kinko Hyo signal.lua
then:
IchimokuKinkoHyo Signal.lua
and none of the 2 works

Thank you in advance


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Fri Jan 17, 2014 12:40 pm

FYI i have found and Fix a bug in Email send Block.

Can you specify which if not functioning.


---

## Re: Ichimoku Kinko Hyo Signal

**rch05000** · Fri Jan 17, 2014 12:56 pm

Hello,

There is not alert anymore and an email anymore.

Thank you in advance


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Fri Jan 17, 2014 1:09 pm

Please Re-Download and Try New Version.


---

## Re: Ichimoku Kinko Hyo Signal

**rch05000** · Fri Jan 17, 2014 1:42 pm

OK the message displays on the PC, but no email


---

## Re: Ichimoku Kinko Hyo Signal

**fchirawu** · Sun Jun 15, 2014 10:45 pm

Hi
This is a great strategy. Can it be modified to include the following options
***Please leave the traditional price and cloud cross. Those are fine but can you add
TENKAN SEN/KIJUN SEN CROSS SIGNAL

Strong Cross Signal
A strong tenkan sen/kijun sen cross Buy signal takes place when a bullish cross happens above the kumo.
A strong tenkan sen/kijun sen cross Sell signal takes place when a bearish cross happens below the kumo.

Neutral Signal
A neutral tenkan sen/kijun sen cross Buy signal takes place when a bullish cross happens within the kumo.
A neutral tenkan sen/kijun sen cross Sell signal takes place when a bearish cross happens within the kumo.

Weak Cross Signal
A weak tenkan sen/kijun sen cross Buy signal takes place when a bullish cross happens below the kumo.
A weak tenkan sen/kijun sen cross Sell signal takes place when a bearish cross happens above the kumo.

KIJUN SEN CROSS SIGNAL

Strong Kijun cross signal
A strong kijun sen cross Buy signal takes place when a bullish cross happens above the kumo.
A strong kijun sen cross Sell signal takes place when a bearish cross happens below the kumo.

Neutral Kijun Sen Cross Signal
A neutral kijun sen cross Buy signal takes place when a bullish cross happens within the kumo.
A neutral kijun sen cross Sell signal takes place when a bearish cross happens within the kumo.

Weak Kijun Sen Cross Signal
A weak kijun sen cross Buy signal takes place when a bullish cross happens below the kumo.
A weak kijun sen cross Sell signal takes place when a bearish cross happens above the kumo.

STRONG SENKOU SPAN CROSS SIGNAL

Strong Senkou Span Cross
A strong senkou span cross signal takes place when the price curve is on the side of the kumo that matches the sentiment of the senkou span cross.

Neutral Senkou Span Cross Signal
A neutral senkou span cross signal takes place when the price curve is inside the kumo at the time of the senkou span cross.

Weak Senkou Span Cross Signal
A weak senkou span cross signal takes place when the price curve is on the opposite side of the kumo that matches the sentiment of the senkou span cross.

STRONG CHIKOU SPAN CROSS SIGNAL

Strong Chikou Span
A strong chikou span cross Buy signal takes place when a bullish cross takes place and current price is above the kumo
A strong chikou span cross Sell signal takes place when a bearish cross takes place and current price is below the kumo.

Chikou Span Cross Signal
A neutral chikou span cross Buy signal takes place when a bullish cross takes place and current price is within the kumo
A neutral chikou span cross Sell signal takes place when a bearish cross takes place and current price is within the kumo.

Weak Chikou Span Cross Signal
A weak chikou span cross Buy signal takes place when a bullish cross takes place and current price is below the kumo
A weak chikou span cross Sell signal takes place when a bearish cross takes place and current price is above the


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Tue Jun 17, 2014 11:51 am

Your request is added to the development list.


---

## Re: Ichimoku Kinko Hyo Signal

**fchirawu** · Fri Jul 11, 2014 6:50 am

Hi

I am checking on the progress of the ichimoku signal modification.

Thank you


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Sat Jul 12, 2014 3:24 am

Unfortunately non.
Will try to finish it within a week.
After that, I go on vacation, should have more free time then.


---

## Re: Ichimoku Kinko Hyo Signal

**nweiss** · Tue Aug 05, 2014 12:34 pm

Hey ,

I Had an error maybe someone could help

Ichimoku Kinko Hyo signal.lua:183: attempt to concatenate global 'label' (a nil value)

Thanks Nikita


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Tue Aug 05, 2014 11:40 pm

Please Re-Download.


---

## Re: Ichimoku Kinko Hyo Signal

**nweiss** · Wed Aug 06, 2014 1:12 am

the TS or the Signal ? when you mean the signal Ive Tried it nothing changed !


---

## Re: Ichimoku Kinko Hyo Signal

**pascallyon** · Mon Aug 10, 2015 8:28 am

Hello Apprentice,

Is it possible to have only one (and simple) signal please ?

When Tenkan crosses up SSB's Kumo = Buy
When Tenkan crosses down SSB's Kumo = Sell

thank you very much !
best regards,
Pascal


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Thu Aug 27, 2015 6:36 am

Something like this.
[viewtopic.php?f=31&t=62594](https://fxcodebase.com/code/viewtopic.php?f=31&t=62594)


---

## Re: Ichimoku Kinko Hyo Signal

**[email protected]** · Sun Jul 17, 2016 6:36 pm

Hello,

I am getting the following errors while Importing this:

attempt to index global 'strategy' (a nil value)
The parameter with the specified id already exists

Please help with the install

Thank you


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Mon Jul 18, 2016 5:25 am

Fixed.


---

## Re: Ichimoku Kinko Hyo Signal

**[email protected]** · Sun Jul 24, 2016 6:22 pm

Thank you! The load problem has been fixed.


---

## Re: Ichimoku Kinko Hyo Signal

**octaviomejia** · Wed Aug 16, 2017 8:34 pm

Thank you, Apprentice! You created a very versatile and easy to use signal indicator.


---

## Re: Ichimoku Kinko Hyo Signal

**dotori** · Wed Jul 29, 2020 10:48 am

Hi
I have a problem loading this in to marketscope
can maybe anyone help?
please take a look at the screenshot of the link
[http://prnt.sc/tqkxeh](http://prnt.sc/tqkxeh)

Or can you convert it to mq4 file? Thanks


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Wed Jul 29, 2020 4:16 pm

Your request is added to the development list.
Development reference 1796.


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Thu Jul 30, 2020 5:16 pm

[Ichimoku Kinko Hyo.lua](files/136445/Ichimoku%20Kinko%20Hyo.lua)

Try this version.


---

## Re: Ichimoku Kinko Hyo Signal

**Apprentice** · Fri Jul 31, 2020 4:21 am

MT4/MQ4 version.
[viewtopic.php?f=38&t=70246](https://fxcodebase.com/code/viewtopic.php?f=38&t=70246)
