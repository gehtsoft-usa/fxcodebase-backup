// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=65084

//+------------------------------------------------------------------+
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Gray

enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };

 



extern bool Use_1=true;
extern int Length_1=36; 


extern bool Use_2=true;
extern int Length_2=68; 


extern bool Use_3=true;
extern int Length_3=102; 


extern bool Use_4=true;
extern int Length_4=136; 


extern bool Use_5=true;
extern int Length_5=200; 


extern e_method MA_Method  = SMA;

double UP[], DN[],NE[];
int Num=0;
int MA_Period[5];

double Raw[];

int init()
{
 IndicatorShortName("3 MA Bar histogram");
 IndicatorDigits(Digits);
 
 IndicatorBuffers(4);
	
 
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,DN);
  SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,NE);
 
SetIndexStyle(3,DRAW_NONE);
SetIndexBuffer(3,Raw);
 
 Num=-1;
 
if (Use_1) 
{
Num=Num+1;
MA_Period[Num]= Length_1;
}
if (Use_2)
{ 
Num=Num+1;
MA_Period[Num]= Length_2;
}
if (Use_3)
{
Num=Num+1;
MA_Period[Num]= Length_3;
}

if (Use_4)
{
Num=Num+1;
MA_Period[Num]= Length_4;
}
if (Use_5)
{
Num=Num+1;
MA_Period[Num]= Length_5;
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
 
	if (limit<Length_5) return (0);
	if (limit<Length_4) return (0);
	if (limit<Length_3) return (0);
	if (limit<Length_2) return (0);
	if (limit<Length_1) return (0);
	
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 
   int i;
   double P;
   double C;
   

   
 while(pos>=0)
 {
   
   Raw[pos]=0; 
   
   for(i=1;i<=Num-1; i++)
   {
   
         P= iMA(NULL,0,MA_Period[i-1],0,MA_Method,PRICE_CLOSE,pos);
         C= iMA(NULL,0,MA_Period[i]  ,0,MA_Method,PRICE_CLOSE,pos);		 
                 
         if (P > C) 
		 {
		 Raw[pos]=Raw[pos]+1;
		 }
		 
         if (P < C) 
		 {
		 Raw[pos]=Raw[pos]-1;
		 }
         
	
   }
 
  
  pos--;
 } 
 
 
 
  pos=limit;
 while(pos>=0)
 {
   
  
   
  NE[pos]=1.;
 
    if (Raw[pos]== (Num-1)  )
    {
    UP[pos]=1.;
 	DN[pos]=0.;
 	NE[pos]=0.;
    }
  if ((MathAbs(Raw[pos])==  (Num-1)) && Raw[pos] < 0 )
  
    {
    DN[pos]=1.;
 	UP[pos]=0.;
 	NE[pos]=0.;
   }

  pos--;
 
 
 }
 return(0);
}

