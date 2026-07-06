# KueFx_Lines_EA

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=75497  
> Forum: 38 · Topic 75497 · 13 post(s)


---

## KueFx_Lines_EA

**Apprentice** · Wed Jan 15, 2025 4:19 am

![Snimka zaslona 2025-01-15 101818.png](images/157808/Snimka%20zaslona%202025-01-15%20101818.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.php?f=17&t=75479](https://fxcodebase.com/code/viewtopic.php?f=17&t=75479)

 [KueFx Lines.mq5](files/157808/KueFx%20Lines.mq5)

 [KueFx_Lines_EA_v1.00.mq5](files/157808/KueFx_Lines_EA_v1.00.mq5)


---

## Re: KueFx_Lines_EA

**trigga** · Wed Jan 15, 2025 3:59 pm

THE KUEFX LINES EA IS MISSING THE RULES , I HAVE ATTACHED ANOTHER PICTURE TO EXPLAIN HOW I WANT IT TO WORK because it is not following the rules and it is missing entries and not opening entries according to the ules

WITH NO REPAINT MODE SET TO TRUE

RED major signal SHOULD OPEN A sell
BLUE major signal SHOULD OPEN A buy
with close on opposite

you can disable the minor signals in the Ea and we simply focus on the major signals only because i mainly use the major signals.

rily need this to work


---

## Re: KueFx_Lines_EA

**Apprentice** · Thu Jan 16, 2025 4:47 am

We have added your request to the development list.
Development reference 44


---

## Re: KueFx_Lines_EA

**pugspuggy** · Thu Jan 16, 2025 8:43 pm

While you fix the above modification request. Can we have the MT4 version as well?


---

## Re: KueFx_Lines_EA

**trigga** · Fri Jan 17, 2025 8:23 am

1. please fix issues with EA opening entries at random and as soon as you start algo trading
2. Ea is not following the rules , Red should open sell entry and blue should open buy entry , its working in reverse mode
would the Ea to have

A. Major Entry : True
B. add setting for Minor Entry like this
Minor Entries Along trend : True
eg. 1. When Red (Sell) appears on top is active ,, minor sell Reentries (White strips on the top) should open ReEntry sell entries and ignore the bottom whites and all should close using Major close on opposite
 2. When Major Blue (Buy) appears on the bottom, minor buy entries (White lines on the bottom) should open ReEntry Buy Entries and ignore top whites and all these Buy entries should close using Major Close on Opposite
C. Close on opposite should be based on the Major Entry

spent the past hours trying to figure out what's wrong and how to explain what i want exactly, hope you will consider this. I believe in this forum and am sorry for the continuous suggestions. I use this strategy so i love it a lot


---

## Re: KueFx_Lines_EA

**Apprentice** · Mon Jan 20, 2025 9:07 am

[KueFx_Lines_EA_v1.10.mq5](files/157893/KueFx_Lines_EA_v1.10.mq5)

You're right, I reversed the sell-buy entries.

Regardless, the indicator repaints heavily, even with “non repaint” setting. For me, a non-repainting indicator can only change anything on the last candle until it closes. It should not touch closed candles. Now, this indicator casually draws lines 5-7-9 candles later, so it repaints despite the non-repaint setting. That's why I added a "lookBackBar" setting option in the EA to allow some experimentation, but the indicator repaints too much. If you look at the chart, it's unfortunately too good to be true.


---

## Re: KueFx_Lines_EA

**trigga** · Mon Jan 20, 2025 4:16 pm

everything is fixed but problem now is the Major Entry setting is no longer working , only the minor entry is working. The 1st version both major and minor were working fine its problem was it was opening an entry at random when running on a live chart. This new version , reverse has been corrected but problem is only minor entry is working, Major setting is not opening entries


---

## Re: KueFx_Lines_EA

**trigga** · Wed Jan 22, 2025 6:04 am

Hi Apprentice

The Ea is working perfectly according to the instructions and would like to say thank you very much for it and may God bless you. I only have 2 minor issues

1. only problem is that when i place it on chart , it joins an already moving signal, more of it opens the last signal direction the moment i start algo trading no matter how late is, may you please allow it to wait for next signal and not join an ongoing signal
2. When i close a trade it opened , it reopens another entry immediately, i would like to close some trades manually and have it waiting for the next proper entry not to open the moment i close it
3. Even before i start algo trading , it will already be trying to open an entry, so the moment i start algo trading it opens an entry that very moment, i would want it to open an entry when next new signal comes and not try and join last signal

the Ea is working great just only those 3 issues. Please fix it for me, i rily appreciate


---

## Re: KueFx_Lines_EA

**Apprentice** · Thu Jan 23, 2025 3:22 pm

We have added your request to the development list.
Development reference 54


---

## Re: KueFx_Lines_EA

**Apprentice** · Thu Jan 30, 2025 4:37 am

[KueFx_Lines_EA_v1.20.mq5](files/158053/KueFx_Lines_EA_v1.20.mq5)

Try this version.


---

## Re: KueFx_Lines_EA

**trigga** · Wed Feb 05, 2025 3:24 pm

Good Ea but problems are still there mainly Error 4572 when algo is off amd the moment you switch it on , it executes entries. Fix these issues . the new Version of the Ea has the following problem, mainly it cannot wait for a signal, it just joins an old signal the moment you place it on chart. Try to attach it to an mt5 Account , you will see error 457
1. Error 4752.When it is placed to a chart it tries to open an entry immediately even when there is no signal, these come as notifications with error 4572 and the moment you start algo they open . May you please fix it so it waits for an entry as normal
2. The moment i start Algo it opens entries even if there is no signal , it must wait for a new signal then open an entry
3. I use Lookback of 30 candles, now i cannot add it since you limited it to 9, so sometimes Ea does not execute any entry .allow for one to add candles as per what i may want
4. If i close an entry on my own , it reopens, sometimes i may close an entry because im happy with profit , EA automatically opens another entry the moment i close, i want it to wait for the next signal and not try to open another entry
5. sometimes it skips an entry or close on opposite misses the command


---

## Re: KueFx_Lines_EA

**Apprentice** · Thu Feb 06, 2025 11:59 am

We have added your request to the development list.
Development reference 89


---

## Re: KueFx_Lines_EA

**Apprentice** · Wed Feb 26, 2025 3:40 pm

[KueFx_Lines_EA_v1.30.mq5](files/158434/KueFx_Lines_EA_v1.30.mq5)

Try this version.
