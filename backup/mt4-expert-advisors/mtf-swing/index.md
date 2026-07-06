# MTF_swing

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=76383  
> Forum: 38 · Topic 76383 · 7 post(s)


---

## MTF_swing

**Apprentice** · Mon Oct 20, 2025 6:48 pm

![Snimka zaslona 2025-10-21 014749.png](images/160940/Snimka%20zaslona%202025-10-21%20014749.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.php?f=38&t=76245](https://fxcodebase.com/code/viewtopic.php?f=38&t=76245)

 [MTF_swing.mq4](files/160940/MTF_swing.mq4)


---

## Re: MTF_swing

**khanatd** · Mon Oct 20, 2025 11:46 pm

hi sir plz add mt4 non repaint arrows at close of current candle or reversals/continuations /breakers etc

thanks
khan


---

## Re: MTF_swing

**Satya264** · Tue Oct 21, 2025 2:08 am

make EA ON THIS INDICATOR BUY immediately ON RED TEXT AND SELL immediately ON GREEN TEXT

TP AND SL (TRUE OR FALSE) ONLY PIPS


---

## Re: MTF_swing

**Apprentice** · Tue Oct 21, 2025 9:34 am

We have added your request to the development list.
Development reference 675


---

## Re: MTF_swing

**khanatd** · Wed Oct 22, 2025 10:32 pm

hi sir plz always show buffers numbers with every one indicator u make non repaint at close of current candle, so one can trade with EA too, plz make it this one too fast if today or tomorow

thanks
khan


---

## Re: MTF_swing

**Apprentice** · Tue Nov 11, 2025 5:09 am

There are two limitations to placing orders immediately when the text appears:

Delayed confirmation: The indicator confirms swing points only after price has moved a certain distance, so by the time the text appears, the price may already have moved away from the swing level.

Repainting: The indicator can repaint — swing points may be recalculated as new bars form, and signals can change or disappear.

Impact: This can result in entries at less favorable prices or false signals that change before execution.

Let me know if you’d like me to modify the EA to handle this differently.

 [MTF_Swing_EA.mq4](files/161202/MTF_Swing_EA.mq4)


---

## Re: MTF_swing

**khanatd** · Tue Nov 11, 2025 3:34 pm

hi sir, can swing be made to appear at close of current candle or two candles sir? alert arrow non repaint should appear at close of current candle or after two candles passed, on this rule EA work too,thanks
