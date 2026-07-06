// More information about this indicator can be found at:
// http://fxcodebase.com/ 

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

//+------------------------------------------------------------------------------------------------+
//|SOL Address            : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                           |
//|Cardano/ADA            : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv             |  
//|Dogecoin Address       : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                     |
//|SHIB Address           : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                             |                                
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#include <stdlib.mqh>

#define BUY_MAP 1
#define SELL_MAP 0
#define HOLD_MAP 2

//Map size for BUY and SELL
#define MAPBASE 10000
//Map size for HOLD
#define HOLDBASE 25000
//Number of map memory-cells for each bar
#define VBASE 7

int    LastBars = 0;
double vector[VBASE];   //Vector with memory-cells for current bar
double vectorp[VBASE];  //Vector with memory-cells for previous bar

//3 Maps
double MapBuy[MAPBASE][VBASE];
double MapSell[MAPBASE][VBASE];
double MapHold[HOLDBASE][VBASE];

//Min and Max amounts of pips of profit to consider teaching BUY and SELL maps
extern int MinPips = 5;
extern int MaxPips = 43;

extern int TakeProfit = 150;
extern int StopLoss   = 100;

//20100820 JT - Set Lots to 0 to use sqrt of AccountBalance
extern string mm           = "Set Lots to 0 to use sqrt of AccountBalance";
extern double Lots         = 0.01;  //20100820 JT - Changed to be less aggressive default
extern double MaxLots      = 3;     //20100820 JT - Changed to be less aggressive maximum
extern string mm1          = "Adjust this to be more conservative or aggressive";
extern double Lots_Per_10K = 1.0;

extern double Slippage = 3;

extern string MapPath = "rl.txt";
extern string EAName  = "RowLearner";
string        myMapPath;

int Magic;

double TLots;

// Item 1
double myPoint;

// 20100820 JT - Pseudo-constants
static double C_MinLots;        // Min qty that can be traded
static double C_MaxLots;        // Max qty that can be traded
static double C_LotValue;       // Value of 1 lot in base currency
static double C_LotStep;        // Min lot increment
static int    C_LotStepDigits;  // Dec. places of lot step
static double C_StopLevelVal;   // e.g. 0.0002
static double C_Point;          // Size of minimum price move
// End add pseudo-constants

// add reverse mode
// when the trade close,
// close actual trade, and open in reverse
//+------------------------------------------------------------------+
input bool stopAndReverse = false;  // Stop and Reverse in losing Trade:

//+-----------------------------------------------------------------+
//| expert initialization function                                  |
//+-----------------------------------------------------------------+
// int init()
int OnInit()
{
   Magic     = Period() + 1937004;
   myMapPath = Symbol() + "_" + MapPath;
   // cav - OrdersList to control orders
   Orders = new OrdersList(Magic, true);

   // Robert added Item 1 - replace Point with myPoint
   myPoint = GetPoint(Symbol());
   InitKohonenMap();

   LoadKohonenMap();

   TLots = Lots;

   return (0);
   // 20100820 JT - Cache MarketInfo
   C_MinLots      = MarketInfo(Symbol(), MODE_MINLOT);
   C_MaxLots      = MarketInfo(Symbol(), MODE_MAXLOT);
   C_LotValue     = MarketInfo(Symbol(), MODE_LOTSIZE);
   C_LotStep      = MarketInfo(Symbol(), MODE_LOTSTEP);
   C_Point        = MarketInfo(Symbol(), MODE_POINT);
   double lotStep = C_LotStep;
   while (lotStep < 1)
   {
      lotStep = lotStep * 10;
      C_LotStepDigits += 1;
   }
   C_StopLevelVal = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
   // End cache MarketInfo

   //20100820 JT - Adjust params (crudely) for different point sizes
   if (C_Point == 0.00001 || C_Point == 0.001)
   {
      Slippage *= 3;
   }
   // End point size adjustment
}

