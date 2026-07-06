//+------------------------------------------------------------------+
//|                                                 Entry_Orders.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#include <Storage.mqh>
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

extern string Name="1";
extern int PriceType=0;  // 0 - Open
                         // 1 - high
                         // 2 - low
                         // 3 - close
                         // 4 - median
                         // 5 - typical
                         // 6 - weighted
                         // 7 - best (low for BUY, high for SELL)
                         // 8 - worst (high for BUY, low for SELL)
extern color BUY = Blue;
extern color SELL = Orange;
extern color END = Red;                         
extern double InitialBalance=10000;
extern double LotSize=1;
                         
double Operations[][3];                        
// [][0] - time
// [][1] - operation
// [][2] - object number
datetime Orders[];
int LineCount;
double TickValue;

double Balance[], Equity[];

int init()
  {
   IndicatorShortName("Entry orders");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Equity);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Balance);
   TickValue=MarketInfo(Symbol(), MODE_TICKVALUE);
   LoadOrders();
   return(0);
  }
  
void SaveOrders()
{
 int i;
 int obj_total=ObjectsTotal();
 string ObjName;
 int Oper;
 datetime T;
 openDB("Entry_Orders "+Name);
 put("ObjTotal",""+obj_total);
 for (i=0;i<obj_total;i++)
 {
  ObjName=ObjectName(i);
  if (ObjectType(ObjName)!=OBJ_ARROW) continue;
  Oper=ObjectGet(ObjName, OBJPROP_ARROWCODE);
  if (Oper!=241 && Oper!=242 && Oper!=251) continue;
  T=ObjectGet(ObjName, OBJPROP_TIME1);
  put("ObjName"+i,ObjName);
  put("ObjOper"+i,""+Oper);
  put("ObjT"+i,""+T);
 }
 closeDB();
 return;
}  

void LoadOrders()
{
 int i;
 int obj_total;
 string ObjName;
 int Oper;
 datetime T;
 openDB("Entry_Orders "+Name);
 obj_total=StrToInteger(get("ObjTotal",0));
 for (i=0;i<obj_total;i++)
 {
  ObjName=get("ObjName"+i,"");
  Oper=StrToInteger(get("ObjOper"+i,"0"));
  T=StrToInteger(get("ObjT"+i,"0"));
  if (ObjName!="" && Oper!=0 && T!=0)
  {
   if (ObjectFind(ObjName)!=-1) ObjectDelete(ObjName);
   ObjectCreate(ObjName, OBJ_ARROW, 0, T, Open[0]);
   ObjectSet(ObjName, OBJPROP_ARROWCODE, Oper);
  } 
 }
}

int deinit()
  {
   ObjectsDeleteAll(0, OBJ_TREND);
   SaveOrders();
   ObjectsDeleteAll(0, OBJ_ARROW);
   return(0);
  }
  
void InitOperations()
{
 ArrayResize(Operations,0);
 return;
}  

void AddOperation(int Oper, datetime T, int Num)
{
 int ArrSize=ArraySize(Operations)/3;
 ArrayResize(Operations, ArrSize+1);
 Operations[ArrSize][1]=Oper;
 Operations[ArrSize][0]=T;
 Operations[ArrSize][2]=Num;
 return;
}

int DecodeOper(int Oper)
{
 if (Oper==241) return (0);
 if (Oper==242) return (1);
 if (Oper==251) return (2);
 return (-1);
}

void Sort()
{
 if (ArraySize(Operations)>0)
 {
  ArraySort(Operations);
 } 
 return;
}

double GetPrice(datetime T, int Oper)
{
 int bar=iBarShift(NULL, 0, T, false);
 if (PriceType==0) return (Open[bar]);
 if (PriceType==1) return (High[bar]);
 if (PriceType==2) return (Low[bar]);
 if (PriceType==3) return (Close[bar]);
 if (PriceType==4) return ((High[bar]+Low[bar])/2);
 if (PriceType==5) return ((High[bar]+Low[bar]+Close[bar])/3);
 if (PriceType==6) return ((High[bar]+Low[bar]+2*Close[bar])/4);
 if (PriceType==7) if (Oper==0) return (Low[bar]); else return (High[bar]);
 if (PriceType==8) if (Oper==0) return (High[bar]); else return (Low[bar]);
}

void DrawLine(datetime T1, datetime T2, int Oper)
{
 LineCount++;
 color OrderColor;
 if (Oper==0) OrderColor=SELL; else OrderColor=BUY;
 double Price1, Price2;
 Price1=GetPrice(T1, 1-Oper);
 Price2=GetPrice(T2, Oper);
 string LineName="Line"+LineCount;
 if (ObjectFind(LineName)!=-1) ObjectDelete(LineName);
 ObjectCreate(LineName, OBJ_TREND, 0, T1, Price1, T2, Price2);
 ObjectSet(LineName, OBJPROP_RAY, false); 
 ObjectSet(LineName, OBJPROP_COLOR, OrderColor); 
 return;
}

void AddOrder(datetime T)
{
 int ArrSize=ArraySize(Orders); 
 ArrayResize(Orders, ArrSize+1);
 Orders[ArrSize]=T;
 return;
}

void RemoveOrder()
{
 int i;
 int ArrSize=ArraySize(Orders);
 for (i=0;i<ArrSize-1;i++)
 {
  Orders[i]=Orders[i+1];
 }
 ArrayResize(Orders, ArrSize-1);
 return;
}

