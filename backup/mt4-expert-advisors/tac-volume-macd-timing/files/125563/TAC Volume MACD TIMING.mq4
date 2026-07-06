// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68298


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

#property indicator_separate_window
#property indicator_buffers 9

extern int Period0       = 60;
extern int Shift = 5;
extern int Period1       = 12;
extern int Period2       = 26;
extern int Period3       = 9;

  
 
#property indicator_color1 clrLavender;

#property indicator_color2 clrDarkGreen;
#property indicator_color3 clrSeaGreen;
#property indicator_color4 clrGreen;
#property indicator_color5 clrSpringGreen;

#property indicator_color6 clrMaroon;
#property indicator_color7 clrFireBrick;
#property indicator_color8 clrRed;
#property indicator_color9 clrOrangeRed;

double Up1[], Up2[], Up3[], Up4[];
double Dn1[], Dn2[], Dn3[], Dn4[];
double Ne[];
double Wave[];
 
int init()
{
   IndicatorShortName("TAC Volume MACD TIMING");
   IndicatorDigits(Digits);
   
   
   IndicatorBuffers(10);
	
   
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Ne);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,Up1);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,Up2);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(3,Up3);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexBuffer(4,Up4);
   
   SetIndexStyle(5,DRAW_HISTOGRAM);
   SetIndexBuffer(5,Dn1);
   SetIndexStyle(6,DRAW_HISTOGRAM);
   SetIndexBuffer(6,Dn2);
   SetIndexStyle(7,DRAW_HISTOGRAM);
   SetIndexBuffer(7,Dn3);
   SetIndexStyle(8,DRAW_HISTOGRAM);
   SetIndexBuffer(8,Dn4);
   
   SetIndexStyle(9,DRAW_NONE);
   SetIndexBuffer(9,Wave);
    

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
   
   double Sum1;
   double Sum2;
   
   while(pos>=0)
   {
     
      
      
      Sum1=0;
	  Sum2=0; 
	  
	  for(int i = 0; i <= Period0; i++)
      {
        Sum1 = Sum1 + Close[pos+i]*Volume[pos+i];
		Sum2 = Sum2 + Volume[pos+i];
      }
	  
	  
	  if (Sum2!=0)
	  {
	  Wave[pos]=Sum1/Sum2;
	  }
	  
	  

      pos--;
   } 
   
   
   pos=limit;
   double HH,HH1;
   int Value;
    while(pos>=0)
   {
   
   
      Ne[pos]=0.;
      Up1[pos]=0.;
	  Up2[pos]=0.;
	  Up3[pos]=0.;
	  Up4[pos]=0.;
      Dn1[pos]=0.;
	  Dn2[pos]=0.;
	  Dn3[pos]=0.;
	  Dn4[pos]=0.;
     
	 
   HH=iMACD(NULL,0,Period1,Period2,Period3,PRICE_CLOSE,MODE_MAIN,pos);
   HH1=iMACD(NULL,0,Period1,Period2,Period3,PRICE_CLOSE,MODE_SIGNAL,pos);
   
   
		//POSITIVO 
		if (HH>=0  && HH>HH1  && Wave[pos]>Wave[pos+Shift]){
		 Value=1;
		 Up1[pos]=1; 
		}
		 
		if (HH>=0  && HH<HH1  && Wave[pos]>Wave[pos+Shift]){
		 Value=2;
		 Up2[pos]=2; 
		}
		 
		if (HH<=0  && HH<HH1  && Wave[pos]>Wave[pos+Shift]){
		 Value=3;
		 Up3[pos]=3; 
		}
		 
		if (HH<=0  && HH>HH1  && Wave[pos]>Wave[pos+Shift]){
		 Value=4;
		 Up4[pos]=4; 
		}
		 
		//NEGATIVO
		if (HH<=0  && Wave[pos]<Wave[pos+Shift]) {
		 Value=-1;
		 Dn1[pos]=-1; 
		}
		 
		if (HH<=0  && HH>HH1  && Wave[pos]<Wave[pos+Shift]){
		 Value=-2;
		 Dn2[pos]=-2; 
		}
		 
		if (HH>=0  && HH>HH1  && Wave[pos]<Wave[pos+Shift]){
		 Value=-3;
		 Dn3[pos]=-3; 
		}
		 
		if (HH>=0  && HH<HH1  && Wave[pos]<Wave[pos+Shift]){
		 Value=-4;
		 Dn4[pos]=-4; 
		}

        Ne[pos]=Value;
		
      pos--;
   } 
   
   return(0);
}

