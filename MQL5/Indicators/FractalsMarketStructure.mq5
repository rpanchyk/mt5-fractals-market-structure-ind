//+------------------------------------------------------------------+
//|                                      FractalsMarketStructure.mq5 |
//|                                         Copyright 2024, rpanchyk |
//|                                      https://github.com/rpanchyk |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2024, rpanchyk"
#property link        "https://github.com/rpanchyk"
#property version     "1.00"
#property description "Indicator shows market structure based on fractals"

#property indicator_chart_window
#property indicator_plots 2
#property indicator_buffers 2

#property tester_indicator "WilliamsFractals"

// types
enum ENUM_ARROW_SIZE
  {
   SMALL_ARROW_SIZE = 1, // Small
   REGULAR_ARROW_SIZE = 2, // Regular
   BIG_ARROW_SIZE = 3, // Big
   HUGE_ARROW_SIZE = 4 // Huge
  };

// buffers
double ExtHighPriceBuffer[]; // Higher price
double ExtLowPriceBuffer[]; // Lower price

// config
input group "Section :: Main";
input int InpPeriod = 12; // Period

input group "Section :: Style";
input int InpArrowShift = 10; // Arrow shift
input ENUM_ARROW_SIZE InpArrowSize = REGULAR_ARROW_SIZE; // Arrow size
input color InpHigherHighColor = clrGreen; // Higher high color
input color InpLowerLowColor = clrRed; // Lower low color

input group "Section :: Dev";
input bool InpDebugEnabled = true; // Enable debug (verbose logging)

// runtime
int fractalsHandle;
double fractalsHighPriceBuffer[];
double fractalsLowPriceBuffer[];

int highIdx;
int lowIdx;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpDebugEnabled)
     {
      Print("FractalsMarketStructure indicator initialization started");
     }

   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   ArrayInitialize(ExtHighPriceBuffer, EMPTY_VALUE);
   SetIndexBuffer(0, ExtHighPriceBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(0, PLOT_LABEL, "High1");
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_ARROW, 159);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -InpArrowShift);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, InpArrowSize);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, InpHigherHighColor);

   ArrayInitialize(ExtLowPriceBuffer, EMPTY_VALUE);
   SetIndexBuffer(1, ExtLowPriceBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(1, PLOT_LABEL, "Low1");
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_ARROW, 159);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, InpArrowShift);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, InpArrowSize);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, InpLowerLowColor);

   ResetLastError();
   fractalsHandle = iCustom(_Symbol, PERIOD_CURRENT, "WilliamsFractals", "", false, InpPeriod);
   if(fractalsHandle == INVALID_HANDLE)
     {
      Print("WilliamsFractals indicator initialization failed: ", GetLastError());
      return INIT_FAILED;
     }

   ArrayInitialize(fractalsHighPriceBuffer, 0);
//ArraySetAsSeries(fractalsHighPriceBuffer, true);
//SetIndexBuffer(0, fractalsHighPriceBuffer, INDICATOR_DATA);

   ArrayInitialize(fractalsLowPriceBuffer, 0);
//ArraySetAsSeries(fractalsLowPriceBuffer, true);

   highIdx = 0;
   lowIdx = 0;

   if(InpDebugEnabled)
     {
      Print("FractalsMarketStructure indicator initialization finished");
     }
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(InpDebugEnabled)
     {
      Print("FractalsMarketStructure indicator deinitialization started");
     }

   ArrayFill(ExtHighPriceBuffer, 0, ArraySize(ExtHighPriceBuffer), 0);
//ArrayResize(ExtHighPriceBuffer, 0);
//ArrayFree(ExtHighPriceBuffer);

   ArrayFill(ExtLowPriceBuffer, 0, ArraySize(ExtLowPriceBuffer), 0);
//ArrayResize(ExtLowPriceBuffer, 0);
//ArrayFree(ExtLowPriceBuffer);

//ArrayFill(fractalsHighPriceBuffer, 0, ArraySize(fractalsHighPriceBuffer), EMPTY_VALUE);
//ArrayResize(fractalsHighPriceBuffer, 0);
//ArrayFree(fractalsHighPriceBuffer);

