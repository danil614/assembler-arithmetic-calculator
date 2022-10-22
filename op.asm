.MODEL SMALL
.STACK 100h

.DATA
TitleMessage db 'EXPRESSION: 4 * A - 2 * (C + B)', 0Dh, 0Ah, '$'
OverflowMessage db 0Dh, 0Ah, 'OVERFLOW!$' ; 0Dh = 13d = \r = CR, 0Ah = 10d = \n = LF
ErrorNumberMessage db 0Dh, 0Ah, 'ERROR NUMBER!$'
EnterNumberA db 'Enter number A: $'
EnterNumberB db 'Enter number B: $'
EnterNumberC db 'Enter number C: $'
ResultNumber db 'Result number: $'

.CODE

; Получает число посимвольно с клавиатуры
; OUTPUT: AX
getNumber proc
	xor bx, bx ; для входного числа
	xor cx, cx ; флаг знака
	
	mov ah, 01h ; функция ввода нового символа
	int 21h ; вызов прерывания
	
	cmp al, '-' ; если нажали -, то отрицательное число
	jne notNegative
	mov cx, 1 ; cx := 1
	
	nextNumber:
		mov ah, 01h ; функция ввода нового символа
		int 21h

		cmp al, 0Dh ; если нажали enter, то это конец числа 
		je endNumber

	notNegative:
		cmp al, 30h ; если введен неверный символ < 0
		jl inputError
		cmp al, 39h ; если введен неверный символ > 9
		jg inputError
		
		and ax, 0Fh ; делаем из введенного символа число
		
		; ax - введенная цифра
		; bx - полное число
		xchg ax, bx ; (ax, bx) := (bx, ax)
		; ax - полное число
		; bx - введенная цифра
		
		mov dx, 0Ah ; dx := 10
		mul dx ; умножаем на основание системы счисления = 10, dx:ax := dx * ax
		
		call checkOverflow ; проверка переполнения
		
		add bx, ax ; прибавляем новое число, bx := bx + ax

		jmp nextNumber
	
	endNumber:
		mov ax, bx ; ax := bx
		cmp cx, 1 ; если cx = 1, то число отрицательное
		je negativeEnd
		ret
	
	negativeEnd:
		neg ax ; смена знака числа
		ret
	
	inputError:
		mov dx, offset ErrorNumberMessage
		call printMessage ; вывод сообщения
		call exitProgram

getNumber endp

; Печатает сообщение из регистра DX
; INPUT: DX
printMessage proc
	push ax
	
	mov ah, 09h ; номер прерывания
	int 21h ; вызов прерывания
	
	pop ax
	ret
printMessage endp

; Закрывает программу
exitProgram proc
	mov ax, 4C00h ; выход из программы
	int 21h
	ret
exitProgram endp

; Проверка на переполнение
checkOverflow proc
	jo overflowNumber ; проверка переполнения
	ret
	
	overflowNumber:
		mov dx, offset OverflowMessage
		call printMessage ; вывод сообщения
		call exitProgram
checkOverflow endp

; Печатает число из регистра AX
; INPUT: AX
printNumber proc
	; Проверяем число на знак.
	and ax, ax
	jns notNegative ; результат неотрицательный => notNegative

	; Если оно отрицательное, выведем минус и оставим его модуль.
	mov cx, ax
	mov ah, 02h
	mov dl, '-'
	int 21h
	mov ax, cx
	neg ax ; смена знака числа

	notNegative:
		xor cx, cx ; cx=0, счетчик
		mov bx, 0Ah ; перевод в 10-ую сс

	nextNumber:
		xor dx, dx ; dx = 0
		div bx ; ax mod bx -> dx, ax div bx -> ax
		push dx ; в стек
		inc cx ; +1
		and ax, ax
		jnz nextNumber ; переход по не равно нулю
		
	printFromStack:
		mov ah, 02h ; функция вывода символа
		pop dx
		or dl, 30h ; число в символ
		int 21h
		dec cx ; -1
		jnz printFromStack ; переход по не равно нулю
		ret
printNumber endp

main:
	mov ax, @data ; смещение для данных
	mov ds, ax ; указание сегмента данных
	
	mov dx, offset TitleMessage ; вывод заголовка программы
	call printMessage ; вывод сообщения
	
	; Ввод чисел A, B, C
	mov dx, offset EnterNumberA
	call printMessage ; вывод сообщения
	call getNumber
	push ax
	
	mov dx, offset EnterNumberB
	call printMessage ; вывод сообщения
	call getNumber
	push ax
	
	mov dx, offset EnterNumberC
	call printMessage ; вывод сообщения
	call getNumber
	push ax

	; Достаем из стека
	pop cx
	pop bx
	pop ax
	
	add bx, cx ; bx := bx + cx = b + c
	call checkOverflow ; проверка переполнения
	
	shl bx, 1 ; сдвиг влево => bx := bx * 2 = (b + c) * 2
	call checkOverflow ; проверка переполнения

	shl ax, 1 ; сдвиг влево => ax := ax * 2 = a * 2
	call checkOverflow ; проверка переполнения
	
	shl ax, 1 ; сдвиг влево => ax := ax * 2 = a * 4
	call checkOverflow ; проверка переполнения

	sub ax, bx ; ax := ax - bx = a * 4 - (b + c) * 2
	call checkOverflow ; проверка переполнения
	
	mov dx, offset ResultNumber
	call printMessage ; вывод сообщения
	call printNumber
	
	mov ax, 4C00h ; выход из программы
	int 21h
end main