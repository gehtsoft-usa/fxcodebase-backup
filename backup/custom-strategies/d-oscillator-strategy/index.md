# D oscillator strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=3609  
> Forum: 31 · Topic 3609 · 9 post(s)


---

## D oscillator strategy

**Alexander.Gettinger** · Sun Mar 06, 2011 11:22 pm

Strategy based on D oscillator ([viewtopic.php?f=17&t=3608](https://fxcodebase.com/code/viewtopic.php?f=17&t=3608)).
Open/close orders at crosses oscillator lines.

Download:

 [D_Oscillator_Strategy.lua](files/8674/D_Oscillator_Strategy.lua)

The Strategy was revised and updated on November 19, 2018.


---

## Re: D oscillator strategy

**Alexander.Gettinger** · Fri Jul 22, 2011 2:48 am

Other version of D oscillator strategy.

Strategy use two D oscillators.
Orders open/close on each cross D oscillator and direction is defined D oscillator 2.

Download:

 [D_Oscillator_Strategy2.lua](files/12988/D_Oscillator_Strategy2.lua)


---

## Re: D oscillator strategy

**sho-me-pips** · Fri Jul 22, 2011 8:17 am

The confirmation signal should be the BF_D_Oscillator (21, 15, 21, .04, 3) on a larger time frame (Day, 8H, 6H...).

If BF_D_Oscillator is crossed up, only use up signals of first D_Oscillator.
If BF_D_Oscillator is crossed down only use down signals of first D_Oscillator.


---

## Re: D oscillator strategy

**sho-me-pips** · Tue Aug 30, 2011 3:30 pm

Please make these to work with FIFO accounts.


---

## Re: D oscillator strategy

**Apprentice** · Wed Nov 30, 2016 8:34 am

Bump up.


---

## Re: D oscillator strategy

**mulligan** · Tue Mar 24, 2020 5:21 pm

Getting the following error message - C:/Program Files/Candleworks/FXTS2/Strategies/Custom/D_Oscillator_Strategy.lua -1:nil

Thanks for your help


---

## Re: D oscillator strategy

**Apprentice** · Wed Mar 25, 2020 6:09 am

Do you have D_OSCILLATOR indicator installed?


---

## Re: D oscillator strategy

**mulligan** · Wed Mar 25, 2020 1:11 pm

yes, I do have the indicator installed.


---

## Re: D oscillator strategy

**Apprentice** · Fri Mar 27, 2020 8:14 am

[D_Oscillator_Strategy.lua](files/132325/D_Oscillator_Strategy.lua)

Try this version.
