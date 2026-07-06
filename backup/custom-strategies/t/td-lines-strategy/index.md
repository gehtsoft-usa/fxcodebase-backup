# TD Lines Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=65015  
> Forum: 31 · Topic 65015 · 15 post(s)


---

## TD Lines Strategy

**Apprentice** · Wed Aug 23, 2017 6:13 am

Color Line Up crossing over: No Action/Buy / Sell or Close Position.
Color Line Up crossing under: No Action/Buy / Sell or Close Position.

Color Line Dn crossing over: No Action/Buy / Sell or Close Position.
Color Line Dn crossing under: No Action/Buy / Sell or Close Position.

 [td_lines_strategy.lua](files/114367/td_lines_strategy.lua)

TDL.lua is available here.
[viewtopic.php?f=17&t=2483&hilit=Demark+Trend+Lines](https://fxcodebase.com/code/viewtopic.php?f=17&t=2483&hilit=Demark+Trend+Lines)


---

## Re: TD Lines Strategy

**MC. Trend Trader** · Fri Aug 25, 2017 7:08 am

Hello,

Many thanks for Strategy.
would you please add follow parameters:

Close in Opposite , Custom ID, Max open position and Time Parameters.

Thanks in advance


---

## Re: TD Lines Strategy

**Apprentice** · Mon Aug 28, 2017 5:13 am

Your request is added to the development list, Under Id Number 3879
 If someone is interested to do this task, please contact me.


---

## Re: TD Lines Strategy

**Apprentice** · Tue Sep 12, 2017 3:59 am

Try this version.

 [td_lines_strategy.lua](files/114810/td_lines_strategy.lua)


---

## Re: TD Lines Strategy

**MC. Trend Trader** · Tue Sep 12, 2017 6:30 pm

Hello Apprentice

Thanks for your work

custom id does not work.
If close on opposite, the position is closed, but no new position is opened. Strategy template build-up from this strategy is very different from the current strategies which I do not understand. Can this strategy be inserted with the current strategy template?

Best Regards


---

## Re: TD Lines Strategy

**MC. Trend Trader** · Tue Oct 03, 2017 4:58 am

Hello Apprentice

The strategy works
Unfortunately Custom ID does not

function Prepare (name_only)
     for _, module in pairs (modules) do module: Prepare (nameOnly); end
     instance: name (profile: id () .. "(" .. instance.bid:name () .. ")");
     if name_only then return; end

I tried to insert custom ID in the line 440 but get error message.

     instance: name (profile: id () .. "(" .. instance.bid:name () .. "(" .. CustomID () .. ")");

Need your help


---

## Re: TD Lines Strategy

**Apprentice** · Thu Oct 12, 2017 3:58 am

Thank you for your report.
Will revise it.


---

## Re: TD Lines Strategy

**Alexander.Gettinger** · Fri Oct 13, 2017 2:33 pm

Revised.

 [td_lines_strategy.lua](files/115424/td_lines_strategy.lua)


---

## Re: TD Lines Strategy

**MC. Trend Trader** · Fri Oct 13, 2017 4:46 pm

Hello Alexander

Thank you very much For your help.
I have one thing to edit.

Example:
If I have a buy position and the strategy change to sell signal
If close on opposite, the position is closed, but no new sell position is opened.
Can you please fix it.

Best regards


---

## Re: TD Lines Strategy

**MC. Trend Trader** · Tue Aug 14, 2018 6:58 pm

Hello,
With this strategy, the opposite position closes the existing position but does not open a new position. It works on many other published strategies. Would be great if it works
 I request of opening multi positions at the same time with different lot sizes, stops & limits for the TD Lines Strategy.

paramaters should be jncluded:

Open trade 1: Yes/No
Trade 1: lot size
Set Limit for Trade 1: Yes/No’
Limit for Trade1, in pips 30
Set Stop for Trade 1 ‘Yes/No’
Stop for Trade 1: 30
Trailing Stop order for Trade 1: ‘Yes/No’
Trailing for Trade 1, in pips 10
Breakeaven for Trade 1: ‘Yes/No’
Min Profit for Trade1 10

The Trade 1 Logic be repeated for a total of 5 positions

Best regards


---

## Re: TD Lines Strategy

**Apprentice** · Sat Aug 18, 2018 5:32 am

Can you specify which version was used?


---

## Re: TD Lines Strategy

**MC. Trend Trader** · Sun Aug 19, 2018 3:01 am

Hello,

The version from Fri Oct 13, 2017 2:33 was used


---

## Re: TD Lines Strategy

**MC. Trend Trader** · Tue Aug 21, 2018 6:06 am

Hello

 can you still add FractalaASTD to the calculation in this strategy.

Best regards


---

## Re: TD Lines Strategy

**Apprentice** · Wed Aug 29, 2018 4:10 am

FractalaASTD?


---

## Re: TD Lines Strategy

**MC. Trend Trader** · Wed Aug 29, 2018 10:50 am

Hello,

In the indicator TDL.Lua you can select FrctalAsTDL, then the lines are displayed differently. I also wanted to have the selection of the strategy

Best regards
