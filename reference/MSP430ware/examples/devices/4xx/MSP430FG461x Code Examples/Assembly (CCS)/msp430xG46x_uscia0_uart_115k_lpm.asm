;******************************************************************************
;   MSP430xG46x Demo - USCI_A0, 115200 UART Echo ISR, DCO SMCLK, LPM3
;
;   Description: Echo a received character, RX ISR used. Normal mode is LPM3.
;   Automatic clock activation for SMCLK through the USCI is demonstrated.
;   USCI_A0 RX interrupt triggers TX Echo.
;   Baud rate divider with 1048576hz = 1048576/115200 = ~9.1 (009h|01h)
;   ACLK = LFXT1 = 32768Hz, MCLK = SMCLK = default DCO = 32 x ACLK = 1048576Hz
;   //* An external watch crystal between XIN & XOUT is required for ACLK *//	
;
;                MSP430xG461x
;             -----------------
;         /|\|              XIN|-
;          | |                 | 32kHz
;          --|RST          XOUT|-
;            |                 |
;            |     P4.6/UCA0TXD|------------>
;            |                 | 115200 - 8N1
;            |     P4.7/UCA0RXD|<------------
;
;
;  JL Bile
;  Texas Instruments Inc.
;  June 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430xG46x.h"
;-------------------------------------------------------------------------------
			.text	;Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #900,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupFLL    bis.b   #XCAP14PF,&FLL_CTL0     ; Configure load caps

OFIFGcheck  bic.b   #OFIFG,&IFG1            ; Clear OFIFG
            mov.w   #047FFh,R15             ; Wait for OFIFG to set again if
OFIFGwait   dec.w   R15                     ; not stable yet
            jnz     OFIFGwait
            bit.b   #OFIFG,&IFG1            ; Has it set again?
            jnz     OFIFGcheck              ; If so, wait some more

SetupP4     bis.b   #0C0h,&P4SEL            ; P4.7,6 = USCI_A0 RXD/TXD
SetupUSCIA0 bis.b   #UCSSEL_2,&UCA0CTL1     ; SMCLK
            mov.b   #07+2,&UCA0BR0            ; 1MHz 115200
            mov.b   #00,&UCA0BR1            ; 1MHz 115200
            mov.b   #02,&UCA0MCTL           ; Modulation
            bic.b   #UCSWRST,&UCA0CTL1        ; **Initialize USCI state machine**
            bis.b   #UCA0RXIE,&IE2          ; Enable USCI_A0 RX interrupt
                                            ;
Mainloop    bis.b   #LPM3+GIE,SR            ; Enter LPM3, interrupts enabled
            nop                             ; Needed only for debugger
                                            ;
;------------------------------------------------------------------------------
USCIA0RX_ISR;  Echo back RXed character, confirm TX buffer is ready first
;------------------------------------------------------------------------------
TX0         bit.b   #UCA0TXIFG,&IFG2        ; USCI_A0 TX buffer ready?
            jz      TX0                     ; Jump if TX buffer not ready
            mov.b   &UCA0RXBUF,&UCA0TXBUF   ; TX -> RXed character
            reti                            ;
                                            ;
;------------------------------------------------------------------------------
;			Interrupt Vectors
;------------------------------------------------------------------------------
            .sect    ".int25"        ; USCI_A0 Rx Vector
            .short   USCIA0RX_ISR            ;
            .sect    ".reset"            ; RESET Vector
            .short   RESET                   ;
            .end
