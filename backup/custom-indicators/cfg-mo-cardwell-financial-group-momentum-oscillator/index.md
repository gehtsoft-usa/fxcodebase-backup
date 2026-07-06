# CFG MO (Cardwell Financial Group Momentum Oscillator)

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=3007  
> Forum: 17 · Topic 3007 · 54 post(s)


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Laurus12** · Thu Nov 17, 2011 2:24 pm

Hello Nikolay,

I have tried to import the CFG MO with the new TS II November 2011 release, but it reports an error message.

The message is as follows: "cfg_mo.bin - Error - Failed to load the indicator from the file ".....\cfg_mo.bin". The error details: The file format or version is invalid."

If a compatibility issue, could you please update the version posted so it is compatible with the new TS II version?

Thanks,
Laurus


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**oxfordj** · Thu Nov 17, 2011 9:52 pm

Nikolay,

I too am receiving the same error msg as the prior user. The Marketscope version is in a binary format rather than .lua


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**vstrelnikov** · Fri Nov 18, 2011 1:25 pm

New binary version for Marketscope 01.11.102511 added in the top post.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**billmc** · Sun Nov 20, 2011 10:18 am

hi cant seem to get this into marekscope, does not have a .lua extension and wont come into my charting, get error.. am i oing something wrong. used to just downloading the .lua and then loading into my batch of indicators,,, thanks much


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Sun Nov 20, 2011 6:07 pm

Strange, Vasiliy have this update bin file.
But you're also should by now have an updated TS.
I would that one thing.
Can you download and install a new version of TS from FXCM site.
But First Download bin file for Marketscope version 01.11.102511.
(Top Most Post)


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**fabfxcm** · Tue Dec 27, 2011 11:49 am

This indicator seems very interesting. Could you please develop a strategy based on it?
Thank you


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Wed Dec 28, 2011 5:26 am

Can you describe the conditions, rules, that this strategy should respect.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**fabfxcm** · Thu Dec 29, 2011 10:11 am

Here my idea for the strategy:
Sell when MO line cross the first smooth line (from up to down or the first smooth line must be over the second smooth line) with an option of confirmation when the MO cross the second smooth line, and when the first smooth line cross the second smooth line.
Buy when MO line cross the first smooth line (from down to up or the first smooth line must be below the second smooth line) with an option of confirmation when the MO cross the second smooth line and when the first smooth line cross the second smooth line.
I hope it's not too complicated.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Thu Dec 29, 2011 6:46 pm

Your request is added to the developmental cue.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**waffle** · Sun Apr 01, 2012 3:47 am

Hi, can you please update the download for marketscope 2.0? Thanks


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Sun Apr 01, 2012 10:34 am

You probably are using the old version,
Download and install version for Marketscope 01.11.102511


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Blackcat2** · Sun Apr 01, 2012 3:23 pm

