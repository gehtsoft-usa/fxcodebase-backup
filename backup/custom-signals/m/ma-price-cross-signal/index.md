# MA / Price Cross Signal

> Source: https://fxcodebase.com/code/viewtopic.php?f=29&t=2386  
> Forum: 29 · Topic 2386 · 47 post(s)


---

## MA / Price Cross Signal

**Apprentice** · Tue Oct 12, 2010 1:10 pm

![MA Price Cross Signal.png](images/5151/MA%20Price%20Cross%20Signal.png)



Signal generating a signal when price touches the moving average.
The signal has two types of signals, Touch and Cross.
Allows selection of the moving average, the Data source. the moving average, the type of prices.

 [MA Price Cross Signal.lua](files/5151/MA%20Price%20Cross%20Signal.lua)

 [MTF Price MA Signal.lua](files/5151/MTF%20Price%20MA%20Signal.lua)


---

## Re: MA / Price Cross Signal

**wizardpro** · Wed Oct 13, 2010 11:33 am

Hi
Failure to understand this MA cross, I though using it had 2 MA line and once it cross then can tell .Using 1 Line I am not sure how to use this.


---

## Re: MA / Price Cross Signal

**Apprentice** · Wed Oct 13, 2010 1:41 pm

This indicator gives a signal when we have the Cross of One moving average and closing price line.

Cross Mod.
Gives signals when the candles on the trading period closes above or below the moving average.

Touch, Mod.
Gives signals whenever Candle, with any part touches moving average.

This is one of the most simple, basic signal.
It warns you when the closing price crossed a moving average.

The signal is written on the basis of the request.


---

## Re: MA / Price Cross Signal

**balmy66012** · Thu Oct 14, 2010 7:16 am

Is there an easy way to make this signal an indicator?

Thanks in advance,

B


---

## Re: MA / Price Cross Signal

**Apprentice** · Thu Oct 14, 2010 7:53 am

Added on development cue.


---

## Re: MA / Price Cross Signal

**Apprentice** · Tue Oct 19, 2010 2:00 am

