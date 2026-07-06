//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73948

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
//
enum closeAllBy
  {
   off = 0,             // Off
   pip = 1,             // Pip/point (as set in "Pip/Point Mode" setting)
   currency = 2,        // Deposit currency
   percentage = 3       // Percentage of the equity
  };
// Define trade condition parameters
int movingAveragePeriod = 11;  // Moving average period
double deviation = 0.001;      // Deviation from moving average for trade condition
double Lot = 0.1;              // Lot Size
double SlVal = 30;
double TpVal = 30;
int MagicNumber = 3535;
//
closeAllBy profit_target_mode = 2;     // Use Global Take Profit by
double profit_target =   100.0;         // Target of global Take Profit
closeAllBy dd_target_mode = 2;         // Use Global Stop Loss by
double dd_target =   100.0;             // Target of global Stop Loss
//
input string             button_note1          = "------------------------------";
input ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_LOWER; // chart btn_corner for anchoring
input string             btn_text              = "Close All";
input string             btn_Font              = "Impact";
input int                btn_FontSize          = 10;                             //btn__font size
input color              btn_text_color        = clrWhite;
input color              btn_background_color  = clrDarkRed;
input color              btn_border_color      = clrBlack;
input int                button_x              = 240;                                     //btn__x
input int                button_y              = 20;                                     //btn__y
input int                btn_Width             = 60;                                 //btn__width
input int                btn_Height            = 20;                                //btn__height
input string             button_note2          = "------------------------------";
string buttonId;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == buttonId)
     {
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, 0);
      closeAll(0, Symbol());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   buttonId =  "TPC_CloseButton";
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_color);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// Remove the indicator from the chart
   ObjectDelete(0, buttonId);
   ObjectsDeleteAll(0, OBJ_LABEL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//| Expert tick function                                             |
//+------------------------------------------------------------------+
double l, sl, tp;
void OnTick()
  {
   static datetime prevCandleTime = 0;
   datetime currentCandleTime = Time[0];
// Check if a new candle has formed
   if(currentCandleTime != prevCandleTime)
     {
      // Calculate the moving average value
      double maValue = iMA(Symbol(), 0, movingAveragePeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
      // Calculate the deviation from the moving average
      double priceDeviation = MathAbs(Close[1] - maValue);
      // Define the trade condition
      if(priceDeviation > deviation)
        {
         // Execute the trade
         if(Close[1] > maValue)
           {
            // Buy at market price
            l = calcLot(1, Symbol(), Lot);
            sl = calcSL(1, Symbol(), l);
            tp = calcTP(1, Symbol(), l, sl);
            int ticket = OrderSend(Symbol(), OP_BUY, l, Ask, 0, sl, tp, "Trade per candle - Buy", MagicNumber, 0, Green);
            if(ticket < 0)
              {
               Print("Failed to place buy order. Error code:", GetLastError());
              }
           }
         else
           {
            // Sell at market price
            l = calcLot(2, Symbol(), Lot);
            sl = calcSL(2, Symbol(), l);
            tp = calcTP(2, Symbol(), l, sl);
            int ticket = OrderSend(Symbol(), OP_SELL, l, Bid, 0, sl, tp, "Trade per candle - Sell", MagicNumber, 0, Red);
            if(ticket < 0)
              {
               Print("Failed to place sell order. Error code:", GetLastError());
              }
           }
        }
      prevCandleTime = currentCandleTime;
     }
   if(profit_target_mode > 0)
     {
      double global_tp = PLOfPositions(profit_target_mode, 0, "");
      if(global_tp > profit_target)
         closeAll(0, "");
     }
   if(dd_target_mode > 0)
     {
      double global_dd = PLOfPositions(dd_target_mode, 0, "");
      if(global_dd < dd_target * (-1))
         closeAll(0, "");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PLOfPositions(int mode, int dir, string sym)
  {
   double countPip = 0.0;
   double countCur = 0.0;
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
      string ordersym = OrderSymbol();
      string comment = OrderComment();
      if((ordersym == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0)
        {
         if(OrderType() == OP_BUY)
            if(dir == 1 || dir == 0)
              {
               countPip += (MarketInfo(ordersym, MODE_BID) - OrderOpenPrice()) / pip(ordersym);
               countCur += OrderProfit();
              }
         if(OrderType() == OP_SELL)
            if(dir == 2 || dir == 0)
              {
               countPip += (OrderOpenPrice() - MarketInfo(ordersym, MODE_ASK)) / pip(ordersym);
               countCur += OrderProfit();
              }
        }
     }
   if(mode == 1)
      return countPip;
   if(mode == 2)
      return countCur;
   if(mode == 3)
      return 1 / (AccountEquity() * countCur) * 100;
   return countCur;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcLot(int dir, string sym, double priceLotVal)
  {
   double tickValue = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
   double step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   double poi = MarketInfo(sym, MODE_POINT);
   double ask =  SymbolInfoDouble(sym, SYMBOL_ASK);
   double bid =  SymbolInfoDouble(sym, SYMBOL_BID);
   double minlot = MarketInfo(sym, MODE_MINLOT);
   double maxlot = MarketInfo(sym, MODE_MAXLOT);
   double marginReq = MarketInfo(sym, MODE_MARGINREQUIRED);
   double maxlotMargin = (AccountEquity() / marginReq) * 0.95;
   double final_lot = minlot;
   double distance = 0.0, risk = 0.0, val = 0.0;
//
   final_lot =  priceLotVal;
   final_lot = MathMin(final_lot, maxlotMargin);
   final_lot = MathMax(final_lot, minlot);
   final_lot = MathMin(final_lot, maxlot);
   final_lot = MathRound(final_lot / step) * step;
   return final_lot;
  }
//+------------------------------------------------------------------+
double pip(string sy)
  {
   sy == "" ? sy = Symbol() :;
   double po = MarketInfo(sy, MODE_POINT);
   int di = (int)MarketInfo(sy, MODE_DIGITS);
   return (di % 2 == 1 ? po * 10 : po);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int multi(string sy)
  {
   sy == "" ? sy = Symbol() :;
   int di = (int)MarketInfo(sy, MODE_DIGITS);
   return (di % 2 == 1 ? 10 : 1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcSL(int dir, string sym, double lot)
  {
   int dig = (int)MarketInfo(sym, MODE_DIGITS);
   double sLevel = MarketInfo(sym, MODE_STOPLEVEL);
   double poi = MarketInfo(sym, MODE_POINT);
   double bid = MarketInfo(sym, MODE_BID);
   double ask = MarketInfo(sym, MODE_ASK);
   double spread = MarketInfo(sym, MODE_SPREAD);
   double tickval = MarketInfo(sym, MODE_TICKVALUE);
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double val = 0.0;
   double aSpread = 0.0;
//
   val = MathMax(SlVal * multi(sym), sLevel + spread) * poi;
   if(dir == 1)
      return NormalizeDouble(ask - val, dig);
   if(dir == 2)
      return NormalizeDouble(bid + val, dig);
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcTP(int dir, string sym, double lot, double slprice)
  {
   int dig = (int)MarketInfo(sym, MODE_DIGITS);
   double sLevel = MarketInfo(sym, MODE_STOPLEVEL);
   double poi = MarketInfo(sym, MODE_POINT);
   double bid = MarketInfo(sym, MODE_BID);
   double ask = MarketInfo(sym, MODE_ASK);
   double spread = MarketInfo(sym, MODE_SPREAD);
   double tickval = MarketInfo(sym, MODE_TICKVALUE);
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double val = 0.0;
//
   val = MathMax(TpVal * multi(sym), sLevel + spread) * poi;
   if(dir == 1)
      return NormalizeDouble(ask + val, dig);
   if(dir == 2)
      return NormalizeDouble(bid - val, dig);
   return 0;
  }
//+------------------------------------------------------------------+
void closeAll(int dir, string sym)
  {
   int succ;
   string commentPart = "";
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS);
      string symbol = OrderSymbol();
      RefreshRates();
      ResetLastError();
      if((symbol == sym || sym == "") && OrderMagicNumber() == (int)MagicNumber && MagicNumber > 0)
        {
         if(dir == 0 || (dir == 1 && OrderType() == OP_BUY) || (dir == 2 && OrderType() == OP_SELL))
           {
            succ = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 30, 0);
            if(succ)
               Print("Close All");
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
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