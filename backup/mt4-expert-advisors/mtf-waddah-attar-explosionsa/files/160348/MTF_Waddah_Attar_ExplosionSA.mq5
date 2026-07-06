// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76263

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

#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_plots 4
#property  indicator_color1  Green
#property  indicator_color2  Red
#property  indicator_color3  Gold
#property  indicator_color4  Aqua
#property  indicator_minimum 0.0
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 1
#property indicator_width4 1
//----
input ENUM_TIMEFRAMES    inpTimeFrame    = PERIOD_CURRENT;
input int                BarLimit     = 1000;
input int                Sensetive    = 150;
input int                DeadZonePip  = 15;
input int                ExplosionPower = 15;
input int                TrendPower   = 15;
input bool               AlertWindow  = false;
input int                AlertCount   = 20;
input bool               AlertLong    = true;
input bool               AlertShort   = true;
input bool               AlertExitLong = true;
input bool               AlertExitShort = true;
//----
double   ind_buffer1[];
double   ind_buffer2[];
double   ind_buffer3[];
double   ind_buffer4[];
//----
int LastTime1 = 1;
int LastTime2 = 1;
int LastTime3 = 1;
int LastTime4 = 1;
int Status = 0, PrevStatus = -1;
double bask, bbid;
ENUM_TIMEFRAMES TimeFrame;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ind_buffer1, INDICATOR_DATA);
   SetIndexBuffer(1, ind_buffer2, INDICATOR_DATA);
   SetIndexBuffer(2, ind_buffer3, INDICATOR_DATA);
   SetIndexBuffer(3, ind_buffer4, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
   ArraySetAsSeries(ind_buffer1, true);
   ArraySetAsSeries(ind_buffer2, true);
   ArraySetAsSeries(ind_buffer3, true);
   ArraySetAsSeries(ind_buffer4, true);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   if(inpTimeFrame == PERIOD_CURRENT || inpTimeFrame <= Period())
      TimeFrame = Period();
   else
     {
      TimeFrame = inpTimeFrame;
      EventSetMillisecondTimer(500);
     }
   string short_name = "WadAttExpl:|" + (string)(TimeFrame) + "|[S-" + (string)Sensetive + "][DZ-" + (string)DeadZonePip + "][EP-" + (string)ExplosionPower + "][TrP-" + (string)TrendPower + "]";
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ChartSetSymbolPeriod(ChartID(), _Symbol, Period());
   ChartRedraw();
  }

