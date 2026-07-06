// More information about this indicator can be found at:
// http://fxcodebase.com/ 

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
//
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 4
//
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_level1 0

#property indicator_maximum 3
#property indicator_minimum -3

double ExtBuffer0[], ExtBuffer1[], value0[], Value1[];

input int period = 9;
input bool draw_arrows = true; // Draw arrows
input int arrow_shift = 25;
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
input int nbars = 300;
input int mtf_maxbars = 1000;
input bool   alertsOn                = false;
input bool   alertsMessage           = false;
input bool   alertsSound             = false;
input bool   alertsNotify            = false;
input bool   alertsEmail             = false;
input string soundFile               = "alert.wav";

input int shift = 1; // Shift

string gral_name = "gral_";
string s_symbol, s_id, s_gral;

int iHandle;

double arrow_up[];
double arrow_down[];

bool flag_last_trend, flag_arr_up, flag_arr_dn, flag_start_max_search;
double last_trend, max_value;
int k;

datetime time_alert_buy, time_alert_sell;
int whichBar = 0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   deleteArrows();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ExtBuffer0, INDICATOR_DATA);
   ArraySetAsSeries(ExtBuffer0, true);
   SetIndexBuffer(1, ExtBuffer1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(2, value0, INDICATOR_CALCULATIONS);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0);
   SetIndexBuffer(3, Value1, INDICATOR_CALCULATIONS);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0);
