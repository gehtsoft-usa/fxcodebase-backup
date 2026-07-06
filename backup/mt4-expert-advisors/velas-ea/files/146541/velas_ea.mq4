// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72437

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
#property description ""
#property tester_indicator "TMA+CG mladen 1.1"

#include <stderror.mqh>
#include <stdlib.mqh>

enum EnumSideControl {
  same,  // Only the same at first
  both,  // Both Sides
};

class CSideControl
{
  EnumSideControl _userSideMode;
  int             _magic;
  int             _currentSide;  // 0.buy 1.sell -1.not set
  int             _firstTK;

 public:
  CSideControl(EnumSideControl userSide, int magic) : _userSideMode(userSide), _magic(magic), _currentSide(-1), _firstTK(0)
  { Print("_userSideMode: ",_userSideMode); }
  ~CSideControl() { ;}

  void SetSide()
  {
    if (_firstTK == 0)
		{
			_currentSide = -1; 
			return;
		}

    if (TradesCount() == 0)
    {
      _currentSide = -1;
      _firstTK     = 0;
      return;
    }
   
	  if (OrderSelect(_firstTK, SELECT_BY_TICKET))
    {
      if (OrderType() == OP_BUY) _currentSide = 0;
      if (OrderType() == OP_SELL) _currentSide = 1;
    }

  }

  bool doControl(int side)
  {
    if (_userSideMode == both) return true;
		
    if (side == _currentSide || _currentSide == -1)
    {
      return true;
    }

    return false;
  }

  void SearchFirstTk()
  {
    if (_firstTK != 0) return;

    for (int i = 0; i < OrdersTotal(); i++)
    {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == _Symbol && OrderMagicNumber() == _magic)
      {
        if (OrderType() != OP_BUY && OrderType() != OP_SELL) continue;

        _firstTK = OrderTicket();

        return;
      }
    }
    _firstTK = 0;
  }

  int TradesCount()
  {
    int count = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == _Symbol && OrderMagicNumber() == _magic)
      {
        if (OrderType() != OP_BUY && OrderType() != OP_SELL) continue;
        count += 1;
      }
    }

    return count;
  }

};
CSideControl*         SideController;

extern double         SL_Points = 40;
extern double         TP_Points = 10;
int                   LotDigits;  // initialized in OnInit
int                   MagicNumber            = 1591433;
extern int            NextOpenTradeAfterBars = 1;  // next open trade after time
extern double         MM_Percent             = 1;
int                   MaxSlippage            = 3;  // slippage, adjusted in OnInit
extern double         CloseAtPL              = 100;
input EnumSideControl SideControl            = same;  // Side Control
extern int            MaxOpenTrades          = 10;
extern int            MaxLongTrades          = 3;
extern int            MaxShortTrades         = 3;
int                   MaxPendingOrders       = 1000;
int                   MaxLongPendingOrders   = 1000;
int                   MaxShortPendingOrders  = 1000;
bool                  Hedging                = true;
int                   OrderRetry             = 5;  //# of retries if sending order returns error
int                   OrderWait              = 5;  //# of seconds to wait if sending order returns error
double                myPoint;                     // initialized in OnInit


double MM_Size(double SL)  // Risk % per trade, SL = relative Stop Loss to calculate risk
{
  double MaxLot    = MarketInfo(Symbol(), MODE_MAXLOT);
  double MinLot    = MarketInfo(Symbol(), MODE_MINLOT);
  double tickvalue = MarketInfo(Symbol(), MODE_TICKVALUE);
  double ticksize  = MarketInfo(Symbol(), MODE_TICKSIZE);
  double lots      = MM_Percent * 1.0 / 100 * AccountBalance() / (SL / ticksize * tickvalue);
  if (lots > MaxLot) lots = MaxLot;
  if (lots < MinLot) lots = MinLot;
  return (lots);
}

double MM_Size_BO()  // Risk % per trade for Binary Options
{
  double MaxLot    = MarketInfo(Symbol(), MODE_MAXLOT);
  double MinLot    = MarketInfo(Symbol(), MODE_MINLOT);
  double tickvalue = MarketInfo(Symbol(), MODE_TICKVALUE);
  double ticksize  = MarketInfo(Symbol(), MODE_TICKSIZE);
  return (MM_Percent * 1.0 / 100 * AccountBalance());
}

void CloseTradesAtPL(double PL)  // close all trades if total P/L >= profit (positive) or total P/L <= loss (negative)
{
  double totalPL = TotalOpenProfit(0);
  if ((PL > 0 && totalPL >= PL) || (PL < 0 && totalPL <= PL))
  {
    myOrderClose(OP_BUY, 100, "");
    myOrderClose(OP_SELL, 100, "");
  }
}

