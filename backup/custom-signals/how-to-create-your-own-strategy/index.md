# How to create your own strategy?

> Source: https://fxcodebase.com/code/viewtopic.php?f=28&t=2075  
> Forum: 29 · Topic 2075 · 1 post(s)


---

## How to create your own strategy?

**Konstantin.Usanov** · Mon Sep 06, 2010 6:40 am

“Everyone wants to win on Forex but not everyone knows how to do this.”

Since we play on Forex, we need to keep in mind one major thought: Forex is a volatile market and we need to find trends – up-trends to open buy positions and down-trends to open sell positions. In this case our positions will be profitable and we will win on Forex.

The process of finding appropriate trends is called "strategy" and can exist in the mind of a trader as a set of unique trading patterns or have a “physical” presentation in one or more software programs reflecting some considered trading patterns.

Some time ago I was impressed by the ability of some indicators (main tools of the technical analysis) to predict the price movement, i.e. detects trends and dreamed about own strategy.
I have deeply investigated this subject and found the strongest indicator in this context - MACD ([http://en.wikipedia.org/wiki/MACD](https://en.wikipedia.org/wiki/MACD)). The mechanism of its prediction is based on the difference between the price and indicator movements, for example, the price going up but the indicator going down. This difference called “divergence”. You can read more about divergence at [http://backtestingblog.com/technical-strategies/macd-technical-strategies/macd-divergence](http://backtestingblog.com/technical-strategies/macd-technical-strategies/macd-divergence).

In this article I will share my experience and describe how to create your own strategy program for the FXCM Trading Station (FXTS). So, let’s create strategy based on the ability of the MACD indicator to predict market trends.

I have started my development from recreation the MACD strategy for self (without using “helper.lua”), because I tried to understand the strategy developing as is. Later I found “**MACD Divergence indicator and signal**” ([http://fxcodebase.com/code/viewtopic.php?f=17&t=869](https://fxcodebase.com/code/viewtopic.php?f=17&t=869)) post with ready approach relative to divergence calculation and just applied it’s for self.
Final result can be found at this post: “**Introduce dMACD strategy (Divergence on MACD Signals)**” [http://www.fxcodebase.com/code/viewtopic.php?f=29&t=1985](http://www.fxcodebase.com/code/viewtopic.php?f=29&t=1985).

Since we are going to create a strategy for the FXTS platform, we only need to write a small program in a simple language to reach our aims. Fortunately, the FXTS platform provides a full set of instruments to do this: a useful manual "The Indicore SDK User Guide", a strategy debugger, and a back testing tool to perform preliminary testing of our strategies before using them on the real market - so we have the ability to estimate the efficiency of our strategy.

Strategies are written in the simple language of Lua ([http://en.wikipedia.org/wiki/Lua_(programming_language)](https://en.wikipedia.org/wiki/Lua_(programming_language))) and work on market data (price, for example) to calculate trading approaches. First of all, we need to get and locally install a set of development tools (**Indicore SDK**) from [http://www.fxcodebase.com/documentation.php](http://www.fxcodebase.com/documentation.php).

This set includes Editor (for writing strategies), Debugger (for debugging, since it is a usual development process) and Manual (a user guide with a full set of functions that can be used in your strategies).

The best way to create your own strategy, especially for beginners, is to “work by analogy”. I mean taking an existing strategy and modifying it for you. This approach will save your time and provide your fast involvement in the development process which will make you an independent and successful trader with clever tools.

Let’s open a ready strategy, for example, the file dMACD.lua in Editor and walk through the source code. Any strategy contains three simple functions: Init(), Prepare(), and Update(). In the Init function we generally define a set of parameters for our strategy, in Prepare we get ready for the planned calculations, and in Update all desired actions are performed. That’s all, simply and cleverly.

In some cases a strategy can have “resources”. It’s useful for localization purposes. To open recourses of the dMACD strategy, simply select “Open resources”on the “Tools” menu of the Editor. All entries from the resource file are used in the Init function and can be easily obtained using resources:get("xxx"), where xxx is a certain entry from the resource file.

Since we are writing a strategy, we need to input data for our calculations. The input data for us is prices or streams of prices in particular. Any strategy can work on two types of price streams, real and historical. Real prices are prices of live data that are permanently updated on the market, while historical prices are prices of collected data. The last ones are generally used for other data about time frames or instruments.
We work with input data in the Prepare and Update functions. Look at the Prepare function of the dMACD strategy, there you can find the "getHistory" execution. It is a command to get the history of the needed time frame (instance.parameters.Period) and a certain instrument (instance.bid:instrument()). We will define gSource in our strategy as the input data source. You can easily discover where we use our input data source by looking at the existing code and finding all such places. Generally, the data source is used to work with ready indicators, MACD in our case, and also to perform strategy calculations in the Update function.

In our strategy we use a ready indicator (MACD) included in the FXTS platform. Since it already has the calculations related to MACD necessary for us, we simply use it. For this purpose we use the command core.indicators:create in the Prepare function.

Data streams taken from any sources, from the MACD indicator in our case, may not contain data at first, so we need to determine where the first data is. It will be useful in our further calculations in the Update function. You can see the xxx :first() command, where xxx is a certain stream of data, in the Prepare function used for this.

Our main calculations intended to detect price trends via divergence are performed by the two functions: checkTrendDown(period) and checkTrendUp(period). The input parameter “period” determines which part of the price stream will be used. Since the Update function is called by the FXTS platform for every tick of data stream, we have the ability to perform our calculations exactly for all periods.
We have a simple way to decide which period is next for us. As the Update function is called for every period and, therefore, gSource (our data source) will get data in a growing way, we can use the size of the data source as the main parameter for period calculations. Please look at the Update function for its way of getting data.

The general result of any strategy is signaling where to perform a trade operation, to sell or to buy. Depending on our calculations we send alerts, the messages are called signals. You can find the two functions – toSELL(period) and toBUY(period) – and find there the command terminal:alertMessage used for this.
Since we are planning to use auto trading for our strategy we need to do two simple things. First, determine the environment: what is the current offer for the price, for which account to do this, and what the trade size will be. Second, create appropriate orders to open poisons. That is all. Please take a look at the end of the Prepare function to find out three command wrapped by instance.parameters.isNeedAutoTrading in the “If” construction. This is the first part of auto trading. The second part is implemented by a function named “trade” which contains commands for creating orders in the automatic mode. As you can see, the “trade” function is included in the toSELL(period) and toBUY(period) functions, so we will perform an auto trade only when our strategy decides to sell or to buy depending on the result of its calculations.

In addition to the three general functions of a strategy, Init(), Prepare(), and Update(), we also need to define one simple function. The AsyncOperationFinished function will be necessary for us in case we use historical input data for our strategy. Since loading of historical data is performed by the FXTS platform in the background mode, we need to know when this process is finished and we can start our calculations in the Update function.

All other functions in the dMACD code are used only to detect the price trend via divergence and using the checkTrendDown(period) and checkTrendUp(period) functions. We have to omit description of a certain algorithm of divergence detecting because you can easily find it yourself in the provided dMACD code or using any alternative internet sources.

The dMACD strategy can be easily used as a template for your own strategies. To do this, just remove all functions except the three general strategy functions, Init(), Prepare(), and Update(), from the code. Also you can keep toSELL(period), toBUY(period), and trade(type, period) as ready functions for signaling and trade operations. After this you need to slightly tune the Update function by substituting the existing calculation functions checkTrendDown(period) and checkTrendUp(period) by your own functions and change Prepare() to use your input data sources, stream prices or ready indicators. And, finally, you need to modify the Init function for your parameters.

You can always read the user guide included in “Indicore SDK” for more information and details. This is a good document describing a full set of functions that can be used in your strategy.

After finishing your own strategy, you should to check it for possible programming errors (bugs). The Indicore SDK provides us with a simple and powerful tool for this purpose – Strategy Debugger. First of all, you should place your strategy in the debugger folder. To do this, just copy the strategy files, for example dMACD.lua and dMACD.lua.rc files, to the folder “C:\Program Files\ IndicoreSDK\strategies” and then run Lua Strategy Debugger. Then you should open your strategy in Debugger (on the menu “File”, choose “Open Strategy” and then choose your file for Debugger). When your strategy is opened, you can perform two operations: run the strategy or walk it step by step. For this, select the appropriate command on the “Debug” menu. In both cases Debugger will ask you for Parameters of your strategy and also for History if you are using a historical data source. You can view the result of running (or stepping) your strategy in the set of tabs located at the bottom of the Debugger. If you have any bugs in your strategy, the Output tab will show the appropriate error messages pointing to the line of the code.

One more useful feature of Debugger is the ability to watch parts of your code. This is very useful when you walk the code step by step to locate an error. Just scroll the code to the necessary place and double-click any variable (for example, period) to select it, then press the C, A, and V keys in sequence holding the Ctrl key. The Watch dialog box will appear. Click OK or press Enter to confirm watching. The Watches tab will be filled with your variable. You also have the ability to perform the same via the Debugger menu (“Debug” -> “Add watch”).

In addition to watching, Debugger allows setting temporary stops in your code. This ability is very useful together with watching. Such temporary stops are called breakpoints. Just click any desired line of your code and then press F9 or on the “Debug” menu choose “Toggle Breakpoint”. A mark of the breakpoint (a white circle) will appear on the corresponding line to the left of the code.
In this case when you run your strategy, Debugger will stop at all breakpoints and you can watch the desired variable. All of this will considerably simplify detecting possible bugs in the code.

The last stage is back testing of your strategy in the FXTS platform.
First of all, you should copy your strategy and its resources (xxx.lua.rc file) to the FXTS folder (for example, to “C:\Program Files\Candleworks\FXTS2\strategies\Custom”). Then you should create a Practice Account at FXCM ([http://www.fxcm.com/open-free-100k.jsp](http://www.fxcm.com/open-free-100k.jsp)) and log in to FXTS with this demo account.
After this you should open Marketscope in FXTS by selecting “Open Marketscope” on the “Charts” menu and add the BACKTEST indicator to a chart. To do this, simply select “Add Indicator” on the “Insert” menu of Marketscope and choose the BACKTEST indicator from the list. BACKTEST will appear on the chart.
To continue, you should open BACKTEST Properties by double-clicking the indicator label and selecting your strategy as Signal (the first parameter of the BACKTEST properties). Then specify all necessary properties for your strategy. To do this, you should click the little button with three dots to the right of the selected strategy in the BACKTEST properties. When you finish with the settings and close the BACKTEST Properties dialog box by clicking OK, the back testing process will start and you will see the Equity chart at the bottom of the chart window as a result of work of your strategy. The price chart will also show your strategy with circles with numbers and arrows (up or down). In addition, you have the ability to get a report of the back testing process. For this, simply right-click in the Equity chart (the bottom area) and then select “BACKTEST(xxx): Show Report”, where xxx is the strategy being tested. The report is provided in a convenient format, so your Internet browser will be opened for it automatically with the appropriate **Strategy Performance Report**.

That’s all about how to create your own strategy for the FXCM Trading Station (FXTS).

As you can see, it’s not as difficult as it may seem for the first time. In any case we have a lot of great resources, like Indicore SDK tools and the [http://www.fxcodebase.com/](http://www.fxcodebase.com/) community where you can find answers to your questions and real solutions for your problems.

Please also take a look at article “**Developing, Debugging and Testing your first strategy**” [http://fxcodebase.com/code/viewtopic.php?f=28&t=2030](https://fxcodebase.com/code/viewtopic.php?f=28&t=2030). This article guides you trough all stages of strategy development: writing code, debugging, back testing and can be very useful for your strategy development.
