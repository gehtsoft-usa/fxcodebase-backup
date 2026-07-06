// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70870


//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+
 

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.00"
#property strict
#property indicator_chart_window

#define OBJTP "labelTP"
#define OBJSL "labelSL"
#define OBJBE "labelBE"

input string fontName = "Arial Bold";

//////////////////////////////
input string slHeader = "------------------------------------------------------------------------------------"; //----- StopLoss label settings
input bool showSL = true;                                                                                       //Show SL label
input string slMsg = "SL : ";                                                                                   //Sl Label MSG
input color slColor = clrOrangeRed;                                                                             //SL label Color
input ENUM_BASE_CORNER slCorner = CORNER_RIGHT_UPPER;                                                           //SL Label Corner
input int slYDistance = 50;                                                                                     //SL label x
input int slXDistance = 0;                                                                                      //SL label y
input int slFont = 12;                                                                                          //SL label Font
                                                                                                                ///////////////////////////////
input string tpHeader = "------------------------------------------------------------------------------------"; //----- TakeProfit label settings
input bool showTP = true;                                                                                       //Show TP label
input string tpMsg = "TP : ";                                                                                   //TP Label MSG
input color tpColor = clrLimeGreen;                                                                             //TP label Color
input ENUM_BASE_CORNER tpCorner = CORNER_RIGHT_UPPER;                                                           //TP Label Corner
input int tpYDistance = 70;                                                                                     //TP label x
input int tpXDistance = 0;                                                                                      //TP label y
input int tpFont = 12;                                                                                          //TP label Font

