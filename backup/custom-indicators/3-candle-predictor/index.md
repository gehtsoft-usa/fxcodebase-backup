# 3 Candle Predictor

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=75859  
> Forum: 17 · Topic 75859 · 4 post(s)


---

## 3 Candle Predictor

**Apprentice** · Sat Apr 26, 2025 7:51 am

![EURUSD D1 (04-26-2025 1502).png](images/159039/EURUSD%20D1%20%2804-26-2025%201502%29.png)



Description:
This indicator predicts the direction of the next candle based on historical patterns formed by the previous 3 candles. It analyzes whether each candle closed higher (Up) or lower (Down) compared to its open price.

How the Indicator Works:
It checks the direction (U for up, D for down) of the last 3 candles.

It searches historical data to find similar 3-candle patterns.

It then examines historically what direction the next candle moved after those matched patterns.

The indicator predicts the next candle direction based on the most frequent outcome following that pattern historically.

Possible 3-Candle Patterns:
Each candle can have 2 states: Up (U) or Down (D).
Thus, the total number of possible unique patterns of three candles is:

2×2 × 2=8  unique patterns

These 8 patterns are:
1. U U U (three candles up)
2. U U D (two candles up, last candle down)
3. U D U (first candle up, second down, third up)
4. U D D (first candle up, two candles down)
5. D U U (first candle down, two candles up)
6. D U D (first down, second up, third down)
7. D D U (two candles down, third candle up)
8. D D D (three candles down)

 [3 Candle Predictor.lua](files/159039/3%20Candle%20Predictor.lua)

This oscillator calculates the prediction accuracy percentage of the "3 Candle Predictor" indicator over the last 10 candles. It measures how frequently the direction predicted by the "3 Candle Predictor" matched the actual direction of price movement (Up or Down).

Interpretation:
100%: All predictions in the last 10 candles were correct.
0%: None of the predictions were correct.
A higher percentage indicates a more reliable predictive pattern in recent market conditions.

 [3 Candle Predictor Accuracy.lua](files/159039/3%20Candle%20Predictor%20Accuracy.lua)


---

## Re: 3 Candle Predictor

**Apprentice** · Sat Apr 26, 2025 8:18 am

![EURUSD D1 (04-26-2025 1515).png](images/159040/EURUSD%20D1%20%2804-26-2025%201515%29.png)



The N-Candle Predictor is an advanced version of the original 3-Candle Predictor.
While the 3-Candle Predictor always analyzes patterns formed by the last 3 candles, the N-Candle Predictor allows the user to define the number of candles (PatternLength) used to form the historical pattern — anywhere from 1 to 10 candles.

This flexibility enables deeper pattern recognition by using longer sequences of market behavior, offering a more customizable and adaptive prediction model compared to the fixed 3-candle approach.

Number of Possible Patterns in N-Candle Predictor
Each candle can have only 2 states:
U (Up) – if close > open
D (Down) – if close < open

Thus, the total number of possible unique patterns for N candles is:
Total Patterns=2^N

Examples:
Pattern Length (N)	Number of Possible Patterns
1	2
2	4
3	8
4	16
5	32
6	64
7	128
8	256
9	512
10	1024

 [N-Candle Predictor.lua](files/159040/N-Candle%20Predictor.lua)

 [N-Candle Predictor Accuracy.lua](files/159040/N-Candle%20Predictor%20Accuracy.lua)

Indicator-based strategy.
[https://fxcodebase.com/code/viewtopic.p ... 91#p159391](https://fxcodebase.com/code/viewtopic.php?f=31&t=75976&p=159391#p159391)

MT4/MT5 indicator
[https://fxcodebase.com/code/viewtopic.p ... 47#p159647](https://fxcodebase.com/code/viewtopic.php?f=38&t=76046&p=159647#p159647)


---

## Re: 3 Candle Predictor

**Apprentice** · Tue Apr 29, 2025 7:52 am

![EURUSD H1 (04-29-2025 1451).png](images/159081/EURUSD%20H1%20%2804-29-2025%201451%29.png)



 

![EURUSD H1 (04-29-2025 1452).png](images/159081/EURUSD%20H1%20%2804-29-2025%201452%29.png)



**N Candle Predictor (Historical Close)**
Sampling logic:

Forms a historical pattern by including the current candle.

The pattern uses period - i (where i = 1..N).

This introduces a bias: the current forming candle (still updating) influences the pattern.

Forecast placement:

Prediction symbols are drawn below or above the current candle (low or high plus/minus some pips).

Always forecasts for the current period.

**Real Time Forecast N Candle Predictor (Strict Past Only)**
Sampling logic:

Forms a historical pattern using only fully closed candles.

Uses period - i - 1, ensuring the current forming candle is never included.

True real-time behavior: the prediction is purely based on the finished candles, no contamination from unfinished price action.

 [Real Time Forecast N-Candle Predictor.lua](files/159081/Real%20Time%20Forecast%20N-Candle%20Predictor.lua)


---

## Re: 3 Candle Predictor

**Apprentice** · Mon May 05, 2025 12:00 pm

![XAUUSD H1 (05-05-2025 1900).png](images/159135/XAUUSD%20H1%20%2805-05-2025%201900%29.png)



 [N-CANDLE PREDICTOR OSCILLATOR.lua](files/159135/N-CANDLE%20PREDICTOR%20OSCILLATOR.lua)

 [MTF_MCP N-CANDLE PREDICTOR.lua](files/159135/MTF_MCP%20N-CANDLE%20PREDICTOR.lua)
