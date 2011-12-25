;******************************************************************************
;   MSP-FET430P140 Demo - ADC12, Extend Sampling Period with SHT Bits
;
;   Description: This program shows how to extend the sampling time with the
;                internal sampling timer.
;
;   This example shows how to extend the sampling time using the sampling
;   timer. In this example, the ADC12OSC is used to provide the sampling period
;   and the SHT0 bits are set to extend the sampling period to 4xADC12CLKx256.
;   A single conversion is performed on channel A0. The A/D conversion results
;   are stored in ADC12MEM0 and are moved to R5 upon completion of the
;   conversion. Test by setting and running to a break point at "jmp Mainloop."
;   To view the conversion results, open a register window in debugger and view
;   the contents of R5.
;
;
;                MSP430F149
;              ---------------
;             |               |
;      Vin -->|P6.0/A0        |
;             |               |
;
;
;   M. Mitchell / G. Morton
;   Texas Instruments Inc.
;   May 2005
;   Built with Code Composer Essentials Version: 1.0
;******************************************************************************
 .cdecls C,LIST,  "msp430x14x.h"
;------------------------------------------------------------------------------
            .text                  ; Program Start
;------------------------------------------------------------------------------
RESET       mov     #0A00h,SP               ; Initialize stackpointer
StopWDT     mov     #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog
                                            ;
SetupADC12  mov     #ADC12ON+SHT0_15,&ADC12CTL0 ; Turn on ADC12, .set SHT0
                                                ; for longer sampling
            mov     #SHP,&ADC12CTL1         ; Use sampling timer
            bis     #BIT0,&ADC12IE          ; Enable ADC12IFG.0 for ADC12MEM0
            bis     #ENC,&ADC12CTL0         ; Enable conversions
                                            ;
Mainloop    bis     #ADC12SC,&ADC12CTL0     ; Start conversions
            bis     #LPM0+GIE,SR            ; Wait for conversion completion
                                            ; Enable interrupts
            nop                             ; Only required for CSPY
            jmp     Mainloop                ; SET BREAKPOINT HERE
                                            ;
;------------------------------------------------------------------------------
ADC12ISR    ; Interrupt Service Routine for ADC12
;------------------------------------------------------------------------------
            mov     &ADC12MEM0,R5           ; Move result, IFG is reset
            bic     #CPUOFF,0(SP)           ; Return active
            reti                            ;
                                            ;
;-----------------------------------------------------------------------------
;           Interrupt Vectors
;-----------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;
            .sect   ".int07"                ; ADC12 Interrupt Vector
            .short  ADC12ISR                ;
            .end