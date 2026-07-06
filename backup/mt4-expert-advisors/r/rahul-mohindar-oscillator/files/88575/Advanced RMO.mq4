// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=59124


//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Length1=30;
extern int Length2=30;
extern int Base_Period=2;
extern int Steps=10;

double RMO[], FirstSignal[], SecondSignal[];

 
double Data1[];
double Data2[];
double Data3[];
double Data4[];
double Data5[];
double Data6[];
double Data7[];
double Data8[];
double Data9[];
double Data10[];

double Data11[];
double Data12[];
double Data13[];
double Data14[];
double Data15[];
double Data16[];
double Data17[];
double Data18[];
double Data19[];
double Data20[];


double Sum[];
int MaxLength;


int init()
{
 IndicatorShortName("Advanced Rahul Mohindar Oscillator");
 
 IndicatorBuffers(4+Steps);
 
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,RMO);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,FirstSignal);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,SecondSignal);
 
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Data1);
 
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Data2);
 
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,Data3);
 
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,Data4);
 
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,Data5);
 
 
 SetIndexStyle(8,DRAW_NONE);
 SetIndexBuffer(8,Data6);
 
 
 SetIndexStyle(9,DRAW_NONE);
 SetIndexBuffer(9,Data7);
 
 
 SetIndexStyle(10,DRAW_NONE);
 SetIndexBuffer(10,Data8);
 
 SetIndexStyle(11,DRAW_NONE);
 SetIndexBuffer(11,Data9);
 
 SetIndexStyle(12,DRAW_NONE);
 SetIndexBuffer(12,Data10);
 
 
 SetIndexStyle(13,DRAW_NONE);
 SetIndexBuffer(13,Data11);
 
 SetIndexStyle(14,DRAW_NONE);
 SetIndexBuffer(14,Data12);
 
 SetIndexStyle(15,DRAW_NONE);
 SetIndexBuffer(15,Data13);
 
 SetIndexStyle(16,DRAW_NONE);
 SetIndexBuffer(16,Data14);
 
 SetIndexStyle(17,DRAW_NONE);
 SetIndexBuffer(17,Data15);
 
 
 SetIndexStyle(18,DRAW_NONE);
 SetIndexBuffer(18,Data16);
 
 
 SetIndexStyle(19,DRAW_NONE);
 SetIndexBuffer(19,Data17);
 
 
 SetIndexStyle(20,DRAW_NONE);
 SetIndexBuffer(20,Data18);
 
 SetIndexStyle(21,DRAW_NONE);
 SetIndexBuffer(21,Data19);
 
 SetIndexStyle(22,DRAW_NONE);
 SetIndexBuffer(22,Data20);
 
 
 SetIndexStyle(23,DRAW_NONE);
 SetIndexBuffer(23,Sum);
 
 
  if(! (Steps >= 1 && Steps <= 20  )  ) 
   {
   Alert("Permitted MA_Modes are between 1 and 20");

   return(-1);
   }

 
 MaxLength=MathMax(10, MathMax(Length1, Length2));
 
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=MaxLength) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double X;
 pos=limit;
 int i;
 
 while(pos>=0)
 {
 
 Sum[pos]=0;
 
     for(i=1;i!=Steps ; i++)
	  {
		  if(i==1)
		  {
		  Data1[pos]=iMA(NULL, 0, Base_Period, 0, MODE_SMA, PRICE_CLOSE, pos);
		  Sum[pos]=Sum[pos]+Data1[pos];
		  }
		  
		
		  
		   if(i==2) 
		  {
		  Data2[pos]=iMAOnArray(Data1,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data2[pos];
		  }
		  
		  
		   if(i==3) 
		  {
		  Data3[pos]=iMAOnArray(Data2,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data3[pos];
		  }
		  
		  
		   if(i==4) 
		  {
		  Data4[pos]=iMAOnArray(Data3,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data4[pos];
		  }
		  
		   if(i==5) 
		  {
		  Data5[pos]=iMAOnArray(Data4,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data5[pos];
		  }
		  
		  
		   if(i==6) 
		  {
		  Data6[pos]=iMAOnArray(Data5,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data6[pos];
		  }
		  
		  
		   if(i==7) 
		  {
		  Data7[pos]=iMAOnArray(Data6,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data7[pos];
		  }
		  
		   if(i==8) 
		  {
		  Data8[pos]=iMAOnArray(Data7,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data8[pos];
		  }
		  
		   if(i==9) 
		  {
		  Data9[pos]=iMAOnArray(Data8,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data9[pos];
		  }
		  
		   if(i==10) 
		  {
		  Data10[pos]=iMAOnArray(Data9,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data10[pos];
		  }
		  
		  if(i==11)
		  {
		  Data11[pos]=iMAOnArray(Data10,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data1[pos];
		  }
		  
		
		  
		   if(i==12) 
		  {
		  Data12[pos]=iMAOnArray(Data11,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data2[pos];
		  }
		  
		  
		   if(i==13) 
		  {
		  Data13[pos]=iMAOnArray(Data12,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data3[pos];
		  }
		  
		  
		   if(i==14) 
		  {
		  Data14[pos]=iMAOnArray(Data13,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data4[pos];
		  }
		  
		   if(i==15) 
		  {
		  Data15[pos]=iMAOnArray(Data14,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data5[pos];
		  }
		  
		  
		   if(i==16) 
		  {
		  Data16[pos]=iMAOnArray(Data15,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data6[pos];
		  }
		  
		  
		   if(i==17) 
		  {
		  Data17[pos]=iMAOnArray(Data16,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data7[pos];
		  }
		  
		   if(i==18) 
		  {
		  Data18[pos]=iMAOnArray(Data17,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data8[pos];
		  }
		  
		   if(i==19) 
		  {
		  Data19[pos]=iMAOnArray(Data18,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data9[pos];
		  }
		  
		   if(i==20) 
		  {
		  Data20[pos]=iMAOnArray(Data19,0,Base_Period,0,MODE_SMA,pos);
		  Sum[pos]=Sum[pos]+Data10[pos];
		  }
	  }
 
 
 
  pos--;
 } 
 
 double Min, Max;

 
 pos=limit;
 while(pos>=0)
 {
  Min=Low[iLowest(NULL, 0, MODE_LOW, Steps, pos)];
  Max=High[iHighest(NULL, 0, MODE_HIGH, Steps, pos)];
  if (Min!=Max)
  {
  
   X= Close[pos] - Sum[pos]/Steps ;
   RMO[pos]=100*X/(Max-Min);
  }
  else
  { 
   RMO[pos]=0;
  } 
  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  FirstSignal[pos]=iMAOnArray(RMO, 0, Length1, 0, MODE_EMA, pos);
  pos--;
 }  

 pos=limit;
 while(pos>=0)
 {
  SecondSignal[pos]=iMAOnArray(FirstSignal, 0, Length2, 0, MODE_EMA, pos);
  pos--;
 }  
 return(0);
}

