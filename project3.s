.equ SWI_SETSEG8,		0x200 	@display on 8 Segment
.equ SWI_SETLED,		0x201 	@LEDs on/off
.equ SWI_CheckBlack,	0x202 	@check Black button
.equ SWI_CheckBlue,		0x203 	@check press Blue button
.equ SWI_DRAW_STRING,	0x204 	@display a string on LCD
.equ SWI_DRAW_INT,		0x205 	@display an int on LCD
.equ SWI_CLEAR_DISPLAY,	0x206 	@clear LCD
.equ SWI_DRAW_CHAR,		0x207 	@display a char on LCD
.equ SWI_CLEAR_LINE,	0x208 	@clear a line on LCD
.equ SWI_EXIT,			0x11 	@terminate program
.equ SWI_GetTicks,		0x6d 	@get current time

.equ SEG_A,				0x80 	@ patterns for 8 segment display
.equ SEG_B,				0x40 	@byte values for each segment
.equ SEG_C,				0x20 	@of the 8 segment display
.equ SEG_D,				0x08
.equ SEG_E,				0x04
.equ SEG_F,				0x01
.equ SEG_G,				0x02
.equ SEG_P,				0x10	@ . pattern

.equ LEFT_LED,			0x02	@bit patterns for LED lights
.equ RIGHT_LED,			0x01
.equ LEFT_BLACK_BUTTON,	0x01	@bit patterns for black buttons
.equ RIGHT_BLACK_BUTTON,0x02	

.equ BLUE_KEY_00,		0x01	@button(0)
.equ BLUE_KEY_01,		0x02	@button(1)
.equ BLUE_KEY_02,		0x04	@button(2)
.equ BLUE_KEY_03,		0x08	@button(3)
.equ BLUE_KEY_04,		0x10	@button(4)
.equ BLUE_KEY_05,		0x20	@button(5)
.equ BLUE_KEY_06,		0x40	@button(6)
.equ BLUE_KEY_07,		0x80	@button(7)
.equ BLUE_KEY_08,		1<<8	@button(8)
.equ BLUE_KEY_09,		1<<9	@button(9)
.equ BLUE_KEY_10,		1<<10	@button(A)
.equ BLUE_KEY_11,		1<<11	@button(B)
.equ BLUE_KEY_12,		1<<12	@button(C)
.equ BLUE_KEY_13,		1<<13	@button(D)
.equ BLUE_KEY_14,		1<<14	@button(E)
.equ BLUE_KEY_15,		1<<15	@button(F)

@ Clear the board, clear the LCD screen
	swi SWI_CLEAR_DISPLAY
@ Both LEDs off
	mov r0,#0
	swi SWI_SETLED
@ 8-segment blank
	mov r0,#0
	swi SWI_SETSEG8

@ Instruction Screen

	mov r0,#6
	mov r1,#1
	ldr r2,=Aster
	swi SWI_DRAW_STRING
	
	mov r0,#6
	mov r1,#2
	ldr r2,=Welcome
	swi SWI_DRAW_STRING
	
	mov r0,#6
	mov r1,#3
	ldr r2,=Aster
	swi SWI_DRAW_STRING

	mov r0,#6
	mov r1,#5
	ldr r2,=Instruction1
	swi SWI_DRAW_STRING

	mov r0,#6
	mov r1,#6
	ldr r2,=Instruction2
	swi SWI_DRAW_STRING
	
	mov r0,#6
	mov r1,#7
	ldr r2,=Instruction3
	swi SWI_DRAW_STRING
	
	mov r0,#6
	mov r1,#8
	ldr r2,=Instruction4
	swi SWI_DRAW_STRING
	
	@ Reset black button
	mov r0,#0
	
	cmp r3,#0
	beq showU_Main
	cmp r3,#0
	beq showL_Main

MainLoop:
	swi SWI_CheckBlack
	
	cmp r0,#1
	beq LED_ProgramLoop

	bne MainLoop

