// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71859

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
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 11

// DEMA
#property indicator_color9 Red
#property indicator_width9 1
extern int PERIOD = 12;  // DEMA periods:

// COMFIRMATIONS
// ------------------------------------------------------------------
double confirBuy[];
double confirSell[];
//--- ARROWS
#property indicator_label10 "Buy Confimation"
#property indicator_type10  DRAW_ARROW
#property indicator_color10 Blue
#property indicator_label11 "Sell Confirmation"
#property indicator_type11  DRAW_ARROW
#property indicator_color11 Orange

// ------------------------------------------------------------------
enum _TARGET_PRICE_MODE {
   TARGET_PERCENTAGE,  // PERCENTAGE
   TARGET_POINTS       // POINTS
};
enum _STOP_PRICE_MODE {
   STOP_PERCENTAGE,  // PERCENTAGE
   STOP_POINTS,      // POINTS
   STOP_SUPERTREND,  // SUPERTREND
};
// ------------------------------------------------------------------
input int                Nbr_Periods       = 10;                 // ST Periods
input double             Multiplier        = 3.0;                // ST Multiplier
extern double            EntryBuffer       = 10;                 // Entry Buffer in Points
input bool               IsTarget          = false;              // Target ON/OFF
input _TARGET_PRICE_MODE TARGET_PRICE_MODE = TARGET_PERCENTAGE;  // Target Type (POINTS/PERCENTAGE)
extern double            Target            = 5;                  // Target in (Points/Percentage)
input bool               IsStop            = false;              // Stoploss ON/OFF
input _STOP_PRICE_MODE   STOP_PRICE_MODE   = STOP_SUPERTREND;    // Stoploss Type (POINTS/PERCENTAGE/SUPERTREND)
extern double            Stop              = 50;                 // Stop in (Points/Percentage)
input bool               IsTrailingSl      = false;              // Trailing SL ON/OFF
extern double            TrailingSl        = 25;                 // Trailing SL in Points
extern int               Qty               = 1;
input double             confirmPer        = 0.1;  // Percent to Confirm Entry %:
// ------------------------------------------------------------------
string   ObjName = "Karthikeyan";
double   BuyArrow[];
double   SellArrow[];
double   TPArrow[];
double   SLArrow[];
string   LastSignal     = "WAITING";
bool     LastTradeOpen  = false;
datetime LastTradeTime  = 0;
datetime LastTrendTime  = 0;
double   LastEntry      = 0;
double   LastStop       = 0;
double   LastTarget     = 0;
double   BuyCheckPrice  = 0;
double   SellCheckPrice = 0;
bool     FirstTrade     = false;
bool     FirstTick      = true;
double   TrendUp[], TrendDown[];
double   Upper[], Lower[];
double   dema[];
string   SuperTrendSignal = "";
// ------------------------------------------------------------------

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- indicator buffers mapping

   IndicatorBuffers(11);

   SetIndexBuffer(0, BuyArrow);
   SetIndexArrow(0, 233);
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 3, clrLime);

   SetIndexBuffer(1, SellArrow);
   SetIndexArrow(1, 234);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 3, clrRed);

   SetIndexBuffer(2, TPArrow);
   SetIndexArrow(2, 252);
   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 1, clrYellow);

   SetIndexBuffer(3, SLArrow);
   SetIndexArrow(3, 251);
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 1, clrPink);

   SetIndexBuffer(4, TrendUp);
   SetIndexArrow(4, 159);
   SetIndexStyle(4, DRAW_ARROW, STYLE_SOLID, 1, clrLime);

   SetIndexBuffer(5, TrendDown);
   SetIndexArrow(5, 159);
   SetIndexStyle(5, DRAW_ARROW, STYLE_SOLID, 1, clrRed);

   // SetIndexBuffer(4,TrendUp);
   // SetIndexBuffer(5,TrendDown);

   SetIndexBuffer(6, Upper);
   SetIndexBuffer(7, Lower);

   SetIndexBuffer(8, dema);
   SetIndexStyle(8, DRAW_LINE);

   SetIndexBuffer(9, confirBuy);
   SetIndexArrow(9, 233);
   SetIndexStyle(9, DRAW_ARROW, STYLE_SOLID, 3, clrBlue);

   SetIndexBuffer(10, confirSell);
   SetIndexArrow(10, 234);
   SetIndexStyle(10, DRAW_ARROW, STYLE_SOLID, 3, clrOrange);

   if (_Digits > 0)
   {
      EntryBuffer *= 100;

      TrailingSl *= 100;

      if (TARGET_PRICE_MODE == TARGET_POINTS)
         Target *= 100;

      if (STOP_PRICE_MODE == STOP_POINTS)
         Stop *= 100;
   }
   //---
   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
   calculateDema();

   //---
   int    limit, i;
   double medianPrice, atr;
   limit = rates_total - prev_calculated;
   if (FirstTick)
   {
      ResetVariables();

      i = Bars - 4;

      atr          = iATR(NULL, 0, Nbr_Periods, i);
      medianPrice  = (High[i] + Low[i]) / 2;
      TrendUp[i]   = medianPrice + (Multiplier * atr);
      TrendDown[i] = medianPrice - (Multiplier * atr);

      limit = Bars - 5;
   } else
   {
      limit = 1;
   }

   datetime Today  = TimeLocal() - (TimeLocal() % (PERIOD_D1 * 60));
   datetime ToDate = Today + (365 * 24 * 60 * 60);

   for (i = limit; i >= 0; i--)
   {
      if (i >= 0)
      {
         TrendUp[i]   = TrendUp[i + 1];
         TrendDown[i] = TrendDown[i + 1];
         atr          = iATR(NULL, 0, Nbr_Periods, i);
         medianPrice  = (High[i] + Low[i]) / 2;
         Upper[i]     = medianPrice + (Multiplier * atr);
         Lower[i]     = medianPrice - (Multiplier * atr);

         if (TrendDown[i + 1] != EMPTY_VALUE)
         {
            if (Close[i] > TrendDown[i + 1])
            {
               TrendDown[i] = EMPTY_VALUE;
               TrendUp[i]   = Lower[i];
            }
            if (Upper[i] < TrendDown[i + 1])
            {
               TrendDown[i] = Upper[i];
            }
         } else if (TrendUp[i + 1] != EMPTY_VALUE)
         {
            if (Close[i] < TrendUp[i + 1])
            {
               TrendUp[i]   = EMPTY_VALUE;
               TrendDown[i] = Upper[i];
            }
            if (Lower[i] > TrendUp[i + 1])
            {
               TrendUp[i] = Lower[i];
            }
         }

         if (TrendUp[i] != EMPTY_VALUE && TrendUp[i + 1] == EMPTY_VALUE)
         {
            LastTrendTime  = Time[i];
            BuyCheckPrice  = High[i] + EntryBuffer * _Point;
            SellCheckPrice = 0;

            BuyCheckPrice = NormalizeDouble(BuyCheckPrice, _Digits);

            SuperTrendSignal = "BUY";

            // Print("buy at="+Time[i]+",BuyCheckPrice="+BuyCheckPrice+",SellCheckPrice="+SellCheckPrice);
         } else if (TrendDown[i] != EMPTY_VALUE && TrendDown[i + 1] == EMPTY_VALUE)
         {
            LastTrendTime  = Time[i];
            SellCheckPrice = Low[i] - EntryBuffer * _Point;
            BuyCheckPrice  = 0;

            SellCheckPrice = NormalizeDouble(SellCheckPrice, _Digits);

            SuperTrendSignal = "SELL";

            // Print("sell at="+Time[i]+",BuyCheckPrice="+BuyCheckPrice+",SellCheckPrice="+SellCheckPrice);
         }

         if (IsStop)
         {
            if (STOP_PRICE_MODE == STOP_SUPERTREND)
            {
               if (LastTradeOpen)
               {
                  if (LastSignal == "BUY")
                  {
                     LastStop = NormalizeDouble(TrendUp[i], _Digits);
                  } else
                  {
                     LastStop = NormalizeDouble(TrendDown[i], _Digits);
                  }
               }
            }
         }
      }

      if (Time[i] > LastTrendTime && ((FirstTick && i >= 0) || ((!FirstTick) && i == 0)))
      {
         if (LastTradeOpen)
         {
            if (IsTrailingSl && (LastStop != LastEntry))
            {
               if (LastSignal == "BUY")
               {
                  double check_price = LastEntry + TrailingSl * _Point;

                  if (((i == 0 && Bid >= check_price) || (i > 0 && ((Close[i] >= check_price) || (check_price >= Low[i] && check_price <= High[i])))) && (check_price > 0))
                  {
                     LastStop = LastEntry;

                     delObj("StopLine");
                     CreateTrendLine("StopLine", LastTrendTime, DoubleToString(LastStop, _Digits), ToDate, DoubleToString(LastStop, _Digits), clrRed);

                     Print("BUY TRAILING at=" + TimeToString(Time[i], TIME_DATE | TIME_MINUTES));
                  }
               } else
               {
                  double check_price = LastEntry - TrailingSl * _Point;

                  if (((i == 0 && Bid <= check_price) || (i > 0 && ((Close[i] <= check_price) || (check_price >= Low[i] && check_price <= High[i])))) && (check_price > 0))
                  {
                     LastStop = LastEntry;

                     delObj("StopLine");
                     CreateTrendLine("StopLine", LastTrendTime, DoubleToString(LastStop, _Digits), ToDate, DoubleToString(LastStop, _Digits), clrRed);

                     Print("SELL TRAILING at=" + TimeToString(Time[i], TIME_DATE | TIME_MINUTES));
                  }
               }
            }

            if ((LastSignal == "BUY") && ((i == 0 && Bid >= LastTarget) || (i > 0 && ((Close[i] >= LastTarget) || (LastTarget >= Low[i] && LastTarget <= High[i])))) && (LastTarget > 0))
            {
               LastTradeOpen = false;

               TPArrow[i] = High[i] + iATR(NULL, 0, 15, i) * 0.5;

               delObj("Line");

               Print("BUY TP at=" + TimeToString(Time[i], TIME_DATE | TIME_MINUTES));
            } else if ((LastSignal == "BUY") && ((i == 0 && Bid <= LastStop) || (i > 0 && ((Close[i] <= LastStop) || (LastStop >= Low[i] && LastStop <= High[i])))) && (LastStop > 0))
            {
               LastTradeOpen = false;

               SLArrow[i] = Low[i] - iATR(NULL, 0, 15, i) * 0.5;

               delObj("Line");

               Print("BUY SL at=" + TimeToString(Time[i], TIME_DATE | TIME_MINUTES));

            } else if ((LastSignal == "SELL") && ((i == 0 && Bid <= LastTarget) || (i > 0 && ((Close[i] <= LastTarget) || (LastTarget >= Low[i] && LastTarget <= High[i])))) && (LastTarget > 0))
            {
               LastTradeOpen = false;

               TPArrow[i] = Low[i] - iATR(NULL, 0, 15, i) * 0.5;

               delObj("Line");

               Print("SELL TP at=" + TimeToString(Time[i], TIME_DATE | TIME_MINUTES));

            } else if ((LastSignal == "SELL") && ((i == 0 && Bid >= LastStop) || (i > 0 && ((Close[i] >= LastStop) || (LastStop >= Low[i] && LastStop <= High[i])))) && (LastStop > 0))
            {
               LastTradeOpen = false;

               SLArrow[i] = High[i] + iATR(NULL, 0, 15, i) * 0.5;

               delObj("Line");

               Print("SELL SL at=" + TimeToString(Time[i], TIME_DATE | TIME_MINUTES));
            }
         }

         bool BuyValid  = false;
         bool SellValid = false;

         if (((i == 0 && Bid >= BuyCheckPrice) || (i > 0 && ((Close[i] >= BuyCheckPrice) || (BuyCheckPrice >= Low[i] && BuyCheckPrice <= High[i])))) && (BuyCheckPrice > 0))
         {
            BuyValid = true;
         }

         if (((i == 0 && Bid <= SellCheckPrice) || (i > 0 && ((Close[i] <= SellCheckPrice) || (SellCheckPrice >= Low[i] && SellCheckPrice <= High[i])))) && (SellCheckPrice > 0))
         {
            SellValid = true;
         }

         //         if(BuyCheckPrice>0 && Time[i+1]>=LastTrendTime)
         //           {
         //            BuyCheckPrice = High[i+1]+EntryBuffer*_Point;
         //            BuyCheckPrice=NormalizeDouble(BuyCheckPrice,_Digits);
         //           }
         //
         //         if(SellCheckPrice>0 && Time[i+1]>=LastTrendTime)
         //           {
         //            SellCheckPrice = Low[i+1]-EntryBuffer*_Point;
         //            SellCheckPrice=NormalizeDouble(SellCheckPrice,_Digits);
         //           }
         //
         //         if(SuperTrendSignal=="BUY" &&((i==0 && Bid>=BuyCheckPrice)||(i>0 && ((Close[i]>=BuyCheckPrice) || (BuyCheckPrice>=Low[i] && BuyCheckPrice<=High[i])))) &&(BuyCheckPrice>0))
         //           {
         //            BuyValid=true;
         //           }
         //
         //         if(SuperTrendSignal=="SELL" &&((i==0 && Bid<=SellCheckPrice)||(i>0 && ((Close[i]<=SellCheckPrice) || (SellCheckPrice>=Low[i] && SellCheckPrice<=High[i])))) &&(SellCheckPrice>0))
         //           {
         //            SellValid=true;
         //           }

         if (BuyValid)
         {
            if (LastSignal == "BUY" && LastTradeOpen)
            {
               BuyValid = false;
            }
            if (BuyValid)
            {
               if (LastTradeOpen)
               {
                  LastTradeOpen = false;

                  delObj("Line");

                  Print("SELL REVERSE CLOSE at=" + TimeToString(Time[i], TIME_DATE | TIME_MINUTES));
               }

               BuyArrow[i] = Low[i] - iATR(NULL, 0, 15, i) * 0.5;

               LastTradeTime = Time[i];

               LastSignal    = "BUY";
               LastTradeOpen = true;
               LastEntry     = 0;
               LastStop      = 0;
               LastTarget    = 0;

               LastEntry = BuyCheckPrice;

               if (IsTarget)
               {
                  if (TARGET_PRICE_MODE == TARGET_POINTS)
                     LastTarget = LastEntry + Target * _Point;

                  else if (TARGET_PRICE_MODE == TARGET_PERCENTAGE)
                     LastTarget = LastEntry + LastEntry * Target / 100;
               }

               if (IsStop)
               {
                  if (STOP_PRICE_MODE == STOP_POINTS)
                     LastStop = LastEntry - Stop * _Point;

                  else if (STOP_PRICE_MODE == STOP_PERCENTAGE)
                     LastStop = LastEntry - LastEntry * Stop / 100;
                  else if (STOP_PRICE_MODE == STOP_SUPERTREND)
                     LastStop = TrendUp[i];
               }

               LastEntry  = NormalizeDouble(LastEntry, _Digits);
               LastTarget = NormalizeDouble(LastTarget, _Digits);
               LastStop   = NormalizeDouble(LastStop, _Digits);

               delObj("Line");
               CreateTrendLine("EntryLine", Time[i], DoubleToString(LastEntry, _Digits), ToDate, DoubleToString(LastEntry, _Digits), clrYellow);
               CreateTrendLine("TargetLine", Time[i], DoubleToString(LastTarget, _Digits), ToDate, DoubleToString(LastTarget, _Digits), clrLime);
               CreateTrendLine("StopLine", Time[i], DoubleToString(LastStop, _Digits), ToDate, DoubleToString(LastStop, _Digits), clrRed);

               BuyCheckPrice = 0;

               Print("BUY at=" + TimeToString(Time[i], TIME_DATE | TIME_MINUTES) + ",Entry=" + LastEntry + ",Stop=" + LastStop + ",Target=" + LastTarget);
            }
         }

         if (SellValid)
         {
            if (LastSignal == "SELL" && LastTradeOpen)
            {
               SellValid = false;
            }
            if (SellValid)
            {
               if (LastTradeOpen)
               {
                  LastTradeOpen = false;

                  delObj("Line");

                  Print("BUY REVERSE CLOSE at=" + TimeToString(Time[i], TIME_DATE | TIME_MINUTES));
               }

               SellArrow[i] = High[i] + iATR(NULL, 0, 15, i) * 0.5;

               LastTradeTime = Time[i];

               LastSignal    = "SELL";
               LastTradeOpen = true;
               LastEntry     = 0;
               LastStop      = 0;
               LastTarget    = 0;

               LastEntry = SellCheckPrice;

               if (IsTarget)
               {
                  if (TARGET_PRICE_MODE == TARGET_POINTS)
                     LastTarget = LastEntry - Target * _Point;

                  else if (TARGET_PRICE_MODE == TARGET_PERCENTAGE)
                     LastTarget = LastEntry - LastEntry * Target / 100;
               }

               if (IsStop)
               {
                  if (STOP_PRICE_MODE == STOP_POINTS)
                     LastStop = LastEntry + Stop * _Point;

                  else if (STOP_PRICE_MODE == STOP_PERCENTAGE)
                     LastStop = LastEntry + LastEntry * Stop / 100;
                  else if (STOP_PRICE_MODE == STOP_SUPERTREND)
                     LastStop = TrendDown[i];
               }

               LastEntry  = NormalizeDouble(LastEntry, _Digits);
               LastTarget = NormalizeDouble(LastTarget, _Digits);
               LastStop   = NormalizeDouble(LastStop, _Digits);

               delObj("Line");
               CreateTrendLine("EntryLine", Time[i], DoubleToString(LastEntry, _Digits), ToDate, DoubleToString(LastEntry, _Digits), clrYellow);
               CreateTrendLine("TargetLine", Time[i], DoubleToString(LastTarget, _Digits), ToDate, DoubleToString(LastTarget, _Digits), clrLime);
               CreateTrendLine("StopLine", Time[i], DoubleToString(LastStop, _Digits), ToDate, DoubleToString(LastStop, _Digits), clrRed);

               SellCheckPrice = 0;

               Print("SELL at=" + TimeToString(Time[i], TIME_DATE | TIME_MINUTES) + ",Entry=" + LastEntry + ",Stop=" + LastStop + ",Target=" + LastTarget);
            }
         }
      }

      int signalBar = iBarShift(NULL, 0, LastTradeTime);
      if (LastSignal == "BUY" && LastTradeOpen == true)
      {
         confirmationLastSignal(signalBar);
      }
      if (LastSignal == "SELL" && LastTradeOpen == true)
      {
         confirmationLastSignal(signalBar);
      }
   }

   FirstTick = false;
   Dashboard();

   //--- return value of prev_calculated for next call
   return (rates_total);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   FirstTick = true;
   delObj(ObjName);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dashboard()
{
   string signal    = "Waiting";
   color  signalClr = clrWhite;
   if (LastSignal == "BUY")
   {
      signal    = "BUY";
      signalClr = clrGreen;
   } else if (LastSignal == "SELL")
   {
      signal    = "SELL";
      signalClr = clrRed;
   }

   if (!LastTradeOpen)
      signalClr = clrWhite;

   CreateText("SignalKey", 15, 30, "SIGNAL :", 8, clrWhite, "Arial Bold", CORNER_LEFT_UPPER);
   CreateText("SignalValue", 100, 30, (LastTradeOpen) ? signal : "Waiting", 8, signalClr, "Arial Bold", CORNER_LEFT_UPPER);

   CreateText("EntryKey", 15, 60, "ENTRY :", 8, clrWhite, "Arial Bold", CORNER_LEFT_UPPER);
   CreateText("EntryValue", 100, 60, (LastTradeOpen) ? LastEntry : 0, 8, clrWhite, "Arial Bold", CORNER_LEFT_UPPER);

   CreateText("TargetKey", 15, 90, "TARGET :", 8, clrWhite, "Arial Bold", CORNER_LEFT_UPPER);
   CreateText("TargetValue", 100, 90, (LastTradeOpen) ? LastTarget : 0, 8, clrWhite, "Arial Bold", CORNER_LEFT_UPPER);

   CreateText("StopKey", 15, 120, "STOP :", 8, clrWhite, "Arial Bold", CORNER_LEFT_UPPER);
   CreateText("StopValue", 100, 120, (LastTradeOpen) ? LastStop : 0, 8, clrWhite, "Arial Bold", CORNER_LEFT_UPPER);

   CreateText("StatusKey", 15, 150, "STATUS :", 8, clrWhite, "Arial Bold", CORNER_LEFT_UPPER);
   CreateText("StatusValue", 100, 150, (LastTradeOpen) ? "OPEN" : "CLOSED", 8, clrWhite, "Arial Bold", CORNER_LEFT_UPPER);

   CreateText("QtyKey", 15, 180, "QTY :", 8, clrWhite, "Arial Bold", CORNER_LEFT_UPPER);
   CreateText("QtyValue", 100, 180, Qty, 8, clrWhite, "Arial Bold", CORNER_LEFT_UPPER);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateText(string name, int x, int y, string text, int fontsize, color clr, string font, int corner)
{
   name = ObjName + "OBJ_LABEL" + name;

   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   //--- set label coordinates
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);

   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
   //--- set the text
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   //--- set text font
   ObjectSetString(0, name, OBJPROP_FONT, font);
   //--- set font size
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontsize);
   //--- set color
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   //--- display in the foreground (false) or background (true)
   //--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   //--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   //--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetString(0, name, OBJPROP_TOOLTIP, "\n");
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateTrendLine(string name, datetime FromDate, double FromPrice, datetime ToDate, double ToPrice, color clr)
{
   name = ObjName + "_" + name;
   ObjectCreate(0, name, OBJ_TREND, 0, FromDate, FromPrice, ToDate, ToPrice);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_RAY, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, "\n");
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetVariables()
{
   LastSignal    = "WAITING";
   LastTradeOpen = false;
   LastTradeTime = 0;
   LastTrendTime = 0;

   LastEntry  = 0;
   LastStop   = 0;
   LastTarget = 0;

   BuyCheckPrice  = 0;
   SellCheckPrice = 0;

   SuperTrendSignal = "";

   ArrayInitialize(BuyArrow, EMPTY_VALUE);
   ArrayInitialize(SellArrow, EMPTY_VALUE);
   ArrayInitialize(TPArrow, EMPTY_VALUE);
   ArrayInitialize(SLArrow, EMPTY_VALUE);

   ArrayInitialize(TrendUp, EMPTY_VALUE);
   ArrayInitialize(TrendDown, EMPTY_VALUE);
   ArrayInitialize(Upper, EMPTY_VALUE);
   ArrayInitialize(Lower, EMPTY_VALUE);
}
//+------------------------------------------------------------------+
void delObj(string name)
{
   int i;
   int totalObj = ObjectsTotal();
   for (i = totalObj - 1; i >= 0; i--)
   {
      if (StringFind(ObjectName(i), name, 0) >= 0)
         ObjectDelete(ObjectName(i));
   }
}
//+------------------------------------------------------------------+