//+---------------------------------------------- -------------------+
//| main expert function                                             |
//+---------------------------------------------- -------------------+
// int start()
void OnTick()
{
   if (Bars < 7) return;

   // Reverse Control
   //+------------------------------------------------------------------+
   if(stopAndReverse)
   {
      doStopAndReverse();
      Orders.GetMarketOrders();
      Orders.cleanCloseOrders();
   }

   //Wait for the new Bar in a chart.
   if (LastBars == Bars)
      return;
   else
      LastBars = Bars;

   // CloseAllOrders();// me parece que no tiene sentido cerrar todo en cada vela ??

   double bmu[3] = {0, 0, 0};

   //Calculating the Tom Demark's pivot points over last 5 bars
   double hi[5] = {0, 0, 0, 0, 0};
   double lo[5] = {0, 0, 0, 0, 0};

   hi[0] = High[2];
   hi[1] = High[3];
   hi[2] = High[4];
   hi[3] = High[5];
   hi[4] = High[6];

   lo[0] = Low[2];
   lo[1] = Low[3];
   lo[2] = Low[4];
   lo[3] = Low[5];
   lo[4] = Low[6];

   double H = hi[ArrayMaximum(hi)];
   double L = lo[ArrayMinimum(lo)];

   vectorp[0] = (H + L + Close[2]) / 3;
   //The difference between pivots and Open price is used to normalize statistics
   vectorp[1] = (2 * vectorp[0] - L) - Open[1];
   vectorp[2] = (vectorp[0] + H - L) - Open[1];
   vectorp[3] = (H + 2 * (vectorp[0] - L)) - Open[1];
   vectorp[4] = (2 * vectorp[0] - H) - Open[1];
   vectorp[5] = (vectorp[0] - H + L) - Open[1];
   vectorp[6] = (L - 2 * (H - vectorp[0])) - Open[1];
   vectorp[0] = vectorp[0] - Open[1];

   hi[0] = High[1];
   hi[1] = High[2];
   hi[2] = High[3];
   hi[3] = High[4];
   hi[4] = High[5];

   lo[0] = Low[1];
   lo[1] = Low[2];
   lo[2] = Low[3];
   lo[3] = Low[4];
   lo[4] = Low[5];

   H = hi[ArrayMaximum(hi)];
   L = lo[ArrayMinimum(lo)];

   vector[0] = (H + L + Close[1]) / 3;
   vector[1] = (2 * vector[0] - L) - Open[0];
   vector[2] = (vector[0] + H - L) - Open[0];
   vector[3] = (H + 2 * (vector[0] - L)) - Open[0];
   vector[4] = (2 * vector[0] - H) - Open[0];
   vector[5] = (vector[0] - H + L) - Open[0];
   vector[6] = (L - 2 * (H - vector[0])) - Open[0];
   vector[0] = vector[0] - Open[0];

   MapLookup(vector, bmu);

   TLots = CalculateLotSize();


   Print("BMU Buy: ", bmu[0], " BMU Sell: ", bmu[1], " BMU Hold: ", bmu[2]);

   if ((NormalizeDouble((Open[0] - Open[1]), Digits) >= NormalizeDouble((MinPips * myPoint), Digits)) && (NormalizeDouble((Open[0] - Open[1]), Digits) <= NormalizeDouble((MaxPips * myPoint), Digits)))
      TeachMap(BUY_MAP, vectorp);
   else if ((NormalizeDouble((Open[0] - Open[1]), Digits) <= -NormalizeDouble((MinPips * myPoint), Digits)) && (NormalizeDouble((Open[0] - Open[1]), Digits) >= -NormalizeDouble((MaxPips * myPoint), Digits)))
      TeachMap(SELL_MAP, vectorp);
   else
      TeachMap(HOLD_MAP, vectorp);

   


   return;
}
//+---------------------------------------------- -------------------+

//+---------------------------------------------- -------------------+
// | expert deinitialization function |
//+---------------------------------------------- -------------------+
// int deinit()
void OnDeinit(const int reason)
{
   SaveKohonenMap();
}

//+---------------------------------------------- -------------------+
//| Close all open orders                                            |
//+---------------------------------------------- -------------------+
void CloseAllOrders()
{
   int total = OrdersTotal();
   // Robert corrected loop order for proper close of Orders
   for (int pos = total - 1; pos >= 0; pos--)
   {
      if (OrderSelect(pos, SELECT_BY_POS) == true)
      {
         if (OrderMagicNumber() != Magic) continue;
         if (OrderSymbol() != Symbol()) continue;
         int err   = 0;
         int count = 0;
         while ((err != 1) && (count < 10))
         {
            if (CheckOpenPositions() == 0) return;  // Ue CheckOpenPosition in case other orders not of this EA are open
            count++;
            RefreshRates();
            if (OrderType() == OP_SELL)
               err = OrderClose(OrderTicket(), OrderLots(), Ask, 10, Violet);  //Close position
            else if (OrderType() == OP_BUY)
               err = OrderClose(OrderTicket(), OrderLots(), Bid, 10, Violet);  //Close position
         }
      }
   }
}