LeftLoop:
	mov r0,#LEFT_LED
	swi SWI_SETLED
	
	bl Lock_Status
	
LED_ProgramLoop:
	mov r0,#RIGHT_LED
	swi SWI_SETLED
	
	cmp r3,#0
	beq showP
	cmp r3,#1
	beq showL

ProgramLoop:
	bl ClearScreen
	bl ProgramLoopMessage
	
	mov r0,#0
	swi SWI_SETLED
	
	@ reset black button
	mov r0,#0

	cmp r3,#0
	beq BlueInner1

	cmp r3,#1
	beq OpenLock

BlueInner1:
	swi SWI_CheckBlack
	cmp r0,#1 @ Confirm Pin
	beq LED_ConfirmPin
	cmp r0,#2 @ Left go back to main
	beq LED_MainLoopReset
		
		BlueInner2:
			swi SWI_CheckBlue
			cmp r0,#0
			beq BlueInner1
			bl BlueDisplayLoop

LED_ConfirmPin:
	mov r0,#RIGHT_LED
	swi SWI_SETLED
	bl CheckPin

OpenLock:
	ldr r0,=SEG_A|SEG_B|SEG_C|SEG_G|SEG_E|SEG_F|SEG_P	
	swi SWI_SETSEG8

	mov r0,#0
	swi SWI_SETSEG8
	bl ClearScreen
	bl OpenInstructions
	
	@ reset all registers
	mov r6,r9 @ r6 is master key
	mov r0,#0
	mov r1,#0
	mov r2,#0
	mov r4,#0
	mov r5,#0
	mov r7,#0
	mov r8,#0
	mov r9,#0
	
	OpenLock1:
		swi SWI_CheckBlack
		cmp r0,#1 @ Confirm Pin
		beq LED_OpenSafe
		cmp r0,#2
		beq LED_LockLoopReset
	
		OpenLock2:
			swi SWI_CheckBlue
			cmp r0,#0
			beq OpenLock1
			bl BlueDisplayLoop
			
LED_OpenSafe:
	cmp r6,r8
	bne OpenLock
	beq OpenLockB

OpenLockB:
	ldr r0,=SEG_A|SEG_D|SEG_E|SEG_F|SEG_P
	swi SWI_SETSEG8

	mov r2,#0
	mov r4,#0
	mov r5,#0

	OpenLockB1:
		swi SWI_CheckBlack
		cmp r0,#1 @ Confirm Pin
		beq LED_OpenSafeB
		cmp r0,#2 @ Left go back to main
		beq LED_LockLoopReset
	
		OpenLockB2:
			swi SWI_CheckBlue
			cmp r0,#0
			beq OpenLock1
			bl BlueDisplayLoop2

LED_OpenSafeB:
	cmp r8,r9
	beq SetLockB
	bne DeniedLock2

SetLockB:
	mov r3,#0 @ Removes Lock Status
	
	bal LockAccept
	
LED_MainLoopReset:
	cmp r3,#0
	beq showUReset
	cmp r3,#1
	beq showLReset
	
	LED_MainLoopResetReturn:
	
	mov r0,#LEFT_LED
	swi SWI_SETLED
	
	bl ClearScreen

	swi SWI_CLEAR_LINE
	
	@ reset all registers
	mov r1,#0
	mov r2,#0
	mov r4,#0
	mov r5,#0
	mov r7,#0
	mov r8,#0
	mov r9,#0
	
	bal ProgramLoop

LED_LockLoopReset:
	cmp r3,#0
	beq showU_Locked
	
	cmp r3,#1
	beq showL_Locked
	
LED_MainLoop:
	mov r0,#LEFT_LED
	swi SWI_SETLED
	
	bal MainLoop
	
CheckPin:
	cmp r4,#4
	bge ConfirmPin
	blt DeniedLock
	
