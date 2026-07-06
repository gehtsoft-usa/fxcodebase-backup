// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=149693#p149693

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

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   2
#property indicator_color1 clrBlue
#property indicator_color2 clrRed


//extern bool Email = TRUE;
input int SL_add_pips = 11;
int gi_84 = 1;
input int changeLiner = 1;
int gi_unused_92 = 1;
int g_shift_96 = 977;
input int Gup = 4;
double g_ibuf_104[];
double g_ibuf_108[];
double g_ibuf_112[];
int g_period_116 = 9;
double g_ibuf_120[];
double g_ibuf_124[];
double g_ibuf_128[];
bool gi_unused_132 = false;
bool gi_unused_136 = false;
bool gi_140 = false;
bool gi_unused_144 = true;
string gs_148 = "BuySellWait";
string g_name_156;
int gi_164 = 1;
int gi_168 = 1;
int gi_172 = 1;
double gd_176 = 1.0;
double gd_184 = 1.0;
int gi_192 = -1;
datetime g_time_196;
input int                BarLimit     = 1000;
input bool  notificationsOn       = true;                      // Notifications
input bool   desktop_notifications = true;                     // Desktop MT4 notifications
input bool   email_notifications   = false;                    // Email notifications
input bool   push_notifications    = false;                    // Push mobile notifications
input bool   sound_notifications   = false;                    // Sound notifications
input string sound_file = "Tick.wav";                          // Choose a sound file for notifications

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, g_ibuf_112, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, gi_164);
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   SetIndexBuffer(1, g_ibuf_120, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, gi_164);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);
   SetIndexBuffer(2, g_ibuf_104, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, g_ibuf_108, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, g_ibuf_124, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, g_ibuf_128, INDICATOR_CALCULATIONS);
   ArraySetAsSeries(g_ibuf_104, true);
   ArraySetAsSeries(g_ibuf_108, true);
   ArraySetAsSeries(g_ibuf_112, true);
   ArraySetAsSeries(g_ibuf_120, true);
   ArraySetAsSeries(g_ibuf_124, true);
   ArraySetAsSeries(g_ibuf_128, true);
   return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   Comment(" ");
   ObjectDelete(0, g_name_156);
   return (0);
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
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);
   ArraySetAsSeries(volume, true);
   ArraySetAsSeries(spread, true);
   int li_36 = 0;
   double ld_0 = 0.0;
   double ld_8 = 0.0;
   double ld_16 = 0.0;
   int limit;
   g_shift_96 = rates_total;
   f0_0();
   limit = MathMin(rates_total - 2, BarLimit);
   ArrayResize(g_ibuf_124, limit + 1);
   ArrayResize(g_ibuf_128, limit + 1);
   ArrayResize(g_ibuf_104, limit + 1);
   ArrayResize(g_ibuf_108, limit + 1);
   ArrayResize(g_ibuf_112, limit + 1);
   ArrayResize(g_ibuf_120, limit + 1);
   for(int li_40 = limit; li_40 >= 0; li_40--)
     {
      if(f0_1(li_40))
        {
         gi_168 = 0;
         gi_172 = gi_192;
         gd_176 = high[li_40];
         li_36 = -1;
         if(li_40 == 1)
           {
            ld_0 = -1;
            ld_8 = high[1] + SL_add_pips * _Point;
            ld_16 = close[1] - (ld_8 - close[1]);
            f0_4("Sell signal", ld_16, ld_8, close[1]);
           }
        }
      if(f0_2(li_40))
        {
         gi_168 = 0;
         gi_172 = gi_192;
         gd_176 = low[li_40];
         li_36 = 1;
         if(li_40 == 1)
           {
            ld_0 = 1;
            ld_8 = low[2] - SL_add_pips * _Point;
            ld_16 = close[1] + (close[1] - ld_8);
            f0_4("Buy signal", ld_16, ld_8, close[1]);
           }
        }
      gd_184 = gd_176 - close[li_40];
      gi_168 += (int)volume[li_40];
      gi_172++;
      if(li_36 == 1)
        {
         g_ibuf_124[li_40] = gi_168;
         g_ibuf_128[li_40] = 0;
        }
      else
        {
         g_ibuf_128[li_40] = gi_168;
         g_ibuf_124[li_40] = 0;
        }
     }
   f0_3(ld_0);
   return (rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f0_3(double ad_0)
  {
   g_name_156 = gs_148 + "BuySellwait";
   string text_8 = " Current Signal: ";
   if(ad_0 == 0.0)
      text_8 = text_8 + "Wait Next Signal ";
   if(ad_0 < 0.0)
      text_8 = text_8 + "Sell";
   if(ad_0 > 0.0)
      text_8 = text_8 + "Buy";
   int li_16 = (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
   int li_20 = PeriodSeconds(_Period);
   double ld_24 = iHigh(_Symbol, _Period, iHighest(_Symbol, _Period, MODE_HIGH, li_16 * 4 / 5, 0));
   double ld_32 = iLow(_Symbol, _Period, iLowest(_Symbol, _Period, MODE_LOW, (li_16 * 4) / 5, 0));
   datetime datetime_40 = iTime(_Symbol, _Period, 0) + (li_16 / 75 + 10) * li_20;
   double price_48 = ld_32 + (ld_24 - ld_32) / 10.0;
   double ld_56 = MathMax(7, 3.0 * MathCeil(li_16 / 5.0 / 3.0) + 1.0 - 3.0) * li_20;
   ObjectDelete(0, g_name_156);
   ObjectCreate(0, g_name_156, OBJ_TEXT, 0, datetime_40, price_48);
   ObjectSetString(0, g_name_156, OBJPROP_TEXT, text_8);
   ObjectSetInteger(0, g_name_156, OBJPROP_COLOR, clrYellow);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int f0_1(int ai_0)
  {
   if(g_ibuf_120[ai_0] == EMPTY_VALUE)
      return (0);
   return (g_ibuf_120[ai_0] > 0.0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int f0_2(int ai_0)
  {
   if(g_ibuf_112[ai_0] == EMPTY_VALUE)
      return (0);
   return (g_ibuf_112[ai_0] > 0.0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum UP_LOW_MODE     { MODE_BASE,         MODE_UPPER,      MODE_LOWER };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f0_0()
  {
   int li_0 = 0;
   double lda_4[];
   double lda_8[];
   double lda_12[];
   double lda_16[];
   ArrayResize(lda_4, g_shift_96);
   ArrayResize(lda_8, g_shift_96);
   ArrayResize(lda_12, g_shift_96);
   ArrayResize(lda_16, g_shift_96);
   ArrayResize(g_ibuf_104, g_shift_96);
   ArrayResize(g_ibuf_108, g_shift_96);
   ArrayResize(g_ibuf_112, g_shift_96);
   ArrayResize(g_ibuf_120, g_shift_96);
   ArraySetAsSeries(lda_4, true);
   ArraySetAsSeries(lda_8, true);
   ArraySetAsSeries(lda_12, true);
   ArraySetAsSeries(lda_16, true);
   ArraySetAsSeries(g_ibuf_104, true);
   ArraySetAsSeries(g_ibuf_108, true);
   ArraySetAsSeries(g_ibuf_112, true);
   ArraySetAsSeries(g_ibuf_120, true);
   for(int shift_20 = g_shift_96 - 1; shift_20 > 0; shift_20--)
     {
      g_ibuf_104[shift_20] = 0;
      g_ibuf_108[shift_20] = 0;
      g_ibuf_112[shift_20] = EMPTY_VALUE;
      g_ibuf_120[shift_20] = EMPTY_VALUE;
     }
   for(int shift_20 = g_shift_96 - g_period_116 - 1; shift_20 > 0; shift_20--)
     {
      lda_4[shift_20] = iBandsMQL4(NULL, 0, g_period_116, Gup, 0, PRICE_CLOSE, MODE_UPPER, shift_20);
      lda_8[shift_20] = iBandsMQL4(NULL, 0, g_period_116, Gup, 0, PRICE_CLOSE, MODE_LOWER, shift_20);
      if(iClose(NULL, 0, shift_20) > lda_4[shift_20 + 1])
         li_0 = 1;
      if(iClose(NULL, 0, shift_20) < lda_8[shift_20 + 1])
         li_0 = -1;
      if(li_0 > 0 && lda_8[shift_20] < lda_8[shift_20 + 1])
         lda_8[shift_20] = lda_8[shift_20 + 1];
      if(li_0 < 0 && lda_4[shift_20] > lda_4[shift_20 + 1])
         lda_4[shift_20] = lda_4[shift_20 + 1];
      lda_12[shift_20] = lda_4[shift_20] + (gi_84 - 1) / 2.0 * (lda_4[shift_20] - lda_8[shift_20]);
      lda_16[shift_20] = lda_8[shift_20] - (gi_84 - 1) / 2.0 * (lda_4[shift_20] - lda_8[shift_20]);
      if(li_0 > 0 && lda_16[shift_20] < lda_16[shift_20 + 1])
         lda_16[shift_20] = lda_16[shift_20 + 1];
      if(li_0 < 0 && lda_12[shift_20] > lda_12[shift_20 + 1])
         lda_12[shift_20] = lda_12[shift_20 + 1];
      if(li_0 > 0)
        {
         if(changeLiner > 0 && g_ibuf_104[shift_20 + 1] == -1.0)
           {
            g_ibuf_112[shift_20] = lda_16[shift_20];
            g_ibuf_104[shift_20] = lda_16[shift_20];
           }
         else
           {
            g_ibuf_104[shift_20] = lda_16[shift_20];
            g_ibuf_112[shift_20] = EMPTY_VALUE;
           }
         if(changeLiner == 2)
            g_ibuf_104[shift_20] = 0;
         g_ibuf_120[shift_20] = EMPTY_VALUE;
         g_ibuf_108[shift_20] = -1.0;
        }
      if(li_0 < 0)
        {
         if(changeLiner > 0 && g_ibuf_108[shift_20 + 1] == -1.0)
           {
            g_ibuf_120[shift_20] = lda_12[shift_20];
            g_ibuf_108[shift_20] = lda_12[shift_20];
           }
         else
           {
            g_ibuf_108[shift_20] = lda_12[shift_20];
            g_ibuf_120[shift_20] = EMPTY_VALUE;
           }
         if(changeLiner == 2)
            g_ibuf_108[shift_20] = 0;
         g_ibuf_112[shift_20] = EMPTY_VALUE;
         g_ibuf_104[shift_20] = -1.0;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f0_4(string as_0, double ad_8, double ad_16, double ad_24)
  {
   string ls_32;
   string ls_40;
   string ls_48;
   string ls_56;
   string ls_64;
   if(iTime(_Symbol, _Period, 0) != g_time_196)
     {
      g_time_196 = iTime(_Symbol, _Period, 0);
      if(ad_24 != 0.0)
         ls_48 = " price " + DoubleToString(ad_24, 4);
      else
         ls_48 = "";
      if(ad_8 != 0.0)
         ls_40 = ", TakeProfit on " + DoubleToString(ad_8, 4);
      else
         ls_40 = "";
      if(ad_16 != 0.0)
         ls_32 = ", StopLoss on " + DoubleToString(ad_16, 4);
      else
         ls_32 = "";
      ls_56 = "BuySellWait " + as_0 + ls_48;
      ls_64 = "BuySellWait " + as_0 + ls_48 + ls_40 + ls_32 + " " + Symbol() + ", " + (string)Period() + " minutes chart";
      // if (Email) SendMail(ls_56, ls_64);
      if(notificationsOn)
        {
         if(desktop_notifications)
            Alert(ls_64);
         if(push_notifications)
            SendNotification(ls_64);
         if(email_notifications)
            SendMail(ls_56, ls_64);
         if(sound_notifications)
            PlaySound(sound_file);
        }
     }
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
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=149693#p149693

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