enum UP_LOW_MODE     { MODE_BASE,         MODE_UPPER,      MODE_LOWER };
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
   double Trend1, Trend2, Explo1, Explo2, Dead;
   double pwrt, pwre;
   int counted_bars = prev_calculated;
   if(counted_bars < 0)
      return(-1);
   if(counted_bars > 0)
      counted_bars--;
   int limit = MathMin(rates_total, BarLimit);
   double Ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   for(int i = limit - 1; i >= 0; i--)
     {
      datetime barTime = iTime(_Symbol, Period(), i);
      int y = iBarShift(_Symbol, TimeFrame, barTime);
      if(y < 0)
         y = 0;
      Trend1 = (iMACDMQL4(NULL, TimeFrame, 20, 40, 9, PRICE_CLOSE, 0, y) -
                iMACDMQL4(NULL, TimeFrame, 20, 40, 9, PRICE_CLOSE, 0, y + 1)) * Sensetive;
      Trend2 = (iMACDMQL4(NULL, TimeFrame, 20, 40, 9, PRICE_CLOSE, 0, y + 2) -
                iMACDMQL4(NULL, TimeFrame, 20, 40, 9, PRICE_CLOSE, 0, y + 3)) * Sensetive;
      Explo1 = (iBandsMQL4(NULL, TimeFrame, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, y) -
                iBandsMQL4(NULL, TimeFrame, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, y));
      Explo2 = (iBandsMQL4(NULL, TimeFrame, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, y + 1) -
                iBandsMQL4(NULL, TimeFrame, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, y + 1));
      Dead = Point() * DeadZonePip;
      ind_buffer1[i] = 0;
      ind_buffer2[i] = 0;
      ind_buffer3[i] = 0;
      ind_buffer4[i] = 0;
      if(Trend1 >= 0)
         ind_buffer1[i] = Trend1;
      if(Trend1 < 0)
         ind_buffer2[i] = (-1 * Trend1);
      ind_buffer3[i] = Explo1;
      ind_buffer4[i] = Dead;
      if(i == 0)
        {
         if(Trend1 > 0 && Trend1 > Explo1 && Trend1 > Dead &&
            Explo1 > Dead && Explo1 > Explo2 && Trend1 > Trend2 &&
            LastTime1 < AlertCount && AlertLong == true && Ask != bask)
           {
            pwrt = 100 * (Trend1 - Trend2) / Trend1;
            pwre = 100 * (Explo1 - Explo2) / Explo1;
            bask = Ask;
            if(pwre >= ExplosionPower && pwrt >= TrendPower)
              {
               if(AlertWindow == true)
                 {
                  Alert("WAE", LastTime1, "- ", Symbol(), " - BUY ", " (",
                        DoubleToString(bask, Digits()), ") Trend PWR ",
                        DoubleToString(pwrt, 0), " - Exp PWR ", DoubleToString(pwre, 0));
                 }
               else
                 {
                  Print("WAE", LastTime1, "- ", Symbol(), " - BUY ", " (",
                        DoubleToString(bask, Digits()), ") Trend PWR ",
                        DoubleToString(pwrt, 0), " - Exp PWR ", DoubleToString(pwre, 0));
                 }
               LastTime1++;
              }
            Status = 1;
           }
         if(Trend1 < 0 && MathAbs(Trend1) > Explo1 && MathAbs(Trend1) > Dead &&
            Explo1 > Dead && Explo1 > Explo2 && MathAbs(Trend1) > MathAbs(Trend2) &&
            LastTime2 < AlertCount && AlertShort == true && Bid != bbid)
           {
            pwrt = 100 * (MathAbs(Trend1) - MathAbs(Trend2)) / MathAbs(Trend1);
            pwre = 100 * (Explo1 - Explo2) / Explo1;
            bbid = Bid;
            if(pwre >= ExplosionPower && pwrt >= TrendPower)
              {
               if(AlertWindow == true)
                 {
                  Alert("WAE", LastTime2, "- ", Symbol(), " - SELL ", " (",
                        DoubleToString(bbid, Digits()), ") Trend PWR ",
                        DoubleToString(pwrt, 0), " - Exp PWR ", DoubleToString(pwre, 0));
                 }
               else
                 {
                  Print("WAE", LastTime2, "- ", Symbol(), " - SELL ", " (",
                        DoubleToString(bbid, Digits()), ") Trend PWR ",
                        DoubleToString(pwrt, 0), " - Exp PWR ", DoubleToString(pwre, 0));
                 }
               LastTime2++;
              }
            Status = 2;
           }
         if(Trend1 > 0 && Trend1 < Explo1 && Trend1 < Trend2 && Trend2 > Explo2 &&
            Trend1 > Dead && Explo1 > Dead && LastTime3 <= AlertCount &&
            AlertExitLong == true && Bid != bbid)
           {
            bbid = Bid;
            if(AlertWindow == true)
              {
               Alert("WAE", LastTime3, "- ", Symbol(), " - Exit BUY ", " ",
                     DoubleToString(bbid, Digits()));
              }
            else
              {
               Print("WAE", LastTime3, "- ", Symbol(), " - Exit BUY ", " ",
                     DoubleToString(bbid, Digits()));
              }
            Status = 3;
            LastTime3++;
           }
         if(Trend1 < 0 && MathAbs(Trend1) < Explo1 &&
            MathAbs(Trend1) < MathAbs(Trend2) && MathAbs(Trend2) > Explo2 &&
            Trend1 > Dead && Explo1 > Dead && LastTime4 <= AlertCount &&
            AlertExitShort == true && Ask != bask)
           {
            bask = Ask;
            if(AlertWindow == true)
              {
               Alert("WAE", LastTime4, "- ", Symbol(), " - Exit SELL ", " ",
                     DoubleToString(bask, Digits()));
              }
            else
              {
               Print("WAE", LastTime4, "- ", Symbol(), " - Exit SELL ", " ",
                     DoubleToString(bask, Digits()));
              }
            Status = 4;
            LastTime4++;
           }
         PrevStatus = Status;
        }
      if(Status != PrevStatus)
        {
         LastTime1 = 1;
         LastTime2 = 1;
         LastTime3 = 1;
         LastTime4 = 1;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
double iMACDMQL4(string symbol, int tf, int fast_ema_period, int slow_ema_period, int signal_period, int price, int mode, int shift)
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   ENUM_APPLIED_PRICE applied_price = PriceMigrate(price);
   int handle = iMACD(symbol, timeframe,
                      fast_ema_period, slow_ema_period,
                      signal_period, applied_price);
   if(handle < 0)
     {
      Print("The iMACD object is not created: Error ", GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle, mode, shift));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iBandsMQL4(string symbol, int tf, int period, double deviation, int bands_shift, int method, int mode, int shift)
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   ENUM_MA_METHOD ma_method = MethodMigrate(method);
   int handle = iBands(symbol, timeframe, period,
                       bands_shift, deviation, ma_method);
   if(handle < 0)
     {
      Print("The iBands object is not created: Error", GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle, mode, shift));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TFMigrate(int tf)
  {
   switch(tf)
     {
      case 0:
         return(PERIOD_CURRENT);
      case 1:
         return(PERIOD_M1);
      case 5:
         return(PERIOD_M5);
      case 15:
         return(PERIOD_M15);
      case 30:
         return(PERIOD_M30);
      case 60:
         return(PERIOD_H1);
      case 240:
         return(PERIOD_H4);
      case 1440:
         return(PERIOD_D1);
      case 10080:
         return(PERIOD_W1);
      case 43200:
         return(PERIOD_MN1);
      case 2:
         return(PERIOD_M2);
      case 3:
         return(PERIOD_M3);
      case 4:
         return(PERIOD_M4);
      case 6:
         return(PERIOD_M6);
      case 10:
         return(PERIOD_M10);
      case 12:
         return(PERIOD_M12);
      case 16385:
         return(PERIOD_H1);
      case 16386:
         return(PERIOD_H2);
      case 16387:
         return(PERIOD_H3);
      case 16388:
         return(PERIOD_H4);
      case 16390:
         return(PERIOD_H6);
      case 16392:
         return(PERIOD_H8);
      case 16396:
         return(PERIOD_H12);
      case 16408:
         return(PERIOD_D1);
      case 32769:
         return(PERIOD_W1);
      case 49153:
         return(PERIOD_MN1);
      default:
         return(PERIOD_CURRENT);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CopyBufferMQL4(int handle, int index, int shift)
  {
   double buf[];
   ArraySetAsSeries(buf, true);
   switch(index)
     {
      case 0:
         if(CopyBuffer(handle, 0, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 1:
         if(CopyBuffer(handle, 1, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 2:
         if(CopyBuffer(handle, 2, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 3:
         if(CopyBuffer(handle, 3, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 4:
         if(CopyBuffer(handle, 4, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      default:
         break;
     }
   return(EMPTY_VALUE);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_MA_METHOD MethodMigrate(int method)
  {
   switch(method)
     {
      case 0:
         return(MODE_SMA);
      case 1:
         return(MODE_EMA);
      case 2:
         return(MODE_SMMA);
      case 3:
         return(MODE_LWMA);
      default:
         return(MODE_SMA);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_APPLIED_PRICE PriceMigrate(int price)
  {
   switch(price)
     {
      case 1:
         return(PRICE_CLOSE);
      case 2:
         return(PRICE_OPEN);
      case 3:
         return(PRICE_HIGH);
      case 4:
         return(PRICE_LOW);
      case 5:
         return(PRICE_MEDIAN);
      case 6:
         return(PRICE_TYPICAL);
      case 7:
         return(PRICE_WEIGHTED);
      default:
         return(PRICE_CLOSE);
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76263

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