ConfirmPin:
	ldr r0,=SEG_A|SEG_D|SEG_E|SEG_F|SEG_P
	swi SWI_SETSEG8
	
	mov r0,#0
	
	mov r0,#8
	swi SWI_CLEAR_LINE
	
	@ Resets counters, and screen position
	mov r2,#0
	mov r4,#0
	mov r5,#0
	
	ConfPin1:
		swi SWI_CheckBlack
		cmp r0,#1 @ Confirm Pin
		beq LED_ConfirmPin2
		cmp r0,#2 @ Left go back to main
		beq LED_MainLoopReset
	
		ConfPin2:
			swi SWI_CheckBlue
			cmp r0,#0
			beq ConfPin1
			bl BlueDisplayLoop2

LED_ConfirmPin2:
	bl ClearScreen
	bl CheckPin2

CheckPin2:
	cmp r8,r9
	beq SetLock
	bne DeniedLock2

Lock_Status:
	cmp r3,#0
	beq Unlock_Status
	cmp r3,#1
	beq Lock_Status

Unlock_Status:
	ldr r0,=SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_P
	swi SWI_SETSEG8
	
	bl Unlocked
	
Lock_Check:
	ldr r0,=SEG_D|SEG_E|SEG_F|SEG_P		
	swi SWI_SETSEG8
	
	bl SetLock

SetLock:
	mov r3,#1 @ Sets Lock
	
	bal ProgramLoop
	
LockAccept:
	ldr r0,=SEG_A|SEG_B|SEG_C|SEG_G|SEG_E|SEG_F|SEG_P	
	swi SWI_SETSEG8
	
	bal ProgramLoop

Unlocked:
	bl ClearScreen
	bl SafeStatus
	bl UnlockScreenMessage
	
DeniedLock:
	mov r0,#0
	swi SWI_SETLED
	
	mov r0,#RIGHT_LED
	swi SWI_SETLED
	
	mov r1,#0
	mov r2,#0
	mov r4,#0
	mov r5,#0
	mov r7,#0
	mov r8,#0
	mov r9,#0
	
	ldr r0,=SEG_A|SEG_B|SEG_G|SEG_F|SEG_E|SEG_P
	swi SWI_SETSEG8
	
	bal ProgramLoop
	
DeniedLock2:
	mov r0,#0
	swi SWI_SETLED
	
	mov r0,#RIGHT_LED
	swi SWI_SETLED
	
	mov r1,#0
	mov r2,#0
	mov r4,#0
	mov r5,#0
	mov r7,#0
	mov r8,#0
	mov r9,#0
	
	ldr r0,=SEG_A|SEG_D|SEG_E|SEG_F|SEG_G|SEG_P
	swi SWI_SETSEG8
	
	bal ProgramLoop

showP:
	ldr r0,=SEG_A|SEG_B|SEG_G|SEG_F|SEG_E|SEG_P
	swi SWI_SETSEG8
	
	bal ProgramLoop
	
showL:
	ldr r0,=SEG_D|SEG_E|SEG_F|SEG_P
	swi SWI_SETSEG8
	
	bal ProgramLoop

showL_Main:
	ldr r0,=SEG_D|SEG_E|SEG_F|SEG_P
	swi SWI_SETSEG8
	
	bal MainLoop

showU:
	ldr r0,=SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_P	
	swi SWI_SETSEG8
	
	bal ProgramLoop
	
showU_Main:
	ldr r0,=SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_P	
	swi SWI_SETSEG8
	
	bal MainLoop
	
showUReset:
	ldr r0,=SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_P
	swi SWI_SETSEG8
	
	bal LED_MainLoopResetReturn
	
showLReset:
	ldr r0,=SEG_D|SEG_E|SEG_F|SEG_P
	swi SWI_SETSEG8

	bal LED_MainLoopResetReturn

showU_Locked:
	ldr r0,=SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_P
	swi SWI_SETSEG8
	
	bal OpenLockB1
	
