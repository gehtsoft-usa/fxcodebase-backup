//+------------------------------------------------------------------+
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  https://goo.gl/9Rj74e | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property indicator_buffers 3
#property indicator_chart_window
#property indicator_color1 clrGreen
#property indicator_color2 clrRed
#property indicator_color3 clrBlue

enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };

extern int   Period = 14;
extern e_method MA_Method        = SMA;
extern int   NormalizationPeriod = 50; 

double Up[];
double Down[];
double Difference[];

double Up_Raw[];
double Down_Raw[];
double Difference_Raw[];
 
double u[];
double d[];

double Array[8];
   
int init(){
   
   IndicatorShortName("TIA_with_Normalization");
   IndicatorBuffers(8);
   
 
   SetIndexBuffer(0,Up);
   SetIndexLabel(0,"Up");
   
   SetIndexBuffer(1,Down);
   SetIndexLabel(1,"Down");
   
   SetIndexBuffer(2,Difference);
   SetIndexLabel(2,"Difference");
      
   SetIndexBuffer(3,u);
   SetIndexBuffer(4,d); 
   
   SetIndexBuffer(5,Up_Raw);
   SetIndexBuffer(6,Down_Raw); 
   SetIndexBuffer(7,Difference_Raw); 
   
   /* if(! ( Method >= 0 &&  Method <= 3  )  ) 
   {
   Alert("Permitted  MA Method are between 0 and 3");

   return(-1);
   }*/
  
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
 
 
 
      
   for(i=limit; i>=0; i--){
   
   
            u[i]=0;
			d[i]=0;
      
			if (Close[i]> Close[i+1])
			{
			u[i]=u[i+1]+1;
			d[i]=0;
			}
			
			if (Close[i]< Close[i+1])
			{
			d[i]=d[i+1]+1;
			u[i]=0;
			}
			
      
   }
   
   for(i=limit-Period-1; i>=0; i--){
      
      Up_Raw[i]= iMAOnArray(u,0,Period,0,ENUM_MA_METHOD(MA_Method),i);
      Down_Raw[i]= iMAOnArray(d,0,Period,0,ENUM_MA_METHOD(MA_Method),i);
	  Difference_Raw[i] = Up[i]-Down[i] ;
   }
   

   double Div1;
   double Div2;
   double Div3;
 
   int min1=0;
   int max1=1 ;
   int min2=2;
   int max2=3;
   int min3=4;
   int max3=5;
   int min4=6;
   int max4=7;
   
   int Start = (limit-Period-NormalizationPeriod-1);
   
        for(i=Start; i>=0; i--){
		 
		           MinMax( i);
		
			 
					Div1= (Array[max2]-Array[min2])*(Array[max1]-Array[min1]);
					Div2= (Array[max3]-Array[min3])*(Array[max1]-Array[min1]);
					Div3= (Array[max4]-Array[min4])*(Array[max1]-Array[min1]);
					
						if (Div1!=0)
						{
						Up[i] =  ((Up_Raw[i] - Array[min2])/ ((Array[max2]-Array[min2]))*(Array[max1]-Array[min1])) +Array[min1]  ;
						}
						if (Div2!=0)
						{
						Down[i]=  ((Down_Raw[i] - Array[min3])/ ((Array[max3]-Array[min3]))*(Array[max1]-Array[min1])) +Array[min1] ;
						}
						
						if (Div3!=0)
						{
						Difference[i]=  ((Difference_Raw[i] - Array[min4])/ ((Array[max4]-Array[min4]))*(Array[max1]-Array[min1])) +Array[min1] ;
						}
			}
   
//----
   return(0);
}

void MinMax(int i)
{
int counted_bars=IndicatorCounted();
int limit = Bars-counted_bars-1;
int Stop;
int XX= (i+NormalizationPeriod);
int YY= (limit-NormalizationPeriod-1);
Stop= MathMin(XX, YY);     
 
   int min1=0;
   int max1=1 ;
   int min2=2;
   int max2=3;
   int min3=4;
   int max3=5;
   int min4=6;
   int max4=7;
   int j;
   
 for(j=Stop;j>=i; j--)
		   {
		     if (j==Stop)
			 {
			 Array[max1]=Close[j];
			 Array[min1]=Close[j];
			 Array[max2]=Up_Raw[j];
			 Array[min2]=Up_Raw[j];
			 Array[max3]=Down_Raw[j];
			 Array[min3]=Down_Raw[j];
			 Array[max4]=Difference_Raw[j];
			 Array[min4]=Difference_Raw[j];
			 
			 }
			 
			 if ( Array[max1]<Close[j])
			 {
			  Array[max1]=Close[j];
			 }			 
			 
			 if ( Array[min1]>Close[j])
			 {
			  Array[min1]=Close[j];
			 }
			 
			 
			  if ( Array[max2]<Up_Raw[j])
			 {
			  Array[max2]=Up_Raw[j];
			 }			 
			 
			 if ( Array[min2]>Up_Raw[j])
			 {
			  Array[min2]=Up_Raw[j];
			 }
			 
			 
			 	 if ( Array[max3]<Down_Raw[j])
			 {
			  Array[max3]=Down_Raw[j];
			 }			 
			 
			 if ( Array[min3]>Down_Raw[j])
			 {
			  Array[min3]=Down_Raw[j];
			 }
			 
			 
			 if ( Array[max4]<Difference_Raw[j])
			 {
			  Array[max4]=Difference_Raw[j];
			 }			 
			 
			 if ( Array[min4]>Difference_Raw[j])
			 {
			 Array[min4]=Difference_Raw[j];
			 }
			 
		   }
		   
		   return;

}
 