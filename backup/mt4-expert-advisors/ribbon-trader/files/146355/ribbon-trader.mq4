// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=146213#p146213

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  |
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
#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property strict
#property indicator_separate_window
#property indicator_minimum 0.5
#property indicator_maximum 3.0
#property indicator_buffers 10
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 Lime
#property indicator_color4 Red
#property indicator_color5 Lime
#property indicator_color6 Red
#property indicator_color7 Lime
#property indicator_color8 Red
#property indicator_color9 clrNONE
#property indicator_color10 clrNONE

extern string myFont                = "Arial Bold";
extern int    myFontSize            = 20;
extern int    xStart                = 0;
extern int    xOffSet               = 0;
extern int    MAPeriod              = 5;
extern int    MAType                = 1;
extern int    BarWidth              = 0;
extern color  BarColorUp            = Lime;
extern color  BarColorDown          = Red;
extern color  TextColor             = Black;
extern int    MaxBars               = 500;
extern int    myWingding            = 110;
extern color  ArrowUp               = clrLime;
extern color  ArrowDown             = clrRed;
input string  TZ                    = "== Notifications ==";  // Notifications
input bool    notifications         = false;                  // Notifications On
input bool    notifAll              = true;                   // Notify when all emas aligned?
input bool    notif05               = true;                   // Notify when ema 5 change?
input bool    notif10               = true;                   // Notify when ema 10 change?
input bool    notif20               = true;                   // Notify when ema 20 change?
input bool    notif30               = true;                   // Notify when ema 30 change?
input bool    desktop_notifications = false;                  // Desktop MT4 Notifications
input bool    email_notifications   = false;                  // Email Notifications
input bool    push_notifications    = false;                  // Push Mobile Notifications

double gd_unused_136 = 1.0;
double buffer0[];
double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];
double buffer5[];
double buffer6[];
double buffer7[];
double buffer8[];
double buffer9[];
string gs_dummy_180;
double emaCurrent;
double emaPrevious;
string gs_unused_204 = "";
int    gi_unused_212 = 16777215;
string gs_216;
string gs_232;
int    gi_unused_244;
int    g_acc_number_248;
int    gi_252;
int    g_color_256    = Red;
string gs_unused_260  = "Font Size";
int    g_fontsize_268 = 40;
string gs_unused_272  = "Font Type";
string gs_verdana_280 = "Verdana";
string g_text_288     = ">>> CHECKING ACCOUNT <<<";
string g_text_296     = ">>> AUTHORIZATION <<<";
string g_name_304     = "cmtagtpbi01";
string g_name_312     = "cmtagtpbi02";
string aname = "ribbon_-_trader_arr_";