input string beHeader = "------------------------------------------------------------------------------------"; //----- Away label settings
input bool showbe = true;                                                                                       //Show Away label
input color beColor = clrLimeGreen;                                                                             //Away label Color
input ENUM_BASE_CORNER beCorner = CORNER_RIGHT_UPPER;                                                           //Away Label Corner
input int beYDistance = 90;                                                                                     //Away label x
input int beXDistance = 0;                                                                                      //Away label y
input int beFont = 12;                                                                                          //Away label Font
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
////////////////////////////////
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
   EventSetTimer(1);
   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(OBJTP);
   ObjectDelete(OBJSL);
   ObjectDelete(OBJBE);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   return 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTP(double value)
{
   string s = tpMsg + "$" + (DoubleToString(value, 0));
   if (ObjectFind(OBJTP) < 0)
   {
      ObjectCreate(OBJTP, OBJ_LABEL, 0, 0, 0);
      ObjectSet(OBJTP, OBJPROP_CORNER, tpCorner);
      ObjectSet(OBJTP, OBJPROP_YDISTANCE, tpYDistance);
      ObjectSet(OBJTP, OBJPROP_XDISTANCE, tpXDistance);
      ObjectSet(OBJTP, OBJPROP_SELECTABLE, false);
      ObjectSetText(OBJTP, s, tpFont, fontName, tpColor);
   }
   ObjectSetText(OBJTP, s);
   ObjectSetInteger(0, OBJTP, OBJPROP_BACK, false);
   WindowRedraw();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSL(double value)
{
   string s = slMsg + "$" + (DoubleToString(value, 0));
   if (ObjectFind(OBJSL) < 0)
   {
      ObjectCreate(OBJSL, OBJ_LABEL, 0, 0, 0);
      ObjectSet(OBJSL, OBJPROP_CORNER, slCorner);
      ObjectSet(OBJSL, OBJPROP_YDISTANCE, slYDistance);
      ObjectSet(OBJSL, OBJPROP_XDISTANCE, slXDistance);
      ObjectSet(OBJSL, OBJPROP_SELECTABLE, false);
      ObjectSetText(OBJSL, s, slFont, fontName, slColor);
   }
   ObjectSetText(OBJSL, s);
   ObjectSetInteger(0, OBJSL, OBJPROP_BACK, false);

   WindowRedraw();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
{
   if (showTP)
   {
      getTakeProfitTotal();
   }
   if (showSL)
   {
      getStopLossTotal();
   }
   if (showbe)
   {
      drawBreakevenDistance();
   }
}
//+------------------------------------------------------------------+
void getTakeProfitTotal()
{
   double pTP = 0.0;
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderSymbol() == _Symbol)
         {
            if ((OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP) && OrderTakeProfit() > 0) // sell type order and TakeProfit is active
            {
               double tick_val = MarketInfo(_Symbol, MODE_TICKVALUE);            //GetTickValue
               double tp_dist = (OrderOpenPrice() - OrderTakeProfit()) / _Point; //CalcDistance
               double tp_val = (tp_dist * tick_val) * OrderLots();               //CalcValue
               pTP += tp_val;
            }

            if ((OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP) && OrderTakeProfit() > 0) //buy type order and TakeProfit is active
            {
               double tick_val = MarketInfo(_Symbol, MODE_TICKVALUE);            //GetTickValue
               double tp_dist = (OrderTakeProfit() - OrderOpenPrice()) / _Point; //CalcDistance
               double tp_val = (tp_dist * tick_val) * OrderLots();               //CalcValue
               pTP += tp_val;
            }
         }
      }
   }
   DrawTP(pTP);
}
void drawBreakevenDistance()
{
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double totalAmountB = 0.0;
   double totalPLB = 0.0;
   double totalAmountS = 0.0;
   double totalPLS = 0.0;
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderSymbol() == _Symbol)
         {
            if ((OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP) && OrderTakeProfit() > 0) // sell type order and TakeProfit is active
            {
               totalAmountS += OrderLots() / lotStep;
               totalPLS += (OrderOpenPrice() - Ask) * (OrderLots() / lotStep);
            }

            if ((OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP) && OrderTakeProfit() > 0) //buy type order and TakeProfit is active
            {
               totalAmountB += OrderLots() / lotStep;
               totalPLB += (Bid - OrderOpenPrice()) * (OrderLots() / lotStep);
            }
         }
      }
   }
   double point = MarketInfo(_Symbol, MODE_POINT);
   int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   double pipSize = point * mult;
   double bProfitShift = totalAmountB == 0 ? 0 : -(totalPLB / totalAmountB) / pipSize;
   double sProfitShift = totalAmountS == 0 ? 0 : -(totalPLS / totalAmountS) / pipSize;
   double away = MathAbs(bProfitShift - sProfitShift);

   string s = DoubleToString(away, 0) + " pips away from current price";
   if (ObjectFind(OBJBE) < 0)
   {
      ObjectCreate(OBJBE, OBJ_LABEL, 0, 0, 0);
      ObjectSet(OBJBE, OBJPROP_CORNER, beCorner);
      ObjectSet(OBJBE, OBJPROP_YDISTANCE, beYDistance);
      ObjectSet(OBJBE, OBJPROP_XDISTANCE, beXDistance);
      ObjectSet(OBJBE, OBJPROP_SELECTABLE, false);
      ObjectSetText(OBJBE, s, beFont, fontName, beColor);
   }
   ObjectSetText(OBJBE, s);
   ObjectSetInteger(0, OBJBE, OBJPROP_BACK, false);
   WindowRedraw();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getStopLossTotal()
{
   double pSL = 0.0;
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderSymbol() == _Symbol)
         {
            if ((OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP) && OrderStopLoss() > 0) // sell type order and TakeProfit is active
            {
               double tick_val = MarketInfo(_Symbol, MODE_TICKVALUE);          //GetTickValue
               double tp_dist = (OrderOpenPrice() - OrderStopLoss()) / _Point; //CalcDistance
               double tp_val = (tp_dist * tick_val) * OrderLots();             //CalcValue
               pSL += tp_val;
            }

            if ((OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP) && OrderStopLoss() > 0) //buy type order and TakeProfit is active
            {
               double tick_val = MarketInfo(_Symbol, MODE_TICKVALUE);          //GetTickValue
               double tp_dist = (OrderStopLoss() - OrderOpenPrice()) / _Point; //CalcDistance
               double tp_val = (tp_dist * tick_val) * OrderLots();             //CalcValue
               pSL += tp_val;
            }
         }
      }
   }
   DrawSL(pSL);
}
//+------------------------------------------------------------------+