void calculateDema()
{
   int limit = Bars - 1 - IndicatorCounted();
   //----
   static double lastEMA, lastEMA_of_EMA;
   double        weight = 2.0 / (1.0 + PERIOD);
   if (IndicatorCounted() == 0)
   {
      dema[limit]    = Close[limit];
      lastEMA        = Close[limit];
      lastEMA_of_EMA = Close[limit];
      limit--;
   }
   //----
   //	Calculate old bars (not the latest), if necessary
   for (int i = limit; i > 0; i--)
   {
      lastEMA        = weight * Close[i] + (1.0 - weight) * lastEMA;
      lastEMA_of_EMA = weight * lastEMA + (1.0 - weight) * lastEMA_of_EMA;
      dema[i]        = 2.0 * lastEMA - lastEMA_of_EMA;
   }
   //----
   //	(Re)calculate current bar
   double EMA        = weight * Close[0] + (1.0 - weight) * lastEMA,
          EMA_of_EMA = weight * EMA + (1.0 - weight) * lastEMA_of_EMA;
   dema[0]           = 2.0 * EMA - EMA_of_EMA;
   //----
   // return(0);
}

void confirmationLastSignal(int signalCandle)
{
   datetime Today  = TimeLocal() - (TimeLocal() % (PERIOD_D1 * 60));
   datetime ToDate = Today + (365 * 24 * 60 * 60);

   if (LastSignal == "BUY" && LastTradeOpen == true)
   {
      int    lastConfirmCandle = 0;
      double lastConfir        = EMPTY_VALUE;
      while (lastConfir == EMPTY_VALUE && lastConfirmCandle <= signalCandle+1)
      {
         lastConfir = confirBuy[lastConfirmCandle];
         lastConfirmCandle++;
      }

      if (lastConfir == EMPTY_VALUE)
      {
         double percent      = (100 - confirmPer) / 100;
         double confirmation = NormalizeDouble((LastEntry * percent), _Digits);

         if (dema[1] <= confirmation)
         {
            confirBuy[1] = confirmation;
         }
      }
   }
   
   if (LastSignal == "SELL" && LastTradeOpen == true)
   {
      int    lastConfirmCandle = 0;
      double lastConfir        = EMPTY_VALUE;
      while (lastConfir == EMPTY_VALUE && lastConfirmCandle <= signalCandle+1)
      {
         lastConfir = confirSell[lastConfirmCandle];
         lastConfirmCandle++;
      }

      if (lastConfir == EMPTY_VALUE)
      {
         double percent      = (100 + confirmPer) / 100;
         double confirmation = NormalizeDouble((LastEntry * percent), _Digits);

         Print(__FUNCTION__," ","percent"," ",percent);
         Print(__FUNCTION__," ","confirmation"," ",confirmation);
         Print(__FUNCTION__," ","LastEntry"," ",LastEntry);

         if (dema[1] >= confirmation)
         {
            confirSell[1] = confirmation;
            ObjectDelete("confirSELL");
            CreateTrendLine("confirSELL", confirmation, DoubleToString(confirmation, _Digits), ToDate, DoubleToString(confirmation, _Digits), clrRed);           
         }
      }
   }
}