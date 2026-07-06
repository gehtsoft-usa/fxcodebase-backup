//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75599

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
enum RiskCalc{ 
AA=1//AccountBalance
,BB=2//AccountEquity
,CC=3//AccountFreeMargin
};
input string NameEA                     = "PipFinite EA";//EA Comment
input string Indicators_Parameters_     = "______________________________________________________";//Indicators Settings _______________________________________________
input string                           _="<<<<<<<<<<<<<<<<<<<<<->>>>>>>>>>>>>>>>>>>>>";//PipFinite Breakout Analyzer   
input int    Periods                    = 4;            //Period  
input string                ___________ ="<<<<<<<<<<<<<<<<<<<<<->>>>>>>>>>>>>>>>>>>>>";//PipFinite Strength Meter    
input int    SMPeriod                   = 7;            //Period 
input int    ThresholdLevel             = 2;            //Threshold Level
input string                      ______="<<<<<<<<<<<<<<<<<<<<<->>>>>>>>>>>>>>>>>>>>>";//PipFinite Exit Scope 
input int    bb                         = 1;            //Volume Factor
input string                    ________="<<<<<<<<<<<<<<<<<<<<<->>>>>>>>>>>>>>>>>>>>>";//Indicator ATR
input int    ATRPeriod                  = 14;           //ATR Period
input double ATRMulti                   = 0;            //ATR Multiplier 
input double ATROffset                  = 0;            //ATR Offset
input string Trade_Parameters_          = "______________________________________________________";//Trade Parameters _______________________________________________
input double StopLoss                   = 0;            //Stop Loss
input double TakeProfit                 = 100;          //Take Profit
input bool   ExitOpposite               = 1;            //Exit by Opposite Signal
input bool   ExitScope                  = 1;            //Exit by PipFinite Exit Scope
input int    MagicNumber                = 1;            //Magic Number  
input int    MaxOpenOrders              = 1;            //Max. Open Orders
input string Trailing_                  = "--------------------< Trailing Stop >--------------------";//Trailing Stop Settings ............................................................................................................
input bool   UseTrailing_Stop           = false;        //Use Trailing Stop
input double TrailingStopStart	       = 10;           //Trailing Stop Start
input double TrailingStopStep           = 10;           //Trailing Stop Step
input string MM_Settings                = "--------------------< Money Management >--------------------";//Money Management Settings ...........................................................................................................
input double FixedLots                  = 0.1;          //Fixed Lot 
input bool   RiskLots                   = 1;            //Use Risk % Lot 
input RiskCalc RiskType                = 1;            //Risk Calculate Type
input double RiskPercent                = 1;            //Risk % 
input string Time_Filter                = "--------------------< Trade Time >--------------------";//Trade Time Settings ............................................................................................................  
input bool   Use_Time_Filter            = false;        //Use Time Filter
input string Time_Start                 = "06:00";      //Time Start 
input string Time_End                   = "21:59";      //Time End 
input bool   StoponFriday               = false;        //Stop/Close on Friday
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
double Drawdown,AllProfit=0,point,ClosingArray[100],Lots,Sloss,Tprof,SLBUY=0,buy=0,sell=0,buy1=0,sell1=0,buy2=0,sell2=0,buy3=0,sell3=0,risk,SLL=0,LastLot=0,lot=0,atr=0;
bool Long=false,Short=false,Long2=false,Short2=false,Buy=false,Sell=false,Buy2=false,Sell2=false,Buy3=false,Sell3=false;int PipValue=1,Lot_Digits,signal,digit_lot=0,
zz=0,xx=0,supp=0,arr=0;
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() 
  {  
   if((Bid<10 && _Digits==5)||(Bid>10 && _Digits==3)) { PipValue=10;}
   if((Bid<10 && _Digits==4)||(Bid>10 && _Digits==2)) { PipValue= 1;}   
   point = Point*PipValue;    
   if(MarketInfo(Symbol(),MODE_LOTSTEP)>=0.01) digit_lot=2;   
   if(MarketInfo(Symbol(),MODE_LOTSTEP)>=0.1) digit_lot=1;   
   if(MarketInfo(Symbol(),MODE_LOTSTEP)>=1) digit_lot=0;   
   return(0);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH 
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() 
{
 return(0);
}
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
//+------------------------------------------------------------------+
//| Time limited trading                                             |
//+------------------------------------------------------------------+    
bool GoodTime()
  {   
   if(!Use_Time_Filter)return(true);
   if(Use_Time_Filter)
     {
      if(TimeGMT()>StrToTime(Time_Start) && TimeGMT()<StrToTime(Time_End))return(true);      
     }
   return(false);
  } 
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//|  Lot Calculate                                                   |
//+------------------------------------------------------------------+
void LotsSize()
   {       
    Lots = FixedLots;
    if(RiskType== 1){ risk = AccountBalance();}
    if(RiskType== 2){ risk = AccountEquity();}
    if(RiskType== 3){ risk = AccountFreeMargin();}     
    if(Lots<MarketInfo(Symbol(),MODE_MINLOT)) Lots=MarketInfo(Symbol(),MODE_MINLOT);
    if(Lots>MarketInfo(Symbol(),MODE_MAXLOT)) Lots=MarketInfo(Symbol(),MODE_MAXLOT);  
    if(MarketInfo(Symbol(),MODE_MINLOT) < 0.1)Lot_Digits=2;
    if (RiskLots){ Lots = NormalizeDouble(risk * RiskPercent/100000,digit_lot);}  
   }   
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+----------------------------------------------------------------------------------+
//|  CloseBuy                                                                        |
//+----------------------------------------------------------------------------------+  
int CloseBuyW()
{
  for(int i=OrdersTotal()-1;i>=0;i--){
   bool os = OrderSelect(i,SELECT_BY_POS);
   if(OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
    {    
     if(OrderType()==OP_BUY){       
     bool oc = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble
     (MarketInfo(Symbol(),MODE_BID),(int)MarketInfo(Symbol(),MODE_DIGITS)),1000,Gold);      
     Print("Closed by Weekend");}
     for(int x=0;x<100;x++)
     {
      if(ClosingArray[x]==0)
      {
       ClosingArray[x]=OrderTicket();
       break; } } } }
   return(1);
}
//+----------------------------------------------------------------------------------+
//| CloseSell                                                                        |
//+----------------------------------------------------------------------------------+
int CloseSellW() 
{
  for(int i=OrdersTotal()-1;i>=0;i--){
   bool os = OrderSelect(i,SELECT_BY_POS);
   if(OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
    {    
     if(OrderType()==OP_SELL){       
     bool oc = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble
     (MarketInfo(Symbol(),MODE_ASK),(int)MarketInfo(Symbol(),MODE_DIGITS)),1000,Gold); 
     Print("Closed by Weekend");}   
     for(int x=0;x<100;x++)
     {
      if(ClosingArray[x]==0)
      {
       ClosingArray[x]=OrderTicket();
       break; } } } }
   return(1);
}
//+----------------------------------------------------------------------------------+
//|  CloseBuy                                                                        |
//+----------------------------------------------------------------------------------+  
int CloseBuyD()
{
  for(int i=OrdersTotal()-1;i>=0;i--){
   bool os = OrderSelect(i,SELECT_BY_POS);
   if(OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
    {    
     if(OrderType()==OP_BUY){       
     bool oc = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble
     (MarketInfo(Symbol(),MODE_BID),(int)MarketInfo(Symbol(),MODE_DIGITS)),1000,Gold);   
     Print("Closed by Session End");}   
     for(int x=0;x<100;x++)
     {
      if(ClosingArray[x]==0)
      {
       ClosingArray[x]=OrderTicket();
       break; } } } }
   return(1);
}
//+----------------------------------------------------------------------------------+
//| CloseSell                                                                        |
//+----------------------------------------------------------------------------------+
int CloseSellD() 
{
  for(int i=OrdersTotal()-1;i>=0;i--){
   bool os = OrderSelect(i,SELECT_BY_POS);
   if(OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
    {    
     if(OrderType()==OP_SELL){       
     bool oc = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble
     (MarketInfo(Symbol(),MODE_ASK),(int)MarketInfo(Symbol(),MODE_DIGITS)),1000,Gold);    
     Print("Closed by Session End");}   
     for(int x=0;x<100;x++)
     {
      if(ClosingArray[x]==0)
      {
       ClosingArray[x]=OrderTicket();
       break; } } } }
   return(1);
}
//+----------------------------------------------------------------------------------+
//|  CloseBuy                                                                        |
//+----------------------------------------------------------------------------------+  
int CloseBuyE()
{
  for(int i=OrdersTotal()-1;i>=0;i--){
   bool os = OrderSelect(i,SELECT_BY_POS);
   if(OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
    {    
     if(OrderType()==OP_BUY){       
     bool oc = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble
     (MarketInfo(Symbol(),MODE_BID),(int)MarketInfo(Symbol(),MODE_DIGITS)),1000,Gold);      
     Print("Closed by Exit Scope");}   
     for(int x=0;x<100;x++)
     {
      if(ClosingArray[x]==0)
      {
       ClosingArray[x]=OrderTicket();
       break; } } } }
   return(1);
}
//+----------------------------------------------------------------------------------+
//| CloseSell                                                                        |
//+----------------------------------------------------------------------------------+
int CloseSellE() 
{
  for(int i=OrdersTotal()-1;i>=0;i--){
   bool os = OrderSelect(i,SELECT_BY_POS);
   if(OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
    {    
     if(OrderType()==OP_SELL){       
     bool oc = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble
     (MarketInfo(Symbol(),MODE_ASK),(int)MarketInfo(Symbol(),MODE_DIGITS)),1000,Gold);    
     Print("Closed by Exit Scope");} 
     for(int x=0;x<100;x++)
     {
      if(ClosingArray[x]==0)
      {
       ClosingArray[x]=OrderTicket();
       break; } } } }
   return(1);
}
//+----------------------------------------------------------------------------------+
//|  CloseBuy                                                                        |
//+----------------------------------------------------------------------------------+  
int CloseBuyO()
{
  for(int i=OrdersTotal()-1;i>=0;i--){
   bool os = OrderSelect(i,SELECT_BY_POS);
   if(OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
    {    
     if(OrderType()==OP_BUY){       
     bool oc = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble
     (MarketInfo(Symbol(),MODE_BID),(int)MarketInfo(Symbol(),MODE_DIGITS)),1000,Gold);      
     Print("Closed by Opposite Breakout Analyzer");} 
     for(int x=0;x<100;x++)
     {
      if(ClosingArray[x]==0)
      {
       ClosingArray[x]=OrderTicket();
       break; } } } }
   return(1);
}
//+----------------------------------------------------------------------------------+
//| CloseSell                                                                        |
//+----------------------------------------------------------------------------------+
int CloseSellO() 
{
  for(int i=OrdersTotal()-1;i>=0;i--){
   bool os = OrderSelect(i,SELECT_BY_POS);
   if(OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
    {    
     if(OrderType()==OP_SELL){       
     bool oc = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble
     (MarketInfo(Symbol(),MODE_ASK),(int)MarketInfo(Symbol(),MODE_DIGITS)),1000,Gold);    
     Print("Closed by Opposite Breakout Analyzer");} 
     for(int x=0;x<100;x++)
     {
      if(ClosingArray[x]==0)
      {
       ClosingArray[x]=OrderTicket();
       break; } } } }
   return(1);
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
void TrailingStops() 
  {
  for(int i = 0; i < OrdersTotal(); i++) 
     {
      bool OrSel = OrderSelect(i, SELECT_BY_POS);    
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) 
        { 
        if(OrderType() == OP_BUY && UseTrailing_Stop && TrailingStopStep > 0 && TrailingStopStart > 0) 
          { 
          if(Bid - OrderOpenPrice() > TrailingStopStart* point && Bid - OrderOpenPrice() > TrailingStopStart * point) 
            {
             if(OrderStopLoss() < (Bid - TrailingStopStep* point))
                bool modify = OrderModify(OrderTicket(), OrderOpenPrice(),Bid - TrailingStopStep* point, OrderTakeProfit(), 0, Lime);
                }
             }                       
        if(OrderType() == OP_SELL && UseTrailing_Stop && TrailingStopStep > 0 && TrailingStopStart > 0)          
           {
           if(OrderOpenPrice() - Ask > TrailingStopStart* point && OrderOpenPrice() - Ask > TrailingStopStart * point)
             {
             if(OrderStopLoss() == 0 || OrderStopLoss() > Ask + TrailingStopStep* point)
               bool modify = OrderModify(OrderTicket(), OrderOpenPrice(),Ask + TrailingStopStep* point, OrderTakeProfit(), 0, Red);                        
               }}}}
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| get total order                                                  |
//+------------------------------------------------------------------+
int total()
  {
   int counter=0;
   for(int x=OrdersTotal()-1;x>=0;x--)
     {
      if(OrderSelect(x,0) && OrderSymbol()==Symbol() && 
         OrderMagicNumber()==MagicNumber)
        {
         counter++;
        }}   
   return(counter);
  } 
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
void Closer(){  
   for(int i = 0; i < OrdersTotal(); i++) 
     {
       bool os = OrderSelect(i, SELECT_BY_POS);    
       if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) 
         {           
          if(OrderType() == OP_BUY) 
            {  
            if(Sell3 && ExitScope){ CloseBuyE();}
            }
          if(OrderType() == OP_SELL) 
            {  
            if(Buy3 && ExitScope){ CloseSellE();}
            } 
          if(OrderType() == OP_BUY) 
            {  
            if(Sell2 && ExitOpposite){ CloseBuyO();}
            }
          if(OrderType() == OP_SELL) 
            {  
            if(Buy2 && ExitOpposite){ CloseSellO();}
            }             
}}}
//OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO   
//+------------------------------------------------------------------+
//|  Open Rules                                                      |
//+------------------------------------------------------------------+
void Indicators() 
{  
   if(!ExitScope)HideTestIndicators(true); 
   double buf3 = iCustom(_Symbol,0,"Market\\PipFinite Exit Scope","",bb,1000,"",3,"",DodgerBlue,Red,LimeGreen,Magenta,"",0,0,0,0,1);   
   double buf4 = iCustom(_Symbol,0,"Market\\PipFinite Exit Scope","",bb,1000,"",3,"",DodgerBlue,Red,LimeGreen,Magenta,"",0,0,0,1,1); 
   double buf30 = iCustom(_Symbol,0,"Market\\PipFinite Exit Scope","",bb,1000,"",3,"",DodgerBlue,Red,LimeGreen,Magenta,"",0,0,0,2,1);   
   double buf40 = iCustom(_Symbol,0,"Market\\PipFinite Exit Scope","",bb,1000,"",3,"",DodgerBlue,Red,LimeGreen,Magenta,"",0,0,0,3,1);  
   HideTestIndicators(false);
   double buf11 = iCustom(NULL, 0, "Market\\PipFinite Breakout Analyzer","",Periods,1000,"",1,1,0,0,2,2,8,"",DodgerBlue,HotPink,ForestGreen,Maroon,DarkSlateGray,"",0,0,0,0,1);
   double buf22 = iCustom(NULL, 0, "Market\\PipFinite Breakout Analyzer","",Periods,1000,"",1,1,0,0,2,2,8,"",DodgerBlue,HotPink,ForestGreen,Maroon,DarkSlateGray,"",0,0,0,1,1);
   double SM1 = iCustom(Symbol(),0,"Market\\PipFinite Strength Meter","",SMPeriod,1000,"",0,0,8,"",LightBlue,YellowGreen,LimeGreen,Blue,Plum,HotPink,OrangeRed,Magenta,"",0,0,0,0,0,1); 
   double SM2 = iCustom(Symbol(),0,"Market\\PipFinite Strength Meter","",SMPeriod,1000,"",0,0,8,"",LightBlue,YellowGreen,LimeGreen,Blue,Plum,HotPink,OrangeRed,Magenta,"",0,0,0,0,1,1);
     
   if(StopLoss!=0)HideTestIndicators(true); 
   atr = iATR(NULL, 0, ATRPeriod,0);
   HideTestIndicators(false);   
    
   Buy  = (buf11 != EMPTY_VALUE && SM1 >= ThresholdLevel);  
   Sell = (buf22 != EMPTY_VALUE && SM2 <= -ThresholdLevel); 
   Buy2  = (buf11 != EMPTY_VALUE);  
   Sell2 = (buf22 != EMPTY_VALUE);    
   Buy3  = (buf30 != EMPTY_VALUE);     
   Sell3 = (buf40 != EMPTY_VALUE);    
}     
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() 
  {
   bool ban=false,band=false;LotsSize();Indicators();TrailingStops();
   Closer();if(!GoodTime()){ CloseBuyD();CloseSellD();return(0);}
   if(StoponFriday && DayOfWeek()==5){ CloseBuyW();CloseSellW();return(0);}
//+------------------------------------------------------------------+
   for(int i=OrdersTotal()-1; i >= 0; i--)
      {
    	if(OrderSelect (i, SELECT_BY_POS))
    	{        
	   if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) 
      {
      if(OrderOpenTime() >= iTime(NULL,0,0)) ban = true;   
    	}}}if(ban){ return(0);}
//+------------------------------------------------------------------+
   for(int i=OrdersHistoryTotal()-1;i>=0;i--)
      {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) 
       { 
       Print("Error in history!"); break; 
       }
       if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;
       if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) 
       {
       if(OrderOpenTime() >= iTime(NULL,0,0)) band = true;   
    	 }}if(band){ return(0);}     
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH   
   if(total() < MaxOpenOrders && GoodTime())
     {   
      if(Buy){
           if(StopLoss == 0){Sloss = Ask - (atr*ATRMulti)+ATROffset;} 
           if(StopLoss != 0){ Sloss = Ask - StopLoss * point;}
           if(TakeProfit == 0){Tprof = 0;}else{ Tprof = Bid + TakeProfit * point;}
           int Tiketb= OrderSend(Symbol(), OP_BUY, Lots, Ask, PipValue, Sloss, Tprof, NameEA ,MagicNumber, 0, Green);
           }
      if(Sell){                  
           if(StopLoss == 0){Sloss = Bid + (atr*ATRMulti)+ATROffset;;} 
           if(StopLoss != 0){ Sloss = Bid + StopLoss * point;}
           if(TakeProfit == 0){Tprof = 0;}else{ Tprof = Ask - TakeProfit * point;}
           int Tikets= OrderSend(Symbol(), OP_SELL, Lots, Bid, PipValue, Sloss, Tprof, NameEA ,MagicNumber, 0, Red);
           }    
     }                        
   return(0);
}
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75599

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 