// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68338
 
//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 clrYellowGreen
#property indicator_color2 clrLightCoral
#property indicator_color3 clrMagenta
#property indicator_color4 clrGoldenrod

/*
ENUM_LINE_STYLE
STYLE_SOLID      0 The pen is solid
STYLE_DASH       1 The pen is dashed
STYLE_DOT        2 The pen is dotted
STYLE_DASHDOT    3 The pen has alternating dashes and dots
STYLE_DASHDOTDOT 4 The pen has alternating dashes and double dots
*/
extern double             MinRewardRatio        =  2;
extern string             BuyLevelNote          = "------------------------------";
extern color              BuyLevelColor         =  clrDodgerBlue;
extern ENUM_LINE_STYLE    BuyLevelStyle         =  STYLE_DOT;
extern int                BuyLevelWidth         =  0;
extern string             SellLevelNote         = "------------------------------";
extern color              SellLevelColor        =  clrTomato;
extern ENUM_LINE_STYLE    SellLevelStyle        =  STYLE_DASHDOT;
extern int                SellLevelWidth        =  0;
extern string             StopLossNote          = "------------------------------";
extern color              StopLossColor         =  clrOrangeRed;
extern ENUM_LINE_STYLE    StopLossStyle         =  STYLE_DASHDOT;
extern int                StopLossWidth         =  0;
extern string             TakeProfitNote        = "------------------------------";
extern color              TakeProfitColor1      =  clrSpringGreen;
extern ENUM_LINE_STYLE    TakeProfitStyle1      =  STYLE_DOT;
extern int                TakeProfitWidth1      =  2;
extern color              TakeProfitColor2      =  clrSpringGreen;
extern ENUM_LINE_STYLE    TakeProfitStyle2      =  STYLE_DASHDOTDOT;
extern int                TakeProfitWidth2      =  2;
extern color              TakeProfitColor3      =  clrSpringGreen;
extern ENUM_LINE_STYLE    TakeProfitStyle3      =  STYLE_DASHDOTDOT;
extern int                TakeProfitWidth3      =  2;
extern string             note1                 = "------------------------------";
extern string             FontName              =  "Arial";
extern int                FontSize              =  8;
extern color              TextColor             =  clrDimGray;
extern string             note2                 = "------------------------------";
extern string             FontName2             =  "Arial";
extern int                FontSize2             =  10;
extern color              TextColor2            =  clrYellow;
extern string             button_note1          = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER; // chart btn_corner for anchoring
extern string             btn_text              = "FiboCalc";
extern string             btn_Font              = "Arial";
extern int                btn_FontSize          = 10;                             //btn__font size
extern color              btn_text_color        = clrWhite;
extern color              btn_background_color  = clrDimGray;
extern color              btn_border_color      = clrBlack;
extern int                button_x              = 20;                                     //btn__x
extern int                button_y              = 13;                                     //btn__y
extern int                btn_Width             = 60;                                 //btn__width
extern int                btn_Height            = 20;                                //btn__height
extern string             button_note2          = "------------------------------";

bool                      show_data             = true;
string IndicatorName, IndicatorObjPrefix;
//template code end1
double PrevDayHiBuffer[];
double PrevDayLoBuffer[];
double PrevDayOpenBuffer[];
double PrevDayCloseBuffer[];
double trend[];
//----
double PrevDayHi, PrevDayLo, PrevDayOpen, PrevDayClose, fb, fs, fe, tp1, tp2, tp3, prevfb, prevfs, prevtrend;
double LastHigh, LastLow, LastOpen, LastClose, x;
double ri, re1, re2, re3, ra1, ra2, ra3;
datetime prevtime, prevtgttime;

//+------------------------------------------------------------------+
string GenerateIndicatorName(const string target) //don't change anything here
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
string buttonId;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorName = GenerateIndicatorName(btn_text);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   double val;
   if(GlobalVariableGet(IndicatorName + "_visibility", val))
      show_data = val != 0;
// put init() here
//---- indicator line
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE);
//----
   IndicatorBuffers(5);
   SetIndexBuffer(0, PrevDayHiBuffer);
   SetIndexBuffer(1, PrevDayLoBuffer);
   SetIndexBuffer(2, PrevDayOpenBuffer);
   SetIndexBuffer(3, PrevDayCloseBuffer);
   SetIndexBuffer(4, trend);
//---- name for DataWindow and indicator subwindow label
   SetIndexLabel(0, "Prev Day High");
   SetIndexLabel(1, "Prev Day Low");
   SetIndexLabel(2, "Prev Day Open");
   SetIndexLabel(3, "Prev Day Close");
//----
   SetIndexDrawBegin(0, 1);
//----
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix + "FiboCalc2020";
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_color);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);
   return 0;
  }
