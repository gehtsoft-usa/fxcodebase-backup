// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=63985

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#define INDICATOR_NAME "SM_BTF"

enum e_cycles
  {
   Min_5 = 1,
   Min_15 = 2,
   Min_30 = 3,
   Min_60 = 4,
   Min_240 = 5,
   Daily = 6,
   Weekly = 7,
   Monthly = 8,
   Quoter = 9,
   Year = 10
  };
enum e_method
  {
   Current = 1,
   Previous = 2
  };

input e_cycles BTF = Daily;
input e_method Method = Previous;
input int Number_Of_BTF_Candles = 3;
input bool Show_Labels = true;
input bool Draw_Cycles_Separator = true;
input color Open_Color = clrDarkGray;
input color High_Color = clrLime;
input color Low_Color = clrRed;
input color Close_Color = clrBlue;
input color HLC3_Color = clrBlue; // (H + L + C) / 3 color
///////////////////////////////////////////////////////////////////
input color HIGH11Color = clrLime; // (H + L) / 2 color
input color HIGH12Color = clrLime;

input color HALF00Color = clrMagenta;

input color LOW11Color = clrRed;
input color LOW12Color = clrRed;
//////////////////////////////////////////////////////////////////

input int Lines_Style = 0;
input int Lines_Width = 2;
input color BTF_Separator = clrDimGray;
//
extern string             button_note1          = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_LOWER;    // btn_corner
extern string             btn_text              = "Show/Hide";
extern string             btn_Font              = "Impact";
extern int                btn_FontSize          = 8;                    //btn_font size
extern color              btn_text_ON_color     = clrWhite;
extern color              btn_text_OFF_color    = clrWhite;
extern color              btn_background_color  = C'41,50,56';
extern color              btn_border_color      = C'41,50,56';
extern int                button_x              = 104;                  //btn__x
extern int                button_y              = 20;                   //btn__y
extern int                btn_Width             = 80;                   //btn__width
extern int                btn_Height            = 20;                   //btn__height
extern string             UniquebuttonId        = "KAF";
extern int                btn_Subwindow         = 0;
extern string             button_note2          = "------------------------------";
//
int Periodo, Minutes;

string IndicatorName;
string IndicatorObjPrefix;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenerateIndicatorName(const string target)
  {
   string name = target;
   int try
         = 2;
   while(WindowFind(name) != -1)
     {
      name = target + " #" + IntegerToString(try
                                                ++);
     }
   return name;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string buttonId;
bool recalc = true;
bool show_data = true;
int init()
  {
   IndicatorName = GenerateIndicatorName("Bigger TF Source");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
    if(IsInvalidTimeframe())
      Alert("The Bigger TF Source selected for this Time Frame cannot be calculated");
      
      double val;
   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, 1);
   IndicatorShortName(INDICATOR_NAME);
   buttonId = INDICATOR_NAME + UniquebuttonId;
   if(GlobalVariableGet(buttonId + "_visibility", val))
      show_data = val != 0;
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_XDISTANCE, button_x);
   return (0);
  }
