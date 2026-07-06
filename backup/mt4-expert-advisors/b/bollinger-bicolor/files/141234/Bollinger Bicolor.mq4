// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=71017


//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC | 
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
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//+------------------------------------------------------------------+




#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window 
#property indicator_buffers 5 
#property indicator_color1 Red  
#property indicator_color2 Green 
#property indicator_color3 LightSeaGreen  
#property indicator_color4 Red  
#property indicator_color5 Green  


//---- indicator parameters 
extern int Periode = 20; 
extern int Decal_Band = 0; 
extern double EType_Band = 2.0; 

//---- buffers 
double MovingBuffer[]; 
double UpperBuffer[];  
double LowerBuffer[];  

// puis on fera une sélection selon 

double UpperBGreen[] ;  
double UpperBRed[] ; 
double LowerBGreen[] ;  
double LowerBRed[] ;  

double EType[] ;  

//+------------------------------------------------------------------+ 
//| initialisation | 
//+------------------------------------------------------------------+ 
int init() 
{ 
//---- indicators 
IndicatorBuffers(8); 

SetIndexStyle(0,DRAW_LINE,0,2); 
SetIndexBuffer(0,UpperBRed);  
SetIndexStyle(1,DRAW_LINE,0,2); 
SetIndexBuffer(1,UpperBGreen);  

SetIndexStyle(2,DRAW_LINE,0,1); 
SetIndexBuffer(2,MovingBuffer);  

SetIndexStyle(3,DRAW_LINE,0,2); 
SetIndexBuffer(3,LowerBRed);  
SetIndexStyle(4,DRAW_LINE,0,2); 
SetIndexBuffer(4,LowerBGreen); 

SetIndexStyle(5,DRAW_NONE); 
SetIndexBuffer(5,UpperBuffer); 

SetIndexStyle(6,DRAW_NONE); 
SetIndexBuffer(6,LowerBuffer); 

SetIndexStyle(7,DRAW_NONE); 
SetIndexBuffer(7,EType); 


//---- 
return(0); 
} 
//+------------------------------------------------------------------+ 
//| Bollinger Bands | 
//+------------------------------------------------------------------+ 
int start() 
{ 
int index ; 

int limit=Bars-Periode; 

for(index=limit-2 ; index>=0 ; index--) 
{ 
MovingBuffer[index]=iMA(NULL,0,Periode,Decal_Band,MODE_SMA,PRICE_CLOSE,index); 
EType[index] = iStdDev(NULL,0,Periode,Decal_Band,MODE_SMA,PRICE_CLOSE,index); 

UpperBuffer[index] = MovingBuffer[index] + EType[index] * EType_Band ;  

LowerBuffer[index] = MovingBuffer[index] - EType[index] * EType_Band ;  

UpperBGreen[index] = UpperBuffer[index] ;  
UpperBRed[index] = UpperBuffer[index] ; 

LowerBGreen[index] = LowerBuffer[index] ; 
LowerBRed[index] = LowerBuffer[index] ;  

if ((UpperBuffer[index] > UpperBuffer[index+1])&&(UpperBuffer[index+1] > UpperBuffer[index+2])) UpperBRed[index+1] = EMPTY_VALUE ;   
else if((UpperBuffer[index] < UpperBuffer[index+1])&&(UpperBuffer[index+1] < UpperBuffer[index+2])) UpperBGreen[index+1] = EMPTY_VALUE ;  

if ((LowerBuffer[index] > LowerBuffer[index+1])&&(LowerBuffer[index+1] > LowerBuffer[index+2])) LowerBRed[index+1] = EMPTY_VALUE ;  
else if ((LowerBuffer[index] < LowerBuffer[index+1])&&(LowerBuffer[index+1] < LowerBuffer[index+2]))LowerBGreen[index+1] = EMPTY_VALUE ; 

} 

//---- 
return(0); 
} 
//+------------------------------------------------------------------+