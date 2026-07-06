# ManualTradingBackTester

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=68379  
> Forum: 38 · Topic 68379 · 10 post(s)


---

## ManualTradingBackTester

**Apprentice** · Tue Apr 23, 2019 7:08 am

Based on request.
[viewtopic.php?f=27&t=67433](https://fxcodebase.com/code/viewtopic.php?f=27&t=67433)
Hot Keys
HotKey_Buy, HotKey_Sell, HotKey_Close_Buy, HotKey_Close_Sell, HotKey_CloseAll

There is an issue with it. It's a global "hotkeys". So, it
opening some positions as I type this post. It's useless for a
real life (unless you don't have a dedicated PC for it).10 min

 [ManualTradingBackTester .mq4](files/125915/ManualTradingBackTester%20.mq4)


---

## Re: ManualTradingBackTester

**filoo7** · Tue Apr 23, 2019 12:10 pm

Great!

I just tested it, and actually the position opens when you type a text ...

it's very boring this global hotkey? You would have another solutions proposed?
The problem is that MT4 uses too many keyboard shortcuts and mainly all F1 / F2 / F3 keys etc ...
I guess it's not possible to disable the MT4 shortcut?...

It's also possible to add a function "hotkey_TP" (Take profit with a percentage) and a "hotkey_BE"?


---

## Re: ManualTradingBackTester

**filoo7** · Wed Apr 24, 2019 1:37 pm

you think with a gamer keyboard and extra keys, the EA could work with the global hotkey?


---

## Re: ManualTradingBackTester

**Apprentice** · Wed Apr 24, 2019 3:26 pm

I would say yes.


---

## Re: ManualTradingBackTester

**filoo7** · Tue May 28, 2019 10:53 am

Hi,
To solve the problem of using the keyboard
it would be possible to use a combination of two keys, rather than one for each command?
for example ctrl + 1, +2 etc ...
Thank's


---

## Re: ManualTradingBackTester

**Apprentice** · Thu May 30, 2019 3:47 am

Added left control check as an additional key.


---

## Re: ManualTradingBackTester

**filoo7** · Thu May 30, 2019 5:32 am

Hi,
can you detailed the setting
I try to enter ctrl + 1 and it does not work.
thank you


---

## Re: ManualTradingBackTester

**Apprentice** · Fri May 31, 2019 7:02 am

this is how MT4 works. It checks the keys only when the code is executing. Sometimes you release the keys before the MT4 code executed. This method of hotkeys is a hack and it barely works. It isn't good for that. There is nothing we can do to improve it.


---

## Re: ManualTradingBackTester

**filoo7** · Wed Jun 19, 2019 6:10 am

it will be possible to add two functions?

first:
key touch Break even +2 pip for the spread

second:
key touch with two take profit option
-option 1: double tp 50% / 50%
-option 2: triple tp 33% / 33% / 34%

Thank you


---

## Re: ManualTradingBackTester

**Apprentice** · Mon Jun 24, 2019 11:49 am

[ManualTradingBackTester .mq4](files/127071/ManualTradingBackTester%20.mq4)

Did only the breakeven part. Multi-level stop is NOT support
by the MT4. Hard-coding is possible and time demanding.