showL_Locked:
	ldr r0,=SEG_D|SEG_E|SEG_F|SEG_P
	swi SWI_SETSEG8

	bal OpenLockB1
	
BlueDisplayLoop:
	cmp r0,#BLUE_KEY_15
	beq FIFTEEN

	cmp r0,#BLUE_KEY_14
	beq FOURTEEN

	cmp r0,#BLUE_KEY_13
	beq THIRTEEN

	cmp r0,#BLUE_KEY_12
	beq TWELVE
	
	cmp r0,#BLUE_KEY_11
	beq ELEVEN

	cmp r0,#BLUE_KEY_10
	beq TEN

	cmp r0,#BLUE_KEY_09
	beq NINE

	cmp r0,#BLUE_KEY_08
	beq EIGHT

	cmp r0,#BLUE_KEY_07
	beq SEVEN

	cmp r0,#BLUE_KEY_06
	beq SIX

	cmp r0,#BLUE_KEY_05
	beq FIVE

	cmp r0,#BLUE_KEY_04
	beq FOUR

	cmp r0,#BLUE_KEY_03
	beq THREE

	cmp r0,#BLUE_KEY_02
	beq TWO

	cmp r0,#BLUE_KEY_01
	beq ONE

	cmp r0,#BLUE_KEY_00
		mov r7,#1
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED
		
		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d0
		swi SWI_DRAW_STRING

		bal CKBLUELOOP
	ONE:
		mov r7,#2
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED
		
		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d1
		swi SWI_DRAW_STRING

		bal CKBLUELOOP
	TWO:
		mov r7,#3
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED
		
		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d2
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP
	THREE:
		mov r7,#4
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED
		
		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d3
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP
	FOUR:
		mov r7,#5
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED
		
		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d4
		swi SWI_DRAW_STRING
	
		bal CKBLUELOOP
	FIVE:
		mov r7,#6
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d5
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP
	SIX:
		mov r7,#7
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d6
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP
	SEVEN:
		mov r7,#8
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d7
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP
	EIGHT:
		mov r7,#9
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED
		
		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d8
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP
	NINE:
		mov r7,#10
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d9
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP
	TEN:
		mov r7,#11
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=dA
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP
	ELEVEN:
		mov r7,#12
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=dB
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP
	TWELVE:
		mov r7,#13
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=dC
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP
	THIRTEEN:
		mov r7,#14
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=dD
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP
	FOURTEEN:
		mov r7,#15
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=dE
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP
	FIFTEEN:
		mov r7,#16
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=dF
		swi SWI_DRAW_STRING
	CKBLUELOOP:		
		mov r0,#0
		swi SWI_SETLED
	
		mov r0,r7
	
		cmp r0,#0x00
		beq BlueInner1
		
		add r4,r4,#1
		mov r2,r4
		cmp r2,#7
		beq ResetCount
		
		add r5,r5,#3
		
		bl StorePin
		
		mov r0,#6
		mov r1,#8
		ldr r2,=CurrCode
		swi SWI_DRAW_STRING
		
		cmp r3,#0
		beq BlueInner1
		
		cmp r3,#1
		beq OpenLock1
		
