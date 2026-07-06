# Valid Swing HighLow

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61768  
> Forum: 17 · Topic 61768 · 17 post(s)


---

## Valid Swing HighLow

**Apprentice** · Fri Jan 30, 2015 12:13 pm

![Valid Swing HighLow.png](images/98396/Valid%20Swing%20HighLow.png)



Based on request.
[viewtopic.php?f=27&t=61760](https://fxcodebase.com/code/viewtopic.php?f=27&t=61760)
Will only show relevant/valid/unbroken swings.

 [Valid Swing HighLow.lua](files/98396/Valid%20Swing%20HighLow.lua)

 [Valid Swing HighLow With Alert.lua](files/98396/Valid%20Swing%20HighLow%20With%20Alert.lua)


---

## Re: Valid Swing HighLow

**jay1994** · Fri Jan 30, 2015 9:10 pm

Is there a MQ4L version of this indicator?


---

## Re: Valid Swing HighLow

**newton** · Sat Jan 31, 2015 1:59 am

hi,

can you add

HH---H > PREVIOUS H
HL---H<PREVIOUS H
LL--- L< PREVIOUS L
LH-- L> PREVIOUS L

AND YES/ NO OPTION TO SHOW HH,HL,LL,LH

THANK YOU


---

## Re: Valid Swing HighLow

**Apprentice** · Sat Jan 31, 2015 9:09 am

Broad Definition Option Added.


---

## Re: Valid Swing HighLow

**Apprentice** · Sat Jan 31, 2015 9:57 am

MQ4 version can be found here.
[viewtopic.php?f=38&t=61769](https://fxcodebase.com/code/viewtopic.php?f=38&t=61769)


---

## Re: Valid Swing HighLow

**4x4partners** · Thu Apr 23, 2015 4:35 am

Hi Apprentice,

Really appreciate this indicator - although I'm getting mixed results. On H1 chart, it seems to work well. But on 30min it seems less accurate. For example, why are so many of the Swing Hi/Low's not on this 30min chart ?

In particular, you'll notice that there are a whole bunch of LL's that don't show up.

I would assume that after a HH (and a HL) are posted, when a LH follows, the indy should be on lookout for a LL - and vice versa. Is that correct??

If you don't mind to have a look at the attached it would be extremely helpful.

Thanks a lot
4x4


---

## Re: Valid Swing HighLow

**4x4partners** · Fri Apr 24, 2015 7:48 am

Hi again,

I think I see what the issue is, or at least part of the issue.

For example I just noticed a HH that was marked as LH - and then I did a test and changed the font size (to force it to update), and it changed it to HH.

Would you mind to have a look? I can send screenshots if you like.

Thanks
4x4


---

## Re: Valid Swing HighLow

**Apprentice** · Mon Apr 27, 2015 2:24 am

This behavior is defined by the initial request.
[viewtopic.php?f=27&t=61760](https://fxcodebase.com/code/viewtopic.php?f=27&t=61760)


---

## Re: Valid Swing HighLow

**4x4partners** · Mon Apr 27, 2015 7:03 am

The issue I'm referring to is one regarding the updating of the indicator. For example, I just tested again. If I go and change the font (forcing it to update) the recent LH was changed to HH.

However if I don't change the font, it stays as it was.

Does this make sense?

I will take screenshots at next interval.

Thanks


---

## Re: Valid Swing HighLow

**4x4partners** · Mon Apr 27, 2015 3:30 pm

Hi Apprentice,

Have a look at the below two screenshots.

They were taken within minutes of one another on the same chart.

The first is before refreshing the indicator, the second is after clicking on it and changing the font size (just to force an update).

 

![VALID SWING - 30MN 042715.png](images/100078/VALID%20SWING%20-%2030MN%20042715.png)



 

![VALID SWING - 30MN 042715 Refresh.png](images/100078/VALID%20SWING%20-%2030MN%20042715%20Refresh.png)


---

## Re: Valid Swing HighLow

**Apprentice** · Fri Jul 28, 2017 8:53 am

The indicator was revised and updated.


---

## Re: Valid Swing HighLow

**Cactus** · Fri Jul 28, 2017 6:32 pm

Good indicator.
Can you add the following:
Explanation:
Fibonacci retracement (plotted from L (0) to H(1))
Fibonacci level = price level of said retracement, for example, 61.8%)

Can you make it so that:
- User can apply fibonacci levels on each L/H pair
- Decide quantity of fibonacci retracements (lookback)
- And choose which levels to set (10 levels in settings, 1(100%,H), 0(0%,L) and 8 custom)
- Add output streams for each level, for example:
with 5 previous retracements
Example output stream reading for 3rd lookback retracement, custom level 2:
"Retracement3,Level2(78.6%) [PRICE]"

And option to have X possible combinations of a retracement (not permutations): for example.
one L joining with multiple H's
L1 with H2 = Retracement1
L1 with H3 = Retracement2
L2 with H6 = Retracement3
etc.

Index of H must always be more recent than L (can't join L to H from right to left)
In other words L must always be Level 0(100%) reading.

Not only show line of levels ((horizontal) output streams) but also the line how L and H are joined (normal line (diagonal) from 0% to 100% without output)

Hope this makes sense.


---

## Re: Valid Swing HighLow

**Apprentice** · Sat Jul 29, 2017 9:11 am

Your request is added to the development list, Under Id Number 3830
 If someone is interested to do this task, please contact me.


---

## Re: Valid Swing HighLow

**Apprentice** · Wed Oct 03, 2018 5:49 am

The indicator was revised and updated.


---

## Re: Valid Swing HighLow

**enotikos** · Tue Aug 03, 2021 4:30 am

Hi,
could you add a simple alert?

thx


---

## Re: Valid Swing HighLow

**Apprentice** · Wed Aug 04, 2021 4:59 am

Your request is added to the development list.
Development reference 717.


---

## Re: Valid Swing HighLow

**Apprentice** · Thu Aug 05, 2021 7:53 am

Valid Swing HighLow With Alert.lua added.
