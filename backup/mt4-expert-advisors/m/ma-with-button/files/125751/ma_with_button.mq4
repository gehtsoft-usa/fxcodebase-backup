// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68338

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
#property strict

#property indicator_chart_window
#property indicator_buffers 5
extern ENUM_MA_METHOD ma1_method = MODE_EMA; // MA 1 Method
extern int ma1_length = 8; // MA 1 Length
extern color ma1_color = Green; // MA 1 Color
extern int ma1_width = 1; // MA 1 Line Width
extern ENUM_MA_METHOD ma2_method = MODE_EMA; // MA 2 Method
extern int ma2_length = 21; // MA 2 Length
extern color ma2_color = Red; // MA 2 Color
extern int ma2_width = 1; // MA 2 Line Width
extern ENUM_MA_METHOD ma3_method = MODE_EMA; // MA 3 Method
extern int ma3_length = 50; // MA 3 Length
extern color ma3_color = Blue; // MA 3 Color
extern int ma3_width = 1; // MA 3 Line Width
extern ENUM_MA_METHOD ma4_method = MODE_EMA; // MA 4 Method
extern int ma4_length = 200; // MA 4 Length
extern color ma4_color = Yellow; // MA 4 Color
extern int ma4_width = 1; // MA 4 Line Width
extern ENUM_MA_METHOD ma5_method = MODE_EMA; // MA 5 Method
extern int ma5_length = 800; // MA 5 Length
extern color ma5_color = Brown; // MA 5 Color
extern int ma5_width = 1; // MA 5 Line Width
extern int button_x = 20;
extern int button_y = 30;

bool show_data = true;

double ma1[], ma2[], ma3[], ma4[], ma5[];

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

string buttonId;

int init()
{
   IndicatorName = GenerateIndicatorName("5 MA with Button");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   
   double val;
   if (GlobalVariableGet(IndicatorName + "_visibility", val))
      show_data = val != 0;

   SetIndexBuffer(0, ma1);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, ma1_width, ma1_color);
   SetIndexBuffer(1, ma2);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, ma2_width, ma2_color);
   SetIndexBuffer(2, ma3);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, ma3_width, ma3_color);
   SetIndexBuffer(3, ma4);
   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, ma4_width, ma4_color);
   SetIndexBuffer(4, ma5);
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, ma5_width, ma5_color);
   
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix + "CloseButton";
   createButton(buttonId, "5 EMA", 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);
   
   return 0;
}

void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
   ObjectDelete(0,buttonID);
   ObjectCreate(0,buttonID,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
   ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
   ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
   ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
   ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
   ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
   ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
   ObjectSetString(0,buttonID,OBJPROP_FONT,font);
   ObjectSetString(0,buttonID,OBJPROP_TEXT,buttonText);
   ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,buttonID,OBJPROP_CORNER,2);
   ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

bool recalc = true;

void handleButtonClicks()
{
   if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
   {
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
      start();
   }
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   handleButtonClicks();
}

int start()
{
   handleButtonClicks();
   if (Bars <= 3) 
      return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return(-1);
   int limit = Bars - 2;
   if (ExtCountedBars > 2 && !recalc) 
      limit = Bars - ExtCountedBars - 1;
   recalc = false;

   int pos = limit;
   while (pos >= 0)
   {
      if (show_data)
      {
         ma1[pos] = iMA(_Symbol, _Period, ma1_length, 0, ma1_method, PRICE_CLOSE, pos);
         ma2[pos] = iMA(_Symbol, _Period, ma2_length, 0, ma2_method, PRICE_CLOSE, pos);
         ma3[pos] = iMA(_Symbol, _Period, ma3_length, 0, ma3_method, PRICE_CLOSE, pos);
         ma4[pos] = iMA(_Symbol, _Period, ma4_length, 0, ma4_method, PRICE_CLOSE, pos);
         ma5[pos] = iMA(_Symbol, _Period, ma5_length, 0, ma5_method, PRICE_CLOSE, pos);
      }
      else
      {
         ma1[pos] = EMPTY_VALUE;
         ma2[pos] = EMPTY_VALUE;
         ma3[pos] = EMPTY_VALUE;
         ma4[pos] = EMPTY_VALUE;
         ma5[pos] = EMPTY_VALUE;
      }
   
      pos--;
   }
   return 0;
}

