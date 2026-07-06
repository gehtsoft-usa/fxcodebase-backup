# Previous_Week_Tails

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=65136  
> Forum: 17 · Topic 65136 · 16 post(s)


---

## Previous_Week_Tails

**Apprentice** · Mon Oct 02, 2017 5:28 am

![AUDNZD H4 (10-02-2017 1044).png](images/115196/AUDNZD%20H4%20%2810-02-2017%201044%29.png)



Based on.
[viewtopic.php?f=27&t=65125](https://fxcodebase.com/code/viewtopic.php?f=27&t=65125)

 [Previous_Week_Tails.lua](files/115196/Previous_Week_Tails.lua)

 [Previous_Period_Tails.lua](files/115196/Previous_Period_Tails.lua)

 [Previous_Period Wick.lua](files/115196/Previous_Period%20Wick.lua)


---

## Re: Previous_Week_Tails

**Muhammad87** · Mon Oct 02, 2017 12:42 pm

Dear Mario,
Can you make it like pivot show mode, rectangles appear today or Historic (so can easy to back test these zones)

indicator.parameters:addGroup(resources:get("R_STYLE"));
indicator.parameters:addString("ShowMode", resources:get("R_SMODE"), resources:get("R_SMODE1"), "TODAY");
indicator.parameters:addStringAlternative("ShowMode", resources:get("R_SMODE_O1"), "", "TODAY");
indicator.parameters:addStringAlternative("ShowMode", resources:get("R_SMODE_O2"), "", "HIST");


---

## Re: Previous_Week_Tails

**Muhammad87** · Mon Oct 02, 2017 7:00 pm

Dear Mario,
In the following line of the code:
 WeekSource = core.host:execute("getSyncHistory",source:instrument() , "W1", true,2 ,4, 3);

Opening Gaps will not appear as The trading station will take the close of previous week the open of current week. Is there a way to begin the weekly data with the open of the first trading candle.
e.g. for this week on EURUSD (1st candle 1st october 17:00 EST, and open 1.17879 on the weekly chart the open is 1.18114 as the previous week close)


---

## Re: Previous_Week_Tails

**Apprentice** · Tue Oct 03, 2017 2:52 am

Your request is added to the development list under Id Number 3914


---

## Re: Previous_Week_Tails

**Apprentice** · Tue Nov 28, 2017 6:04 am

Try this version.

 [Previous_Week_Tails.lua](files/116263/Previous_Week_Tails.lua)


---

## Re: Previous_Week_Tails

**Apprentice** · Tue Jul 03, 2018 7:07 am

The Indicator was revised and updated.


---

## Re: Previous_Week_Tails

**fjasonfx** · Tue Jul 03, 2018 10:42 am

Apprentice,

 If it is not too much could we get this to where it would show the previous tails on all the other time frames? Thanks!

Jason


---

## Re: Previous_Week_Tails

**Apprentice** · Wed Jul 04, 2018 1:28 pm

Previous_Period_Tails added.


---

## Re: Previous_Week_Tails

**fjasonfx** · Thu Jul 05, 2018 1:08 am

It looks like only the upper tails are being displayed.


---

## Re: Previous_Week_Tails

**fjasonfx** · Wed Jul 11, 2018 12:46 pm

Hi Apprentice,
 Whenever you get a chance(as I know you are an extremely busy person) could you get the Previous Period Tails indicator to show both the upper and lower tails? It only is showing the upper tails on the previous candle now. Oh and if it is possible could we get a historical mode?

Thanks,
Jason


---

## Re: Previous_Week_Tails

**Apprentice** · Wed Jul 11, 2018 7:27 pm

Try it now.


---

## Re: Previous_Week_Tails

**fjasonfx** · Wed Jul 11, 2018 10:33 pm

Sorry but now it looks like it is showing from the open to the low. Would like for it to show just the previous upper and lower wicks. Thanks!


---

## Re: Previous_Week_Tails

**Apprentice** · Thu Jul 12, 2018 4:29 am

Previous_Week_Tails.lua is coded in this way.


---

## Re: Previous_Week_Tails

**fjasonfx** · Thu Jul 12, 2018 10:57 am

Oh ok. Maybe I just need to request a totally new indicator that will show the previous period candle upper and lower wick/tail zones. Something like this. Thanks!


---

## Re: Previous_Week_Tails

**Apprentice** · Fri Jul 13, 2018 4:04 am

Previous_Period Wick.lua added.


---

## Re: Previous_Week_Tails

**fjasonfx** · Fri Jul 13, 2018 4:09 pm

That looks great Apprentice. Thank you!