// Robert modified for opening orders with ECN brokers
void Buy()
{
   int    err;
   double TPprice, STprice;
   int    result = -1;
   int    count  = 0;
   while ((result == -1) && (count < 10))
   {
      RefreshRates();
      count++;
      if (IsTradeAllowed())
      {
         result = OrderSend(Symbol(), OP_BUY, TLots, Ask, Slippage, 0, 0, "", Magic, 0, Green);
         if (result > 0)
         {
            OrderSelect(result, SELECT_BY_TICKET, MODE_TRADES);
            if (StopLoss != 0 || TakeProfit != 0)
            {
               TPprice = 0.0;
               if (TakeProfit > 0) TPprice = OrderOpenPrice() + TakeProfit * myPoint;
               STprice = 0.0;
               if (StopLoss > 0) STprice = OrderOpenPrice() - StopLoss * myPoint;
               // Normalize stoploss / takeprofit to the proper # of digits.
               if (Digits > 0)
               {
                  STprice = NormalizeDouble(STprice, Digits);
                  TPprice = NormalizeDouble(TPprice, Digits);
               }
               ModifyOrder(result, OrderOpenPrice(), STprice, TPprice, LightGreen);
            }
         }
      }
      if (result == -1)
      {
         err = GetLastError();
         Print("OrderSend failed with error(" + err + ") " + ErrorDescription(err));
      }
   }
}

// Robert modified for opening orders with ECN brokers
void Sell()
{
   int    err;
   double TPprice, STprice;
   int    result = -1;
   int    count  = 0;
   while ((result == -1) && (count < 10))
   {
      RefreshRates();
      count++;
      if (IsTradeAllowed())
      {
         result = OrderSend(Symbol(), OP_SELL, TLots, Bid, Slippage, 0, 0, "", Magic, 0, Red);
         if (result > 0)
         {
            OrderSelect(result, SELECT_BY_TICKET, MODE_TRADES);
            if (StopLoss != 0 || TakeProfit != 0)
            {
               TPprice = 0.0;
               if (TakeProfit > 0) TPprice = OrderOpenPrice() - TakeProfit * myPoint;
               STprice = 0.0;
               if (StopLoss > 0) STprice = OrderOpenPrice() + StopLoss * myPoint;
               // Normalize stoploss / takeprofit to the proper # of digits.
               if (Digits > 0)
               {
                  STprice = NormalizeDouble(STprice, Digits);
                  TPprice = NormalizeDouble(TPprice, Digits);
               }
               ModifyOrder(result, OrderOpenPrice(), STprice, TPprice, LightGreen);
            }
         }
      }

      if (result == -1)
      {
         err = GetLastError();
         Print("OrderSend failed with error(" + err + ") " + ErrorDescription(err));
      }
   }
}

//+---------------------------------------------- -------------------+
//| Modify Open Position Controls                                    |
//|  Try to modify position 3 times                                  |
//+---------------------------------------------- -------------------+
void ModifyOrder(int ord_ticket, double op, double price, double tp, color mColor)
{
   int CloseCnt, err;

   CloseCnt = 0;
   while (CloseCnt < 3)
   {
      if (OrderModify(ord_ticket, op, price, tp, 0, mColor))
      {
         CloseCnt = 3;
      } else
      {
         err = GetLastError();
         Print(CloseCnt, " Error modifying order : (", err, ") " + ErrorDescription(err));
         if (err > 0) CloseCnt++;
      }
   }
}

void InitKohonenMap()
{
   for (int i = 0; i < MAPBASE; i++)
   {
      for (int v = 0; v < VBASE; v++)
      {
         MapSell[i][v] = 0;
         MapBuy[i][v]  = 0;
      }
   }
   for (int i = 0; i < HOLDBASE; i++)
   {
      for (int v = 0; v < VBASE; v++)
      {
         MapHold[i][v] = 0;
      }
   }
}

