// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71877

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

//----------------------- INCLUDES
#include <stdlib.mqh>


//----------------------- EA PARAMETER
extern string  
         Expert_Name          = "---------- Universal MA Cross EA v7.2";
extern int
         MagicNumber          = 1234; //Needed if running multiple EAs on the same account
extern double 
         StopLoss             = 20,  // Use 0 (zero) if you don't like to use Stop Loss.
         TakeProfit           = 30;  // Use 0 (zero) if you like to use open target.

extern string  
         TrailingStop_Setting = "---------- Trailing Stop Setting";
extern int         
         TrailingStopType     = 1, // 1:will start trailing if profit in pips is greater / same with TrailingStop. 2:will start trailing as soon as trade in profit.
         TrailingStop         = 15; //Use 0 (zero) if you don't use trailing stop
         
extern string  
         Indicator_Setting    = "---------- Indicator Setting";
extern int
         FastMAPeriod         = 5,   //Fast Moving Average Period
         FastMAType           = 1,    //0:SMA 1:EMA 2:SMMA 3:LWMA
         FastMAPrice          = 0,    //0:Close 1:Open 2:High 3:Low 4:Median 5:Typical 6:Weighted
         FastMAshift          = 0,    //Fast Moving Average Shift
         SlowMAPeriod         = 13,   //Slow Moving Average Period.
         SlowMAType           = 1,    //0:SMA 1:EMA 2:SMMA 3:LWMA
         SlowMAPrice          = 0,    //0:Close 1:Open 2:High 3:Low 4:Median 5:Typical 6:Weighted
         SlowMAshift          = 0;    //Slow Moving Average Shift
         
extern string  
         CossDistance_Setting = "---------- Min Cross Distance Setting";
extern int
         MinCrossDistance     = 0,    //Set the pip distance between FastMA and SlowMA to be consider as a valid cross. Use 0 (zero) to disable this filter.
         MaxLookUp            = 0;    //Set number of bar after the cross to keep checking on the entry condition in regards with the minimum distance between FastMA and SlowMA. Need MinCrosDistance > 0 to enable this feature. Use 0 (zero) to disable this feature.

extern string  
         Exit_Setting         = "---------- Exit Setting";
extern bool
         StopAndReverse       = true,  //If set to TRUE, will exit any trade and reverse position when signal change.
         PureSAR              = false, //If set to TRUE, will use no Stop Loss - Take Profit - and Trailing Stop. This is always in play setting.
         ExitOnCross          = false; //If set to TRUE, will exit any trade if there is an opposite cross without consider any additional filter. So exit purely base on moving average cross.

extern string  
         ThirdEMA_Setting     = "---------- Third MA Setting";
extern bool
         UseThirdMA           = true, //If set to TRUE (and UseCounterTrend = FALSE), will only trade according to ThirdMA direction, above for BUY and below for SELL.
         UseCounterTrend      = false, //If set to TRUE will keep trade even if counter ThirdMA direction, but with different StopLoss and TakeProfit. Need UseThirdMA = TRUE to enable this feature.
         OnlyCounterTrend     = false; //If set to TRUE will set the EA only to trade counter trend trade, mean BUY if cross below ThirdMA and SELL if cross above ThirdMA. Need UseCounterTrend = TRUE to enable this feature.
extern int
         ThirdMAPeriod        = 62,  //Third Moving Average Period.
         ThirdMAType          = 1,    //0:SMA 1:EMA 2:SMMA 3:LWMA
         ThirdMAPrice         = 0,    //0:Close 1:Open 2:High 3:Low 4:Median 5:Typical 6:Weighted
         ThirdMAshift         = 0,    //Third Moving Average Shift
         CTStopLoss           = 0,    //Set your Stop Loss for CounterTrend trade. Use 0 (zero) if you don't like to use Stop Loss (not recommended).
         CTTakeProfit         = 0;    //Set your Take Profit for CounterTrend trade. Use 0 (zero) if you like to use open target.      

/*
extern string  
         BGFilter_Setting     = "---------- BG Cross Filter Setting";
extern bool
         UseBGFilter          = false;
extern int
         BGFilter             = 20;                  
*/
       
