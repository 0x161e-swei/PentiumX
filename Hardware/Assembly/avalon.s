.text
#baseAddr 0000
#中断向量区
j start #reset
add $zero, $zero, $zero #00000004
add $zero ,$zero ,$zero #00000008
add $zero, $zero, $zero #0000000C
add $zero, $zero, $zero #00000010
add $zero, $zero, $zero #00000014
add $zero, $zero, $zero #00000018
add $zero, $zero, $zero #0000001C
#参数区
add $zero, $zero, $zero #00000020 文本光标：0000XXYY 00XX0000保存在当前line中的位置
add $zero, $zero, $zero #00000024 图形光标：00XXXYYY
add $zero, $zero, $zero #00000028 键盘缓冲区头指针
add $zero, $zero, $zero #0000002C 键盘缓冲区尾指针
add $zero, $zero, $zero #00000030 键盘缓冲区低字：最近4个ASCII码
add $zero, $zero, $zero #00000034 键盘缓冲区第2字：次近4个ASCII码
add $zero, $zero, $zero #00000038 键盘缓冲区第3字：次高4个ASCII码
add $zero, $zero, $zero #0000003C 键盘缓冲区高字：最高4个ASCII码
add $zero, $zero, $zero #00000040 System Status Word:shif=D31,press_hold=d30,最后8位存当前line的字符数，限定一次性不能输入超过255个字符
add $zero, $zero, $zero #00000044 键盘扫描码缓冲区低：去掉F0
add $zero, $zero, $zero #00000048 键盘扫描码缓冲区高：去掉F0
add $zero, $zero, $zero #0000004C
add $zero, $zero, $zero #00000050
add $zero, $zero, $zero #00000054
add $zero, $zero, $zero #00000058
add $zero, $zero, $zero #0000005C
add $zero, $zero, $zero #00000060
add $zero, $zero, $zero #00000064

#################################################

start: #00000080
	addi $sp, $zero, 16000 #堆栈初始化，SP=16000
	sw   $zero, 0x20($zero) #初始化文本模式光标VRAM addre:C0000+ROW*80+COL
	sw   $zero, 0x24($zero) #初始化图形模式光标

	#初始化接口
	ori $s1, $zero, 0xff00 # $1=FFFFFF00: LED、SW、BTN读写端口
	add  $s2, $s1, $s1 # $s2=FFFFFE00：7段码显示端口
	ori $s3, $zero, 0xd000 # $s3=ffffd000：PS2键盘端口

	addi $s5, $zero, 0x7fff #硬件计数器定时常数$s5=00007fff
	addi $t1, $zero, 0x2ab # $t1=000002AB= 10101010(LED) 11(counter_set) 光标位置在初始
	sw   $t1, 0($s1) 

	addi $t0, $zero, 0x2
	sw   $t0, 4($s1) #输入counter_ctrl
	lw   $t1, 0($s1) #读取sw开关状态
	andi $t1, $t1, 0x00ff  #取出末八位
	add  $t1, $t1, $t1 #左移两位对齐led输出(末两位为counter_set)
	add  $t1, $t1, $t1 #左移两位后计数器通道为00
	sw   $t1, 0($s1) #输入

	sw   $s5, 4($s1) #输入计数器常数0x7fff，开始计时

#################################################

	#初始化引导界面
	lui  $t2, 0x000c
	addi $t1, $zero, 0x12c0 #显存vram单元数 19200 ? 4800
CL_next_init:
	sw   $zero, 0($t2)
	addi $t2, $t2, 4 #下一个单元
	addi $t1, $t1, -1
	bne  $t1, $zero, CL_next_init

	lui  $t0, 0x000c
	addi $t0, $t0, 0x44c0
	addi $t5, $zero, 0x50

delay:
	lui  $s4, 0xfffd #程序软件计数延时，时常数fffc0000
delay1:
	addi $s4, $s4, 1
	bne  $s4, $zero, delay1
	lw   $t1, 0($s1) #读取sw开关状态
	andi $t1, $t1, 0x00ff  #取出末八位
	add  $t1, $t1, $t1 #左移两位对齐led输出(末两位为counter_set)
	add  $t1, $t1, $t1 #左移两位后计数器通道为00
	sw   $t1, 0($s1) #输入

	addi $t9, $zero, 0x0780 # color(1,1,1), ascii 0x2e 字符'■'
	sw   $t9, 0($t0)
	addi $t0, $t0, 4
	addi $t5, $t5, -1
	bne  $t5, $zero, delay #重复打80个'■'

	jal  Clear_screen

polling:
	jal  Cursor_out
	jal  Key_scan
	beq  $v0, $zero, polling
	add  $s0, $zero, $v0  #当前返回值（有效扫描码）存入$s0, $a0
	add  $a0, $zero, $v0
	lui  $a1, 0x000c
	addi $a1, $a1, 0x1c #--------??????
	addi $a2, $zero, 0x700 #颜色信息，白色
	#jal  disp_reg
	add  $a0, $zero, $s0 #与上面重复，可能disp_reg中用到了$a0
	jal  Key2ascii #转换ascii码
	beq  $v0, $zero, repolling #返回值为0，不diaplay


	addi $t0, $zero, 0x0d
	beq  $v0, $t0, Clear_Enter_polling # clear指令
	Clear_Enter_Back:
	beq  $v0, $t0, Reboot_Enter_polling # reboot指令
	Reboot_Enter_Back:
	beq  $v0, $t0, Snake_Enter_polling # reboot指令
	Snake_Enter_Back:
	beq  $v0, $t0, LF_polling # 回车换行

	addi $t0, $zero, 0x08
	beq  $v0, $t0, BS_polling #退格

	addi $t0, $zero, 0x1d
	beq  $v0, $t0, Cursor_Left_polling #左移光标

	addi $t0, $zero, 0x1c
	beq  $v0, $t0, Cursor_Right_polling #右移光标

	addi $a0, $v0, 0x700 #转换得到的ascii加上颜色信息（白色）
	jal  disp_ascii #显示当前ascii码
repolling:
	j    polling
LF_polling:
	jal  LF
	j    polling
BS_polling:
	jal  BS
	j    polling
Cursor_Left_polling:
	jal  Cursor_Left
	j    polling
Cursor_Right_polling:
	jal  Cursor_Right
	j    polling
Clear_Enter_polling:
	jal  Clear_Enter
	beq  $v0, $zero, polling #返回值为0，不diaplay
	j    Clear_Enter_Back
Reboot_Enter_polling:
	jal  Reboot_Enter
	j    Reboot_Enter_Back
Snake_Enter_polling:
	jal  Snake_Enter
	beq  $v0, $zero, polling #返回值为0，不diaplay
	j    Snake_Enter_Back


#--------------------------------------系统指令------------------------------------------------------------

#---------------------------------clear指令---------------------------------------------------------
Clear_Enter:
	addi $sp, $sp, -12
	sw   $t0, 0($sp)
	sw   $t1, 4($sp)
	sw   $t2, 8($sp)

	lw   $t0, 0x40($zero)
	andi $t0, $t0, 0xff #获取当前line字符数
	addi $t1, $zero, 0x5
	bne  $t0, $t1, Clear_Enter_ret

	lw   $t0, 0x20($zero) #读取当前光标位置
	andi $t1, $t0, 0x3f00 #获取光标行
	srl  $t2, $t1, 4 #行*16
	sll  $t1, $t2, 2 #行*64
	add  $t2, $t1, $t2 # $t2=行*80
	andi $t1, $t0, 0x007f
	add  $t2, $t1, $t2 # $t2 = 行*80+列
	lw   $t0, 0x20($zero)
	srl  $t0, $t0, 16
	andi $t0, $t0, 0xff #获取光标在当前行的位置
	sub  $t2, $t2, $t0

	sll  $t2, $t2, 2 # $t2 = (行*80+列)*4
	lui  $t0, 0x000c
	add  $t0, $t0, $t2

	lw   $t1, 0($t0)
	addi $t2, $zero, 0x763 #acsii码 c
	bne  $t1, $t2, Clear_Enter_ret

	addi $t0, $t0, 4
	lw   $t1, 0($t0)
	addi $t2, $zero, 0x76c #acsii码 l
	bne  $t1, $t2, Clear_Enter_ret

	addi $t0, $t0, 4
	lw   $t1, 0($t0)
	addi $t2, $zero, 0x765 #acsii码 e
	bne  $t1, $t2, Clear_Enter_ret

	addi $t0, $t0, 4
	lw   $t1, 0($t0)
	addi $t2, $zero, 0x761 #acsii码 a
	bne  $t1, $t2, Clear_Enter_ret

	addi $t0, $t0, 4
	lw   $t1, 0($t0)
	addi $t2, $zero, 0x772 #acsii码 r
	bne  $t1, $t2, Clear_Enter_ret

	add  $v0, $zero, $zero
	addi $sp, $sp, -4
	sw   $ra, 0($sp)
	jal  Clear_screen
	lw   $ra, 0($sp)
	addi $sp, $sp, 4


Clear_Enter_ret:
	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 12
	jr   $ra

#--------------------------------------------reboot指令------------------------------==
Reboot_Enter:
	addi $sp, $sp, -12
	sw   $t0, 0($sp)
	sw   $t1, 4($sp)
	sw   $t2, 8($sp)

	lw   $t0, 0x40($zero)
	andi $t0, $t0, 0xff #获取当前line字符数
	addi $t1, $zero, 0x6
	bne  $t0, $t1, Reboot_Enter_ret

	lw   $t0, 0x20($zero) #读取当前光标位置
	andi $t1, $t0, 0x3f00 #获取光标行
	srl  $t2, $t1, 4 #行*16
	sll  $t1, $t2, 2 #行*64
	add  $t2, $t1, $t2 # $t2=行*80
	andi $t1, $t0, 0x007f
	add  $t2, $t1, $t2 # $t2 = 行*80+列
	lw   $t0, 0x20($zero)
	srl  $t0, $t0, 16
	andi $t0, $t0, 0xff #获取光标在当前行的位置
	sub  $t2, $t2, $t0

	sll  $t2, $t2, 2 # $t2 = (行*80+列)*4
	lui  $t0, 0x000c
	add  $t0, $t0, $t2

	lw   $t1, 0($t0)
	addi $t2, $zero, 0x772 #acsii码 r
	bne  $t1, $t2, Reboot_Enter_ret


	addi $t0, $t0, 4
	lw   $t1, 0($t0)
	addi $t2, $zero, 0x765 #acsii码 e
	bne  $t1, $t2, Reboot_Enter_ret

	addi $t0, $t0, 4
	lw   $t1, 0($t0)
	addi $t2, $zero, 0x762 #acsii码 b
	bne  $t1, $t2, Reboot_Enter_ret

	addi $t0, $t0, 4
	lw   $t1, 0($t0)
	addi $t2, $zero, 0x76f #acsii码 o
	bne  $t1, $t2, Reboot_Enter_ret

	addi $t0, $t0, 4
	lw   $t1, 0($t0)
	addi $t2, $zero, 0x76f #acsii码 o
	bne  $t1, $t2, Reboot_Enter_ret

	addi $t0, $t0, 4
	lw   $t1, 0($t0)
	addi $t2, $zero, 0x774 #acsii码 t
	bne  $t1, $t2, Reboot_Enter_ret

	j    start


