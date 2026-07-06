// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=155861#p155861

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  |
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

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 |
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 14
#property indicator_plots   11
//
input int   periods     = 55;
input color Val_1_Color = clrOrchid;
input color Val_2_Color = clrDarkOrange;
input color Val_3_Color = clrChartreuse;
input color Val_4_Color = clrSteelBlue;
input color Val_5_Color = clrChartreuse;
input color Val_6_Color = clrDarkOrange;
input color Val_7_Color = clrOrchid;

input color clrLower  = PaleGreen;  // Lower Zone Color:
input color clrMedium = Gray;       // Medium Zone Color:
input color clrHigher = Tomato;     // Higher Zone Color:

input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                 // Arrow Down Color:
//
double line0[];
double line1[];
double line2[];
double line4[];
double line5[];
double line6[];
double ZoneLower1[], ZoneLower2[];
double ZoneCentral1[], ZoneCentral2[];
double ZoneHigher1[], ZoneHigher2[];

double dif;

double ArrowUp[];
double ArrowDn[];

string short_name;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ZoneLower1, INDICATOR_DATA);
   SetIndexBuffer(1, ZoneLower2, INDICATOR_DATA);
   SetIndexBuffer(2, line0, INDICATOR_DATA);
   SetIndexBuffer(3, line1, INDICATOR_DATA);
   SetIndexBuffer(4, ZoneCentral1, INDICATOR_DATA);
   SetIndexBuffer(5, ZoneCentral2, INDICATOR_DATA);
   SetIndexBuffer(6, line2, INDICATOR_DATA);
   SetIndexBuffer(7, line4, INDICATOR_DATA);
   SetIndexBuffer(8, line5, INDICATOR_DATA);
   SetIndexBuffer(9, line6, INDICATOR_DATA);
   SetIndexBuffer(10, ZoneHigher1, INDICATOR_DATA);
   SetIndexBuffer(11, ZoneHigher2, INDICATOR_DATA);
   SetIndexBuffer(12, ArrowUp, INDICATOR_DATA);
   SetIndexBuffer(13, ArrowDn, INDICATOR_DATA);