Is it possible to create an indicator (not signal) to interpret this indicator just like what Nikolay did for TDI ([viewtopic.php?f=17&t=4133](https://fxcodebase.com/code/viewtopic.php?f=17&t=4133)). It'll say when to go long, short, etc... That'll be awesome

Thanks..
BC


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**waffle** · Sun Apr 01, 2012 7:13 pm

> **Apprentice wrote:**
> You probably are using the old version,
> Download and install version for Marketscope 01.11.102511

No, marketscope 2.0 is the newest version, I downloaded it about two weeks ago.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Mon Apr 02, 2012 4:51 am

I'm talking about the new version of indicator.
I have delete old version, for some time there were two of them.
Look for new version on Topmost Post.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Tue Apr 03, 2012 1:46 am

to fabfxcm
Requested can be found here.
[viewtopic.php?f=31&t=15522](https://fxcodebase.com/code/viewtopic.php?f=31&t=15522)


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**waffle** · Tue Apr 03, 2012 4:26 am

> **Apprentice wrote:**
> to fabfxcm
> Requested can be found here.
> [viewtopic.php?f=31&t=15522](https://fxcodebase.com/code/viewtopic.php?f=31&t=15522)

Thankyou


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**rose123** · Wed Aug 29, 2012 9:36 am

hi,

can you create divergence strategy

 buy : bullish divergence of mo and mo in between sm2 and sm3
and mo < oversold level (-70)

 sell: bearish divergence of mo and mo in between sm2 and sm3
and mo > overbought level (70)


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Thu Aug 30, 2012 5:16 pm

Your request is added to the development list.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**compulsive** · Sat Jan 19, 2013 8:01 pm

Hi Apprentice,

Is it possible for you to add a sound alert when ever the MO went touch a number....I am using 99.0000 and the top side and 1.000 on the bottom side.

Tks

Compulsive


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Mon Jan 21, 2013 5:38 am

CFG_MO with Alert Added, See TopMost Post.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**compulsive** · Mon Jan 21, 2013 7:43 am

> **Apprentice wrote:**
> CFG_MO with Alert Added, See TopMost Post.

Thank you----manually it will play the alert, but it will not play automatically - do you know what could cause it not to?


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Wed Jan 23, 2013 8:34 am

Have u install and activated Alert Signal ( _Alert.lua)
It is necessary to have Audio & Email Alerts.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**compulsive** · Wed Jan 23, 2013 10:54 am

> **Apprentice wrote:**
> Have u install and activated Alert Signal ( _Alert.lua)
> It is necessary to have Audio & Email Alerts.

See attached - gives me an error


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Wed Jan 23, 2013 12:16 pm

_Alert in not Indicator.
It is Strategy, Signal.

Here u can read How to Download and Install a Custom Signal/Strategy
[viewtopic.php?f=31&t=2310](https://fxcodebase.com/code/viewtopic.php?f=31&t=2310)


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**compulsive** · Wed Jan 23, 2013 10:16 pm

> **Apprentice wrote:**
> _Alert in not Indicator.
> It is Strategy, Signal.
>
> Here u can read How to Download and Install a Custom Signal/Strategy
> [viewtopic.php?f=31&t=2310](https://fxcodebase.com/code/viewtopic.php?f=31&t=2310)

 thank you


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**compulsive** · Fri Feb 08, 2013 7:59 pm

Hello Apprentice,

is it possible to add a rate level of 50 to the oscillator.

Thank you


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Sun Feb 10, 2013 8:25 am

Central Line Added to CFG_MO with Alert.bin.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**compulsive** · Wed Feb 13, 2013 10:41 pm

> **Apprentice wrote:**
> Central Line Added.

Thank you - is it possible to instead of adding the central line to have as an option the Fibonacci Retracement added from 100 to zero **or**the Gann Retracement from 100 to zero (either or, extends both start and end) and if you can to adjust the font size as an option for the percentages?

Tks

Greatly appreciated
Compulsive


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Blackcat2** · Thu Feb 14, 2013 4:00 am

Hi,

I've downloaded the most recent .bin file but couldn't see the central lines. Where can I get the right file?

Cheers..
BC


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Thu Feb 14, 2013 4:10 am

Sorry, Central Line was Added to CFG_MO with Alert.bin only.
Compulsive,Your request is added to the development list.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**compulsive** · Thu Feb 21, 2013 10:44 pm

Just wanted to know if this is in the process to be added


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Fri Feb 22, 2013 3:39 am

If u are asking about CFG_MO with Alert.bin make sure to install and have activate _Alert.lua Signal. _Alert is not indicator, it activated same as Signal/Strategy.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**compulsive** · Fri Feb 22, 2013 8:49 am

> **compulsive wrote:**
>
>
> > **Apprentice wrote:**
> > Central Line Added.
>
>
>
>
> Thank you - is it possible to instead of adding the central line to have as an option the Fibonacci Retracement added from 100 to zero **or**the Gann Retracement from 100 to zero (either or, extends both start and end) and if you can to adjust the font size as an option for the percentages?
>
> Tks
>
> Greatly appreciated
> Compulsive

This is what I am asking


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Sat Feb 23, 2013 7:41 am

Unfortunately not.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**compulsive** · Sun Feb 24, 2013 8:54 pm

> **Apprentice wrote:**
> Unfortunately not.

ok...why is that? I am not a programmer but you were able to add a center line, why cant the FIB be added? Or is it because is a copy right material?

Tks

Compulsive


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Mon Feb 25, 2013 5:40 am

Unfortunately I have not found the time for this task.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**compulsive** · Thu Jun 13, 2013 10:12 am

anything?

 is it possible to instead of adding the central line to have as an option the Fibonacci Retracement added from 100 to zero or the Gann Retracement from 100 to zero (either or, extends both start and end) and if you can to adjust the font size as an option for the percentages?


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**veyron89890** · Fri Jan 16, 2015 12:00 pm

can somebody tell me where i can find this inidicator in.jar file ?


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Mon Jan 19, 2015 4:00 am

Here you will not find support for .jar
Can you specify what your target platform?


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**veyron89890** · Mon Jan 19, 2015 4:53 am

> **Apprentice wrote:**
> Here you will not find support for .jar
> Can you specify what your target platform?

I use motivewave [http://www.motivewave.com/](http://www.motivewave.com/)


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Tue Jan 20, 2015 3:13 am

Unfortunately for now we do not have the interests of resources to provide support for this platform. Can you introduce new indicators to MotiveWave?


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Mon Dec 14, 2015 4:01 am

Compatibility issue Fix. _Alert helper is not longer needed.

If you want to use updated version of this indicator,
please make sure to use TS Version 01.14.101415. or higher.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**compulsive** · Thu Feb 04, 2016 6:32 am

Can you turn this code into EASYLANGUAGE?


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Fri Feb 05, 2016 7:52 am

EasyLanguage is not my primary interest.
Anyone?


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Thu Aug 24, 2017 9:09 am

The indicator was revised and updated.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Tue Sep 18, 2018 6:39 am

Bump up.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**TheIntuitiveOne** · Fri Nov 20, 2020 2:27 am

Does a download of CFG MO exist for ThinkorSwim?

Thx


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Fri Nov 20, 2020 3:09 am

Not that I know.


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**TheIntuitiveOne** · Fri Nov 20, 2020 3:31 am

How best to get this done, and at what cost?


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**SunnyTA** · Tue Mar 16, 2021 11:48 pm

Hi,

I need some help to review the CFG indicator that I created in pinescript.
I am not a developer so not sure if I captured the parameters correctly so would really appreciate if someone could review the code


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**SunnyTA** · Tue Mar 16, 2021 11:55 pm

> **Nikolay.Gekht wrote:**
> The copyright owner and creator of CFG MO (Cardwell Financial Group Momentum Oscillator) is Cardwell Finacial Group and Andrew Cardwell. The indicator is copyrighted at the United States Copyright Office as "Relative Strength Index : advanced/by Andrew E. Cardwell, Jr." with registration/date number TX0003375191 / 1992-07-22.
>
> For more details about this indicator and other indicators and methods developed my Mr. Andrew Cardwell, please visit [http://cardwellrsiedge.com](http://cardwellrsiedge.com) or contact Mr. Andrew Cardwell at cardwellrsi(at)hotmail(dot)com.
>
> This implementation is done by the fxcodebase team upon Mr. Andrew E. Cardwell's permission.
>
> If you would like to publish the indicator on your website, please do not forget to include the copyright notice and the entire description of the indicator too. Think of this as of the part of the license agreement. Any reverse engineering or reproducing of this indicator without Andrew Cardwell's permission is a violation of the United States Copyright law.
>
> Please note that this indicator is sometimes wrongfully referred to as Constance M. Brown's composite index indicator. If you come across this indicator on the Internet, please help us all to right a wrong and provide people with a reference to the CFG MO indicator.
>
> The description of the indicator below is provided by Lars Kjoes.
>
> Simply put formula for warning when RSI is failing to detect market reversals. I have added a picture with points and descriptions below. Note the differences highlighted with pink lines in the picture:
>
>
>
> snapshot.png
>
>
>
> - Point A: The CFG MO shows a positive reversal when RSI is not. Also note that the MO turns about on the slower moving average which signifies support. The averages are also showing positive spread. Both the latter clarifies the reversal signal. Also note that IF support had been at a point where the averages had crossed and the faster on the way up, this would be a strong continuation signal.
>
> - Point B: The CFG MO shows divergence when RSI does not. Again note the turning point in CFG MO with the fast moving average as resistance.
>
> - Point C: As in point B the turning point is with resistance of the faster moving average.
>
> - Note that this is in a 60min chart and these relatively clear signals would not necessarily show up in other time frames. For example at a reversal in the 60min chart the MO would not show any MA signals, but in 4hours it could give a strong reversal or divergence signal straight on a MA-crossing.
>
> Downloads:
>
>
>
> cfg_mo.bin
>
>
>
>
> CFGMO.ex4
>
>
>
>
> CFG_MO.fxd
>
>
>
>
> CFGMomentumOscillator.vtscr
>
>
>
>
>
> Alert.png
>
>
> This indicator provides Audio / Email Alerts if and when CFG MO cross over/under defined Overbought/Oversold levels.
>
>
> CFG_MO with Alert.bin
>
>
>
> Compatibility issue Fix. _Alert helper is not longer needed.
>
> If you want to use updated version of this indicator,
> please make sure to use TS Version 01.14.101415. or higher.

Hi,

I tried creating the CFG indicator in pinescript.
I am not a developer so would really appreciate if you could review the code and confirm if it is rightly coded


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**sunnybrampton2016** · Sat Mar 23, 2024 4:46 pm

hello, can you provide the code with lua extension


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Wed Mar 27, 2024 10:25 am

Do you have the source for any platform?

We have added your request to the development list.
Development reference 271


---

## Re: CFG MO (Cardwell Financial Group Momentum Oscillator)

**Apprentice** · Thu Dec 05, 2024 12:08 pm

It’s a proprietary indicator. The source code is not available.