extern string  
         Order_Setting        = "---------- Order Setting";
extern bool
         ReverseCondition     = false, //Set TRUE to reverse the entry condition.
         ConfirmedOnEntry     = false,  //TRUE:entry on the next signal bar
         OneEntryPerBar       = true;  //If set to TRUE, will only trade once on one bar. If set to FALSE, will trade more than once on one bar if the entry condition is still valid, although still one trade at a time.
extern int
         NumberOfTries        = 10, //Number of try if the order rejected by the system.
         Slippage             = 5;  //Slippage setting

extern string  
         OpenOrder_Setting    = "---------- Multiple Open Trade Setting";
//  MaxOpenTrade         = 1, //Number of maximum open trade at one time. StopAndReverse/PureSAR must be FALSE so the EA won't close the open order when there is an opposite signal, but rather it will open a new trade. Set the number of open trade allowed. If StopAndReverse / PureSAR = TRUE this setting will always = 1, mean one trade at a time.
extern int
        MaxOpenTradeBuy   =  2,
        MaxOpenTradeSell  =  2,

         MinPriceDistance     = 5; //If multiple open trade enable (by set MaxOpenOrder>1 and OneEntryPerBar=FALSE) this number will determine the minimum distance between each trade on same direction.

extern string  
         Time_Parameters      = "---------- EA Active Time";
extern bool    
         UseHourTrade         = true; //If set to TRUE, the EA only active on certain time.      
extern int     
         StartHour            = 8, //Time when the EA start active (use with UseHourTrade = TRUE).
         EndHour              = 19; //Time when the EA stop active (use with UseHourTrade = TRUE).
         
extern string  
         MM_Parameters        = "---------- Money Management";
extern double 
         Lots                 = 1.0; //Number of lot per trade.
extern bool 
         MM                   = false, //If set to TRUE, will use build in money management.
         AccountIsMicro       = false; //If using Micro Account set this to TRUE.
extern int 
         Risk                 = 10; //Use with MM = TRUE to set the risk per trade. 10 = 10% Equity
         
extern string  
         Alert_Setting        = "---------- Alert Setting";
extern bool
         EnableAlert          = false; //Will sound an alert when there is a moving average cross, cross UP or cross DOWN.
extern string
         SoundFilename        = "alert.wav"; //The filename for the alert.

extern string  
         Testing_Parameters= "---------- Back Test Parameter";
extern bool
         PrintControl         = false, //Print some comment on backtesting.
         Show_Settings        = false; //Show setting on the chart.


//----------------------- GLOBAL VARIABLE
static int 
         TimeFrame            = 0;
string
         TicketComment        = "UniversalMA v7.2",
         LastTrade,
         LastAlert,
         TradeDirection       = "NONE",
         PreviousDirection    = "NONE",
         CurrentDirection     = "NONE";
