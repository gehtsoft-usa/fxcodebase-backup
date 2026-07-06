//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=153537#p153537

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

#property indicator_separate_window
#property indicator_buffers 21
#property indicator_plots 21

#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDarkGray
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrLime
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrRed
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrDarkGray
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrLime
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrRed
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrDarkGray
#property indicator_type10  DRAW_ARROW
#property indicator_color10 clrLime
#property indicator_type11  DRAW_ARROW
#property indicator_color11 clrRed
#property indicator_type12  DRAW_ARROW
#property indicator_color12 clrDarkGray
#property indicator_type13  DRAW_ARROW
#property indicator_color13 clrLime
#property indicator_type14  DRAW_ARROW
#property indicator_color14 clrRed
#property indicator_type15  DRAW_ARROW
#property indicator_color15 clrDarkGray
#property indicator_type16  DRAW_ARROW
#property indicator_color16 clrLime
#property indicator_type17  DRAW_ARROW
#property indicator_color17 clrRed
#property indicator_type18  DRAW_ARROW
#property indicator_color18 clrDarkGray
#property indicator_type19  DRAW_ARROW
#property indicator_color19 clrLime
#property indicator_type20  DRAW_ARROW
#property indicator_color20 clrRed
#property indicator_type21  DRAW_ARROW
#property indicator_color21 clrDarkGray

#property indicator_minimum 0
#property indicator_maximum 5

input int    Periods    = 10;
input int    BarLimit   = 200;
input string Comment0   = "<< Currency Pair: Leave Blank for Current >>";
input string Currency_Pair  = "EURUSD";

double w1_up[];
double w1_dn[];
double w1_nt[];
double d1_up[];
double d1_dn[];
double d1_nt[];
double h4_up[];
double h4_dn[];
double h4_nt[];
double h1_up[];
double h1_dn[];
double h1_nt[];
double m30_up[];
double m30_dn[];
double m30_nt[];
double m15_up[];
double m15_dn[];
double m15_nt[];
double m5_up[];
double m5_dn[];
double m5_nt[];

string IndName;
string IndicatorName;
string IndicatorObjPrefix;

int indicator_subwindow = -1;

double Hlv_W1 = 0;
double Hlv_D1 = 0;
double Hlv_H4 = 0;
double Hlv_H1 = 0;
double Hlv_M30 = 0;
double Hlv_M15 = 0;
double Hlv_M5 = 0;