//+------------------------------------------------------------------+
//don't change anything here
void createButton(string buttonID, string buttonText, int width, int height, string font, int fontSize, color bgColor, color borderColor, color txtColor)
  {
   ObjectDelete(0, buttonID);
   ObjectCreate(0, buttonID, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, buttonID, OBJPROP_COLOR, txtColor);
   ObjectSetInteger(0, buttonID, OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, buttonID, OBJPROP_BORDER_COLOR, borderColor);
   ObjectSetInteger(0, buttonID, OBJPROP_BORDER_TYPE, BORDER_RAISED);
   ObjectSetInteger(0, buttonID, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, buttonID, OBJPROP_YSIZE, height);
   ObjectSetString(0, buttonID, OBJPROP_FONT, font);
   ObjectSetString(0, buttonID, OBJPROP_TEXT, buttonText);
   ObjectSetInteger(0, buttonID, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, buttonID, OBJPROP_SELECTABLE, 0);
   ObjectSetInteger(0, buttonID, OBJPROP_CORNER, btn_corner);
   ObjectSetInteger(0, buttonID, OBJPROP_HIDDEN, 1);
   ObjectSetInteger(0, buttonID, OBJPROP_XDISTANCE, 9999);
   ObjectSetInteger(0, buttonID, OBJPROP_YDISTANCE, 9999);
  }
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
//put deinit() here
   ObjectDelete("PrevDayHi");
   ObjectDelete("PrevDayLo");
   ObjectDelete("PrevDayOpen");
   ObjectDelete("PrevDayClose");
   ObjectDelete("fe");
   ObjectDelete("fe Line"); //StopLoss Level
   ObjectDelete("fs");
   ObjectDelete("fs Line"); //Sell Level Line
   ObjectDelete("tp3");
   ObjectDelete("tp3 Line"); //Profit Target 3
   ObjectDelete("tp2");
   ObjectDelete("tp2 Line"); //Profit Target 2
   ObjectDelete("tp1");
   ObjectDelete("tp1 Line"); //Profit Target 1
   ObjectDelete("fb");
   ObjectDelete("fb Line"); //Buy Level Line
   ObjectsDeleteAll(0, "fbc_");
   Comment("");
   return 0;
  }
//+------------------------------------------------------------------+
//don't change anything here
bool recalc = true;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleButtonClicks()
  {
   if(ObjectGetInteger(0, buttonId, OBJPROP_STATE))
     {
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
      start();
     }
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything here
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   handleButtonClicks();
  }
