// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72138

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

// Your donations will allow the service to continue onward.
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
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict
#include <Trade/Trade.mqh>
CTrade trade();

enum NextTrade {
  Increment = 0,
  Multiply  = 1,
  Decrement
};

string       s4       = "===   Gold  Level  Indicator Setting   ====  ";
input bool   AlertOn  = false;
input int    drowDays = 1;
input bool   showText = false;
input double order    = 0.01;

string array_level[] = {"SP", "N", "B", "B1", "B2", "B3", "B4", "B5", "B6", "S", "S1", "S2", "S3", "S4", "S5", "S6"};

//    Buying    TakeProfit  Combination
double buy_price_entry = 0;
double BUY_TP1         = 0;
double BUY_TP2         = 0;
double BUY_TP3         = 0;
double BUY_TP4         = 0;
double BUY_TP5         = 0;
double BUY_TP6         = 0;

bool BUY_TP1_BOOL = false;
bool BUY_TP2_BOOL = false;
bool BUY_TP3_BOOL = false;
bool BUY_TP4_BOOL = false;
bool BUY_TP5_BOOL = false;
bool BUY_TP6_BOOL = false;

// Selling Take Profit  Combination
double sell_price_entry = 0;
double SELL_TP1         = 0;
double SELL_TP2         = 0;
double SELL_TP3         = 0;
double SELL_TP4         = 0;
double SELL_TP5         = 0;
double SELL_TP6         = 0;

bool SELL_TP1_BOOL = false;
bool SELL_TP2_BOOL = false;
bool SELL_TP3_BOOL = false;
bool SELL_TP4_BOOL = false;
bool SELL_TP5_BOOL = false;
bool SELL_TP6_BOOL = false;

datetime NewCandleTimeCurrentDay;
// #define   BUTTON_NAME_CLOSE_ALL_TRADE   "CLOSE ALL TRADE"
input string s3                          = "===Partial  Close  Trading   Setting   ===";
double       TP1_LEVEL                   = 0;
bool         TP1_LEVEL_BOOL              = false;
input double TP1_LEVEL_QUANTITY          = 0.01;  //  Partial Close Level 1
double       TP2_LEVEL                   = 0;
bool         TP2_LEVEL_BOOL              = false;
input double TP2_LEVEL_QUANTITY          = 0.02;  //  Partial Close Level 2
double       TP3_LEVEL                   = 0;
bool         TP3_LEVEL_BOOL              = false;
input double TP3_LEVEL_QUANTITY          = 0.03;  //  Partial Close Level 3
double       TP4_LEVEL                   = 0;
bool         TP4_LEVEL_BOOL              = false;
input double TP4_LEVEL_QUANTITY          = 0.04;  //  Partial Close Level 4
double       TP5_LEVEL                   = 0;
bool         TP5_LEVEL_BOOL              = false;
input double TP5_LEVEL_QUANTITY          = 0.05;  //  Partial Close Level 5
double       TP6_LEVEL                   = 0;
bool         TP6_LEVEL_BOOL              = false;
input double TP6_LEVEL_QUANTITY          = 0.06;  //  Partial Close Level 6
ulong        capture_recent_order_ticket = 0;
double       capture_recent_order_lot    = 0;
int          capture_recent_order_type   = -1;
input int    MAGIC_NUMBER                = 398376;  //  Magic  Number

string UpcomingSignal = "NONE";

input double LotSize = 0.04;

//
input NextTrade NextTradeSelection = Increment;  //   Lot Type Increment/Multiply/Decrement
input double    add_increamental   = 0.02;       //   Lot Value  Increment/Multiply/Decrement

input bool alert_send_notification = true;  //  Alert / Send Notification
input bool Trade_execution         = true;  //  Trade Execution

//   Additional  Feature  Future  Development
//   Trade   Close After Previouse  Line  Settelement
//   Trade  Close   After  New Day Line   Appeared
//   Trade Close    After  Follow  Recent  Line ,
//   Add Volume   error Show as comment
//    Add Custom  indicator  Not Available  There

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string ROW_7[] = {"CLOSE ALL TRADES"};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int XOffset = 0;  // Horizontal offset (pixels)
int YOffset = 2;  // Vertical offset (pixels)

input bool   stop_loss_setting = true;  //  Stop  Loss Setting
input double stop_loss         = 10;    //  Stop Loss in Pips