void myAlert(string type, string message)
{
  if (type == "print")
    Print(message);
  else if (type == "error")
  {
    Print(type + " | velas ea 3 @ " + Symbol() + "," + IntegerToString(Period()) + " | " + message);
  } else if (type == "order")
  {
  } else if (type == "modify")
  {
  }
}

int TradesCount(int type)  // returns # of open trades for order type, current symbol and magic number
{
  int result = 0;
  int total  = OrdersTotal();
  for (int i = 0; i < total; i++)
  {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) continue;
    if (OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderType() != type) continue;
    result++;
  }
  return (result);
}

datetime LastOpenTradeTime()
{
  datetime result = 0;
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
    if (OrderType() > 1) continue;
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
    {
      result = OrderOpenTime();
      break;
    }
  }
  return (result);
}

bool SelectLastHistoryTrade()
{
  int lastOrder = -1;
  int total     = OrdersHistoryTotal();
  for (int i = total - 1; i >= 0; i--)
  {
    if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
    {
      lastOrder = i;
      break;
    }
  }
  return (lastOrder >= 0);
}

double TotalOpenProfit(int direction)
{
  double result = 0;
  int    total  = OrdersTotal();
  for (int i = 0; i < total; i++)
  {
    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
    if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
    if ((direction < 0 && OrderType() == OP_BUY) || (direction > 0 && OrderType() == OP_SELL)) continue;
    result += OrderProfit();
  }
  return (result);
}

datetime LastOpenTime()
{
  datetime opentime1 = 0, opentime2 = 0;
  if (SelectLastHistoryTrade())
    opentime1 = OrderOpenTime();
  opentime2 = LastOpenTradeTime();
  if (opentime1 > opentime2)
    return opentime1;
  else
    return opentime2;
}

int myOrderSend(int type, double price, double volume, string ordername)  // send order, return ticket ("price" is irrelevant for market orders)
{
  if (!IsTradeAllowed()) return (-1);
  int    ticket        = -1;
  int    retries       = 0;
  int    err           = 0;
  int    long_trades   = TradesCount(OP_BUY);
  int    short_trades  = TradesCount(OP_SELL);
  int    long_pending  = TradesCount(OP_BUYLIMIT) + TradesCount(OP_BUYSTOP);
  int    short_pending = TradesCount(OP_SELLLIMIT) + TradesCount(OP_SELLSTOP);
  string ordername_    = ordername;
  if (ordername != "")
    ordername_ = "(" + ordername + ")";
  // test Hedging
  if (!Hedging && ((type % 2 == 0 && short_trades + short_pending > 0) || (type % 2 == 1 && long_trades + long_pending > 0)))
  {
    myAlert("print", "Order" + ordername_ + " not sent, hedging not allowed");
    return (-1);
  }
  // test maximum trades
  if ((type % 2 == 0 && long_trades >= MaxLongTrades) || (type % 2 == 1 && short_trades >= MaxShortTrades) || (long_trades + short_trades >= MaxOpenTrades) || (type > 1 && type % 2 == 0 && long_pending >= MaxLongPendingOrders) || (type > 1 && type % 2 == 1 && short_pending >= MaxShortPendingOrders) || (type > 1 && long_pending + short_pending >= MaxPendingOrders))
  {
    myAlert("print", "Order" + ordername_ + " not sent, maximum reached");
    return (-1);
  }
  // prepare to send order
  while (IsTradeContextBusy()) Sleep(100);
  RefreshRates();
  if (type == OP_BUY)
    price = Ask;
  else if (type == OP_SELL)
    price = Bid;
  else if (price < 0)  // invalid price for pending order
  {
    myAlert("order", "Order" + ordername_ + " not sent, invalid price for pending order");
    return (-1);
  }
  int clr = (type % 2 == 1) ? clrRed : clrBlue;
  while (ticket < 0 && retries < OrderRetry + 1)
  {
    ticket = OrderSend(Symbol(), type, NormalizeDouble(volume, LotDigits), NormalizeDouble(price, Digits()), MaxSlippage, 0, 0, ordername, MagicNumber, 0, clr);
    if (ticket < 0)
    {
      err = GetLastError();
      myAlert("print", "OrderSend" + ordername_ + " error #" + IntegerToString(err) + " " + ErrorDescription(err));
      Sleep(OrderWait * 1000);
    }
    retries++;
  }
  if (ticket < 0)
  {
    myAlert("error", "OrderSend" + ordername_ + " failed " + IntegerToString(OrderRetry + 1) + " times; error #" + IntegerToString(err) + " " + ErrorDescription(err));
    return (-1);
  }
  string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
  myAlert("order", "Order sent" + ordername_ + ": " + typestr[type] + " " + Symbol() + " Magic #" + IntegerToString(MagicNumber));
  return (ticket);
}