//+------------------------------------------------------------------+
int start2()
  {
   int limit, i, counted_bars = IndicatorCounted();
//---- indicator calculation
   if(Period() > PERIOD_H4)
      return(-1);
   limit = Bars - 2;
//----
   for(i = limit; i >= 0; i--)
     {
      if(High[i]   > LastHigh)
         LastHigh = High[i];//[iHighest(NULL, 0, MODE_HIGH, i + 1)];
      if(Low[i]    < LastLow)
         LastLow  = Low[i];//[iLowest(NULL, 0, MODE_LOW, i + 1)];
      if(Open[i + 1] > LastOpen)
         LastOpen = Open[i + 1];
      //----
      if(TimeDay(Time[i]) != TimeDay(Time[i + 1]) && prevtime != Time[i])
        {
         PrevDayHi    = LastHigh;
         PrevDayLo    = LastLow;
         PrevDayOpen  = LastClose;
         PrevDayClose = Open[i];
         //----
         LastLow      = Open[i];
         LastHigh     = Open[i];
         LastOpen     = Open[i];
         LastClose    = Open[i];
         //----
         if(TimeDayOfYear(Time[i]) == TimeDayOfYear(Time[0]) && TimeYear(Time[i]) == TimeYear(Time[0]))
           {
            if(ObjectFind("PrevDayHi") != 0)
              {
               ObjectCreate("PrevDayHi", OBJ_TEXT, 0, 0, 0);
               ObjectSetText("PrevDayHi", "          Prev. Day High", FontSize, FontName);
               ObjectSet("PrevDayHi", OBJPROP_COLOR, TextColor);
               ObjectMove("PrevDayHi", 0, Time[i], PrevDayHi);
              }
            else
              {
               ObjectMove("PrevDayHi", 0, Time[i], PrevDayHi);
              }
            //----
            if(ObjectFind("PrevDayLo") != 0)
              {
               ObjectCreate("PrevDayLo", OBJ_TEXT, 0, 0, 0);
               ObjectSetText("PrevDayLo", "          Prev. Day Low", FontSize, FontName);
               ObjectSet("PrevDayLo", OBJPROP_COLOR, TextColor);
               ObjectMove("PrevDayLo", 0, Time[i], PrevDayLo);
              }
            else
              {
               ObjectMove("PrevDayLo", 0, Time[i], PrevDayLo);
              }
            //----
            if(ObjectFind("PrevDayOpen") != 0)
              {
               ObjectCreate("PrevDayOpen", OBJ_TEXT, 0, 0, 0);
               ObjectSetText("PrevDayOpen", "                Prev. Day Open", FontSize, FontName);
               ObjectSet("PrevDayOpen", OBJPROP_COLOR, TextColor);
               ObjectMove("PrevDayOpen", 0, Time[i], PrevDayOpen);
              }
            else
              {
               ObjectMove("PrevDayOpen", 0, Time[i], PrevDayOpen);
              }
            //----
            if(ObjectFind("PrevDayClose") != 0)
              {
               ObjectCreate("PrevDayClose", OBJ_TEXT, 0, 0, 0);
               ObjectSetText("PrevDayClose", "                Prev. Day Close", FontSize, FontName);
               ObjectSet("PrevDayClose", OBJPROP_COLOR, TextColor);
               ObjectMove("PrevDayClose", 0, Time[i], PrevDayClose);
              }
            else
              {
               ObjectMove("PrevDayClose", 0, Time[i], PrevDayClose);
              }
           }
         prevtime = Time[i];
        }
      PrevDayHiBuffer[i]    = PrevDayHi;
      PrevDayLoBuffer[i]    = PrevDayLo;
      PrevDayOpenBuffer[i]  = PrevDayOpen;
      PrevDayCloseBuffer[i] = PrevDayClose;
     }
// BUY
   if(counted_bars > 0)
     {
      if(Ask > LastClose)
         trend[0] = 1;
      if(Bid < LastClose)
         trend[0] = -1;
      if(trend[0] > 0)
        {
         fb  = PrevDayHi - (PrevDayHi - PrevDayLo) * 0.382;
         fe  = PrevDayHi - (PrevDayHi - PrevDayLo) * 0.618;
         tp1 = ((PrevDayHi - PrevDayLo) * 0.618) + fb;
         tp2 = (PrevDayHi - PrevDayLo) + fb;
         tp3 = 1.618 * (PrevDayHi - PrevDayLo) + fb;
         ri  = MathRound((fb  - fe) * 10000) / 10000;
         re1 = MathRound((tp1 - fb) * 10000) / 10000;
         re2 = MathRound((tp2 - fb) * 10000) / 10000;
         re3 = MathRound((tp3 - fb) * 10000) / 10000;
         if(ri > 0)
           {
            ra1 = MathRound((re1 / ri) * 10) / 10;
            ra2 = MathRound((re2 / ri) * 10) / 10;
            ra3 = MathRound((re3 / ri) * 10) / 10;
           }
         //----
         if(ObjectFind("fs") == 0)
            ObjectDelete("fs");
         if(ObjectFind("fs Line") == 0)
            ObjectDelete("fs Line");
         if(ObjectFind("fb") != 0)
           {
            ObjectCreate("fb", OBJ_TEXT, 0, Time[0], fb);
            ObjectSetText("fb", " BUY LEVEL", FontSize, FontName);
            ObjectSet("fb", OBJPROP_COLOR, TextColor);
           }
         else
           {
            ObjectMove("fb", 0, Time[0], fb);
           }
         //----
         if(ObjectFind("fb Line") != 0)
           {
            ObjectCreate("fb Line", OBJ_HLINE, 0, Time[0], fb);
            ObjectSet("fb Line", OBJPROP_STYLE, BuyLevelStyle);
            ObjectSet("fb Line", OBJPROP_COLOR, BuyLevelColor);
            ObjectSet("fb Line", OBJPROP_WIDTH, BuyLevelWidth);
           }
         else
           {
            ObjectMove("fb Line", 0, Time[0], fb);
           }
         //----
         if(ra1 > MinRewardRatio)
            //            if (DisplayComments)
            Comment(
               "\n\nPrevDayHi ", PrevDayHi, "\nPrevDayLo ", PrevDayLo, "\nTrend was UP ",
               "\nBUY @ ", fb, "\nStopLoss ", fe, "\nTakeProfit 1 ", tp1,
               " Risk/Reward Ratio : ", ra1, " OK Trade ", "\nTakeProfit 2 ", tp2,
               " Risk/Reward Ratio : ", ra2, " OK Trade ", "\nTakeProfit 3 ", tp3,
               " Risk/Reward Ratio : ", ra3, " OK Trade ");
         else
            //            if (DisplayComments) {
            Comment(
               "\n\nPrevDayHi ", PrevDayHi, "\nPrevDayLo ", PrevDayLo, "\nTrend was UP ",
               "\nBUY @ ", fb, "\nStopLoss ", fe, "\nTakeProfit 1 ", tp1,
               " Risk/Reward Ratio : ", ra1, " NO TRADE ", "\nTakeProfit 2 ", tp2,
               " Risk/Reward Ratio : ", ra2, " NO TRADE ", "\nTakeProfit 3 ", tp3,
               " Risk/Reward Ratio : ", ra3, " NO TRADE ");
        }
      // SELL
      if(trend[0] < 0)
        {
         fs  = (PrevDayHi - PrevDayLo) * 0.382 + (PrevDayLo);
         fe  = (PrevDayHi - PrevDayLo) * 0.618 + (PrevDayLo);
         tp1 = ((PrevDayLo - PrevDayHi) * 0.618) + fs;
         tp2 = (PrevDayLo - PrevDayHi) + fs;
         tp3 = 1.618 * (PrevDayLo - PrevDayHi) + fs;
         ri  = MathRound((fs  - fe) * 10000) / 10000;
         re1 = MathRound((tp1 - fs) * 10000) / 10000;
         re2 = MathRound((tp2 - fs) * 10000) / 10000;
         re3 = MathRound((tp3 - fs) * 10000) / 10000;
         if(ri > 0)
           {
            ra1 = MathRound((re1 / ri) * 10) / 10;
            ra2 = MathRound((re2 / ri) * 10) / 10;
            ra3 = ((re3 / ri) * 10) / 10;
           }
         //----
         if(ObjectFind("fb") == 0)
            ObjectDelete("fb");
         if(ObjectFind("fb Line") == 0)
            ObjectDelete("fb Line");
         if(ObjectFind("fs") != 0)
           {
            ObjectCreate("fs", OBJ_TEXT, 0, Time[0], fs);
            ObjectSetText("fs", " SELL LEVEL", FontSize, FontName);
            ObjectSet("fs", OBJPROP_COLOR, TextColor);
           }
         else
           {
            ObjectMove("fs", 0, Time[0], fs);
           }
         //----
         if(ObjectFind("fs Line") != 0)
           {
            ObjectCreate("fs Line", OBJ_HLINE, 0, Time[0], fs);
            ObjectSet("fs Line", OBJPROP_COLOR, SellLevelColor);
            ObjectSet("fs Line", OBJPROP_STYLE, SellLevelStyle);
            ObjectSet("fs Line", OBJPROP_WIDTH, SellLevelWidth);
           }
         else
           {
            ObjectMove("fs Line", 0, Time[0], fs);
           }
         //----
         if(ra1 > MinRewardRatio)
            //            if (DisplayComments)
            Comment(
               //"Owner : ", AccountName(),"Account number : ", AccountNumber(),
               "\n\nPrevDayHi ", PrevDayHi, "\nPrevDayLo ", PrevDayLo, "\nTrend was Down ",
               "\nSELL @ ", fs, "\nStopLoss ", fe, "\nTakeProfit 1 ", tp1,
               " Risk/Reward Ratio : ", ra1, " OK Trade ", "\nTakeProfit 2 ", tp2,
               " Risk/Reward Ratio : ", ra2, " OK Trade ", "\nTakeProfit 3 ", tp3,
               " Risk/Reward Ratio : ", ra3, " OK Trade ");
         else
            //            if (DisplayComments)
            Comment(
               //"Owner : ", AccountName(),"Account number : ", AccountNumber(),
               "\n\nPrevDayHi ", PrevDayHi, "\nPrevDayLo ", PrevDayLo, "\nTrend was Down ",
               "\nSELL @ ", fs, "\nStopLoss ", fe, "\nTakeProfit 1 ", tp1,
               " Risk/Reward Ratio : ", ra1, " NO TRADE ", "\nTakeProfit 2 ", tp2,
               " Risk/Reward Ratio : ", ra2, " NO TRADE ", "\nTakeProfit 3 ", tp3,
               " Risk/Reward Ratio : ", ra3, " NO TRADE ");
         prevtrend = trend[0];
        }
      //----
      if(prevtgttime != Time[0] || prevfs != fs || prevfb != fb)
        {
         if(ObjectFind("fe") != 0)
           {
            ObjectCreate("fe", OBJ_TEXT, 0, Time[0], fe);
            ObjectSetText("fe", " STOPLOSS LEVEL", FontSize, FontName);
            ObjectSet("fe", OBJPROP_COLOR, TextColor);
           }
         else
           {
            ObjectMove("fe", 0, Time[0], fe);
           }
         //----
         if(ObjectFind("fe Line") != 0)
           {
            ObjectCreate("fe Line", OBJ_HLINE, 0, Time[0], fe);
            ObjectSet("fe Line", OBJPROP_COLOR, StopLossColor);
            ObjectSet("fe Line", OBJPROP_STYLE, StopLossStyle);
            ObjectSet("fe Line", OBJPROP_WIDTH, StopLossWidth);
           }
         else
           {
            ObjectMove("fe Line", 0, Time[0], fe);
           }
         //----
         if(ObjectFind("tp1") != 0)
           {
            ObjectCreate("tp1", OBJ_TEXT, 0, Time[0], tp1);
            ObjectSetText("tp1", " PROFIT TARGET 1", FontSize, FontName);
            ObjectSet("tp1", OBJPROP_COLOR, TextColor);
           }
         else
           {
            ObjectMove("tp1", 0, Time[0], tp1);
           }
         //----
         if(ObjectFind("tp1 Line") != 0)
           {
            ObjectCreate("tp1 Line", OBJ_HLINE, 0, Time[0], tp1);
            ObjectSet("tp1 Line", OBJPROP_COLOR, TakeProfitColor1);
            ObjectSet("tp1 Line", OBJPROP_STYLE, TakeProfitStyle1);
            ObjectSet("tp1 Line", OBJPROP_WIDTH, TakeProfitWidth1);
           }
         else
           {
            ObjectMove("tp1 Line", 0, Time[0], tp1);
           }
         //----
         if(ObjectFind("tp2") != 0)
           {
            ObjectCreate("tp2", OBJ_TEXT, 0, Time[0], tp2);
            ObjectSetText("tp2", " PROFIT TARGET 2", FontSize, FontName);
            ObjectSet("tp2", OBJPROP_COLOR, TextColor);
           }
         else
           {
            ObjectMove("tp2", 0, Time[0], tp2);
           }
         if(ObjectFind("tp2 Line") != 0)
           {
            ObjectCreate("tp2 Line", OBJ_HLINE, 0, Time[0], tp2);
            ObjectSet("tp2 Line", OBJPROP_COLOR, TakeProfitColor2);
            ObjectSet("tp2 Line", OBJPROP_STYLE, TakeProfitStyle2);
            ObjectSet("tp2 Line", OBJPROP_WIDTH, TakeProfitWidth2);
           }
         else
           {
            ObjectMove("tp2 Line", 0, Time[0], tp2);
           }
         //----
         if(ObjectFind("tp3") != 0)
           {
            ObjectCreate("tp3", OBJ_TEXT, 0, Time[0], tp3);
            ObjectSetText("tp3", " PROFIT TARGET 3", FontSize, FontName);
            ObjectSet("tp3", OBJPROP_COLOR, TextColor);
           }
         else
           {
            ObjectMove("tp3", 0, Time[0], tp3);
           }
         //----
         if(ObjectFind("tp3 Line") != 0)
           {
            ObjectCreate("tp3 Line", OBJ_HLINE, 0, Time[0], tp3);
            ObjectSet("tp3 Line", OBJPROP_COLOR, TakeProfitColor3);
            ObjectSet("tp3 Line", OBJPROP_STYLE, TakeProfitStyle3);
            ObjectSet("tp3 Line", OBJPROP_WIDTH, TakeProfitWidth3);
           }
         else
           {
            ObjectMove("tp3 Line", 0, Time[0], tp3);
           }
         prevfb = fb;
         prevfs = fs;
         prevtgttime = Time[0];
        }
     }
//----
for(i = limit; i >= 0; i--)
     {
      if(PrevDayHiBuffer[i + 1] != PrevDayHiBuffer[i] || i == 0)
        {
         setLabel(1, i + 1, PrevDayHiBuffer[i + 1]);
        }
      if(PrevDayLoBuffer[i + 1] != PrevDayLoBuffer[i] || i == 0)
        {
         setLabel(2, i + 1, PrevDayLoBuffer[i + 1]);
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
int start()
  {
   handleButtonClicks();
   recalc = false;
   int limit, i, counted_bars = IndicatorCounted();
//---- indicator calculation
   if(counted_bars > 0)
      limit = Bars - counted_bars - 1;
   if(counted_bars == 0)
     {
      if(Period() > PERIOD_H4)
         return(-1);
      limit = Bars - 2;
     }
//----
   for(i = limit; i >= 0; i--)
     {
      if(High[i]   > LastHigh)
         LastHigh = High[i];//[iHighest(NULL, 0, MODE_HIGH, i + 1)];
      if(Low[i]    < LastLow)
         LastLow  = Low[i];//[iLowest(NULL, 0, MODE_LOW, i + 1)];
      if(Open[i + 1] > LastOpen)
         LastOpen = Open[i + 1];
      //----
      if(TimeDay(Time[i]) != TimeDay(Time[i + 1]) && prevtime != Time[i])
        {
         PrevDayHi    = LastHigh;
         PrevDayLo    = LastLow;
         PrevDayOpen  = LastClose;
         PrevDayClose = Open[i];
         //----
         LastLow      = Open[i];
         LastHigh     = Open[i];
         LastOpen     = Open[i];
         LastClose    = Open[i];
         //----
         if(TimeDayOfYear(Time[i]) == TimeDayOfYear(Time[0]) && TimeYear(Time[i]) == TimeYear(Time[0]))
           {
            if(ObjectFind("PrevDayHi") != 0)
              {
               ObjectCreate("PrevDayHi", OBJ_TEXT, 0, 0, 0);
               ObjectSetText("PrevDayHi", "          Prev. Day High", FontSize, FontName);
               ObjectSet("PrevDayHi", OBJPROP_COLOR, TextColor);
               ObjectMove("PrevDayHi", 0, Time[i], PrevDayHi);
              }
            else
              {
               ObjectMove("PrevDayHi", 0, Time[i], PrevDayHi);
              }
            //----
            if(ObjectFind("PrevDayLo") != 0)
              {
               ObjectCreate("PrevDayLo", OBJ_TEXT, 0, 0, 0);
               ObjectSetText("PrevDayLo", "          Prev. Day Low", FontSize, FontName);
               ObjectSet("PrevDayLo", OBJPROP_COLOR, TextColor);
               ObjectMove("PrevDayLo", 0, Time[i], PrevDayLo);
              }
            else
              {
               ObjectMove("PrevDayLo", 0, Time[i], PrevDayLo);
              }
            //----
            if(ObjectFind("PrevDayOpen") != 0)
              {
               ObjectCreate("PrevDayOpen", OBJ_TEXT, 0, 0, 0);
               ObjectSetText("PrevDayOpen", "                Prev. Day Open", FontSize, FontName);
               ObjectSet("PrevDayOpen", OBJPROP_COLOR, TextColor);
               ObjectMove("PrevDayOpen", 0, Time[i], PrevDayOpen);
              }
            else
              {
               ObjectMove("PrevDayOpen", 0, Time[i], PrevDayOpen);
              }
            //----
            if(ObjectFind("PrevDayClose") != 0)
              {
               ObjectCreate("PrevDayClose", OBJ_TEXT, 0, 0, 0);
               ObjectSetText("PrevDayClose", "                Prev. Day Close", FontSize, FontName);
               ObjectSet("PrevDayClose", OBJPROP_COLOR, TextColor);
               ObjectMove("PrevDayClose", 0, Time[i], PrevDayClose);
              }
            else
              {
               ObjectMove("PrevDayClose", 0, Time[i], PrevDayClose);
              }
           }
         prevtime = Time[i];
        }
      PrevDayHiBuffer[i]    = PrevDayHi;
      PrevDayLoBuffer[i]    = PrevDayLo;
      PrevDayOpenBuffer[i]  = PrevDayOpen;
      PrevDayCloseBuffer[i] = PrevDayClose;
     }
// BUY
   if(counted_bars > 0)
     {
      if(Ask > LastClose)
         trend[0] = 1;
      if(Bid < LastClose)
         trend[0] = -1;
      if(trend[0] > 0)
        {
         fb  = PrevDayHi - (PrevDayHi - PrevDayLo) * 0.382;
         fe  = PrevDayHi - (PrevDayHi - PrevDayLo) * 0.618;
         tp1 = ((PrevDayHi - PrevDayLo) * 0.618) + fb;
         tp2 = (PrevDayHi - PrevDayLo) + fb;
         tp3 = 1.618 * (PrevDayHi - PrevDayLo) + fb;
         ri  = MathRound((fb  - fe) * 10000) / 10000;
         re1 = MathRound((tp1 - fb) * 10000) / 10000;
         re2 = MathRound((tp2 - fb) * 10000) / 10000;
         re3 = MathRound((tp3 - fb) * 10000) / 10000;
         if(ri > 0)
           {
            ra1 = MathRound((re1 / ri) * 10) / 10;
            ra2 = MathRound((re2 / ri) * 10) / 10;
            ra3 = MathRound((re3 / ri) * 10) / 10;
           }
         //----
         if(ObjectFind("fs") == 0)
            ObjectDelete("fs");
         if(ObjectFind("fs Line") == 0)
            ObjectDelete("fs Line");
         if(ObjectFind("fb") != 0)
           {
            ObjectCreate("fb", OBJ_TEXT, 0, Time[0], fb);
            ObjectSetText("fb", " BUY LEVEL", FontSize, FontName);
            ObjectSet("fb", OBJPROP_COLOR, TextColor);
           }
         else
           {
            ObjectMove("fb", 0, Time[0], fb);
           }
         //----
         if(ObjectFind("fb Line") != 0)
           {
            ObjectCreate("fb Line", OBJ_HLINE, 0, Time[0], fb);
            ObjectSet("fb Line", OBJPROP_STYLE, BuyLevelStyle);
            ObjectSet("fb Line", OBJPROP_COLOR, BuyLevelColor);
            ObjectSet("fb Line", OBJPROP_WIDTH, BuyLevelWidth);
           }
         else
           {
            ObjectMove("fb Line", 0, Time[0], fb);
           }
         //----
         if(ra1 > MinRewardRatio)
            //            if (DisplayComments)
            Comment(
               //"Owner : ", AccountName()," Account number : ", AccountNumber(),
               "\n\nPrevDayHi ", PrevDayHi, "\nPrevDayLo ", PrevDayLo, "\nTrend was UP ",
               "\nBUY @ ", fb, "\nStopLoss ", fe, "\nTakeProfit 1 ", tp1,
               " Risk/Reward Ratio : ", ra1, " OK Trade ", "\nTakeProfit 2 ", tp2,
               " Risk/Reward Ratio : ", ra2, " OK Trade ", "\nTakeProfit 3 ", tp3,
               " Risk/Reward Ratio : ", ra3, " OK Trade ");
         else
            //            if (DisplayComments)
            Comment(
               //"Owner : ", AccountName()," Account number : ", AccountNumber(),
               "\n\nPrevDayHi ", PrevDayHi, "\nPrevDayLo ", PrevDayLo, "\nTrend was UP ",
               "\nBUY @ ", fb, "\nStopLoss ", fe, "\nTakeProfit 1 ", tp1,
               " Risk/Reward Ratio : ", ra1, " NO TRADE ", "\nTakeProfit 2 ", tp2,
               " Risk/Reward Ratio : ", ra2, " NO TRADE ", "\nTakeProfit 3 ", tp3,
               " Risk/Reward Ratio : ", ra3, " NO TRADE ");
        }
      // SELL
      if(trend[0] < 0)
        {
         fs  = (PrevDayHi - PrevDayLo) * 0.382 + (PrevDayLo);
         fe  = (PrevDayHi - PrevDayLo) * 0.618 + (PrevDayLo);
         tp1 = ((PrevDayLo - PrevDayHi) * 0.618) + fs;
         tp2 = (PrevDayLo - PrevDayHi) + fs;
         tp3 = 1.618 * (PrevDayLo - PrevDayHi) + fs;
         ri  = MathRound((fs  - fe) * 10000) / 10000;
         re1 = MathRound((tp1 - fs) * 10000) / 10000;
         re2 = MathRound((tp2 - fs) * 10000) / 10000;
         re3 = MathRound((tp3 - fs) * 10000) / 10000;
         if(ri > 0)
           {
            ra1 = MathRound((re1 / ri) * 10) / 10;
            ra2 = MathRound((re2 / ri) * 10) / 10;
            ra3 = ((re3 / ri) * 10) / 10;
           }
         //----
         if(ObjectFind("fb") == 0)
            ObjectDelete("fb");
         if(ObjectFind("fb Line") == 0)
            ObjectDelete("fb Line");
         if(ObjectFind("fs") != 0)
           {
            ObjectCreate("fs", OBJ_TEXT, 0, Time[0], fs);
            ObjectSetText("fs", " SELL LEVEL", FontSize, FontName);
            ObjectSet("fs", OBJPROP_COLOR, TextColor);
           }
         else
           {
            ObjectMove("fs", 0, Time[0], fs);
           }
         //----
         if(ObjectFind("fs Line") != 0)
           {
            ObjectCreate("fs Line", OBJ_HLINE, 0, Time[0], fs);
            ObjectSet("fs Line", OBJPROP_COLOR, SellLevelColor);
            ObjectSet("fs Line", OBJPROP_STYLE, SellLevelStyle);
            ObjectSet("fs Line", OBJPROP_WIDTH, SellLevelWidth);
           }
         else
           {
            ObjectMove("fs Line", 0, Time[0], fs);
           }
         //----
         if(ra1 > MinRewardRatio)
            //            if (DisplayComments)
            Comment(
               //"Owner : ", AccountName(),"Account number : ", AccountNumber(),
               "\n\nPrevDayHi ", PrevDayHi, "\nPrevDayLo ", PrevDayLo, "\nTrend was Down ",
               "\nSELL @ ", fs, "\nStopLoss ", fe, "\nTakeProfit 1 ", tp1,
               " Risk/Reward Ratio : ", ra1, " OK Trade ", "\nTakeProfit 2 ", tp2,
               " Risk/Reward Ratio : ", ra2, " OK Trade ", "\nTakeProfit 3 ", tp3,
               " Risk/Reward Ratio : ", ra3, " OK Trade ");
         else
            //            if (DisplayComments)
            Comment(
               //"Owner : ", AccountName(),"Account number : ", AccountNumber(),
               "\n\nPrevDayHi ", PrevDayHi, "\nPrevDayLo ", PrevDayLo, "\nTrend was Down ",
               "\nSELL @ ", fs, "\nStopLoss ", fe, "\nTakeProfit 1 ", tp1,
               " Risk/Reward Ratio : ", ra1, " NO TRADE ", "\nTakeProfit 2 ", tp2,
               " Risk/Reward Ratio : ", ra2, " NO TRADE ", "\nTakeProfit 3 ", tp3,
               " Risk/Reward Ratio : ", ra3, " NO TRADE ");
         prevtrend = trend[0];
        }
      //----
      if(prevtgttime != Time[0] || prevfs != fs || prevfb != fb)
        {
         if(ObjectFind("fe") != 0)
           {
            ObjectCreate("fe", OBJ_TEXT, 0, Time[0], fe);
            ObjectSetText("fe", " STOPLOSS LEVEL", FontSize, FontName);
            ObjectSet("fe", OBJPROP_COLOR, TextColor);
           }
         else
           {
            ObjectMove("fe", 0, Time[0], fe);
           }
         //----
         if(ObjectFind("fe Line") != 0)
           {
            ObjectCreate("fe Line", OBJ_HLINE, 0, Time[0], fe);
            ObjectSet("fe Line", OBJPROP_COLOR, StopLossColor);
            ObjectSet("fe Line", OBJPROP_STYLE, StopLossStyle);
            ObjectSet("fe Line", OBJPROP_WIDTH, StopLossWidth);
           }
         else
           {
            ObjectMove("fe Line", 0, Time[0], fe);
           }
         //----
         if(ObjectFind("tp1") != 0)
           {
            ObjectCreate("tp1", OBJ_TEXT, 0, Time[0], tp1);
            ObjectSetText("tp1", " PROFIT TARGET 1", FontSize, FontName);
            ObjectSet("tp1", OBJPROP_COLOR, TextColor);
           }
         else
           {
            ObjectMove("tp1", 0, Time[0], tp1);
           }
         //----
         if(ObjectFind("tp1 Line") != 0)
           {
            ObjectCreate("tp1 Line", OBJ_HLINE, 0, Time[0], tp1);
            ObjectSet("tp1 Line", OBJPROP_COLOR, TakeProfitColor1);
            ObjectSet("tp1 Line", OBJPROP_STYLE, TakeProfitStyle1);
            ObjectSet("tp1 Line", OBJPROP_WIDTH, TakeProfitWidth1);
           }
         else
           {
            ObjectMove("tp1 Line", 0, Time[0], tp1);
           }
         //----
         if(ObjectFind("tp2") != 0)
           {
            ObjectCreate("tp2", OBJ_TEXT, 0, Time[0], tp2);
            ObjectSetText("tp2", " PROFIT TARGET 2", FontSize, FontName);
            ObjectSet("tp2", OBJPROP_COLOR, TextColor);
           }
         else
           {
            ObjectMove("tp2", 0, Time[0], tp2);
           }
         if(ObjectFind("tp2 Line") != 0)
           {
            ObjectCreate("tp2 Line", OBJ_HLINE, 0, Time[0], tp2);
            ObjectSet("tp2 Line", OBJPROP_COLOR, TakeProfitColor2);
            ObjectSet("tp2 Line", OBJPROP_STYLE, TakeProfitStyle2);
            ObjectSet("tp2 Line", OBJPROP_WIDTH, TakeProfitWidth2);
           }
         else
           {
            ObjectMove("tp2 Line", 0, Time[0], tp2);
           }
         //----
         if(ObjectFind("tp3") != 0)
           {
            ObjectCreate("tp3", OBJ_TEXT, 0, Time[0], tp3);
            ObjectSetText("tp3", " PROFIT TARGET 3", FontSize, FontName);
            ObjectSet("tp3", OBJPROP_COLOR, TextColor);
           }
         else
           {
            ObjectMove("tp3", 0, Time[0], tp3);
           }
         //----
         if(ObjectFind("tp3 Line") != 0)
           {
            ObjectCreate("tp3 Line", OBJ_HLINE, 0, Time[0], tp3);
            ObjectSet("tp3 Line", OBJPROP_COLOR, TakeProfitColor3);
            ObjectSet("tp3 Line", OBJPROP_STYLE, TakeProfitStyle3);
            ObjectSet("tp3 Line", OBJPROP_WIDTH, TakeProfitWidth3);
           }
         else
           {
            ObjectMove("tp3 Line", 0, Time[0], tp3);
           }
         prevfb = fb;
         prevfs = fs;
         prevtgttime = Time[0];
        }
     }
//----
   if(show_data)
     {
      prevtgttime = Time[Bars];
      for(int banzai = 0; banzai < 4; banzai++)
         SetIndexStyle(banzai, DRAW_LINE);
      start2();
      
     }
   else
     {
      for(banzai = 0; banzai < 4; banzai++)
         SetIndexStyle(banzai, DRAW_NONE);
      ObjectDelete("PrevDayHi");
      ObjectDelete("PrevDayLo");
      ObjectDelete("PrevDayOpen");
      ObjectDelete("PrevDayClose");
      ObjectDelete("fe");
      ObjectDelete("fe Line");
      ObjectDelete("fs");
      ObjectDelete("fs Line");
      ObjectDelete("tp3");
      ObjectDelete("tp3 Line");
      ObjectDelete("tp2");
      ObjectDelete("tp2 Line");
      ObjectDelete("tp1");
      ObjectDelete("tp1 Line");
      ObjectDelete("fb");
      ObjectDelete("fb Line");
      ObjectsDeleteAll(0, "fbc_");
      Comment("");
     }
   
   
   return 0;
  }
//+------------------------------------------------------------------+
void setLabel(int dir, int bar, double val)
  {
   string name = "fbc_" + (string)dir + "_" + (string)bar;
   string value;
   if(dir == 1)
      value = "PDH@" + DoubleToString(val, Digits);
   else
      value = "PDL@" + DoubleToString(val, Digits);
   ObjectCreate(name, OBJ_TEXT, 0, 0, 0);
   ObjectSetText(name, value, FontSize2, FontName2);
   ObjectSet(name, OBJPROP_COLOR, TextColor2);
   if(dir == 1)
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
   else
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
   ObjectMove(name, 0, Time[bar], val);
  }
//+------------------------------------------------------------------+
