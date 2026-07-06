# RSI Crossover

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=2675  
> Forum: 17 · Topic 2675 · 30 post(s)


---

## RSI Crossover

**Apprentice** · Fri Nov 12, 2010 4:10 am

![RSI Crossover.png](images/6066/RSI%20Crossover.png)



Basically this is a common RSI.
But there are a few differences.

The indicator is moved vertically by 50 points.
Now oscillate around the zero line, Over Bought / Sold Lines are now +20 and -20 -
I did it,
in order to get RSI Histogram.
Histogram you can use, in the same way as the MACD histogram.
For earlier detection of crossover.
Between RSI and its moving average.
Which is also added.

 [RSI_Crossover.lua](files/6066/RSI_Crossover.lua)

Indicator-based strategy.
[https://fxcodebase.com/code/viewtopic.php?f=31&t=74691](https://fxcodebase.com/code/viewtopic.php?f=31&t=74691)


---

## Re: RSI Crossover

**DWetherell** · Fri Nov 12, 2010 7:26 am

Thanks for the indicator Apprentice...The only thing it is missing is the Moving average of the RSI itself. What I am try to do is smooth out all the jagged edges of the RSI that create unwanted trades. So the formula for that would be very simple...Moving Average(5) of RSI (14).

Also, I attached a screenshot of the look I was going for. It is similar to the MA cloud. Can you make a second Version?


---

## Re: RSI Crossover

**nazar_123** · Fri Nov 12, 2010 9:35 am

thank you very much for this indicator


---

## Re: RSI Crossover

**Apprentice** · Fri Nov 12, 2010 10:17 am

I'll try today to make your version.
My version has a moving average of RSI (blue line).


---

## Re: RSI Crossover

**Apprentice** · Sat Nov 13, 2010 4:06 pm

![Smoothed RSI.png](images/6106/Smoothed%20RSI.png)



Your version, I called Smoothed RSI.
Indicator offers a choice of type and period for moving average of RSI.
Gives Graphic notification, for 50 line crossover

 [Smoothed RSI.lua](files/6106/Smoothed%20RSI.lua)

 [Smoothed RSI with Alert.lua](files/6106/Smoothed%20RSI%20with%20Alert.lua)

Compatibility issue fixed.
_Alert Helper is not longer needed.


---

## Re: RSI Crossover

**DWetherell** · Sat Nov 13, 2010 6:34 pm

Thanks for the follow up indicator...much appreciated!


---

## Re: RSI Crossover

**davetherave110179** · Thu Mar 24, 2011 12:12 pm

Apprentice,

The SMOOTHED RSI indicator has a 'Graphic notification' when it crosses the 50 line, could you add a sound and email notification as well??

Link here:
[http://www.fxcodebase.com/code/viewtopic.php?f=17&t=2675&p=6106&hilit=Smoothed+RSI#p6106](http://www.fxcodebase.com/code/viewtopic.php?f=17&t=2675&p=6106&hilit=Smoothed+RSI#p6106)

Thanks for all your hard work!

davetherave110179


---

## Re: RSI Crossover

**Apprentice** · Thu Mar 24, 2011 5:18 pm

Your request has been added to developmental cue.


---

## Re: RSI Crossover

**davetherave110179** · Fri Mar 25, 2011 10:43 am

Thanks.


---

## Re: RSI Crossover

**Apprentice** · Fri Mar 25, 2011 10:50 am

Smoothed RSI Update.

I made a few simplifications.
Adapted it for easier use in the Signal and strategy.


---

## Re: RSI Crossover

**Apprentice** · Fri Mar 25, 2011 11:07 am

Requested can be found here.
[http://fxcodebase.com/code/viewtopic.php?f=31&t=3731](https://fxcodebase.com/code/viewtopic.php?f=31&t=3731)


---

## Re: RSI Crossover

**davetherave110179** · Fri Mar 25, 2011 12:20 pm

Apprentice,

There might be some communication issues here, so I will try and ask as simply as possible:

Can you add an EMAIL and SOUND notifications to the EXISTING Smoothed RSI Indicator as NO STRATAGIES can select a DATASOURCE (I only found this out today, sorry).

I am recieving nice crossover signals from the Smoothed_RSI Indicator with a HPF datasource (just need email and sound). Please refer to the image below.

Sorry to be a pain in the rear. Thank you again.

davetherave110179


---

## Re: RSI Crossover

**Apprentice** · Fri Mar 25, 2011 2:46 pm

Clear Request is of great help.
In the original Request, this has not been clearly defined.

As far I know, this is not possible in Easy way.


---

## Re: RSI Crossover

**davetherave110179** · Sat Mar 26, 2011 8:14 am

Hi,

 To further my previous post, I have done some research and it turns out that multiple 'functions' can be created. If logic is right, then seperate EMAIL and SOUND functions can be inserted/created in the Indicator file. Like this:

function SOUND()
 XXXXXXXXXX
end

function EMAIL()
 XXXXXXXXXX
end

All we are doing is calling both the SOUND and EMAIL functions after the rsi has crossed the 50 line, thereby getting around the problem of datasourcing the HPF indicator which cannot be done in a stratagy file.

Would this idea solve the problem?? I am going to try, anyway.

davetherave110179


---

## Re: RSI Crossover

**davetherave110179** · Sat Mar 26, 2011 11:34 am

Hi,

I have attempted what I said in the previous post and I have had no error messages . Can someone take a look at the code and check all is okay as I am not sure what possible errors I am supposed to be looking for. All I know is I am recieving NO error messeges .

If all is okay with the code, can a "BUY" or "SELL" message be attached to the email when the rsi crosses above/below the 50 line??

Much thanks.

davetherave110179

I HAVE REMOVED THE ATTACHED FILE FROM THIS POSTING.


---

## Re: RSI Crossover

**sunshine** · Mon Mar 28, 2011 6:46 am

Hi davetherave,

As fas as I know, it's not possible to include "send email" and "play sound" functionality in the Marketscope indicators using standard functions. Indicators that send e-mails and play sound are called "signals" or "strategies" Why not use signals?

Theoretically you can use separate Lua module for sending emails, but I never tried it.


---

## Re: RSI Crossover

**davetherave110179** · Mon Mar 28, 2011 2:45 pm

Hi,

> As fas as I know, it's not possible to include "send email" and "play sound" functionality in the Marketscope indicators using standard functions.

Noted. I have removed these as they are ineffective.

> Theoretically you can use separate Lua module for sending emails, but I never tried it.

How would I do this? As I have already mentioned in other postings, Marketscope will not allow datasourcing of stratagy elements. So I am having to find another way of generating email and sound from the SMOOTHED_RSI Indicator with a HPF Datasource (as previously mentioned, SMOOTHED_RSI does not lag or repaint).

If you could post the instructions it would be very much appriciated.

davetherave110179


---

## Re: RSI Crossover

**Apprentice** · Tue Mar 29, 2011 3:46 am

The best way to send email and audio messages are the strategies and signals.
We are currently working on Update for HPF and HPFO.
After that we will be able to make the appropriate signals.

I see that you show interest in programming.
The best way to learn the Lua programming language and its capabilities.
[http://www.lua.org/](http://www.lua.org/)
And For the SDK package and its capabilities.
[http://www.fxcodebase.com/documents/Ind ... ntent.html](http://www.fxcodebase.com/documents/IndicoreSDK/web-content.html)

The complete SDK package can be downloaded here
[http://fxcodebase.com/documents/bin/IndicoreSDK.exe](https://fxcodebase.com/documents/bin/IndicoreSDK.exe)

Please, in future posts related to the development of indicators, post within this topic Indicator Development.
[viewforum.php?f=28](https://fxcodebase.com/code/viewforum.php?f=28)


---

## Re: RSI Crossover

**davetherave110179** · Tue Mar 29, 2011 4:30 am

Hi Apprentice,

Thanks for the links. I already got those.

I will, in future post any Indicator questions in the link you mentioned.

Many thanks.

davetherave110179
-----------------------------------------------------------------------------------
**"Logic is something you humans do badly." T'pol to Reed (Star Trek: Enterprise)**


---

## Re: RSI Crossover

**Apprentice** · Fri May 13, 2011 2:32 am

Update


---

## Re: RSI Crossover

**mulligan** · Wed Dec 31, 2014 1:11 pm

I have a request for the Smoothed RSI indicator. It is simply style options for the dots that show on the price when 50 line is crossed. Could you add show, don't show, size, and up down color options. Would be very helpful when I have other indicators with dots on chart.

Thanks very much


---

## Re: RSI Crossover

**Apprentice** · Fri Jan 02, 2015 2:41 am

Additional options added to Smoothed RSI indicator.


---

## Re: RSI Crossover

**easytrading** · Mon Feb 02, 2015 3:25 am

Hello Apprentice,

is it possible to develope Smoothed RSI version supported by Tick Data and also Gives Graphic notification, for 50 line crossover please?

your help is much appreciated.


---

## Re: RSI Crossover

**Apprentice** · Tue Feb 03, 2015 9:24 am

Smoothed RSI with Alert.lua Added.


---

## Re: RSI Crossover

**easytrading** · Tue Feb 03, 2015 12:59 pm

and what about the Smoothed RSI crossover version supported by Tick Data please ?

Best regards.


---

## Re: RSI Crossover

**Apprentice** · Thu Feb 05, 2015 4:00 am

RSI crossover supported for Tick Data added.


---

## Re: RSI Crossover

**easytrading** · Fri Feb 06, 2015 3:24 pm

hello Aprentice,

if you please, could you add HPF,NON-LAG MA and TICK ZIGZAG indicators to the MA method list of Smoothed RSI crossover.
your help is so much appreciated.


---

## Re: RSI Crossover

**Apprentice** · Sun Feb 08, 2015 1:58 am

Your request is added to the development list.


---

## Re: RSI Crossover

**Apprentice** · Wed Feb 24, 2016 11:20 am

Compatibility issue fixed.
_Alert Helper is not longer needed.


---

## Re: RSI Crossover

**Apprentice** · Thu Sep 13, 2018 3:26 am

The indicator was revised and updated.
