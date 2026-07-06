// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71769

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
// Gobal Variables
enum ModeDate {
   Manual,
   FromStartEA,
};
input ModeDate    modeDate = FromStartEA;    // Mode to set Initial Date:
input datetime manualDate  = D'2021.12.01';  // Initial Date (for Manual mode):
datetime       iniDate;
//////////////////////////////////////////////////////////////////////

class PipCounter
{
   datetime _iniTm;
   datetime _endTm;
   int      _tk;
   double   _WinPipsHistory;
   double   _LossPipsHistory;
   double   _WinPipsOpen;
   double   _LossPipsOpen;

  public:
   PipCounter() {}
   ~PipCounter() {}

   void     iniTm(datetime inpiniTm) { _iniTm = inpiniTm; }
   datetime iniTm(void) { return _iniTm; }
   void     endTm(datetime inpendTm) { _endTm = inpendTm; }
   datetime endTm(void) { return _endTm; }

   double Distance(double priceA, double priceB, string pair)
   {
      double dist = fabs(priceA - priceB);
      double mPoint;
      if (SymbolInfoDouble(pair, SYMBOL_POINT, mPoint))
      {
         return NormalizeDouble((dist / mPoint), 2);
      }
      else
      {
         Print(__FUNCTION__, " ", "Can't take the points value, error:", " ", GetLastError()," pair: ", pair);
      }
      return 0;
   }

   double Pips(int tk)
   {
      if (OrderSelect(tk, SELECT_BY_TICKET))
      {
         double closePrice = OrderClosePrice() == 0 ? OrderType() == OP_BUY ? Bid : Ask : OrderClosePrice();
         return Distance(closePrice, OrderOpenPrice(), OrderSymbol()) / 10;
      }
      return 0;
   }

   void CalculateHistory(datetime fromDate)
   {
      _WinPipsHistory  = 0;
      _LossPipsHistory = 0;

      for (int i = OrdersHistoryTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderOpenTime() >= fromDate)
         {
            double pipsTk = Pips(OrderTicket());

            if (OrderProfit() >= 0)
            {
               _WinPipsHistory += pipsTk;
            } else
            {
               _LossPipsHistory += pipsTk;
            }
         }
      }
   }

   void CalculateOpen()
   {
      _WinPipsOpen  = 0;
      _LossPipsOpen = 0;

      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            double pipsTk = Pips(OrderTicket());
            if (OrderProfit() >= 0)
            {
               _WinPipsOpen += pipsTk;
            } else
            {
               _LossPipsOpen += pipsTk;
            }
         }
      }
   }

   double WinPipsFrom(datetime fromDate)
   {
      CalculateHistory(fromDate);
      return _WinPipsHistory;
   }

   double LossPipsFrom(datetime fromDate)
   {
      CalculateHistory(fromDate);
      return _LossPipsHistory;
   }

   double NetPipsFrom(datetime fromDate)
   {
      CalculateHistory(fromDate);
      return _LossPipsHistory + _WinPipsHistory;
   }

   double WinPipsOpen()
   {
      CalculateOpen();
      return _WinPipsOpen;
   }

   double LossPipsOpen()
   {
      CalculateOpen();
      return _LossPipsOpen;
   }

   double NetPipsOpen()
   {
      CalculateOpen();
      return _LossPipsOpen + _WinPipsOpen;
   }
};
PipCounter pipCounter;

int OnInit()
{
   setIniTm();
   return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick()
{
   // double lossPipsClose = pipCounter.LossPipsFrom(iniDate);
 
   Comment("------------------------------------------------------",
   "\n","Initial Date: ",iniDate,
   "\n","Win Pips - Closed trades: ", DoubleToString(pipCounter.WinPipsFrom(iniDate),2),
   "\n","Loss Pips - Closed trades: ",DoubleToString(pipCounter.LossPipsFrom(iniDate),2),
   "\n","Win Pips - Open trades: ",   DoubleToString(pipCounter.WinPipsOpen(),2),
   "\n","Loss Pips - Open trades: ",  DoubleToString(pipCounter.LossPipsOpen(),2),
   "\n","------------------------------------------------------");
}

//////////////////////////////////////////////////////////////////////

void setIniTm()
{
   switch (modeDate)
   {
      case Manual:
         iniDate = manualDate;
         break;
      case FromStartEA:
         iniDate = TimeCurrent();
         break;
   }
}