BlueDisplayLoop2:
	cmp r0,#BLUE_KEY_15
	beq FIFTEEN2

	cmp r0,#BLUE_KEY_14
	beq FOURTEEN2

	cmp r0,#BLUE_KEY_13
	beq THIRTEEN2

	cmp r0,#BLUE_KEY_12
	beq TWELVE2
	
	cmp r0,#BLUE_KEY_11
	beq ELEVEN2

	cmp r0,#BLUE_KEY_10
	beq TEN2

	cmp r0,#BLUE_KEY_09
	beq NINE2

	cmp r0,#BLUE_KEY_08
	beq EIGHT2

	cmp r0,#BLUE_KEY_07
	beq SEVEN2

	cmp r0,#BLUE_KEY_06
	beq SIX2

	cmp r0,#BLUE_KEY_05
	beq FIVE2

	cmp r0,#BLUE_KEY_04
	beq FOUR2

	cmp r0,#BLUE_KEY_03
	beq THREE2

	cmp r0,#BLUE_KEY_02
	beq TWO2

	cmp r0,#BLUE_KEY_01
	beq ONE2

	cmp r0,#BLUE_KEY_00
		mov r7,#1
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d0
		swi SWI_DRAW_STRING

		bal CKBLUELOOP2
	ONE2:
		mov r7,#2
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d1
		swi SWI_DRAW_STRING

		bal CKBLUELOOP2
	TWO2:
		mov r7,#3
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d2
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP2
	THREE2:
		mov r7,#4
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED
		
		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d3
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP2
	FOUR2:
		mov r7,#5
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d4
		swi SWI_DRAW_STRING
	
		bal CKBLUELOOP2
	FIVE2:
		mov r7,#6
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d5
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP2
	SIX2:
		mov r7,#7
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d6
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP2
	SEVEN2:
		mov r7,#8
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d7
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP2
	EIGHT2:
		mov r7,#9
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d8
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP2
	NINE2:
		mov r7,#10
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=d9
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP2
	TEN2:
		mov r7,#11
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=dA
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP2
	ELEVEN2:
		mov r7,#12
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=dB
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP2
	TWELVE2:
		mov r7,#13
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=dC
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP2
	THIRTEEN2:
		mov r7,#14
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=dD
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP2
	FOURTEEN2:
		mov r7,#15
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=dE
		swi SWI_DRAW_STRING
		
		bal CKBLUELOOP2
	FIFTEEN2:
		mov r7,#16
		mov r0,#(LEFT_LED|RIGHT_LED)
		swi SWI_SETLED

		mov r0,#11
		add r0,r0,r5
		mov r0,r0
		mov r1,#8
		ldr r2,=dF
		swi SWI_DRAW_STRING
	CKBLUELOOP2:
		mov r0,#0
		swi SWI_SETLED
	
		mov r0,r7
	
		cmp r0,#0x00
		beq ConfPin1
		
		add r4,r4,#1
		mov r2,r4
		cmp r2,#7
		
		beq ResetCount
		@ ResetCountReturn:
		
		add r5,r5,#3
		
		bl StorePin2
		
		mov r0,#6
		mov r1,#8
		ldr r2,=CurrCode
		swi SWI_DRAW_STRING
		
		bal ConfPin1
		
		cmp r3,#0
		beq ConfPin1
		
		cmp r3,#1
		beq OpenLockB1
		
	StorePin:
		add r8,r8,r7
		mov r8,r8,lsl#4
		
		bx lr
		
	StorePin2:
		add r9,r9,r7
		mov r9,r9,lsl#4
		
		bx lr
		
	ResetCount:
		mov r2,#0
		mov r4,#6
		mov r5,#15
		
		mov pc,lr
		
	ProgramLoopMessage:
	
		mov r0,#6
		mov r1,#1
		ldr r2,=Aster
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#2
		ldr r2,=ScreenP
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#3
		ldr r2,=Aster
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#4
		ldr r2,=InstructionP1
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#5
		ldr r2,=InstructionP2
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#6
		ldr r2,=InstructionP3
		swi SWI_DRAW_STRING
		
		mov pc,lr
	
	SafeStatus:
	
		mov r0,#6
		mov r1,#1
		ldr r2,=Aster
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#2
		ldr r2,=SafeStatusM
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#3
		ldr r2,=Aster
		swi SWI_DRAW_STRING
		
		mov pc,lr
	
	ConfPinMessage:
		mov r0,#1
		swi SWI_CLEAR_LINE
		mov r0,#2
		swi SWI_CLEAR_LINE
		mov r0,#3
		swi SWI_CLEAR_LINE
		mov r0,#4
		swi SWI_CLEAR_LINE
		mov r0,#5
		swi SWI_CLEAR_LINE
		mov r0,#6
		swi SWI_CLEAR_LINE
		mov r0,#7
		swi SWI_CLEAR_LINE
	
		mov r0,#6
		mov r1,#1
		ldr r2,=Aster
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#2
		ldr r2,=ConfPinMessageD
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#3
		ldr r2,=Aster
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#4
		ldr r2,=ConfPinMessage1
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#5
		ldr r2,=ConfPinMessage2
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#6
		ldr r2,=ConfPinMessage3
		swi SWI_DRAW_STRING
		
		mov pc,lr
		
	DeniedLenMessage:
	
		mov r0,#6
		mov r1,#1
		ldr r2,=Aster
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#2
		ldr r2,=DeniedLenM
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#3
		ldr r2,=Aster
		swi SWI_DRAW_STRING
		
		mov r0,#8
		mov r1,#5
		ldr r2,=D1Instruct
		swi SWI_DRAW_STRING
		
		mov pc,lr
	
	LockScreenMessage:

		mov r0,#6
		mov r1,#5
		ldr r2,=LockScreen
		swi SWI_DRAW_STRING
		
		mov pc,lr
	
	UnlockScreenMessage:
	
		mov r0,#6
		mov r1,#1
		ldr r2,=Aster
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#2
		ldr r2,=UnlockScreen
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#3
		ldr r2,=Aster
		swi SWI_DRAW_STRING
		
		mov pc,lr
	
	LockAcceptScreen:
	
		mov r0,#6
		mov r1,#1
		ldr r2,=Aster
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#2
		ldr r2,=LockAccept1
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#3
		ldr r2,=LockAccept2
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#4
		ldr r2,=Aster
		swi SWI_DRAW_STRING
	
		mov pc,lr
	
	OpenInstructions:
		ldr r0,=SEG_A|SEG_B|SEG_G|SEG_F|SEG_E|SEG_P	
		swi SWI_SETSEG8
	
		mov r0,#6
		mov r1,#1
		ldr r2,=Aster
		swi SWI_DRAW_STRING
	
		mov r0,#6
		mov r1,#2
		ldr r2,=OpenM
		swi SWI_DRAW_STRING
	
		mov r0,#6
		mov r1,#3
		ldr r2,=Aster
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#4
		ldr r2,=Open1
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#5
		ldr r2,=Open2
		swi SWI_DRAW_STRING
		
		mov pc,lr
	
	OpenSafeScreen:
		mov r0,#6
		mov r1,#1
		ldr r2,=Aster
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#2
		ldr r2,=OpenSafe1
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#3
		ldr r2,=OpenSafe2
		swi SWI_DRAW_STRING
		
		mov r0,#6
		mov r1,#4
		ldr r2,=Aster
		swi SWI_DRAW_STRING
		
		mov pc,lr
	
	ClearScreen:
		mov r0,#1
		swi SWI_CLEAR_LINE
		mov r0,#2
		swi SWI_CLEAR_LINE
		mov r0,#3
		swi SWI_CLEAR_LINE
		mov r0,#4
		swi SWI_CLEAR_LINE
		mov r0,#5
		swi SWI_CLEAR_LINE
		mov r0,#6
		swi SWI_CLEAR_LINE
		mov r0,#7
		swi SWI_CLEAR_LINE
		mov r0,#8
		swi SWI_CLEAR_LINE

		mov pc,lr
		