Reboot_Enter_ret:
	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 12
	jr   $ra

#------------------------------------------------启动Snake-----------------------------
Snake_Enter:
	addi $sp, $sp, -12
	sw   $t0, 0($sp)
	sw   $t1, 4($sp)
	sw   $t2, 8($sp)

	lw   $t0, 0x40($zero)
	andi $t0, $t0, 0xff #获取当前line字符数
	addi $t1, $zero, 0x5
	bne  $t0, $t1, Snake_Enter_ret

	lw   $t0, 0x20($zero) #读取当前光标位置
	andi $t1, $t0, 0x3f00 #获取光标行
	srl  $t2, $t1, 4 #行*16
	sll  $t1, $t2, 2 #行*64
	add  $t2, $t1, $t2 # $t2=行*80
	andi $t1, $t0, 0x007f
	add  $t2, $t1, $t2 # $t2 = 行*80+列
	lw   $t0, 0x20($zero)
	srl  $t0, $t0, 16
	andi $t0, $t0, 0xff #获取光标在当前行的位置
	sub  $t2, $t2, $t0

	sll  $t2, $t2, 2 # $t2 = (行*80+列)*4
	lui  $t0, 0x000c
	add  $t0, $t0, $t2

	lw   $t1, 0($t0)
	addi $t2, $zero, 0x773 #acsii码 s
	bne  $t1, $t2, Snake_Enter_ret

	addi $t0, $t0, 4
	lw   $t1, 0($t0)
	addi $t2, $zero, 0x76e #acsii码 n
	bne  $t1, $t2, Snake_Enter_ret

	addi $t0, $t0, 4
	lw   $t1, 0($t0)
	addi $t2, $zero, 0x761 #acsii码 a
	bne  $t1, $t2, Snake_Enter_ret

	addi $t0, $t0, 4
	lw   $t1, 0($t0)
	addi $t2, $zero, 0x76b #acsii码 k
	bne  $t1, $t2, Snake_Enter_ret

	addi $t0, $t0, 4
	lw   $t1, 0($t0)
	addi $t2, $zero, 0x765 #acsii码 e
	bne  $t1, $t2, Snake_Enter_ret

	addi $sp, $sp, -4
	sw   $ra, 0($sp)
	jal  Snake
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	add  $v0, $zero, $zero


Snake_Enter_ret:
	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 12
	jr   $ra

###########系统调用#################
#---------------显示光标---------------------------------
Cursor_out:
	addi $sp, $sp, -16
	sw   $t0, 0($sp)
	sw   $t1, 4($sp)
	sw   $t2, 8($sp)
	sw   $t3, 0xc($sp)

	lw   $t2, 0x20($zero) #取当前光标
	andi $t3, $t2, 0x7f #取末7位，光标列
	add  $t3, $t3, $t3 #左移一位， 以便拼接
	andi $t2, $t2, 0x3f00 #取6位，光标行
	add  $t2, $t2, $t3 #合并光标行列
	sll  $t2, $t2, 9 #再左移9位，对齐gpiof0

	lw   $t1, 0($s1) #读取sw开关状态
	andi $t1, $t1, 0x00ff  #取出末八位
	add  $t1, $t1, $t1 #左移两位对齐led输出(末两位为counter_set)
	add  $t1, $t1, $t1 #左移两位后计数器通道为00

	or   $t1, $t1, $t2 #合并光标
	sw   $t1, 0($s1) #写入光标

	lw   $t3, 0xc($sp)
	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 16
	jr   $ra


#----------------清屏---------------------------------
Clear_screen:
	addi $sp, $sp, -12   #space for t0, t1, t2
	sw   $t0, 0($sp)
	sw   $t1, 4($sp)
	sw   $t2, 8($sp)
	lui  $t2, 0x000c
	addi $t0, $zero, 0x12c0 #显存vram单元数 19200 ? 4800
CL_next:
	sw   $zero, 0($t2)
	addi $t2, $t2, 4 #下一个单元
	addi $t0, $t0, -1
	bne  $t0, $zero, CL_next
	addi $t0, $zero, 0x000B #置文本光标
	sw   $t0, 0x20($zero)
	addi $t0, $zero, 0x643 #行前加'C'
	lui  $t2, 0x000c #回到初始位置
	sw   $t0, 0($t2)
	addi $t2, $t2, 4
	addi $t0, $zero, 0x64a #行前加'J'
	sw   $t0, 0($t2)
	addi $t2, $t2, 4
	addi $t0, $zero, 0x640 #行前加'@'
	sw   $t0, 0($t2)
	addi $t2, $t2, 4
	addi $t0, $zero, 0x641 #行前加'A'
	sw   $t0, 0($t2)
	addi $t2, $t2, 4
	addi $t0, $zero, 0x676 #行前加'v'
	sw   $t0, 0($t2)
	addi $t2, $t2, 4
	addi $t0, $zero, 0x661 #行前加'a'
	sw   $t0, 0($t2)
	addi $t2, $t2, 4
	addi $t0, $zero, 0x66c #行前加'l'
	sw   $t0, 0($t2)
	addi $t2, $t2, 4
	addi $t0, $zero, 0x66f #行前加'o'
	sw   $t0, 0($t2)
	addi $t2, $t2, 4
	addi $t0, $zero, 0x66e #行前加'n'
	sw   $t0, 0($t2)
	addi $t2, $t2, 4
	addi $t0, $zero, 0x63e #行前加'>'
	sw   $t0, 0($t2)
	addi $t2, $t2, 4
	sw   $zero, 0($t2)     #行前加' '

	lw   $t0, 0x40($zero)
	andi $t0, $t0, 0xff00 #置当前line字符数为0
	sw   $t0, 0x40($zero)

	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 12
	jr   $ra

#-------------------------换行-------------------------------
LF:
	addi $sp, $sp, -16
	sw   $t0, 0($sp)
	sw   $t1, 4($sp)
	sw   $t2, 8($sp)
	sw   $t3, 12($sp)

	lw   $t0, 0x20($zero) #获取光标当前位置
	lw   $t3, 0x40($zero) #获取当前line字符数
	andi $t3, $t3, 0xff
	srl  $t1, $t0, 16
	andi $t1, $t1, 0x00ff #获取光标在当前line的位置
	sub  $t3, $t3, $t1 #计算光标后的字符数

	andi $t2, $t0, 0x7f #获取光标列
	andi $t0, $t0, 0x3f00 #获取光标行
	add  $t2, $t2, $t3 #列加上到行尾的距离

LF_toTail:
	slti $t1, $t2, 0x50 #判断列数是否<80
	bne  $t1, $zero, LF_goLF
	addi $t0, $t0, 0x100
	addi $t2, $t2, -80
	j    LF_toTail 

LF_goLF:
	add  $t2, $zero, $zero
	addi $t0, $t0, 0x100 #行+1
	addi $t1, $zero, 0x3c00 #常数60
	bne  $t0, $t1, LF_ret #行没超过60，返回
	add $t0, $zero, $zero #行清零

	addi $sp, $sp, -4
	sw   $ra, 0($sp)
	jal  Screen_move_up #清屏（换上移一行？）
	#jal  Clear_screen 
	jal  LF
	lw   $ra, 0($sp)
	addi $sp, $sp, 4

	lw   $t3, 12($sp)
	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 16
	jr   $ra

LF_ret:
	add  $t0, $t0, $t2
	sw   $t0, 0x20($zero)

	lw   $t0, 0x40($zero)
	andi $t0, $t0, 0xff00 #置当前line字符数为0
	sw   $t0, 0x40($zero)

	
	addi $sp, $sp, -4
	sw   $ra, 0($sp)
	addi $a0, $zero, 0x643 #行前加'C'
	jal  disp_ascii #
	addi $a0, $zero, 0x64a #行前加'J'
	jal  disp_ascii #
	addi $a0, $zero, 0x640 #行前加'@'
	jal  disp_ascii #
	addi $a0, $zero, 0x641 #行前加'A'
	jal  disp_ascii #
	addi $a0, $zero, 0x676 #行前加'v'
	jal  disp_ascii #
	addi $a0, $zero, 0x661 #行前加'a'
	jal  disp_ascii #
	addi $a0, $zero, 0x66c #行前加'l'
	jal  disp_ascii #
	addi $a0, $zero, 0x66f #行前加'o'
	jal  disp_ascii #
	addi $a0, $zero, 0x66e #行前加'n'
	jal  disp_ascii #
	addi $a0, $zero, 0x63e #行前加'>'
	jal  disp_ascii #
	add $a0, $zero, $zero #行前加' '
	jal  disp_ascii #
	lw   $ra, 0($sp)
	addi $sp, $sp, 4

	lw   $t0, 0x40($zero)
	andi $t0, $t0, 0xff00 #置当前line字符数为0
	sw   $t0, 0x40($zero)

	lw   $t0, 0x20($zero)
	lui  $t1, 0xff00
	addi $t1, $t1, 0x7fff
	addi $t1, $t1, 0x7000
	addi $t1, $t1, 0x1000 # $t1=0xff00_ffff
	and  $t0, $t0, $t1 #置光标在当前line的位置为0
	sw   $t0, 0x20($zero)


	lw   $t3, 12($sp)
	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 16
	jr   $ra