datetime
         CheckTime,
         CheckEntryTime,
         CrossTime;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{

//----------------------- GENERATE MAGIC NUMBER AND TICKET COMMENT
//----------------------- SOURCE : PENGIE
   MagicNumber    = subGenerateMagicNumber(MagicNumber, Symbol(), Period());
	TicketComment  = StringConcatenate(TicketComment, "-", Symbol(), "-", Period());

//----------------------- SET MinCrossDistance ALWAYS POSITIVE
   MinCrossDistance = MathAbs(MinCrossDistance);

//----------------------- SHOW EA SETTING ON THE CHART
//----------------------- SOURCE : CODERSGURU
   if(Show_Settings) subPrintDetails();
   else Comment("");
   
//----------------------- INITIALIZE PURE Stop And Reverse
//----------------------- NO STOP LOSS, NO TAKE PROFIT, NO TRAILING STOP
   if(PureSAR)
   {
      StopLoss       = 0;
      TakeProfit     = 0;
      TrailingStop   = 0;
      StopAndReverse = true;
   }

//----------------------- MaxTrade ALWAYS >= 1
   // if(MaxOpenTrade<=0) MaxOpenTrade = 1;
   
//+------------------------------------------------------------------+
//| CHECK LAST OPEN TRADE                                            |
//+------------------------------------------------------------------+
   LastTrade = subCheckOpenTrade();
   Print("Last Trade : ",LastTrade);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
 
//----------------------- PREVENT RE-COUNTING WHILE USER CHANGING TIME FRAME
//----------------------- SOURCE : CODERSGURU
   TimeFrame=Period(); 
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   double 
         FastMACurrent,
         SlowMACurrent,
         ThirdMAValue;
                   
   int   
         cnt,
         ticket,
         total,
         shiftCROSS,
         Distance;
         
   bool
         BuyCondition,
         SellCondition,
         CounterTrend;

   string
         CrossDirection;         
         
//----------------------- TIME FILTER
   if (UseHourTrade)
   {
      if(!(Hour()>=StartHour && Hour()<=EndHour))
      {
         Comment("Non-Trading Hours!");
         return(0);
      }
   }

//----------------------- CHECK CHART NEED MORE THAN 100 BARS
   if(Bars<100)
   {
      Print("bars less than 100");
      return(0);  
   }

//----------------------- TRAILING STOP SECTION
   if(TrailingStop>0 && subTotalTrade()>0)
   {
      total = OrdersTotal();
      for(cnt=0;cnt<total;cnt++)
      {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

         if(OrderType()<=OP_SELL &&
            OrderSymbol()==Symbol() &&
            OrderMagicNumber()==MagicNumber)
         {
            subTrailingStop(OrderType());
         }
      }
   }            

//----------------------- ADJUST LOTS IF USING MONEY MANAGEMENT
   if(MM) Lots = subLotSize();

//----------------------- SET VALUE FOR VARIABLE
   if(ConfirmedOnEntry)
   {
      if(CheckTime==iTime(NULL,TimeFrame,0)) return(0); else CheckTime = iTime(NULL,TimeFrame,0);
   
      FastMACurrent    = iMA(NULL,TimeFrame,FastMAPeriod,FastMAshift,FastMAType,FastMAPrice,1);
      SlowMACurrent    = iMA(NULL,TimeFrame,SlowMAPeriod,SlowMAshift,SlowMAType,SlowMAPrice,1);
   }
   else
   {
      FastMACurrent    = iMA(NULL,TimeFrame,FastMAPeriod,FastMAshift,FastMAType,FastMAPrice,0);
      SlowMACurrent    = iMA(NULL,TimeFrame,SlowMAPeriod,SlowMAshift,SlowMAType,SlowMAPrice,0);
   }
   
   CrossDirection = subCrossDirection(FastMACurrent,SlowMACurrent);

//----------------------- CONDITION CHECK
   if(!ReverseCondition)
   {
//----------------------- BUY CONDITION   
      if(CrossDirection=="UP")
      {
         BuyCondition   = true;
         TradeDirection = "UP";
         CrossTime      = iTime(NULL,TimeFrame,0);
      }                       

//----------------------- SELL CONDITION   
      if(CrossDirection=="DOWN")
      {
         SellCondition  = true;
         TradeDirection = "DOWN";
         CrossTime      = iTime(NULL,TimeFrame,0);
      }
   }
   else
   {
//----------------------- SELL CONDITION   
      if(CrossDirection=="UP")
      {
         SellCondition  = true;
         TradeDirection = "UP";
         CrossTime      = iTime(NULL,TimeFrame,0);
      }                       

//----------------------- BUY CONDITION   
      if(CrossDirection=="DOWN")
      {
         BuyCondition   = true;
         TradeDirection = "DOWN";
         CrossTime      = iTime(NULL,TimeFrame,0);
      }
   }                        

   if(PrintControl)
   {
      if(BuyCondition)  Print("MA Cross BUY");
      if(SellCondition) Print("MA Cross SELL");
   }      

//----------------------- ALERT ON CROSS
   if(EnableAlert && ConfirmedOnEntry)
   {
      if(TradeDirection=="UP" && LastAlert!="UP")
      {
         subCrossAlert("UP");
         LastAlert = "UP";
      }            
      if(TradeDirection=="DOWN" && LastAlert!="DOWN")
      {
         subCrossAlert("DOWN");
         LastAlert ="DOWN";
      }
   }                        

//+------------------------------------------------------------------+
//| EXIT BASE ONLY ON MOVING AVERAGE CROSS                           |
//+------------------------------------------------------------------+
if(ExitOnCross && subTotalTrade()>0)
   {
      if((LastTrade=="BUY" && SellCondition) || (LastTrade=="SELL" && BuyCondition))
      {
         subCloseOrder();
         if(subTotalTrade()>0) subCloseOrder();
         if(subTotalTrade()>0) subCloseOrder();
         
         if(IsTesting() && PrintControl) Print("EXIT ON CROSS !");
      }
   }

//+------------------------------------------------------------------+
//| CHECKING FOR MIN CROSS DISTANCE SEVERAL BAR AFTER THE CROSS      |
//+------------------------------------------------------------------+
   if(MaxLookUp>0 && MinCrossDistance>0)
   {
      BuyCondition  = false;
      SellCondition = false;
      shiftCROSS    = iBarShift(NULL,TimeFrame,CrossTime);
      Distance      = MathFloor(MathAbs((FastMACurrent-SlowMACurrent)/Point));
   
      if(shiftCROSS<=MaxLookUp && Distance>=MinCrossDistance)
      {
         if(!ReverseCondition)
         {
            BuyCondition  = TradeDirection=="UP";
            SellCondition = TradeDirection=="DOWN";
         }
         else
         {
            SellCondition = TradeDirection=="UP";
            BuyCondition  = TradeDirection=="DOWN";
         }
      }
      
      if(PrintControl)
      {
         Print(TimeToStr(CrossTime,TIME_MINUTES)," - ",shiftCROSS," - ",Distance," - ",MinCrossDistance," - ",TradeDirection);
         if(BuyCondition ) Print("MinCrosDistance BUY");
         if(SellCondition) Print("MinCrosDistance SELL");
      }
   }

//+------------------------------------------------------------------+
//| ADDITIONAL FILTER                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| THIRD MOVING AVERAGE                                             |
//+------------------------------------------------------------------+
   if(UseThirdMA)
   {
      ThirdMAValue = iMA(NULL,TimeFrame,ThirdMAPeriod,ThirdMAshift,ThirdMAType,ThirdMAPrice,0);

      if(!UseCounterTrend)
      {      
         BuyCondition  = (BuyCondition  && SlowMACurrent>ThirdMAValue);
         SellCondition = (SellCondition && SlowMACurrent<ThirdMAValue);
      }
      else
      {
         CounterTrend = ((BuyCondition && FastMACurrent<ThirdMAValue) ||
                        (SellCondition && FastMACurrent>ThirdMAValue));

//+------------------------------------------------------------------+
//| DON'T ALLOW ANY TREND FOLLOWING ENTRY / ONLY COUNTER TREND       |
//+------------------------------------------------------------------+
         if(OnlyCounterTrend && !CounterTrend)
         {
            BuyCondition  = false;
            SellCondition = false;
         }
      }
   }

//----------------------- STOP AND REVERSE
if(StopAndReverse && subTotalTrade()>0)
   {
      if((LastTrade=="BUY" && SellCondition) || (LastTrade=="SELL" && BuyCondition))
      {
         subCloseOrder();
         if(subTotalTrade()>0) subCloseOrder();
         if(subTotalTrade()>0) subCloseOrder();

         if(IsTesting() && PrintControl) Print("STOP AND REVERSE !");
      }
   }


//----------------------- ENTRY
//----------------------- TOTAL ORDER BASE ON MAGICNUMBER AND SYMBOL
   total = subTotalTrade();

//----------------------- IF NUMBER TRADE LESS THAN MaxTrade
   if( (BuyCondition || SellCondition)) 
   {

//----------------------- ONE ENTRY PER BAR
      if(OneEntryPerBar)
      {
         if(CheckEntryTime==iTime(NULL,TimeFrame,0)) return(0); else CheckEntryTime = iTime(NULL,TimeFrame,0);
      }         

//----------------------- BUY CONDITION   
      if(BuyCondition)
      {
         if(!subHighestLowest("BUY")) return(0);
      
         if(!CounterTrend)
         {
            ticket = subOpenOrder(OP_BUY,StopLoss,TakeProfit);
            if(ticket<=0) ticket = subOpenOrder(OP_BUY,StopLoss,TakeProfit);
            if(ticket<=0) ticket = subOpenOrder(OP_BUY,StopLoss,TakeProfit);
         }
         else
         {
            ticket = subOpenOrder(OP_BUY,CTStopLoss,CTTakeProfit);
            if(ticket<=0) ticket = subOpenOrder(OP_BUY,CTStopLoss,CTTakeProfit);
            if(ticket<=0) ticket = subOpenOrder(OP_BUY,CTStopLoss,CTTakeProfit);
         }
         subCheckError(ticket,"BUY");
         LastTrade = "BUY";
         return(0);
      }

//----------------------- SELL CONDITION   
      if(SellCondition)
      {
         if( !subHighestLowest("SELL")) return(0);
         
         if(!CounterTrend)
         {
            ticket = subOpenOrder(OP_SELL,StopLoss,TakeProfit);
            if(ticket<=0) ticket = subOpenOrder(OP_SELL,StopLoss,TakeProfit);
            if(ticket<=0) ticket = subOpenOrder(OP_SELL,StopLoss,TakeProfit);
         }
         else
         {
            ticket = subOpenOrder(OP_SELL,CTStopLoss,CTTakeProfit);
            if(ticket<=0) ticket = subOpenOrder(OP_SELL,CTStopLoss,CTTakeProfit);
            if(ticket<=0) ticket = subOpenOrder(OP_SELL,CTStopLoss,CTTakeProfit);
         }
         subCheckError(ticket,"SELL");
         LastTrade = "SELL";
         return(0);
      }
      return(0);
   }
   
   return(0);
}

