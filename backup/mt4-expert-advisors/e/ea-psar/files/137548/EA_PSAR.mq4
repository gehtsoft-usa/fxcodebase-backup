// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70423

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
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




#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property description   "This Expert Advisor opens orders when the PSAR changes from above to below the price or vice versa"
#property description   " "
#property description   "DISCLAIMER: This code comes with no guarantee, you can use it at your own risk"
#property description   "We recommend to test it first on a Demo Account"

/*
ENTRY BUY: PSAR changes from above the previous bar to below the current bar
ENTRY SELL: PSAR changes from below the previous bar to above the current bar
EXIT: Take profit or trailing stop using PSAR
*/


extern double LotSize=0.1;             //Position size

extern double StopLoss=20;             //Stop loss in pips
extern double TakeProfit=500;          //Take profit in pips

extern int Slippage=2;                 //Slippage in pips

extern bool TradeEnabled=true;         //Enable trade

extern double PSARStep=0.2;            //PSAR Step         
extern double PSARMaxStep=0.02;        //PSAR Max Step

extern int MagicNumber=11223344;       //Magic Number to assign to the orders

//Functional variables
double ePoint;                         //Point normalized

bool CanOrder;                         //Check for risk management
bool CanOpenBuy;                       //Flag if there are buy orders open
bool CanOpenSell;                      //Flag if there are sell orders open

int OrderOpRetry=10;                   //Number of attempts to perform a trade operation
int SleepSecs=3;                       //Seconds to sleep if can't order
int MinBars=60;                        //Minimum bars in the graph to enable trading

//Functional variables to determine prices
double MinSL;
double MaxSL;
double TP;
double SL;
double Spread;
int Slip; 


//Variable initialization function
void Initialize(){          
   RefreshRates();
   ePoint=Point;
   Slip=Slippage;
   if (MathMod(Digits,2)==1){
      ePoint*=10;
      Slip*=10;
   }
   TP=TakeProfit*ePoint;
   SL=StopLoss*ePoint;
   CanOrder=TradeEnabled;
   CanOpenBuy=true;
   CanOpenSell=true;
}


//Check if orders can be submitted
void CheckCanOrder(){            
   if( Bars<MinBars ){
      Print("INFO - Not enough Bars to trade");
      CanOrder=false;
   }
   OrdersOpen();
   return;
}


//Check if there are open orders and what type
void OrdersOpen(){
   for( int i = 0 ; i < OrdersTotal() ; i++ ) {
      if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false ) {
         Print("ERROR - Unable to select the order - ",GetLastError());
         break;
      } 
      if( OrderSymbol()==Symbol() && OrderType() == OP_BUY) CanOpenBuy=false;
      if( OrderSymbol()==Symbol() && OrderType() == OP_SELL) CanOpenSell=false;
   }
   return;
}


//Close all the orders of a specific type and current symbol
void CloseAll(int Command){
   double ClosePrice=0;
   for( int i = 0 ; i < OrdersTotal() ; i++ ) {
      if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false ) {
         Print("ERROR - Unable to select the order - ",GetLastError());
         break;
      }
      if( OrderSymbol()==Symbol() && OrderType()==Command) {
         if(Command==OP_BUY) ClosePrice=Bid;
         if(Command==OP_SELL) ClosePrice=Ask;
         double Lots=OrderLots();
         int Ticket=OrderTicket();
         for(int j=1; j<OrderOpRetry; j++){
            bool res=OrderClose(Ticket,Lots,ClosePrice,Slip,Red);
            if(res){
               Print("TRADE - CLOSE - Order ",Ticket," closed at price ",ClosePrice);
               break;
            }
            else Print("ERROR - CLOSE - error closing order ",Ticket," return error: ",GetLastError());
         }
      }
   }
   return;
}