@ ================================================

.data
zero:	.word 	SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_F				@0
one:	.word	SEG_B|SEG_C 									@1
two:	.word	SEG_A|SEG_B|SEG_G|SEG_E|SEG_D 					@2
three:	.word	SEG_A|SEG_B|SEG_G|SEG_C|SEG_D					@3
four:	.word	SEG_F|SEG_G|SEG_B|SEG_C							@4
five:	.word	SEG_A|SEG_F|SEG_G|SEG_C|SEG_D					@5
six:	.word	SEG_A|SEG_F|SEG_G|SEG_E|SEG_D|SEG_C				@6
seven:	.word	SEG_A|SEG_B|SEG_C								@7
eight:	.word	SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_G		@8
nine:	.word	SEG_A|SEG_B|SEG_F|SEG_G|SEG_C					@9
A_LED:	.word	SEG_A|SEG_B|SEG_C|SEG_G|SEG_E|SEG_F|SEG_P		@A
B_LED:	.word	SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_G|SEG_P	@B
C_LED:	.word	SEG_A|SEG_D|SEG_E|SEG_F|SEG_P					@C
D_LED:	.word	SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_P		@D
E_LED:	.word	SEG_A|SEG_D|SEG_G|SEG_E|SEG_F|SEG_P				@E
F_LED:	.word	SEG_A|SEG_G|SEG_F|SEG_E|SEG_P					@F

