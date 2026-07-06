//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76450
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
 

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Black
#property indicator_color2 Blue
#property indicator_color3 Red

extern bool ShowText = TRUE;
int LookbackPeriod = 14;
extern int TextHorOffset = 50;
double IndicatorBuffer[];
double UpBuffer[];
double DownBuffer[];
string SignalText = "";
string IndicatorName = "TRENDSENTRY";
int LastBarTime = 0;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   IndicatorDigits(Digits + 1);
   SetIndexBuffer(0, IndicatorBuffer);
   SetIndexBuffer(1, UpBuffer);
   SetIndexBuffer(2, DownBuffer);
   IndicatorShortName(IndicatorName);
   SetIndexLabel(1, "UP");
   SetIndexLabel(2, "DOWN");
   return (0);
}
	  		 	  			 			 					 	   	   	 		  	     		    			  		    		  	     	 	 				 				  						 	 				  			     	 				  			 	   				 					  		  	 		 
// 52D46093050F38C27267BCE42543EF60
int deinit() {
   return (0);
}
	     		 		 			  		  	      	    					 	       	 		 	 	    	 	 		  		 			 	  	  							 				  	 		 	 			   	  	 		 	 				  	 		  		  	 			 	  	  
// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double TypicalPrice;
   int CountedBars = IndicatorCounted();
   double FilteredValue = 0;
   double PreviousFilteredValue = 0;
   double PreviousIndicatorValue = 0;
   double LowestPrice = 0;
   double HighestPrice = 0;
   if (ShowText) InitTextLabel();
   int SignalColor = 16777215;
   if (CountedBars > 0) CountedBars--;
   int BarsToCalculate = Bars - CountedBars;
   if (BarsToCalculate < 35) BarsToCalculate = 35;
   if (IsNewBar() && BarsToCalculate < 40) BarsToCalculate = 300;

   int StartBar = 1;
   if (BarsToCalculate <= StartBar) {
      UpBuffer[0] = EMPTY_VALUE;
      DownBuffer[0] = EMPTY_VALUE;
      return(0);
   }

   for (int i = BarsToCalculate - 1; i >= StartBar; i--) {
      if (i < BarsToCalculate - 1 && IndicatorBuffer[i] != EMPTY_VALUE && IndicatorBuffer[i] != 0) continue;

      if (i + 1 < Bars) {
         PreviousIndicatorValue = IndicatorBuffer[i + 1];
         double PrevHigh = High[iHighest(NULL, 0, MODE_HIGH, LookbackPeriod, i + 1)];
         double PrevLow = Low[iLowest(NULL, 0, MODE_LOW, LookbackPeriod, i + 1)];
         double PrevTP = (High[i + 1] + Low[i + 1] + Close[i + 1]) / 3.0;
         if (PrevHigh != PrevLow) {
            PreviousFilteredValue = 0.66 * ((PrevTP - PrevLow) / (PrevHigh - PrevLow) - 0.5) + 0.67 * PreviousFilteredValue; // Cải thiện ước tính
         } else {
            PreviousFilteredValue = 0;
         }
      } else {
         PreviousFilteredValue = 0;
         PreviousIndicatorValue = 0;
      }

      HighestPrice = High[iHighest(NULL, 0, MODE_HIGH, LookbackPeriod, i)];
      LowestPrice = Low[iLowest(NULL, 0, MODE_LOW, LookbackPeriod, i)];
      TypicalPrice = (High[i] + Low[i] + Close[i]) / 3.0;
      FilteredValue = 0.66 * ((TypicalPrice - LowestPrice) / (HighestPrice - LowestPrice) - 0.5) + 0.67 * PreviousFilteredValue;
      FilteredValue = MathMin(MathMax(FilteredValue, -0.999), 0.999);
      IndicatorBuffer[i] = MathLog((FilteredValue + 1.0) / (1 - FilteredValue)) / 2.0 + PreviousIndicatorValue / 2.0;
      PreviousFilteredValue = FilteredValue;
      PreviousIndicatorValue = IndicatorBuffer[i];
   }

   bool IsBullish = TRUE;
   for (i = BarsToCalculate - 1; i >= StartBar; i--) {
      if (UpBuffer[i] != EMPTY_VALUE || DownBuffer[i] != EMPTY_VALUE) {
         if (i == StartBar) {
            if (UpBuffer[i] != EMPTY_VALUE) {
               SignalText = "LONG";
               SignalColor = 65280;
            } else if (DownBuffer[i] != EMPTY_VALUE) {
               SignalText = "SHORT";
               SignalColor = 255;
            }
         }
         continue;
      }

      UpBuffer[i] = EMPTY_VALUE;
      DownBuffer[i] = EMPTY_VALUE;
      if (IndicatorBuffer[i] < 0.0) IsBullish = FALSE;
      else IsBullish = TRUE;
      if (!IsBullish) {
         DownBuffer[i] = iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_HIGH, i);
         UpBuffer[i] = EMPTY_VALUE;
         if (i == StartBar) SignalText = "SHORT"; SignalColor = 255;
      } else {
         UpBuffer[i] = iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_LOW, i);
         DownBuffer[i] = EMPTY_VALUE;
         if (i == StartBar) SignalText = "LONG"; SignalColor = 65280;
      }
   }

   UpBuffer[0] = EMPTY_VALUE;
   DownBuffer[0] = EMPTY_VALUE;

   if (ShowText) UpdateTextLabel(IndicatorName, SignalText, 20, SignalColor, TextHorOffset + 100, 50);
   return (0);
}
	  	 	 	 				    			  	    				  		 	 		   	 			 					        			   		 		 		  	 			 	   			  	  		     	     	  		     		        			  				   	   
// 19F6B3E57E7C3D034D6318C3C69149B4
void InitTextLabel() {
   if (ObjectFind(IndicatorName) == -1) ObjectCreate(IndicatorName, OBJ_LABEL, 0, 0, 0);
   UpdateTextLabel(IndicatorName, "", 20, White, TextHorOffset + 100, 50);
}
	   	  	 		  	   		 			       	  			 			    	 		 		        						  	   		 	 			 				 	  					   		 			 	   		   		 			 		  			   		 						 		    
// F412C23B721CFEB0738FBC3525A5D9AC
void UpdateTextLabel(string ObjectName, string Text, int FontSize, color TextColor, int XPosition, int YPosition) {
   ObjectSet(ObjectName, OBJPROP_CORNER, 1);
   ObjectSet(ObjectName, OBJPROP_XDISTANCE, XPosition);
   ObjectSet(ObjectName, OBJPROP_YDISTANCE, YPosition);
   ObjectSetText(ObjectName, Text, FontSize, "Arial Bold", TextColor);
}
		 	 	 	  			     		  	  	 				   	 	 		 	 	 			  				   	    				  		 					  	 	 	 	   	 	  	  	      	 	   	  	      			        		  			    	   
// 88F3AD7A7E7B65F5E0D00334A43C38C7
int IsNewBar() {
   int CurrentBarTime = iTime(Symbol(), PERIOD_M1, 0);
   if (LastBarTime == 0) LastBarTime = CurrentBarTime;
   if (LastBarTime != CurrentBarTime) {
      LastBarTime = CurrentBarTime;
      return (1);
   }
   return (0);
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76450
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/