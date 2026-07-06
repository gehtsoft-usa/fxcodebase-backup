# Result vs Effort

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=76119  
> Forum: 17 · Topic 76119 · 2 post(s)


---

## Result vs Effort

**Apprentice** · Thu Jul 03, 2025 2:34 pm

![USDJPY H8 (07-03-2025 2133).png](images/159837/USDJPY%20H8%20%2807-03-2025%202133%29.png)



**Indicator: Result vs Effort**

This indicator evaluates the relationship between **price change (Result)** and **trading volume (Effort)** over a specified period. It applies logical checks to detect strong directional movements and identify potential trend or reversal signals. Users can customize various conditions to refine signal accuracy.

**Up Signal Conditions** (all must be true):

- **ResultEffort Trend:** Current value must be greater than the previous value, indicating upward momentum.
- **Magnitude Check:** If "Absolute" is enabled, the absolute current value must exceed the previous value multiplied by "Multiplier".
- **Reversal Check:** If "Reversal" is enabled, a reversal must have occurred two bars ago (i.e., the value two bars ago must be less than the value three bars ago).
- **Confirmation Check:** If "Confirmation" is enabled, the previous value must be greater than the value two bars ago (confirming upward continuation).
- **Trend Direction:** If "Trend" is enabled, the current value must be positive (indicating an uptrend).
If all conditions are met, an **Up marker** is plotted **above the current bar's high**.

**Down Signal Conditions** (all must be true):

- **ResultEffort Trend:** Current value must be less than the previous value, indicating downward momentum.
- **Magnitude Check:** If "Absolute" is enabled, the absolute current value must exceed the previous value multiplied by "Multiplier".
- **Reversal Check:** If "Reversal" is enabled, a reversal must have occurred two bars ago (i.e., the value two bars ago must be greater than the value three bars ago).
- **Confirmation Check:** If "Confirmation" is enabled, the previous value must be less than the value two bars ago (confirming downward continuation).
- **Trend Direction:** If "Trend" is enabled, the current value must be negative (indicating a downtrend).
If all conditions are met, a **Down marker** is plotted **below the current bar's low**.

**Purpose**:
The indicator helps traders detect meaningful price shifts relative to volume, aiding in the identification of trend continuations or reversals. Its multi-layered logic allows for precise control over signal sensitivity.

 [Result vs Effort.lua](files/159837/Result%20vs%20Effort.lua)


---

## Re: Result vs Effort

**Ariel19** · Mon Jul 21, 2025 3:15 am

> **Apprentice wrote:**
>
>
> USDJPY H8 (07-03-2025 2133).png
>
>
> **Indicator: Result vs Effort**
>
> This indicator evaluates the relationship between **price change (Result)** and **trading volume (Effort)** over a specified period. It applies logical checks to detect strong directional movements and identify potential trend or reversal signals. Users can customize various conditions to refine signal accuracy.
>
> **Up Signal Conditions** (all must be true):
>
>
> - **ResultEffort Trend:** Current value must be greater than the previous value, indicating upward momentum.
> - **Magnitude Check:** If "Absolute" is enabled, the absolute current value must exceed the previous value multiplied by "Multiplier".
> - **Reversal Check:** If "Reversal" is enabled, a reversal must have occurred two bars ago (i.e., the value two bars ago must be less than the value three bars ago).
> - **Confirmation Check:** If "Confirmation" is enabled, the previous value must be greater than the value two bars ago (confirming upward continuation).
> - **Trend Direction:** If "Trend" is enabled, the current value must be positive (indicating an uptrend).
> If all conditions are met, an **Up marker** is plotted **above the current bar's high**.
>
> **Down Signal Conditions** (all must be true):
>
>
> - **ResultEffort Trend:** Current value must be less than the previous value, indicating downward momentum.
> - **Magnitude Check:** If "Absolute" is enabled, the absolute current value must exceed the previous value multiplied by "Multiplier".
> - **Reversal Check:** If "Reversal" is enabled, a reversal must have occurred two bars ago (i.e., the value two bars ago must be greater than the value three bars ago).
> - **Confirmation Check:** If "Confirmation" is enabled, the previous value must be less than the value two bars ago (confirming downward continuation).
> - **Trend Direction:** If "Trend" is enabled, the current value must be negative (indicating a downtrend).
> If all conditions are met, a **Down marker** is plotted **below the current bar's low**.
> [Retro Bowl](https://retrobowlplus.com)
> **Purpose**:
> The indicator helps traders detect meaningful price shifts relative to volume, aiding in the identification of trend continuations or reversals. Its multi-layered logic allows for precise control over signal sensitivity.
>
>
>
>
>
>
> Result vs Effort.lua

Which condition in the Result vs Effort indicator is most often turned on/off when you want to avoid noise signals in a strong trend?
