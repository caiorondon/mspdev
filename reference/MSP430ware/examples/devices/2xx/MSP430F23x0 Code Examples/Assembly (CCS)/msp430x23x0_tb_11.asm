;*******************************************************************************
;   MSP430F23x0 Demo - Timer_B, PWM TB1-2, Up Mode, 32kHz ACLK
;
;   Description: This program generates two PWM outputs on P4.1-2 using
;   Timer_B configured for up mode. The value in TBCCR0, 512-1, defines the PWM
;   period and the values in TBCCR1-2 the PWM duty cycles. Using 32kHz ACLK
;   as TBCLK, the timer period is 15.6ms. Normal operating mode is LPM3.
;   ACLK = TBCLK = LFXT1 = 32768Hz, MCLK = SMCLK = default DCO ~1.2MHz.
;   //* External watch crystal installed on XIN XOUT is required for ACLK *//
;
;                MSP430F23x0
;             -----------------
;         /|\|              XIN|-
;          | |                 | 32k
;          --|RST          XOUT|-
;            |                 |
;            |         P4.1/TB1|--> TBCCR1 - 75% PWM
;            |         P4.2/TB2|--> TBCCR2 - 25% PWM
;
;  JL Bile
;  Texas Instruments Inc.
;  June 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430x23x0.h"
;-------------------------------------------------------------------------------
			.text	;Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #450h,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupP4     bis.b   #06h,&P4DIR             ; P4.1-P4.2 output
            bis.b   #06h,&P4SEL             ; P4.1-P4.2 TB1-2 otions
SetupC0     mov.w   #512-1,&TBCCR0          ; PWM Period
SetupC1     mov.w   #OUTMOD_7,&TBCCTL1      ; TBCCR1 reset/set
            mov.w   #384,&TBCCR1            ; TBCCR1 PWM Duty Cycle
SetupC2     mov.w   #OUTMOD_7,&TBCCTL2      ; TBCCR2 reset/set
            mov.w   #128,&TBCCR2            ; TBCCR2 PWM duty cycle
SetupTB     mov.w   #TBSSEL_1+MC_1,&TBCTL   ; ACLK, upmode
                                            ;
Mainloop    bis.w   #LPM3,SR                ; Enter LPM3
            nop                             ; Required only for debugger
                                            ;
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect	".reset"            ; MSP430 RESET Vector
            .short	RESET                   ;
            .end
