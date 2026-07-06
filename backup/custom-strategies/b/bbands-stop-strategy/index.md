# BBands_Stop Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=4672  
> Forum: 31 · Topic 4672 · 13 post(s)


---

## BBands_Stop Strategy

**Apprentice** · Thu Jun 09, 2011 12:30 pm

![BBands_Stop Strategy.png](images/11581/BBands_Stop%20Strategy.png)



 [BBands_Stop Strategy.lua](files/11581/BBands_Stop%20Strategy.lua)

Please, do not forget to download and install the indicator BBANDS_STOP from here.
[viewtopic.php?f=17&t=757](https://fxcodebase.com/code/viewtopic.php?f=17&t=757)

The Strategy was revised and updated on December 11, 2018.


---

## Re: BBands_Stop Strategy

**4xtr8r** · Thu Jun 09, 2011 2:11 pm

Hi,

I have it automated, but a couple of things i noticed:

1) It's not buying/selling on the 1st bar when signaled. It's buying on the 3rd bar.
2) It's not buying AT the close of the bar.

Can you have it buy/sell on the 1st bar (dot)... and AT the close of the bar.

Thank you!


---

## Re: BBands_Stop Strategy

**4xtr8r** · Thu Jun 09, 2011 3:00 pm

Hi,

Anyway to have the limit work on half of the position? Maybe an option to have how many lots you would like to exit at limit price?

Can you also make it work for US accounts?

Thanks.


---

## Re: BBands_Stop Strategy

**4xtr8r** · Fri Jun 17, 2011 1:07 pm

Hi Apprentice,

Can this strategy be coded to run on MT4?

Thank you.


---

## Re: BBands_Stop Strategy

**Apprentice** · Fri Jun 17, 2011 1:14 pm

As you know, this forum is committed to developing addons for Marketskope Charting Platform.
And this is a free service.
The development of addons for other platforms is not our primary goal.
However, we offer this service through our premium service.

[viewforum.php?f=32](https://fxcodebase.com/code/viewforum.php?f=32)
[[email protected]](https://fxcodebase.com/cdn-cgi/l/email-protection#aacecfdccfc6c5dac7cfc4de84d9cfd8dcc3c9cfeacdcfc2ded9c5ccdedfd9cb84c9c5c7)

This service is not free unfortunately.
I would ask you to contacting our development team.
Via email or this forum.


---

## Re: BBands_Stop Strategy

**robmsan** · Thu Apr 05, 2012 1:56 pm

This is a great strategy but its not placing stop or limit orders please correct this ASAP thank you very much.


---

## Re: BBands_Stop Strategy

**mulligan** · Tue Mar 18, 2014 10:31 am

I've been using the bbands stop indicator very successfully on the 1 minute chart with length 1440 (1 day in minutes), deviation 1.5, money risk 0.0, signal 1. Being a short term trader, this gives me an immediate read on a larger trend. The indicator works perfectly. However, these numbers, in the strategy, are only giving a few random signals that don't match the indicator. I'm not trying to use the automated trading, just want the signals. Any help is appreciated.


---

## Re: BBands_Stop Strategy

**Apprentice** · Wed Mar 19, 2014 5:37 am

if u Set "Allow strategy to trade" it will act as Signal/Alert.


---

## Re: BBands_Stop Strategy

**mulligan** · Wed Mar 19, 2014 7:40 am

"Allow strategy to trade" is turned off since I only want the signal/alert. The problem I am having is that with these settings, I am not getting alerts as the bbands stop change from up to down and down to up. The signals, if any, don't match the indicator, which is acting correctly.


---

## Re: BBands_Stop Strategy

**Apprentice** · Thu Mar 20, 2014 3:14 am

Signals are completely wrong? or delayed?

I can add alert function to the original indicator.
Would this meet your needs.


---

## Re: BBands_Stop Strategy

**mulligan** · Thu Mar 20, 2014 9:37 am

That is correct. The signals from the strategy are often wrong, delayed, or just don't happen. An alert for BBands_Stop in the style of BB CS Cross Alert.lua which allows for setting parameters of the indicator and the options of "show alert, sound, and recurrent sound" would be perfect. Thanks for your consideration.


---

## Re: BBands_Stop Strategy

**Apprentice** · Mon Mar 24, 2014 4:38 am

Please Try BBands_Stop with Alert.lua
[viewtopic.php?f=17&t=757&p=1394#p1394](https://fxcodebase.com/code/viewtopic.php?f=17&t=757&p=1394#p1394)


---

## Re: BBands_Stop Strategy

**Apprentice** · Sun Dec 11, 2016 5:47 am

Strategy was revised and updated.
