//******************************************************************************
//  MSP430F21x2 Demo - Timer1_A2, Toggle P1.0, Overflow ISR, 32kHz ACLK
//
//  Description: Toggle P1.0 using software and the Timer1_A1 overflow ISR.
//  In this example an ISR triggers when Timer1_A2 overflows. Inside the ISR P1.0
//  is toggled. Toggle rate is exactly 0.5Hz.
//  Proper use of the TA1IV interrupt vector generator is demonstrated.
//  ACLK = TA1CLK = LFXT1 = 32768Hz, MCLK = SMCLK = default DCO ~1.2MHz
//  //* An external watch crystal on XIN XOUT is required for ACLK *//
//
//              MSP430F21x2
//            -----------------
//        /|\|              XIN|-
//         | |                 | 32kHz
//         --|RST          XOUT|-
//           |                 |
//           |             P1.0|-->LED
//
//  A. Dannenberg
//  Texas Instruments Inc.
//  April 2006
//  Built with CCE Version: 3.2.0 and IAR Embedded Workbench Version: 4.10A
//******************************************************************************
#include "msp430x21x2.h"

void main(void)
{
  WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT
  P1DIR |= 0x01;                            // P1.0 output
  TA1CTL = TASSEL_1 + MC_2 + TAIE;           // ACLK, contmode, interrupt

  __bis_SR_register(LPM3_bits + GIE);       // Enter LPM3 w/ interrupt
}

// Timer1_A1 Interrupt Vector (TAIV) handler
#pragma vector=TIMER1_A1_VECTOR
__interrupt void Timer1_A1(void)
{
  switch (__even_in_range(TA1IV, 10))        // Efficient switch-implementation
  {
    case  2:  break;                        // TACCR1 not used
    case  4:  break;                        // TACCR2 not used
    case 10:  P1OUT ^= 0x01;                // overflow
              break;
  }
}

