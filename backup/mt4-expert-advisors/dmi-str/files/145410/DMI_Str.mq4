// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71992

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

#define MAGICMA 33457236

input int    DMI_Length     = 14;
input bool   Use_ADX_Filter = true;
input int    ADX_Length     = 14;
input double ADX_Level      = 20.;
input int    Price          = 0;  // Applied price
                                  // 0 - Close
                                  // 1 - Open
                                  // 2 - High
                                  // 3 - Low
                                  // 4 - Median
                                  // 5 - Typical
                                  // 6 - Weighted

input string Signal_Type_Str = "Signal type: 0 - Direct, 1 - Reverse";
input int    Signal_Type     = 0;  // 0 - Direct, 1 - Reverse

input string Allowed_Side_Str = "Allowed side: 0 - Both, 1 - Buy, 2 - Sell";
input int    Allowed_Side     = 0;      // 0 - Both, 1 - Buy, 2 - Sell
input bool   Allow_Trade      = true;   // Allow Trade:
input int    uMaxQntTrades    = 1;      // Number of trades at same time:
input bool   uCloseOposite    = false;  // Close in Oposite:
input double Lots             = 0.1;    // Lots:
input bool   Set_Stop         = true;   // Stop Loss On:
input int    Stop             = 50;     // SL Points:
input bool   Set_Limit        = true;   // Take Profit On:
input int    Limit            = 100;    // Take profit Points:
input bool   Show_Alert       = true;   // Show alerts:
input bool   Play_Sound       = false;  // Play Sound:
input string Sound_File       = "";     // Sound File:
input bool   Send_Email       = false;  // Send eMail:

datetime LastBar;
double   Dist;
int      qntTrades;

int OnInit()
{
   LastBar = 0;

   return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}

void CloseAll()
{
   bool res;
   int  OT = OrdersTotal();
   for (int i = OT - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) break;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGICMA)
      {
         if (OrderType() == OP_BUY) res = OrderClose(OrderTicket(), OrderLots(), Bid, 5);
         if (OrderType() == OP_SELL) res = OrderClose(OrderTicket(), OrderLots(), Ask, 5);
      }
   }
}

void _Alert(string op)
{
   if (Show_Alert)
   {
      Alert(Symbol() + " :" + op);
   }

   if (Play_Sound)
   {
      PlaySound(Sound_File);
   }

   if (Send_Email)
   {
      SendMail(Symbol() + " :", op);
   }
}

int CalculateOrders()
{
   int Count = 0;
   qntTrades = 0;
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGICMA)
      {
         if (OrderType() == OP_BUY)
         {
            Count++;
            qntTrades++;
         }
         if (OrderType() == OP_SELL)
         {
            Count--;
            qntTrades++;
         }
      }
   }
   return (Count);
}

int qntTrades()
{
   qntTrades = 0;
   for (int i = 0; i < OrdersTotal(); i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGICMA)
      {
         qntTrades++;
      }
   }
   return qntTrades;
}

void OnTick()
{
   if (LastBar == Time[1])
   {
      return;
   }
   LastBar = Time[1];

   double DMIP0, DMIP1, DMIM0, DMIM1, ADX0;

   DMIP0 = iADX(NULL, 0, DMI_Length, Price, 1, 1);
   DMIP1 = iADX(NULL, 0, DMI_Length, Price, 1, 2);
   DMIM0 = iADX(NULL, 0, DMI_Length, Price, 2, 1);
   DMIM1 = iADX(NULL, 0, DMI_Length, Price, 2, 2);
   ADX0  = iADX(NULL, 0, ADX_Length, Price, 0, 1);

   int    CO;
   int    res;
   double SL, TP;

   CO = CalculateOrders();

   if ((Signal_Type == 0 && DMIP0 > DMIM0 && DMIP1 <= DMIM1 && (!(Use_ADX_Filter) || ADX0 > ADX_Level)) || (Signal_Type == 1 && DMIP0 < DMIM0 && DMIP1 >= DMIM1 && (!(Use_ADX_Filter) || ADX0 > ADX_Level)))
   {
      _Alert("Buy");
      CO = CalculateOrders();

      if (Allow_Trade)
      {
         if (uCloseOposite && CO < 0) CloseAll();
         if (qntTrades() < uMaxQntTrades)
         {
            if (Allowed_Side != 2)
            {
               if (Set_Stop)
               {
                  SL = NormalizeDouble(Bid - Stop * Point, Digits);
               } else
               {
                  SL = 0.;
               }
               if (Set_Limit)
               {
                  TP = NormalizeDouble(Bid + Limit * Point, Digits);
               } else
               {
                  TP = 0.;
               }
               res = OrderSend(Symbol(), OP_BUY, Lots, Ask, 5, SL, TP, "", MAGICMA, 0, Blue);
            }
         }
      }
   }

   if ((Signal_Type == 1 && DMIP0 > DMIM0 && DMIP1 <= DMIM1 && (!(Use_ADX_Filter) || ADX0 > ADX_Level)) || (Signal_Type == 0 && DMIP0 < DMIM0 && DMIP1 >= DMIM1 && (!(Use_ADX_Filter) || ADX0 > ADX_Level)))
   {
      _Alert("Sell");
      CO = CalculateOrders();
      Print(__FUNCTION__, " ", "CO", " ", CO);

      if (Allow_Trade)
      {
         if (uCloseOposite && CO >= 0) CloseAll();
         if (qntTrades() < uMaxQntTrades)
         {
            if (Allowed_Side != 1)
            {
               if (Set_Stop)
               {
                  SL = NormalizeDouble(Ask + Stop * Point, Digits);
               } else
               {
                  SL = 0.;
               }
               if (Set_Limit)
               {
                  TP = NormalizeDouble(Ask - Limit * Point, Digits);
               } else
               {
                  TP = 0.;
               }
               res = OrderSend(Symbol(), OP_SELL, Lots, Bid, 5, SL, TP, "", MAGICMA, 0, Red);
            }
         }
      }
   }
}