I thought today to meet your requirement,
But I remembered that I had written the next indicator.
[viewtopic.php?f=17&t=2012&p=4109&hilit=overlay#p4109](https://fxcodebase.com/code/viewtopic.php?f=17&t=2012&p=4109&hilit=overlay#p4109)

If it does not suit your needs I'll write a new one.


---

## Re: MA / Price Cross Signal

**Apprentice** · Tue Oct 19, 2010 3:12 am

After a short, thinking about the problem, I decided to write an indicator that you are looking for.
Existing solutions do not provide all the information as the original strategy.

[viewtopic.php?f=17&t=2451&p=5328#p5328](https://fxcodebase.com/code/viewtopic.php?f=17&t=2451&p=5328#p5328)


---

## Re: MA / Price Cross Signal

**Apprentice** · Wed Nov 03, 2010 9:34 am

Update


---

## Re: MA / Price Cross Signal

**Representative** · Fri Nov 26, 2010 9:03 am

I am looking for a signal that starts shouting at me when 2 different EMA's cross each other (after the close of a candle/at open of new candle). I have added an image to show where I would like it to make a noise or something.
Is this possible at all? or even better, does it already exist?!


---

## Re: MA / Price Cross Signal

**Apprentice** · Fri Nov 26, 2010 11:10 am

I believe that such strategy exists.
[http://www.fxcodebase.com/code/viewtopi ... =31&t=2763](http://www.fxcodebase.com/code/viewtopic.php?f=31&t=2763)


---

## Re: MA / Price Cross Signal

**luciana** · Mon Jan 03, 2011 4:58 pm

Hi, currently I'm using two different indicators/signals price cross signal and the cross of 2 MA . What I mean is to get a signal when the price closes above/below a MA and in the same time 2 MA crosses each another. Is it possible to develop such an indicator with alert option or direct me to an existing one. Thanks.


---

## Re: MA / Price Cross Signal

**Apprentice** · Sat Feb 26, 2011 6:02 am

This indicator or strategy is possible.

Can you tell me more about your strategy.
What you want to achieve


---

## Re: MA / Price Cross Signal

**nazaar** · Fri Dec 02, 2011 11:52 pm

Hi Apprentice,

I would like a signal generated when price touches the 200 ema or 100 sma but do not want to have these ema / sma being displayed on my chart. In order for this signal to work do I have to have the ema / sma on?

Thanks,
Nazaar


---

## Re: MA / Price Cross Signal

**Apprentice** · Sun Dec 04, 2011 4:53 am

Your request is added to the developmental cue.


---

## Re: MA / Price Cross Signal

**STEIGO** · Mon Dec 05, 2011 12:05 pm

Why not just set the color of the 200ma and 100ma to the same color as your chart.


---

## Re: MA / Price Cross Signal

**simonecabras** · Wed Feb 15, 2012 6:17 pm

I have downloaded the signal but Trading Station II tells me that there is an error and does not upload it.

Let me know what can I do.

Regards,
Simone


---

## Re: MA / Price Cross Signal

**sunshine** · Thu Feb 16, 2012 1:48 am

Hi Simone,
Welcome to the forum!
Could you please send me as much information as possible about the issue, including the exact error message you are receiving along with screenshots?


---

## Re: MA / Price Cross Signal

**Apprentice** · Thu Feb 16, 2012 2:54 am

I can not be sure.
But it seems to me that you use some of the moving averages,
not available by default.
If you install them, your problem should disappear.


---

## Re: MA / Price Cross Signal

**Leisure** · Thu Feb 23, 2012 8:50 am

Since Marketscope allows the displaying of a 10 ema from the 4 hour time frame on a 1 hour chart, can this signal be modified to include the functionality when the 1 hour candle closes above or below the 4 hour 10 ema?

Thanks


---

## Re: MA / Price Cross Signal

**Apprentice** · Fri Feb 24, 2012 4:36 am

It's easier to write a new strategy.


---

## Re: MA / Price Cross Signal

**ertonm** · Thu Mar 01, 2012 9:54 pm

Hi,

Is it possible to add a RSI filter to MA/Price cross signal. I would like to have a signal when the price cross the MA and the RSI crosses "X" level in the mean time.

Thank you


---

## Re: MA / Price Cross Signal

**Apprentice** · Fri Mar 02, 2012 5:19 am

you use RSI just for confirmation?


---

## Re: MA / Price Cross Signal

**ertonm** · Fri Mar 02, 2012 9:06 am

Hi Apprentice,

I use RSI and MACD generally but that is only to time the entry.
I take a look at the big picture too.
If you can add MACD crossover as a filter it will be awsome.

Thank you.


---

## Re: MA / Price Cross Signal

**Apprentice** · Sun Mar 04, 2012 3:25 am

I think we are on the same page.
Which of these two indicators you use to generate the signal.
And one of them, just to confirm the signal.
Or make a trade regardless of the sequence.
When both indicators have the same indication.


---

## Re: MA / Price Cross Signal

**Apprentice** · Mon Mar 05, 2012 7:26 am

MTF Signal Added. (Topmost post)


---

## Re: MA / Price Cross Signal

**Apprentice** · Fri Mar 09, 2012 6:52 am

RSI Filter Added.

 [MA Price Cross Signal with RSI Filter.lua](files/27786/MA%20Price%20Cross%20Signal%20with%20RSI%20Filter.lua)

RSI works only for Cross Signal not for Touch.

RSI Filter
Crossover
RSI > 50
Crossunder
RSI < 50


---

## Re: MA / Price Cross Signal

**ertonm** · Wed Apr 18, 2012 9:53 am

Apprentice thank you very much for this signal.
appreciate it.


---

## Re: MA / Price Cross Signal

**Apprentice** · Fri Jun 15, 2012 12:58 pm

to nazaar
Price / ma cross signal can be found here.
[viewtopic.php?f=29&t=20226](https://fxcodebase.com/code/viewtopic.php?f=29&t=20226)


---

## Re: MA / Price Cross Signal

**cjames** · Wed Nov 07, 2012 1:07 pm

The original 7.64KB MA Price Cross Signal.lua (with just the one moving average) works beautifully but for one strange omission... the email it sends includes no information about the event or even which currency pair has crossed the MA. Just says "MA Cross". A more informative email would make the email function very useful. Cheers.


---

## Re: MA / Price Cross Signal

**sagymmm** · Tue Jun 04, 2013 7:40 am

I wonder if we can add the Wilder MA (WMA) to the cross signal


---

## Re: MA / Price Cross Signal

**Apprentice** · Wed Jun 05, 2013 2:38 am

I believe that Wilders is already one of the options.


---

## Re: MA / Price Cross Signal

**kingolli** · Tue Jul 02, 2013 12:05 pm

> **cjames wrote:**
> The original 7.64KB MA Price Cross Signal.lua (with just the one moving average) works beautifully but for one strange omission... the email it sends includes no information about the event or even which currency pair has crossed the MA. Just says "MA Cross". A more informative email would make the email function very useful. Cheers.

I want to use this signal with email alert, too. The simple subject "EUR/USD Cross Under" would be very useful. Thanks!


---

## Re: MA / Price Cross Signal

**kingolli** · Tue Jul 02, 2013 12:11 pm

> **cjames wrote:**
> The original 7.64KB MA Price Cross Signal.lua (with just the one moving average) works beautifully but for one strange omission... the email it sends includes no information about the event or even which currency pair has crossed the MA. Just says "MA Cross". A more informative email would make the email function very useful. Cheers.

That would be great. Personally, for me the best solution would be a Line like the following:

"EUR/USD crossed under MVA50 on H4" -----> is that possible?


---

## Re: MA / Price Cross Signal

**Apprentice** · Wed Jul 03, 2013 2:33 am

Yes it is.

Your request is added to the development list.


---

## Re: MA / Price Cross Signal

**IQFX32** · Sat Jul 06, 2013 1:52 pm

Hi,

It could be a strategie?

Thx


---

## Re: MA / Price Cross Signal

**Apprentice** · Tue Jul 09, 2013 4:07 am

Try this version.
[viewtopic.php?f=31&t=2403](https://fxcodebase.com/code/viewtopic.php?f=31&t=2403)


---

## Re: MA / Price Cross Signal

**yogisan18** · Mon Aug 26, 2013 4:47 pm

Hi!

I've been looking everywhere for an alarm/signal when price touches/crosses MA.

The alarm/signal should be triggered as soon as price touches MA during the life of the present candle.

Can you help?

Thank you,

Jo


---

## Re: MA / Price Cross Signal

**Apprentice** · Tue Aug 27, 2013 2:29 am

Your request is added to the development list.


---

## Re: MA / Price Cross Signal

**Fxijtuk** · Thu Jan 09, 2014 12:47 pm

Would is be possible to add ARSI to this signal so that we could get an alert when one ARSI crosses another?

Thanks very much.


---

## Re: MA / Price Cross Signal

**Apprentice** · Sat Jan 11, 2014 7:19 am

U can use this ARSI Strategy for Fast/Slow ARSI Line Cross Signalling.
[viewtopic.php?f=31&t=60190](https://fxcodebase.com/code/viewtopic.php?f=31&t=60190)


---

## Re: MA / Price Cross Signal

**nchatzoglou** · Wed Jan 29, 2014 1:24 am

Hi,

I m using the "MTF Price MA Singnal.lua" with the touch option and in 5M TM in 20EMA H1 chart which I found very usefull. I recently came across another signal MA Distance signal [viewtopic.php?f=29&t=10289](https://fxcodebase.com/code/viewtopic.php?f=29&t=10289) which gives the option of a signal when price reaches certain distance in pips from the moving average. I found this option very usefull but there is no multi time frame option. What I want to ask you is that since you created a great signal "MTF Price MA Signal" which I am already succesfully using it, can you incorporate in this signal the same option for the distance in pips just as with the MA Distance signal ???
Thank you


---

## Re: MA / Price Cross Signal

**Apprentice** · Thu Jan 30, 2014 4:06 am

Your request is added to the development list.


---

## Re: MA / Price Cross Signal

**IQFX36** · Tue Oct 27, 2015 6:27 pm

Hi
Which is the highest EMA it admits?
Thx.


---

## Re: MA / Price Cross Signal

**Apprentice** · Thu Oct 29, 2015 5:42 am

Any period between 2 and 1000.


---

## Re: MA / Price Cross Signal

**Avignon** · Wed May 24, 2017 6:41 pm

Hello,

Unless I am mistaken, we have the mail notification but we do not know what the currency.

I know, I'm fussy !


---

## Re: MA / Price Cross Signal

**Apprentice** · Thu May 25, 2017 5:28 am

Try it now.


---

## Re: MA / Price Cross Signal

**Avignon** · Wed May 31, 2017 3:18 pm

It works ! Thank you !
