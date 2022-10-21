.MODEL SMALL
.STACK 100h

.DATA
Message db 'Hello, world!$'

.CODE

start:

	mov ax, @data ; смещение для данных
	mov ds, ax ; указание сегмента данных
	
	mov dx, offset Message
	mov ah, 9h ; номер прерывания
	int 21h ; вызов прерывания
	
	mov ah, 8h ; ожидание ввода
	int 21h

	mov ax, 4C00h ; выход из программы
	int 21h

end start