void MapLookup(double& vector[], double& BMU[])
{
   BMU[0] = FindBMU(BUY_MAP, vector);

   BMU[1] = FindBMU(SELL_MAP, vector);

   BMU[2] = FindBMU(HOLD_MAP, vector);

   int i = 0;

   double vec[VBASE];
   //BUY
   for (i = 0; i < MAPBASE; i++)
   {
      int z = 0;
      for (int v = 0; v < VBASE; v++)
      {
         if (MapBuy[i][v] == 0) z++;
         vec[v] = MapBuy[i][v];
      }
      if (z == VBASE) break;

      double E = EuclidDistance(vec, vector);
   }

   //SELL
   for (i = 0; i < MAPBASE; i++)
   {
      int z = 0;
      for (int v = 0; v < VBASE; v++)
      {
         if (MapSell[i][v] == 0) z++;
         vec[v] = MapSell[i][v];
      }
      if (z == VBASE) break;

      double E = EuclidDistance(vec, vector);
   }

   //HOLD
   for (i = 0; i < HOLDBASE; i++)
   {
      int z = 0;
      for (int v = 0; v < VBASE; v++)
      {
         if (MapHold[i][v] == 0) z++;
         vec[v] = MapHold[i][v];
      }
      if (z == VBASE) break;

      double E = EuclidDistance(vec, vector);
   }
}

double FindBMU(int Buy, double& vector[])
{
   int N = 0;

   if (Buy == 1)
      N = MAPBASE;
   else if (Buy == 0)
      N = MAPBASE;
   else
      N = HOLDBASE;

   double BestEuclidDistance = 9999999;
   double vec[VBASE];
   for (int i = 0; i < N; i++)
   {
      double E;
      for (int v = 0; v < VBASE; v++)
      {
         if (Buy == 1)
            vec[v] = MapBuy[i][v];
         else if (Buy == 0)
            vec[v] = MapSell[i][v];
         else
            vec[v] = MapHold[i][v];
      }
      E = EuclidDistance(vec, vector);
      if (E < BestEuclidDistance)
      {
         BestEuclidDistance = E;
      }
   }

   return (BestEuclidDistance);
}

double EuclidDistance(double& VectorFromMap[], double& vector[])
{
   double E = 0;

   for (int v = 0; v < VBASE; v++)
   {
      E += MathPow((VectorFromMap[v] * 10000 - vector[v] * 10000), 2);
   }

   E = MathSqrt(E);

   return (E);
}

void TeachMap(int Buy, double& vector[])
{
   int BMUx = -1;

   int N;

   int x;

   if (Buy == 1)
      N = MAPBASE;
   else if (Buy == 0)
      N = MAPBASE;
   else
      N = HOLDBASE;

   for (x = 0; x < N; x++)
   {
      bool flag = false;
      for (int v = 0; v < VBASE; v++)
      {
         if (Buy == 1)
         {
            if (MapBuy[x][v] != 0) flag = true;
         } else if (Buy == 0)
         {
            if (MapSell[x][v] != 0) flag = true;
         } else
         {
            if (MapHold[x][v] != 0) flag = true;
         }
      }
      if (flag == false) break;
   }

   for (int v = 0; v < VBASE; v++)
   {
      if (Buy == 1)
         MapBuy[x][v] = vector[v];
      else if (Buy == 0)
         MapSell[x][v] = vector[v];
      else
         MapHold[x][v] = vector[v];
   }
}

void LoadKohonenMap()
{
   int err;
   int handle = FileOpen(myMapPath, FILE_BIN | FILE_WRITE | FILE_READ);
   if (handle < 1)
   {
      err = GetLastError();
      Print("File couldn't be opened; the last error is ", err, ":", ErrorDescription(err));
      return;
   }
   FileReadArray(handle, MapBuy, 0, MAPBASE * VBASE);
   FileReadArray(handle, MapSell, 0, MAPBASE * VBASE);
   FileReadArray(handle, MapHold, 0, HOLDBASE * VBASE);
   FileClose(handle);
}

void SaveKohonenMap()
{
   int err;
   int handle = FileOpen(myMapPath, FILE_BIN | FILE_WRITE | FILE_READ);
   if (handle < 1)
   {
      err = GetLastError();
      Print("File couldn't be opened; the last error is ", err, ":", ErrorDescription(err));
      return;
   }
   FileWriteArray(handle, MapBuy, 0, MAPBASE * VBASE);
   FileWriteArray(handle, MapSell, 0, MAPBASE * VBASE);
   FileWriteArray(handle, MapHold, 0, HOLDBASE * VBASE);
}