input bool max_number_setting = true;  // Max Number of Trade Setting
input int  max_number_trade   = 10;    // Max Number of trade Execution

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// NOTE: OnInit
int OnInit()
{
  //---    Advanced  Level Of Coding
  // Installation of custom indicator
  //  ObjectDescription(ObjectName(NULL, i, 0, OBJ_TEXT ))
  // int  label   =    ObjectsTotal( NULL   ,  0 ,  OBJ_LABEL ) ;
  //     for (int  i = 0; i <   label ; i++) {
  //       //
  //     string  output[];

  //     string  name = ObjectName(NULL, i, 0, OBJ_LABEL);

  //    Alert(  "=== Name  ===="   ,   name );

  //     }
  int handle = iCustom(Symbol(), PERIOD_CURRENT, "Gold_Level_mt5", AlertOn, drowDays, showText, order);

  fx_gold_level_ea();
  trade.SetExpertMagicNumber(MAGIC_NUMBER);

  for (int i = 0; i < ArraySize(ROW_7); i++) {
    int x_size = 183;
    int y_size = 23;
    ObjectCreate(0, "PanelLabel" + ROW_7[i], OBJ_EDIT, 0, 0, 0);
    ObjectSetInteger(0, "PanelLabel" + ROW_7[i], OBJPROP_XDISTANCE, XOffset);
    ObjectSetInteger(0, "PanelLabel" + ROW_7[i], OBJPROP_YDISTANCE, YOffset + 2 + 20 * 5);
    ObjectSetInteger(0, "PanelLabel" + ROW_7[i], OBJPROP_XSIZE, x_size);
    ObjectSetInteger(0, "PanelLabel" + ROW_7[i], OBJPROP_YSIZE, y_size);
    ObjectSetInteger(0, "PanelLabel" + ROW_7[i], OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, "PanelLabel" + ROW_7[i], OBJPROP_STATE, false);
    ObjectSetInteger(0, "PanelLabel" + ROW_7[i], OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, "PanelLabel" + ROW_7[i], OBJPROP_READONLY, true);
    //   ObjectSetString(0,"PanelLabel"+  ROW_7[i],OBJPROP_TOOLTIP,"Drag to Move");
    ObjectSetInteger(0, "PanelLabel" + ROW_7[i], OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, "PanelLabel" + ROW_7[i], OBJPROP_TEXT, i == 0 ? ROW_7[i] : ROW_7[i]);
    ObjectSetString(0, "PanelLabel" + ROW_7[i], OBJPROP_FONT, "Consolas");
    ObjectSetInteger(0, "PanelLabel" + ROW_7[i], OBJPROP_FONTSIZE, 9);
    ObjectSetInteger(0, "PanelLabel" + ROW_7[i], OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, "PanelLabel" + ROW_7[i], OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, "PanelLabel" + ROW_7[i], OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, "PanelLabel" + ROW_7[i], OBJPROP_BORDER_COLOR, clrBlack);
  }
  //---
  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// ok
// clang-format off
int fx_gold_level_ea()
{
  // double indicator_Intallation = iCustom(Symbol(), PERIOD_CURRENT, "GOLD_LEVEL", 0, 1);
  

  for (int i = 0; i < ArraySize(array_level); i++) 
	{
    // string name = ObjectDescription(array_level[i]);
    string name = ObjectGetString(0, array_level[i], OBJPROP_TEXT);
    double price = ObjectGetDouble(0, array_level[i], OBJPROP_PRICE);

    Print(name, "==========   Testing    ================", array_level[i], " price: ", price);
    string output[];
    int    k = StringSplit(name, StringGetCharacter("@", 0), output);

    if (ArraySize(output) == 2) {
      if (array_level[i] == "B") { buy_price_entry = output[1]; Print("buy_price_entry", buy_price_entry); }
      if (array_level[i] == "B1") { BUY_TP1 = output[1]; }
      if (array_level[i] == "B2") { BUY_TP2 = output[1]; }
      if (array_level[i] == "B3") { BUY_TP3 = output[1]; }
      if (array_level[i] == "B4") { BUY_TP4 = output[1]; }
      if (array_level[i] == "B5") { BUY_TP5 = output[1]; }
      if (array_level[i] == "B6") { BUY_TP6 = output[1]; }

      if (array_level[i] == "S") { sell_price_entry = output[1]; Print("sell_price_entry", sell_price_entry); }
      if (array_level[i] == "S1") { SELL_TP1 = output[1]; }
      if (array_level[i] == "S2") { SELL_TP2 = output[1]; }
      if (array_level[i] == "S3") { SELL_TP3 = output[1]; }
      if (array_level[i] == "S4") { SELL_TP4 = output[1]; }
      if (array_level[i] == "S5") { SELL_TP5 = output[1]; }
      if (array_level[i] == "S6") { SELL_TP6 = output[1]; }
    }
  }

  return 0;
}
// clang-format on

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// ok
int fx_price_mapping()
{
  if (buy_price_entry != 0.0) {
    //  buy  price mapping
    // Lot size calcualtion

    if (buy_price_entry <= (Ask() + 10 * Point()) && buy_price_entry >= (Ask() - 10 * Point()) && (UpcomingSignal == "NONE" || UpcomingSignal == "SELL")) {
      UpcomingSignal = "BUY";
      Comment("=============   Buying    ===========");
      fx_take_trade_order(0, LotSize);

      //  Take Buy  Trade
      //  Buy  Order Here
    }
  }
  if (sell_price_entry != 0.0) {
    //  sell  price mapping
    //  Lot size calculaion

    if (sell_price_entry <= (Bid() + 10 * Point()) && sell_price_entry >= (Bid() - 10 * Point()) && (UpcomingSignal == "NONE" || UpcomingSignal == "BUY")) {
      //  Sell  Order   Here

      UpcomingSignal = "SELL";
      Comment("=========  SELLING  ========");

      fx_take_trade_order(1, LotSize);
    }
  }

  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// ok
int isExistTrade()
{
  //  for  (  )
  string date_trade;
  int    count_trade           = 0;
  ulong  ticket_one            = 0;
  ulong  ticket_two            = 0;
  int    start_index           = OrdersTotal() - 1;
  ulong  recent_ticket         = 0;
  int    counter_ticket_holder = 0;
  double order_lot_mapping     = 0;
  int    order_type_mapping    = 0;

  ulong tk = 0;
  for (int i = PositionsTotal() - 1; i >= 0; i--) {
    if (PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_MAGIC) == MAGIC_NUMBER) {
      tk          = PositionGetTicket(i);
      double lots = PositionGetDouble(POSITION_VOLUME);

      // for (int i = start_index; i >= 0; i--)
      // {
      // if (OrderSelect(i, SELECT_BY_POS))
      // {
      // if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC_NUMBER)
      // {
      //
      if (counter_ticket_holder == 0) {
        // ticket_one = OrderTicket();
        ticket_one = tk;
      }
      if (counter_ticket_holder != 0) {
        // ticket_two = OrderTicket();
        ticket_two = tk;
      }
      if (ticket_one < ticket_two) {
        ticket_one = ticket_two;
        // order_lot_mapping = OrderLots();
        order_lot_mapping = lots;
        //   Alert  ("Ticket one " ,  ticket_one ,  "Ticket Two" , ticket_two  ) ;
      }
      count_trade = count_trade + 1;
    }

    if (i == 0) {
      if (count_trade == 0) {
        //  capture_recent_order_ticket   = -1;
        return 0;
      }

      else {
        // capture_recent_order_ticket    =  recent_ticket;
        // capture_recent_order_ticket    =   ticket_one;
        // capture_recent_order_lot     =  order_lot_mapping;

        if (count_trade == 1) {
          // capture_recent_order_ticket = OrderTicket();
          capture_recent_order_ticket = tk;
        }

        return count_trade;
      }
    }
  }
  // }

  return 0;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
// ok
void OnDeinit(const int reason)
{
  for (int i = 0; i < ArraySize(ROW_7); i++) {
    ObjectDelete(0, "PanelLabel" + ROW_7[i]);
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// ok
double fx_lots_increament()
{
  for (int i = PositionsTotal() - 1; i >= 0; i--) {
    if (PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_MAGIC) == MAGIC_NUMBER) {
      ulong  tk   = PositionGetTicket(i);
      double lots = PositionGetDouble(POSITION_VOLUME);

      // for (int i = (OrdersTotal() - 1); i >= 0; i--)
      // {
      // if (OrderSelect(i, SELECT_BY_POS))
      // {
      // if (OrderMagicNumber() == MAGIC_NUMBER && OrderSymbol() == Symbol())
      // {
      if (NextTradeSelection == Increment) {
        // return OrderLots() + add_increamental;
        return lots + add_increamental;
      }
      if (NextTradeSelection == Multiply) {
        // return OrderLots() * add_increamental;
        return lots * add_increamental;
      }

      if (NextTradeSelection == Decrement) {
        // if (OrderLots() - add_increamental < 0)
        if (lots - add_increamental < 0) {
          Alert("Wrong Lot");
        }
        // return OrderLots() - add_increamental;
        return lots - add_increamental;
      }
    }

    // if (i == OrdersTotal() - 1)
    if (i == PositionsTotal() - 1) {
      return LotSize;
    }
  }
  // }

  // order_lot_mapping   *    OrderLots()
  //  order_lot_mapping

  ///

  return LotSize;
  return 0;
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
// ok
void OnTick()
{
  if (isExistTrade() == 0) {
    if (IsNewCandleCurrentDay()) {
      fx_reset();
      fx_close_mode(true, "");
      fx_gold_level_ea();
    }
  }
  //---
  //--
  // double   buy_price_entry   =    0   ;

  // double    BUY_TP1       =  0  ;
  // double    BUY_TP2    =    0 ;
  // double    BUY_TP3     =  0  ;
  // double    BUY_TP4    = 0  ;
  // double    BUY_TP5    =  0  ;
  // double   BUY_TP6     = 0 ;

  // // Selling Take Profit  Combination

  // double  sell_price_entry   =  0 ;
  // double  SELL_TP1    = 0 ;
  // double  SELL_TP2   = 0;
  // double  SELL_TP3    = 0 ;
  // double   SELL_TP4  =   0  ;
  // double   SELL_TP5   = 0  ;
  // double   SELL_TP6     =0 ;

  fx_price_mapping();

  if (isExistTrade() == 1) {
    fx_stop_loss_management("SET");

    //  Set  Stop  Loss
    // Tracking  the trade  Here
    // Alert    (   "is Exit trade here");
    // TP1_LEVEL
    //  TP1_LEVEL_BOOL
    // TP1_LEVEL_QUANTITY
    if (TP1_LEVEL_BOOL == false && capture_recent_order_type == 0 && TP1_LEVEL <= Ask()) {
      //  Partial Close

      if (TP1_LEVEL_QUANTITY != 0 || TP1_LEVEL_QUANTITY != 0.0) {
        double lots_close = fx_partial_close(TP1_LEVEL_QUANTITY);
        // OrderClose(capture_recent_order_ticket, lots_close, Bid(), 10, clrGold);
        trade.PositionClosePartial(capture_recent_order_ticket, lots_close);
      }

      TP1_LEVEL_BOOL = true;

    }

    else if (TP2_LEVEL_BOOL == false && capture_recent_order_type == 0 && TP2_LEVEL <= Ask()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))

      if (TP2_LEVEL_QUANTITY != 0 || TP2_LEVEL_QUANTITY != 0.0) {
        double lots_close = fx_partial_close(TP2_LEVEL_QUANTITY);
        // OrderClose(capture_recent_order_ticket, lots_close, Bid(), 10, clrGold);
        trade.PositionClosePartial(capture_recent_order_ticket, lots_close);
      }
      TP2_LEVEL_BOOL = true;

    }

    else if (TP3_LEVEL_BOOL == false && capture_recent_order_type == 0 && TP3_LEVEL <= Ask()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))

      if (TP3_LEVEL_QUANTITY != 0 || TP3_LEVEL_QUANTITY != 0.0) {
        double lots_close = fx_partial_close(TP3_LEVEL_QUANTITY);
        // OrderClose(capture_recent_order_ticket, lots_close, Bid(), 10, clrGold);
        trade.PositionClosePartial(capture_recent_order_ticket, lots_close);
      }
      TP3_LEVEL_BOOL = true;

    }

    else if (TP4_LEVEL_BOOL == false && capture_recent_order_type == 0 && TP4_LEVEL <= Ask()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))

      if (TP4_LEVEL_QUANTITY != 0.0 || TP4_LEVEL_QUANTITY != 0) {
        double lots_close = fx_partial_close(TP4_LEVEL_QUANTITY);
        // OrderClose(capture_recent_order_ticket, lots_close, Bid(), 10, clrGold);
        trade.PositionClosePartial(capture_recent_order_ticket, lots_close);
      }
      TP4_LEVEL_BOOL = true;

    }

    else if (TP5_LEVEL_BOOL == false && capture_recent_order_type == 0 && TP5_LEVEL <= Ask()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))

      if (TP5_LEVEL_QUANTITY != 0 || TP5_LEVEL_QUANTITY != 0.0) {
        double lots_close = fx_partial_close(TP5_LEVEL_QUANTITY);
        // OrderClose(capture_recent_order_ticket, lots_close, Bid(), 10, clrGold);
        trade.PositionClosePartial(capture_recent_order_ticket, lots_close);
      }

      TP5_LEVEL_BOOL = true;
    }

    else if (TP6_LEVEL_BOOL == false && capture_recent_order_type == 0 && TP6_LEVEL <= Ask()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))

      if (TP6_LEVEL_QUANTITY != 0 || TP6_LEVEL_QUANTITY != 0.0) {
        double lots_close = fx_partial_close(TP6_LEVEL_QUANTITY);
        // OrderClose(capture_recent_order_ticket, lots_close, Bid(), 10, clrGold);
        trade.PositionClosePartial(capture_recent_order_ticket, lots_close);
      }
      TP6_LEVEL_BOOL = true;

    }

    else if (TP1_LEVEL_BOOL == false && capture_recent_order_type == 1 && TP1_LEVEL >= Bid()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))

      if (TP1_LEVEL_QUANTITY != 0 || TP1_LEVEL_QUANTITY != 0.0) {
        double lots_close = fx_partial_close(TP1_LEVEL_QUANTITY);
        // OrderClose(capture_recent_order_ticket, lots_close, Ask(), 10, clrGold);
        trade.PositionClosePartial(capture_recent_order_ticket, lots_close);
      }
      TP1_LEVEL_BOOL = true;

    }

    else if (TP2_LEVEL_BOOL == false && capture_recent_order_type == 1 && TP2_LEVEL >= Bid()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))
      if (TP2_LEVEL_QUANTITY != 0 || TP2_LEVEL_QUANTITY != 0.0) {
        double lots_close = fx_partial_close(TP2_LEVEL_QUANTITY);
        // OrderClose(capture_recent_order_ticket, lots_close, Ask(), 10, clrGold);
        trade.PositionClosePartial(capture_recent_order_ticket, lots_close);
      }
      TP2_LEVEL_BOOL = true;

    }

    else if (TP3_LEVEL_BOOL == false && capture_recent_order_type == 1 && TP3_LEVEL >= Bid()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))

      if (TP3_LEVEL_QUANTITY != 0 || TP3_LEVEL_QUANTITY != 0.0) {
        double lots_close = fx_partial_close(TP3_LEVEL_QUANTITY);
        // OrderClose(capture_recent_order_ticket, lots_close, Ask(), 10, clrGold);
        trade.PositionClosePartial(capture_recent_order_ticket, lots_close);
      }

      TP3_LEVEL_BOOL = true;

    }

    else if (TP4_LEVEL_BOOL == false && capture_recent_order_type == 1 && TP4_LEVEL >= Bid()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))

      if (TP4_LEVEL_QUANTITY != 0 || TP4_LEVEL_QUANTITY != 0.0) {
        double lots_close = fx_partial_close(TP4_LEVEL_QUANTITY);
        // OrderClose(capture_recent_order_ticket, lots_close, Ask(), 10, clrGold);
        trade.PositionClosePartial(capture_recent_order_ticket, lots_close);
      }

      TP4_LEVEL_BOOL = true;

    }

    else if (TP5_LEVEL_BOOL == false && capture_recent_order_type == 1 && TP5_LEVEL >= Bid()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))

      if (TP5_LEVEL_QUANTITY != 0 || TP5_LEVEL_QUANTITY != 0.0) {
        double lots_close = fx_partial_close(TP5_LEVEL_QUANTITY);
        // OrderClose(capture_recent_order_ticket, lots_close, Ask(), 10, clrGold);
        trade.PositionClosePartial(capture_recent_order_ticket, lots_close);
      }

      TP5_LEVEL_BOOL = true;

    } else if (TP6_LEVEL_BOOL == false && capture_recent_order_type == 1 && TP6_LEVEL >= Bid()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))

      if (TP6_LEVEL_QUANTITY != 0 || TP6_LEVEL_QUANTITY != 0.0) {
        double lots_close = fx_partial_close(TP6_LEVEL_QUANTITY);
        // OrderClose(capture_recent_order_ticket, lots_close, Ask(), 10, clrGold);
        trade.PositionClosePartial(capture_recent_order_ticket, lots_close);
      }
      TP6_LEVEL_BOOL = true;
    }
    // else if  (   TP2_LEVEL_BOOL    ==  false    &&   capture_recent_order_type    ==   0   &&    TP2_LEVEL    <=   Ask() )   {
    //        //  Partial Close
    //   //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))
    //     OrderClose(        capture_recent_order_ticket  ,   TP2_LEVEL_QUANTITY    , Bid() , 10 , clrGold    )

    // }

  } else if (isExistTrade() > 1) {
    fx_stop_loss_management("REMOVE");
    if (TP1_LEVEL_BOOL == false && capture_recent_order_type == 0 && TP1_LEVEL <= Ask()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))
      // OrderClose(        capture_recent_order_ticket  ,   TP1_LEVEL_QUANTITY    , Bid() , 10 , clrGold    )  ;

      fx_close_mode(true, "");
      TP1_LEVEL_BOOL = true;

    }

    else if (TP2_LEVEL_BOOL == false && capture_recent_order_type == 0 && TP2_LEVEL <= Ask()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))
      // OrderClose(        capture_recent_order_ticket  ,   TP2_LEVEL_QUANTITY    , Bid() , 10 , clrGold    )  ;
      fx_close_mode(true, "");
      TP2_LEVEL_BOOL = true;

    }

    else if (TP3_LEVEL_BOOL == false && capture_recent_order_type == 0 && TP3_LEVEL <= Ask()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))
      // OrderClose(        capture_recent_order_ticket  ,   TP3_LEVEL_QUANTITY    , Bid() , 10 , clrGold    ) ;
      fx_close_mode(true, "");
      TP3_LEVEL_BOOL = true;

    }

    else if (TP4_LEVEL_BOOL == false && capture_recent_order_type == 0 && TP4_LEVEL <= Ask()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))
      // OrderClose(        capture_recent_order_ticket  ,   TP4_LEVEL_QUANTITY    , Bid() , 10 , clrGold    )   ;
      fx_close_mode(true, "");
      TP4_LEVEL_BOOL = true;

    }

    else if (TP5_LEVEL_BOOL == false && capture_recent_order_type == 0 && TP5_LEVEL <= Ask()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))
      // OrderClose(        capture_recent_order_ticket  ,   TP5_LEVEL_QUANTITY    , Bid() , 10 , clrGold    )    ;
      fx_close_mode(true, "");

      TP5_LEVEL_BOOL = true;
    }

    else if (TP6_LEVEL_BOOL == false && capture_recent_order_type == 0 && TP6_LEVEL <= Ask()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))
      // OrderClose(        capture_recent_order_ticket  ,   TP6_LEVEL_QUANTITY    , Bid() , 10 , clrGold    )   ;
      fx_close_mode(true, "");
      TP6_LEVEL_BOOL = true;

    }

    else if (TP1_LEVEL_BOOL == false && capture_recent_order_type == 1 && TP1_LEVEL >= Bid()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))
      // OrderClose(        capture_recent_order_ticket  ,   TP1_LEVEL_QUANTITY    , Ask() , 10 , clrGold    )  ;
      fx_close_mode(true, "");
      TP1_LEVEL_BOOL = true;

    }

    else if (TP2_LEVEL_BOOL == false && capture_recent_order_type == 1 && TP2_LEVEL >= Bid()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))
      // OrderClose(        capture_recent_order_ticket  ,   TP2_LEVEL_QUANTITY    , Ask() , 10 , clrGold    ) ;
      fx_close_mode(true, "");
      TP2_LEVEL_BOOL = true;

    }

    else if (TP3_LEVEL_BOOL == false && capture_recent_order_type == 1 && TP3_LEVEL >= Bid()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))
      // OrderClose(        capture_recent_order_ticket  ,   TP3_LEVEL_QUANTITY     , Ask() , 10 , clrGold    )    ;
      fx_close_mode(true, "");
      TP3_LEVEL_BOOL = true;

    }

    else if (TP4_LEVEL_BOOL == false && capture_recent_order_type == 1 && TP4_LEVEL >= Bid()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))
      // OrderClose(        capture_recent_order_ticket  ,   TP4_LEVEL_QUANTITY    , Ask() , 10 , clrGold    )    ;

      fx_close_mode(true, "");
      TP4_LEVEL_BOOL = true;

    }

    else if (TP5_LEVEL_BOOL == false && capture_recent_order_type == 1 && TP5_LEVEL >= Bid()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))
      // OrderClose(        capture_recent_order_ticket  ,   TP5_LEVEL_QUANTITY    , Ask() , 10 , clrGold    )    ;
      fx_close_mode(true, "");
      TP5_LEVEL_BOOL = true;

    } else if (TP6_LEVEL_BOOL == false && capture_recent_order_type == 1 && TP6_LEVEL >= Bid()) {
      //  Partial Close
      //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))
      // OrderClose(        capture_recent_order_ticket  ,   TP6_LEVEL_QUANTITY    , Ask() , 10 , clrGold    )  ;
      fx_close_mode(true, "");
      // fx_close_mode
      TP6_LEVEL_BOOL = true;
    }
    // else if  (   TP2_LEVEL_BOOL    ==  false    &&   capture_recent_order_type    ==   0   &&    TP2_LEVEL    <=   Ask() )   {
    //        //  Partial Close
    //   //  if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, clrGold))
    //     OrderClose(        capture_recent_order_ticket  ,   TP2_LEVEL_QUANTITY    , Bid() , 10 , clrGold    )

    // }

  } else if (isExistTrade() == 0) {
    // Trade  Goes  Here
    //  fx_reset();
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// ok
int fx_reset()
{
  UpcomingSignal   = "NONE";
  buy_price_entry  = 0;
  sell_price_entry = 0;
  TP1_LEVEL        = 0;
  TP1_LEVEL_BOOL   = false;

  TP2_LEVEL      = 0;
  TP2_LEVEL_BOOL = false;

  TP3_LEVEL      = 0;
  TP3_LEVEL_BOOL = false;

  TP4_LEVEL      = 0;
  TP4_LEVEL_BOOL = false;

  TP5_LEVEL      = 0;
  TP5_LEVEL_BOOL = false;

  TP6_LEVEL      = 0;
  TP6_LEVEL_BOOL = false;

  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// ok
int fx_reset_initial_trade()
{
  TP1_LEVEL      = 0;
  TP1_LEVEL_BOOL = false;

  TP2_LEVEL      = 0;
  TP2_LEVEL_BOOL = false;

  TP3_LEVEL      = 0;
  TP3_LEVEL_BOOL = false;

  TP4_LEVEL      = 0;
  TP4_LEVEL_BOOL = false;

  TP5_LEVEL      = 0;
  TP5_LEVEL_BOOL = false;

  TP6_LEVEL      = 0;
  TP6_LEVEL_BOOL = false;

  return 0;
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// ok
bool IsNewCandleCurrentDay()
{
  if (NewCandleTimeCurrentDay == iTime(Symbol(), PERIOD_D1, 0))
    return false;
  else {
    NewCandleTimeCurrentDay = iTime(Symbol(), PERIOD_D1, 0);
    return true;
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// ok
void OnChartEvent(const int     id,
                  const long&   lparam,
                  const double& dparam,
                  const string& sparam)
{
  string ClickDesc = ObjectGetString(0, sparam, OBJPROP_TEXT);

  if (ClickDesc == "CLOSE ALL TRADES") {
    fx_close_mode(true, "");
    fx_reset();
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// OK
void fx_close_mode(bool type, string addtional)
{
  for (int i = PositionsTotal(); i >= 0; i--) {
    ulong tk = PositionGetTicket(i);
    if (PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_MAGIC) == MAGIC_NUMBER) {
      trade.PositionClose(tk, 100);
    }
  }
}

// int fx_close_mode(bool type, string addtional)
// {
//   //  if( )
//   RefreshRates();
//   // Log in the terminal the total of orders, current and past.
//   Print(OrdersTotal());

//   // Start a loop to scan all the orders.
//   // The loop starts from the last order, proceeding backwards; Otherwise it would skip some orders.
//   for (int i = (OrdersTotal() - 1); i >= 0; i--)
//   {
//     // If the order cannot be selected, throw and log an error.
//     if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
//     {
//       Print("ERROR - Unable to select the order - ", GetLastError());
//       break;
//     }

//     // Create the required variables.
//     // Result variable - to check if the operation is successful or not.
//     bool res = false;

//     // Allowed Slippage - the difference between current price and close price.
//     int Slippage = 0;

//     // Bid() and Ask() prices for the instrument of the order.
//     double Bid()Price = MarketInfo(OrderSymbol(), MODE_BID);
//     double Ask()Price = MarketInfo(OrderSymbol(), MODE_ASK);

//     // Closing the order using the correct price depending on the type of order.
//     if (OrderType() == OP_BUY && OrderMagicNumber() == MAGIC_NUMBER)
//     {
//       res = OrderClose(OrderTicket(), OrderLots(), Bid()Price, Slippage);
//     } else if (OrderType() == OP_SELL && OrderMagicNumber() == MAGIC_NUMBER)
//     {
//       res = OrderClose(OrderTicket(), OrderLots(), Ask()Price, Slippage);
//     }

//     // If there was an error, log it.
//     if (res == false)
//       Print("ERROR - Unable to close the order - ", OrderTicket(), " - ", GetLastError());
//     if (i == 0)
//     {
//       fx_reset();
//     }
//   }

//   return 0;
// }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// OK
int fx_take_trade_order(int order_type, double order_lot_mapping)
{
  //  Comment("  Current  Order Type Placed"   ,   OrderType()    ==   0   ?    "BUY"     : "SELL"  ,  "====") ;
  Print("order_type ", order_type);

  ENUM_ORDER_TYPE _type;
  if (order_type == 0) { _type = ORDER_TYPE_BUY; }
  if (order_type == 1) { _type = ORDER_TYPE_SELL; }

  if (alert_send_notification == true) {
    Alert(order_type == 1 ? (Symbol() + "   Sell") : (Symbol() + "  Buy"));
    SendNotification(order_type == 1 ? (Symbol() + " Sell") : (Symbol() + "  Buy"));
  }

  if (Trade_execution == true) {
    ulong res = 0;

    if (fx_max_number_trade() < max_number_trade || max_number_setting == false) {
      // res = OrderSend(Symbol(), order_type, fx_lots_increament(), order_type == 0 ? Ask() : Bid(), 5, 0, 0, NULL, MAGIC_NUMBER, 0, order_type == 0 ? clrBlue : clrRed);

      // Buy
      if (order_type == 0) {
        if (trade.PositionOpen(Symbol(), _type, fx_lots_increament(), Ask(), 0, 0)) {
          // en res necesito el tk de esta orden
          int pos = PositionsTotal() - 1;
          res     = PositionGetTicket(pos);
        }
      }

      // Sell
      if (order_type == 1) {
        if (trade.PositionOpen(Symbol(), _type, fx_lots_increament(), Bid(), 0, 0)) {
          // en res necesito el tk de esta orden
          int pos = PositionsTotal() - 1;
          res     = PositionGetTicket(pos);
        }
      }
    }

    if (fx_max_number_trade() >= max_number_trade) {
      Comment(" Max Trade Limit ");
    }

    //

    if (res < 1) {
      //

      //  Alert    ( "   Order Not  Placed  Error "   ,   GetLastError()    )  ;

    } else {
      capture_recent_order_type   = order_type;
      capture_recent_order_ticket = res;
      //  capture_recent_order_ticket
      if (order_type == 0) { 
				fx_mapping_trading(0);
      }
      if (order_type == 1) {
        fx_mapping_trading(1);
      }
    }
  }

  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double fx_mapping_trading(int order_type_mapping_value)
{
  if (order_type_mapping_value == 0) {
    TP1_LEVEL = BUY_TP1;
    TP2_LEVEL = BUY_TP2;
    TP3_LEVEL = BUY_TP3;
    TP4_LEVEL = BUY_TP4;
    TP5_LEVEL = BUY_TP5;
    TP6_LEVEL = BUY_TP6;
  }
  if (order_type_mapping_value == 1) {
    TP1_LEVEL = SELL_TP1;
    TP2_LEVEL = SELL_TP2;
    TP3_LEVEL = SELL_TP3;
    TP4_LEVEL = SELL_TP4;
    TP5_LEVEL = SELL_TP5;
    TP6_LEVEL = SELL_TP6;
  }

  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// NOTE: fx_partial_close
double fx_partial_close(double lots_mapping)
{
  //

  if (PositionSelectByTicket(capture_recent_order_ticket)) {
    double lotsToClose = lots_mapping;
    double lots = PositionGetDouble(POSITION_VOLUME);

    // return (lots_mapping * lots) / 100;

    if (lots_mapping > lots) { lotsToClose = lots; }

    return lotsToClose;
  }

  return 0;
}

//+------------------------------------------------------------------+

/*


Hi

Can this indicator be doable to an EA?

The indicator sets buy-sell and TP levels.

I would want an EA that takes the buy and sell signals but with hedge.
If buy signals triggers but price reverses and triggers sell then it will hedge at x2 the initial price. The EA keeps on hedging(zone recovery), until it hits the TP level (exit 1-2-3-4-5-6).

I do this manually but will be awesome if a ea does it.

EA settings:
- fix lot for each day
- multiply or add value for initial entry
- close all button on the chart
- % partial on TP levels (% on 1-2-3-4-5)
- add lot on TP level (add fix lot on 1-2-3-4-5-6)



*/

/*



Entry rules will be when price pas or touches the buy or sell level.
Same as exit, all orders are close to determine level (1-2-3-4-5-6-) or partial close. Depends if you are hedge then it´s best to exit on the 1:a level if not hedge the you can partial close on 1-2-3-4-5-6.

---------------------------------

Entry rules is when price touch the buy or sell level.
I do it manually, put a fix lot on buy and sell level, when price hits which ever I close the other one.
Now if price goes to TP 1 (BT1/ST1), I close partial and let the order run if I think price can go higher, if not I close it all.
When I hedge is if price triggers my buy order and reverses, takes my sell order and reverses again. triggers a buy order again put now price just keeps on pushing up to TP1 level.
If price hedges (between buy and sell zone) I close all when price gets to TP1.
When hedging I always multiply by 2 s 0.01buy-0.02sell-0.04 buy and so on till price leaves that buy and sell zone and goes to TP levels.
Gambit




*/

// Steps to Use (Gold Level EA) - Parial Level  :-
// 1. After  downloading both file  (  EA-  GOLD LEVEL EA , INDICATOR- GOLD LEVEL)
// 2.  The indicator draw ,  two  level of "buy" and "sell"   -   all  trade placed on this level,
// Partial Trade Setting  -    if Initial Lot  Size  is 0.10
// If you put  "Partial % Level 1  =  20"  ,   it  means - it  closed 20% of 0.10 Lot size  - i.e (0.02) , Now Remaining lot is 0.08
// if you put  "Partial % Level 2 =20"  ,  it means - it closed 20% of 0.08 Current active lot size - i.e (0.016 - round off 0.01),  Now Remaining Lot is 0.07
// Similar For all "Partial Setting"
// Note : - if you put  "0" on Partial % Level Setting - it means  -  "This Level Become Skip - (  Not Considered- tp/sl) "

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double fx_stoploss(int order_type)
{
  if (order_type == 0) {
    return Bid() - fx_pips_evaluation() * stop_loss * Point();
  } else if (order_type == 1) {
    return Ask() + fx_pips_evaluation() * stop_loss * Point();
  }

  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_stop_loss_management(string stop_loss_value_type)
{
  // if (stop_loss_value_type == "SET") {
  //   for (int i = 0; i < OrdersTotal(); i++) {
  //     if (OrderSelect(i, SELECT_BY_POS)) {
  //       if (OrderMagicNumber() == MAGIC_NUMBER && OrderSymbol() == Symbol()) {
  //         if ((OrderStopLoss() == 0 || OrderStopLoss() == 0.0) && stop_loss_setting == true) {
  //           double stop_loss_calculation = fx_stoploss(OrderType());

  //           fx_order_modification(OrderTicket(), OrderOpenPrice(), stop_loss_calculation, OrderTakeProfit(), 0, "NONE", OrderMagicNumber());
  //         }
  //       }
  //     }
  //   }
  // }
  // else if (stop_loss_value_type == "REMOVE") {
  //   for (int i = 0; i < OrdersTotal(); i++) {
  //     if (OrderSelect(i, SELECT_BY_POS)) {
  //       if (OrderMagicNumber() == MAGIC_NUMBER && OrderSymbol() == Symbol()) {

  // 	      if ((OrderStopLoss() != 0 || OrderStopLoss() != 0.0) && stop_loss_setting == true) {
  //           double stop_loss_calculation = 0;

  //           fx_order_modification(OrderTicket(), OrderOpenPrice(), stop_loss_calculation, OrderTakeProfit(), 0, "NONE", OrderMagicNumber());
  //         }
  //       }
  //     }
  //   }
  // }

  if (stop_loss_value_type == "SET") {
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong tk = PositionGetTicket(i);
      if (PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_MAGIC) == MAGIC_NUMBER) {
        double sl = PositionGetDouble(POSITION_SL);
        double tp = PositionGetDouble(POSITION_TP);

        if (sl == 0 && stop_loss_setting == true) {
          int type;
          if (PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY) type = 0;
          if (PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL) type = 1;
          double stop_loss_calculation = fx_stoploss(type);
          trade.PositionModify(tk, stop_loss_calculation, tp);
        }
      }
    }
  }

  if (stop_loss_value_type == "REMOVE") {
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong tk = PositionGetTicket(i);
      if (PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_MAGIC) == MAGIC_NUMBER) {
        double sl = PositionGetDouble(POSITION_SL);
        double tp = PositionGetDouble(POSITION_TP);

        if (sl != 0 && stop_loss_setting == true) {
          int type;
          if (PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY) type = 0;
          if (PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL) type = 1;
          double stop_loss_calculation = 0;
          trade.PositionModify(tk, stop_loss_calculation, tp);
        }
      }
    }
  }

  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// int fx_order_modification(int ticket, double order_open_price, double local_storage_stop_loss, double order_take_profit, int expiration, string additional, int order_magic_number)
// {
//   // OrderTicket()  , OrderOpenPrice() ,local_strage ,OrderTakeProfit(), 0 , "NONE" ,  OrderMagicNumber()

//   // OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice()-(StopLoss*pips),OrderOpenPrice()+(TakeProfit*pips), 0, CLR_NONE); // OP_BUY
//   bool res = OrderModify(ticket, order_open_price, local_storage_stop_loss, order_take_profit, expiration, CLR_NONE);
//   if (!res) {
//     Alert("Error in OrderModify. Error code=", GetLastError());
//   }

//   return 0;
// }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_pips_evaluation()
{
  if (Digits() == 2 || Digits() == 3) {
    return 100;
    // LotSize =  0.01;
  } else if (Digits() == 4 || Digits() == 5) {
    return 10;
  } else {
    return 1;
  }

  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_max_number_trade()
{
  // int count_number_trade = 0;
  // for (int i = 0; i < OrdersTotal(); i++) {
  //   if (OrderSelect(i, SELECT_BY_POS)) {
  //     if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC_NUMBER) {
  //       count_number_trade = count_number_trade + 1;
  //     }
  //     if (OrdersTotal() - 1 == i) {
  //       return count_number_trade;
  //     }
  //   }
  // }

  int count = 0;
  for (int i = PositionsTotal(); i >= 0; i--) {
    ulong tk = PositionGetTicket(i);
    if (PositionGetSymbol(i) == Symbol() && PositionGetInteger(POSITION_MAGIC) == MAGIC_NUMBER) {
      count++;
    }
  }
  return count;
}
//+------------------------------------------------------------------+
double Bid() { return SymbolInfoDouble(_Symbol, SYMBOL_BID); }
double Ask() { return SymbolInfoDouble(_Symbol, SYMBOL_ASK); }