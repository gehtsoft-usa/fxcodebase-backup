// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71485

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   |
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Yellow
#property indicator_width1 7
#property indicator_width2 7
//---- input parameters
input int     ChannelType = 99;
input double  Margins     = 0;
input int     Shift       = 0;
input int     Mode        = 0;



//---- buffers
double UpBuffer[];
double DnBuffer[];
double MdBuffer[];
double smin[];
double smax[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(5);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE,2);
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DnBuffer);
   SetIndexBuffer(2,MdBuffer);
   SetIndexBuffer(3,smin);
   SetIndexBuffer(4,smax);
//---- name for DataWindow and indicator subwindow label
   short_name="Fractal Channel("+ChannelType+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Up Channel");
   SetIndexLabel(1,"Down Channel");
   SetIndexLabel(2,"Middle Channel");

   SetIndexShift(0,Shift);
   SetIndexShift(1,Shift);
   SetIndexShift(2,Shift);
//----
   SetIndexDrawBegin(0,2*ChannelType);
   SetIndexDrawBegin(1,2*ChannelType);
   SetIndexDrawBegin(2,2*ChannelType);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| FractalChannel_v3.1                                                |
//+------------------------------------------------------------------+
int start()
{
int  	   shift,k,counted_bars=IndicatorCounted();
double   v1,v2,cond[100];
			
   if ( counted_bars > 0 )  int limit=Bars-counted_bars-1;
   if ( counted_bars < 0 )  return(0);
   if ( counted_bars ==0 )  limit=Bars-2*ChannelType-1; 
     
	for(shift=limit;shift>=0;shift--) 
   {	
	v1 = Fractals(0,ChannelType,shift);
	v2 = Fractals(1,ChannelType,shift);
	
	smax[shift]=smax[shift+1];			
	if ( v1>0 ) smax[shift]=v1; 
	if (Mode == 0)
	if (High[shift]>smax[shift]) smax[shift]=High[shift];
	smin[shift]=smin[shift+1];
	if ( v2>0 ) smin[shift]=v2; 
	if (Mode == 0)
	if (Low[shift]<smin[shift]) smin[shift]=Low[shift];
	
	if (shift==Bars-1-2*ChannelType) {smin[shift]=Low[shift];smax[shift]=High[shift];}
	
	UpBuffer[shift]=smax[shift]-(smax[shift]-smin[shift])*Margins;
	DnBuffer[shift]=smin[shift]+(smax[shift]-smin[shift])*Margins;
	MdBuffer[shift]=(UpBuffer[shift]+DnBuffer[shift])/2;
	}
return(0);
}

double Fractals(int Type, int Size, int i)
{
   int k=1;
	double v1, cond[100];
	
	while (k<=Size) 
	{
      if (Type==0) bool condition = High[i+Size+k]<=High[i+Size] && High[i+Size-k]<High[i+Size];
      else condition = Low[i+Size+k]>=Low[i+Size] && Low[i+Size-k]>Low[i+Size];
      
      if (condition) 
      {
      if (Type==0) cond[k]=High[i+Size]; else cond[k]=Low[i+Size];
	     if(k==1)
	     {v1=cond[k];k++;} 
	     else
	     if(cond[k-1]==cond[k]){v1=cond[k];k++;}else {v1=0; break;}
	     
      }     
      else
      {
      v1=0;
      break;
	   }
	}
return(v1);	
}  
//+------------------------------------------------------------------+