double GetPoint(string sym)
{
   // double _Point;
   // int    _Digits = MarketInfo(sym, MODE_DIGITS);
   // if (_Digits < 4)
   //    _Point = 0.01;
   // else
   //    _Point = 0.0001;

   //--- cav new version 2
   return MarketInfo(sym, MODE_POINT);
}

//+---------------------------------------------- -------------------+
//| Check Open Position Controls                                     |
//+---------------------------------------------- -------------------+

int CheckOpenPositions()
{
   int cnt, NumPositions;
   int NumBuyTrades, NumSellTrades;  // Number of buy and sell trades in this symbol

   NumBuyTrades  = 0;
   NumSellTrades = 0;
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol()) continue;
      if (OrderMagicNumber() != Magic) continue;

      if (OrderType() == OP_BUY) NumBuyTrades++;
      if (OrderType() == OP_SELL) NumSellTrades++;
   }
   NumPositions = NumBuyTrades + NumSellTrades;
   return (NumPositions);
}

double CalculateLotSize()
{
   double result = 0;

   if (Lots > 0)
   {
      result = Lots;
   } else
   {
      double startLots = 1.0 * MathSqrt(AccountBalance()) / 100;
      double pow2      = 1.0 / Lots_Per_10K;
      double minLot    = MarketInfo(Symbol(), MODE_MINLOT);

      result = FormatLotSize(MathMax(1.0 * startLots / pow2, minLot));
   }

   return (result);
}

double FormatLotSize(double dLots)
{
   double lots = StrToDouble(DoubleToStr(dLots, C_LotStepDigits));
   if (lots < C_MinLots) lots = C_MinLots;
   if (lots > MaxLots) lots = MaxLots;
   if (lots > C_MaxLots) lots = C_MaxLots;

   return (lots);
}

// add open tk to order array to control reverse mode
//+------------------------------------------------------------------+
void doStopAndReverse()
{
   if (Orders.qnt() == 0) return;

   for (int i = 0; i < Orders.qnt(); i++)
   {
      if (Orders.isClose(i) && OrderProfit() < 0 )
      {
         if(OrderComment()!="reverse")
         OpenReverse(OrderTicket());
      }
   }   
}

bool OpenReverse(int tk)
{
   OrderSelect(tk, SELECT_BY_TICKET);
   ENUM_ORDER_TYPE type = OrderType() == OP_BUY ? OP_SELL : OP_BUY;
   double          openPrice = OrderType() == OP_BUY ? Bid : Ask;
   double          lot                     = OrderLots();
   color           orderColor = OrderType() == OP_BUY ? Green : Red;

   int ctrl = OrderSend(Symbol(), type, lot, openPrice, Slippage, 0, 0, "reverse", Magic, 0, orderColor);
   
   if (ctrl > 0)
   {
      Print(__FUNCTION__," REVERSE TRADE OPEN "," tk:"," ",tk," | new tk: ",ctrl );
      setTPSL(ctrl);
      return false;
   }

   return true;
}

void setTPSL(int tk)
{
   OrderSelect(tk, SELECT_BY_TICKET, MODE_TRADES);
   double TPprice = 0.0;
   double STprice = 0.0;


   if (OrderType() == OP_BUY)
   {
      if (StopLoss != 0 || TakeProfit != 0)
      {
         if (TakeProfit > 0) TPprice = OrderOpenPrice() + TakeProfit * myPoint;
         if (StopLoss > 0) STprice = OrderOpenPrice() - StopLoss * myPoint;
         if (Digits > 0)
         {
            STprice = NormalizeDouble(STprice, Digits);
            TPprice = NormalizeDouble(TPprice, Digits);
         }
         ModifyOrder(tk, OrderOpenPrice(), STprice, TPprice, LightGreen);
      }
   }

   if (OrderType() == OP_SELL)
   {
      if (StopLoss != 0 || TakeProfit != 0)
      {
         if (TakeProfit > 0) TPprice = OrderOpenPrice() - TakeProfit * myPoint;
         if (StopLoss > 0) STprice = OrderOpenPrice() + StopLoss * myPoint;
         if (Digits > 0)
         {
            STprice = NormalizeDouble(STprice, Digits);
            TPprice = NormalizeDouble(TPprice, Digits);
         }
         ModifyOrder(tk, OrderOpenPrice(), STprice, TPprice, LightGreen);
      }
   }
}




