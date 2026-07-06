// Id: 10098
//+------------------------------------------------------------------+
//|                                             Averaged_Rainbow.mq4 |
//|                               Copyright � 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Yellow

extern int Number=10;
extern int Length=5;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double AR[];
double MA8[], MA9[], MA10[], MA11[], MA12[], MA13[], MA14[];

int init()
{
     double temp = iCustom(NULL, 0, "MA_Rainbow", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'MA_Rainbow' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("Averaged Rainbow");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,AR);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,MA8);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,MA9);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,MA10);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,MA11);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,MA12);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,MA13);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,MA14);
 
 if (Number>15)
 {
  Print("Number can not be greater than 15!");
  Number=15;
 }

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 
 if (Number>8)
 {
  pos=limit;
  while(pos>=0)
  {
   MA8[pos]=iCustom(NULL, 0, "MA_Rainbow", Length, Price, Method, 7, pos);
   pos--;
  } 

  pos=limit;
  while(pos>=0)
  {
   MA9[pos]=iMAOnArray(MA8, 0, Length, 0, Method, pos);
   pos--;
  } 
  
  if (Number>9)
  {
   pos=limit;
   while(pos>=0)
   {
    MA10[pos]=iMAOnArray(MA9, 0, Length, 0, Method, pos);
    pos--;
   } 

   if (Number>10)
   {
    pos=limit;
    while(pos>=0)
    {
     MA11[pos]=iMAOnArray(MA10, 0, Length, 0, Method, pos);
     pos--;
    } 
    
    if (Number>11)
    {
     pos=limit;
     while(pos>=0)
     {
      MA12[pos]=iMAOnArray(MA11, 0, Length, 0, Method, pos);
      pos--;
     } 
    
     if (Number>12)
     {
      pos=limit;
      while(pos>=0)
      {
       MA13[pos]=iMAOnArray(MA12, 0, Length, 0, Method, pos);
       pos--;
      } 

      if (Number>13)
      {
       pos=limit;
       while(pos>=0)
       {
        MA14[pos]=iMAOnArray(MA13, 0, Length, 0, Method, pos);
        pos--;
       } 
      }
     }
    }   
   } 
  }
 } 
 
 double MAs[16];
 int i;
 double sum;

 pos=limit;
 while(pos>=0)
 {
  MAs[1]=iCustom(NULL, 0, "MA_Rainbow", Length, Price, Method, 0, pos);
  MAs[2]=iCustom(NULL, 0, "MA_Rainbow", Length, Price, Method, 1, pos);
  MAs[3]=iCustom(NULL, 0, "MA_Rainbow", Length, Price, Method, 2, pos);
  MAs[4]=iCustom(NULL, 0, "MA_Rainbow", Length, Price, Method, 3, pos);
  MAs[5]=iCustom(NULL, 0, "MA_Rainbow", Length, Price, Method, 4, pos);
  MAs[6]=iCustom(NULL, 0, "MA_Rainbow", Length, Price, Method, 5, pos);
  MAs[7]=iCustom(NULL, 0, "MA_Rainbow", Length, Price, Method, 6, pos);
  MAs[8]=MA8[pos];
  MAs[9]=MA9[pos];
  MAs[10]=MA10[pos];
  MAs[11]=MA11[pos];
  MAs[12]=MA12[pos];
  MAs[13]=MA13[pos];
  MAs[14]=MA14[pos];
  MAs[15]=iMAOnArray(MA14, 0, Length, 0, Method, pos);
  
  sum=0;
  for (i=1;i<=Number;i++)
  {
   sum+=MAs[i];
  }
  AR[pos]=sum/Number;
  
  pos--;
 } 
 
 return(0);
}

