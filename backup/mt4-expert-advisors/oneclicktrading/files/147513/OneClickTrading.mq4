// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72734

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
#property strict
// Includes
#include <Controls/Button.mqh>
CButton bt1, bt2;

string symbol;
double lots;
bool   tpOn;
double tpPips;
bool   slOn;
double slPips;

enum Side {
  Buy,
  Sell,
};
Side _side;

// Gobal Variables
input int    magico    = 2022;                   // Magic Number:
input string T1        = "== Trade 1 Setup ==";  // == Trade 1 Setup ==
input bool   t1_ON     = true;                   // Trade 1 ON:
input string t1_sym    = "EURUSD";               // Instrument:
input Side   t1_Side   = Buy;                    // Side:
input double t1_Lots   = 1;                      // Lots:
input bool   t1_TPOn   = true;                   // Take Profit ON:
input double t1_TPPips = 30;                     // Take Profit in Pips:
input bool   t1_SLOn   = true;                   // StopLoss ON:
input double t1_SLPips = 30;                     // StopLoss in Pips:
input string T2        = "== Trade 2 Setup ==";  // == Trade 2 Setup ==
input bool   t2_ON     = true;                   // Trade 2 ON:
input string t2_sym    = "GBPUSD";               // Instrument:
input Side   t2_Side   = Sell;                   // Side:
input double t2_Lots   = 1;                      // Lots:
input bool   t2_TPOn   = true;                   // Take Profit ON:
input double t2_TPPips = 30;                     // Take Profit in Pips:
input bool   t2_SLOn   = true;                   // StopLoss ON:
input double t2_SLPips = 30;                     // StopLoss in Pips:
input string T3        = "== Trade 3 Setup ==";  // == Trade 3 Setup ==
input bool   t3_ON     = false;                  // Trade 3 ON:
input string t3_sym    = "EURUSD";               // Instrument:
input Side   t3_Side   = Buy;                    // Side:
input double t3_Lots   = 1;                      // Lots:
input bool   t3_TPOn   = false;                  // Take Profit ON:
input double t3_TPPips = 30;                     // Take Profit in Pips:
input bool   t3_SLOn   = false;                  // StopLoss ON:
input double t3_SLPips = 30;                     // StopLoss in Pips:
input string T4        = "== Trade 4 Setup ==";  // == Trade 4 Setup ==
input bool   t4_ON     = false;                  // Trade 4 ON:
input string t4_sym    = "EURUSD";               // Instrument:
input Side   t4_Side   = Buy;                    // Side:
input double t4_Lots   = 1;                      // Lots:
input bool   t4_TPOn   = false;                  // Take Profit ON:
input double t4_TPPips = 30;                     // Take Profit in Pips:
input bool   t4_SLOn   = false;                  // StopLoss ON:
input double t4_SLPips = 30;                     // StopLoss in Pips:
input string T5        = "== Trade 5 Setup ==";  // == Trade 5 Setup ==
input bool   t5_ON     = false;                  // Trade 5 ON:
input string t5_sym    = "EURUSD";               // Instrument:
input Side   t5_Side   = Buy;                    // Side:
input double t5_Lots   = 1;                      // Lots:
input bool   t5_TPOn   = false;                  // Take Profit ON:
input double t5_TPPips = 30;                     // Take Profit in Pips:
input bool   t5_SLOn   = false;                  // StopLoss ON:
input double t5_SLPips = 30;                     // StopLoss in Pips:

//////////////////////////////////////////////////////////////////////

int OnInit()
{
  ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
	
	if (!Create_button("Open Trades", 10, 100, 17, 100, bt1)) return (INIT_FAILED);
	if (!Create_button("Close Trades", 10, 120, 17, 100, bt2)) return (INIT_FAILED);
  
	return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick() {}

void OnTimer(void) {}

void OnTrade(void) {}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
	if (id == CHARTEVENT_OBJECT_CLICK && sparam == "Open Trades")
  {
    SendTrades();
  }
	if (id == CHARTEVENT_OBJECT_CLICK && sparam == "Close Trades")
  {
    CloseAll();
  }
}


//////////////////////////////////////////////////////////////////////