void createButton(string buttonID, string buttonText, int width, int height, string font, int fontSize, color bgColor, color borderColor, color txtColor)
  {
   ObjectDelete(ChartID(), buttonID);
   ObjectCreate(ChartID(), buttonID, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_COLOR, txtColor);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_BORDER_COLOR, borderColor);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_XSIZE, width);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_YSIZE, height);
   ObjectSetString(ChartID(), buttonID, OBJPROP_FONT, font);
   ObjectSetString(ChartID(), buttonID, OBJPROP_TEXT, buttonText);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_SELECTABLE, 0);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_CORNER, btn_corner);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_HIDDEN, 1);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_XDISTANCE, 9999);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_YDISTANCE, 9999);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleButtonClicks()
  {
   if(ObjectGetInteger(ChartID(), buttonId, OBJPROP_STATE))
     {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(buttonId + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
      start();
     }
  }
//+------------------------------------------------------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything here
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   handleButtonClicks();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   handleButtonClicks();
   recalc = false;
   start2();
   if(show_data)
     {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_COLOR, btn_text_ON_color);
      
     }
   else
     {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_COLOR, btn_text_OFF_color);
      
      deinit();
     }
   return(0);
  }
  
  int start2()
  {
   int i;
   double OPEN, HIGH, LOW, CLOSE, HALF00, HIGH11, HIGH12, LOW11, LOW12; ///////////////////////////
   datetime Line_Start, Line_End;
   bool Draw_Label;
   if(IsInvalidTimeframe())
      return 0;
   int start = Number_Of_BTF_Candles;
   int periods = 1;
   switch(BTF)
     {
      case 1:
         Periodo = PERIOD_M5;
         Minutes = 5;
         break;
      case 2:
         Periodo = PERIOD_M15;
         Minutes = 15;
         break;
      case 3:
         Periodo = PERIOD_M30;
         Minutes = 30;
         break;
      case 4:
         Periodo = PERIOD_H1;
         Minutes = 60;
         break;
      case 5:
         Periodo = PERIOD_H4;
         Minutes = 240;
         break;
      case 6:
         Periodo = PERIOD_D1;
         Minutes = 1440;
         break;
      case 7:
         Periodo = PERIOD_W1;
         Minutes = 10080;
         break;
      case 8:
         Periodo = PERIOD_MN1;
         Minutes = 43200;
         break;
      case Quoter:
        {
         Periodo = PERIOD_MN1;
         periods = 3;
         Minutes = 43200;
         while(start < iBars(NULL, PERIOD_MN1) - 1)
           {
            MqlDateTime time;
            if(!TimeToStruct(iTime(NULL, PERIOD_MN1, start), time) || time.mon == 1)
               break;
            ++start;
           }
         start -= 3;
        }
      break;
      case Year:
        {
         Periodo = PERIOD_MN1;
         periods = 12;
         Minutes = 43200;
         while(start < iBars(NULL, PERIOD_MN1) - 1)
           {
            MqlDateTime time;
            if(!TimeToStruct(iTime(NULL, PERIOD_MN1, start), time) || time.mon == 1)
               break;
            ++start;
           }
         start -= 12;
        }
      break;
     }
   int shift = Method == Current ? 0 : periods;
   for(i = start; i >= 0; i -= periods)
     {
      OPEN = iOpen(NULL, Periodo, i + shift);
      CLOSE = iClose(NULL, Periodo, i + shift - 2);
      HIGH = iHigh(NULL, Periodo, i + shift);
      LOW = iLow(NULL, Periodo, i + shift);
      double range = iHigh(NULL, Periodo, i + shift) - iLow(NULL, Periodo, i + shift); ///////////////////////////
      HIGH11 = HIGH + range * 0.5; ///////////////////////////
      HIGH12 = HIGH + range * 1;   ///////////////////////////
      HALF00 = HIGH - range * 0.5; ///////////////////////////
      LOW11 = LOW - range * 0.5;   ///////////////////////////
      LOW12 = LOW - range * 1;     ///////////////////////////
      for(int ii = 1; ii < periods; ++ii)
        {
         HIGH = MathMax(HIGH, iHigh(NULL, Periodo, i + shift - ii));
         LOW = MathMin(LOW, iLow(NULL, Periodo, i + shift - ii));
        }
      Line_Start = iTime(NULL, Periodo, i);
      if(i < periods)
        {
         Line_End = iTime(NULL, Periodo, MathMax(0, i - periods + 1)) + (1 * (Minutes * 60));
         Draw_Label = true;
        }
      else
        {
         Line_End = iTime(NULL, Periodo, MathMax(0, i - periods));
         Draw_Label = false;
        }
      Pivot("OPEN" + i, Line_Start, OPEN, Line_End, Open_Color, 3, STYLE_SOLID, Draw_Label);
      Pivot("HIGH" + i, Line_Start, HIGH, Line_End, High_Color, 2, STYLE_SOLID, Draw_Label);
      Pivot("LOW" + i, Line_Start, LOW, Line_End, Low_Color, 2, STYLE_SOLID, Draw_Label);
      Pivot("CLOSE" + i, Line_Start, CLOSE, Line_End, Close_Color, 2, STYLE_SOLID, Draw_Label);
      Pivot("HLC3" + i, Line_Start, (HIGH + LOW + CLOSE) / 3, Line_End, HLC3_Color, 2, STYLE_SOLID, Draw_Label);
      Pivot("HIGH11" + i, Line_Start, HIGH11, Line_End, HIGH11Color, 1, STYLE_DOT, Draw_Label);   ///////////////////////////
      Pivot("HIGH12" + i, Line_Start, HIGH12, Line_End, HIGH12Color, 1, STYLE_SOLID, Draw_Label); ///////////////////////////
      Pivot("HALF00" + i, Line_Start, HALF00, Line_End, HALF00Color, 2, STYLE_SOLID, Draw_Label); ///////////////////////////
      Pivot("LOW11" + i, Line_Start, LOW11, Line_End, LOW11Color, 1, STYLE_DOT, Draw_Label);      ///////////////////////////
      Pivot("LOW12" + i, Line_Start, LOW12, Line_End, LOW11Color, 1, STYLE_SOLID, Draw_Label);    ///////////////////////////
      if(Draw_Cycles_Separator)
         Separator("Sep" + i, Line_Start, BTF_Separator, 0, STYLE_DOT);
     }
   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Pivot(string Nombre, datetime tiempo1, double precio1, datetime tiempo2, color bpcolor, int ancho, int style, bool draw_text)
  {
   ObjectDelete(IndicatorObjPrefix + Nombre);
   ObjectCreate(IndicatorObjPrefix + Nombre, OBJ_TREND, 0, tiempo1, precio1, tiempo2, precio1);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_COLOR, bpcolor);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_STYLE, style);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_WIDTH, ancho);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_RAY, False);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_BACK, true);
   if(Show_Labels && draw_text)
     {
      ObjectDelete(IndicatorObjPrefix + "T" + Nombre);
      ObjectCreate(IndicatorObjPrefix + "T" + Nombre, OBJ_TEXT, 0, tiempo2 + (2 * Period() * 60), precio1);
      ObjectSetText(IndicatorObjPrefix + "T" + Nombre, StringSubstr(Nombre, 0, StringLen(Nombre) - 1), 10, "Arial", bpcolor);
      ObjectSet(IndicatorObjPrefix + "T" + Nombre, OBJPROP_TIME1, tiempo2 + (2 * Period() * 60));
      ObjectSet(IndicatorObjPrefix + "T" + Nombre, OBJPROP_PRICE1, precio1);
     }
  }

// Draw Separator
void Separator(string Nombre, datetime tiempo1, color sesscolor, int ancho, int style)
  {
   ObjectDelete(IndicatorObjPrefix + Nombre);
   ObjectCreate(IndicatorObjPrefix + Nombre, OBJ_VLINE, 0, tiempo1, WindowPriceMax());
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_COLOR, sesscolor);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_STYLE, style);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_WIDTH, ancho);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_BACK, True);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsInvalidTimeframe()
  {
   bool wrong_tf = false;
   if(Period() == 5 && BTF < 2)
      wrong_tf = true;
   if(Period() == 15 && BTF < 3)
      wrong_tf = true;
   if(Period() == 30 && BTF < 4)
      wrong_tf = true;
   if(Period() == 60 && BTF < 5)
      wrong_tf = true;
   if(Period() == 240 && BTF < 6)
      wrong_tf = true;
   if(Period() == 1440 && BTF < 7)
      wrong_tf = true;
   if(Period() == 10080 && BTF < 8)
      wrong_tf = true;
   if(Period() == 43200)
      wrong_tf = true;
   return (wrong_tf);
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