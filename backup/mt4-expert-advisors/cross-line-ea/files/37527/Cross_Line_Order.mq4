//+------------------------------------------------------------------+
//|                                             Cross_Line_Order.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

extern string Direction="B";
extern double Lots=0.1;
extern int TP=0;
extern int SL=0;
extern int Slippage=5;

bool EnableWork;

int init()
  {
   EnableWork=true;
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   if (!(EnableWork)) return;
   int i;
   int obj_total=ObjectsTotal();
   string ObjName;
   int ObjType;
   double x0, y0, x1, y1;
   double d1, d2, d;
   bool Ray;
   bool Cross=false;
   int res;
   bool Line;
   double TP_Level, SL_Level;
   for (i=0;i<obj_total;i++)
   {
    ObjName=ObjectName(i);
    ObjType=ObjectType(ObjName);
    Line=false;
    if (ObjType==OBJ_VLINE)
    {
     x0=ObjectGet(ObjName, OBJPROP_TIME1);
     x1=x0;
     y0=0;
     y1=1000000;
     Ray=true;
     Line=true;
    }
    if (ObjType==OBJ_HLINE)
    {
     y0=ObjectGet(ObjName, OBJPROP_PRICE1);
     y1=y0;
     x0=0;
     x1=Time[0]+1000;
     Ray=true;
     Line=true;
    }
    if (ObjType==OBJ_TREND || ObjType==OBJ_TRENDBYANGLE)
    {
     x0=ObjectGet(ObjName, OBJPROP_TIME1);
     y0=ObjectGet(ObjName, OBJPROP_PRICE1);
     x1=ObjectGet(ObjName, OBJPROP_TIME2);
     y1=ObjectGet(ObjName, OBJPROP_PRICE2);
     Ray=ObjectGet(ObjName, OBJPROP_RAY);
     Line=true;
    }
    
    d1=(y0-y1)*Time[0]+(x1-x0)*Close[0]+(x0*y1-x1*y0);
    d2=(y0-y1)*Time[1]+(x1-x0)*Close[1]+(x0*y1-x1*y0);
    d=d1*d2;
    if ((d<0 || d1==0) && Line) 
    {
     if (x1>=x0)
     {
      if (Time[0]>=x0 && (Ray || Time[0]<=x1)) Cross=true;
     }
     else
     {
      if (Time[0]<=x0 && (Ray || Time[0]>=x1)) Cross=true;
     } 
    } 
   }
   
   if (Cross)
   {
    if (Direction=="B")
    {
     if (TP==0) TP_Level=0; else TP_Level=NormalizeDouble(Bid+TP*Point, Digits);
     if (SL==0) SL_Level=0; else SL_Level=NormalizeDouble(Bid-SL*Point, Digits);
     res=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,SL_Level,TP_Level,"",0,0,Blue);
    }
    else
    {
     if (TP==0) TP_Level=0; else TP_Level=NormalizeDouble(Ask-TP*Point, Digits);
     if (SL==0) SL_Level=0; else SL_Level=NormalizeDouble(Ask+SL*Point, Digits);
     res=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,SL_Level,TP_Level,"",0,0,Blue);
    }
    if (res!=-1) EnableWork=false;
   }

   return(0);
  }