//----------------------- END PROGRAM

//+------------------------------------------------------------------+
//| FUNCTION DEFINITIONS
//+------------------------------------------------------------------+

//----------------------- MONEY MANAGEMENT FUNCTION  
//----------------------- SOURCE : CODERSGURU
double subLotSize()
{
     double lotMM = MathCeil(AccountFreeMargin() *  Risk / 1000) / 100;
	  
	  if(AccountIsMicro==false) //normal account
	  {
	     if(lotMM < 0.1)                  lotMM = Lots;
	     if((lotMM > 0.5) && (lotMM < 1)) lotMM = 0.5;
	     if(lotMM > 1.0)                  lotMM = MathCeil(lotMM);
	     if(lotMM > 100)                  lotMM = 100;
	  }
	  else //micro account
	  {
	     if(lotMM < 0.01)                 lotMM = Lots;
	     if(lotMM > 1.0)                  lotMM = MathCeil(lotMM);
	     if(lotMM > 100)                  lotMM = 100;
	  }
	  
	  return (lotMM);
}

//----------------------- NUMBER OF ORDER BASE ON SYMBOL AND MAGICNUMBER FUNCTION
int subTotalTrade()
{
   int
      cnt, 
      total = 0;

   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL &&
         OrderSymbol()==Symbol() &&
         OrderMagicNumber()==MagicNumber) total++;
   }
   return(total);
}

