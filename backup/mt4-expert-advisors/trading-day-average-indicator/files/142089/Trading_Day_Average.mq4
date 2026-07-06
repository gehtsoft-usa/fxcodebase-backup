// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=17983

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.1"

#property indicator_chart_window

input string BeginTime = "03:00";
enum Mode
{
   HighLow, // High/Low
   OpenClose // Open/Close
};
input Mode mode = HighLow; // Mode
input int bars_limit = 1000; // Bars limit

#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Green

double CloudBuff[], LowBuff[], HighBuff[];

int init()
{
   IndicatorShortName("Trading day average");
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, CloudBuff);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, LowBuff);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, HighBuff);
   return (0);
}

int deinit()
{

   return (0);
}

int start()
{
   if (Bars <= 2)
      return (0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0)
      return (-1);
   int toSkip = 0;
   for (int pos = MathMin(bars_limit, Bars - 1 - MathMax(IndicatorCounted() - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      datetime LastBegin = StrToTime(TimeToStr(Time[pos], TIME_DATE) + " " + BeginTime);
      if (LastBegin > Time[pos])
         LastBegin -= 86400;
      int LastBeginBar = iBarShift(NULL, 0, LastBegin, false);
      int Length = LastBeginBar - pos + 1;
      CloudBuff[pos] = iMA(NULL, 0, Length, 0, MODE_SMA, mode == HighLow ? PRICE_HIGH : PRICE_OPEN, pos);
      HighBuff[pos] = CloudBuff[pos];
      LowBuff[pos] = iMA(NULL, 0, Length, 0, MODE_SMA, mode == HighLow ? PRICE_LOW : PRICE_CLOSE, pos);
   }

   return (0);
}