void Draw()
{
 int ArrSize=ArraySize(Operations)/3;
 int i, ii, OrderSize;
 int Status=0;
 int Oper;
 string ObjName;
 double Price;
 color ArrowColor;
 LineCount=0;
 ObjectsDeleteAll(0, OBJ_TREND);
 ArrayResize(Orders,0);
 for (i=0;i<ArrSize;i++) 
 {
  Oper=Operations[i][1];
  if (Oper==0)
  {
   Price=GetPrice(Operations[i][0], Oper);
   ArrowColor=BUY;
   if (Status<0) 
   {
    DrawLine(Orders[0], Operations[i][0], Oper);
    RemoveOrder();
   } 
   else
   {
    AddOrder(Operations[i][0]);
   } 
   Status++;
  }
  else
  {
   if (Oper==1)
   {
    Price=GetPrice(Operations[i][0], Oper);
    ArrowColor=SELL;
    if (Status>0) 
    {
     DrawLine(Orders[0], Operations[i][0], Oper);
     RemoveOrder();
    } 
    else
    {
     AddOrder(Operations[i][0]);
    } 
    Status--;
   }
   else
   {
    ArrowColor=END;
    OrderSize=ArraySize(Orders);
    Price=GetPrice(Operations[i][0], 1);
    if (Status>0) 
    {
     Price=GetPrice(Operations[i][0], 1); 
     for (ii=0;ii<OrderSize;ii++)
     {
      DrawLine(Orders[ii], Operations[i][0], 1);
     }
     ArrayResize(Orders,0);
    }
    else
    {
     if (Status<0)
     {
      Price=GetPrice(Operations[i][0], 0);
      for (ii=0;ii<OrderSize;ii++)
      {
       DrawLine(Orders[ii], Operations[i][0], 0);
      }
      ArrayResize(Orders,0);
     } 
    } 
    Status=0;
   }
  }
  if (Price!=0)
  {
   ObjName=ObjectName(Operations[i][2]);
   ObjectSet(ObjName, OBJPROP_PRICE1, Price);
   ObjectSet(ObjName, OBJPROP_COLOR, ArrowColor);
  } 
 }
 return;
}

void CalculateBE()
{
 int limit=Bars-1;
 int pos=limit-1;
 int i, ii;
 double dE, dB;
 double Status=0;
 double ObjPrice;
 string ObjName;
 double OrdersPrices[];
 int Oper;
 int ArrSize=ArraySize(Operations)/3;
 int OP_Size;
 Balance[limit]=InitialBalance;
 Equity[limit]=InitialBalance;
 ArrayResize(OrdersPrices,0);
 while (pos>=0)
 {
  dB=0;
  dE=(Close[pos]-Close[pos+1])*Status*TickValue/Point;
  for (i=0;i<ArrSize;i++)
  {
   if (Time[pos+1]<Operations[i][0] && Time[pos]>=Operations[i][0])
   {
    ObjName=ObjectName(Operations[i][2]);
    ObjPrice=ObjectGet(ObjName, OBJPROP_PRICE1);
    Oper=Operations[i][1];
    if (Oper==0)
    {
     if (Status>=0)
     {
      OP_Size=ArraySize(OrdersPrices);
      ArrayResize(OrdersPrices,OP_Size+1);
      OrdersPrices[OP_Size]=ObjPrice;
     }
     else
     {
      dB=dB+(OrdersPrices[0]-ObjPrice)*LotSize*TickValue/Point;
      OP_Size=ArraySize(OrdersPrices);
      for (ii=0;ii<OP_Size-1;ii++)
      {
       OrdersPrices[ii]=OrdersPrices[ii+1];
      }
      ArrayResize(OrdersPrices, OP_Size-1);
     }
     Status=Status+LotSize;
     dE=dE+(Close[pos]-ObjPrice)*LotSize*TickValue/Point;
    }
    if (Oper==1)
    {
     if (Status<=0)
     {
      OP_Size=ArraySize(OrdersPrices);
      ArrayResize(OrdersPrices,OP_Size+1);
      OrdersPrices[OP_Size]=ObjPrice;
     }
     else
     {
      dB=dB+(ObjPrice-OrdersPrices[0])*LotSize*TickValue/Point;
      OP_Size=ArraySize(OrdersPrices);
      for (ii=0;ii<OP_Size-1;ii++)
      {
       OrdersPrices[ii]=OrdersPrices[ii+1];
      }
      ArrayResize(OrdersPrices, OP_Size-1);
     }
     Status=Status-LotSize;
     dE=dE+(ObjPrice-Close[pos])*LotSize*TickValue/Point;
    }
    if (Oper==2)
    {
     dE=dE+(ObjPrice-Close[pos])*Status*TickValue/Point;
     if (Status!=0)
     {
      OP_Size=ArraySize(OrdersPrices);
      for (ii=0;ii<OP_Size;ii++)
      {
       if (Status>0)
       {
        dB=dB+(ObjPrice-OrdersPrices[ii])*LotSize*TickValue/Point;
       }
       else
       {
        dB=dB+(OrdersPrices[ii]-ObjPrice)*LotSize*TickValue/Point;
       }
      }
     }
     Status=0;
     ArrayResize(OrdersPrices,0);
    }
   }
   Equity[pos]=Equity[pos+1]+dE;
   Balance[pos]=Balance[pos+1]+dB;
  }
  pos--;
 } 
 
}

int start()
  {
   int i;
   int obj_total=ObjectsTotal();
   string ObjName;
   int Oper;
   datetime T;
   InitOperations();
   for (i=0;i<obj_total;i++)
   {
    ObjName=ObjectName(i);
    if (ObjectType(ObjName)!=OBJ_ARROW) continue;
    Oper=ObjectGet(ObjName, OBJPROP_ARROWCODE);
    Oper=DecodeOper(Oper);
    if (Oper!=-1)
    {
     T=ObjectGet(ObjName, OBJPROP_TIME1);
     AddOperation(Oper, T, i);
    } 
   }
   Sort();
   Draw();
   CalculateBE();
   
   return(0);
  }