//+------------------------------------------------------------------+
//| FUNCTION : CHECK OPEN ORDER BASE ON SYMBOL AND MAGIC NUMBER      |
//| SOURCE   : n/a                                                   |
//| MODIFIED : FIREDAVE                                              |
//+------------------------------------------------------------------+
string subCheckOpenTrade()
{
   int
      cnt         = 0;
   string
      lasttrade   = "None";      

   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL &&
         OrderSymbol()==Symbol() &&
         OrderMagicNumber()==MagicNumber)
      {
         if(OrderType()==OP_BUY ) lasttrade = "BUY";
         if(OrderType()==OP_SELL) lasttrade = "SELL";
      }         
   }
   return(lasttrade);
}

//----------------------- FIND LOWEST/HIGHEST BUY-SELL FUNCTION
bool subHighestLowest(string type)
{
   int
      cnt, 
      total = 0;
      
   double
      HighestBuy  = 0,
      LowestBuy   = 10000,
      HighestSell = 0,
      LowestSell  = 10000;

   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL &&
         OrderSymbol()==Symbol() &&
         OrderMagicNumber()==MagicNumber)
      {
         if(OrderType()==OP_BUY)
         {
            if(OrderOpenPrice()<LowestBuy ) LowestBuy  = OrderOpenPrice();
            if(OrderOpenPrice()>HighestBuy) HighestBuy = OrderOpenPrice();
         }

         if(OrderType()==OP_SELL)
         {
            if(OrderOpenPrice()<LowestSell ) LowestSell  = OrderOpenPrice();
            if(OrderOpenPrice()>HighestSell) HighestSell = OrderOpenPrice();
         }

      }
   }
   
   if     (type=="BUY"  && (Ask<=LowestBuy -MinPriceDistance*Point || Ask>=HighestBuy +MinPriceDistance*Point)) return(true);
   else if(type=="SELL" && (Bid<=LowestSell-MinPriceDistance*Point || Bid>=HighestSell+MinPriceDistance*Point)) return(true);
   else return(false);
}