int myOrderModifyRel(int ticket, double SL, double TP)  // modify SL and TP (relative to open price), zero targets do not modify
{
  if (!IsTradeAllowed()) return (-1);
  bool success = false;
  int  retries = 0;
  int  err     = 0;
  SL           = NormalizeDouble(SL, Digits());
  TP           = NormalizeDouble(TP, Digits());
  if (SL < 0) SL = 0;
  if (TP < 0) TP = 0;
  // prepare to select order
  while (IsTradeContextBusy()) Sleep(100);
  if (!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
  {
    err = GetLastError();
    myAlert("error", "OrderSelect failed; error #" + IntegerToString(err) + " " + ErrorDescription(err));
    return (-1);
  }
  // prepare to modify order
  while (IsTradeContextBusy()) Sleep(100);
  RefreshRates();
  // convert relative to absolute
  if (OrderType() % 2 == 0)  // buy
  {
    if (NormalizeDouble(SL, Digits()) != 0)
      SL = OrderOpenPrice() - SL;
    if (NormalizeDouble(TP, Digits()) != 0)
      TP = OrderOpenPrice() + TP;
  } else  // sell
  {
    if (NormalizeDouble(SL, Digits()) != 0)
      SL = OrderOpenPrice() + SL;
    if (NormalizeDouble(TP, Digits()) != 0)
      TP = OrderOpenPrice() - TP;
  }
  if (CompareDoubles(SL, 0)) SL = OrderStopLoss();                                               // not to modify
  if (CompareDoubles(TP, 0)) TP = OrderTakeProfit();                                             // not to modify
  if (CompareDoubles(SL, OrderStopLoss()) && CompareDoubles(TP, OrderTakeProfit())) return (0);  // nothing to do
  while (!success && retries < OrderRetry + 1)
  {
    success = OrderModify(ticket, NormalizeDouble(OrderOpenPrice(), Digits()), NormalizeDouble(SL, Digits()), NormalizeDouble(TP, Digits()), OrderExpiration(), CLR_NONE);
    if (!success)
    {
      err = GetLastError();
      myAlert("print", "OrderModify error #" + IntegerToString(err) + " " + ErrorDescription(err));
      Sleep(OrderWait * 1000);
    }
    retries++;
  }
  if (!success)
  {
    myAlert("error", "OrderModify failed " + IntegerToString(OrderRetry + 1) + " times; error #" + IntegerToString(err) + " " + ErrorDescription(err));
    return (-1);
  }
  string alertstr = "Order modified: ticket=" + IntegerToString(ticket);
  if (!CompareDoubles(SL, 0)) alertstr = alertstr + " SL=" + DoubleToString(SL);
  if (!CompareDoubles(TP, 0)) alertstr = alertstr + " TP=" + DoubleToString(TP);
  myAlert("modify", alertstr);
  return (0);
}

void myOrderClose(int type, double volumepercent, string ordername)  // close open orders for current symbol, magic number and "type" (OP_BUY or OP_SELL)
{
  if (!IsTradeAllowed()) return;
  if (type > 1)
  {
    myAlert("error", "Invalid type in myOrderClose");
    return;
  }
  bool   success    = false;
  int    err        = 0;
  string ordername_ = ordername;
  if (ordername != "")
    ordername_ = "(" + ordername + ")";
  int total = OrdersTotal();
  int orderList[][2];
  int orderCount = 0;
  int i;
  for (i = 0; i < total; i++)
  {
    while (IsTradeContextBusy()) Sleep(100);
    if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
    if (OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderType() != type) continue;
    orderCount++;
    ArrayResize(orderList, orderCount);
    orderList[orderCount - 1][0] = (int)OrderOpenTime();
    orderList[orderCount - 1][1] = OrderTicket();
  }
  if (orderCount > 0)
    ArraySort(orderList, WHOLE_ARRAY, 0, MODE_ASCEND);
  for (i = 0; i < orderCount; i++)
  {
    if (!OrderSelect(orderList[i][1], SELECT_BY_TICKET, MODE_TRADES)) continue;
    while (IsTradeContextBusy()) Sleep(100);
    RefreshRates();
    double price  = (type == OP_SELL) ? Ask : Bid;
    double volume = NormalizeDouble(OrderLots() * volumepercent * 1.0 / 100, LotDigits);
    if (NormalizeDouble(volume, LotDigits) == 0) continue;
    success = OrderClose(OrderTicket(), volume, NormalizeDouble(price, Digits()), MaxSlippage, clrWhite);
    if (!success)
    {
      err = GetLastError();
      myAlert("error", "OrderClose" + ordername_ + " failed; error #" + IntegerToString(err) + " " + ErrorDescription(err));
    }
  }
  string typestr[6] = {"Buy", "Sell", "Buy Limit", "Sell Limit", "Buy Stop", "Sell Stop"};
  if (success) myAlert("order", "Orders closed" + ordername_ + ": " + typestr[type] + " " + Symbol() + " Magic #" + IntegerToString(MagicNumber));
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  SideController = new CSideControl(SideControl, MagicNumber);
  // initialize myPoint
  myPoint = Point();
  if (Digits() == 5 || Digits() == 3)
  {
    myPoint *= 10;
    MaxSlippage *= 10;
  }
  // initialize LotDigits
  double LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
  if (NormalizeDouble(LotStep, 3) == round(LotStep))
    LotDigits = 0;
  else if (NormalizeDouble(10 * LotStep, 3) == round(10 * LotStep))
    LotDigits = 1;
  else if (NormalizeDouble(100 * LotStep, 3) == round(100 * LotStep))
    LotDigits = 2;
  else
    LotDigits = 3;
  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  SideController.SearchFirstTk();
  SideController.SetSide();
  
	int    ticket = -1;
  double price;
  double TradeSize;
  double SL;
  double TP;

  CloseTradesAtPL(CloseAtPL);

  // Open Buy Order
  RefreshRates();
  if (iCustom(NULL, PERIOD_CURRENT, "TMA+CG mladen 1.1", "current time frame", 56, PRICE_WEIGHTED, 1.618, true, false, false, false, false, false, false, 2, 1) > Bid  // TMA+CG mladen 1.1 > Price
      && Close[2] < Open[2]                                                                                                                                            // Candlestick Close < Candlestick Open
      && Close[1] > Open[2]                                                                                                                                            // Candlestick Close > Candlestick Open
      && (MathMin(Open[1], Close[1]) - Low[1]) < MathAbs(Open[1] - Close[1]) * 0.5                                                                                     // Candlestick Lower Wick < Candlestick Body * fixed value
      && (High[1] - MathMax(Open[1], Close[1])) > MathAbs(Open[1] - Close[1]) * 0.5                                                                                    // Candlestick Upper Wick > Candlestick Body * fixed value
  )
  {
    RefreshRates();
    price     = Ask;
    SL        = SL_Points * myPoint;  // Stop Loss = value in points (relative to price)
    TradeSize = MM_Size(SL);
    TP        = TP_Points * myPoint;                                                        // Take Profit = value in points (relative to price)
    if (TimeCurrent() - LastOpenTime() < NextOpenTradeAfterBars * PeriodSeconds()) return;  // next open trade after time after previous trade's open
    if (IsTradeAllowed())
    {
			if(!SideController.doControl(0)) { return; }

      ticket = myOrderSend(OP_BUY, price, TradeSize, "");
      if (ticket <= 0) return;
    } else  // not autotrading => only send alert
      myAlert("order", "");
    myOrderModifyRel(ticket, SL, 0);
    myOrderModifyRel(ticket, 0, TP);
  }

  // Open Sell Order
  RefreshRates();
  if (iCustom(NULL, PERIOD_CURRENT, "TMA+CG mladen 1.1", "current time frame", 56, PRICE_WEIGHTED, 1.618, true, false, false, false, false, false, false, 1, 1) < Bid  // TMA+CG mladen 1.1 < Price
      && Close[2] > Open[2]                                                                                                                                            // Candlestick Close > Candlestick Open
      && Close[1] < Open[2]                                                                                                                                            // Candlestick Close < Candlestick Open
      && (MathMin(Open[1], Close[1]) - Low[1]) > MathAbs(Open[1] - Close[1]) * 0.5                                                                                     // Candlestick Lower Wick > Candlestick Body * fixed value
      && (High[1] - MathMax(Open[1], Close[1])) < MathAbs(Open[1] - Close[1]) * 0.5                                                                                    // Candlestick Upper Wick < Candlestick Body * fixed value
  )
  {
    RefreshRates();
    price     = Bid;
    SL        = SL_Points * myPoint;  // Stop Loss = value in points (relative to price)
    TradeSize = MM_Size(SL);
    TP        = TP_Points * myPoint;                                                        // Take Profit = value in points (relative to price)
    if (TimeCurrent() - LastOpenTime() < NextOpenTradeAfterBars * PeriodSeconds()) return;  // next open trade after time after previous trade's open
    if (IsTradeAllowed())
    {
			if(!SideController.doControl(1)) { return; }

      ticket = myOrderSend(OP_SELL, price, TradeSize, "");
      if (ticket <= 0) return;
    } else  // not autotrading => only send alert
      myAlert("order", "");
    myOrderModifyRel(ticket, SL, 0);
    myOrderModifyRel(ticket, 0, TP);
  }
}
//+------------------------------------------------------------------+

/*

1. cuando no hay ordenes no hay side
2. al abrir la primera, se setea el side
3. luego cada vez que intenta abir hay que controlar que solo sea para el lado permitido: 
4. mantener el side hasta que no haya trades abiertos

*/

