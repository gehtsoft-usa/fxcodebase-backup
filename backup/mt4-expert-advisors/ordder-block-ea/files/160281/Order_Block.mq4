// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76249

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_plots 0

input int    SwingLookback    = 10;      // Swing Lookback
input int    MaxBarsBack      = 200;     // Maximum bars back from current
input int    MaxSwings        = 5;       // Maximum number of swings to find
input int    ShowBullishOB    = 3;       // Show Last Bullish OB
input int    ShowBearishOB    = 3;       // Show Last Bearish OB
input bool   UseCandleBody    = false;   // Use Candle Body
input color  BullishOBColor   = clrBlue;     // Bullish OB Color
input color  BullBreakColor   = clrRed;      // Bullish Break Color
input color  BearishOBColor   = clrOrange;   // Bearish OB Color
input color  BearBreakColor   = clrLime;     // Bearish Break Color

struct OrderBlock
  {
   double            top;
   double            bottom;
   datetime          time;
   bool              breaker;
   datetime          break_time;
   int               swing_bar;
  };

OrderBlock bullish_obs[];
OrderBlock bearish_obs[];
datetime last_check_time = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArrayResize(bullish_obs, 0);
   ArrayResize(bearish_obs, 0);
   last_check_time = 0;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "OB_");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total < SwingLookback * 3)
      return(0);
   if(Time[0] != last_check_time)
     {
      last_check_time = Time[0];
      CheckOrderBlockBreaks(0, open, high, low, close);
      ObjectsDeleteAll(0, "OB_");
      OrderBlock temp_bullish[];
      OrderBlock temp_bearish[];
      ArrayCopy(temp_bullish, bullish_obs);
      ArrayCopy(temp_bearish, bearish_obs);
      ArrayResize(bullish_obs, 0);
      ArrayResize(bearish_obs, 0);
      FindSwingsFromCurrent(rates_total, time, open, high, low, close);
      RestoreBreakInfo(temp_bullish, temp_bearish);
      CheckOrderBlockBreaks(0, open, high, low, close);
      DrawOrderBlocks();
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FindSwingsFromCurrent(int rates_total,
                           const datetime &time[],
                           const double &open[],
                           const double &high[],
                           const double &low[],
                           const double &close[])
  {
   int swing_highs_found = 0;
   int swing_lows_found = 0;
   int start_bar = SwingLookback;
   int end_bar = MathMin(MaxBarsBack, rates_total - SwingLookback);
   for(int i = start_bar; i < end_bar && (swing_highs_found < MaxSwings || swing_lows_found < MaxSwings); i++)
     {
      if(swing_highs_found < MaxSwings && IsSwingHigh(i, rates_total, high))
        {
         CreateBearishOrderBlock(i, time, open, high, low, close);
         swing_highs_found++;
        }
      if(swing_lows_found < MaxSwings && IsSwingLow(i, rates_total, low))
        {
         CreateBullishOrderBlock(i, time, open, high, low, close);
         swing_lows_found++;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsSwingHigh(int bar, int total, const double &high[])
  {
   if(bar < SwingLookback || bar >= total - SwingLookback)
     {
      return false;
     }
   double current_high = high[bar];
   for(int i = bar + 1; i <= bar + SwingLookback; i++)
     {
      if(i >= total)
         break;
      if(high[i] >= current_high)
        {
         return false;
        }
     }
   for(int i = bar - SwingLookback; i < bar; i++)
     {
      if(i < 0)
         break;
      if(high[i] >= current_high)
        {
         return false;
        }
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsSwingLow(int bar, int total, const double &low[])
  {
   if(bar < SwingLookback || bar >= total - SwingLookback)
     {
      return false;
     }
   double current_low = low[bar];
   for(int i = bar + 1; i <= bar + SwingLookback; i++)
     {
      if(i >= total)
         break;
      if(low[i] <= current_low)
        {
         return false;
        }
     }
   for(int i = bar - SwingLookback; i < bar; i++)
     {
      if(i < 0)
         break;
      if(low[i] <= current_low)
        {
         return false;
        }
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateBullishOrderBlock(int swing_bar,
                             const datetime &time[],
                             const double &open[],
                             const double &high[],
                             const double &low[],
                             const double &close[])
  {
   for(int k = 0; k < ArraySize(bullish_obs); k++)
     {
      if(bullish_obs[k].swing_bar == swing_bar)
         return;
     }
   double min_low = low[swing_bar];
   double ob_high = high[swing_bar];
   datetime ob_time = time[swing_bar];
   int ob_bar = swing_bar;
   for(int j = swing_bar + 1; j <= swing_bar + SwingLookback; j++)
     {
      if(j >= ArraySize(time))
         continue;
      double candle_low = UseCandleBody ? MathMin(open[j], close[j]) : low[j];
      double candle_high = UseCandleBody ? MathMax(open[j], close[j]) : high[j];
      if(candle_low <= min_low)
        {
         min_low = candle_low;
         ob_high = candle_high;
         ob_time = time[j];
         ob_bar = j;
        }
     }
   int size = ArraySize(bullish_obs);
   ArrayResize(bullish_obs, size + 1);
   bullish_obs[size].top = ob_high;
   bullish_obs[size].bottom = min_low;
   bullish_obs[size].time = ob_time;
   bullish_obs[size].breaker = false;
   bullish_obs[size].break_time = 0;
   bullish_obs[size].swing_bar = swing_bar;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateBearishOrderBlock(int swing_bar,
                             const datetime &time[],
                             const double &open[],
                             const double &high[],
                             const double &low[],
                             const double &close[])
  {
   for(int k = 0; k < ArraySize(bearish_obs); k++)
     {
      if(bearish_obs[k].swing_bar == swing_bar)
         return;
     }
   double max_high = high[swing_bar];
   double ob_low = low[swing_bar];
   datetime ob_time = time[swing_bar];
   int ob_bar = swing_bar;
   for(int j = swing_bar + 1; j <= swing_bar + SwingLookback; j++)
     {
      if(j >= ArraySize(time))
         continue;
      double candle_low = UseCandleBody ? MathMin(open[j], close[j]) : low[j];
      double candle_high = UseCandleBody ? MathMax(open[j], close[j]) : high[j];
      if(candle_high >= max_high)
        {
         max_high = candle_high;
         ob_low = candle_low;
         ob_time = time[j];
         ob_bar = j;
        }
     }
   int size = ArraySize(bearish_obs);
   ArrayResize(bearish_obs, size + 1);
   bearish_obs[size].top = max_high;
   bearish_obs[size].bottom = ob_low;
   bearish_obs[size].time = ob_time;
   bearish_obs[size].breaker = false;
   bearish_obs[size].break_time = 0;
   bearish_obs[size].swing_bar = swing_bar;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RestoreBreakInfo(const OrderBlock &old_bullish[], const OrderBlock &old_bearish[])
  {
   for(int i = 0; i < ArraySize(bullish_obs); i++)
     {
      for(int j = 0; j < ArraySize(old_bullish); j++)
        {
         if(bullish_obs[i].swing_bar == old_bullish[j].swing_bar &&
            bullish_obs[i].time == old_bullish[j].time)
           {
            bullish_obs[i].breaker = old_bullish[j].breaker;
            bullish_obs[i].break_time = old_bullish[j].break_time;
            break;
           }
        }
     }
   for(int i = 0; i < ArraySize(bearish_obs); i++)
     {
      for(int j = 0; j < ArraySize(old_bearish); j++)
        {
         if(bearish_obs[i].swing_bar == old_bearish[j].swing_bar &&
            bearish_obs[i].time == old_bearish[j].time)
           {
            bearish_obs[i].breaker = old_bearish[j].breaker;
            bearish_obs[i].break_time = old_bearish[j].break_time;
            break;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckOrderBlockBreaks(int current_bar,
                           const double &open[],
                           const double &high[],
                           const double &low[],
                           const double &close[])
  {
   for(int i = 0; i < ArraySize(bullish_obs); i++)
     {
      if(!bullish_obs[i].breaker)
        {
         int ob_bar_index = -1;
         for(int b = 0; b < Bars; b++)
           {
            if(Time[b] == bullish_obs[i].time)
              {
               ob_bar_index = b;
               break;
              }
           }
         if(ob_bar_index == -1)
            continue;
         for(int bar = ob_bar_index - 1; bar >= current_bar; bar--)
           {
            if(bar < 0 || bar >= Bars)
               continue;
            double candle_low = UseCandleBody ? MathMin(open[bar], close[bar]) : low[bar];
            if(candle_low < bullish_obs[i].bottom)
              {
               bullish_obs[i].breaker = true;
               bullish_obs[i].break_time = Time[bar];
               break;
              }
           }
        }
     }
   for(int i = 0; i < ArraySize(bearish_obs); i++)
     {
      if(!bearish_obs[i].breaker)
        {
         int ob_bar_index = -1;
         for(int b = 0; b < Bars; b++)
           {
            if(Time[b] == bearish_obs[i].time)
              {
               ob_bar_index = b;
               break;
              }
           }
         if(ob_bar_index == -1)
            continue;
         for(int bar = ob_bar_index - 1; bar >= current_bar; bar--)
           {
            if(bar < 0 || bar >= Bars)
               continue;
            double candle_high = UseCandleBody ? MathMax(open[bar], close[bar]) : high[bar];
            if(candle_high > bearish_obs[i].top)
              {
               bearish_obs[i].breaker = true;
               bearish_obs[i].break_time = Time[bar];
               break;
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawOrderBlocks()
  {
   datetime current_time = TimeCurrent();
   int bull_count = MathMin(ShowBullishOB, ArraySize(bullish_obs));
   int bull_start = MathMax(0, ArraySize(bullish_obs) - ShowBullishOB);
   for(int i = bull_start; i < ArraySize(bullish_obs); i++)
     {
      string date_str = TimeToString(bullish_obs[i].time, TIME_DATE | TIME_MINUTES);
      StringReplace(date_str, ".", "");
      StringReplace(date_str, ":", "");
      StringReplace(date_str, " ", "_");
      string obj_name = "OB_Bull_" + IntegerToString(i) + "_" + date_str;
      if(bullish_obs[i].breaker)
        {
         if(bullish_obs[i].break_time > bullish_obs[i].time)
           {
            ObjectCreate(0, obj_name + "_Orig", OBJ_RECTANGLE, 0,
                         bullish_obs[i].time, bullish_obs[i].top,
                         bullish_obs[i].break_time, bullish_obs[i].bottom);
            ObjectSetInteger(0, obj_name + "_Orig", OBJPROP_COLOR, BullishOBColor);
            ObjectSetInteger(0, obj_name + "_Orig", OBJPROP_FILL, true);
            ObjectSetInteger(0, obj_name + "_Orig", OBJPROP_BACK, true);
            ObjectSetInteger(0, obj_name + "_Orig", OBJPROP_WIDTH, 1);
           }
         ObjectCreate(0, obj_name + "_Break", OBJ_RECTANGLE, 0,
                      bullish_obs[i].break_time, bullish_obs[i].top,
                      current_time, bullish_obs[i].bottom);
         ObjectSetInteger(0, obj_name + "_Break", OBJPROP_COLOR, BullBreakColor);
         ObjectSetInteger(0, obj_name + "_Break", OBJPROP_FILL, true);
         ObjectSetInteger(0, obj_name + "_Break", OBJPROP_BACK, true);
         ObjectSetInteger(0, obj_name + "_Break", OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, obj_name + "_Break", OBJPROP_STYLE, STYLE_DOT);
        }
      else
        {
         ObjectCreate(0, obj_name, OBJ_RECTANGLE, 0,
                      bullish_obs[i].time, bullish_obs[i].top,
                      current_time, bullish_obs[i].bottom);
         ObjectSetInteger(0, obj_name, OBJPROP_COLOR, BullishOBColor);
         ObjectSetInteger(0, obj_name, OBJPROP_FILL, true);
         ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
         ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 1);
        }
     }
   int bear_count = MathMin(ShowBearishOB, ArraySize(bearish_obs));
   int bear_start = MathMax(0, ArraySize(bearish_obs) - ShowBearishOB);
   for(int i = bear_start; i < ArraySize(bearish_obs); i++)
     {
      string date_str = TimeToString(bearish_obs[i].time, TIME_DATE | TIME_MINUTES);
      StringReplace(date_str, ".", "");
      StringReplace(date_str, ":", "");
      StringReplace(date_str, " ", "_");
      string obj_name = "OB_Bear_" + IntegerToString(i) + "_" + date_str;
      if(bearish_obs[i].breaker)
        {
         if(bearish_obs[i].break_time > bearish_obs[i].time)
           {
            ObjectCreate(0, obj_name + "_Orig", OBJ_RECTANGLE, 0,
                         bearish_obs[i].time, bearish_obs[i].top,
                         bearish_obs[i].break_time, bearish_obs[i].bottom);
            ObjectSetInteger(0, obj_name + "_Orig", OBJPROP_COLOR, BearishOBColor);
            ObjectSetInteger(0, obj_name + "_Orig", OBJPROP_FILL, true);
            ObjectSetInteger(0, obj_name + "_Orig", OBJPROP_BACK, true);
            ObjectSetInteger(0, obj_name + "_Orig", OBJPROP_WIDTH, 1);
           }
         ObjectCreate(0, obj_name + "_Break", OBJ_RECTANGLE, 0,
                      bearish_obs[i].break_time, bearish_obs[i].top,
                      current_time, bearish_obs[i].bottom);
         ObjectSetInteger(0, obj_name + "_Break", OBJPROP_COLOR, BearBreakColor);
         ObjectSetInteger(0, obj_name + "_Break", OBJPROP_FILL, true);
         ObjectSetInteger(0, obj_name + "_Break", OBJPROP_BACK, true);
         ObjectSetInteger(0, obj_name + "_Break", OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, obj_name + "_Break", OBJPROP_STYLE, STYLE_DOT);
        }
      else
        {
         ObjectCreate(0, obj_name, OBJ_RECTANGLE, 0,
                      bearish_obs[i].time, bearish_obs[i].top,
                      current_time, bearish_obs[i].bottom);
         ObjectSetInteger(0, obj_name, OBJPROP_COLOR, BearishOBColor);
         ObjectSetInteger(0, obj_name, OBJPROP_FILL, true);
         ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
         ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 1);
        }
     }
  }
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76249

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+