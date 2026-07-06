// More information about this indicator can be found at:
// http://fxcodebase.com/


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

#property strict
#include <stdlib.mqh> 
input string EAComment            = "ClearMethod EA";// EA Comment
input string Trade_Parameters     = "___________________________________________";//Trade Parameters ___________________________________________
input double Lot                  = 0.01;   // Lot Size
input double TakeProfit           = 0;     // Take Profit   
input double StopLoss             = 0;     // Stop Loss   
input bool   ExitOpposite         = 1;      // Exit by Opposite Signal
input int    MagicNumber          = 1;      // Magic Number
input bool   ShowInfo             = 1;      // Show Info to Chart 
input ENUM_BASE_CORNER Corner     = 1;      // Info Corner
input string TrailingStopLoss     = "--------------------< Trailing Stop >--------------------";//Trailing Stop Settings ............................................................................................................
input bool   UseTrailingStop      = 0;      // Use Trailing 
input double TrailingStart	      = 15;     // Trailing Start
input double TrailingStop         = 10;     // Trailing Distance 
input string Indicators_          = "___________________________________________";//Indicators Parameters___________________________________________
input bool   IsDrawClearSignals   = true;
input bool   IsDrawMoveSignals    = false;
input bool   IsAlertClearUpSignals= false;
input bool   IsAlertClearDownSignals= false;
input bool   IsAlertMoveUpSignals = false;
input bool   IsAlertMoveDownSignals= false;
input int    BarShift             = 1;      // Signal Bar Shift
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
double lots=0, ClosingArray[100], point=0.0001, DrawDowns=0, DDBuffer=0, Drawdown=0;
int Pip=1, lotdigit=0, sh=0, sp=0;
string text[26], prefix="";
bool Buy=0, Sell=0; 
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
void OnInit() 
{ 
   sh = BarShift;ArrayResize(text,26); 
   if(MarketInfo(Symbol(),MODE_LOTSTEP)==1) lotdigit=0;
   if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.1) lotdigit=1;   
   if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.01) lotdigit=2;
   int digits=(int)MarketInfo(Symbol(),MODE_DIGITS);
   
   if(digits==4 || (Bid<1000 && digits==2)){ Pip=1;} else Pip=10;
   
   if(digits<=1) point = 1; //CFD & Indexes  
   if(digits==4 || digits==5) point = 0.0001; 
   if((digits==2 || digits==3) && Bid>1000) point = 1;
   if((digits==2 || digits==3) && Bid<1000) point = 0.01;
   if(StringFind(NULL,"XAU")>-1 || StringFind(NULL,"xau")>-1 || StringFind(NULL,"GOLD")>-1) point = 0.1;//Gold   
   if(IsTesting()) prefix="Test"+IntegerToString(MagicNumber)+Symbol();else prefix=IntegerToString(MagicNumber)+Symbol();
   
   return;
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  if(!IsTesting()){
  for(int i= ObjectsTotal(); i>=0; i--) 
     {
      string name= ObjectName(i);
      if(StringSubstr(name,0,4)=="Info")
        {
         ObjectDelete(name);}
        }
     }//else GVDel(prefix);
 return;
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//+----------------------------------------------------------------------------+
   // Check History...
   if(Bars < 10){ Print("Not enough bars for working the EA");return;}