#---------------------------------退格----------------------
BS:
	addi $sp, $sp, -16
	sw   $t0, 0($sp)
	sw   $t1, 4($sp)
	sw   $t2, 8($sp)
	sw   $t3, 12($sp)

	lw   $t0, 0x20($zero)
	srl  $t0, $t0, 16
	andi $t2, $t0, 0x00ff #获取光标在当前line的位置
	beq  $t2, $zero, BS_ret #光标位置在0，返回

	lw   $t0, 0x20($zero) #读取当前光标位置
	andi $t1, $t0, 0x3f00 #获取光标行
	srl  $t3, $t1, 4 #行*16
	sll  $t1, $t3, 2 #行*64
	add  $t3, $t1, $t3 # $t2=行*80
	andi $t1, $t0, 0x007f
	add  $t3, $t1, $t3 # $t2 = 行*80+列
	sll  $t3, $t3, 2 # $t2 = (行*80+列)*4
	addi $t3, $t3, -4
	lui  $t1, 0x000c
	add  $t3, $t1, $t3
	sw   $zero, 0($t3) #将该格填成空格

	 #-----------------------------------------将光标后的字符均往前移一格----
	lw   $t3, 0x20($zero) #读取当前光标位置
	srl  $t3, $t3, 16 #右移16位
	andi $t3, $t3, 0x00ff #获取当前光标在line中的位置
	lw   $t2, 0x40($zero)
	andi $t2, $t2, 0x00ff #获取当前行字符数
	sub  $t3, $t2, $t3 #获取光标后面的字符数，即为循环常量
	sll  $t3, $t3, 2 #乘4

	lw   $t0, 0x20($zero) #读取当前光标位置
	andi $t1, $t0, 0x3f00 #获取光标行
	srl  $t2, $t1, 4 #行*16
	sll  $t1, $t2, 2 #行*64
	add  $t2, $t1, $t2 # $t2=行*80
	andi $t1, $t0, 0x007f
	add  $t2, $t1, $t2 # $t2 = 行*80+列
	sll  $t2, $t2, 2 # $t2 = (行*80+列)*4
	lui  $t0, 0x000c #vram首地址
	add  $t0, $t0, $t2 #vram中对应光标位置

	addi $t3, $t3, 4 #算上光标当前位置的字符

BS_shift:
	beq  $t3, $zero, BS_moveCursor
	lw   $t1, 0($t0)
	sw   $t1, -4($t0)
	addi $t0, $t0, 4
	addi $t3, $t3, -4
	j    BS_shift

BS_moveCursor:
	sw   $zero, -4($t0) #最后一格填成空格

	lw   $t0, 0x40($zero)
	andi $t1, $t0, 0x00ff #获取当前line字符数
	addi $t0, $t0, -1 #字符数-1
	sw   $t0, 0x40($zero)

	lw   $t0, 0x20($zero) #获取光标当前位置
	andi $t2, $t0, 0x7f #获取光标列
	andi $t0, $t0, 0x3f00 #获取光标行
	bne  $t2, $zero, BS_NOMAL #没退到行首，返回
	addi $t2, $zero, 0x4f
	addi $t0, $t0, -256 #行-1 256=0x100

	add  $t0, $t0, $t2

	lw   $t1, 0x20($zero)
	lui  $t2, 0x00ff
	and  $t2, $t1, $t2 #获取光标在当前行的位置
	lui  $t1, 0x0001
	sub  $t1, $t2, $t1 #光标在当前line中的位置-1
	add  $t0, $t1, $t0 #合成当前line的位置和全局位置
	sw   $t0, 0x20($zero)

	j    BS_ret

BS_NOMAL:
	addi $t2, $t2, -1 #列-1
	add  $t0, $t0, $t2

	lw   $t1, 0x20($zero)
	lui  $t2, 0x00ff
	and  $t2, $t1, $t2 #获取光标在当前行的位置
	lui  $t1, 0x0001
	sub  $t1, $t2, $t1 #光标在当前line中的位置-1
	add  $t0, $t1, $t0 #合成当前line的位置和全局位置
	sw   $t0, 0x20($zero)

BS_ret:
	lw   $t3, 12($sp)
	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 16
	jr   $ra

#---------------------------------光标左移--------------------------
Cursor_Left:
	addi $sp, $sp, -12
	sw   $t0, 0($sp)
	sw   $t1, 4($sp)
	sw   $t2, 8($sp)

	lw   $t0, 0x20($zero)
	lui  $t1, 0x00ff
	and  $t1, $t1, $t0 #获取光标在当前line的位置
	beq  $t1, $zero, Cursor_Left_ret

	lw   $t0, 0x20($zero) #获取光标当前位置
	andi $t2, $t0, 0x7f #获取光标列
	andi $t0, $t0, 0x3f00 #获取光标行
	bne  $t2, $zero, Cursor_Left_Nomal #没退到行首，返回
	addi $t2, $zero, 0x4f
	addi $t0, $t0, -256 #行-1 256=0x100

	add  $t0, $t0, $t2

	lw   $t1, 0x20($zero)
	lui  $t2, 0x00ff
	and  $t2, $t1, $t2 #获取光标在当前行的位置
	lui  $t1, 0x0001
	sub  $t1, $t2, $t1 #光标在当前line中的位置-1
	add  $t0, $t1, $t0 #合成当前line的位置和全局位置
	sw   $t0, 0x20($zero)

	j    Cursor_Left_ret

Cursor_Left_Nomal:
	addi $t2, $t2, -1 #列-1
	add  $t0, $t0, $t2

	lw   $t1, 0x20($zero)
	lui  $t2, 0x00ff
	and  $t2, $t1, $t2 #获取光标在当前行的位置
	lui  $t1, 0x0001
	sub  $t1, $t2, $t1 #光标在当前line中的位置-1
	add  $t0, $t1, $t0 #合成当前line的位置和全局位置
	sw   $t0, 0x20($zero)

Cursor_Left_ret:
	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 12
	jr   $ra


#---------------------------------光标右移-----------------------------------
Cursor_Right:
	addi $sp, $sp, -12
	sw   $t0, 0($sp)
	sw   $t1, 4($sp)
	sw   $t2, 8($sp)

	lw   $t0, 0x20($zero)
	lui  $t1, 0x00ff
	and  $t0, $t1, $t0 #获取光标在当前line的位置
	lw   $t1, 0x40($zero) #获取当前line的字符数
	sll  $t1, $t1, 16 #左移16位对齐
	beq  $t1, $t0, Cursor_Right_ret #光标在当前line的位置等于当前line的字符数，直接返回

	lw   $t0, 0x20($zero) #获取光标当前位置
	andi $t2, $t0, 0x7f #获取光标列
	addi $t2, $t2, 1 #列+1
	andi $t0, $t0, 0x3f00 #获取光标行
	addi $t1, $zero, 0x50 #常量80
	bne  $t2, $t1, Cursor_Right_Nomal #没超出80，跳转
	add  $t2, $zero, $zero
	addi $t0, $t0, 0x100 #行+1

	add  $t0, $t0, $t2
	lw   $t1, 0x20($zero)
	lui  $t2, 0x00ff
	and  $t2, $t1, $t2 #获取光标在当前行的位置
	lui  $t1, 0x0001
	add  $t1, $t2, $t1 #光标在当前line中的位置+1
	add  $t0, $t1, $t0 #合成当前line的位置和全局位置
	sw   $t0, 0x20($zero)

	j    Cursor_Right_ret

Cursor_Right_Nomal:
	add  $t0, $t0, $t2

	lw   $t1, 0x20($zero)
	lui  $t2, 0x00ff
	and  $t2, $t1, $t2 #获取光标在当前行的位置
	lui  $t1, 0x0001
	add  $t1, $t2, $t1 #光标在当前line中的位置+1
	add  $t0, $t1, $t0 #合成当前line的位置和全局位置
	sw   $t0, 0x20($zero)

Cursor_Right_ret:
	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 12
	jr   $ra



#---------------------------屏幕上移一行---------------------------------
Screen_move_up:
	addi $sp, $sp, -16
	sw   $t0, 0($sp)
	sw   $t1, 4($sp)
	sw   $t2, 8($sp)
	sw   $t3, 12($sp)

	addi $t0, $zero, 0x1270 #循环常量4720
	addi $t3, $zero, 0x50 #循环常量80
	lui  $t1, 0x000c

Screen_move_up_loop:
	beq  $t0, $zero, blank_last
	lw   $t2, 320($t1)
	sw   $t2, 0($t1) #把下一行该位置的字符写入该行同位置
	addi $t1, $t1, 4
	addi $t0, $t0, -1
	j    Screen_move_up_loop

blank_last:
	beq  $t3, $zero, Screen_move_up_ret
	sw   $zero, 0($t1) #把最后一行填成空格
	addi $t1, $t1, 4
	addi $t3, $t3, -1
	j    blank_last

Screen_move_up_ret:
	lw   $t0, 0x20($zero)
	andi $t1, $t0, 0x3f00
	beq  $t1, $zero, Screen_move_up_subret
	addi $t1, $zero, 0x100
	sub  $t0, $t0, $t1
	sw   $t0, 0x20($zero)

Screen_move_up_subret:
	lw   $t3, 12($sp)
	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 16
	jr   $ra



#----------------读ps2键盘扫描码-------------------------
Key_scan:
	addi $sp, $sp, -20
	sw   $t0, 0($sp)
	sw   $t1, 4($sp)
	sw   $t2, 8($sp)
	sw   $t3, 12($sp)
	sw   $t8, 16($sp)

	add  $v0, $zero, $zero
	add  $t8, $zero, $zero
	lw   $t3, 0($s3) #读ps2键盘扫描码
	andi $t1, $t3, 0x100 #检查是否ready
	beq  $t1, $zero, Key_ret #没有ready，返回$v0=0

key_proceed:
	andi $t3, $t3, 0xff #去掉ready位得到扫描码
	andi $t2, $t8, 0xff #保存按下时扫描码
	sll  $t8, $t8, 8 #左移8位
	add  $t8, $t8, $t3 #锁存当前key data在低8位，历史key data在高8位 
	sw   $t8, 0($s2) #送七段码显示
	addi $t0, $zero, 0x0012
	beq  $t0, $t3, Key_shift #左shift键被按下，跳转
	addi $t0, $zero, 0x0059 #右shift键
	bne  $t0, $t3, Key_E0F0

Key_shift: #---------------------------------------？？？？？？？？？？
	lw   $t0, 0x40($zero)
	lui  $t1, 0x8000
	or   $t0, $t1, $t0
	sw   $t0, 0x40($zero) #设置shift标志