//
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM2);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrLower);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, Val_1_Color);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, Val_2_Color);
//
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_HISTOGRAM2);
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, clrMedium);
   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, Val_3_Color);
   PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, Val_4_Color);
   PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(6, PLOT_LINE_COLOR, Val_5_Color);
   PlotIndexSetInteger(7, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(7, PLOT_LINE_COLOR, Val_6_Color);
//
   PlotIndexSetInteger(8, PLOT_DRAW_TYPE, DRAW_HISTOGRAM2);
   PlotIndexSetInteger(8, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(8, PLOT_LINE_COLOR, clrHigher);
//
   PlotIndexSetInteger(9, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(9, PLOT_ARROW, 116);
   PlotIndexSetInteger(9, PLOT_LINE_COLOR, ArrowUpClr);
   PlotIndexSetInteger(10, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(10, PLOT_ARROW, 116);
   PlotIndexSetInteger(10, PLOT_LINE_COLOR, ArrowDnClr);
   if(!ArrowsOn)
     {
      PlotIndexSetInteger(11, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(12, PLOT_DRAW_TYPE, DRAW_NONE);
     }
//
   short_name = "DFT";
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
//
   ArraySetAsSeries(ZoneLower1, true);
   ArraySetAsSeries(ZoneLower2, true);
   ArraySetAsSeries(line0, true);
   ArraySetAsSeries(line1, true);
   ArraySetAsSeries(ZoneCentral1, true);
   ArraySetAsSeries(ZoneCentral2, true);
   ArraySetAsSeries(line2, true);
   ArraySetAsSeries(line4, true);
   ArraySetAsSeries(line5, true);
   ArraySetAsSeries(line6, true);
   ArraySetAsSeries(ZoneHigher1, true);
   ArraySetAsSeries(ZoneHigher2, true);
   ArraySetAsSeries(ArrowUp, true);
   ArraySetAsSeries(ArrowDn, true);
//
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(6, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(7, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(8, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(9, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(10, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(11, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(12, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(13, PLOT_EMPTY_VALUE, EMPTY_VALUE);
//
   PlotIndexSetString(0, PLOT_LABEL, "lower Zone");
   PlotIndexSetString(1, PLOT_LABEL, "Fibo 0.000");
   PlotIndexSetString(2, PLOT_LABEL, "Fibo 0.236");
   PlotIndexSetString(3, PLOT_LABEL, "medium Zone");
   PlotIndexSetString(4, PLOT_LABEL, "Fibo 0.382");
   PlotIndexSetString(5, PLOT_LABEL, "Fibo 0.618");
   PlotIndexSetString(6, PLOT_LABEL, "Fibo 0.764");
   PlotIndexSetString(7, PLOT_LABEL, "Fibo 1.00");
   PlotIndexSetString(8, PLOT_LABEL, "higher Zone");
   PlotIndexSetString(9, PLOT_LABEL, "Arrow up");
   PlotIndexSetString(10, PLOT_LABEL, "Arrow down");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int c = 0;
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
   int limit = rates_total;
   if(prev_calculated > 0)
      limit = rates_total - prev_calculated;
   if(limit >= rates_total - 2)
      limit = rates_total - 3;
//
   for(int i = limit; i >= 0; i--)
     {
      line0[i] = EMPTY_VALUE;
      line1[i] = EMPTY_VALUE;
      line2[i] = EMPTY_VALUE;
      line4[i] = EMPTY_VALUE;
      line5[i] = EMPTY_VALUE;
      line6[i] = EMPTY_VALUE;
      //---
      ZoneLower1[i] = EMPTY_VALUE;
      ZoneLower2[i] = EMPTY_VALUE;
      ZoneCentral1[i] = EMPTY_VALUE;
      ZoneCentral2[i] = EMPTY_VALUE;
      ZoneHigher1[i] = EMPTY_VALUE;
      ZoneHigher2[i] = EMPTY_VALUE;
      ArrowUp[i] = EMPTY_VALUE;
      ArrowDn[i] = EMPTY_VALUE;
      //---
      line6[i] = iHigh(Symbol(), Period(), iHighest(Symbol(), Period(), MODE_HIGH, periods, i));
      line0[i] = iLow(Symbol(), Period(), iLowest(Symbol(), Period(), MODE_LOW, periods, i));
      //---
      dif      = line6[i] - line0[i];
      line1[i] = line0[i] + dif * 0.236;
      line2[i] = line0[i] + dif * 0.382;
      line4[i] = line0[i] + dif * 0.618;
      line5[i] = line0[i] + dif * 0.764;
      //---
      ZoneLower1[i]   = line1[i];
      ZoneLower2[i]   = line0[i];
      ZoneCentral1[i] = line1[i];
      ZoneCentral2[i] = line5[i];
      ZoneHigher1[i]  = line6[i];
      ZoneHigher2[i]  = line5[i];
      //---
      bool nb = IsNewBar();
      if(haveSignalUp(i))
        {
         ArrowUp[i + 1] = iLow(Symbol(), Period(), i + 1);
         if(nb)
            Notifications(0);
        }
      if(haveSignalDown(i))
        {
         ArrowDn[i + 1] = iHigh(Symbol(), Period(), i + 1);
         if(nb)
            Notifications(1);
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
bool haveSignalUp(int i)
  {
   double low = iLow(NULL, 0, i + 1);
   if(low <= line0[i + 1])
     {
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool haveSignalDown(int i)
  {
   double high = iHigh(NULL, 0, i + 1);
   if(high >= line6[i + 1])
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
     {
      lastbar = curbar;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
void Notifications(int type)
  {
   string text = "";
   if(type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
   else
      text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";
   text += " ";
   if(!notifications)
      return;
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
     }
   return IntegerToString(lPeriod);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 