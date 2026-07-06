// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68375

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
#property indicator_buffers 0

input double LEVEL_1 = 0.236; // Level 1
input color LevelColor1 = Red; // Level 1 color
input int LevelWidth1 = 1; // Level 1 width
input ENUM_LINE_STYLE LevelStyle1 = STYLE_SOLID; // Level 1 style
input double LEVEL_2 = 0.382; // Level 2
input color LevelColor2 = Green; // Level 2 color
input int LevelWidth2 = 1; // Level 2 width
input ENUM_LINE_STYLE LevelStyle2 = STYLE_SOLID; // Level 2 style
input double LEVEL_3 = 0.500; // Level 3
input color LevelColor3 = Blue; // Level 3 color
input int LevelWidth3 = 1; // Level 3 width
input ENUM_LINE_STYLE LevelStyle3 = STYLE_SOLID; // Level 3 style
input double LEVEL_4 = 0.618; // Level 4
input color LevelColor4 = Yellow; // Level 4 color
input int LevelWidth4 = 1; // Level 4 width
input ENUM_LINE_STYLE LevelStyle4 = STYLE_SOLID; // Level 4 style
input double LEVEL_5 = 0.762; // Level 5
input color LevelColor5 = Lime; // Level 5 color
input int LevelWidth5 = 1; // Level 5 width
input ENUM_LINE_STYLE LevelStyle5 = STYLE_SOLID; // Level 5 style
extern int button_x = 20; // Button X
extern int button_y = 30; // Button Y

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
int items = 0;

int init()
{
   IndicatorName = GenerateIndicatorName("Fibonacci");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);

   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix + "AddFibonacciButton";
   createButton(buttonId, "Add Fib", 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
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

void CreateFibLevel(const double level, const color clr, const int width, const ENUM_LINE_STYLE style)
{
   string trendId = IndicatorObjPrefix + "_trend_" + IntegerToString(items);
   double fromPrice = ObjectGetDouble(0, trendId, OBJPROP_PRICE, 0);
   double toPrice = ObjectGetDouble(0, trendId, OBJPROP_PRICE, 1);
   datetime from = (datetime)ObjectGet(trendId, OBJPROP_TIME1);
   datetime to = (datetime)ObjectGet(trendId, OBJPROP_TIME2);

   string levelId = IndicatorObjPrefix + "_level_" + IntegerToString(items) + "_" + DoubleToString(level);
   double levelPrice = fromPrice - (fromPrice - toPrice) * level;
   ObjectCreate(levelId, OBJ_TREND, 0, from, levelPrice, to, levelPrice);
   ObjectSet(levelId, OBJPROP_RAY, false);
   ObjectSetInteger(0, levelId, OBJPROP_COLOR, clr); 
   ObjectSetInteger(0, levelId, OBJPROP_WIDTH, width); 
   ObjectSetInteger(0, levelId, OBJPROP_STYLE, style); 
}

void handleButtonClicks()
{
   if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
   {
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);

      string trendId = IndicatorObjPrefix + "_trend_" + IntegerToString(items);
      ObjectCreate(trendId, OBJ_TREND, 0, Time[10], Close[10], Time[0], Close[0]);
      ObjectSet(trendId, OBJPROP_RAY, false);

      CreateFibLevel(LEVEL_1, LevelColor1, LevelWidth1, LevelStyle1);
      CreateFibLevel(LEVEL_2, LevelColor2, LevelWidth2, LevelStyle2);
      CreateFibLevel(LEVEL_3, LevelColor3, LevelWidth3, LevelStyle3);
      CreateFibLevel(LEVEL_4, LevelColor4, LevelWidth4, LevelStyle4);
      CreateFibLevel(LEVEL_5, LevelColor5, LevelWidth5, LevelStyle5);

      ++items;
   }
}

void MoveLevel(const double fromPrice, const double toPrice, const datetime from, const datetime to, const int i, const double level)
{
   string levelId = IndicatorObjPrefix + "_level_" + IntegerToString(i) + "_" + DoubleToString(level);
   if (ObjectFind(0, levelId) == -1)
      return;
   double levelPrice = fromPrice - (fromPrice - toPrice) * level;
   ObjectSet(levelId, OBJPROP_TIME1, from);
   ObjectSet(levelId, OBJPROP_TIME2, to);
   ObjectSet(levelId, OBJPROP_PRICE1, levelPrice);
   ObjectSet(levelId, OBJPROP_PRICE2, levelPrice);
}

void moveLevels()
{
   for (int i = 0; i < items; ++i)
   {
      string trendId = IndicatorObjPrefix + "_trend_" + IntegerToString(i);
      if (ObjectFind(0, trendId) == -1)
         continue;

      double fromPrice = ObjectGetDouble(0, trendId, OBJPROP_PRICE, 0);
      double toPrice = ObjectGetDouble(0, trendId, OBJPROP_PRICE, 1);
      datetime from = (datetime)ObjectGet(trendId, OBJPROP_TIME1);
      datetime to = (datetime)ObjectGet(trendId, OBJPROP_TIME2);

      MoveLevel(fromPrice, toPrice, from, to, i, LEVEL_1);
      MoveLevel(fromPrice, toPrice, from, to, i, LEVEL_2);
      MoveLevel(fromPrice, toPrice, from, to, i, LEVEL_3);
      MoveLevel(fromPrice, toPrice, from, to, i, LEVEL_4);
      MoveLevel(fromPrice, toPrice, from, to, i, LEVEL_5);
   }
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   handleButtonClicks();
   moveLevels();
}

int start()
{
   handleButtonClicks();
   return 0;
}