Key_E0F0:
	addi $t0, $zero, 0x7078
	add  $t0, $t0, $t0 # $t0=E0F0
	sll  $t1, $t8, 0x10
	srl  $t1, $t1, 0x10 #清掉高16位的数据与E0F0对比
	beq  $t0, $t1, Key_next_E0 #若是扩展释放按键码，读经紧随的键盘扫描码，丢弃F0释放码
	addi $t0, $zero, 0x00f0
	beq  $t3, $t0, Key_next_F0 #若是释放按键码，读经紧随的键盘扫描码，丢弃F0释放码
	#-----------------？？？？？
	lw   $t1, 0x40($zero) #判断长按标志,若长按,继续读键盘扫描码
	lui  $t0, 0x4000
	and  $t1, $t1, $t0
	bne  $t1, $zero, scan2mem

	beq  $t3, $t2, Press_hold # $t2中保存了前一次的扫描码，用于判断长按
	srl  $t2, $t8, 0x10 #获取前两次扫描码
	andi $t2, $t2, 0xff #取低16位
	addi $t0, $zero, 0x00e0
	beq  $t2, $t0, Press_hold #判断前前一个扫描码是否是E0，由于之前判断是否是释放，所以不会冲突

Key_again:
	lw   $t3, 0($s3) #读下一个ps2扫描码
	andi $t1, $t3, 0x100 #判断是否ready
	beq  $t1, $zero, Key_again
	j    key_proceed

Key_next_E0:
	addi $t3, $zero, 0x00E0 #清除F0
Key_next_F0:
	lw   $t2, 0x40($zero)
	lui  $t0, 0xbfff
	addi $t0, $t0, 0x7fff
	addi $t0, $t0, 0x7000
	addi $t0, $t0, 0x1000 # $t0 = 0xbfff_ffff
	and  $t2, $t2, $t0 #清除长按标志
	sw   $t2, 0x40($zero)
	j    Key_next

Press_hold:
	lw   $t2, 0x40($zero)
	lui  $t0, 0x4000
	or   $t2, $t2, $t0 #建立长按标志
	sw   $t2, 0x40($zero)

scan2mem: #扫描码放入缓冲区：00000044 00000048
	sll  $v0, $v0, 8 #左移8位
	add  $v0, $v0, $t3 #暂存当前键盘扫描码在低8位，历史扫描码在高位

	lw   $t0, 0x44($zero) #读取缓存区扫描码
	srl  $t1, $t0, 0x18 #获取低位缓存区高8位扫描码，用于存入高位缓存区
	sll  $t0, $t0, 8
	add  $t0, $t0, $t3 #存入低位缓存区
	sw   $t0, 0x44($zero)
	lw   $t0, 0x48($zero)
	sll  $t0, $t0, 8 #空出第八位待写入
	add  $t0, $t0, $t1 #写入低位缓存区高8位扫描码
	sw   $t0, 0x48($zero)
	addi $t0, $zero, 0x00e0
	bne  $t3, $t0, Key_ret #判断当前扫描码是否为E0, 是则继续读，否则返回

Key_next: #当前扫描码为F0或者E0时要继续读下一个
	lw   $t3, 0($s3) #读取ps2扫描码
	andi $t1, $t3, 0x100 #判断是否ready
	beq  $t1, $zero, Key_next
	andi $t3, $t3, 0xff #屏蔽ready位，得到key data
	addi $t0, $zero, 0x00f0
	beq  $t3, $t0, Key_next #判断是否为F0, 该情况一定为E0 F0 XX

	sll  $t8, $t8, 8
	add  $t8, $t8, $t3 #锁存当前Key Data在低8位，历史Key Data在高位
	sw   $t8, 0($s2) #送七段码显示
	addi $t0, $zero, 0x7800
	add  $t0, $t0, $t0 # $t0=F000
	sll  $t2, $t8, 0x10
	srl  $t2, $t2, 0x10 #清除高16位扫描码
	addi $t0, $t0, 0x12 # $t0=F012 即左shift键的释放码
	beq  $t0, $t2, Key_shift_up
	addi $t0, $t0, 0x47 # $t0=F059 即右shift键的释放码
	bne  $t0, $t2, scan2mem

Key_shift_up:
	lw   $t0, 0x40($zero)
	lui  $t1, 0x7fff
	addi $t1, $t1, 0x7fff
	addi $t1, $t1, 0x7000
	addi $t1, $t1, 0x1000 # $t1 = 0x7fff_ffff
	and  $t0, $t1, $t0 #清除shift标志
	sw   $t0, 0x40($zero)
	j    scan2mem

Key_ret:
	lw   $t0, 0($sp)
	lw   $t1, 4($sp)
	lw   $t2, 8($sp)
	lw   $t3, 12($sp)
	lw   $t8, 16($sp)
	addi $sp, $sp, 0x14
	jr   $ra

#---------------ascii码转换---------------------------------------
Key2ascii:
	addi $sp, $sp, -16
	sw   $t0, 0($sp)
	sw   $t1, 4($sp)
	sw   $t2, 8($sp)
	sw   $t3, 12($sp)

	addi $t0, $zero, 0x7000
	add  $t0, $t0, $t0 # $t0=E000
	and  $t1, $a0, $t0
	bne  $t1, $t0, get_ascii #判断是否为扩展位扫描码
	addi $t1, $zero, 0x7fff
	sll  $t1, $t1, 0x1
	addi $t1, $t1, 0x1
	and  $t1, $t1, $a0 #获取低16位的扫描码:E0XX
	addi $t2, $t0, 0x75 # $t2 = E075
	bne  $t2, $t1, Next_E01
	addi $v0, $zero, 0x1e # 上箭头 ↑
	j    ascii_ret #返回ascii码
Next_E01:
	addi $t2, $t0, 0x72 # $t2 = E072
	bne  $t2, $t1, Next_E02
	addi $v0, $zero, 0x1f # 下箭头 ↓
	j    ascii_ret #返回ascii码
Next_E02:
	addi $t2, $t0, 0x6B # $t2 = E06b
	bne  $t2, $t1, Next_E03
	addi $v0, $zero, 0x1d # 左箭头 ←
	j    ascii_ret #返回ascii码
Next_E03: #-----------------------------------似乎只有右箭头带E0，其余无用
	addi $t2, $t0, 0x74 # $t2 = E074
	bne  $t2, $t1, Next_E04
	addi $v0, $zero, 0x1c # 右箭头 →
	j    ascii_ret #返回ascii码
Next_E04:
	addi $t2, $t0, 0x6c # $t2 = E06c
	bne  $t2, $t1, Next_E05
	addi $v0, $zero, 0x0b # HOME键
	j    ascii_ret #返回ascii码
Next_E05:
	addi $t2, $t0, 0x5a # $t2 = E05a
	bne  $t2, $t1, Next_E06
	addi $v0, $zero, 0x0d # 小键盘回车
	j    ascii_ret #返回ascii码
Next_E06: #----------------------------------空操作？
	add  $zero, $zero, $zero
get_ascii:
	andi $t1, $a0, 0xff #获取低8位的扫描码:00XX
	addi $t2, $zero, 0x45 
	bne  $t2, $t1, Next_01
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, num0
	addi $v0, $zero, 0x29 
	j    ascii2mem #写入缓存
	num0:
	addi $v0, $zero, 0x30
	j    ascii2mem #写入缓存
Next_01:
	addi $t2, $zero, 0x16 
	bne  $t2, $t1, Next_02
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, num1
	addi $v0, $zero, 0x21
	j    ascii2mem #写入缓存
	num1:
	addi $v0, $zero, 0x31
	j    ascii2mem #写入缓存
Next_02:
	addi $t2, $zero, 0x1e 
	bne  $t2, $t1, Next_03
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, num2
	addi $v0, $zero, 0x40
	j    ascii2mem #写入缓存
	num2:
	addi $v0, $zero, 0x32
	j    ascii2mem #写入缓存
Next_03:
	addi $t2, $zero, 0x26 
	bne  $t2, $t1, Next_04
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, num3
	addi $v0, $zero, 0x23
	j    ascii2mem #写入缓存
	num3:
	addi $v0, $zero, 0x33
	j    ascii2mem #写入缓存
Next_04:
	addi $t2, $zero, 0x25 
	bne  $t2, $t1, Next_05
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, num4
	addi $v0, $zero, 0x24
	j    ascii2mem #写入缓存
	num4:
	addi $v0, $zero, 0x34
	j    ascii2mem #写入缓存
Next_05:
	addi $t2, $zero, 0x2e 
	bne  $t2, $t1, Next_06
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, num5
	addi $v0, $zero, 0x25
	j    ascii2mem #写入缓存
	num5:
	addi $v0, $zero, 0x35
	j    ascii2mem #写入缓存
Next_06:
	addi $t2, $zero, 0x36 
	bne  $t2, $t1, Next_07
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, num6
	addi $v0, $zero, 0x5e 
	j    ascii2mem #写入缓存
	num6:
	addi $v0, $zero, 0x36
	j    ascii2mem #写入缓存
Next_07:
	addi $t2, $zero, 0x3d 
	bne  $t2, $t1, Next_08
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, num7
	addi $v0, $zero, 0x26
	j    ascii2mem #写入缓存
	num7:
	addi $v0, $zero, 0x37
	j    ascii2mem #写入缓存
Next_08:
	addi $t2, $zero, 0x3e 
	bne  $t2, $t1, Next_09
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, num8
	addi $v0, $zero, 0x2a 
	j    ascii2mem #写入缓存
	num8:
	addi $v0, $zero, 0x38
	j    ascii2mem #写入缓存
Next_09:
	addi $t2, $zero, 0x46 
	bne  $t2, $t1, Next_A
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, num9
	addi $v0, $zero, 0x28
	j    ascii2mem #写入缓存
	num9:
	addi $v0, $zero, 0x39 
	j    ascii2mem #写入缓存
Next_A:
	addi $t2, $zero, 0x1c 
	bne  $t2, $t1, Next_B
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, a
	addi $v0, $zero, 0x41 
	j    ascii2mem #写入缓存
	a:
	addi $v0, $zero, 0x61 
	j    ascii2mem #写入缓存
Next_B:
	addi $t2, $zero, 0x32 
	bne  $t2, $t1, Next_C
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, b
	addi $v0, $zero, 0x42 
	j    ascii2mem #写入缓存
	b:
	addi $v0, $zero, 0x62 
	j    ascii2mem #写入缓存
Next_C:
	addi $t2, $zero, 0x21 
	bne  $t2, $t1, Next_D
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, c
	addi $v0, $zero, 0x43 
	j    ascii2mem #写入缓存
	c:
	addi $v0, $zero, 0x63 
	j    ascii2mem #写入缓存
