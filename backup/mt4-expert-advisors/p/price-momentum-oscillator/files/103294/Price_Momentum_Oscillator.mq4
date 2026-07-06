//+------------------------------------------------------------------+
//|                             Volume_Price_Momentum_Oscillator.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int one=35;
extern int two=20;
extern int Period=10;


double PMO[];
double Signal[];


double RawOne[];
double CustomSmoothingFunctionOne[];
double RawTwo[];
double CustomSmoothingFunctionTwo[];



double SmoothingMultiplierOne;
double SmoothingMultiplierTwo;
int init()
{
 IndicatorShortName("PMO");
 
 IndicatorBuffers(6);
 
 IndicatorDigits(Digits);
 

 
 SetIndexBuffer(2,RawOne); 
 SetIndexBuffer(3,CustomSmoothingFunctionOne); 
 SetIndexBuffer(4,RawTwo);  
 SetIndexBuffer(5,CustomSmoothingFunctionTwo);
 
   SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PMO);
  SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 
 
 	SmoothingMultiplierOne = (2. / one);
	SmoothingMultiplierTwo = (2. / two);

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
 pos=limit;
 while(pos>=0)
 { 
    if (Close[pos+1]!=0 )
	{
    RawOne[pos] =(( (Close[pos]/Close[pos+1]) * 100. )-100.)  ;
    }
	 pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 { 
 CustomSmoothingFunctionOne[pos] = ( RawOne[pos] - CustomSmoothingFunctionOne[pos+1]) * SmoothingMultiplierOne +  CustomSmoothingFunctionOne[pos+1]; 
 RawTwo[pos]= 10. *CustomSmoothingFunctionOne[pos];
 
   pos--;
 } 
 
 
 
  pos=limit;
 while(pos>=0)
 {     
    CustomSmoothingFunctionTwo[pos] = ( RawTwo[pos] - CustomSmoothingFunctionTwo[pos+1]) * SmoothingMultiplierTwo +  CustomSmoothingFunctionTwo[pos+1]; 
    PMO[pos]=CustomSmoothingFunctionTwo[pos];
   pos--;
 } 
 
 
 
  pos=limit;
 while(pos>=0)
 {
   Signal[pos]= iMAOnArray(PMO,0,Period,0,1,pos);
  pos--;
 } 
   
 return(0);
}