int ma_handle_W1_H = INVALID_HANDLE;
int ma_handle_W1_L = INVALID_HANDLE;
int ma_handle_D1_H = INVALID_HANDLE;
int ma_handle_D1_L = INVALID_HANDLE;
int ma_handle_H4_H = INVALID_HANDLE;
int ma_handle_H4_L = INVALID_HANDLE;
int ma_handle_H1_H = INVALID_HANDLE;
int ma_handle_H1_L = INVALID_HANDLE;
int ma_handle_M30_H = INVALID_HANDLE;
int ma_handle_M30_L = INVALID_HANDLE;
int ma_handle_M15_H = INVALID_HANDLE;
int ma_handle_M15_L = INVALID_HANDLE;
int ma_handle_M5_H = INVALID_HANDLE;
int ma_handle_M5_L = INVALID_HANDLE;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenerateIndicatorName(const string target)
  {
   return target;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, w1_up, INDICATOR_DATA);
   SetIndexBuffer(1, w1_dn, INDICATOR_DATA);
   SetIndexBuffer(2, w1_nt, INDICATOR_DATA);
   SetIndexBuffer(3, d1_up, INDICATOR_DATA);
   SetIndexBuffer(4, d1_dn, INDICATOR_DATA);
   SetIndexBuffer(5, d1_nt, INDICATOR_DATA);
   SetIndexBuffer(6, h4_up, INDICATOR_DATA);
   SetIndexBuffer(7, h4_dn, INDICATOR_DATA);
   SetIndexBuffer(8, h4_nt, INDICATOR_DATA);
   SetIndexBuffer(9, h1_up, INDICATOR_DATA);
   SetIndexBuffer(10, h1_dn, INDICATOR_DATA);
   SetIndexBuffer(11, h1_nt, INDICATOR_DATA);
   SetIndexBuffer(12, m30_up, INDICATOR_DATA);
   SetIndexBuffer(13, m30_dn, INDICATOR_DATA);
   SetIndexBuffer(14, m30_nt, INDICATOR_DATA);
   SetIndexBuffer(15, m15_up, INDICATOR_DATA);
   SetIndexBuffer(16, m15_dn, INDICATOR_DATA);
   SetIndexBuffer(17, m15_nt, INDICATOR_DATA);
   SetIndexBuffer(18, m5_up, INDICATOR_DATA);
   SetIndexBuffer(19, m5_dn, INDICATOR_DATA);
   SetIndexBuffer(20, m5_nt, INDICATOR_DATA);
   ArraySetAsSeries(w1_up, true);
   ArraySetAsSeries(w1_dn, true);
   ArraySetAsSeries(w1_nt, true);
   ArraySetAsSeries(d1_up, true);
   ArraySetAsSeries(d1_dn, true);
   ArraySetAsSeries(d1_nt, true);
   ArraySetAsSeries(h4_up, true);
   ArraySetAsSeries(h4_dn, true);
   ArraySetAsSeries(h4_nt, true);
   ArraySetAsSeries(h1_up, true);
   ArraySetAsSeries(h1_dn, true);
   ArraySetAsSeries(h1_nt, true);
   ArraySetAsSeries(m30_up, true);
   ArraySetAsSeries(m30_dn, true);
   ArraySetAsSeries(m30_nt, true);
   ArraySetAsSeries(m15_up, true);
   ArraySetAsSeries(m15_dn, true);
   ArraySetAsSeries(m15_nt, true);
   ArraySetAsSeries(m5_up, true);
   ArraySetAsSeries(m5_dn, true);
   ArraySetAsSeries(m5_nt, true);
   ArrayInitialize(w1_up, EMPTY_VALUE);
   ArrayInitialize(w1_dn, EMPTY_VALUE);
   ArrayInitialize(w1_nt, EMPTY_VALUE);
   ArrayInitialize(d1_up, EMPTY_VALUE);
   ArrayInitialize(d1_dn, EMPTY_VALUE);
   ArrayInitialize(d1_nt, EMPTY_VALUE);
   ArrayInitialize(h4_up, EMPTY_VALUE);
   ArrayInitialize(h4_dn, EMPTY_VALUE);
   ArrayInitialize(h4_nt, EMPTY_VALUE);
   ArrayInitialize(h1_up, EMPTY_VALUE);
   ArrayInitialize(h1_dn, EMPTY_VALUE);
   ArrayInitialize(h1_nt, EMPTY_VALUE);
   ArrayInitialize(m30_up, EMPTY_VALUE);
   ArrayInitialize(m30_dn, EMPTY_VALUE);
   ArrayInitialize(m30_nt, EMPTY_VALUE);
   ArrayInitialize(m15_up, EMPTY_VALUE);
   ArrayInitialize(m15_dn, EMPTY_VALUE);
   ArrayInitialize(m15_nt, EMPTY_VALUE);
   ArrayInitialize(m5_up, EMPTY_VALUE);
   ArrayInitialize(m5_dn, EMPTY_VALUE);
   ArrayInitialize(m5_nt, EMPTY_VALUE);
   Hlv_W1 = 0;
   Hlv_D1 = 0;
   Hlv_H4 = 0;
   Hlv_H1 = 0;
   Hlv_M30 = 0;
   Hlv_M15 = 0;
   Hlv_M5 = 0;
   int arrow = 110;
   for(int i = 0; i < 21; i++)
     {
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(i, PLOT_ARROW, arrow);
      PlotIndexSetString(i, PLOT_LABEL, "");
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, EMPTY_VALUE);
     }
   IndName = "MTF_Gann_Hi_Lo_Activator_HeatMap";
   IndicatorName = IndName;
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   string Symbolo = (Currency_Pair != "") ? Currency_Pair : NULL;
   if(Period() < PERIOD_W1)
     {
      ma_handle_W1_H = iMA(Symbolo, PERIOD_W1, Periods, 0, MODE_SMA, PRICE_HIGH);
      ma_handle_W1_L = iMA(Symbolo, PERIOD_W1, Periods, 0, MODE_SMA, PRICE_LOW);
     }
   if(Period() < PERIOD_D1)
     {
      ma_handle_D1_H = iMA(Symbolo, PERIOD_D1, Periods, 0, MODE_SMA, PRICE_HIGH);
      ma_handle_D1_L = iMA(Symbolo, PERIOD_D1, Periods, 0, MODE_SMA, PRICE_LOW);
     }
   if(Period() < PERIOD_H4)
     {
      ma_handle_H4_H = iMA(Symbolo, PERIOD_H4, Periods, 0, MODE_SMA, PRICE_HIGH);
      ma_handle_H4_L = iMA(Symbolo, PERIOD_H4, Periods, 0, MODE_SMA, PRICE_LOW);
     }
   if(Period() < PERIOD_H1)
     {
      ma_handle_H1_H = iMA(Symbolo, PERIOD_H1, Periods, 0, MODE_SMA, PRICE_HIGH);
      ma_handle_H1_L = iMA(Symbolo, PERIOD_H1, Periods, 0, MODE_SMA, PRICE_LOW);
     }
   if(Period() < PERIOD_M30)
     {
      ma_handle_M30_H = iMA(Symbolo, PERIOD_M30, Periods, 0, MODE_SMA, PRICE_HIGH);
      ma_handle_M30_L = iMA(Symbolo, PERIOD_M30, Periods, 0, MODE_SMA, PRICE_LOW);
     }
   if(Period() < PERIOD_M15)
     {
      ma_handle_M15_H = iMA(Symbolo, PERIOD_M15, Periods, 0, MODE_SMA, PRICE_HIGH);
      ma_handle_M15_L = iMA(Symbolo, PERIOD_M15, Periods, 0, MODE_SMA, PRICE_LOW);
     }
   if(Period() < PERIOD_M5)
     {
      ma_handle_M5_H = iMA(Symbolo, PERIOD_M5, Periods, 0, MODE_SMA, PRICE_HIGH);
      ma_handle_M5_L = iMA(Symbolo, PERIOD_M5, Periods, 0, MODE_SMA, PRICE_LOW);
     }
   for(int k = 0; k < 21; k++)
     {
      double tmpArr[];
      ArrayResize(tmpArr, 1);
      ArraySetAsSeries(tmpArr, true);
      tmpArr[0] = EMPTY_VALUE;
     }
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   if(ma_handle_W1_H != INVALID_HANDLE)
      IndicatorRelease(ma_handle_W1_H);
   if(ma_handle_W1_L != INVALID_HANDLE)
      IndicatorRelease(ma_handle_W1_L);
   if(ma_handle_D1_H != INVALID_HANDLE)
      IndicatorRelease(ma_handle_D1_H);
   if(ma_handle_D1_L != INVALID_HANDLE)
      IndicatorRelease(ma_handle_D1_L);
   if(ma_handle_H4_H != INVALID_HANDLE)
      IndicatorRelease(ma_handle_H4_H);
   if(ma_handle_H4_L != INVALID_HANDLE)
      IndicatorRelease(ma_handle_H4_L);
   if(ma_handle_H1_H != INVALID_HANDLE)
      IndicatorRelease(ma_handle_H1_H);
   if(ma_handle_H1_L != INVALID_HANDLE)
      IndicatorRelease(ma_handle_H1_L);
   if(ma_handle_M30_H != INVALID_HANDLE)
      IndicatorRelease(ma_handle_M30_H);
   if(ma_handle_M30_L != INVALID_HANDLE)
      IndicatorRelease(ma_handle_M30_L);
   if(ma_handle_M15_H != INVALID_HANDLE)
      IndicatorRelease(ma_handle_M15_H);
   if(ma_handle_M15_L != INVALID_HANDLE)
      IndicatorRelease(ma_handle_M15_L);
   if(ma_handle_M5_H != INVALID_HANDLE)
      IndicatorRelease(ma_handle_M5_H);
   if(ma_handle_M5_L != INVALID_HANDLE)
      IndicatorRelease(ma_handle_M5_L);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Etiqueta(const string sName, const string sLabel, double dPrice, datetime tTime)
  {
   string obj = IndicatorObjPrefix + sName;
   long chart_id = ChartID();
   if(indicator_subwindow == -1)
     {
      indicator_subwindow = ChartWindowFind(chart_id, IndicatorName);
     }
   int sub_window = indicator_subwindow;
   if(ObjectFind(chart_id, obj) == -1)
     {
      ObjectCreate(chart_id, obj, OBJ_TEXT, sub_window, tTime, dPrice);
     }
   else
     {
      ObjectMove(chart_id, obj, 0, tTime, dPrice);
     }
   string txt = " " + sLabel;
   ObjectSetString(chart_id, obj, OBJPROP_TEXT, txt);
   ObjectSetInteger(chart_id, obj, OBJPROP_FONTSIZE, 8);
   ObjectSetString(chart_id, obj, OBJPROP_FONT, "Lucida Console");
   ObjectSetInteger(chart_id, obj, OBJPROP_COLOR, clrWhite);
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
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(time, true);
   int limit;
   limit = MathMin(rates_total - 1, BarLimit);
   int clear_start = rates_total - 1;
   for(int j = clear_start; j >= 0; j--)
     {
      w1_up[j] = EMPTY_VALUE;
      w1_dn[j] = EMPTY_VALUE;
      w1_nt[j] = EMPTY_VALUE;
      d1_up[j] = EMPTY_VALUE;
      d1_dn[j] = EMPTY_VALUE;
      d1_nt[j] = EMPTY_VALUE;
      h4_up[j] = EMPTY_VALUE;
      h4_dn[j] = EMPTY_VALUE;
      h4_nt[j] = EMPTY_VALUE;
      h1_up[j] = EMPTY_VALUE;
      h1_dn[j] = EMPTY_VALUE;
      h1_nt[j] = EMPTY_VALUE;
      m30_up[j] = EMPTY_VALUE;
      m30_dn[j] = EMPTY_VALUE;
      m30_nt[j] = EMPTY_VALUE;
      m15_up[j] = EMPTY_VALUE;
      m15_dn[j] = EMPTY_VALUE;
      m15_nt[j] = EMPTY_VALUE;
      m5_up[j] = EMPTY_VALUE;
      m5_dn[j] = EMPTY_VALUE;
      m5_nt[j] = EMPTY_VALUE;
     }
   if(ArraySize(w1_up) != rates_total)
     {
      ArrayResize(w1_up, rates_total);
      ArraySetAsSeries(w1_up, true);
      ArrayResize(w1_dn, rates_total);
      ArraySetAsSeries(w1_dn, true);
      ArrayResize(w1_nt, rates_total);
      ArraySetAsSeries(w1_nt, true);
      ArrayResize(d1_up, rates_total);
      ArraySetAsSeries(d1_up, true);
      ArrayResize(d1_dn, rates_total);
      ArraySetAsSeries(d1_dn, true);
      ArrayResize(d1_nt, rates_total);
      ArraySetAsSeries(d1_nt, true);
      ArrayResize(h4_up, rates_total);
      ArraySetAsSeries(h4_up, true);
      ArrayResize(h4_dn, rates_total);
      ArraySetAsSeries(h4_dn, true);
      ArrayResize(h4_nt, rates_total);
      ArraySetAsSeries(h4_nt, true);
      ArrayResize(h1_up, rates_total);
      ArraySetAsSeries(h1_up, true);
      ArrayResize(h1_dn, rates_total);
      ArraySetAsSeries(h1_dn, true);
      ArrayResize(h1_nt, rates_total);
      ArraySetAsSeries(h1_nt, true);
      ArrayResize(m30_up, rates_total);
      ArraySetAsSeries(m30_up, true);
      ArrayResize(m30_dn, rates_total);
      ArraySetAsSeries(m30_dn, true);
      ArrayResize(m30_nt, rates_total);
      ArraySetAsSeries(m30_nt, true);
      ArrayResize(m15_up, rates_total);
      ArraySetAsSeries(m15_up, true);
      ArrayResize(m15_dn, rates_total);
      ArraySetAsSeries(m15_dn, true);
      ArrayResize(m15_nt, rates_total);
      ArraySetAsSeries(m15_nt, true);
      ArrayResize(m5_up, rates_total);
      ArraySetAsSeries(m5_up, true);
      ArrayResize(m5_dn, rates_total);
      ArraySetAsSeries(m5_dn, true);
      ArrayResize(m5_nt, rates_total);
      ArraySetAsSeries(m5_nt, true);
      ArrayInitialize(w1_up, EMPTY_VALUE);
      ArrayInitialize(w1_dn, EMPTY_VALUE);
      ArrayInitialize(w1_nt, EMPTY_VALUE);
      ArrayInitialize(d1_up, EMPTY_VALUE);
      ArrayInitialize(d1_dn, EMPTY_VALUE);
      ArrayInitialize(d1_nt, EMPTY_VALUE);
      ArrayInitialize(h4_up, EMPTY_VALUE);
      ArrayInitialize(h4_dn, EMPTY_VALUE);
      ArrayInitialize(h4_nt, EMPTY_VALUE);
      ArrayInitialize(h1_up, EMPTY_VALUE);
      ArrayInitialize(h1_dn, EMPTY_VALUE);
      ArrayInitialize(h1_nt, EMPTY_VALUE);
      ArrayInitialize(m30_up, EMPTY_VALUE);
      ArrayInitialize(m30_dn, EMPTY_VALUE);
      ArrayInitialize(m30_nt, EMPTY_VALUE);
      ArrayInitialize(m15_up, EMPTY_VALUE);
      ArrayInitialize(m15_dn, EMPTY_VALUE);
      ArrayInitialize(m15_nt, EMPTY_VALUE);
      ArrayInitialize(m5_up, EMPTY_VALUE);
      ArrayInitialize(m5_dn, EMPTY_VALUE);
      ArrayInitialize(m5_nt, EMPTY_VALUE);
      Hlv_W1 = 0;
      Hlv_D1 = 0;
      Hlv_H4 = 0;
      Hlv_H1 = 0;
      Hlv_M30 = 0;
      Hlv_M15 = 0;
      Hlv_M5 = 0;
     }
   int i;
   ENUM_TIMEFRAMES period;
   double SMA_H, SMA_L, ssl, Hld = 0;
   string Symbolo = (Currency_Pair != "") ? Currency_Pair : NULL;
   double buf_h[], buf_l[];
   ArraySetAsSeries(buf_h, true);
   ArraySetAsSeries(buf_l, true);
   for(i = limit; i >= 0; i--)
     {
      if(Period() < PERIOD_W1 && ma_handle_W1_H != INVALID_HANDLE && ma_handle_W1_L != INVALID_HANDLE)
        {
         period = PERIOD_W1;
         int bars_needed = iBars(Symbolo, PERIOD_W1);
         if(bars_needed > 0 && CopyBuffer(ma_handle_W1_H, 0, 0, bars_needed, buf_h) > 0 && CopyBuffer(ma_handle_W1_L, 0, 0, bars_needed, buf_l) > 0)
           {
            int shift = iBarShift(Symbolo, PERIOD_W1, time[i], false);
            if(shift >= 0 && shift < bars_needed - 1)
              {
               SMA_H = buf_h[shift + 1];
               SMA_L = buf_l[shift + 1];
               double close_price = iClose(Symbolo, PERIOD_W1, shift);
               if(close_price > 0 && SMA_H > 0 && SMA_L > 0)
                 {
                  if(close_price > SMA_H)
                     Hlv_W1 = 1;
                  else
                     if(close_price < SMA_L)
                        Hlv_W1 = -1;
                  ssl = (Hlv_W1 == -1) ? SMA_H : SMA_L;
                  if(close[i] > ssl)
                    {
                     w1_up[i] = 1.0;
                    }
                  else
                    {
                     w1_dn[i] = 1.0;
                    }
                 }
              }
           }
        }
      if(Period() < PERIOD_D1 && ma_handle_D1_H != INVALID_HANDLE && ma_handle_D1_L != INVALID_HANDLE)
        {
         period = PERIOD_D1;
         int bars_needed = iBars(Symbolo, PERIOD_D1);
         if(bars_needed > 0 && CopyBuffer(ma_handle_D1_H, 0, 0, bars_needed, buf_h) > 0 && CopyBuffer(ma_handle_D1_L, 0, 0, bars_needed, buf_l) > 0)
           {
            int shift = iBarShift(Symbolo, PERIOD_D1, time[i], false);
            if(shift >= 0 && shift < bars_needed - 1)
              {
               SMA_H = buf_h[shift + 1];
               SMA_L = buf_l[shift + 1];
               double close_price = iClose(Symbolo, PERIOD_D1, shift);
               if(close_price > 0 && SMA_H > 0 && SMA_L > 0)
                 {
                  if(close_price > SMA_H)
                     Hlv_D1 = 1;
                  else
                     if(close_price < SMA_L)
                        Hlv_D1 = -1;
                  ssl = (Hlv_D1 == -1) ? SMA_H : SMA_L;
                  if(close[i] > ssl)
                    {
                     d1_up[i] = 1.5;
                    }
                  else
                    {
                     d1_dn[i] = 1.5;
                    }
                 }
              }
           }
        }
      if(Period() < PERIOD_H4 && ma_handle_H4_H != INVALID_HANDLE && ma_handle_H4_L != INVALID_HANDLE)
        {
         period = PERIOD_H4;
         int bars_needed = iBars(Symbolo, PERIOD_H4);
         if(bars_needed > 0 && CopyBuffer(ma_handle_H4_H, 0, 0, bars_needed, buf_h) > 0 && CopyBuffer(ma_handle_H4_L, 0, 0, bars_needed, buf_l) > 0)
           {
            int shift = iBarShift(Symbolo, PERIOD_H4, time[i], false);
            if(shift >= 0 && shift < bars_needed - 1)
              {
               SMA_H = buf_h[shift + 1];
               SMA_L = buf_l[shift + 1];
               double close_price = iClose(Symbolo, PERIOD_H4, shift);
               if(close_price > 0 && SMA_H > 0 && SMA_L > 0)
                 {
                  if(close_price > SMA_H)
                     Hlv_H4 = 1;
                  else
                     if(close_price < SMA_L)
                        Hlv_H4 = -1;
                  ssl = (Hlv_H4 == -1) ? SMA_H : SMA_L;
                  if(close[i] > ssl)
                    {
                     h4_up[i] = 2.0;
                    }
                  else
                    {
                     h4_dn[i] = 2.0;
                    }
                 }
              }
           }
        }
      if(Period() < PERIOD_H1 && ma_handle_H1_H != INVALID_HANDLE && ma_handle_H1_L != INVALID_HANDLE)
        {
         period = PERIOD_H1;
         int bars_needed = iBars(Symbolo, PERIOD_H1);
         if(bars_needed > 0 && CopyBuffer(ma_handle_H1_H, 0, 0, bars_needed, buf_h) > 0 && CopyBuffer(ma_handle_H1_L, 0, 0, bars_needed, buf_l) > 0)
           {
            int shift = iBarShift(Symbolo, PERIOD_H1, time[i], false);
            if(shift >= 0 && shift < bars_needed - 1)
              {
               SMA_H = buf_h[shift + 1];
               SMA_L = buf_l[shift + 1];
               double close_price = iClose(Symbolo, PERIOD_H1, shift);
               if(close_price > 0 && SMA_H > 0 && SMA_L > 0)
                 {
                  if(close_price > SMA_H)
                     Hlv_H1 = 1;
                  else
                     if(close_price < SMA_L)
                        Hlv_H1 = -1;
                  ssl = (Hlv_H1 == -1) ? SMA_H : SMA_L;
                  if(close[i] > ssl)
                    {
                     h1_up[i] = 2.5;
                    }
                  else
                    {
                     h1_dn[i] = 2.5;
                    }
                 }
              }
           }
        }
      if(Period() < PERIOD_M30 && ma_handle_M30_H != INVALID_HANDLE && ma_handle_M30_L != INVALID_HANDLE)
        {
         period = PERIOD_M30;
         int bars_needed = iBars(Symbolo, PERIOD_M30);
         if(bars_needed > 0 && CopyBuffer(ma_handle_M30_H, 0, 0, bars_needed, buf_h) > 0 && CopyBuffer(ma_handle_M30_L, 0, 0, bars_needed, buf_l) > 0)
           {
            int shift = iBarShift(Symbolo, PERIOD_M30, time[i], false);
            if(shift >= 0 && shift < bars_needed - 1)
              {
               SMA_H = buf_h[shift + 1];
               SMA_L = buf_l[shift + 1];
               double close_price = iClose(Symbolo, PERIOD_M30, shift);
               if(close_price > 0 && SMA_H > 0 && SMA_L > 0)
                 {
                  if(close_price > SMA_H)
                     Hlv_M30 = 1;
                  else
                     if(close_price < SMA_L)
                        Hlv_M30 = -1;
                  ssl = (Hlv_M30 == -1) ? SMA_H : SMA_L;
                  if(close[i] > ssl)
                    {
                     m30_up[i] = 3.0;
                    }
                  else
                    {
                     m30_dn[i] = 3.0;
                    }
                 }
              }
           }
        }
      if(Period() < PERIOD_M15 && ma_handle_M15_H != INVALID_HANDLE && ma_handle_M15_L != INVALID_HANDLE)
        {
         period = PERIOD_M15;
         int bars_needed = iBars(Symbolo, PERIOD_M15);
         if(bars_needed > 0 && CopyBuffer(ma_handle_M15_H, 0, 0, bars_needed, buf_h) > 0 && CopyBuffer(ma_handle_M15_L, 0, 0, bars_needed, buf_l) > 0)
           {
            int shift = iBarShift(Symbolo, PERIOD_M15, time[i], false);
            if(shift >= 0 && shift < bars_needed - 1)
              {
               SMA_H = buf_h[shift + 1];
               SMA_L = buf_l[shift + 1];
               double close_price = iClose(Symbolo, PERIOD_M15, shift);
               if(close_price > 0 && SMA_H > 0 && SMA_L > 0)
                 {
                  if(close_price > SMA_H)
                     Hlv_M15 = 1;
                  else
                     if(close_price < SMA_L)
                        Hlv_M15 = -1;
                  ssl = (Hlv_M15 == -1) ? SMA_H : SMA_L;
                  if(close[i] > ssl)
                    {
                     m15_up[i] = 3.5;
                    }
                  else
                    {
                     m15_dn[i] = 3.5;
                    }
                 }
              }
           }
        }
      if(Period() < PERIOD_M5 && ma_handle_M5_H != INVALID_HANDLE && ma_handle_M5_L != INVALID_HANDLE)
        {
         period = PERIOD_M5;
         int bars_needed = iBars(Symbolo, PERIOD_M5);
         if(bars_needed > 0 && CopyBuffer(ma_handle_M5_H, 0, 0, bars_needed, buf_h) > 0 && CopyBuffer(ma_handle_M5_L, 0, 0, bars_needed, buf_l) > 0)
           {
            int shift = iBarShift(Symbolo, PERIOD_M5, time[i], false);
            if(shift >= 0 && shift < bars_needed - 1)
              {
               SMA_H = buf_h[shift + 1];
               SMA_L = buf_l[shift + 1];
               double close_price = iClose(Symbolo, PERIOD_M5, shift);
               if(close_price > 0 && SMA_H > 0 && SMA_L > 0)
                 {
                  if(close_price > SMA_H)
                     Hlv_M5 = 1;
                  else
                     if(close_price < SMA_L)
                        Hlv_M5 = -1;
                  ssl = (Hlv_M5 == -1) ? SMA_H : SMA_L;
                  if(close[i] > ssl)
                    {
                     m5_up[i] = 4.0;
                    }
                  else
                    {
                     m5_dn[i] = 4.0;
                    }
                 }
              }
           }
        }
     }
   Etiqueta("HeatLbl_W1", " - W1 ", 1.0, time[0]);
   Etiqueta("HeatLbl_D1", " - D1 ", 1.5, time[0]);
   Etiqueta("HeatLbl_H4", " - H4 ", 2.0, time[0]);
   Etiqueta("HeatLbl_H1", " - H1 ", 2.5, time[0]);
   Etiqueta("HeatLbl_M30", " - M30 ", 3.0, time[0]);
   Etiqueta("HeatLbl_M15", " - M15 ", 3.5, time[0]);
   Etiqueta("HeatLbl_M5", " - M5 ", 4.0, time[0]);
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ChartSetSymbolPeriod(0, Symbol(), Period());
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Limpiar()
  {
  }
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=153537#p153537

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