Next_D:
	addi $t2, $zero, 0x23 
	bne  $t2, $t1, Next_E
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, d
	addi $v0, $zero, 0x44 
	j    ascii2mem #写入缓存
	d:
	addi $v0, $zero, 0x64 
	j    ascii2mem #写入缓存
Next_E:
	addi $t2, $zero, 0x24 
	bne  $t2, $t1, Next_F
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, e
	addi $v0, $zero, 0x45 
	j    ascii2mem #写入缓存
	e:
	addi $v0, $zero, 0x65 
	j    ascii2mem #写入缓存
Next_F:
	addi $t2, $zero, 0x2b 
	bne  $t2, $t1, Next_G
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, f
	addi $v0, $zero, 0x46 
	j    ascii2mem #写入缓存
	f:
	addi $v0, $zero, 0x66 
	j    ascii2mem #写入缓存
Next_G:
	addi $t2, $zero, 0x34 
	bne  $t2, $t1, Next_H
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, g
	addi $v0, $zero, 0x47 
	j    ascii2mem #写入缓存
	g:
	addi $v0, $zero, 0x67 
	j    ascii2mem #写入缓存
Next_H:
	addi $t2, $zero, 0x33 
	bne  $t2, $t1, Next_I
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, h
	addi $v0, $zero, 0x48 
	j    ascii2mem #写入缓存
	h:
	addi $v0, $zero, 0x68 
	j    ascii2mem #写入缓存	
Next_I:
	addi $t2, $zero, 0x43
	bne  $t2, $t1, Next_J
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, i
	addi $v0, $zero, 0x49 
	j    ascii2mem #写入缓存
	i:
	addi $v0, $zero, 0x69 
	j    ascii2mem #写入缓存
Next_J:
	addi $t2, $zero, 0x3b 
	bne  $t2, $t1, Next_K
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, j
	addi $v0, $zero, 0x4a 
	j    ascii2mem #写入缓存
	j:
	addi $v0, $zero, 0x6a
	j    ascii2mem #写入缓存
Next_K:
	addi $t2, $zero, 0x42 
	bne  $t2, $t1, Next_L
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, k
	addi $v0, $zero, 0x4b 
	j    ascii2mem #写入缓存
	k:
	addi $v0, $zero, 0x6b 
	j    ascii2mem #写入缓存
Next_L:
	addi $t2, $zero, 0x4b 
	bne  $t2, $t1, Next_M
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, l
	addi $v0, $zero, 0x4c 
	j    ascii2mem #写入缓存
	l:
	addi $v0, $zero, 0x6c
	j    ascii2mem #写入缓存
Next_M:
	addi $t2, $zero, 0x3a
	bne  $t2, $t1, Next_N
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, m
	addi $v0, $zero, 0x4d
	j    ascii2mem #写入缓存
	m:
	addi $v0, $zero, 0x6d 
	j    ascii2mem #写入缓存
Next_N:
	addi $t2, $zero, 0x31
	bne  $t2, $t1, Next_O
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, n
	addi $v0, $zero, 0x4e
	j    ascii2mem #写入缓存
	n:
	addi $v0, $zero, 0x6e
	j    ascii2mem #写入缓存
Next_O:
	addi $t2, $zero, 0x44
	bne  $t2, $t1, Next_P
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, o
	addi $v0, $zero, 0x4f
	j    ascii2mem #写入缓存
	o:
	addi $v0, $zero, 0x6f 
	j    ascii2mem #写入缓存
Next_P:
	addi $t2, $zero, 0x4d
	bne  $t2, $t1, Next_Q
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, p
	addi $v0, $zero, 0x50
	j    ascii2mem #写入缓存
	p:
	addi $v0, $zero, 0x70
	j    ascii2mem #写入缓存
Next_Q:
	addi $t2, $zero, 0x15
	bne  $t2, $t1, Next_R
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, q
	addi $v0, $zero, 0x51
	j    ascii2mem #写入缓存
	q:
	addi $v0, $zero, 0x71 
	j    ascii2mem #写入缓存
Next_R:
	addi $t2, $zero, 0x2d
	bne  $t2, $t1, Next_S
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, r
	addi $v0, $zero, 0x52
	j    ascii2mem #写入缓存
	r:
	addi $v0, $zero, 0x72
	j    ascii2mem #写入缓存
Next_S:
	addi $t2, $zero, 0x1b
	bne  $t2, $t1, Next_T
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, s
	addi $v0, $zero, 0x53
	j    ascii2mem #写入缓存
	s:
	addi $v0, $zero, 0x73
	j    ascii2mem #写入缓存
Next_T:
	addi $t2, $zero, 0x2c
	bne  $t2, $t1, Next_U
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, t
	addi $v0, $zero, 0x54
	j    ascii2mem #写入缓存
	t:
	addi $v0, $zero, 0x74
	j    ascii2mem #写入缓存
Next_U:
	addi $t2, $zero, 0x3c
	bne  $t2, $t1, Next_V
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, u
	addi $v0, $zero, 0x55
	j    ascii2mem #写入缓存
	u:
	addi $v0, $zero, 0x75
	j    ascii2mem #写入缓存
Next_V:
	addi $t2, $zero, 0x2a
	bne  $t2, $t1, Next_W
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, v
	addi $v0, $zero, 0x56
	j    ascii2mem #写入缓存
	v:
	addi $v0, $zero, 0x76
	j    ascii2mem #写入缓存
Next_W:
	addi $t2, $zero, 0x1d
	bne  $t2, $t1, Next_X
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, w
	addi $v0, $zero, 0x57
	j    ascii2mem #写入缓存
	w:
	addi $v0, $zero, 0x77
	j    ascii2mem #写入缓存
Next_X:
	addi $t2, $zero, 0x22
	bne  $t2, $t1, Next_Y
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, x
	addi $v0, $zero, 0x58
	j    ascii2mem #写入缓存
	x:
	addi $v0, $zero, 0x78 
	j    ascii2mem #写入缓存
Next_Y:
	addi $t2, $zero, 0x35
	bne  $t2, $t1, Next_Z
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, y
	addi $v0, $zero, 0x59
	j    ascii2mem #写入缓存
	y:
	addi $v0, $zero, 0x79 
	j    ascii2mem #写入缓存
Next_Z:
	addi $t2, $zero, 0x1a
	bne  $t2, $t1, Next_ELSE_01
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, z
	addi $v0, $zero, 0x5a
	j    ascii2mem #写入缓存
	z:
	addi $v0, $zero, 0x7a 
	j    ascii2mem #写入缓存
Next_ELSE_01:#---------------------------------------空格键--------------------------------
	addi $t2, $zero, 0x29
	bne  $t2, $t1, Next_ELSE_02
	addi $v0, $zero, 0x20 
	j    ascii2mem #写入缓存
Next_ELSE_02:#-------------------------------------[{---------------------------------
	addi $t2, $zero, 0x54
	bne  $t2, $t1, Next_ELSE_03
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, el2
	addi $v0, $zero, 0x7b
	j    ascii2mem #写入缓存
	el2:
	addi $v0, $zero, 0x5b
	j    ascii2mem #写入缓存
Next_ELSE_03:#-------------------------------------]}----------------------------
	addi $t2, $zero, 0x5b
	bne  $t2, $t1, Next_ELSE_04
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, el3
	addi $v0, $zero, 0x7d
	j    ascii2mem #写入缓存
	el3:
	addi $v0, $zero, 0x5d
	j    ascii2mem #写入缓存
Next_ELSE_04:#------------------------------------\|--------------------------------
	addi $t2, $zero, 0x5d
	bne  $t2, $t1, Next_ELSE_05
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, el4
	addi $v0, $zero, 0x7c
	j    ascii2mem #写入缓存
	el4:
	addi $v0, $zero, 0x5c
	j    ascii2mem #写入缓存
Next_ELSE_05:#-----------------------------------;:-------------------------------
	addi $t2, $zero, 0x4c
	bne  $t2, $t1, Next_ELSE_06
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, el5
	addi $v0, $zero, 0x3a
	j    ascii2mem #写入缓存
	el5:
	addi $v0, $zero, 0x3b
	j    ascii2mem #写入缓存
Next_ELSE_06:#------------------------------------'"-------------------------------
	addi $t2, $zero, 0x52
	bne  $t2, $t1, Next_ELSE_07
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, el6
	addi $v0, $zero, 0x22 
	j    ascii2mem #写入缓存
	el6:
	addi $v0, $zero, 0x27
	j    ascii2mem #写入缓存
Next_ELSE_07:#--------------------------------,<-----------------------------
	addi $t2, $zero, 0x41
	bne  $t2, $t1, Next_ELSE_08
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, el7
	addi $v0, $zero, 0x3c
	j    ascii2mem #写入缓存
	el7:
	addi $v0, $zero, 0x2c
	j    ascii2mem #写入缓存
Next_ELSE_08:#-------------------------------.>------------------------
	addi $t2, $zero, 0x49
	bne  $t2, $t1, Next_ELSE_09
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, el8
	addi $v0, $zero, 0x3e
	j    ascii2mem #写入缓存
	el8:
	addi $v0, $zero, 0x2e
	j    ascii2mem #写入缓存
Next_ELSE_09:#-------------------------------/?------------------------
	addi $t2, $zero, 0x4a
	bne  $t2, $t1, Next_ELSE_10
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, el9
	addi $v0, $zero, 0x3f 
	j    ascii2mem #写入缓存
	el9:
	addi $v0, $zero, 0x2f
	j    ascii2mem #写入缓存
Next_ELSE_10:#----------------------------`~-----------------------------
	addi $t2, $zero, 0x0e
	bne  $t2, $t1, Next_ELSE_11
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, el10
	addi $v0, $zero, 0x7e 
	j    ascii2mem #写入缓存
	el10:
	addi $v0, $zero, 0x60
	j    ascii2mem #写入缓存
Next_ELSE_11:#--------------------------'-_'---------------------------------
	addi $t2, $zero, 0x4e
	bne  $t2, $t1, Next_ELSE_12
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, el11
	addi $v0, $zero, 0x5f 
	j    ascii2mem #写入缓存
	el11:
	addi $v0, $zero, 0x2d
	j    ascii2mem #写入缓存
