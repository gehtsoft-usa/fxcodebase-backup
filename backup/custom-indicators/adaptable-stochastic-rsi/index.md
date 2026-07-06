# Adaptable Stochastic RSI

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=22756  
> Forum: 17 · Topic 22756 · 11 post(s)


---

## Adaptable Stochastic RSI

**Apprentice** · Mon Aug 27, 2012 11:00 am

![Adaptable StochRSI.png](images/39268/Adaptable%20StochRSI.png)



This version allows the user to choose the method of smoothing for K and D lines.
Default method is MVA (simple moving average).

 [Adaptable StochRSI.lua](files/39268/Adaptable%20StochRSI.lua)

The indicator was revised and updated


---

## Re: Adaptable Stochastic RSI

**Alexander.Gettinger** · Mon Nov 17, 2014 5:09 pm

MQL4 version of Adaptable Stochastic RSI oscillator: [viewtopic.php?f=38&t=61452](https://fxcodebase.com/code/viewtopic.php?f=38&t=61452).


---

## Re: Adaptable Stochastic RSI

**Coondawg71** · Mon Apr 13, 2015 8:54 am

Can we please request Alert functions added to this version of Adaptable Stochastic RSI, same Alert functions as what is offered in Stochastic RSI but that indicator incurs errors and is not usable.

Thanks!

sjc


---

## Re: Adaptable Stochastic RSI

**Apprentice** · Mon Apr 13, 2015 9:29 am

Have tested abovementioned indicator.
Nothing came up. Can you specify the error that you experience.


---

## Re: Adaptable Stochastic RSI

**Coondawg71** · Mon Apr 13, 2015 10:50 am

lua 532, lua 19 : first parameter must be a string

indicator will load, but once a user changes which alerts they want activated is when it goes into error

sjc


---

## Re: Adaptable Stochastic RSI

**TxChristopher** · Tue Nov 03, 2015 10:02 am

I get this same error. The indicator is great but crashes when you need it most.

An error occurred during the calculation of the indicator 'STOCHASTIC RSI WITH ALERT'. The error details: Stochastic RSI with Alert.lua:532: _Alert.lua:19: The first parameter must be a string.


---

## Re: Adaptable Stochastic RSI

**Apprentice** · Wed Nov 04, 2015 8:13 am

Do you have Active _Alert.lua Helper?


---

## Re: Adaptable Stochastic RSI

**TxChristopher** · Wed Nov 04, 2015 9:45 am

Yes. I use it with the Stochastic with Alert indicator, which works flawlessly. I wish the Stochastic RSI one would function as cleanly and in the same fashion but it crashes as mentioned before when it comes time for it to send its alert out.

log below, (email address redacted) the log does not show the Stochastic RSI because it errors so I have alerts off for it, but if it were then the log would be filled with errors.

Symbol	Strategy/Indicator	Message	Time

EUR/USD	_Alert	An e-mail with notification has been successfully sent to '**********@******.com', subject: 'STOCHASTIC WITH ALERT'.	11/04/2015 00:00:03
EUR/USD	_Alert	An e-mail with notification has been successfully sent to '**********@******.com', subject: 'STOCHASTIC WITH ALERT'.	11/02/2015 08:08:34
EUR/USD	_Alert	An e-mail with notification has been successfully sent to '**********@******.com', subject: 'STOCHASTIC WITH ALERT'.	11/02/2015 07:47:04
EUR/USD	_Alert	An e-mail with notification has been successfully sent to '**********@******.com', subject: 'STOCHASTIC WITH ALERT'.	11/02/2015 00:00:02
EUR/USD	_Alert	An e-mail with notification has been successfully sent to '**********@******.com', subject: 'STOCHASTIC WITH ALERT'.	11/01/2015 20:00:01
EUR/USD	_Alert	An e-mail with notification has been successfully sent to '**********@******.com', subject: 'STOCHASTIC WITH ALERT'.	11/01/2015 18:05:51
EUR/USD	_Alert	An e-mail with notification has been successfully sent to '**********@******.com', subject: 'STOCHASTIC WITH ALERT'.	11/01/2015 17:18:30
EUR/USD	_Alert	An e-mail with notification has been successfully sent to '**********@******.com', subject: 'STOCHASTIC WITH ALERT'.	10/31/2015 14:02:29
EUR/USD	_Alert	_Alert is started.	10/31/2015 14:02:27
 Connection with the chart server has been restored.	10/31/2015 14:02:24
EUR/USD	_Alert	_Alert is stopped.	10/30/2015 18:10:35
 Connection with the chart server has been lost. Until the connection is restored, existing charts will not download additional historical data, strategies will be paused and creation of new charts is disabled.	10/30/2015 18:10:35
EUR/USD	_Alert	An e-mail with notification has been successfully sent to '**********@******.com', subject: 'STOCHASTIC WITH ALERT'.	10/29/2015 18:44:11
EUR/USD	_Alert	_Alert is started.	10/29/2015 16:05:09


---

## Re: Adaptable Stochastic RSI

**TxChristopher** · Wed Nov 04, 2015 3:41 pm

Also while you are looking at this indicator can crossovers of the K and D lines under and over be alerted like the "Stochastic with Alert" indicator? Sometimes it gets close enough to oversold or overbought and crosses back the other way but there is no mechanism to catch those like there is with "Stochastic with Alert.lua"


---

## Re: Adaptable Stochastic RSI

**Apprentice** · Fri Nov 06, 2015 4:45 am

Try upadated version.
[viewtopic.php?f=17&t=451&hilit=Stochastic+RSI+with+Alert](https://fxcodebase.com/code/viewtopic.php?f=17&t=451&hilit=Stochastic+RSI+with+Alert)


---

## Re: Adaptable Stochastic RSI

**Apprentice** · Sat Aug 05, 2017 4:31 am

The indicator was revised and updated.
