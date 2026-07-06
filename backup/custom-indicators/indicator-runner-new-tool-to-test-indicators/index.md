# Indicator runner - new tool to test indicators

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=64428  
> Forum: 17 · Topic 64428 · 11 post(s)


---

## Indicator runner - new tool to test indicators

**Konstantin.Toporov** · Thu Feb 09, 2017 2:18 pm

Indicore SDK since 3.3.0 now contains a new tool - Indicator runner.
The tools is intended to make standalone indicator calculations and export the output data into a text file.
Indicator runner can use standard data source as well as external data (any csv file, downloaded, for example, from yahoo).
The samples how to use Indicator runner are included into Indicore SDK.
More details about the tool can be found in the [Indicator runner documentation](https://fxcodebase.com/bin/products/IndicoreSDK/3.3.0/help/JS/web-content.html#Indicator_Runner.html)


---

## Re: Indicator runner - new tool to test indicators

**Cactus** · Thu Feb 09, 2017 8:51 pm

I like this very much.
I have a few questions though

Can I output more than 1 indicator data at the same time? For example: would this be hard to achieve?
ni = mva
ni2 = stochastic
ni3 = bb

Can we extract both bid and ask at the same time?

How does -l options affect the output?
"clr" - Classic Lua Runtime
"jit" - Lua Vm Jit Interpreter
"ffi" - Lua Vm Jit Compiler

What is -rd for exactly?

I notice in sample file -h parameter, but not in the documentation, how to use this correctly?

I have problems using a custom CSV (cannot parse error). It is in the format used by "Get Historical Prices GUI" posted on General Discussion forum: [viewtopic.php?f=25&t=63875](http://www.fxcodebase.com/code/viewtopic.php?f=25&t=63875), so:
DateTime	BidOpen	BidHigh	BidLow	BidClose	AskOpen	AskHigh	AskLow	AskClose	Volume
21/10/2001 21:00	61.654	61.674	61.554	61.664	61.746	61.766	61.646	61.756	0


---

## Re: Indicator runner - new tool to test indicators

**Konstantin.Toporov** · Fri Feb 10, 2017 11:53 am

> Can I output more than 1 indicator data at the same time? For example: would this be hard to achieve?

We tried to make the tool simple so it calculates only one indicator at time.
We will consider this feature to include into the future release.

> Can we extract both bid and ask at the same time?

Bid and Ask are different price streams so the same indicator calculating Bid and Ask it is actually 2 indicator test runs.

> How does -l options affect the output?

This option does not affect the output it should affect only calculations performance.

> What is -rd for exactly?

This option is to get the output of ownerdrawn indicators. By default the OD ouput is written to out_od.csv. With this option the file name can be changed. We will extend the documentation to make it more comprehensive.

> I notice in sample file -h parameter, but not in the documentation, how to use this correctly?

This parameter is to customize a format of the external csv files. We will extend the documentation about that topic as well.

> I have problems using a custom CSV (cannot parse error)

We will research the problem and I ll post the results in this topic.

Thank you for the questions.


---

## Re: Indicator runner - new tool to test indicators

**Cactus** · Tue Feb 21, 2017 7:10 pm

Cool. And what about tick frame indicators? Can t1 period be "simulated" on the candles in a similar fashion as backtesting works


---

## Re: Indicator runner - new tool to test indicators

**Konstantin.Toporov** · Tue Feb 28, 2017 11:08 am

We will work on that feature.
Sorry for the inconvenience.


---

## Re: Indicator runner - new tool to test indicators

**Cactus** · Sat Mar 03, 2018 11:25 am

I made these two posts regarding Indicator Runner in the SDK Updates thread about some issues I was having with the weekly timeframe or using a standalone vs console utilities bundles version of the indicator runner:
[viewtopic.php?f=28&t=2178&start=80#p117919](https://fxcodebase.com/code/viewtopic.php?f=28&t=2178&start=80#p117919)
[viewtopic.php?f=28&t=2178&start=80#p117928](https://fxcodebase.com/code/viewtopic.php?f=28&t=2178&start=80#p117928)


---

## Re: Indicator runner - new tool to test indicators

**mitenp** · Sun Jul 03, 2022 4:28 pm

Hi,

Setting up Indicore SDK onto new machine after returning to trading after a few years.

Downloaded following via the link from [https://fxcodebase.com/documentation.php](https://fxcodebase.com/documentation.php)
[http://fxcodebase.com/bin/products/Indi ... -3.4.0.exe](https://fxcodebase.com/bin/products/IndicoreSDK/3.4.0/IndicoreSDK3-3.4.0.exe)

IndicatorRunner is not present in that installation.

Found v3.3 at [http://fxcodebase.com/bin/products/Indi ... -3.3.0.exe](https://fxcodebase.com/bin/products/IndicoreSDK/3.3.0/IndicoreSDK3-3.3.0.exe) and that has IndicatorRunner. Is this the version I should use ?

Have a general question about which version of the SDK I should use as also found this version ([http://fxcodebase.com/bin/products/Indi ... .5-x64.exe](https://fxcodebase.com/bin/products/IndicoreSDK/3.5.0/integration/IndicoreIntegrationSDK-3.5-x64.exe)) however its lacking most of the applications eg debugger etc. Is this version only used for specific purpose ?

Note the 3.3.9 version link ([http://www.fxcodebase.com/bin/products/ ... -3.3.9.exe](http://www.fxcodebase.com/bin/products/IndicoreSDK/3.3.0/IndicoreSDK3-3.3.9.exe)) on [https://fxcodebase.com/wiki/index.php/A ... K_Releases](https://fxcodebase.com/wiki/index.php/All_Indicore_SDK_Releases) fails to download.

Thanks


---

## Re: Indicator runner - new tool to test indicators

**Apprentice** · Mon Jul 04, 2022 3:30 am

I sent your inquiry to the team.

I personally don't use the SDK much.
I use Notepad++ for coding and Trading station for testing.


---

## Re: Indicator runner - new tool to test indicators

**mitenp** · Mon Jul 04, 2022 5:13 am

Ah ok, is there a post on how to use the Trading Station for testing especially testing tick by tick or bar by bar ?

Thanks


---

## Re: Indicator runner - new tool to test indicators

**Apprentice** · Mon Jul 04, 2022 5:15 pm

You can use Trade simulation mode,
I know it is NOT an ideal tool for the job.


---

## Re: Indicator runner - new tool to test indicators

**mitenp** · Mon Jul 04, 2022 6:14 pm

Thanks