Next_ELSE_12:#-------------------------------=+--------------------------
	addi $t2, $zero, 0x55
	bne  $t2, $t1, Next_ENTER
	lw   $t3, 0x40($zero)
	lui  $t1, 0x8000
	and  $t3, $t3, $t1
	beq  $t3, $zero, el12
	addi $v0, $zero, 0x2b
	j    ascii2mem #写入缓存
	el12:
	addi $v0, $zero, 0x3d
	j    ascii2mem #写入缓存
Next_ENTER:#-------------------------------回车键--------------------------
	addi $t2, $zero, 0x5a
	bne  $t2, $t1, Next_BS
	addi $v0, $zero, 0x0d
	j    ascii_ret #直接返回
Next_BS:#-------------------------------退格键--------------------------
	addi $t2, $zero, 0x66
	bne  $t2, $t1, Next_UP
	addi $v0, $zero, 0x08
	j    ascii_ret #直接返回
Next_UP:#-------------------------------上键--------------------------
	addi $t2, $zero, 0x75
	bne  $t2, $t1, Next_DOWN
	addi $v0, $zero, 0x1e
	j    ascii_ret #直接返回
Next_DOWN:#-------------------------------下键--------------------------
	addi $t2, $zero, 0x72
	bne  $t2, $t1, Next_LEFT
	addi $v0, $zero, 0x1f
	j    ascii_ret #直接返回
Next_LEFT:#-------------------------------左键--------------------------
	addi $t2, $zero, 0x6b
	bne  $t2, $t1, Next_RIGHT
	addi $v0, $zero, 0x1d
	j    ascii_ret #直接返回
Next_RIGHT:#-------------------------------右键--------------------------
	addi $t2, $zero, 0x74
	bne  $t2, $t1, Next_ESC
	addi $v0, $zero, 0x1c
	j    ascii_ret #直接返回
Next_ESC:#-------------------------------ESC键--------------------------
	addi $t2, $zero, 0x76
	bne  $t2, $t1, Next_END
	addi $v0, $zero, 0x1b
	j    ascii_ret #直接返回

Next_END:
	add $v0, $zero, $zero

ascii2mem:
	addi $t0, $zero, 0x0d
	beq  $t0, $v0, ascii_ret #判断是否为回车键，是则直接返回

	lw   $t0, 0x30($zero)
	srl  $t1, $t0, 0x18 #取出高8位
	sll  $t0, $t0, 8 #空出低8位
	add  $t0, $t0, $v0 #将当前ascii填入缓存
	sw   $t0, 0x30($zero)

	lw   $t0, 0x34($zero)
	srl  $t2, $t0, 0x18 #取出高8位
	sll  $t0, $t0, 8 #空出低8位
	add  $t0, $t0, $t1 #将上一级高8位ascii填入缓存
	sw   $t0, 0x34($zero)

	lw   $t0, 0x38($zero)
	srl  $t1, $t0, 0x18 #取出高8位
	sll  $t0, $t0, 8 #空出低8位
	add  $t0, $t0, $t2 #将上一级高8位ascii填入缓存
	sw   $t0, 0x38($zero)

	lw   $t0, 0x3c($zero)
	sll  $t0, $t0, 8 #空出低8位
	add  $t0, $t0, $t1 #将上一级高8位ascii填入缓存
	sw   $t0, 0x3c($zero)

ascii_ret:
	lw   $t3, 12($sp)
	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 0x10
	jr   $ra



#-------------------------显示ascii码------------------
disp_ascii_ret:
	lw   $t3, 12($sp)
	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 16
	jr   $ra

disp_ascii:
	addi $sp, $sp, -16
	sw   $t0, 0($sp)
	sw   $t1, 4($sp)
	sw   $t2, 8($sp)
	sw   $t3, 12($sp)

	addi $t0, $zero, 0x70d
	beq  $t0, $a0, disp_ascii_ret #判断是否为回车键，是则直接返回
	addi $t0, $zero, 0x708
	beq  $t0, $a0, disp_ascii_ret #判断是否为退格键，是则直接返回
	addi $t0, $zero, 0x71e
	beq  $t0, $a0, disp_ascii_ret #判断是否为上键，是则直接返回
	addi $t0, $zero, 0x71f
	beq  $t0, $a0, disp_ascii_ret #判断是否为下键，是则直接返回
	addi $t0, $zero, 0x71d
	beq  $t0, $a0, disp_ascii_ret #判断是否为左键，是则直接返回
	addi $t0, $zero, 0x71c
	beq  $t0, $a0, disp_ascii_ret #判断是否为右键，是则直接返回
	addi $t0, $zero, 0x70b
	beq  $t0, $a0, disp_ascii_ret #判断是否为HOME键，是则直接返回
	addi $t0, $zero, 0x71b
	beq  $t0, $a0, disp_ascii_ret #判断是否为ESC键，是则直接返回

	lw   $t0, 0x40($zero)
	andi $t1, $t0, 0x00ff #获取当前line字符数,存在$t1中
	addi $t2, $zero, 0x00ff
	beq  $t2, $t1, disp_ascii_ret #字符数已满255，直接返回

#-------------------------------------判断是否需要上移一行--------------------
	lw   $t0, 0x20($zero) #获取光标当前位置
	lw   $t3, 0x40($zero) #获取当前line字符数
	andi $t3, $t3, 0xff
	srl  $t1, $t0, 16
	andi $t1, $t1, 0x00ff #获取光标在当前line的位置
	sub  $t3, $t3, $t1 #计算光标后的字符数

	andi $t2, $t0, 0x7f #获取光标列
	andi $t0, $t0, 0x3f00 #获取光标行
	add  $t2, $t2, $t3 #列加上到行尾的距离

disp_TailXY:
	slti $t1, $t2, 0x50 #判断列数是否<80
	bne  $t1, $zero, disp_TailXY_next
	addi $t0, $t0, 0x100
	addi $t2, $t2, -80
	j    disp_TailXY 

disp_TailXY_next:
	addi $t2, $t2, 1 #列+1
	addi $t1, $zero, 0x50 #常量80
	bne  $t2, $t1, disp_go_on #没超出80，继续
	add  $t2, $zero, $zero
	addi $t0, $t0, 0x100 #行+1
	addi $t1, $zero, 0x3c00 #常数60
	bne  $t0, $t1, disp_go_on #行没超过60，返回

	addi $sp, $sp, -4
	sw   $ra, 0($sp)
	jal  Screen_move_up #清屏（换上移一行？）
	lw   $ra, 0($sp)
	addi $sp, $sp, 4



disp_go_on:
    #-----------------------------------------将光标后的字符均往后移一格----
	lw   $t3, 0x20($zero) #读取当前光标位置
	srl  $t3, $t3, 16 #右移16位
	andi $t3, $t3, 0x00ff #获取当前光标在line中的位置
	lw   $t2, 0x40($zero) #获取当前line字符数
	andi $t2, $t2, 0xff
	sub  $t3, $t2, $t3 #获取光标后面的字符数，即为循环常量
	sll  $t3, $t3, 2 #乘4

	lw   $t0, 0x20($zero) #读取当前光标位置
	andi $t1, $t0, 0x3f00 #获取光标行
	srl  $t2, $t1, 4 #行*16
	sll  $t1, $t2, 2 #行*64
	add  $t2, $t1, $t2 # $t2=行*80
	andi $t1, $t0, 0x007f
	add  $t2, $t1, $t2 # $t2 = 行*80+列
	sll  $t2, $t2, 2 # $t2 = (行*80+列)*4
	lui  $t0, 0x000c #vram首地址
	add  $t0, $t0, $t2 #vram中对应光标位置
	add  $t0, $t0, $t3 #vram中对应该line末地址

	addi $t3, $t3, 4 #算上光标位置上的字符

disp_ascii_shift:
	beq  $t3, $zero, disp_ascii_insert
	lw   $t1, 0($t0)
	sw   $t1, 4($t0)
	addi $t0, $t0, -4
	addi $t3, $t3, -4
	j    disp_ascii_shift

disp_ascii_insert:
	lw   $t0, 0x40($zero)
	andi $t1, $t0, 0x00ff #获取当前line字符数,存在$t1中
	addi $t0, $t0, 1 #未满，字符数+1
	sw   $t0, 0x40($zero)

	lw   $t0, 0x20($zero) #读取当前光标位置
	andi $t1, $t0, 0x3f00 #获取光标行
	srl  $t2, $t1, 4 #行*16
	sll  $t1, $t2, 2 #行*64
	add  $t2, $t1, $t2 # $t2=行*80
	andi $t1, $t0, 0x007f
	add  $t2, $t1, $t2 # $t2 = 行*80+列
	sll  $t2, $t2, 2 # $t2 = (行*80+列)*4
	lui  $t1, 0x000c
	add  $t2, $t1, $t2
	add  $t1, $zero, $a0 #要写入的ascii码
	sw   $t1, 0($t2)

	addi $sp, $sp, -4
	sw   $ra, 0($sp)
	jal  Cursor_move_F #调用cursor_move_f来移动光标
	lw   $ra, 0($sp)
	addi $sp, $sp, 4

	lw   $t3, 12($sp)
	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 16
	jr   $ra

#------------------disp_ascii过程中用于移动光标------------------
Cursor_move_F:
	addi $sp, $sp, -12
	sw   $t0, 0($sp)
	sw   $t1, 4($sp)
	sw   $t2, 8($sp)

	lw   $t0, 0x20($zero) #获取光标当前位置
	andi $t2, $t0, 0x7f #获取光标列
	addi $t2, $t2, 1 #列+1
	andi $t0, $t0, 0x3f00 #获取光标行
	addi $t1, $zero, 0x50 #常量80
	bne  $t2, $t1, Cursor_move_F_ret #没超出80，返回
	add  $t2, $zero, $zero
	addi $t0, $t0, 0x100 #行+1
	addi $t1, $zero, 0x3c00 #常数60
	bne  $t0, $t1, Cursor_move_F_ret #行没超过60，返回
	add  $t0, $zero, $zero #行清零

	addi $sp, $sp, -4
	sw   $ra, 0($sp)
	jal  Clear_screen #清屏（换上移一行？）
	lw   $ra, 0($sp)
	addi $sp, $sp, 4

	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 12
	jr   $ra

Cursor_move_F_ret:
	add  $t0, $t0, $t2
	lw   $t1, 0x20($zero)
	lui  $t2, 0x00ff
	and $t2, $t1, $t2 #获取光标在当前line的位置
	lui  $t1, 0x0001
	add  $t1, $t2, $t1 #光标在当前line中的位置+1
	add  $t0, $t1, $t0 #合成当前line的位置和全局位置
	sw   $t0, 0x20($zero)

	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 12
	jr   $ra

