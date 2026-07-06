# Markov Regime Probability

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=76346  
> Forum: 17 · Topic 76346 · 1 post(s)


---

## Markov Regime Probability

**Apprentice** · Fri Oct 03, 2025 4:03 am

![TSLA.us H1 (10-03-2025 1100).png](images/160738/TSLA.us%20H1%20%2810-03-2025%201100%29.png)



Markov & HMM Regime Probability Indicators (Basic / Adaptive / HMM)

This package introduces three related indicators for FXCM TS2 / Indicore. All three are based on probabilistic models of price regimes, with different levels of sophistication. They allow traders to visualize the probability of bullish vs bearish conditions directly on the chart, either as an oscillator or by coloring candles.

Parameters:
Period – rolling window length.
SmoothEMA – smoothing factor for probability line.
Paint – option to color candles on the main chart.
ProbThresh – probability threshold for bull/bear classification (when relevant).
Candle coloring follows Indicore rules (first stream in group sets the color).
Consistent interface across all versions (grouped parameters, harmonized naming).

Version 1: Markov Regime Probability (Basic)
Model: Simple 2-state Markov chain (UP vs DOWN) based on transitions in the rolling window.
Output: Probability that the next bar will be UP.
Painting: By fixed probability threshold (ProbThresh).
Lightweight, fast, suitable for lower timeframes.

Version 2: Markov Regime Probability (Adaptive)
Same Markov core as v1, but thresholds are not fixed.
Adaptive thresholds are calculated as rolling mean ± K·standard deviation of the probability line.
Two painting modes:
ByProb – fixed threshold (like v1).
ByAuto – adaptive thresholds (probabilities must significantly deviate from average to trigger bull/bear).
Adds robustness when the dataset is biased toward one side (avoids constant green or red).
Still lightweight, only slightly more computational load than v1.

Version 3: HMM Regime Probability (Baum–Welch)
Model: 2-state Gaussian Hidden Markov Model estimated with Baum–Welch (EM algorithm) on log returns.
Each state has its own mean and variance; transition probabilities are learned per window.

Output:
Probability of the “bull” state (the state with higher mean).
Optional Viterbi decoding of the most likely regime sequence.
Painting modes:
ByProb – fixed threshold on probability of bull state.
ByState – based on last decoded Viterbi state.
More sophisticated and statistically meaningful than v1/v2.

Performance note:
EM iterations and forward–backward computations are heavier than Markov versions.
Recommended parameters for stability and speed: Period=150–300, EMIters=5–10.
Suitable for higher timeframes or end-of-bar calculations.

 [Markov Regime Probability (Basic).lua](files/160738/Markov%20Regime%20Probability%20%28Basic%29.lua)

 [Markov Regime Probability (Adaptive).lua](files/160738/Markov%20Regime%20Probability%20%28Adaptive%29.lua)

 [HMM Regime Probability (Baum–Welch).lua](files/160738/HMM%20Regime%20Probability%20%28BaumWelch%29.lua)
