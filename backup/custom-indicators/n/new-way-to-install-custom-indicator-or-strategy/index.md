# New way to install custom indicator or strategy!

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=59681  
> Forum: 17 · Topic 59681 · 12 post(s)


---

## New way to install custom indicator or strategy!

**Nikolay.Gekht** · Wed Oct 16, 2013 9:04 am

Starting from October 2013 update of Trading Station installing new indicators/strategies is easy as 1-2-3. Just drag and drop an indicator, a view, or a strategy file from a folder or even directly from a website to Marketscope!.


---

## Re: New way to install custom indicator or strategy!

**evgeniyn** · Wed Oct 16, 2013 3:06 pm

It's great, but pls see below some enchantments,
 1)Will be good to add possibility to install number of extensions (not only one per time)
 2)In case of install one extension - auto reopen it
 3)Drag'n'Drop extension in backtest chart window too


---

## Re: New way to install custom indicator or strategy!

**LeTigre30** · Mon Nov 04, 2013 9:23 pm

Hi,

Very nice ...

Also, is it possible to add in the next TS2/MarketScope release, the possibility to update Indicators and Strategies, when the platform is running ?

Currently, after having modified those materials, it's mandatory to close and reopen the platform.

Bst Rgds


---

## Re: New way to install custom indicator or strategy!

**Apprentice** · Tue Nov 05, 2013 12:43 am

U only need to remove indicator or strategy from marketscope.
Not close the entire platform.
Install the new version.
And readd a new version of Indicators or Strategies to marketscope.
As far as I know it is necessary with MT4


---

## Re: New way to install custom indicator or strategy!

**LeTigre30** · Tue Nov 05, 2013 4:22 am

Hi Apprentice,

Well noted for TS2 ...

With MT4, it's not neccessary.
I explain ...
MT4 is opened with a chart and an Indicator in ;
if the Indicator is in the Personal Indicators (subfolder on left side of the platform), you can access to it via MetaEditor ; you can modify it, after having compiled it and closed MetaEditor, the new version of your indicator runs in the chart.

Bst Rgds


---

## Re: New way to install custom indicator or strategy!

**sunshine** · Tue Nov 05, 2013 7:26 am

Hi evgeniyn,

> **evgeniyn wrote:**
> It's great, but pls see below some enchantments,
> 1)Will be good to add possibility to install number of extensions (not only one per time)

You can install a number of extensions at a time. Just select a few indicators/strategies files before drag-n-drop.
You can also do this, if have a lua package (.ipkg file). The .ipkg file is a package with indicators and strategies which can be easily created with the Indicore Package Maker utility. For details please see [Indicore Package Maker](http://www.fxcodebase.com/wiki/index.php/Indicore_Package_Maker).

> **evgeniyn wrote:**
> 2)In case of install one extension - auto reopen it

Please clarify what you mean. Do you mean automatically replace the extension which is currently being opened in charts if a new version of extension is installed?

> **evgeniyn wrote:**
> 3)Drag'n'Drop extension in backtest chart window too

I will forward your requests to development team.


---

## Re: New way to install custom indicator or strategy!

**LeTigre30** · Fri Oct 31, 2014 4:40 am

Hello to dev team,

Sorry to disappoint you, the Drag and Drop solution to quickly import Indis, Views or Strategies, does not correctly function with TS2 or MarketScope 2 !
In fact, when I need to import one of these elements, it's mandatory to close the TS2.
The version of the TS2 is : 01.13.111313, and my system is : W8.0 64 bits.

What happens when I want to import one of these elements ?

When I drag the lua file on to TS2 or MK2 (from a folder : \Indicators\Custom\), an icon (a circle with a \ within the round, in black color), appears, which means that it's forbidden to realize this action or the signification of the mouse pointers says "not available" (in Control Panel ... Mouse Pointers).

As usual, I have to close and reopen the TS2.

Why not, also, one could have the possibility to modify the source code of an element, when the TS2 is launched, like the MT4 behavior, is it so difficult to realize this modification in the TS2 behavior ? It would be much more convenient.

Regards,


---

## Re: New way to install custom indicator or strategy!

**Valeria** · Thu Nov 06, 2014 11:38 am

Hi LeTigre30,

> Why not, also, one could have the possibility to modify the source code of an element, when the TS2 is launched, like the MT4 behavior, is it so difficult to realize this modification in the TS2 behavior ? It would be much more convenient.

If you want to modify the installed extension (indicator or strategy), you should copy it from \Indicators\Custom\ to the other folder on your computer, then modify and reinstall.
Unfortunately, currently there is no way to modify an installed extension from the Trading Station folder. Anyway, thank you for the feedback/suggestion, I have added this feature to the wish-list.


---

## Re: New way to install custom indicator or strategy!

**stapik** · Sun Apr 19, 2015 11:18 am

welcome
I have a problem with installing the indicator
Error: The file can not be opened.
I have tried many indicators and it is always the same error.
Please help


---

## Re: New way to install custom indicator or strategy!

**Apprentice** · Thu Apr 23, 2015 5:46 am

I can not confirm this.
Using the method from the above video.
1) Try to completely uninstall your TS.
2) Try to repeat this from other computers.
Probably on other networks.
If the problem persists, let me know.


---

## Re: New way to install custom indicator or strategy!

**broken850** · Sat May 23, 2015 12:41 pm

This looks like a really good indicator. A standard alert for signal line and WOE line cross with pop up show alert and sound would be great. Show alert on chart with arrows would be icing on the cake.


---

## Re: New way to install custom indicator or strategy!

**Apprentice** · Fri May 26, 2017 7:08 am

Can you provide, indicator name, web reference.