#---------------------------------------贪吃蛇----------------------------------------------------------
Snake:
#----------------------------初始化------------
	addi $sp, $sp, -28
	sw   $t0, 0($sp)
	sw   $t1, 4($sp)
	sw   $t2, 8($sp)
	sw   $t3, 12($sp)
	sw   $t4, 16($sp)
	sw   $t5, 20($sp)
	sw   $t6, 24($sp)



	addi $sp, $sp, -4
	sw   $ra, 0($sp)

Snake_restart:
	jal  Clear_screen #清屏

	lw   $t1, 0($s1) #读取sw开关状态
	andi $t1, $t1, 0x00ff  #取出末八位
	add  $t1, $t1, $t1 #左移两位对齐led输出(末两位为counter_set)
	add  $t1, $t1, $t1 #左移两位后计数器通道为00
	lui  $t2, 0x8000 #置gpiof0最高位为1，禁用光标
	or   $t1, $t1, $t2 #合并光标
	sw   $t1, 0($s1) #写入光标

#-------------------------------绘制边框--------------------
	lui  $t0, 0x000c
	addi $t1, $zero, 0x50 #循环常数80

Snake_top:
	addi $t2, $zero, 0x47f #红色的'■'
	sw   $t2, 0($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, -1
	bne  $t1, $zero, Snake_top

	addi $t1, $zero, 58 #循环常数58

Snake_side:
	sw   $t2, 0($t0)
	addi $t0, $t0, 0x13c #79*4
	sw   $t2, 0($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, -1
	bne  $t1, $zero, Snake_side

	addi $t1, $zero, 0x50 #循环常数80

Snake_bottom:
	addi $t2, $zero, 0x47f #红色的'■'
	sw   $t2, 0($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, -1
	bne  $t1, $zero, Snake_bottom

#----------开始游戏------------------------------
#    $sp 存放堆栈首地址(逆序存放,堆栈首是蛇尾节点), $t1存放蛇身长度, $t2存放当前移动方向, $t5存放蛇头横纵坐标, $t6最高位存放当前是否存在空格，低位存放坐标
Snake_start:
	lui  $t1, 0x000c
	addi $t1, $t1, 0x2620 #初始地址
	addi $t2, $zero, 0x77f #蛇为白色方块
	sw   $t2, 0($t1)
	sw   $t2, 320($t1) #初始有两个节点

	addi $sp, $sp, -8 #为初始蛇的两个节点申请空间存放其vram地址
	sw   $t1, 4($sp)
	addi $t1, $t1, 320
	sw   $t1, 0($sp)

	addi $t1, $zero, 8 #初始化蛇身长度为2*4
	addi $t2, $zero, 0 #初始化蛇移动方向为向上
	addi $t5, $zero, 0x1e28 #初始化横纵坐标为30行40列
	add  $t6, $zero, $zero #初始化没有方块

Snake_polling:
	jal  Random_block
	
	j    Snake_detect_eat_polling
Snake_sub_polling1:
	jal  Snake_move
Snake_sub_polling2:
	#jal  Key_scan
	lw   $t3, 0($s3) #读ps2键盘扫描码
	andi $t4, $t3, 0x100 #检查是否ready
	beq  $t4, $zero, Snake_polling #没有ready
	andi $t3, $t3, 0xff #去掉ready位得到扫描码

	#beq  $v0, $zero, Snake_polling
	#add  $s0, $zero, $v0  #当前返回值（有效扫描码）存入$s0, $a0
	#add  $a0, $zero, $s0 #与上面重复，可能disp_reg中用到了$a0
	#jal  Key2ascii #转换ascii码
	addi $t4, $zero, 0xf0 #扫描码 释放码
	beq  $t4, $t3, Snake_keyscan_f0 #
	
	addi $t4, $zero, 0x76 #扫描码 esc键
	beq  $t4, $t3, Snake_ret #退出程序

	addi $t4, $zero, 0x75 # 上键
	addi $a0, $zero, 0
	beq  $t4, $t3, Snake_Change_dir
	addi $t4, $zero, 0x6b # 左键
	addi $a0, $zero, 1
	beq  $t4, $t3, Snake_Change_dir
	addi $t4, $zero, 0x74 # 右键
	addi $a0, $zero, 2
	beq  $t4, $t3, Snake_Change_dir
	addi $t4, $zero, 0x72 # 下键
	addi $a0, $zero, 3
	beq  $t4, $t3, Snake_Change_dir

	addi $t4, $zero, 0x29 #扫描码 空格键
	beq  $t4, $t3, Snake_pause #暂停程序

Snake_Change_dir_back:
	j    Snake_polling

Snake_keyscan_f0:
	lw   $t3, 0($s3) #读ps2键盘扫描码
	andi $t4, $t3, 0x100 #检查是否ready
	beq  $t4, $zero, Snake_keyscan_f0 #没有ready
	j    Snake_sub_polling2


Snake_detect_eat_polling:
	jal  Snake_detect_eat
	beq  $v0, $zero, Snake_sub_polling1
	j    Snake_sub_polling2

Snake_Change_dir:
	add  $t3, $a0, $t2
	addi $t4, $zero, 3
	beq  $t3, $t4, Snake_Change_dir_back #不改变方向

	add  $t2, $a0, $zero #改变方向
	j    Snake_Change_dir_back



Snake_move:
	lui  $s4, 0xfffd #程序软件计数延时，时常数fffd0000
	Snake_move_delay:
	addi $s4, $s4, 1
	bne  $s4, $zero, Snake_move_delay

	lw   $t0, 0($sp) #获取蛇尾地址
	sw   $zero, 0($t0) #将蛇尾填成空白

	add  $t4, $t1, $zero #用于循环
	addi $t4, $t4, -4 #蛇头不需要循环
	add  $t3, $sp, $zero #堆栈首地址，蛇尾

Snake_move_loop:
	lw   $t0, 4($t3) #倒数第二个节点
	sw   $t0, 0($t3) #将其设为新蛇尾
	addi $t4, $t4, -4
	addi $t3, $t3, 4
	bne  $t4, $zero, Snake_move_loop #循环结束以后蛇头地址存在$t0中

	addi $t3, $zero, 0x0 #向上移动
	beq  $t2, $t3, Snake_move_up

	addi $t3, $zero, 0x1 #向左移动
	beq  $t2, $t3, Snake_move_left

	addi $t3, $zero, 0x2 #向右移动
	beq  $t2, $t3, Snake_move_right

	addi $t3, $zero, 0x3 #向下移动
	beq  $t2, $t3, Snake_move_down

Snake_move_up:
	andi $t3, $t5, 0x3f00 #获取纵坐标
	andi $t4, $t5, 0x7f #获取横坐标
	addi $t3, $t3, -256 #纵坐标-1
	beq  $t3, $zero, Snake_fail

	add  $t5, $t3, $t4 #更新蛇头位置

	srl  $t3, $t3, 4 #行*16
	sll  $t0, $t3, 2 #行*64
	add  $t3, $t0, $t3 # $t3=行*80
	add  $t3, $t3, $t4 # $t2 = 行*80+列
	sll  $t3, $t3, 2 # $t2 = (行*80+列)*4
	lui  $t0, 0x000c
	add  $t0, $t0, $t3 #新的蛇头vram地址
	addi $t3, $zero, 0x77f
	sw   $t3, 0($t0) #填入新的蛇头

	add  $t3, $sp, $t1 #蛇头在堆栈中的位置
	addi $t3, $t3, -4
	sw   $t0, 0($t3) #填入堆栈

	jr   $ra

Snake_move_left:
	andi $t3, $t5, 0x3f00 #获取纵坐标
	andi $t4, $t5, 0x7f #获取横坐标
	addi $t4, $t4, -1 #横坐标-1
	beq  $t4, $zero, Snake_fail

	add  $t5, $t3, $t4 #更新蛇头位置

	srl  $t3, $t3, 4 #行*16
	sll  $t0, $t3, 2 #行*64
	add  $t3, $t0, $t3 # $t3=行*80
	add  $t3, $t3, $t4 # $t2 = 行*80+列
	sll  $t3, $t3, 2 # $t2 = (行*80+列)*4
	lui  $t0, 0x000c
	add  $t0, $t0, $t3 #新的蛇头vram地址
	addi $t3, $zero, 0x77f
	sw   $t3, 0($t0) #填入新的蛇头

	add  $t3, $sp, $t1 #蛇头在堆栈中的位置
	addi $t3, $t3, -4
	sw   $t0, 0($t3) #填入堆栈

	jr   $ra

Snake_move_right:
	andi $t3, $t5, 0x3f00 #获取纵坐标
	andi $t4, $t5, 0x7f #获取横坐标
	addi $t4, $t4, 1 #横坐标+1
	addi $t0, $zero, 79
	beq  $t4, $t0, Snake_fail

	add  $t5, $t3, $t4 #更新蛇头位置

	srl  $t3, $t3, 4 #行*16
	sll  $t0, $t3, 2 #行*64
	add  $t3, $t0, $t3 # $t3=行*80
	add  $t3, $t3, $t4 # $t2 = 行*80+列
	sll  $t3, $t3, 2 # $t2 = (行*80+列)*4
	lui  $t0, 0x000c
	add  $t0, $t0, $t3 #新的蛇头vram地址
	addi $t3, $zero, 0x77f
	sw   $t3, 0($t0) #填入新的蛇头

	add  $t3, $sp, $t1 #蛇头在堆栈中的位置
	addi $t3, $t3, -4
	sw   $t0, 0($t3) #填入堆栈

	jr   $ra

Snake_move_down:
	andi $t3, $t5, 0x3f00 #获取纵坐标
	andi $t4, $t5, 0x7f #获取横坐标
	addi $t3, $t3, 256 #纵坐标+1
	addi $t0, $zero, 0x3b00
	beq  $t3, $t0, Snake_fail

	add  $t5, $t3, $t4 #更新蛇头位置

	srl  $t3, $t3, 4 #行*16
	sll  $t0, $t3, 2 #行*64
	add  $t3, $t0, $t3 # $t3=行*80
	add  $t3, $t3, $t4 # $t2 = 行*80+列
	sll  $t3, $t3, 2 # $t2 = (行*80+列)*4
	lui  $t0, 0x000c
	add  $t0, $t0, $t3 #新的蛇头vram地址
	addi $t3, $zero, 0x77f
	sw   $t3, 0($t0) #填入新的蛇头

	add  $t3, $sp, $t1 #蛇头在堆栈中的位置
	addi $t3, $t3, -4
	sw   $t0, 0($t3) #填入堆栈

	jr   $ra

#--------------------------随机生成方块-------------------------------------
Random_block:
	bne  $t6, $zero, Random_block_ret
	Random_block_y:
	lw   $t0, 4($s1) #从计时器读一个数
	andi $t3, $t0, 0x3f00 #获取纵坐标

	beq  $t3, $zero, Random_block_y
	slti $t0, $t3, 0x3b00
	beq  $t0, $zero, Random_block_y_fix

	Random_block_x:
	lw   $t0, 4($s1) #从计时器读一个数
	andi $t4, $t0, 0x7f #获取横坐标

	beq  $t4, $zero, Random_block_x
	slti $t0, $t4, 0x4f
	beq  $t0, $zero, Random_block_x_fix

Random_block_fix_ok:
	lui  $t6, 0x8000
	add  $t6, $t3, $t4 #生成新的方块坐标信息

	lui  $t4, 0x000c

	srl  $a0, $t3, 8

	addi $sp, $sp, -4
	sw   $ra, 0($sp)
	jal  ToDecimal #转换成10进制
	lw   $ra, 0($sp)
	addi $sp, $sp, 4

	andi $t0, $v0, 0xf
	addi $t0, $t0, 0x630
	sw   $t0, 8($t4)

	srl  $t0, $v0, 4
	addi $t0, $t0, 0x630
	sw   $t0, 4($t4)

	andi $a0, $t6, 0x7f

	addi $sp, $sp, -4
	sw   $ra, 0($sp)
	jal  ToDecimal #转换成10进制
	lw   $ra, 0($sp)
	addi $sp, $sp, 4

	andi $t0, $v0, 0xf
	addi $t0, $t0, 0x630
	sw   $t0, 20($t4)

	srl  $t0, $v0, 4
	addi $t0, $t0, 0x630
	sw   $t0, 16($t4)

	andi $t3, $t6, 0x3f00 #获取纵坐标
	andi $t4, $t6, 0x7f #获取横坐标

	srl  $t3, $t3, 4 #行*16
	sll  $t0, $t3, 2 #行*64
	add  $t3, $t0, $t3 # $t3=行*80
	add  $t3, $t3, $t4 # $t2 = 行*80+列
	sll  $t3, $t3, 2 # $t2 = (行*80+列)*4

	lui  $t0, 0x000c
	add  $t0, $t0, $t3 #生成随机block的vram地址
	lw   $t4, 0($t0) #读取随机生成的vram地址中的内容

	addi $t3, $zero, 0x77f
	beq  $t4, $t3, Random_block
	sw   $t3, 0($t0) #填入
Random_block_ret:
	
	jr   $ra

Random_block_y_fix:
	addi $t3, $t3, -8192
	j    Random_block_x
Random_block_x_fix:
	addi $t4, $t4, -60
	j    Random_block_fix_ok

#---------------------检测是否吃到方块-------------------------
Snake_detect_eat:
	add  $v0, $zero, $zero

	addi $t3, $zero, 0x0 #向上移动
	beq  $t2, $t3, Snake_detect_up

	addi $t3, $zero, 0x1 #向左移动
	beq  $t2, $t3, Snake_detect_left

	addi $t3, $zero, 0x2 #向右移动
	beq  $t2, $t3, Snake_detect_right

	addi $t3, $zero, 0x3 #向下移动
	beq  $t2, $t3, Snake_detect_down

Snake_detect_up:
	andi $t3, $t6, 0x3f7f #获取方块的坐标
	sub  $t3, $t5, $t3 #蛇头坐标减去方块坐标
	addi $t4, $zero, 0x0100
	sub  $t0, $t5, $t4

	bne  $t3, $t4, Snake_detect_eat_self #不相等，直接返回
	j    Snake_eat_shift

Snake_detect_left:
	andi $t3, $t6, 0x3f7f #获取方块的坐标
	sub  $t3, $t5, $t3 #蛇头坐标减去方块坐标
	addi $t4, $zero, 0x0001
	sub  $t0, $t5, $t4

	bne  $t3, $t4, Snake_detect_eat_self #不相等，直接返回
	j    Snake_eat_shift

Snake_detect_right:
	andi $t3, $t6, 0x3f7f #获取方块的坐标
	sub  $t3, $t3, $t5 #方块坐标减去蛇头坐标
	addi $t4, $zero, 0x0001
	add  $t0, $t5, $t4

	bne  $t3, $t4, Snake_detect_eat_self #不相等，直接返回
	j    Snake_eat_shift

Snake_detect_down:
	andi $t3, $t6, 0x3f7f #获取方块的坐标
	sub  $t3, $t3, $t5 #方块坐标减去蛇头坐标
	addi $t4, $zero, 0x0100
	add  $t0, $t5, $t4

	bne  $t3, $t4, Snake_detect_eat_self #不相等，直接返回

Snake_eat_shift:
	addi $sp, $sp, -4 #为新节点开空间

	add  $t4, $t1, $zero #用于循环
	#addi $t4, $t4, -4 #蛇头不需要循环
	add  $t3, $sp, $zero #堆栈首地址，蛇尾

Snake_eat_shift_loop:
	lw   $t0, 4($t3) #将原蛇尾地址存到新的栈首
	sw   $t0, 0($t3) #
	addi $t4, $t4, -4
	addi $t3, $t3, 4
	bne  $t4, $zero, Snake_eat_shift_loop #

	andi $t3, $t6, 0x3f00 #获取纵坐标
	andi $t4, $t6, 0x7f #获取横坐标

	add  $t5, $t3, $t4 #更新蛇头位置

	srl  $t3, $t3, 4 #行*16
	sll  $t0, $t3, 2 #行*64
	add  $t3, $t0, $t3 # $t3=行*80
	add  $t3, $t3, $t4 # $t2 = 行*80+列
	sll  $t3, $t3, 2 # $t2 = (行*80+列)*4
	lui  $t0, 0x000c
	add  $t0, $t0, $t3 #新的蛇头vram地址

	addi $t1, $t1, 4
	add  $t3, $sp, $t1 #蛇头在堆栈中的位置
	addi $t3, $t3, -4
	sw   $t0, 0($t3) #填入堆栈

	add  $t6, $zero, $zero
	addi $v0, $zero, 1

Snake_detect_eat_ret:
	jr   $ra

Snake_detect_eat_self:
	andi $t3, $t0, 0x3f00 #获取纵坐标
	andi $t4, $t0, 0x7f #获取横坐标

	srl  $t3, $t3, 4 #行*16
	sll  $t0, $t3, 2 #行*64
	add  $t3, $t0, $t3 # $t3=行*80
	add  $t3, $t3, $t4 # $t2 = 行*80+列
	sll  $t3, $t3, 2 # $t2 = (行*80+列)*4
	lui  $t0, 0x000c
	add  $t0, $t0, $t3 #下一个移动位置的vram地址

	lw   $t3, 0($sp) #读蛇尾位置
	beq  $t3, $t0, Snake_detect_eat_ret #是蛇尾则返回
	lw   $t3, 0($t0) #读取vram中的内容
	addi $t4, $zero, 0x77f
	beq  $t3, $t4, Snake_fail #该位置是方块，fail
	j    Snake_detect_eat_ret


Snake_fail:
	jal  Key_scan
	beq  $v0, $zero, Snake_fail
	add  $s0, $zero, $v0  #当前返回值（有效扫描码）存入$s0, $a0
	add  $a0, $zero, $s0 #与上面重复，可能disp_reg中用到了$a0
	jal  Key2ascii #转换ascii码

	addi $t3, $zero, 0x1b #ascii esc键
	beq  $v0, $t3, Snake_ret #退出程序

	addi $t3, $zero, 0x0d #ascii enter键
	beq  $v0, $t3, Snake_fail_restart #重启程序

	j    Snake_fail

Snake_fail_restart:
	add  $sp, $sp, $t1 #释放使用的堆栈
	j    Snake_restart


Snake_pause:
	lw   $t3, 0($s3) #读ps2键盘扫描码
	andi $t4, $t3, 0x100 #检查是否ready
	beq  $t4, $zero, Snake_pause #没有ready
	andi $t3, $t3, 0xff #去掉ready位
	addi $t4, $zero, 0xf0 #扫描码 f0
	bne  $t4, $t3, Snake_pause #暂停程序
Snake_pause1:
	lw   $t3, 0($s3) #读ps2键盘扫描码
	andi $t4, $t3, 0x100 #检查是否ready
	beq  $t4, $zero, Snake_pause1 #没有ready	
	andi $t3, $t3, 0xff #去掉ready位
	addi $t4, $zero, 0x29 #扫描码 空格键
	bne  $t4, $t3, Snake_pause #暂停程序
Snake_pause2:
	jal  Key_scan
	beq  $v0, $zero, Snake_pause2
	add  $s0, $zero, $v0  #当前返回值（有效扫描码）存入$s0, $a0
	add  $a0, $zero, $s0 #与上面重复，可能disp_reg中用到了$a0
	jal  Key2ascii #转换ascii码

	addi $t3, $zero, 0x20 #ascii 空格键
	beq  $v0, $t3, Snake_sub_polling2 #继续

	j    Snake_pause2

Snake_ret:
	add  $sp, $sp, $t1 #释放使用的堆栈

	jal  Clear_screen #清屏
	lw   $ra, 0($sp)
	addi $sp, $sp, 4

	lw   $t6, 24($sp)
	lw   $t5, 20($sp)
	lw   $t4, 16($sp)
	lw   $t3, 12($sp)
	lw   $t2, 8($sp)
	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 28
	jr   $ra

#------------------------转10进制(用于100以内)--------------------------
ToDecimal: #用$a0传递参数
	addi $sp, $sp, -8
	sw   $t0, 0($sp)
	sw   $t1, 4($sp)


	add  $t1, $zero, $zero # $t1存十位，初始为0
ToDecimal_loop:
	slti $t0, $a0, 10
	bne  $t0, $zero, ToDecimal_ret
	addi $a0, $a0, -10
	addi $t1, $t1, 1
	j    ToDecimal_loop
ToDecimal_ret:
	add  $v0, $t1, $zero
	sll  $v0, $v0, 4 #左移4位
	add  $v0, $v0, $a0

	lw   $t1, 4($sp)
	lw   $t0, 0($sp)
	addi $sp, $sp, 8
	jr   $ra