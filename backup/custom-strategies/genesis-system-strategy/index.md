# Genesis System Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=61770  
> Forum: 31 · Topic 61770 · 12 post(s)


---

## Genesis System Strategy

**Apprentice** · Mon Feb 02, 2015 6:10 am

![Genesis System Strategy.png](images/98424/Genesis%20System%20Strategy.png)



Based on Genesis System Heat Map.
[viewtopic.php?f=17&t=60294](https://fxcodebase.com/code/viewtopic.php?f=17&t=60294)
Open Long
All four Long consensus
Open Short
All four Short consensus

Exit (Option)
If we do not have consensus.

 [Genesis System Strategy.lua](files/98424/Genesis%20System%20Strategy.lua)


---

## Re: Genesis System Strategy

**Apprentice** · Tue Nov 15, 2016 2:50 am

I could not reproduce it.


---

## Re: Genesis System Strategy

**jetaro** · Tue Nov 15, 2016 8:49 am

> **jaricarr wrote:**
> Hello Apprentice and jetaro,
>
> The strategy continues to produce a problem with the CCI Histogram.

jaricarr, that is a different problem. As it says in your error message, you must install the CCI_Histogram indicator.

[download/file.php?id=11118](http://www.fxcodebase.com/code/download/file.php?id=11118)


---

## Re: Genesis System Strategy

**jaricarr** · Wed Nov 16, 2016 12:06 am

I was able to download and reinstall the CCI Histogram.


---

## Re: Genesis System Strategy

**Apprentice** · Sun Dec 18, 2016 10:18 am

Strategy was revised and updated.


---

## Re: Genesis System Strategy

**spinemaligna** · Fri Jan 05, 2018 6:14 am

Firstly Happy New Year from Scotland to everyone.

This is the error message I get when running the strategy. I am on a four hour chart in simulation mode. I have installed the most up to date version I think.

C:/Program Files (x86)/Candleworks/FXTS2/Strategies/Custom/Genesis System Strategy.lua:358: C:/Program Files (x86)/Candleworks/FXTS2/Indicators/Custom/CCI_Histogram.lua (122, -1) : E19 - Specified index is out of range.

If I can get this working then I will request a modification to the strategy to have the signal confirmed by a higher time frame version of the Genesis indicator. Could you indicate if this is possible.

Many thanks.

Ross


---

## Re: Genesis System Strategy

**Apprentice** · Sun Jan 07, 2018 5:15 am

Try to use my version.


---

## Re: Genesis System Strategy

**spinemaligna** · Wed Jan 10, 2018 1:00 pm

Hi
I uninstalled the strategy and reinstalled the one on this page and the problem persists I'm afraid.

Ross


---

## Re: Genesis System Strategy

**spinemaligna** · Fri Jan 19, 2018 3:51 pm

Success,

I have now got the strategy working. Could I ask for a further embellishment in the addition of a second longer time frame iteration of the genesis matrix to confirm the signal. The signal will be given when the short time frame bar closes with all four indicators in unison and the long term version, at that moment, also agrees. The option to have the confirmation or not would be given.

Thanks,

Ross


---

## Re: Genesis System Strategy

**Apprentice** · Wed Jan 24, 2018 7:21 am

Your request is added to the development list under Id Number 4023


---

## Re: Genesis System Strategy

**Apprentice** · Wed Feb 21, 2018 5:44 am

[Genesis System Strategy.spinemaligna.lua](files/117834/Genesis%20System%20Strategy.spinemaligna.lua)

Try this version.


---

## Re: Genesis System Strategy

**spinemaligna** · Thu Mar 01, 2018 2:37 pm

Thanks for your work. Testing it now

Ross