//ArrayFree(fractalsLowPriceBuffer);

   IndicatorRelease(fractalsHandle);

   ArrayFill(fractalsHighPriceBuffer, 0, ArraySize(fractalsHighPriceBuffer), 0);
   ArrayFill(fractalsLowPriceBuffer, 0, ArraySize(fractalsLowPriceBuffer), 0);

   if(InpDebugEnabled)
     {
      Print("FractalsMarketStructure indicator deinitialization finished");
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total == prev_calculated)
     {
      return rates_total;
     }
   int startIndex = prev_calculated == 0 ? 0 : prev_calculated - 1;
   int endIndex = rates_total - 1;
   if(InpDebugEnabled)
     {
      PrintFormat("RatesTotal: %i, PrevCalculated: %i, StartIndex: %i, EndIndex: %i", rates_total, prev_calculated, startIndex, endIndex);
     }

   for(int i = startIndex; i <= endIndex; i++)
     {
      if(i < InpPeriod)
        {
         continue;
        }

      //if(high[i] > high[highIdx])
      //  {
      //   SetHigh(time, high, low, i);
      //  }
      //if(low[i] < low[lowIdx])
      //  {
      //   SetLow(time, high, low, i);
      //  }

      ResetLastError();
      if(CopyBuffer(fractalsHandle, 0, rates_total - i, InpPeriod, fractalsHighPriceBuffer) == -1)
        {
         Print("Error: Cannot get HighPriceBuffer of WilliamsFractals indicator: ", GetLastError());
         return rates_total;
        }
        
        //Print(
        //"0: ", fractalsHighPriceBuffer[0],
        //", 1: ", fractalsHighPriceBuffer[1],
        //", 2: ", fractalsHighPriceBuffer[2],
        //", 3: ", fractalsHighPriceBuffer[3],
        //", 4: ", fractalsHighPriceBuffer[4],
        //", 5: ", fractalsHighPriceBuffer[5],
        //", 6: ", fractalsHighPriceBuffer[6],
        //", 7: ", fractalsHighPriceBuffer[7],
        //", 8: ", fractalsHighPriceBuffer[8],
        //", 9: ", fractalsHighPriceBuffer[9],
        //", 10: ", fractalsHighPriceBuffer[10],
        //", 11: ", fractalsHighPriceBuffer[11]
        //);
        
      double highPrice = fractalsHighPriceBuffer[0];
      if(highPrice > 0) // && high[i] > high[highIdx])
        {
         SetHigh(time, high, low, i - InpPeriod);
        }

      ResetLastError();
      if(CopyBuffer(fractalsHandle, 1, rates_total - i, InpPeriod, fractalsLowPriceBuffer) == -1)
        {
         Print("Error: Cannot get LowPriceBuffer of WilliamsFractals indicator: ", GetLastError());
         return rates_total;
        }
      double lowPrice = fractalsLowPriceBuffer[0];
      if(lowPrice > 0) // && low[i] < low[lowIdx])
        {
         SetLow(time, high, low, i - InpPeriod);
        }
     }

   return rates_total;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetHigh(const datetime &time[], const double &high[], const double &low[], int i)
  {
  if(InpDebugEnabled)
           {
            PrintFormat("New high price %f at %s on %i bar (prev high price %f at %s on %i bar)", 
            high[i], TimeToString(time[i]), i, high[highIdx], TimeToString(time[highIdx]), highIdx);
           }
          
if(lowIdx < highIdx)
{
   
} 
else
{

   if(low[lowIdx] > high[i])
     {
      ExtLowPriceBuffer[lowIdx] = EMPTY_VALUE;
      
      for(int j = lowIdx + 1; j <= i; j++)
        {
         if(low[j] < low[lowIdx])
           {
            lowIdx = j;
           }
        }
      ExtLowPriceBuffer[lowIdx] = low[lowIdx];
     }

   highIdx = i;
   ExtHighPriceBuffer[highIdx] = high[highIdx];
}
           
return;
           
     //if(lowIdx < highIdx)
     //   {
     //   Print("-----------------------");
     //    if(ExtHighPriceBuffer[highIdx] < high[i])
     //      {
     //       ExtHighPriceBuffer[highIdx] = EMPTY_VALUE;
     //       Print("Hide high on ", highIdx, " bar at ", time[highIdx], " between ", highIdx, "-", i);
     //      }
     //   }
     //   else
     //     {
  
   //if(i - lowIdx >= InpPeriod)
   if(lowIdx <= highIdx)
     {
      lowIdx = highIdx + 1;
      for(int j = highIdx + 2; j <= i; j++)
        {
         if(low[j] < low[lowIdx])
           {
            lowIdx = j;
           }
        }

      if(ExtLowPriceBuffer[lowIdx] == EMPTY_VALUE || ExtLowPriceBuffer[lowIdx] <= 0.0)
      //if(lowIdx < highIdx)
        {
         //if(InpCalcHighLowEnabled)
         //  {
         //   ExtCalcLowPriceBuffer[lowIdx] = low[lowIdx];
         //  }
         //else
         //  {
            //ExtLowPriceBuffer[lowIdx] = low[lowIdx];
           //}
         if(InpDebugEnabled)
           {
            Print("Calculated Low on ", lowIdx, " bar at ", time[lowIdx], " in range: ", highIdx, "-", i);
           }
        }
        
         if(highIdx == lowIdx)
        {
         //ExtHighPriceBuffer[lowIdx] = EMPTY_VALUE;
        }
     }
   //else
   //  {
   //   if(lowIdx < highIdx)
   //     {
   //      ExtHighPriceBuffer[highIdx] = EMPTY_VALUE;
   //     }
   //  }
     
           
          //}

   highIdx = i;
   ExtHighPriceBuffer[highIdx] = high[highIdx];
   if(InpDebugEnabled)
     {
      Print("High on ", highIdx, " bar at ", time[highIdx]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetLow(const datetime &time[], const double &high[], const double &low[], int i)
  {
  if(InpDebugEnabled)
           {
            PrintFormat("New low price %f at %s on %i bar (prev low price %f at %s on %i bar)", 
            low[i], TimeToString(time[i]), i, low[lowIdx], TimeToString(time[lowIdx]), lowIdx);
           }
           
if(highIdx < lowIdx)
{
   
}
else
{

   if(high[highIdx] < low[i])
     {
      ExtHighPriceBuffer[highIdx] = EMPTY_VALUE;
      
      for(int j = highIdx + 1; j <= i; j++)
        {
         if(high[j] > high[highIdx])
           {
            highIdx = j;
           }
        }
      ExtHighPriceBuffer[highIdx] = high[highIdx];
     }
     
   lowIdx = i;
   ExtLowPriceBuffer[lowIdx] = low[lowIdx];
}
           
return;
           
        //if(highIdx < lowIdx)
        //{if(ExtLowPriceBuffer[lowIdx] > low[i])
        //   {
        // ExtLowPriceBuffer[lowIdx] = EMPTY_VALUE;
        // }
        //} else
        //    {
             
  
   //if(i - highIdx >= InpPeriod)
   if(highIdx <= lowIdx)
     {
      highIdx = lowIdx;
      for(int j = lowIdx + 1; j <= i; j++)
        {
         if(high[j] > high[highIdx])
           {
            highIdx = j;
           }
        }
      
      if(ExtHighPriceBuffer[highIdx] == EMPTY_VALUE || ExtHighPriceBuffer[highIdx] <= 0.0)
      //if(highIdx < lowIdx)
        {
         //if(InpCalcHighLowEnabled)
         //  {
         //   ExtCalcHighPriceBuffer[highIdx] = high[highIdx];
         //  }
         //else
         //  {
            //ExtHighPriceBuffer[highIdx] = high[highIdx];
           //}
         if(InpDebugEnabled)
           {
            Print("Calculated High on ", highIdx, " bar at ", time[highIdx], " in range: ", lowIdx, "-", i);
           }
        }
         if(highIdx == lowIdx)
        {
         //ExtLowPriceBuffer[lowIdx] = EMPTY_VALUE;
        }
     }
   //else
   //  {
   //   if(highIdx < lowIdx)
   //     {
   //      ExtLowPriceBuffer[lowIdx] = EMPTY_VALUE;
   //     }
   //  }
   

            //}
            
   lowIdx = i;
   ExtLowPriceBuffer[lowIdx] = low[lowIdx];
   if(InpDebugEnabled)
     {
      Print("Low on ", lowIdx, " bar at ", time[lowIdx]);
     }
  }
//+------------------------------------------------------------------+
