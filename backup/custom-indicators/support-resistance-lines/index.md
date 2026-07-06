# Support_Resistance_Lines

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=69170  
> Forum: 17 · Topic 69170 · 23 post(s)


---

## Support_Resistance_Lines

**Apprentice** · Fri Nov 29, 2019 4:51 am

![AUDJPY D1 (11-29-2019 0858).png](images/129996/AUDJPY%20D1%20%2811-29-2019%200858%29.png)



Based on request.
[viewtopic.php?f=27&t=63130](https://fxcodebase.com/code/viewtopic.php?f=27&t=63130)

 [Support_Resistance_Lines.lua](files/129996/Support_Resistance_Lines.lua)

Indicator based strategy.
[viewtopic.php?f=31&t=69171](https://fxcodebase.com/code/viewtopic.php?f=31&t=69171)


---

## Re: Support_Resistance_Lines

**yolerap** · Fri Nov 29, 2019 6:58 am

Hello,

You are impressive for your reactivity !

The strategy can't open position when I used it with backtesting :/
The screenshot shows the strategy when I didn't modified any parameters and when I modified the parameters.

Cordially,


---

## Re: Support_Resistance_Lines

**Apprentice** · Sat Nov 30, 2019 6:19 am

You need to have the latest version of Support_Resistance_Lines.lua installed on your trading station.


---

## Re: Support_Resistance_Lines

**robeen** · Sat Nov 30, 2019 9:15 am

Hi apprentice,
 I have this error when i change the timeframe :

Support_Resistance_Lines_strategy.lua:1418: attempt to perform arithmetic on field '_close_percent' (a nil value)

Thank you


---

## Re: Support_Resistance_Lines

**yolerap** · Mon Dec 02, 2019 2:33 pm

I have the same results that I told you before Apprentice with the latest version of the indicator :/

I hope you can correct this


---

## Re: Support_Resistance_Lines

**Apprentice** · Tue Dec 03, 2019 6:24 am

I can't repeat it. The code looks OK.
WIll run more test on demo.
Can you make sure you are using the latest versions on indicator/strategy?


---

## Re: Support_Resistance_Lines

**yolerap** · Tue Dec 03, 2019 5:43 pm

I don't know what was wrong but now it's working thanks a lot !

Could you just explain what does mean ( for better work )
- the " validation method " : high/low and open/close
- the "zone method" : narrow and wide
- the "tolerance"

Thank you team's Apprentice


---

## Re: Support_Resistance_Lines

**Apprentice** · Fri Dec 06, 2019 2:01 pm

Your request is added to the development list.
Development reference 403.


---

## Re: Support_Resistance_Lines

**Apprentice** · Thu Dec 12, 2019 5:23 pm

the " validation method " : high/low and open/close
What prices to use for the filter of signals
the "zone method" : narrow and wide
Affects filter of signals as well: to use nearest/furthest price to compare with the filter
the "tolerance"
Filter parameter as well. All these parameters depend on each other.


---

## Re: Support_Resistance_Lines

**yolerap** · Tue Feb 25, 2020 7:45 am

Hi,

Could you please add the option " Loockback " for this strategy so :
Insert the number of Supp or Res line before close the position and open a new one.

Thank you,


---

## Re: Support_Resistance_Lines

**Apprentice** · Tue Feb 25, 2020 10:00 am

Your request is added to the development list.
Development reference 778.


---

## Re: Support_Resistance_Lines

**Apprentice** · Wed Feb 26, 2020 5:41 am

I don't understand what changes are needed.
Can you provide a bit more detailed request?


---

## Re: Support_Resistance_Lines

**yolerap** · Wed Feb 26, 2020 2:01 pm

Yes sure,

Look attachment :

There are 4 red lines resistances and 1 green support line.

Conditions to close the positions/open a new one :
We need a second green support line to open buy position.
If I had a short position and there is no second green support line, don't close the current position.

So, if there are 2 red lines, open a short position
If there are 2 green lines, open a buy position

I hope it's possible for you,

Thank you


---

## Re: Support_Resistance_Lines

**Apprentice** · Fri Feb 28, 2020 6:04 am

[Support_Resistance_Lines.lua](files/131570/Support_Resistance_Lines.lua)

 [Support_Resistance_Lines_strategy.lua](files/131570/Support_Resistance_Lines_strategy.lua)

Try this version.


---

## Re: Support_Resistance_Lines

**yolerap** · Fri Feb 28, 2020 12:24 pm

Thank you but it doesn't work,

This message appear ( look attachement ) when I test the strategy ( backtesting and simulation ).
I downloaded the latest version of the indicator.

Could you repear this please ?


---

## Re: Support_Resistance_Lines

**MC. Trend Trader** · Fri Feb 28, 2020 3:25 pm

Hello

I have increased the number of position counts to 4.
The positioncount code is incomplete and is not displayed correctly.

Best regards


---

## Re: Support_Resistance_Lines

**Apprentice** · Sun Mar 01, 2020 3:55 pm

Your request is added to the development list.
Development reference 792.


---

## Re: Support_Resistance_Lines

**Apprentice** · Mon Mar 02, 2020 2:27 pm

It looks like the latest version of the indicator is not installed properly.
Try to refresh your browser and re-download afterwords.


---

## Re: Support_Resistance_Lines

**yolerap** · Tue Mar 03, 2020 1:56 pm

Hi,

I'm sorry but it doesn't work with the latest version.. And I tested too the version 2 posted by Mc Trend Trader, it doesn't work too. These strategy was tested in backtesting and simulation, the same error message appear like my precedent post.
Could you repear this strategy pls ?


---

## Re: Support_Resistance_Lines

**Apprentice** · Wed Mar 04, 2020 5:36 am

Your request is added to the development list.
Development reference 817.


---

## Re: Support_Resistance_Lines

**Apprentice** · Wed Mar 04, 2020 7:41 am

The error indicators that the indicator doesn't have a required stream. I've added that stream in that new version. If you have such an error then you havn't installed the updated indicator.


---

## Re: Support_Resistance_Lines

**Kelly123** · Thu Apr 16, 2020 2:52 am

Apprentice
when use this indicator on multi time frames when you scroll back on the chart the platform freezes can only only log out, Have uninstalled platform and reinstalled platform and the indicator still same problem can you help
Kelly


---

## Re: Support_Resistance_Lines

**Apprentice** · Thu Apr 16, 2020 4:07 am

[Support_Resistance_Lines.lua](files/132887/Support_Resistance_Lines.lua)

Try this version with alert disabled.