//
   s_symbol = Symbol();
   s_id = s_symbol + " " + fTimeFrameName(0);
   s_gral = gral_name + s_id;
   IndicatorSetString(INDICATOR_SHORTNAME, "GRAALUn");
   time_alert_buy = 0;
   time_alert_sell = 0;
   if(tf != PERIOD_CURRENT)
      iHandle = iCustom(_Symbol, tf, "GRAALUn_Ar.ex5", period, false);
   return(INIT_SUCCEEDED);
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
   double Value2 = 0;
   double price;
   double MinL = 0;
   double MaxH = 0;
   int minBars = 1;
   int limit;
   if(prev_calculated > rates_total || prev_calculated <= 0)
     {
      deleteArrows();
      limit = MathMin(rates_total - 4, TerminalInfoInteger(TERMINAL_MAXBARS) - 10);
      ArrayInitialize(ExtBuffer0, 0);
      ArrayInitialize(ExtBuffer1, 0);
     }
   else
     {
      limit = rates_total - prev_calculated;
      limit++;
     }
   if(tf != Period())
      limit = MathMin(mtf_maxbars, rates_total);
   for(int i = limit; i >= 0 && !IsStopped(); --i)
     {
      if(tf == PERIOD_CURRENT || tf == _Period)
        {
         MaxH = iHigh(_Symbol, tf, iHighest(Symbol(), tf, MODE_HIGH, period, i));
         MinL = iLow(_Symbol, tf, iLowest(Symbol(), tf, MODE_LOW, period, i));
         price = (iHigh(_Symbol, tf, i) + iLow(_Symbol, tf, i)) / 2;
         if(MaxH - MinL == 0)
            value0[i] = 0.33 * 2 * (0 - 0.5) + 0.67 * value0[i + 1];
         else
            value0[i] = 0.33 * 2 * ((price - MaxH) / (MinL - MaxH) - 0.5) + 0.67 * value0[i + 1];
         if(1 - value0[i] == 0)
            ExtBuffer0[i] = 0.5 + 0.5 * ExtBuffer0[i + 1];
         else
            ExtBuffer0[i] = -0.5 * MathLog((1 + value0[i]) / (1 - value0[i])) + 0.5 * ExtBuffer0[i + 1];
         if(MaxH - MinL == 0)
            Value1[i] = 0.33 * 2 * (0 - 0.5) + 0.67 * Value1[i + 1];
         else
            Value1[i] = 0.33 * 2 * ((price - MaxH) / (MinL - MaxH) - 0.5) + 0.67 * Value1[i + 1];
         if(1 - Value1[i] == 0)
            ExtBuffer1[i] = 0.5 + 0.5 * ExtBuffer1[i + 1];
         else
            ExtBuffer1[i] = -0.5 * MathLog((1 - Value1[i]) / (1 + Value1[i])) + 0.5 * ExtBuffer1[i + 1];
        }
      else
        {
         int index = iBarShift2(Symbol(), tf, iTime(Symbol(), Period(), i));
         if(index < 0)
           {
            continue;
           }
         double buff0[1], buff1[1];
         if(CopyBuffer(iHandle, 0, index, 1, buff0) > 0 && i >= 0 && ArraySize(ExtBuffer0) > i)
            ExtBuffer0[i] = buff0[0];
         if(CopyBuffer(iHandle, 1, index, 1, buff1) > 0 && i >= 0 && ArraySize(ExtBuffer1) > i)
            ExtBuffer1[i] = buff1[0];
        }
     }
   flag_last_trend = false;
   k = 0;
   flag_start_max_search = false;
   last_trend = 0;
   max_value = 0;
   for(int i = shift; i < nbars; i++)
     {
      flag_arr_up = false;
      flag_arr_dn = false;
      if(ExtBuffer0[i] < 0 && ExtBuffer0[i + 1] >= 0)
        {
         if(draw_arrows)
           {
            create_arrow(s_gral + (string)iTime(Symbol(), Period(), i), iHigh(Symbol(), Period(), i) + arrow_shift * _Point, iTime(Symbol(), Period(), i), 242, 2, clrRed, ANCHOR_BOTTOM);
           }
         if(!flag_last_trend)
           {
            k = i;
            flag_start_max_search = true;
            last_trend = -1;
            max_value = ExtBuffer1[i];
           }
         flag_last_trend = true;
         flag_arr_dn = true;
        }
      if(ExtBuffer0[i] > 0 && ExtBuffer0[i + 1] <= 0)
        {
         if(draw_arrows)
           {
            create_arrow(s_gral + (string)iTime(Symbol(), Period(), i), iLow(Symbol(), Period(), i) - arrow_shift * _Point, iTime(Symbol(), Period(), i), 241, 2, clrWhite, ANCHOR_TOP);
           }
         if(!flag_last_trend)
           {
            k = i;
            flag_start_max_search = true;
            last_trend = 1;
            max_value = ExtBuffer1[i];
           }
         flag_last_trend = true;
         flag_arr_up = true;
        }
      if(flag_start_max_search && i > k)
        {
         if(last_trend < 0)
           {
            if(flag_arr_up)
               flag_start_max_search = false;
            else
               if(ExtBuffer0[i] >= max_value)
                  max_value = ExtBuffer0[i];
           }
         if(last_trend > 0)
           {
            if(flag_arr_dn)
               flag_start_max_search = false;
            else
               if(ExtBuffer0[i] <= max_value)
                  max_value = ExtBuffer0[i];
           }
        }
     }
   int i = shift;
   if(alertsOn)
     {
      if((ExtBuffer1[i] > 0 && ExtBuffer1[i + 1] <= 0) && (time_alert_sell != iTime(Symbol(), Period(), 0)))
        {
         doAlert(whichBar, "SELL");
         time_alert_sell = iTime(Symbol(), Period(), 0);
        }
      if((ExtBuffer1[i] < 0 && ExtBuffer1[i + 1] >= 0) && (time_alert_buy != iTime(Symbol(), Period(), 0)))
        {
         doAlert(whichBar, "BUY");
         time_alert_buy = iTime(Symbol(), Period(), 0);
        }
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_arrow(string name, double price, datetime time, int arrow_code, int width, color _color, ENUM_ARROW_ANCHOR _anchor)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_ARROW, 0, 0, 0);
     }
   ObjectSetDouble(0, name, OBJPROP_PRICE, price);
   ObjectSetInteger(0, name, OBJPROP_TIME, time);
   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, arrow_code);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_COLOR, _color);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, _anchor);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deleteArrows()
  {
   ObjectsDeleteAll(0, gral_name);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string fTimeFrameName(int arg)
  {
   if(arg == 0)
     {
      arg = Period();
     }
   switch(arg)
     {
      case 0:
         return("0");
      case 1:
         return("M1");
      case 2:
         return("M2");
      case 5:
         return("M5");
      case 15:
         return("M15");
      case 30:
         return("M30");
      case 60:
         return("H1");
      case 240:
         return("H4");
      case 1440:
         return("D1");
      case 10080:
         return("W1");
      case 43200:
         return("MN1");
      default:
         return("M" + IntegerToString(arg));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(int forBar, string doWhat)
  {
   static string   previousAlert = "nothing";
   static datetime previousTime;
   string message;
   if(previousAlert != doWhat || previousTime != iTime(Symbol(), Period(), forBar))
     {
      previousAlert  = doWhat;
      previousTime   = iTime(Symbol(), Period(), forBar);
      string eName = "GRAALUn_Ar";
      message =  eName + " " + s_id + " " + doWhat;
      if(alertsMessage)
         Alert(message);
      if(alertsNotify)
         SendNotification(message);
      if(alertsEmail)
         SendMail(Symbol() + " " + fTimeFrameName(Period()) + " " + eName, message);
      if(alertsSound)
         PlaySound(soundFile);
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int iBarShift2(string symbol, int TF, datetime time, bool exact = false)
  {
   if(time < 0)
      return(-1);
   ENUM_TIMEFRAMES timeframe = TFMigrate(TF);
   datetime Arr[], time1;
   ArraySetAsSeries(Arr, true);
   if(CopyTime(symbol, timeframe, 0, 1, Arr) > 0)
      time1 = Arr[0];
   if(CopyTime(symbol, timeframe, time, time1, Arr) > 0)
     {
      if(ArraySize(Arr) > 2)
         return(ArraySize(Arr) - 1);
      if(time < time1)
         return(1);
      else
         return(0);
     }
   else
      return(-1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TFMigrate(int TF)
  {
   switch(TF)
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

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

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
