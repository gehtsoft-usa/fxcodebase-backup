// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68997

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window 

#import "user32.dll"
  int GetWindowRect(int hwnd, int& lpRect[]);
#import

extern color Lines_Color=Red;
extern ENUM_LINE_STYLE Lines_Style=STYLE_DASH;
extern int Lines_Width=1;
input int horizonal_lines = 1; // Number of horizonal lines
input int vertical_lines = 1; // Number of vertical lines
int WindowL, WindowR, WindowH;

void GetWindowSize()
{
   int h=WindowHandle(Symbol(), Period());
   int r[4];
   
   GetWindowRect(h, r);

   WindowL = r[2];
   WindowR = r[0];
   WindowH = r[3] - r[1] - 26;
}

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

int init()
{
   IndicatorName = GenerateIndicatorName("Screen Quadrant");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);

   GetWindowSize();
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   
   return(0);
}

void DrawHLine(string id, double price)
{
   long current_chart_id = ChartID();
   if (ObjectFind(current_chart_id, IndicatorObjPrefix + id) < 0)
   {
      ObjectCreate(current_chart_id, IndicatorObjPrefix + id, OBJ_HLINE, 0, 0, price);
      ObjectSet(IndicatorObjPrefix + id, OBJPROP_COLOR, Lines_Color);
      ObjectSet(IndicatorObjPrefix + id, OBJPROP_STYLE, Lines_Style);
      ObjectSet(IndicatorObjPrefix + id, OBJPROP_WIDTH, Lines_Width);
   }
   else
   {
      ObjectSet(IndicatorObjPrefix + id, OBJPROP_PRICE1, price);
   }
}

void DrawVLine(string id, datetime dt)
{
   long current_chart_id = ChartID();
   if (ObjectFind(current_chart_id, IndicatorObjPrefix + id) < 0)
   {
      ObjectCreate(current_chart_id, IndicatorObjPrefix + id, OBJ_VLINE, 0, dt, 0);
      ObjectSet(IndicatorObjPrefix + id, OBJPROP_COLOR, Lines_Color);
      ObjectSet(IndicatorObjPrefix + id, OBJPROP_STYLE, Lines_Style);
      ObjectSet(IndicatorObjPrefix + id, OBJPROP_WIDTH, Lines_Width);
   }
   else
      ObjectSet(IndicatorObjPrefix + id, OBJPROP_TIME1, dt);
}

void DrawLines()
{
   GetWindowSize();
   
   double fromPrice = WindowPriceMax(0);
   double step = (fromPrice - WindowPriceMin(0)) / (horizonal_lines + 1);
   for (int i = 1; i <= horizonal_lines; ++i)
   {
      DrawHLine("_h" + IntegerToString(i), fromPrice - step * i);
   }
   long current_chart_id = ChartID();
   int vstep = MathAbs(WindowL - WindowR) / (vertical_lines + 1);
   for (int i = 1; i <= vertical_lines; ++i)
   {
      datetime TimePos;
      int s=0;
      double v;
      ChartXYToTimePrice(current_chart_id, vstep * i, WindowH-100, s, TimePos, v);
      DrawVLine("_v" + IntegerToString(i), TimePos);
   }
   
   return;
}

int start()
{
   return(0);
}

void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam)
{
   if (id==CHARTEVENT_CHART_CHANGE || id==4)
   {
      DrawLines();
   }
}


