// Id: 22726
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66925

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

// Trading arrows template v.1.0.0
#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.4"
#property strict

string IndicatorName = "Strategy tester";

extern datetime start_date = 0; // Start date
extern datetime stop_date = 0; // End date
extern string indicator_name = "AFBSR breakout alert"; // Indicator name
extern color label_color = clrRed; // Label color
extern color background_color = clrLightBlue; // Background color
extern int martingale = 0;
extern int x_start = 200; // X position of box
extern int y_start = 5; // Y position of box
extern int x_dist = 100; // Cell width
extern int y_dist = 20; // Cell height
extern int font_size = 12; // Font size
extern ENUM_BASE_CORNER corner = CORNER_RIGHT_UPPER; // Corder of the box

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_label1 "BUY"
#property indicator_label2 "SELL"

double buy[], sell[];
bool initFailed = false;

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
   IndicatorName = GenerateIndicatorName("Strategy tester");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   double temp = iCustom(NULL, 0, indicator_name, 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      initFailed = true;
      Alert("Indicator not found");
      return INIT_FAILED;
   }
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_ARROW, 0, 2);
   SetIndexArrow(0, 217);
   SetIndexBuffer(0, buy);
   SetIndexStyle(1, DRAW_ARROW, 0, 2);
   SetIndexArrow(1, 218);
   SetIndexBuffer(1, sell);
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1

int GetDirection(const int period)
{
   double buyVal = iCustom(NULL, 0, indicator_name, buyStream, period);
   if (buyVal != EMPTY_VALUE && buyVal != 0)
      return ENTER_BUY_SIGNAL;
   double sellVal = iCustom(NULL, 0, indicator_name, sellStream, period);
   if (sellVal != EMPTY_VALUE && sellVal != 0)
      return ENTER_SELL_SIGNAL;
   return 0;
}

int buyStream = -1;
int sellStream = -1;
datetime lastDatetime = 0;
void FindStreams()
{
   int pos = 0;
   while (pos < MathMin(1000, Bars - 3) && (buyStream == -1 || sellStream == -1))
   {
      int streamIndex = -1;
      while (streamIndex < 8)
      {
         streamIndex++;
         ResetLastError();
         double val = iCustom(NULL, 0, indicator_name, streamIndex, pos);
         int err = GetLastError();
         if (err != ERR_NO_ERROR)            
            break;
         if (val == EMPTY_VALUE || val == 0)
            continue;
         double val1 = iCustom(NULL, 0, indicator_name, streamIndex, pos + 1);
         if (val1 != EMPTY_VALUE && val1 != 0)
            continue;
         double val2 = iCustom(NULL, 0, indicator_name, streamIndex, pos + 2);
         if (val2 != EMPTY_VALUE && val2 != 0)
            continue;
         if (val >= High[pos])
         {
            sellStream = streamIndex;
         }
         else if (val <= Low[pos])
         {
            buyStream = streamIndex;
         }
      }
      pos++;
   }
}

bool firstValue = true;
double lastPrice = 0.0;
int wins = 0;
int loses = 0;
void RegisterSell(const int period)
{
   buy[period] = EMPTY_VALUE;
   sell[period] = High[period];
   bool win = false;
   for (int i = period - 1; i >= MathMax(0, period - 1 - martingale); --i)
   {
      if (Open[i] > Close[i])
         win = true;
   }
   if (win)
      wins++;
   else
      loses++;
}

void RegisterBuy(const int period)
{
   buy[period] = Low[period];
   sell[period] = EMPTY_VALUE;
   bool win = false;
   for (int i = period - 1; i >= MathMax(0, period - 1 - martingale); --i)
   {
      if (Open[i] < Close[i])
         win = true;
   }
   if (win)
      wins++;
   else
      loses++;
}

int start()
{
   if (Bars <= 1 || (buyStream == -1 && sellStream == -1 && lastDatetime == Time[0]) || initFailed)
      return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0)
      return(-1);
   if (buyStream == -1 || sellStream == -1)
   {
      lastDatetime = Time[0];
      FindStreams();
      if (buyStream == -1 || sellStream == -1)
         return 0;
   }
   
   int limit = Bars - 1;
   if(ExtCountedBars > 1 && !firstValue)
      limit = Bars - ExtCountedBars - 1;
   firstValue = false;

   int pos = limit;
   while (pos >= 0)
   {
      if (Time[pos] >= start_date && Time[pos] <= stop_date)
      {
         int direction = GetDirection(pos);
         switch (direction)
         {
            case ENTER_BUY_SIGNAL:
               RegisterBuy(pos);
               break;
            case ENTER_SELL_SIGNAL:
               RegisterSell(pos);
               break;
         }
      }
      pos--;
   }
   Draw();
   return(0);
}

void DrawLabel(const string id, const string text, const int x, const int y, const int width, const int height, const color back_clr, const color text_color)
{
   int x_mult = corner == CORNER_LEFT_LOWER || corner == CORNER_LEFT_UPPER ? -1 : 1;
   int y_mult = corner == CORNER_LEFT_LOWER || corner == CORNER_RIGHT_LOWER ? -1 : 1;
   ObjectCreate(0, IndicatorObjPrefix + id + "Bg", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, IndicatorObjPrefix + id + "Bg", OBJPROP_XDISTANCE, x); 
   ObjectSetInteger(0, IndicatorObjPrefix + id + "Bg", OBJPROP_YDISTANCE, y); 
   ObjectSetInteger(0, IndicatorObjPrefix + id + "Bg", OBJPROP_XSIZE, width); 
   ObjectSetInteger(0, IndicatorObjPrefix + id + "Bg", OBJPROP_YSIZE, height); 
   ObjectSetInteger(0, IndicatorObjPrefix + id + "Bg", OBJPROP_BGCOLOR, back_clr);
   ObjectSetInteger(0, IndicatorObjPrefix + id + "Bg", OBJPROP_CORNER, corner);
   ObjectCreate(IndicatorObjPrefix + id, OBJ_LABEL, 0,0,0,0,0);
   ObjectSet(IndicatorObjPrefix + id, OBJPROP_XDISTANCE, x - x_mult * width / 2); 
   ObjectSet(IndicatorObjPrefix + id, OBJPROP_YDISTANCE, y + y_mult * height / 2); 
   ObjectSetInteger(0, IndicatorObjPrefix + id, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, IndicatorObjPrefix + id, OBJPROP_ANCHOR, ANCHOR_CENTER); 
   ObjectSetText(IndicatorObjPrefix + id, text, font_size, "Arial", text_color);
}

void Draw()
{   
   DrawLabel("Total", IntegerToString(wins + loses), x_start, y_start, x_dist, y_dist, background_color, label_color);
   DrawLabel("Details", "+" + IntegerToString(wins) + "/-" + IntegerToString(loses), x_start, y_start + y_dist, x_dist, y_dist, background_color, label_color);
   if (wins + loses > 0)
      DrawLabel("Ratio", DoubleToStr(wins * 100.0 / (wins + loses), 2) + "%", x_start, y_start + y_dist * 2, x_dist, y_dist, background_color, label_color);
}