// ------------------------------------------------------------------
class CNewCandle
  {
private:
   int               _initialCandles;
   string            _symbol;
   int               _tf;

public:
                     CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
                     CNewCandle()
     {
      // toma los valores del chart actual
      _initialCandles = iBars(Symbol(), Period());
      _symbol         = Symbol();
      _tf             = Period();
     }
                    ~CNewCandle() {;}

   bool              IsNewCandle()
     {
      int _currentCandles = iBars(_symbol, _tf);
      if(_currentCandles > _initialCandles)
        {
         _initialCandles = _currentCandles;
         return true;
        }
      return false;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CNewCandle newCandle();
// ------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   ObjectsDeleteAll(0, aname);
   gi_unused_244 = 1;
   gs_232        = " RibbonTrader " + Symbol() + Period();
   gs_216        = gs_232 + "0";
   IndicatorShortName(gs_232);
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, BarWidth, BarColorUp);
   SetIndexArrow(0, myWingding);
   SetIndexBuffer(0, buffer0);
   SetIndexLabel(0, "EMA 5");
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, BarWidth, BarColorDown);
   SetIndexArrow(1, myWingding);
   SetIndexBuffer(1, buffer1);
   SetIndexLabel(1, "EMA 5");
   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, BarWidth, BarColorUp);
   SetIndexArrow(2, myWingding);
   SetIndexBuffer(2, buffer2);
   SetIndexLabel(2, "EMA 10");
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, BarWidth, BarColorDown);
   SetIndexArrow(3, myWingding);
   SetIndexBuffer(3, buffer3);
   SetIndexLabel(3, "EMA 10");
   SetIndexStyle(4, DRAW_ARROW, STYLE_SOLID, BarWidth, BarColorUp);
   SetIndexArrow(4, myWingding);
   SetIndexBuffer(4, buffer4);
   SetIndexLabel(4, "EMA 20");
   SetIndexStyle(5, DRAW_ARROW, STYLE_SOLID, BarWidth, BarColorDown);
   SetIndexArrow(5, myWingding);
   SetIndexBuffer(5, buffer5);
   SetIndexLabel(5, "EMA 20");
   SetIndexStyle(6, DRAW_ARROW, STYLE_SOLID, BarWidth, BarColorUp);
   SetIndexArrow(6, myWingding);
   SetIndexBuffer(6, buffer6);
   SetIndexLabel(6, "EMA 30");
   SetIndexStyle(7, DRAW_ARROW, STYLE_SOLID, BarWidth, BarColorDown);
   SetIndexArrow(7, myWingding);
   SetIndexBuffer(7, buffer7);
   SetIndexLabel(7, "EMA 30");
   SetIndexStyle(8, DRAW_NONE);
   SetIndexBuffer(8, buffer8);
   SetIndexLabel(8, "All EMA UP");
   SetIndexStyle(9, DRAW_NONE);
   SetIndexBuffer(9, buffer9);
   SetIndexLabel(9, "All EMA DOWN");
   IndicatorDigits(0);
   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete(g_name_304);
   ObjectDelete(g_name_312);
   ObjectsDeleteAll(0, aname);
   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   ObjectDelete(g_name_304);
   ObjectDelete(g_name_312);
   int indiCount = IndicatorCounted();
   if(indiCount < 0)
      return (-1);
   if(indiCount > 0)
      indiCount--;
   int limit = Bars - indiCount;
   if(gi_252 < Bars - 1)
      limit = Bars - 1;
   for(int i = 0; i < limit; i++)
     {
      buffer0[i] = EMPTY_VALUE;
      buffer1[i] = EMPTY_VALUE;
      buffer2[i] = EMPTY_VALUE;
      buffer3[i] = EMPTY_VALUE;
      buffer4[i] = EMPTY_VALUE;
      buffer5[i] = EMPTY_VALUE;
      buffer6[i] = EMPTY_VALUE;
      buffer7[i] = EMPTY_VALUE;
      buffer8[i] = EMPTY_VALUE;
      buffer9[i] = EMPTY_VALUE;
      emaCurrent  = iMA(NULL, 0, 5, 0, MODE_EMA, PRICE_CLOSE, i);
      emaPrevious = iMA(NULL, 0, 5, 0, MODE_EMA, PRICE_CLOSE, i + 1);
      if(emaCurrent < emaPrevious)
         buffer1[i] = 2.5;
      else
         buffer0[i] = 2.5;
      emaCurrent  = iMA(NULL, 0, 10, 0, MODE_EMA, PRICE_CLOSE, i);
      emaPrevious = iMA(NULL, 0, 10, 0, MODE_EMA, PRICE_CLOSE, i + 1);
      if(emaCurrent < emaPrevious)
         buffer3[i] = 2;
      else
         buffer2[i] = 2;
      emaCurrent  = iMA(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE, i);
      emaPrevious = iMA(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE, i + 1);
      if(emaCurrent < emaPrevious)
         buffer5[i] = 1.5;
      else
         buffer4[i] = 1.5;
      emaCurrent  = iMA(NULL, 0, 30, 0, MODE_EMA, PRICE_CLOSE, i);
      emaPrevious = iMA(NULL, 0, 30, 0, MODE_EMA, PRICE_CLOSE, i + 1);
      if(emaCurrent < emaPrevious)
         buffer7[i] = 1;
      else
         buffer6[i] = 1;
      if(i > gi_252)
         gi_252 = i;
      if(newCandle.IsNewCandle())
        {
         ObjectsDeleteAll(0, aname);
         if(notifAll)
           {
            if(buffer0[i + 1] != EMPTY_VALUE && buffer2[i + 1] != EMPTY_VALUE && buffer4[i + 1] != EMPTY_VALUE && buffer6[i + 1] != EMPTY_VALUE)
              {
               Notifications(2);
              }
            if(buffer1[i + 1] != EMPTY_VALUE && buffer3[i + 1] != EMPTY_VALUE && buffer5[i + 1] != EMPTY_VALUE && buffer7[i + 1] != EMPTY_VALUE)
              {
               Notifications(3);
              }
           }
         if(notif05)
           {
            if(buffer0[i + 2] == EMPTY_VALUE && buffer0[i + 1] != EMPTY_VALUE)
              {
               Notifications(0, "EMA 5: ");
              }
            if(buffer0[i + 2] != EMPTY_VALUE && buffer0[i + 1] == EMPTY_VALUE)
              {
               Notifications(1, "EMA 5: ");
              }
           }
         if(notif10)
           {
            if(buffer2[i + 2] == EMPTY_VALUE && buffer2[i + 1] != EMPTY_VALUE)
              {
               Notifications(0, "EMA 10: ");
              }
            if(buffer2[i + 2] != EMPTY_VALUE && buffer2[i + 1] == EMPTY_VALUE)
              {
               Notifications(1, "EMA 10: ");
              }
           }
         if(notif20)
           {
            if(buffer4[i + 2] == EMPTY_VALUE && buffer4[i + 1] != EMPTY_VALUE)
              {
               Notifications(0, "EMA 20: ");
              }
            if(buffer4[i + 2] != EMPTY_VALUE && buffer4[i + 1] == EMPTY_VALUE)
              {
               Notifications(1, "EMA 20: ");
              }
           }
         if(notif30)
           {
            if(buffer6[i + 2] == EMPTY_VALUE && buffer6[i + 1] != EMPTY_VALUE)
              {
               Notifications(0, "EMA 30: ");
              }
            if(buffer6[i + 2] != EMPTY_VALUE && buffer6[i + 1] == EMPTY_VALUE)
              {
               Notifications(1, "EMA 30: ");
              }
           }
        }
     }
   for(int i = 0; i < limit; i++)
     {
      if((buffer0[i] != EMPTY_VALUE && buffer2[i] != EMPTY_VALUE && buffer4[i] != EMPTY_VALUE && buffer6[i] != EMPTY_VALUE) &&
         (buffer0[i + 1] == EMPTY_VALUE || buffer2[i + 1] == EMPTY_VALUE || buffer4[i + 1] == EMPTY_VALUE || buffer6[i + 1] == EMPTY_VALUE))
        {
         buffer8[i] = 1;
         CreateArr(1, i);
        }
      else
        {
         buffer8[i] = EMPTY_VALUE;
         CreateArr(3, i);
        }
      if((buffer1[i] != EMPTY_VALUE && buffer3[i] != EMPTY_VALUE && buffer5[i] != EMPTY_VALUE && buffer7[i] != EMPTY_VALUE) &&
         (buffer1[i + 1] == EMPTY_VALUE || buffer3[i + 1] == EMPTY_VALUE || buffer5[i + 1] == EMPTY_VALUE || buffer7[i + 1] == EMPTY_VALUE))
        {
         buffer9[i] = 1;
         CreateArr(2, i);
        }
      else
        {
         buffer9[i] = EMPTY_VALUE;
         CreateArr(4, i);
        }
     }
   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateArr(int dir, int bar)
  {
   if(dir == 1)
     {
      ObjectCreate(0, aname + "U" + (string)bar, OBJ_ARROW, 0, iTime(Symbol(), Period(), bar), Low[bar]);
      ObjectSetInteger(0, aname + "U" + (string)bar, OBJPROP_COLOR, ArrowUp);
      ObjectSetInteger(0, aname + "U" + (string)bar, OBJPROP_ARROWCODE, 233);
     }
   if(dir == 2)
     {
      ObjectCreate(0, aname + "D" + (string)bar, OBJ_ARROW, 0, iTime(Symbol(), Period(), bar), High[bar]);
      ObjectSetInteger(0, aname + "D" + (string)bar, OBJPROP_COLOR, ArrowDown);
      ObjectSetInteger(0, aname + "D" + (string)bar, OBJPROP_ANCHOR,ANCHOR_BOTTOM);
      ObjectSetInteger(0, aname + "D" + (string)bar, OBJPROP_ARROWCODE, 234);
     }
   if(dir == 3)
     {
      ObjectDelete(0, aname + "U" + (string)bar);
     }
   if(dir == 4)
     {
      ObjectDelete(0, aname + "D" + (string)bar);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notifications(int type, string text = "")
  {
   if(type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + " change to buy Signal";
   if(type == 1)
      text += _Symbol + " " + GetTimeFrame(_Period) + " change to sell Signal";
   if(type == 2)
      text += _Symbol + " " + GetTimeFrame(_Period) + " All Emas Aligned in BUY Signal";
   if(type == 3)
      text += _Symbol + " " + GetTimeFrame(_Period) + " All Emas Aligned in SELL Signal";
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
