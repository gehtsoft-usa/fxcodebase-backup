# ARSI Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=60190  
> Forum: 31 · Topic 60190 · 12 post(s)


---

## ARSI Strategy

**Apprentice** · Sat Jan 11, 2014 7:17 am

![ARSI Strategy.png](images/91923/ARSI%20Strategy.png)



Open Long
Fast/Slow ARSI CrossOver
Open Short
Fast/Slow ARSI CrossUnder

 [ARSI Strategy.lua](files/91923/ARSI%20Strategy.lua)

The Strategy was revised and updated on December 17, 2018.


---

## Re: ARSI Strategy

**Alextc** · Mon Jan 13, 2014 2:33 am

Hello, thank you very much for your work. I get an error when I want to start backtesting: "the first parameter must be source indicator". I have installed the indicator. Thank you very much.


---

## Re: ARSI Strategy

**Apprentice** · Mon Jan 13, 2014 3:07 am

Not able to reproduce it, continue testing.
Can you share the parameters used.


---

## Re: ARSI Strategy

**Fxijtuk** · Tue Jan 14, 2014 3:55 am

Thank you for this.

I am getting the same error message even using the default settings "ARSI Strategy.lua:191:ARSI.lua:40: The first parameter must be an indicator source"

I've tried changing the parameters to match the open chart but nothing I change makes a difference, I still get the same error message.

Kind regards,


---

## Re: ARSI Strategy

**Alextc** · Tue Jan 14, 2014 4:49 am

The parameters are the default ones. I have not changed anything. The used pair EUR / USD


---

## Re: ARSI Strategy

**Apprentice** · Wed Jan 15, 2014 6:20 am

Hmm, strange, this should not happened.
Will investigate.


---

## Re: ARSI Strategy

**Fxijtuk** · Wed Jan 15, 2014 6:31 am

Thanks, it's appreciated.


---

## Re: ARSI Strategy

**Valeria** · Thu Jan 16, 2014 11:27 pm

Hi guys,

Could you please specify, which version of Trading Station you use?
To check the version of Trading Station go to Help -> About FXCM Trading Station.


---

## Re: ARSI Strategy

**Fxijtuk** · Fri Jan 17, 2014 5:52 am

Hi,

Thanks, I had tried checking for updates from within Marketscope but now see from the DailyFX forum that this may not work. As suggested, I uninstalled the old version 01.13.092613, and installed the updated version 01.13.111313 from the download and the strategy is now working.

Thank you both for all your help.


---

## Re: ARSI Strategy

**xpertizetrading** · Thu Jul 09, 2015 11:25 am

Hi Team,

I'm interested in a very similar strategy. Kindly see if it is possible to code.

Instead of Fast/Slow ARSI Crossover-Crossunder Signal, I'm looking for Fast Regression Cross Slow Regression for strategy.

Everything else remains the same. And the regression needed is the regular regression.
Not the polynomial regression.

Thanks and Regards,
XpertizeTrading


---

## Re: ARSI Strategy

**Apprentice** · Mon Jul 13, 2015 7:31 am

Try this Version.
[viewtopic.php?f=31&t=62421](https://fxcodebase.com/code/viewtopic.php?f=31&t=62421)


---

## Re: ARSI Strategy

**Apprentice** · Tue Dec 13, 2016 4:58 am

Strategy was revised and updated.
