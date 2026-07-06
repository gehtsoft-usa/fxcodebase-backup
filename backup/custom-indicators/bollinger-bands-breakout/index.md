# Bollinger Bands Breakout

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=70255  
> Forum: 17 · Topic 70255 · 8 post(s)


---

## Bollinger Bands Breakout

**Apprentice** · Sun Aug 02, 2020 9:18 am

![AUDJPY D1 (08-02-2020 1428).png](images/136517/AUDJPY%20D1%20%2808-02-2020%201428%29.png)



Based on request.
[viewtopic.php?f=31&t=69928&start=10](https://fxcodebase.com/code/viewtopic.php?f=31&t=69928&start=10)

 [Bollinger Bands Breakout.lua](files/136517/Bollinger%20Bands%20Breakout.lua)

 [Bollinger Bands Breakout with Alert.lua](files/136517/Bollinger%20Bands%20Breakout%20with%20Alert.lua)


---

## Re: Bollinger Bands Breakout

**new_here** · Sun Aug 09, 2020 4:27 pm

Hi Apprentice.

Please correct me if I am wrong.

There won't be an email alert for Bollinger Bands Breakout because it requires FXCM's infrastructure to work ?

But could we have in near future just simple on screen+sound alert which will work as long as computer is on ?

Thanks.


---

## Re: Bollinger Bands Breakout

**Apprentice** · Mon Aug 10, 2020 3:57 am

TO be able to work, your trading station should be on.
Bollinger Bands Breakout with Alert added.


---

## Re: Bollinger Bands Breakout

**new_here** · Mon Aug 10, 2020 12:20 pm

Thank you Apprentice for this upgrade.

Let me point out one thing which fiercely limiting capability of this tool.

It is disability to launch multipe instances with different settings in the same currency pair tab like EMAs for example.

I know one can open multiple tabs but if one is following few currency pairs multiplied by different settings each it equals having many many tabs open. Big mess on the screen.

Imagine following (having open) 15 tabs for example. They won't even fit into average size of the monitor

Thank you again for the upgrade you made so far.


---

## Re: Bollinger Bands Breakout

**Apprentice** · Tue Aug 11, 2020 3:32 am

Your request is added to the development list.
Development reference 1870.


---

## Re: Bollinger Bands Breakout

**Apprentice** · Tue Aug 11, 2020 5:28 am

[Bollinger Bands Breakout Dashboard.lua](files/136780/Bollinger%20Bands%20Breakout%20Dashboard.lua)

Please use this version of Bollinger Bands Breakout with Alert.lua

 [Bollinger Bands Breakout with Alert.lua](files/136780/Bollinger%20Bands%20Breakout%20with%20Alert.lua)


---

## Re: Bollinger Bands Breakout

**new_here** · Tue Aug 11, 2020 11:25 pm

Hi Apprentice,

Thank you for latest upgrade, I am still wondering how did you manage to make it so quick.

I have been playing with Bollinger Bands Breakout for the whole day and I noticed the odd things happening which you, as a programmer for long years, will understand and know how to tackle immediately.

For example, when I have opened the bar chart of any currency in one minute time interval (m1) plus BBB launched with non default time interval in data source drop down menu, (m5) for example, there is a time gap between signal (arrow) created and actual sound/email alert.

In particular example above (chart m1/BBB data source m5) there is always four (m1) bar chart periods (4 minutes) time gap between up or down arrow and alert.

When bar chart is (m1) but BBB data source (m15) this time, the gap is already 8 or 9 periods/minutes long.

So, I guess bigger the BBB data source time interval the longer is the gap created which is absolutely impossible for human to instantly, like computer, determine far back in to past at which times and prices the alert actually rang.

That's why I am asking you Apprentice if it would be a great deal for you to activate a feature in BBB, which would in any combination of bar chart time interval and BBB data source time interval calculated in the blink of an eye from present time until all the way backward and show to us, by means of simple red/green dots, where exactly one would open the trade if followed blindly the BBB signal alert.

With mentioned skills or BBB feature above, one is able to properly research in all possible ways BBB behaviour on particular currency pair and built/evaluate profitable entry/limit/stop loss order strategy.

Thank you for your time spent on reading a bit long post, I simply couldn't find the way to describe it shorter.


---

## Re: Bollinger Bands Breakout

**Apprentice** · Wed Aug 12, 2020 4:35 am

Try to use "Live" "Signal Execution" option