//+------------------------------------------------------------------+
class Order
{
   int             _id;
   string          _symbol;
   double          _price;
   double          _sl;
   double          _tp;
   double          _lot;
   ENUM_ORDER_TYPE _type;
   int             _magic;
   string          _comment;
   string          _strategy;
   datetime        _expireTime;
   datetime        _signalTime;
   double          _profit;

  public:
   Order(
       int             id,
       string          symbol,
       double          price,
       double          sl,
       double          tp,
       double          lot,
       int             type,
       int             magic,
       string          comment,
       string          strategy,
       datetime        expireTime,
       datetime        signalTime,
       double          profit) : _id(id),
                        _symbol(symbol),
                        _price(price),
                        _sl(sl),
                        _tp(tp),
                        _lot(lot),
                        _type(type),
                        _magic(magic),
                        _comment(comment),
                        _strategy(strategy),
                        _expireTime(expireTime),
                        _signalTime(signalTime),
                        _profit(profit) {}

   Order() {}
   ~Order() {}
   
   // clang-format off
	Order* SetId(int id){_id=id; return &this;}
	Order* SetSymbol(string symbol){_symbol=symbol; return &this;}
	Order* SetPrice(double price){_price=price; return &this;}
	Order* SetSl(double sl){_sl=sl; return &this;}
	Order* SetTp(double tp){_tp=tp; return &this;}
	Order* SetLot(double lot){_lot=lot; return &this;}
	Order* SetType(int type){_type=type; return &this;}
	Order* SetMagic(int magic){_magic=magic; return &this;}
	Order* SetComment(string comment){_comment=comment; return &this;}
	Order* SetStrategy(string strategy){_strategy=strategy; return &this;}
	Order* SetExpireTime(datetime expireTm){_expireTime=expireTm; return &this;}
	Order* SetSignalTime(datetime signalTm){_signalTime=signalTm; return &this;}
	Order* SetProfit(double profit){_profit=profit; return &this;}

   int            id() { return _id; }
   string         symbol() { return _symbol; }
   double         price() { return _price; }
   double         sl() { return _sl; }
   double         tp() { return _tp; }
   double         lot() { return _lot; }
   int            type() { return _type; }
   int            magic() { return _magic; }
   string         comment() { return _comment; }
   string         strategy() { return _strategy; }
   datetime       expireTime() { return _expireTime; }
   datetime       signalTime() { return _signalTime; }
   double         profit() { return _profit; }
};


class OrdersList
{
   Order* orders[];
   int    _magic;
   bool   _useMagic;

  public:
   
   OrdersList() 
   { 
      _useMagic = false;
      Print("New OrderList Created");
   }

   OrdersList(int magic, bool useMagic) : _magic(magic), _useMagic(useMagic){Print("New OrderList Created");};
   ~OrdersList() { clearList(); }

   //+------------------------------------------------------------------+
   bool AddOrder(Order* order)
   {
      int t = ArraySize(orders);
      if (ArrayResize(orders, t + 1))
      {
         orders[t] = order;
         return true;
      }

      return false;
   }