void SendTrades()
{
  if (t1_ON)
  {
    symbol   = t1_sym;
    _side    = t1_Side;
    lots     = t1_Lots;
    tpOn     = t1_TPOn;
    tpPips   = t1_TPPips;
    slOn     = t1_SLOn;
    slPips   = t1_SLPips;

    SendOrder();    
  }
  if (t2_ON)
  {
    symbol   = t2_sym;
		_side    = t2_Side;
    lots     = t2_Lots;
    tpOn     = t2_TPOn;
    tpPips   = t2_TPPips;
    slOn     = t2_SLOn;
    slPips   = t2_SLPips;
		  
		SendOrder();
  }
  if (t3_ON)
  {
    symbol   = t3_sym;
		_side    = t3_Side;
    lots     = t3_Lots;
    tpOn     = t3_TPOn;
    tpPips   = t3_TPPips;
    slOn     = t3_SLOn;
    slPips   = t3_SLPips;

	  SendOrder();
  }
  if (t4_ON)
  {
    symbol   = t4_sym;
    _side    = t4_Side;
		lots     = t4_Lots;
    tpOn     = t4_TPOn;
    tpPips   = t4_TPPips;
    slOn     = t4_SLOn;
    slPips   = t4_SLPips;

	  SendOrder();
  }
  if (t5_ON)
  {
    symbol   = t5_sym;
    _side    = t5_Side;
		lots     = t5_Lots;
    tpOn     = t5_TPOn;
    tpPips   = t5_TPPips;
    slOn     = t5_SLOn;
    slPips   = t5_SLPips;

	  SendOrder();
  }
  // mode = close;
}
// ------------------------------------------------------------------
void SendOrder()
{
	string side = _side == Buy ? "buy" : "sell";
  ENUM_ORDER_TYPE type = side == "buy" ? OP_BUY : OP_SELL;

  int tk = OrderSend(symbol, type, lots, Price(side), 100000, SL(side), TP(side), "", magico, 0, clrNONE);

  if (tk < 0) 
	{ 
		Print(__FUNCTION__, " ", "Connot Send Order, error: ", GetLastError()); 
	} else 
	{
		Alert("Trade Open Ok: ", symbol, "Tk: ", tk);
	}
}
void CloseAll()
{
  double _price;
  
	for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == magico)
    {
      if (OrderType() == OP_BUY) { _price = SymbolInfoDouble(OrderSymbol(), SYMBOL_BID); }
      if (OrderType() == OP_SELL){ _price = SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK); }					
      
				if (!OrderClose(OrderTicket(), OrderLots(), _price, 100000, clrNONE))
	      {
	      	Print(__FUNCTION__, " ", "can't close Order: ", OrderTicket(), " error: ", GetLastError());
	      }
     }
  }
}
double Price(string direction)
{
  double result = 0;
  if (direction == "buy")
  {
		result = SymbolInfoDouble(symbol, SYMBOL_ASK);
    return result;
  }

  if (direction == "sell")
  {
		result = SymbolInfoDouble(symbol, SYMBOL_BID);
    return result;
  }

  return -1;
}
double SL(string direction)
{
	if (slPips == 0 || slOn == false) { return 0; }
  
  double result = 0;
  double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);				
  double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
	double point = SymbolInfoDouble(symbol, SYMBOL_POINT);				

	if (direction == "buy") { result  = ask - slPips * 10 * point; }
  if (direction == "sell") { result = bid + slPips * 10 * point; }

  return result;
}
double TP(string direction)
{
  if (tpPips == 0 || tpOn == false) { return 0; }
  
  double result = 0;
  double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);				
  double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
	double point = SymbolInfoDouble(symbol, SYMBOL_POINT);				
	
	if (direction == "buy") { result  = ask + tpPips * 10 * point; }
  if (direction == "sell") { result = bid - tpPips * 10 * point; }

  return result;
}


	bool Create_button(string name, const int x1, const int y1, const int high, const int width, CButton &bt)
	{
	 int x2 = x1+width;
   int y2 = y1+high;

	 bt.Create(0, name, 0, x1, y1, x2, y2);
   bt.Text(name);
   bt.Font("Calibri");
   bt.FontSize(8);

   return true;
	}
	
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

