// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73751

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Aqua
#property indicator_color2 Blue
#property indicator_color3 Red

//---- input parameters
extern int     Length      = 10;      // Volty Length
extern double  Kv          = 1.0;     // Sensivity Factor
extern int     StepSize    = 0;       // Constant Step Size (if need)
extern int     MA_Mode     = 0;       // Volty MA Mode : 0-SMA, 1-LWMA 
extern int     Advance     = 0;       // Offset
extern double  Percentage  = 0;       // Percentage of Up/Down Moving   
extern bool    HighLow     = false;   // High/Low Mode Switch (more sensitive)
extern int     ColorMode   = 0;       // Color Mode Switch
extern int     BarsNumber  = 0;       

//---- indicator buffers
double LineBuffer[];
double UpBuffer[];
double DnBuffer[];
double smin[];
double smax[];
double trend[];

double StepMA=0, ATR0=0,ATRmax=-100000,ATRmin=1000000;
int limit;

//---- StepSize Calculation

   double StepSizeCalc ( int Len, double Km, int Size, int k)
   {

   double result;
   if( Size==0 ) 
   {
        double AvgRange=0;
	     double Weight = 0;
	     for (int i=Len-1;i>=0;i--)
	     { 
            if(MA_Mode==0) double alfa= 1.0; else alfa= 1.0*(Len-i)/Len; 
            AvgRange+= alfa*(High[k+i]-Low[k+i]);
            Weight += alfa;
        }
	     ATR0 = AvgRange/Weight;
	
	if (ATR0>ATRmax) ATRmax=ATR0;
	if (ATR0<ATRmin) ATRmin=ATR0;
	
	result=MathRound(0.5*Km*(ATRmax+ATRmin)/Point); 
	}
	else
	result=Km*StepSize;
   
   return(result);
   }

//---- StepMA Calculation   
   
   double StepMACalc (bool HL, double Size, int k)
   {
   int counted_bars=IndicatorCounted();
   double result;
   
   if (HL)
	  {
	  smax[k]=Low[k]+2.0*Size*Point;
	  smin[k]=High[k]-2.0*Size*Point;
     } 	
	else  	 
	  {
	  smax[k]=Close[k]+2.0*Size*Point;
	  smin[k]=Close[k]-2.0*Size*Point;
	  }
	  if (counted_bars==0){smax[limit+1]=smax[limit];smin[limit+1]=smin[limit];trend[limit+1]=0;}
	  
	  trend[k]=trend[k+1];   
	  
	  if (Close[k]>smax[k+1]) trend[k]=1;   
	 
	  if (Close[k]<smin[k+1]) trend[k]=-1;  
	 
	  if(trend[k]>0)
	  {
	  if(smin[k]<smin[k+1]) smin[k]=smin[k+1];
	  result=smin[k]+Size*Point;
	  } 
	  else
	  {
	  if(smax[k]>smax[k+1]) smax[k]=smax[k+1];
	  result=smax[k]-Size*Point;
	  }
     //Print (" k=",k," trend=",trend[k], " res=",result," Smax=", smax[k], " Smin=", smin[k]);
	  
     
     return(result); 
     } 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(6);
   
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   
   SetIndexArrow(1,159);
   SetIndexArrow(2,159);
   
   SetIndexBuffer(0,LineBuffer);
   SetIndexBuffer(1,UpBuffer);
   SetIndexBuffer(2,DnBuffer);
   
   SetIndexShift(0,Advance);
   SetIndexShift(1,Advance);
   SetIndexShift(2,Advance);
   
   SetIndexBuffer(3,smin);
   SetIndexBuffer(4,smax);
   SetIndexBuffer(5,trend);
   
//---- name for DataWindow and indicator subwindow label
   short_name="StepMA("+Length+","+Kv+","+StepSize+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"UpTrend");
   SetIndexLabel(2,"DownTrend"); 
//----
   SetIndexDrawBegin(0,Length);
   SetIndexDrawBegin(1,Length);
   SetIndexDrawBegin(2,Length);
//----
   return(0);
   }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }     
//+------------------------------------------------------------------+
//| StepMA_v7.1                                                        |
//+------------------------------------------------------------------+
int start()
  {
   int shift, counted_bars=IndicatorCounted();
     
   if ( BarsNumber > 0 ) int Nbars=BarsNumber; else Nbars=Bars;
   if ( counted_bars > 0 )  limit=Bars-counted_bars;
   if ( counted_bars < 0 )  return(0);
   if ( counted_bars ==0 )  limit=Nbars-Length-1; 
     
	for(shift=limit;shift>=0;shift--) 
   {	
     
	int Step = StepSizeCalc( Length, Kv, StepSize, shift);
				
	Comment (" StepSize= ", Step);
	
	StepMA = StepMACalc ( HighLow, Step, shift)+Percentage/100.0*Step*Point;
	
	if ( ColorMode == 0) LineBuffer[shift]=StepMA;
	
	if ( ColorMode == 1)
	{
	if ( trend[shift]>0 ) {UpBuffer[shift]=StepMA-Step*Point;DnBuffer[shift]=EMPTY_VALUE;}
	else
	if ( trend[shift]<0 ) {DnBuffer[shift]=StepMA+Step*Point;UpBuffer[shift]=EMPTY_VALUE;}
	}
	else
	if ( ColorMode == 2)
	{
	if (trend[shift]>0) 
	  {
	  UpBuffer[shift]=StepMA;
	  if ( trend[shift+1] < 0 ) UpBuffer[shift+1] = DnBuffer[shift+1];
	  DnBuffer[shift]=EMPTY_VALUE;
	  }
	  if (trend[shift]<0) 
	  {
	  DnBuffer[shift]=StepMA;
	  if ( trend[shift+1] > 0 ) DnBuffer[shift+1] = UpBuffer[shift+1];
	  UpBuffer[shift]=EMPTY_VALUE;
	  }
	}
	else
	{	
	UpBuffer[shift]=EMPTY_VALUE; DnBuffer[shift]=EMPTY_VALUE;
	}
	
	}
	return(0);	
 }

// ------------------------------------------------------------------

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+