//+------------------------------------------------------------------+
//| FUNCTION : CHECK IS CROSS OR NOT                                 |
//| SOURCE   : CODERSGURU                                            |
//| MODIFIED : FIREDAVE                                              |
//+------------------------------------------------------------------+
string subCrossDirection(double fastMA, double slowMA)
{
        if(fastMA>slowMA) CurrentDirection = "UP";
   else if(fastMA<slowMA) CurrentDirection = "DOWN";
   
   if(PreviousDirection=="NONE")
   {
      PreviousDirection = CurrentDirection;
      return("NONE");
   }

   if(PrintControl) Print("Prev : ",PreviousDirection," - Curr : ",CurrentDirection);
   
   if(PreviousDirection!=CurrentDirection)
   {
      PreviousDirection = CurrentDirection;
      return(CurrentDirection);
   }
   else return("NONE");
}

//----------------------- OPEN ORDER FUNCTION
//----------------------- SOURCE   : CODERSGURU
//----------------------- SOURCE   : PENGIE
//----------------------- MODIFIED : FIREDAVE
int subOpenOrder(int type, int stoploss, int takeprofit)
{
   int
         ticket      = 0,
         err         = 0,
         c           = 0;
         
   double         
         aStopLoss   = 0,
         aTakeProfit = 0,
         bStopLoss   = 0,
         bTakeProfit = 0;

   if(stoploss!=0)
   {
      aStopLoss   = NormalizeDouble(Ask-stoploss*Point,4);
      bStopLoss   = NormalizeDouble(Bid+stoploss*Point,4);
   }
   
   if(takeprofit!=0)
   {
      aTakeProfit = NormalizeDouble(Ask+takeprofit*Point,4);
      bTakeProfit = NormalizeDouble(Bid-takeprofit*Point,4);
   }
   
   if(type==OP_BUY)
   {   

      if( fx_open_trade(0)  ==  false )
        {
      for(c=0;c<NumberOfTries;c++)
      {
      
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,aStopLoss,aTakeProfit,TicketComment,MagicNumber,0,Green);
         err=GetLastError();
         if(err==0)
         { 
            if(ticket>0) break;
         }
         else
         {
            if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
            {
               Sleep(5000);
               continue;
            }
            else //normal error
            {
               if(ticket>0) break;
            }  
         }

      }
      }   
   }
   if(type==OP_SELL)
   { 
      if( fx_open_trade(1)  ==  false )
        {  
      for(c=0;c<NumberOfTries;c++)
      {
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,bStopLoss,bTakeProfit,TicketComment,MagicNumber,0,Red);
         err=GetLastError();
         if(err==0)
         { 
            if(ticket>0) break;
         }
         else
         {
            if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
            {
               Sleep(5000);
               continue;
            }
            else //normal error
            {
               if(ticket>0) break;
            }  
         }
      }
   }   
   }  
   return(ticket);
}



