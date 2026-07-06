// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&p=157297#p157297

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_plots   1
#property indicator_buffers 1

input int values_count = 2; // Values to summ
input int corrPeriod = 20;
input int      bars                     = 2; // Bars of max/min
input string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
input string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD";
bool     Include_M1               = true;
bool     Include_M5               = false;
bool     Include_M15              = false;
bool     Include_M30              = false;
bool     Include_H1               = false;
bool     Include_H4               = false;
bool     Include_D1               = false;
bool     Include_W1               = false;
bool     Include_MN1              = false;
input color    Labels_Color             = clrWhite;
input color    Confirmed_Up_Color       = clrGreen; // Confirmed up color
input color    Confirmed_Dn_Color       = clrRed; // Confirmed down color
input color    Neutral_Color            = clrDarkGray;
input int      x_shift                  = 100; // X coordinate
input int      y_shift                  = 50;  // Y coordinate

enum DisplayMode { Horizontal, Vertical };
input DisplayMode display_mode = Vertical; // Display mode
input int font_size = 10; // Font Size;
input int cell_width = 80; // Cell width
input int cell_height = 30; // Cell height

#define MAX_TIMEFRAMES 9
ENUM_TIMEFRAMES timeframes[MAX_TIMEFRAMES] =
  {
   PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30,
   PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1
  };
bool includes[MAX_TIMEFRAMES];
string shortName;
long chart_id = 0;
string fileName;
int iCustom_handle;
int sum[];
string pairList[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   includes[0] = Include_M1;
   includes[1] = Include_M5;
   includes[2] = Include_M15;
   includes[3] = Include_M30;
   includes[4] = Include_H1;
   includes[5] = Include_H4;
   includes[6] = Include_D1;
   includes[7] = Include_W1;
   includes[8] = Include_MN1;
//
   shortName = "Gannswing_Dashboard";
   IndicatorSetString(INDICATOR_SHORTNAME, shortName);
   chart_id = ChartID();
   EventSetTimer(1);
//
   StringSplit(Pairs, ',', pairList);
   ArrayResize(sum, ArraySize(pairList));
   ArrayInitialize(sum, 0);
   fileName = "CumulativeDelta";
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(chart_id, shortName);
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   DrawDashboard();
   return(rates_total);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(MQLInfoInteger(MQL_TESTER) == 0)
      DrawDashboard();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeframeStr(ENUM_TIMEFRAMES tf)
  {
   switch(tf)
     {
      case PERIOD_M1:
         return "Tick";
      case PERIOD_M5:
         return "M5";
      case PERIOD_M15:
         return "M15";
      case PERIOD_M30:
         return "M30";
      case PERIOD_H1:
         return "H1";
      case PERIOD_H4:
         return "H4";
      case PERIOD_D1:
         return "D1";
      case PERIOD_W1:
         return "W1";
      case PERIOD_MN1:
         return "MN1";
     }
   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawDashboard()
  {
   ObjectsDeleteAll(chart_id, shortName);
   int rows = 0;
   int col = 0;
   int shiftX = x_shift;
   int shiftY = y_shift;
   int tf_count = 0;
   for(int i = 0; i < MAX_TIMEFRAMES; i++)
     {
      if(!includes[i])
         continue;
      tf_count++;
     }
//
   if(display_mode == Vertical)
     {
      rows = ArraySize(pairList);
      col = 0;
      for(int j = 0; j < rows; j++)
        {
         string sym = pairList[j];
         DrawLabel(shortName + "_label_row_" + sym, sym, shiftX - cell_width, shiftY + cell_height * j, Labels_Color);
        }
      for(int i = 0; i < MAX_TIMEFRAMES; i++)
        {
         if(!includes[i])
            continue;
         string tf = GetTimeframeStr(timeframes[i]);
         DrawLabel(shortName + "_label_" + tf, GetTimeframeStr(timeframes[i]), shiftX + cell_width * col, shiftY - cell_height, Labels_Color);
         col++;
        }
     }
   else
     {
      rows = 0;
      col = ArraySize(pairList);
      for(int j = 0; j < col; j++)
        {
         string sym = pairList[j];
         DrawLabel(shortName + "_label_row_" + sym, sym, shiftX + cell_width * j, shiftY - cell_height, Labels_Color);
        }
      for(int i = 0; i < MAX_TIMEFRAMES; i++)
        {
         if(!includes[i])
            continue;
         string tf = GetTimeframeStr(timeframes[i]);
         DrawLabel(shortName + "_label_row_" + tf, GetTimeframeStr(timeframes[i]), shiftX - cell_width, shiftY + cell_height * rows, Labels_Color);
         rows++;
        }
     }
   if(display_mode == Horizontal)
     {
      int tf_index = 0;
      for(int i = 0; i < MAX_TIMEFRAMES; i++)
        {
         if(!includes[i])
            continue;
         string tf = EnumToString(timeframes[i]);
         for(int j = 0; j < ArraySize(pairList); j++)
           {
            string sym = pairList[j];
            iCustom_handle = iCustom(sym, timeframes[i], fileName, true, 0, 0, true, corrPeriod);
            sum[j] += custom_indi_calc(0, i);
            string label = (string)sum[j];
            color clr = (sum[j] > 0) ? Confirmed_Up_Color : (sum[j] < 0) ? Confirmed_Dn_Color : Neutral_Color;
            string name = shortName + "_h_" + tf + "_" + sym;
            int x = shiftX + cell_width * j;
            int y = shiftY + cell_height * tf_index;
            DrawLabel(name, label, x, y, clr);
           }
         tf_index++;
        }
     }
   else
     {
      int row = 0;
      for(int j = 0; j < rows; j++)
        {
         string sym = pairList[j];
         int col = 0;
         for(int i = 0; i < MAX_TIMEFRAMES; i++)
           {
            if(!includes[i])
               continue;
            string tf = EnumToString(timeframes[i]);
            for(int j = 0; j < ArraySize(pairList); j++)
              {
               string sym = pairList[j];
              }
            iCustom_handle = iCustom(sym, timeframes[i], fileName, true, 0, 0, true, corrPeriod);
            sum[j] += custom_indi_calc(0, i);
            string label = (string)sum[j];
            color clr = (sum[j] > 0) ? Confirmed_Up_Color : (sum[j] < 0) ? Confirmed_Dn_Color : Neutral_Color;
            string name = shortName + "_h_" + tf + "_" + sym;
            int x = shiftX + cell_width * col;
            int y = shiftY + cell_height * row;
            DrawLabel(name, label, x, y, clr);
            col++;
           }
         row++;
        }
     }
   ChartRedraw(chart_id);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int custom_indi_calc(int buffer, int shift)
  {
   double value[1];
   int copy = CopyBuffer(iCustom_handle, buffer, shift, 1, value);
   if(copy > 0)
     {
      return (int)value[0];
     }
   return -1;
  }

static string oldState = "";
static string state;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLabel(string name, string text, int x, int y, color clr)
  {
   int subwindow = ChartWindowFind(chart_id, shortName);
   ObjectDelete(chart_id, name);
   ObjectCreate(chart_id, name, OBJ_LABEL, subwindow, 0, 0);
   ObjectSetInteger(chart_id, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(chart_id, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_id, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(chart_id, name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger(chart_id, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(chart_id, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chart_id, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(chart_id, name, OBJPROP_BACK, true);
   ObjectSetString(chart_id, name, OBJPROP_TEXT, text);
  }
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&p=157297#p157297

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 