   // recorrer las ordenes de mercado y agregar las que no estén en el array
   //+------------------------------------------------------------------+
   void GetMarketOrders()
   {
      for (int i = 0; i < OrdersTotal(); i++)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
				if( _useMagic && OrderMagicNumber()!=_magic ) { continue; }
            if( exist(OrderTicket()) ){ continue;}

			   Order* newOrder = new Order();
				newOrder.SetId(OrderTicket())
					.SetSymbol(OrderSymbol())
					.SetPrice(OrderOpenPrice())
					.SetSl(OrderStopLoss())
					.SetTp(OrderTakeProfit())
					.SetLot(OrderLots())
					.SetType(OrderType())
					.SetMagic(OrderMagicNumber())
					.SetComment(OrderComment())
					.SetExpireTime(OrderExpiration())
					.SetProfit(OrderProfit());

   				if(AddOrder(newOrder)) { PrintOrder(i); }
         }
      }
   }

   // controlar si el id ya está adentro del array
   //+------------------------------------------------------------------+
   bool exist(int id)
   {
      for (int i = 0; i < qnt(); i++)
      {
         if (id(i) == id) { return true; }
      }
      return false;
   }

   // borra una orden en la posición indicada y acomoda el array
   //+------------------------------------------------------------------+
   bool deleteOrder(int index)
   {
      if (notOverFlow(index))
      {
         delete orders[index];
      }

      if (qnt() > index)
      {
         for (int i = index; i < qnt() - 1; i++)
         {
            orders[i] = orders[i + 1];
         }
         ArrayResize(orders, qnt() - 1);
         return true;
      }

      return false;
   }
   
	// borra todos los elementos de la lista
   //+------------------------------------------------------------------+
   void clearList()
   {
      for (int i = 0; i < qnt(); i++)
      {
         if (CheckPointer(orders[i]) != POINTER_INVALID)
         {
            deleteOrder(i);
         }
      }
   }

   //+------------------------------------------------------------------+
   bool notOverFlow(int index)
   {
      if (index > ArraySize(orders) - 1) return false;
      if (index < 0) return false;
      if (CheckPointer(orders[index]) == POINTER_INVALID) return false;

      return true;
   }

   // cantidad de ordenes guardadas
   //+------------------------------------------------------------------+
   int qnt()
   {
      return ArraySize(orders);
   }

	// clang-format off 
	
	// Metodos para acceder a información de cada trade mediante su index:
	//+------------------------------------------------------------------+
	int      id(int index)             { if (notOverFlow(index)) { return orders[index].id(); } return -1; }
	string   symbol(int index)         { if (notOverFlow(index)) { return orders[index].symbol(); } return ""; }
	double   price(int index)          { if (notOverFlow(index)) { return orders[index].price(); } return -1; }
	double   sl(int index)             { if (notOverFlow(index)) { return orders[index].sl(); } return -1; }
	double   tp(int index)             { if (notOverFlow(index)) { return orders[index].tp(); } return -1; }
	double   lot(int index)            { if (notOverFlow(index)) { return orders[index].lot(); } return -1; }
	int      magic(int index)          { if (notOverFlow(index)) { return orders[index].magic(); } return -1; }
	datetime expire(int index)         { if (notOverFlow(index)) { return orders[index].expireTime(); } return -1; }
	datetime signalTime(int index)     { if (notOverFlow(index)) { return orders[index].signalTime(); } return -1; }
	string   comment(int index)        { if (notOverFlow(index)) { return orders[index].comment(); } return ""; }
	ENUM_ORDER_TYPE type(int index)    { if (notOverFlow(index)) { return orders[index].type(); } return -1; }
	// clang-format on

	// comprueba si la orden está cerrada
	//+------------------------------------------------------------------+
	bool isClose(int index)
	{
		if(notOverFlow(index)) {
			if (OrderSelect(id(index), SELECT_BY_TICKET))
			{
				if(OrderCloseTime()!= 0)return true;
			}
		}
		return false;                
   }

	// borra de la lista los trades cerrados
	//+------------------------------------------------------------------+
	void cleanCloseOrders()
	{
		if (qnt() == 0) { return; }

      for (int i = 0; i < qnt(); i++)
      {
         if (isClose(i)) { deleteOrder(i); }
      }
	}

   //+------------------------------------------------------------------+
   void PrintOrder(const int index)
   {
      if (!notOverFlow(index)) { return; }
      if (CheckPointer(orders[index]) == POINTER_INVALID) { return; }
      // clang-format off
      Print("Order ", index, " id: ",          orders[index].id());
      Print("Order ", index, " symbol: ",      orders[index].symbol());
      Print("Order ", index, " type: ",        orders[index].type());
      Print("Order ", index, " lot: ",         orders[index].lot());
      Print("Order ", index, " price: ",       orders[index].price());
      Print("Order ", index, " sl: ",          orders[index].sl());
      Print("Order ", index, " tp: ",          orders[index].tp());
      Print("Order ", index, " magic: ",       orders[index].magic());
      Print("Order ", index, " comment: ",     orders[index].comment());
      Print("Order ", index, " strategy: ",    orders[index].strategy());
      Print("Order ", index, " expire time: ", orders[index].expireTime());
      Print("Order ", index, " signal time: ", orders[index].signalTime());
      Print("Order ", index, " profit: ",      orders[index].profit());
      // clang-format on
   }
   //+------------------------------------------------------------------+
   void PrintList()
   {
      for (int i = 0; i < qnt(); i++) 
      {
         PrintOrder(i);
      }
   }
};

OrdersList* Orders;

