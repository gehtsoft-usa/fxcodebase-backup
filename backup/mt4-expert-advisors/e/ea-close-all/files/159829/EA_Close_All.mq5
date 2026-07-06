// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=76114

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
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

#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>
#include <Trade/OrderInfo.mqh> 
  
input string EAComment              = "EA Close All";// EA Comment 
input int    MagicNumber            = 0;             // Magic Number
input bool   ShowInfo               = 1;             // Show Info to Chart 
input ENUM_BASE_CORNER Corner       = 0;             // Info Corner
input ENUM_ANCHOR_POINT Anchor      = 0;             // Info Anchor
input string CloseAtPipsProfits     = "--------------------< Close by Pips Profit >--------------------";//Close by Pips Profit ...........................................................................................................
input bool   UseCloseAtPipsProfits  = 0;             // Close by Pips Profit
input int    PipsProfit             = 5;             // Profit in Pips 
input string CloseAtProfits         = "--------------------< Close by $ Profit >--------------------";//Close by $ Profit ...........................................................................................................
input bool   UseCloseAtProfits      = 0;             // Close by $ Profit
input double Profit                 = 5;             // Profit in $ 
input string ClosePercentLoss       = "--------------------< Close by % Loss >--------------------";//Close by % Loss ...........................................................................................................
input bool   CloseAtPercentLoss     = 0;             // Close by % Loss
input double PercentLoss            = 5;             // Loss %
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
double ClosingArray[100], DrawDowns=0, DDBuffer=0, DDBuffer1=0,DDBuffer2, margen= 0, Drawdown=0;int Pip=1, lotdigit=0;string text[26], prefix="";
CTrade trade;
CPositionInfo positionInfo;
COrderInfo orderInfo;
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() 
{ 
   trade.SetExpertMagicNumber(MagicNumber);
   
   trade.Buy(0.1,Symbol(),SymbolInfoDouble(Symbol(),SYMBOL_ASK),0,0,"");
   int digits=(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
   double bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   
   if(digits==4 || (bid<1000 && digits==2)){ Pip=1;} else Pip=10;
   
   if(MQLInfoInteger(MQL_TESTER)) prefix="Test"+IntegerToString(MagicNumber);
   else prefix=IntegerToString(MagicNumber);
   
   return(INIT_SUCCEEDED);
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  if(!MQLInfoInteger(MQL_TESTER)){
  for(int i= ObjectsTotal(0); i>=0; i--) 
     {
      string name= ObjectName(0,i);
      if(StringSubstr(name,0,4)=="Info")
        {
         ObjectDelete(0,name);}
        }
     } else GVDel(prefix);
 return;
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{ 
   OrdersClose();if(!MQLInfoInteger(MQL_OPTIMIZATION)) PrintInfo();  
 
   return;
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Orders Close                                                     |
//+------------------------------------------------------------------+ 
void OrdersClose()
{ 
   if(UseCloseAtPipsProfits && 0 < Orders(-1) && CheckPipsProfit(-1)> PipsProfit && GVGet("EPPb")==0){ GVSet("EPPb",1);} 

   if(UseCloseAtPipsProfits && 0 < Orders(-1) && GVGet("EPPb")==1){ if(CloseOrders(-1,FIFO(-1))){ Print("-> Exit with pips profits!");}} 
        
   if(UseCloseAtProfits && CheckProfit(-1) > 0 && CheckProfit(-1) >= Profit && GVGet("EPb")==0){ GVSet("EPb",1);} 
   
   if(UseCloseAtProfits && 0 < Orders(-1) && GVGet("EPb")==1){ if(CloseOrders(-1,FIFO(-1))){ Print("-> Exit with $ profits!");}}   
   
   if(CloseAtPercentLoss && 0 < Orders(-1) && CheckProfit(-1) < 0 && MathAbs(CheckProfit(-1))> (PercentLoss*AccountInfoDouble(ACCOUNT_BALANCE)/100) && GVGet("EPlb")==0){ GVSet("EPlb",1);} 
   
   if(CloseAtPercentLoss && 0 < Orders(-1) && GVGet("EPlb")==1){ if(CloseOrders(-1,FIFO(-1))){ Print("-> Exit with % loss!");}}                                                                  

   if(1 > Orders(-1)){ GVSet("EPPb",0);GVSet("EPb",0);GVSet("EPlb",0);}  
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Check Pips Profit                                                |
//+------------------------------------------------------------------+     
double CheckPipsProfit(int type) //-1= All,0=Buy,1=Sell; 
{
   double Profitb=0, Profits=0; 
    
   for(int i=PositionsTotal()-1;i>=0;i--)
      {
       if(positionInfo.SelectByIndex(i))            
        {
         if(MagicNumber == 0 || positionInfo.Magic() == MagicNumber)
          {         
           if(positionInfo.PositionType()==POSITION_TYPE_BUY){  
           Profitb=Profitb+(((SymbolInfoDouble(positionInfo.Symbol(),SYMBOL_BID))-positionInfo.PriceOpen())/point(positionInfo.Symbol()));} 
           if(positionInfo.PositionType()==POSITION_TYPE_SELL){  
           Profits=Profits+((positionInfo.PriceOpen()-SymbolInfoDouble(positionInfo.Symbol(),SYMBOL_ASK))/point(positionInfo.Symbol()));} 
          }
        }
      } 
       if(0==type){ return(Profitb);}
       if(1==type){ return(Profits);}
       if(-1==type){ return(Profits+Profitb);}
     return(0);
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Check $ Profit                                                   |
//+------------------------------------------------------------------+     
double CheckProfit(int type) //-1= All,0=Buy,1=Sell;
{
  double Profitb=0,Profits=0;       
  for(int i=PositionsTotal()-1;i>=0;i--)
     {
      if(positionInfo.SelectByIndex(i))            
       {
        if(MagicNumber == 0 || positionInfo.Magic() == MagicNumber)
         {        
          if(positionInfo.PositionType()==POSITION_TYPE_BUY){ Profitb+=positionInfo.Profit()+positionInfo.Swap()+positionInfo.Commission();} 
          if(positionInfo.PositionType()==POSITION_TYPE_SELL){ Profits+=positionInfo.Profit()+positionInfo.Swap()+positionInfo.Commission();} 
         }
       }
     } 
       if(0==type){ return(Profitb);}
       if(1==type){ return(Profits);}
       if(-1==type){ return(Profits+Profitb);}
     return(0);
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------+
//|  Close Orders                                              |
//+------------------------------------------------------------+  
bool CloseOrders(int type, ulong tick)
{  
  bool oc=0;    
  if(positionInfo.SelectByTicket(tick))
   {
    if(MagicNumber == 0 || positionInfo.Magic() == MagicNumber)
     {   
      if(type==-1){
       if(positionInfo.PositionType()==POSITION_TYPE_BUY){ oc = trade.PositionClose(tick);}
       if(positionInfo.PositionType()==POSITION_TYPE_SELL){ oc = trade.PositionClose(tick);}      
      }  
      if(positionInfo.PositionType()==POSITION_TYPE_BUY && type==0){ oc = trade.PositionClose(tick);}
      if(positionInfo.PositionType()==POSITION_TYPE_SELL && type==1){ oc = trade.PositionClose(tick);} 
      if(positionInfo.PositionType()==POSITION_TYPE_BUY && type==6){ oc = trade.PositionClose(tick);}  
      if(positionInfo.PositionType()==POSITION_TYPE_SELL && type==7){ oc = trade.PositionClose(tick);}       
     
      for(int x=0;x<100;x++)
       {
        if(ClosingArray[x]==0)
         {
          ClosingArray[x]=(double)tick;
          break; 
         } 
       } 
     } 
   }
   
  // Handle pending orders
  for(int i=OrdersTotal()-1;i>=0;i--)
   {
    if(orderInfo.SelectByIndex(i))
     {
      if(MagicNumber == 0 || orderInfo.Magic() == MagicNumber)
       {
        if(type==-1 || type==6 || type==7 || type==9)
         {
          oc = trade.OrderDelete(orderInfo.Ticket());
         }
       }
     }
   }
   
   return(oc);
}   
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Get total order                                                  |
//+------------------------------------------------------------------+
int Orders(int type)
{
   int count=0;
   //-1= All,0=Buy,1=Sell,2=BuyLimit,3=SellLimit,4=BuyStop,5=SellStop,6=AllBuy,7=AllSell,8=AllMarket,9=AllPending;   
   
   // Count positions
   for(int i=PositionsTotal()-1;i>=0;i--)
      {
       if(positionInfo.SelectByIndex(i))
         { 
          if(MagicNumber == 0 || positionInfo.Magic() == MagicNumber)
           {
            if(type < 0){ count++;}
            if(positionInfo.PositionType() == POSITION_TYPE_BUY && (type == 0 || type == 6 || type == 8)){ count++;}  
            if(positionInfo.PositionType() == POSITION_TYPE_SELL && (type == 1 || type == 7 || type == 8)){ count++;}  
           }
         }  
      }
      
   // Count pending orders  
   for(int i=OrdersTotal()-1;i>=0;i--)
      {
       if(orderInfo.SelectByIndex(i))
         { 
          if(MagicNumber == 0 || orderInfo.Magic() == MagicNumber)
           {
            if(type < 0 || type == 9){ count++;}
            if(orderInfo.OrderType() == ORDER_TYPE_BUY_LIMIT && (type == 2 || type == 6)){ count++;}
            if(orderInfo.OrderType() == ORDER_TYPE_SELL_LIMIT && (type == 3 || type == 7)){ count++;}
            if(orderInfo.OrderType() == ORDER_TYPE_BUY_STOP && (type == 4 || type == 6)){ count++;}
            if(orderInfo.OrderType() == ORDER_TYPE_SELL_STOP && (type == 5 || type == 7)){ count++;}
           }
         }  
      }
      
   return(count);
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH// 
//+------------------------------------------------------------------+
//| Print info to chart                                              |
//+------------------------------------------------------------------+
void PrintInfo()
{
  string Current = "NO ORDER";
  
  if(CurrentProfit()!=0){ Current = DoubleToString(CurrentProfit(),2);}
  
  if(AccountInfoDouble(ACCOUNT_BALANCE)!=0){ DrawDowns = DrawDown()*100.0/AccountInfoDouble(ACCOUNT_BALANCE);}
    
  if(ShowInfo){    
    text[1]= EAComment;
    text[2]= "-------------------------------------------";
    text[3]= "Spread: " + DoubleToString(SymbolInfoInteger(Symbol(), SYMBOL_SPREAD)/Pip, 2); 
    text[4]= "-------------------------------------------"; 
    text[5]=  "Account Number: " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)); 
   
    text[6]= "Account Leverage: " + IntegerToString(AccountInfoInteger(ACCOUNT_LEVERAGE));
    text[7]= "Account Balance: " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2);
    text[8]= "Account Equity: " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2);
    text[9]= "Max. Draw Down: " +"-"+ DoubleToString(DrawDown(), 2)+"("+DoubleToString(DrawDowns,2)+"%"")";
    text[10]= "Max. Draw liquido: "+ "-" + DoubleToString(DrawDown()-margen(), 2); 
    text[11]= "Max. Margen: " + DoubleToString(margen(), 2);//"Time Current: " + TimeToStr(TimeCurrent());
    text[12]= "Used Margin: " + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN), 2);
    text[13]= "Free Margin: " + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2);
    text[14]= "Account Today Profit: " + DoubleToString(DailyProfits(), 2);     
    text[15]= "Current Profit: " + Current; 
   
    text[18]= "-------------------------------------------";
    
    
    
    
    
    int i=1, k=20;
    while (i<=15)
    {
       string ChartInfo = "Info"+IntegerToString(i);
       ObjectCreate(0,ChartInfo, OBJ_LABEL, 0, 0, 0);
       ObjectSetString(0,ChartInfo, OBJPROP_TEXT, text[i]);
       ObjectSetString(0,ChartInfo, OBJPROP_FONT, "Arial");
       ObjectSetInteger(0,ChartInfo, OBJPROP_FONTSIZE, 12);
       ObjectSetInteger(0,ChartInfo, OBJPROP_COLOR, clrAqua);
       ObjectSetInteger(0,ChartInfo, OBJPROP_CORNER, Corner);   
       ObjectSetInteger(0,ChartInfo, OBJPROP_ANCHOR, Anchor);  
       ObjectSetInteger(0,ChartInfo, OBJPROP_XDISTANCE, 7);  
       ObjectSetInteger(0,ChartInfo, OBJPROP_YDISTANCE, k);
       i++;
       k=k+25;
    }
  }
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+----------------------------------------------------------------------------------+
//| Daily Profit                                                                     |
//+----------------------------------------------------------------------------------+  
double DailyProfits()
{   
   double DayProfits=0;
   MqlDateTime dt;
   TimeCurrent(dt);
   int today = dt.day_of_year;
   
   // Check history
   HistorySelect(0,TimeCurrent());
   for(int i=0;i<HistoryDealsTotal();i++)
      {
       ulong ticket = HistoryDealGetTicket(i);
       if(ticket > 0)
        {
         datetime deal_time = (datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
         MqlDateTime deal_dt;
         TimeToStruct(deal_time,deal_dt);
         if(deal_dt.day_of_year == today && deal_dt.year == dt.year)
          {
           if(MagicNumber == 0 || HistoryDealGetInteger(ticket,DEAL_MAGIC) == MagicNumber)
            {
             DayProfits += HistoryDealGetDouble(ticket,DEAL_PROFIT);
             DayProfits += HistoryDealGetDouble(ticket,DEAL_SWAP);
             DayProfits += HistoryDealGetDouble(ticket,DEAL_COMMISSION);
            }
          }
        }
      }
      
   // Check current positions
   for(int i = 0; i < PositionsTotal(); i++) 
      {
       if(positionInfo.SelectByIndex(i))
        {
         datetime pos_time = positionInfo.Time();
         MqlDateTime pos_dt;
         TimeToStruct(pos_time,pos_dt);
         if(pos_dt.day_of_year == today && pos_dt.year == dt.year)
          {
           if(MagicNumber == 0 || positionInfo.Magic() == MagicNumber)
            {
             DayProfits += positionInfo.Profit();
             DayProfits += positionInfo.Swap();
             DayProfits += positionInfo.Commission();
            }
          }
        }
      }       
  return(DayProfits);
}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+----------------------------------------------------------------------------------+
//| Current Profit                                                                   |
//+----------------------------------------------------------------------------------+  
double CurrentProfit()
{   
   double Profits=0;
   
   for(int i = 0;i < PositionsTotal();i++) 
      {
       if(positionInfo.SelectByIndex(i))
        {
         if(MagicNumber == 0 || positionInfo.Magic() == MagicNumber)
          {
           Profits += positionInfo.Profit();
           Profits += positionInfo.Swap();
           Profits += positionInfo.Commission();
          }
        }
      }       
  return(Profits);
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+----------------------------------------------------------------------------------+
//| Get Draw Down                                                                    |
//+----------------------------------------------------------------------------------+
double DrawDown()
{
   double DD=AccountInfoDouble(ACCOUNT_MARGIN)-CurrentProfit();
   if(DD>DDBuffer)DDBuffer=DD;
   return(DDBuffer);
}     
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Check Symbol Points                                              |
//+------------------------------------------------------------------+     
double point(string symbol=NULL)  
{  
   string sym=symbol;if(symbol==NULL) sym=Symbol();
   double bid=SymbolInfoDouble(sym,SYMBOL_BID);
   int digits=(int)SymbolInfoInteger(sym,SYMBOL_DIGITS);
   
   if(digits<=1) return(1); //CFD & Indexes  
   if(digits==4 || digits==5) return(0.0001); 
   if((digits==2 || digits==3) && bid>1000) return(1);
   if((digits==2 || digits==3) && bid<1000) return(0.01);
   if(StringFind(sym,"XAU")>-1 || StringFind(sym,"xau")>-1 || StringFind(sym,"GOLD")>-1) return(0.1);//Gold  
   return(0);
} 
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH   
//+------------------------------------------------------------------+
//|  Global Variable Set                                             |
//+------------------------------------------------------------------+  
datetime GVSet(string name,double value)
{
   return(GlobalVariableSet(prefix+name,value));
}
//+------------------------------------------------------------------+
//|  Global Variable Get                                             |
//+------------------------------------------------------------------+
double GVGet(string name)
{
   return(GlobalVariableGet(prefix+name));
}
//+------------------------------------------------------------------+
//|  Global Variable Delete                                          |
//+------------------------------------------------------------------+
bool GVDel(string pref)
{
   for(int tries=0; tries<10; tries++)
      {
      int obj=GlobalVariablesTotal();
      for(int o=0; o<obj;o++)
         {
          string name=GlobalVariableName(o);
          int index=StringFind(name,pref,0);
          if(index>-1)GlobalVariableDel(name);
         }
      }
   return(false);  
}  
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+------------------------------------------------------------------+
//| get first order ticket                                           |
//+------------------------------------------------------------------+
ulong FIFO(int type) 
{
  ulong Prev=999999999, Curr=0, tick=0;

  for(int i = 0; i < PositionsTotal(); i++)
     {
      if(positionInfo.SelectByIndex(i)) 
        {  
         if(MagicNumber == 0 || positionInfo.Magic() == MagicNumber) 
           {     
            if((positionInfo.PositionType() == POSITION_TYPE_BUY && type == 0) || 
               (positionInfo.PositionType() == POSITION_TYPE_SELL && type == 1) || 
               type == -1)
             { 
              Curr = positionInfo.Ticket();
              if(Curr < Prev){ Prev = Curr; tick = positionInfo.Ticket();}      
             }
           }
        } 
     } 
  return(tick);
} 
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH\\
//                                                                           _________                                                                                    ||
//                                                                          /         \                                                                                   ||
//                                                                         |  THE END  |                                                                                  ||
//                                                                          \_________/                                                                                   ||
//                                                                                                                                                                        ||
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
double margen()
{
   double aa=AccountInfoDouble(ACCOUNT_MARGIN);
   if(aa>DDBuffer1)DDBuffer1=aa;
   return(DDBuffer1); 
   } 
  // hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
  double DrawDown1()
{
   double DD=AccountInfoDouble(ACCOUNT_MARGIN)- margen();
   if(DD>DDBuffer2)DDBuffer2=DD;
   return(DDBuffer2);
}   
    