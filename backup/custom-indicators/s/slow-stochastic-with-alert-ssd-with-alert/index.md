# Slow stochastic with alert / SSD with Alert

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=65390  
> Forum: 17 · Topic 65390 · 16 post(s)


---

## Slow stochastic with alert / SSD with Alert

**Apprentice** · Thu Nov 23, 2017 8:20 am

![AUDNZD H4 (11-23-2017 1230).png](images/116184/AUDNZD%20H4%20%2811-23-2017%201230%29.png)



 [Slow stochastic with alert.lua](files/116184/Slow%20stochastic%20with%20alert.lua)

MT4/MQ4 version.
[viewtopic.php?f=38&t=68559](https://fxcodebase.com/code/viewtopic.php?f=38&t=68559)


---

## Re: Slow stochastic with alert / SSD with Alert

**Apprentice** · Sat Apr 21, 2018 9:30 am

The Indicator was revised and updated.


---

## Re: Slow stochastic with alert / SSD with Alert

**ZoranB** · Fri Feb 08, 2019 2:03 am

Hi Apprentice,
I love this indicator! How difficult would be to make it an MTF indicator?
So everything should work exactly as it is but there should be a parameter for the time frame that the indicator should be reflecting. This way one could have H4 or D1 version of the indicator on H1 (or any other) chart so that brother picture could be considered without exiting the screen.

Thanks,
Zoran


---

## Re: Slow stochastic with alert / SSD with Alert

**Apprentice** · Fri Feb 08, 2019 4:42 am

![Higher Time Frame.png](images/123774/Higher%20Time%20Frame.png)



For higher time frame you could simply use "period" selector within the Data Source tab.


---

## Re: Slow stochastic with alert / SSD with Alert

**ZoranB** · Fri Feb 08, 2019 10:29 pm

WOW - great - thanks a lot!!!


---

## Re: Slow stochastic with alert / SSD with Alert

**minifire18** · Thu Jun 06, 2019 8:19 am

Apprentice
Can you code for MT4 SSD with alerts and also where you can change the data source for example 1Hr chart using the data from a 4Hr
thanks minifire


---

## Re: Slow stochastic with alert / SSD with Alert

**Apprentice** · Sat Jun 08, 2019 2:54 am

Your request is added to the development list under Id Number 4706


---

## Re: Slow stochastic with alert / SSD with Alert

**Apprentice** · Tue Jun 11, 2019 5:40 am

MT4/MQ4 version.
[viewtopic.php?f=38&t=68559](https://fxcodebase.com/code/viewtopic.php?f=38&t=68559)


---

## Re: Slow stochastic with alert / SSD with Alert

**mulligan** · Wed Apr 22, 2020 11:08 am

Could we please get this same alert for the SFK fast Stochastic. Thanks very much.


---

## Re: Slow stochastic with alert / SSD with Alert

**Apprentice** · Thu Apr 23, 2020 4:20 am

Your request is added to the development list.
Development reference 1113.


---

## Re: Slow stochastic with alert / SSD with Alert

**Apprentice** · Thu Apr 23, 2020 5:19 am

It uses SFK. SD is D parameter in SFK


---

## Re: Slow stochastic with alert / SSD with Alert

**mulligan** · Thu Apr 23, 2020 5:00 pm

Fast Stochastic, SFK (a standard indicator included with TS) has only %K and %D with no SD or slowing of D. This indicator will not allow me to set SD to zero, only a minimum of 2. Can you please change that or or create a true SFK with alert. Thanks very much.


---

## Re: Slow stochastic with alert / SSD with Alert

**Apprentice** · Fri Apr 24, 2020 12:52 pm

Your request is added to the development list.
Development reference 1125.


---

## Re: Slow stochastic with alert / SSD with Alert

**Apprentice** · Mon Apr 27, 2020 4:55 am

If uses true SFK. SD parameter is used as a D for the SFK. Just set SD as D parameter.


---

## Re: Slow stochastic with alert / SSD with Alert

**mulligan** · Mon Apr 27, 2020 9:13 am

Unfortunately it does not work because SSD with alert has %K, %D, and %D slowing. None of these will allow for a value less than 2. So there is always 3 inputs of at least 2 periods. SFK has only 2 inputs. I understand the relationship between SSD and SFK, it's just that the mechanics of this indicator won't allow 1 input to be zero or in effect turned off.


---

## Re: Slow stochastic with alert / SSD with Alert

**Apprentice** · Fri May 01, 2020 10:02 am

![USDCNH H1 (05-01-2020 1511).png](images/133438/USDCNH%20H1%20%2805-01-2020%201511%29.png)



 [SFK with alert.lua](files/133438/SFK%20with%20alert.lua)
