# Risk Management Indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=34200  
> Forum: 17 · Topic 34200 · 18 post(s)


---

## Risk Management Indicator

**LeTigre30** · Mon Apr 08, 2013 12:17 am

Hello to All,

I have downloaded the Risk Management Indicator from FXCM Apps Store : RiskManagement.lua

Unfortunately, this indicator prints the labels on Upper-Right, Upper-Left, Bottom-Right and Bottom-Left corners of the chart.

If, as me, you have a lot of indicators on the same chart, the Risk Management informations are not readable. So, I have modified the source code to have the possibility to place labels on the verticals Center-Right and Center-Left of the chart.

Also, I have added in the source code, the possibility to choose the currency of the account in a list, AUD, CAD, CHF, EUR, GBP, JPY, NZD and USD (as I have not found the way to retrieve the Account currency from the table "Accounts" see my last post [http://fxcodebase.com/code/viewtopic.php?f=17&t=34179)](https://fxcodebase.com/code/viewtopic.php?f=17&t=34179)).

Find enclosed the files RiskManagement_1.lua and RiskManagement_1.lua.rc for the different languages (you can modify the translations if those are not correct).

 [RiskManagement_1.lua](files/58130/RiskManagement_1.lua)

 [RiskManagement_1.lua.rc](files/58130/RiskManagement_1.lua.rc)

The indicator was revised and updated


---

## Re: Risk Management Indicator

**LeTigre30** · Mon Apr 08, 2013 12:40 am

In addendum to my first post :
I have observed an issue in the label "TradeSize" nnn Lots.
I explain : per example I take a risk of 20 %, and leave Stop Pips at 75 and Limit Pips at 100 (the original values in the original indicator), the original source code sends 24082 Lots.
This value is an error as it is not possible to open a position of 24082 Lots in XAU/USD with a MMR od 3.00 EUR / Lot : necessary equity = 24082 * 3.00 = 72246 EUR !!! for an equity of 69520.72 it is not possible.

I will correct this issue in the next improvement of this indicator.


---

## Re: Risk Management Indicator

**ShadyFX** · Wed Jul 10, 2013 10:46 am

I've been having problems with the original Risk Management indicator it constantly misjudges proper stop loss amount per trade. I soon realized it may be because my account is in GBP. Unfortunately, I only trade and never really had any coding experience. So could you help me installing this .lua.rc for GBP accounts.

Gleatly appreciated


---

## Re: Risk Management Indicator

**trendwatch** · Fri Jul 26, 2013 5:13 am

Hi,

Stop input. Do I have to enter stop+spread or just the stop?


---

## Re: Risk Management Indicator

**Apprentice** · Thu Jun 01, 2017 10:42 am

Indicator was revised and updated.


---

## Re: Risk Management Indicator

**fortesan9** · Thu Apr 01, 2021 5:01 pm

Dearest FXCodebase & Co,

Would it be possible to integrate additional financial calculations (ideas attached in excel file) and in the style or structure (please forgive) of the INFO Overlay [https://fxcodebase.com/code/viewtopic.p ... 10#p133154](https://fxcodebase.com/code/viewtopic.php?f=17&t=15542&sid=4efb53ad0a8d6456289b4a894a97dc2c&start=10#p133154) is presented.

Best,
fortesan9


---

## Re: Risk Management Indicator

**Apprentice** · Fri Apr 02, 2021 3:56 am

Your request is added to the development list.
Development reference 330.


---

## Re: Risk Management Indicator

**Apprentice** · Fri Apr 09, 2021 1:28 pm

It's unclear what fields should be defined by the user and what should be calculated.


---

## Re: Risk Management Indicator

**fortesan9** · Fri Apr 09, 2021 2:17 pm

[RMI2.xlsx](files/141436/RMI2.xlsx)

My apologies,

Attached is the revised spreadsheet, yellow cells are User Defined and white cells are Calculations.

P.D. An additional chart is plotted for grafical purposes.. I think the indicator would look sofisticated if one is added.


---

## Re: Risk Management Indicator

**Apprentice** · Mon Apr 12, 2021 11:26 am

Your request is added to the development list.
Development reference 349.


---

## Re: Risk Management Indicator

**fortesan9** · Mon Apr 12, 2021 11:11 pm

Thanks Don Apprentice,


---

## Re: Risk Management Indicator

**Apprentice** · Thu Apr 15, 2021 5:14 am

[RiskManagement.lua](files/141520/RiskManagement.lua)

 [RiskManagement.lua.rc](files/141520/RiskManagement.lua.rc)

Try this version.


---

## Re: Risk Management Indicator

**fortesan9** · Fri Apr 16, 2021 1:29 pm

Does not display all data when applying the indicator on the charts.

what am i doing wrong?


---

## Re: Risk Management Indicator

**Apprentice** · Mon Apr 19, 2021 2:38 am

You havn't install it.


---

## Re: Risk Management Indicator

**fortesan9** · Tue Apr 20, 2021 10:43 pm

The results for Lots, Position Cost, Position Value, Applied Leverage, Limit Profit in $, and Position Profit Margin appear incorrect, these are the formulas:

Lots = (Position Risk Value / Pip Value)

Position Cost = (MMR * Lots)

Position Value = (Lot Size * Lots) * Price

Applied Leverage = (Position Value / Account Equity)

Limit Profit in $ = (Pip Cost) * (Limit Profit in Pips) * (Lots)

Postition Profit Margin = (Limit Profit in Pips / Account Equity)


---

## Re: Risk Management Indicator

**fortesan9** · Wed Apr 21, 2021 11:35 am

> **Apprentice wrote:**
> You havn't install it.

Displays perfectly fine now, Thanks Don, just the mentioned formulas i think..


---

## Re: Risk Management Indicator

**Apprentice** · Wed Apr 21, 2021 11:37 am

Your request is added to the development list.
Development reference 392.


---

## Re: Risk Management Indicator

**Apprentice** · Wed Apr 28, 2021 8:54 am

Everything as requested. From the code:

local lots = position_risk_value / pip_value;
CellsBuilder:Add(MAIN_FONT, "Position Cost", text_color, 1, row, 0);
CellsBuilder:Add(MAIN_FONT, win32.formatNumber(MMR * lots, false, 2), text_color, 2, row, 0);
local position_value = entry_price * baseUnitSize * lots;
local leverage = (baseUnitSize * lots * entry_price / equityAmount);
CellsBuilder:Add(MAIN_FONT, "Limit Profit in $", text_color, 1, row, 0);
CellsBuilder:Add(MAIN_FONT, win32.formatNumber(limit_curr, false, 2), text_color, 2, row, 0);
CellsBuilder:Add(MAIN_FONT, "Position Profit Margin %", text_color, 1, row, 0);
CellsBuilder:Add(MAIN_FONT, win32.formatNumber(100 * limit_curr / equityAmount, false, 2) .. "%", text_color, 2, row, 0);