bool  fx_open_trade(int  order_type)  {
  int count_trade_buy =     0 ; 
  int count_trade_sell  = 0   ;  
    for  (   int i  =   0  ;  i<   OrdersTotal()  ;  i++){
        if ( (OrderSelect(i  , SELECT_BY_POS) )) {
           
         if  (  OrderType()  ==  OP_BUY)  {
               count_trade_buy   = count_trade_buy  +1 ; 
         }
         if  (   OrderType()   ==  OP_SELL)  {
              count_trade_sell   =  count_trade_sell  + 1;

         }

         if ( OrdersTotal()  ==   i )  {
                  if  (  order_type   ==  OP_BUY )  {
                          count_trade_buy  >  MaxOpenTradeBuy;
                          return true ; 

                  }
                  if  (  order_type    ==  OP_SELL) {
                     count_trade_sell    >   MaxOpenTradeSell;
                     return   true ; 
                  }            
         }

     



        }

    }
  


   return   false   ; 
}

//----------------------- CLOSE ORDER FUNCTION
void subCloseOrder()
{
   int
         cnt, 
         total       = 0,
         ticket      = 0,
         err         = 0,
         c           = 0;

   total = OrdersTotal();
   for(cnt=total-1;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

      if(OrderSymbol()==Symbol() &&
         OrderMagicNumber()==MagicNumber)
      {
         switch(OrderType())
         {
            case OP_BUY      :
               for(c=0;c<NumberOfTries;c++)
               {
                  ticket=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Violet);
                  err=GetLastError();
                  if(err==0)
                  { 
                     if(ticket>0) break;
                  }
                  else
                  {
                     if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
                     {
                        Sleep(5000);
                        continue;
                     }
                     else //normal error
                     {
                        if(ticket>0) break;
                     }  
                  }
               }   
               break;
               
            case OP_SELL     :
               for(c=0;c<NumberOfTries;c++)
               {
                  ticket=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Violet);
                  err=GetLastError();
                  if(err==0)
                  { 
                     if(ticket>0) break;
                  }
                  else
                  {
                     if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
                     {
                        Sleep(5000);
                        continue;
                     }
                     else //normal error
                     {
                        if(ticket>0) break;
                     }  
                  }
               }   
               break;
               
            case OP_BUYLIMIT :
            case OP_BUYSTOP  :
            case OP_SELLLIMIT:
            case OP_SELLSTOP :
               OrderDelete(OrderTicket());
         }
      }
   }      
}


//----------------------- TRAILING STOP FUNCTION
//----------------------- SOURCE   : CODERSGURU
//----------------------- MODIFIED : FIREDAVE
void subTrailingStop(int Type)
{
   if(Type==OP_BUY)   // buy position is opened   
   {
      switch(TrailingStopType)
      {
//----------------------- AFTER PROFIT TRAILING STOP      
         case 1:
            if(Bid-OrderOpenPrice()>Point*TrailingStop &&
              OrderStopLoss()<Bid-Point*TrailingStop)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
               return(0);
            }
            break;
            
//----------------------- TRAILING STOP
         case 2:
            if(Bid>OrderOpenPrice() &&
              OrderStopLoss()<Bid-Point*TrailingStop)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
               return(0);
            }
            break;

//----------------------- DEFAULT : AFTER PROFIT TRAILING STOP      
         default:
            if(Bid-OrderOpenPrice()>Point*TrailingStop &&
              OrderStopLoss()<Bid-Point*TrailingStop)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
               return(0);
            }  
      }
   }

   if(Type==OP_SELL)   // sell position is opened   
   {
      switch(TrailingStopType)
      {
//----------------------- AFTER PROFIT TRAILING STOP      
         case 1:
            if(OrderOpenPrice()-Ask>Point*TrailingStop)
            {
            if(OrderStopLoss()>Ask+Point*TrailingStop || OrderStopLoss()==0)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
               return(0);
            }
            }
            break;
            
//----------------------- TRAILING STOP
         case 2:
            if(OrderOpenPrice()>Ask)
            {
            if(OrderStopLoss()>Ask+Point*TrailingStop || OrderStopLoss()==0)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
               return(0);
            }
            }
            break;

//----------------------- DEFAULT : AFTER PROFIT TRAILING STOP      
         default:
            if(OrderOpenPrice()-Ask>Point*TrailingStop)
            {
            if(OrderStopLoss()>Ask+Point*TrailingStop || OrderStopLoss()==0)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
               return(0);
            }
            }
      }
   }
}



