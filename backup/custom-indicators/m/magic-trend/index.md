# Magic Trend

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=3144  
> Forum: 17 · Topic 3144 · 20 post(s)


---

## Magic Trend

**Apprentice** · Wed Jan 05, 2011 10:16 am

![Magic Trend.png](images/7372/Magic%20Trend.png)



IF CCI >= 0 then
 MAGIC = max(previous MAGIC, LOW - ATR())
else
 MAGIC = min(previous MAGIC, HIGH + ATR())
end

 [Magic Trend.lua](files/7372/Magic%20Trend.lua)

 [Magic Trend with Alert.lua](files/7372/Magic%20Trend%20with%20Alert.lua)

 [Magic Trend Overlay.lua](files/7372/Magic%20Trend%20Overlay.lua)

Indicator-Based strategy
[https://fxcodebase.com/code/viewtopic.php?f=31&t=71684](https://fxcodebase.com/code/viewtopic.php?f=31&t=71684)


---

## Re: Magic Trend

**macogi37** · Tue Jan 11, 2011 2:08 pm

Hi Apprentice,
there is a strategy for this indicator?
 would be nice to be able to test ...
Thanks


---

## Re: Magic Trend

**Apprentice** · Tue Jan 11, 2011 2:54 pm

Moved From Beta Subforum.


---

## Re: Magic Trend

**Apprentice** · Wed Sep 21, 2011 3:57 am

Required can be found here.
[viewtopic.php?f=31&t=6681](https://fxcodebase.com/code/viewtopic.php?f=31&t=6681)


---

## Re: Magic Trend

**RJH501** · Sun Oct 16, 2011 1:57 pm

The strategy will not trade US account.

Your assistance will be appreciated.

Richard


---

## Re: Magic Trend

**Apprentice** · Mon Oct 17, 2011 2:31 am

I was not able to repeat this one.
I continue testing.


---

## Re: Magic Trend

**fxcyberman** · Tue Jul 16, 2013 10:28 pm

When does it show green or red color ?
Which criteria reached ?


---

## Re: Magic Trend

**Apprentice** · Wed Jul 17, 2013 3:57 am

Green
If Line goes Up
Red
If Line goes Down
Gray for Flat


---

## Re: Magic Trend

**Alexander.Gettinger** · Thu Aug 29, 2013 11:03 am

MQL4 version of Magic Trend indicator: [http://www.fxcodebase.com/code/viewtopi ... 38&t=59351](http://www.fxcodebase.com/code/viewtopic.php?f=38&t=59351).


---

## Re: Magic Trend

**Apprentice** · Fri Sep 06, 2013 6:28 am

Updated.


---

## Re: Magic Trend

**jamrocktrader** · Thu Nov 19, 2015 7:13 am

Hey Apprentice

Could you please add a 'live/end of turn' option and an audio alert to the magic trend indicator. _Alert.lua would be use to trigger the alarm.

Also the indicator does not refreshes automatically. Could you look in that.

Thank you


---

## Re: Magic Trend

**Apprentice** · Tue Nov 24, 2015 5:12 am

Magic Trend with Alert.lua added.


---

## Re: Magic Trend

**jamrocktrader** · Tue Nov 24, 2015 7:54 am

Excellent work. Thank you.


---

## Re: Magic Trend

**Apprentice** · Wed Dec 02, 2015 5:55 am

Compatibility issue fixed.
_Alert Helper is not longer needed.


---

## Re: Magic Trend

**Apprentice** · Sat Aug 05, 2017 4:22 am

The indicator was revised and updated.


---

## Re: Magic Trend

**easytrading** · Wed Jul 11, 2018 4:14 pm

Hello Apprentice,

if you please, could we have price overlay for Magic Trend.lua with my appreciation.


---

## Re: Magic Trend

**Apprentice** · Thu Jul 12, 2018 8:17 am

Magic Trend Overlay.lua added.


---

## Re: Magic Trend

**Fernas** · Thu Jul 12, 2018 9:57 am

Hello

it seems that the indicator is insensitive to CCI periods. I have changed the value of CCI period from 5 to 50 range with no effect what so ever on the indicator (EUR-USD Daily chart). Could you please confirm this observation.


---

## Re: Magic Trend

**jaminjermaine** · Sun Sep 30, 2018 4:08 pm

Can the trade amount in lots be modified to accept more than 100k?


---

## Re: Magic Trend

**Apprentice** · Mon Oct 01, 2018 5:00 am

Try it now.