G_LED:	.word	SEG_A|SEG_C|SEG_D|SEG_G|SEG_E|SEG_F|SEG_P		@G
U_LED:	.word	SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_P				@U
L_LED:	.word	SEG_D|SEG_E|SEG_F|SEG_P							@L
P_LED:	.word	SEG_A|SEG_B|SEG_G|SEG_F|SEG_E|SEG_P				@P
Empty:	.word 	0 												@Blank display

Welcome:		.asciz	"Welcome to your Digital Safe"
Aster:			.asciz	"****************************"
Instruction1:	.asciz	"Press right black button"
Instruction2:	.asciz	"To create pin / forget pin."
Instruction3:	.asciz	"Press left black button"
Instruction4:	.asciz	"to unlock."

ScreenP:		.asciz	"     	Input Code:    	"
InstructionP1:	.asciz	"Enter 4 - 7 pin combination"
InstructionP2:	.asciz	"Press Left Black: Back to Reset"
InstructionP3:	.asciz	"Press Right Black: Confirm Pin"

DeniedLenM:		.asciz	"    Unacceptable Pin Code  "
D1Instruct:		.asciz	"Please Reset: Left Black"
D2Instruct:		.asciz	"& "
D3Instruct:		.asciz	"Input 4 - 7 digit pin "

ResetMess:		.asciz	"...Resetting Code..."

ConfPinMessageD:.asciz	"        Confirm Pin"
ConfPinMessage1:.asciz	"Reenter Pin Code	"
ConfPinMessage2:.asciz	"Press Left Black: Back to Reset"
ConfPinMessage3:.asciz	"Press Right Black: Confirm Pin"

SafeStatusM:	.asciz	"		Safe Status		"
LockScreen:		.asciz	"     	*Locked "
UnlockScreen:	.asciz	"	  	*Unlocked "

LockAccept1:	.asciz	"      Safe Locked	"
LockAccept2:	.asciz	"Press Left Black to Continue "

OpenM:			.asciz	"Safe Locked			"
Open1:			.asciz	"Enter personal pincode "
Open2:			.asciz	"to unlock safe."

OpenSafe1:		.asciz	"Pincode accepted"
OpenSafe2:		.asciz	"Safe Unlocked"

Or:				.asciz	"Or"
CurrCode:		.asciz	"Code:"
d0:				.asciz	"[0]"
d1:				.asciz	"[1]"
d2:				.asciz	"[2]"
d3:				.asciz	"[3]"
d4:				.asciz	"[4]"
d5:				.asciz	"[5]"
d6:				.asciz	"[6]"
d7:				.asciz	"[7]"
d8:				.asciz	"[8]"
d9:				.asciz	"[9]"
dA:				.asciz	"[A]"
dB:				.asciz	"[B]"
dC:				.asciz	"[C]"
dD:				.asciz	"[D]"
dE:				.asciz	"[E]"
dF:				.asciz	"[F]"

.end