//----------------------- CHECK ERROR CODE FUNCTION
//----------------------- SOURCE : CODERSGURU
void subCheckError(int ticket, string Type)
{
    if(ticket>0) 
    {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print(Type + " order opened : ",OrderOpenPrice());
    }
    else Print("Error opening " + Type + " order : (",GetLastError(),") ", ErrorDescription(GetLastError()));
}

//----------------------- GENERATE MAGIC NUMBER BASE ON SYMBOL AND TIME FRAME FUNCTION
//----------------------- SOURCE   : PENGIE
//----------------------- MODIFIED : FIREDAVE
int subGenerateMagicNumber(int MagicNumber, string symbol, int timeFrame)
{
   int isymbol = 0;
   if (symbol == "EURUSD")       isymbol = 1;
   else if (symbol == "GBPUSD")  isymbol = 2;
   else if (symbol == "USDJPY")  isymbol = 3;
   else if (symbol == "USDCHF")  isymbol = 4;
   else if (symbol == "AUDUSD")  isymbol = 5;
   else if (symbol == "USDCAD")  isymbol = 6;
   else if (symbol == "EURGBP")  isymbol = 7;
   else if (symbol == "EURJPY")  isymbol = 8;
   else if (symbol == "EURCHF")  isymbol = 9;
   else if (symbol == "EURAUD")  isymbol = 10;
   else if (symbol == "EURCAD")  isymbol = 11;
   else if (symbol == "GBPUSD")  isymbol = 12;
   else if (symbol == "GBPJPY")  isymbol = 13;
   else if (symbol == "GBPCHF")  isymbol = 14;
   else if (symbol == "GBPAUD")  isymbol = 15;
   else if (symbol == "GBPCAD")  isymbol = 16;
   else                          isymbol = 17;
   if(isymbol<10) MagicNumber = MagicNumber * 10;
   return (StrToInteger(StringConcatenate(MagicNumber, isymbol, timeFrame)));
}


//----------------------- PRINT COMMENT FUNCTION
//----------------------- SOURCE : CODERSGURU
void subPrintDetails()
{
   string sComment   = "";
   string sp         = "----------------------------------------\n";
   string NL         = "\n";

   sComment = sp;
   sComment = sComment + "TakeProfit=" + DoubleToStr(TakeProfit,0) + " | ";
   sComment = sComment + "TrailingStop=" + DoubleToStr(TrailingStop,0) + " | ";
   sComment = sComment + "StopLoss=" + DoubleToStr(StopLoss,0) + NL; 
   sComment = sComment + sp;
   sComment = sComment + "Reverse Entry Condition=" + subBoolToStr(ReverseCondition) + NL;
   sComment = sComment + "Confirmed On Entry=" + subBoolToStr(ConfirmedOnEntry) + NL;
   sComment = sComment + "Stop And Reverse=" + subBoolToStr(StopAndReverse) + NL;
   sComment = sComment + "Pure SAR=" + subBoolToStr(PureSAR) + NL;
   sComment = sComment + sp;
   sComment = sComment + "Lots=" + DoubleToStr(Lots,2) + " | ";
   sComment = sComment + "MM=" + subBoolToStr(MM) + " | ";
   sComment = sComment + "Risk=" + DoubleToStr(Risk,0) + "%" + NL;
   sComment = sComment + sp;
  
   Comment(sComment);
}


//----------------------- BOOLEN VARIABLE TO STRING FUNCTION
//----------------------- SOURCE : CODERSGURU
string subBoolToStr ( bool value)
{
   if(value) return ("True");
   else return ("False");
}

//----------------------- ALERT ON MA CROSS
//----------------------- SOURCE : FIREDAVE
void subCrossAlert(string type)
{
   string AlertComment;
   
   if(type=="UP")   AlertComment = "Moving Average Cross UP !";
   if(type=="DOWN") AlertComment = "Moving Average Cross DOWN !";
   
   Alert(AlertComment);
   PlaySound(SoundFilename);
}

//----------------------- END FUNCTION