//+----------------------------------------------------------------------------+
   int err;TrailingStops();Entry();OrdersClose();PrintInfo(); 
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//       
      if(Buy && 1 > Orders(-1) && CurrBar() && ClosedBar() && MarginCheck(0)) 
        {  
         double Sloss = 0, Tprof = 0;  
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = Bid - StopLoss * point;}
         if(TakeProfit == 0){ Tprof = 0;}else{ Tprof = Ask + TakeProfit * point;}             
         int Ticket = OrderSend(Symbol(), OP_BUY, Lots(), High[0], 1*Pip, Sloss, Tprof, EAComment, MagicNumber, 0, clrGreen);
         err = GetLastError();if(err!=ERR_NO_ERROR){ Print("Error on Order open = ", ErrorDescription(err));}
        }       
      if(Sell && 1 > Orders(-1) && CurrBar() && ClosedBar() && MarginCheck(1)) 
        { 
         double Sloss = 0, Tprof = 0;           
         if(StopLoss == 0){ Sloss = 0;}else{ Sloss = Ask + StopLoss * point;}
         if(TakeProfit == 0){ Tprof = 0;}else{ Tprof = Bid - TakeProfit * point;}
         int Tickets = OrderSend(Symbol(), OP_SELL, Lots(), Low[0], 1*Pip, Sloss, Tprof, EAComment, MagicNumber, 0, clrRed);
         err = GetLastError();if(err!=ERR_NO_ERROR){ Print("Error on Order open = ", ErrorDescription(err));}
        }        
   return;
}    
//OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO//
//+------------------------------------------------------------------+
//|  Get the values from the indicators                              |   
//+------------------------------------------------------------------+
double SI(int buff,int shift){ return(iCustom(NULL,0,"ClearMethodSignalsk17", IsDrawClearSignals,IsDrawMoveSignals,IsAlertClearUpSignals,
                                                       IsAlertClearDownSignals,IsAlertMoveUpSignals,IsAlertMoveDownSignals,buff,shift));}   
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+------------------------------------------------------------------+
//| Get Entry Signals                                                |  iClose(NULL,0,0)
//+------------------------------------------------------------------+
void Entry() 
{ 
   Buy = false; Sell = false;// Just for updating the signal in each ticks!!! 
   
  Buy  = (SI(0,1) != 0 && SI(0,2) == 0); 
   
  Sell = (SI(1,1) != 0 && SI(1,2) == 0); 
}     
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Calculate Trade Volume(Lot)                                      |
//+------------------------------------------------------------------+
double Lots()
{ 
   lots = Lot; double LotStep = MarketInfo(Symbol(),MODE_LOTSTEP), 
   MaxLot = MarketInfo(Symbol(),MODE_MAXLOT), MinLot = MarketInfo(Symbol(),MODE_MINLOT);
   return( MathRound(MathMin(MathMax(lots,MinLot),MaxLot)/LotStep)*LotStep );
} 
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Close Opened Orders                                              |
//+------------------------------------------------------------------+
void OrdersClose()
{ 
   int err; if(!ExitOpposite)return; 
   
   for(int i = 0; i < OrdersTotal(); i++) 
      {
       bool OrSel = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);    
       if(OrderSymbol() == Symbol() && (MagicNumber == 0 || OrderMagicNumber() == MagicNumber)) 
         {
          if(OrderType() == OP_BUY && Sell && iTime(NULL,0,0) > iTime(NULL,0,iBarShift(NULL,0,OrderOpenTime(),1))) 
            {
             bool close = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, clrBlue);CloseOrders(0); 
             err = GetLastError(); if(err!=ERR_NO_ERROR){ Print("Error on Order closing = ", ErrorDescription(err));}
            }               
          if(OrderType() == OP_SELL && Buy && iTime(NULL,0,0) > iTime(NULL,0,iBarShift(NULL,0,OrderOpenTime(),1)))   
            {
             bool close = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, clrRed);CloseOrders(1); 
             err = GetLastError(); if(err!=ERR_NO_ERROR){ Print("Error on Order closing = ", ErrorDescription(err));}}}
            }  
}    
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Trailing Stop                                                    |
//+------------------------------------------------------------------+
void TrailingStops() 
{
  if(!UseTrailingStop || TrailingStop == 0)return; 
  
  for(int i = 0; i < OrdersTotal(); i++) 
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {    
      if(OrderSymbol() == Symbol() && (MagicNumber == 0 || OrderMagicNumber() == MagicNumber)) 
        {         
        if(OrderType() == OP_BUY) 
          { 
          if(Bid - OrderOpenPrice() > TrailingStart * point && OrderStopLoss() < ND(Bid-TrailingStop*point)) 
            { 
             Trail(ND(Bid - TrailingStop * point),OrderTicket());
            }
        }                       
        if(OrderType() == OP_SELL)          
          {
          if(OrderOpenPrice() - Ask > TrailingStart * point && (OrderStopLoss()==0||OrderStopLoss()>ND(Ask+TrailingStop*point)))
            {
             Trail(ND(Ask + TrailingStop * point),OrderTicket());                     
            }
         }
}}}}
//+------------------------------------------------------------------------------------------------------------------------------------+
void Trail(double sl, int ticket)
{  
   int err;
   if(OrderSelect(ticket, SELECT_BY_TICKET,MODE_TRADES))
     {    
      if(OrderSymbol() == Symbol() && OrderType() <= 1) 
        {   
         bool modify = OrderModify(ticket, OrderOpenPrice(), sl, OrderTakeProfit(), 0, clrGold);err = GetLastError();
         if(err!=ERR_NO_ERROR){ Print("Error on Trail Order modify = ", ErrorDescription(err));}}
        }
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+
double ND(double price)
{
   if(price > 0)return(NormalizeDouble(price,_Digits));
   return(0);
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Get total order                                                  |
//+------------------------------------------------------------------+
int Orders(int type)
{
   int count=0;
   //-1= All,0=Buy,1=Sell,2=BuyLimit,3=SellLimit,4=BuyStop,5=SellStop,6=AllBuy,7=AllSell,8=AllMarket,9=AllPending;   
   for(int x=OrdersTotal()-1;x>=0;x--)
      {
      if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES)){ 
      if(OrderSymbol()==Symbol() && (MagicNumber == 0 || OrderMagicNumber() == MagicNumber)) 
        {
         if(type < 0){ count++;}
         if(OrderType() == type && type >= 0){ count++;}  
         if(OrderType() <= 1 && type == 8){ count++;}  
         if(OrderType() > 1 && type == 9){ count++;}  
         if((OrderType() == 0 || OrderType() == 2 || OrderType() == 4) && type == 6){ count++;}
         if((OrderType() == 1 || OrderType() == 3 || OrderType() == 5) && type == 7){ count++;}       
        }}}   
   return(count);
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------+
//|  Close Orders                                              |
//+------------------------------------------------------------+  
bool CloseOrders(int type)
{ //-1= All,0=Buy,1=Sell,2=BuyLimit,3=SellLimit,4=BuyStop,5=SellStop,6=All Buys,7=All Sells,8=All Market,9=All Pending;
  bool oc=0;    
  for(int i=OrdersTotal()-1;i>=0;i--){
  bool os = OrderSelect(i,SELECT_BY_POS, MODE_TRADES);
  if(OrderSymbol()==Symbol() && (MagicNumber == 0 || OrderMagicNumber() == MagicNumber))
    {   
     if(type==-1){
     if(OrderType()==0){ oc = OrderClose(OrderTicket(),OrderLots(),Bid,1000,clrGold);}
     if(OrderType()==1){ oc = OrderClose(OrderTicket(),OrderLots(),Ask,1000,clrGold);}      
     if(OrderType()>1){ oc = OrderDelete(OrderTicket());}}  
     if(OrderType()>1 && type==9){ oc = OrderDelete(OrderTicket());} 
     if(OrderType()<=1 && type==8){ oc = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),1000,clrGold);}
     if(OrderType()==type && type==0){ oc = OrderClose(OrderTicket(),OrderLots(),Bid,1000,clrGold);}
     if(OrderType()==type && type==1){ oc = OrderClose(OrderTicket(),OrderLots(),Ask,1000,clrGold);} 
     if(OrderType()==type && OrderType()> 1){ oc = OrderDelete(OrderTicket());} 
     if(OrderType()==0 && type==6){ oc = OrderClose(OrderTicket(),OrderLots(),Bid,1000,clrGold);}  
     if((OrderType()==2 || OrderType()== 4) && type==6){ oc = OrderDelete(OrderTicket());}   
     if(OrderType()==1 && type==7){ oc = OrderClose(OrderTicket(),OrderLots(),Bid,1000,clrGold);}  
     if((OrderType()==3 || OrderType()== 5) && type==7){ oc = OrderDelete(OrderTicket());}       
     for(int x=0;x<100;x++)
     {
      if(ClosingArray[x]==0)
      {
       ClosingArray[x]=OrderTicket();
       break; } } } }
   return(oc);
}      
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH// 
//+------------------------------------------------------------------+
//| Print info to chart                                              |
//+------------------------------------------------------------------+
void PrintInfo()
{
  string Current = "NO ORDER";
  
  if(CurrentProfit()!=0){ Current = DoubleToStr(CurrentProfit(),2);}
  
  if(AccountBalance()!=0){ DrawDowns = DrawDown()*100.0/AccountBalance();}
    
  if(ShowInfo){    
    text[1]= EAComment;
    text[2]= "-------------------------------------------";
    text[3]= "Time Current: " + TimeToStr(TimeCurrent());
    text[4]= "-------------------------------------------";    
    text[5]= "Account Number: " + IntegerToString(AccountNumber());
    text[6]= "Account Leverage: " + IntegerToString(AccountLeverage());
    text[7]= "Account Balance: " + DoubleToStr(AccountBalance(), 2);
    text[8]= "Account Equity: " + DoubleToStr(AccountEquity(), 2);
    text[9]= "Free Margin: " + DoubleToStr(AccountFreeMargin(), 2);
    text[10]= "Used Margin: " + DoubleToStr(AccountMargin(), 2);
    text[11]= "Max. Draw Down: " + DoubleToStr(DrawDown(), 2)+"("+DoubleToStr(DrawDowns,2)+"%"")";
    text[12]= "Account Today Profit: " + DoubleToStr(DailyProfits(), 2);
    text[13]= "-------------------------------------------";
    text[14]= "Lot Size: " + DoubleToStr(Lots(),lotdigit);
    text[15]= "Take Profit: " + DoubleToStr(TakeProfit,0);
    text[16]= "Stop Loss: " + DoubleToStr(StopLoss,0);    
    text[17]= "Spread: " + DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD)/Pip, 2); 
    text[18]= "Current Profit: " + Current;     
    text[19]= "-------------------------------------------";
    
    int i=1, k=20;
    while (i<=19)
    {
       string ChartInfo = "Info"+IntegerToString(i);
       ObjectCreate(ChartInfo, OBJ_LABEL, 0, 0, 0);
       ObjectSetText(ChartInfo, text[i], 9, "Arial", Aqua);
       ObjectSet(ChartInfo, OBJPROP_CORNER, Corner);   
       ObjectSet(ChartInfo, OBJPROP_XDISTANCE, 7);  
       ObjectSet(ChartInfo, OBJPROP_YDISTANCE, k);
       i++;
       k=k+13;
    }
  }
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+----------------------------------------------------------------------------------+
//| Daily Profit                                                                     |
//+----------------------------------------------------------------------------------+  
double DailyProfits()
{   
   int i; double LastDayProfits=0;
   for(i=0;i<OrdersHistoryTotal();i++)
    {
     bool os = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
     if(OrderMagicNumber()==MagicNumber && TimeDayOfYear(OrderCloseTime())==DayOfYear()){
     LastDayProfits=LastDayProfits+OrderProfit()+OrderSwap()+OrderCommission();}}
  
   for(i = 0; i < OrdersTotal(); i++) 
    {
     bool Os = OrderSelect(i,SELECT_BY_POS, MODE_TRADES); 
     if(OrderMagicNumber()==MagicNumber && TimeDayOfYear(OrderOpenTime())==DayOfYear()){
     LastDayProfits=LastDayProfits+OrderProfit()+OrderSwap()+OrderCommission();
   }}       
  return(LastDayProfits);
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+----------------------------------------------------------------------------------+
//| Current Profit                                                                   |
//+----------------------------------------------------------------------------------+  
double CurrentProfit()
{   
   double Profit=0;
   for(int i = 0;i < OrdersTotal();i++) 
      {
       bool Os = OrderSelect(i, SELECT_BY_POS, MODE_TRADES); 
       if(OrderSymbol()==Symbol() && (MagicNumber == 0 || OrderMagicNumber() == MagicNumber)){
       Profit=Profit+OrderProfit()+OrderSwap()+OrderCommission();}
      }       
  return(Profit);
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+----------------------------------------------------------------------------------+
//| Get Draw Down                                                                    |
//+----------------------------------------------------------------------------------+
double DrawDown()
{
   double DD=AccountBalance()-AccountEquity();
   if(DD>DDBuffer)DDBuffer=DD;
   return(DDBuffer);
} 
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Check Free Margin                                                |
//+------------------------------------------------------------------+
bool MarginCheck(int type)// 0 - buy, 1 - sell;
{  
   if((AccountFreeMarginCheck(Symbol(), type, Lots()) <= 0.0 || 
      GetLastError() == ERR_NOT_ENOUGH_MONEY)){
      Print("NOT ENOUGH MONEY TO TRADE OPEN");return(false);}             
   return(true);
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Disable trade in current bar(if one is already open)             |
//+------------------------------------------------------------------+
bool CurrBar()
{ 
   bool yes = 1;
//+------------------------------------------------------------------+
   for(int i = OrdersTotal()-1; i >= 0; i--)
      {
    	if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    	{  
    	if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) 
      {     
       if(OrderOpenTime() >= iTime(Symbol(),0,0)) yes = 0;   
      }}}   
   return(yes);
}     
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Disable trade in current bar(if one is already opened and closed)|
//+------------------------------------------------------------------+
bool ClosedBar()
{ 
   bool yes = 1;
//+------------------------------------------------------------------+
   for(int i = OrdersHistoryTotal()-1; i>=0; i--)
      {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) 
      { 
      Print("Error in history!"); break; 
      }
      if(OrderSymbol() != Symbol() || OrderType()>OP_SELL) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) 
      {	    
      if(OrderOpenTime() >= iTime(NULL,0,0)) yes = 0;   
    	}}   
   return(yes);
} 
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//

                                                                        //| THE END |\\  
 
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//