//Open new order of a given type
void OpenNew(int Command){
   RefreshRates();
   double OpenPrice=0;
   double SLPrice;
   double TPPrice;
   if(Command==OP_BUY){
      OpenPrice=Ask;
      SLPrice=OpenPrice-SL;
      TPPrice=OpenPrice+TP;
   }
   if(Command==OP_SELL){
      OpenPrice=Bid;
      SLPrice=OpenPrice+SL;
      TPPrice=OpenPrice-TP;
   }
   for(int i=1; i<OrderOpRetry; i++){
      int res=OrderSend(Symbol(),Command,LotSize,OpenPrice,Slip,NormalizeDouble(SLPrice,Digits),NormalizeDouble(TPPrice,Digits),"",MagicNumber,0,Green);
      if(res){
         Print("TRADE - NEW - Order ",res," submitted: Command ",Command," Volume ",LotSize," Open ",OpenPrice," Slippage ",Slip," Stop ",SLPrice," Take ",TPPrice);
         break;
      }
      else Print("ERROR - NEW - error sending order, return error: ",GetLastError());
   }
   return;
}


//Technical analysis of the indicators
bool CrossToOpenBuy=false;
bool CrossToOpenSell=false;


void CheckPSARCross(){
   CrossToOpenBuy=false;
   CrossToOpenSell=false;
   double PSARCurr=iSAR(Symbol(),0,PSARStep,PSARMaxStep,0);
   double PSARPrev=iSAR(Symbol(),0,PSARStep,PSARMaxStep,1);
   if(PSARCurr<Close[0] && PSARPrev>Close[1]){
      CrossToOpenBuy=true;
   }
   if(PSARCurr>Close[0] && PSARPrev<Close[1]){
      CrossToOpenSell=true;
   }
}


//Trailing Stop with PSAR
void UpdatePositions(){

   //Scan the open orders backwards
   for(int i=OrdersTotal()-1; i>=0; i--){
   
      //Select the order, if not selected print the error and continue with the next index
      if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false ) {
         Print("ERROR - Unable to select the order - ",GetLastError());
         continue;
      } 
      
      //Check if the order can be modified matching the criteria, if criteria not matched skip to the next
      if(OrderSymbol()!=Symbol()) continue;
      if(OrderMagicNumber()!=MagicNumber) continue;
      
      //Prepare the prices
      double TakeProfitPrice=OrderTakeProfit();
      double StopLossPrice=OrderStopLoss();
      double OpenPrice=OrderOpenPrice();
      double NewStopLossPrice=StopLossPrice;
      double NewTakeProfitPrice=TakeProfitPrice;
      
      //PSAR Value of the current symbol, current time frame , PSARStep, PSARMaxStep, previous candle
      double PSARPrice=iSAR(Symbol(),0,PSARStep,PSARMaxStep,1);
      
      //Get updated prices and calculate the new Stop Loss and Take Profit levels, these depends on the type of order
      RefreshRates();
      if(OrderType()==OP_BUY){
         if(PSARPrice>StopLossPrice && PSARPrice<Close[1] && PSARPrice<TakeProfitPrice){
            NewStopLossPrice=NormalizeDouble(PSARPrice,Digits);
         }
      } 
      if(OrderType()==OP_SELL){
         if(PSARPrice<StopLossPrice && PSARPrice>Close[1] && PSARPrice>TakeProfitPrice){
            NewStopLossPrice=NormalizeDouble(PSARPrice,Digits);
         }
      }
      
      //If the new Stop Loss and Take Profit Levels are different from the previous then I try to update the order
      if(NewStopLossPrice!=StopLossPrice){
         Print("Modifying order ",OrderTicket()," Open Price ",OpenPrice," New Stop Loss ",NewStopLossPrice," New Take Profit ",NewTakeProfitPrice);
         if(OrderModify(OrderTicket(),OpenPrice,NewStopLossPrice,NewTakeProfitPrice,0,Yellow)){
            Print("Order modified");
         }
         else{
            Print("Order failed to update with error - ",GetLastError());
         }      
      
      }

   
   }
}




//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   //Calling initialization, checks and technical analysis
   Initialize();
   CheckCanOrder();
   UpdatePositions();
   CheckPSARCross();
   //Check of Entry/Exit signal with operations to perform
   if(CrossToOpenBuy){
      CloseAll(OP_SELL);
      if(CanOpenBuy && CanOrder) OpenNew(OP_BUY);
   }
   if(CrossToOpenSell){
      CloseAll(OP_BUY);
      if(CanOpenSell && CanOrder) OpenNew(OP_SELL);
   }
  }
//+------------------------------------------------------------------+
