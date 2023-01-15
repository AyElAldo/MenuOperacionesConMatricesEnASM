
page 60, 130                                        ; Longitud: 60  -  Ancho: 130
title Menu de calculo de matrices                   ;

; ---------------------------------- MACROS ---------------------------------- ;

salirPrograma macro
    clrscr
    mov ah, 04ch
    mov al, 00
    int 21h  
endm 

                            ; ---- Limpia pantalla ---- ;
clrscr macro
    mov ah, 0Fh
    int 10h

    mov ah, 0
    int 10h
endm

                            ; ---- Posiciona cursor ---- ;
posicionaCursor macro fila, col
    mov dh, fila
    mov dl, col
    mov bh, 00

    mov ah, 02h
    int 10h
endm

                            ; ---- Oculta el cursor ---- ;
ocultaCursor macro 
    mov ah, 01h
    mov cx, 02607h
    int 10h
endm

                            ; ---- Muestra el cursor ---- ;
mostrarCursor macro
    mov cx, 607h
    mov ah, 01h
    int 10h
endm

                            ; ---- Imprime  ----;
imprimir macro cad
    mov dx, cad
    mov ah, 09h
    int 21h
endm

                            ; ---- Cambia color de la fuente ---- ;
;--- Color: (primer digito: pantalla, segundo digito: fuente)
;--- Inicio y Fin : Coordenadas      

cambiaColor macro color, iniF, iniC, finF, finC
    mov ah, 06h
    mov al, 00
    mov bh, color
    mov ch, iniF
    mov cl, iniC
    mov dh, finF
    mov dl, finC
    int 10h
endm

                            ; ---- Verificar puerto ---- ;
extraerPuerto60h macro scancode, salto
    in al, 60h
    cmp al, scancode
    je salto
endm 

extraerPuerto60h_jne macro scancode, salto
    in al, 60h
    cmp al, scancode
    jne salto
endm

extraerPuerto60h_jne_largo macro scancode, salto, Et1, Salida
    in al, 60h
    cmp al, scancode
    jne Et1
    jmp Salida
    Et1:
    jmp far ptr salto
    Salida:
endm

leerCadena macro guarda, tamano
     ; ----- Lee la cadena ------ ;
        mov ah, 3fh
        mov bx, 00
        mov cx, tamano
        mov dx, offset guarda
        int 21h
endm

; ------------------ Separa la cadena y la guarda en una matriz numerica -------------------- ;
separarCadena macro cadena, matriz, Iteracion, Siguiente, Siguiente2
    ; ---- Pasar cadena a numero --- ;

        mov si, offset cadena                           ; Apuntador al inicio de la cadena
        mov di, si                                      ; Si: Primer digito     Di: Recorre digitos
        mov bx, offset matriz                           ; bx: Apuntador a matriz (numero)

        mov aux, 00                                     ; aux: Auxiliar
        mov contador, 00                                ; contador: cuenta los elementos de la matriz
        
    Iteracion:
                    ; Recorre cada digito hasta llegar a la coma 
        inc di                                          ; Incrementa DI
        cmp byte ptr [di], 2Ch                          ; Compara con ','
        je Siguiente
        cmp byte ptr [di], 0Dh                          ; Compara con ENTER
        je Siguiente
        jmp Iteracion


    Siguiente:
        mov al, [si]
        mov aux, al                             ; Primer digito
        xor aux, 30h
        mov dx, di
        sub dx, si                              ; Comprueba tamano de digitos
        cmp dx, 01
        je Siguiente2
        mov al, 10
        mul aux
        mov aux, al
        inc si                                  ; Segundo digito
        mov al, [si]
        xor al, 30h
        add aux, al                             ; Obtiene el numero

    Siguiente2:
        mov al, aux
        mov [bx], al
        inc bx
        add si, 02
        inc contador
        cmp contador, 16 
        jne Iteracion


    ; --------------------------------- ;
endm

; --------------------------------- Reescribe la matriz a cadena --------------------------------- ;
matriz_a_ASCII macro matrizOrigen, matriz_convertida, Salto1, Salto2
    mov si, offset matrizOrigen
    mov di, offset matriz_convertida
    mov cx, 16
    mov contAux, 00                                 ; contAux: Cuenta elementos por fila
Salto2:
    xor ax, ax                                      ; Limpia registro ax
    mov al, [si]
    mov bl, DIEZ                                    ; Prepara bl para division
    div bl                                          ; Separa digitos 
    xor ax, 3030h                                   ; Convierte a ASCII
    mov [di], al
    inc di
    mov [di], ah
    inc di
    mov byte ptr [di], 20h                          ; 20h
    inc contAux
    cmp contAux, 04
    jne Salto1
    mov contAux, 00
    mov byte ptr [di], 24h
Salto1:
    inc di
    inc si
    loop Salto2
endm

; --------------------------------- Imprime la matriz en forma --------------------------------- ;
; DEBE DE INGRESAR LA MATRIZ CONVERTIDA

imprime_matriz macro matriz_convertida, fila, columna, Imprime, numFilas
    mov si, offset matriz_convertida
    mov aux, fila                                    ; Aux: Guarda fila de la posicion del cursor
    mov cx, numFilas                                 ; cx: Numero de filas

    Imprime:
    posicionaCursor aux, columna
    mov ah, 09
    mov dx, si
    int 21h
    add si, 12
    inc aux
    loop Imprime
endm

        ; ------------ Suma de matrices ---------- ;
sumaMatrices macro mat1, mat2, mat3
    mov bx, offset mat1
    mov si, offset mat2
    mov di, offset mat3

    mov cx, 16
    suma:
    mov al, [bx]
    add al, [si]
    mov [di], al
    inc bx
    inc si
    inc di
    loop suma
endm

; ------------- Transpuesta ------------- ;
obtenerTranspuesta macro matriz, respuesta
    mov bx, offset matriz 
    mov si, offset respuesta

    mov cx, 04
    mov [aux2], bx
    mov dx, 0
    jmp cambiarRenglon
    cambiarColumna:
    mov bx, [aux2]
    inc bx
    mov cx, 04
    mov [aux2], bx
    cambiarRenglon:
    mov al, [bx]
    mov [si], al
    add bx, 04
    add si, 01
    inc dx
    cmp dx, 16
    je continuar
    loop cambiarRenglon
    jmp cambiarColumna
    continuar:
endm

; --------------Sumar y obtener diagonal -------------- ;
suma_obtieneDiagonal macro matriz, vector, suma
    mov bx, offset matriz
    mov si, offset vector

    mov ah, [bx]
    mov [si], ah
    mov cx, 03
    sumarDiagonal:
        inc si
        add bx, 05
        mov dh, [bx]
        mov [si], dh
        add ah, [bx]
        loop sumarDiagonal
    mov [suma], ah
endm

; ------------------- SUMAR COLUMNAS ---------------- ;
sumarColumnas macro matriz, sumaCol
    mov bx, offset matriz
    mov si, offset sumaCol

    mov cx, 04
    mov [memoria], bx
    mov dh, 0
    jmp sumarColumna
    saltarColumna:
    mov bx, [memoria]
    inc bx
    mov cx, 04
    mov [memoria], bx
    sumarColumna:
    mov al, [bx]
    mov dl, 03 ; Parte baja DL es para sumar
    inc dh
    suma1:
    add bx, 04
    add al, [bx]
    dec dl
    cmp dl, 00
    jne suma1 
    mov [si], al
    inc si
    cmp dh, 04 ; Parte alta DH para romper el bucle infinito
    je continuar2
    loop saltarColumna
    continuar2:

endm

sumarRenglones macro matriz, vector
    mov bx, offset matriz
    mov si, offset vector

    mov cx, 04
    mov [memoria], bx
    mov dh, 0
    jmp sumaFila

    saltarRenglon:
    mov bx, [memoria]
    add bx, 04
    mov [memoria], bx
    mov cx, 04
    sumaFila:
    mov al, [bx]
    mov dl, 03 ; Parte baja DL es para sumar
    inc dh
    suma2:
    inc bx
    add al, [bx]
    dec dl
    cmp dl, 00
    jne suma2
    mov [si], al
    inc si
    cmp dh, 04 ; Romper bucle infinito (parte alta de DX)
    je continuar3
    loop saltarRenglon
    continuar3:

endm

; 1byte
; --------------------------------- FIN DE MACROS ------------------------------- ;
.286
.model small                                        ; code: 64k  -  data: 64k

; ------------------------------- CONSTANTES ------------------------------- ;

DIEZ equ 10

.stack 64                                           ; Tamaño de la pila 64 bytes

; ------------------------------- VARIABLES ------------------------------- ;

.data                                               ; DECLARACION DE VARIABLES
ubicar db 'AQUI TOY'                                ; Auxiliar para ubicar el comienzo del dataseg


                        ; -------- Variables reloj ----------;

cadenaHora db 'HH:MM:SS:CS', '$'                    ; Cadena que imprime la hora

; ---------------------------------------- Variables Menu ----------------------------------- ;
                        ; ------------- Enunciados ------------- ;

opcionA db 'A) Suma de dos matrices', '$'
opcionB db 'B) Obtener transpuesta', '$'
opcionC db 'C) Multiplicar matrices', '$'
opcionD db 'D) Obtener suma de diagonal principal', '$'
opcionE db 'E) Suma de columnas de una matriz', '$'
opcionF db 'F) Suma de renglones de una matriz', '$'


cadenaPideMatriz1 db 'Escribe la primera matriz: ', '$'
cadenaPideMatriz2 db 'Escribe la segunda matriz: ', '$'
cadenaRespuestaDiagonal db 'La suma de la diagonal es: ', '$'
cadenaRespuestaColumnas db 'La suma de las columnas es: ', '$'
cadenaRespuestaRenglones db 'La suma de los renglones es: ', '$'
presionaContinuar db ' --- Presiona I para mostrar resultado ---', '$'
presionaESC db ' --- Presiona ESC para salir al menu principal ---', '$'

cadenaSuma db '---------- SUMA DE MATRICES ---------', '$'
cadenaTranspuesta db '---------- MATRIZ TRANSPUESTA ---------', '$'
cadenaDiagonal db '------- SUMA DE LA DIAGONAL -------', '$'
cadenaColumnas db '------ SUMA DE LAS COLUMNAS ------', '$'
cadenaFilas db '------ SUMA DE LAS FILAS ------', '$'

; ------- Signos -------- ;
signoSuma db '+', '$'
signoResta db '-', '$'
signoIgual db '=', '$'
signoFlecha db '--->', '$'

                        ; -------- Variables Operaciones -----------;
cadMatriz1 db 66 dup(' '), '$'                      ; Contiene la cadena de la matriz1 que el usuario escriba
cadMatriz2 db 66 dup(' '), '$'                      ; Contiene la cadena de la matriz2 que el usuario escriba
matriz1 db 16 dup(' ')                              ; Contiene 
matriz2 db 16 dup(' ')
matriz1_convertida db 66 dup(' '), '$'              ; Matriz1 convertida a cadena
matriz2_convertida db 66 dup(' '), '$'              ; Matriz2 convertida a cadena
matrizRespuesta db 16 dup(' ')                      ; Contiene la respuesta numerica de cada operacion de las matrices
matrizRespuesta_convertida db 66 dup(' '), '$'      ; Respuesta de las matrices convertida a cadena
contAux db 0
aux db 0
aux2 dw 0
contador db 0
respuesta db 0
vector db 0,0,0,0
vector_convertido db 8 dup(' '), '$'
respuesta_convertida db 0,0,' ','$'
memoria dw 0

; ------------------------ Inicio del codigo ---------------------------- ;
.code                                               ; INICIO DE CODIGO
    Inicio proc far
        mov ax, @data
        mov ds, ax                                  ; Resolviendo segmento de datos
        mov es, ax                                  ; El segmento extra tambien se define 
                                                            
        clrscr                                      ; MACRO: Limpiar pantalla
        
        ocultaCursor                                ; MACRO: Oculta cursor

; -------------------------------------- MENU -------------------------------------- ;

; -- CON LA FINALIDAD DE AHORRAR MEMORIA, SE ESCRIBE PRIMERO EL MENU DADO QUE SON --
; -- SOLO CADENAS FIJAS, POR LO TANTO, NO SE TIENE QUE IMPRIMIR EN BUCLE          --
; -- SOLO SE USARAN LOS SALTOS AL RELOJ, YA QUE ES EL UNICO QUE CAMBIA EN LA      --
; -- PANTALLA PRINCIPAL                                                           --
    
    Menu_Principal proc far
        mov al, 00                                  ; Borra el ESC para que no finalice el programa
        out 60h, al 

; --------------------- Impresion de enunciados --------------------------- ;

                            ; --- Imprime opcionA --- ;
        cambiaColor 70h, 0,0,24,79                ; Color Menu
        cambiaColor 07h, 0,0,06,79                ; Color Reloj

        posicionaCursor 10, 25
        mov di, offset opcionA
        imprimir di
                            ; --- Imprime opcionB --- ;
        
        posicionaCursor 12, 25
        mov di, offset opcionB
        imprimir di
                            ; --- Imprime opcionC --- ;
        
        posicionaCursor 14, 25
        mov di, offset opcionC
        imprimir di
                            ; --- Imprime opcionD --- ;
        
        posicionaCursor 16, 25
        mov di, offset opcionD
        imprimir di
                            ; --- Imprime opcionE --- ;
        
        posicionaCursor 18, 25
        mov di, offset opcionE
        imprimir di
                            ; --- Imprime opcionF --- ;
        
        posicionaCursor 20, 25
        mov di, offset opcionF
        imprimir di
    endp

; ------------------------------------ RELOJ ------------------------------------ ;

    Anima proc far  

        mov ah, 2Ch                                 ; Interrupcion para obtener el tiempo del sistema
        int 21h

        ; ch : hora
        ; cl : minutos
        ; dh : segundos
        ; dl : centesimas

        ;;; CAST HORA ;;;
        xor ax, ax                                  ; Limpia ax

        mov al, ch                                  ; Numerador
        mov bx, DIEZ                                ; Denominador
        div bl                                      ; ah : residuo      al : cociente
        add al, 30h                                 ; Pasando a ASCII el cociente
        add ah, 30h                                 ; Pasando a ASCII el residuo

        mov si, offset cadenaHora                   ; Apuntador al inicio de la cadenaHora

        mov [si], al                                ; Pone la hora
        mov [si+1], ah                                    

        ;;; CAST MINUTOS ;;;
        xor ax, ax                                  ; Limpia ax

        mov al, cl                                  ; Numerador
        mov bx, DIEZ                                ; Denominador
        div bl                                      ; ah : residuo      al : cociente
        add al, 30h                                 ; Pasando a ASCII el cociente
        add ah, 30h                                 ; Pasando a ASCII el residuo
                                    
        mov [si+3], al                              ; Pone los minutos
        mov [si+4], ah                              

        ;;; CAST SEGUNDOS ;;;
        xor ax, ax                                  ; Limpia ax

        mov al, dh                                  ; Numerador
        mov bx, DIEZ                                ; Denominador
        div bl                                      ; ah : residuo      al : cociente
        add al, 30h                                 ; Pasando a ASCII el cociente
        add ah, 30h                                 ; Pasando a ASCII el residuo
                                    
        mov [si+6], al                              ; Pone los segundos
        mov [si+7], ah                          

        ;;; CAST CENTSIMAS DE SEGUNDO ;;;
        xor ax, ax                                  ; Limpia ax

        mov al, dl                                  ; Numerador
        mov bx, DIEZ                                ; Denominador
        div bl                                      ; ah : residuo      al : cociente
        add al, 30h                                 ; Pasando a ASCII el cociente
        add ah, 30h                                 ; Pasando a ASCII el residuo
                                    
        mov [si+9], al                              ; Pone las centesimas de segundo
        mov [si+10], ah                                              

        posicionaCursor 03, 35                      ; MACRO: Posiciona el cursor
        
        imprimir si                                 ; MACRO: Imprime la cadena en SI
        jmp Switch_Opciones

    Anima endp

; ---------------------------- Switch - Opciones ------------------------------ ;
    Switch_Opciones proc far
        in al, 60h                                  ; Puerto 60h a al
        cmp al, 01
        jne Switch_Siguiente
        salirPrograma
    Switch_Siguiente:
        cmp al, 1Eh                                 ; Opcion A
        je OpcionA_proc
        cmp al, 30h                                 ; Opcion B
        je OpcionB_aux
        cmp al, 2Eh                                 ; Opcion C
        je OpcionC_aux
        cmp al, 20h                                 ; Opcion D
        je OpcionD_aux 
        cmp al, 12h                                 ; Opcion E
        je OpcionE_aux
        cmp al, 21h                                 ; Opcion F
        je OpcionF_aux
        
        jmp Anima                                ;

; Al no haber saltos largos para saltos condicionales, nos ayudamos     ;
; de saltos incondicionales para hacer los saltos a los procedimientos  ;
; de cada opcion.                                                       ;

    OpcionB_aux:
        jmp far ptr OpcionB_proc
    OpcionC_aux:
        jmp far ptr OpcionC_proc
    OpcionD_aux:
        jmp far ptr OpcionD_proc
    OpcionE_aux:
        jmp far ptr OpcionE_proc
    OpcionF_aux:
        jmp far ptr opcionF_proc

    Switch_Opciones endp
;------------------------------------ FIN RELOJ ------------------------------------------;

; ------------------- OPCION A : SUMA MATRIZ---------------- ;

    OpcionA_proc proc far
        clrscr                                          ; MACRO: Limpia pantalla

        cambiaColor 10h, 0,0,24,79                      ; Color Menu
        cambiaColor 01h, 0,0,06,79                      ; Color Reloj

        posicionaCursor 03, 23                          ; Posiciona cursor
        mov si, offset cadenaSuma                       
        imprimir si                                     ; Imprime la opcion seleccionada

        posicionaCursor 09, 5
        mov si, offset cadenaPideMatriz1                ; SI: Pedir la cadena 1
        imprimir si
        leerCadena cadMatriz1, 66                       ; MACRO: Leer la cadena escrita por el usuario
 
        posicionaCursor 11, 5
        mov si, offset cadenaPideMatriz2                ; SI: Pedir la cadena 2
        imprimir si
        leerCadena cadMatriz2, 66                       ; MACRO: Leer la cadena escrita por el usuario

        separarCadena cadMatriz1, matriz1, OpcionA_Et1_1, OpcionA_Et2_1, OpcionA_Et3_1
        separarCadena cadMatriz2, matriz2, OpcionA_Et1_2, OpcionA_Et2_2, OpcionA_Et3_2

        sumaMatrices matriz1, matriz2, matrizRespuesta

    
        matriz_a_ASCII matriz1, matriz1_convertida, OpcionA_matriz_a_ASCII1_Salto1,OpcionA_matriz_a_ASCII1_Salto2
        matriz_a_ASCII matriz2, matriz2_convertida, OpcionA_matriz_a_ASCII2_Salto1, OpcionA_matriz_a_ASCII2_Salto2
        matriz_a_ASCII matrizRespuesta, matrizRespuesta_convertida, OpcionA_matriz_a_ASCII3_Salto1, OpcionA_matriz_a_ASCII3_Salto2
   
    OpcionA_Imprime_Operacion:
        ocultaCursor

        imprime_matriz matriz1_convertida, 17, 10, OpcionA_Imprime1_Salto1, 4
        posicionaCursor 18, 25
        mov si, offset signoSuma
        imprimir si
        imprime_matriz matriz2_convertida, 17, 30, OpcionA_Imprime2_Salto1, 4
        
        
        posicionaCursor 14, 22                   ; Muestra PRESIONA I PARA CONTINUAR 
        mov si, offset presionaContinuar
        imprimir si

        extraerPuerto60h_jne 17h, OpcionA_Imprime_Operacion  ; Espera letra I

    OpcionA_Impresion:              

        posicionaCursor 14, 15                  ; Muestra PRESIONA ESC
        mov si, offset presionaESC
        imprimir si

        posicionaCursor 18, 48
        mov si, offset signoIgual
        imprimir si
        imprime_matriz matrizRespuesta_convertida, 17, 55, OpcionA_Imprime3_Salto1, 4

        extraerPuerto60h_jne 01, OpcionA_Impresion              ; Si no es ESC, vuelve a imprimir
        jmp far ptr Menu_Principal

    OpcionA_proc endp 

; ------------------- OPCION B : TRANSPUESTA MATRIZ ---------------- ;

    OpcionB_proc proc far
    
        clrscr                                      ; MACRO: Limpia pantalla

        cambiaColor 20h, 0,0,24,79                      ; Color Menu
        cambiaColor 02h, 0,0,06,79 

        posicionaCursor 03, 20                          ; Posiciona cursor
        mov si, offset cadenaTranspuesta                      ; Imprime la opcion seleccionada
        imprimir si 

        posicionaCursor 09, 5
        mov si, offset cadenaPideMatriz1
        imprimir si
        leerCadena cadMatriz1, 66                       ; Lee la cadena

        separarCadena cadMatriz1, matriz1, OpcionB_Et1_1, OpcionB_Et2_1, OpcionB_Et3_1
        obtenerTranspuesta matriz1, matrizRespuesta
        matriz_a_ASCII matriz1, matriz1_convertida, OpcionB_matriz_a_ASCII1_Salto1,OpcionB_matriz_a_ASCII1_Salto2
        matriz_a_ASCII matrizRespuesta, matrizRespuesta_convertida, OpcionB_matriz_a_ASCII2_Salto1,OpcionB_matriz_a_ASCII2_Salto2

    OpcionB_Imprime_Operacion:
        ocultaCursor

        imprime_matriz matriz1_convertida, 17, 15, OpcionB_Imprime1_Salto1, 4     ; Imprime matriz
       

        posicionaCursor 14, 22                   ; Muestra PRESIONA I PARA CONTINUAR 
        mov si, offset presionaContinuar
        imprimir si

        extraerPuerto60h_jne 17h, OpcionB_Imprime_Operacion  ; Espera letra I

    OpcionB_Impresion:
        
        posicionaCursor 14, 15                   ; Muestra PRESIONA ESC PARA CONTINUAR 
        mov si, offset presionaESC
        imprimir si

        posicionaCursor 18, 37
        mov si, offset signoFlecha
        imprimir si

        imprime_matriz matrizRespuesta_convertida, 17, 50, OpcionB_Imprime2_Salto1, 4

        extraerPuerto60h_jne 01, OpcionB_Impresion
        jmp far ptr Menu_Principal

    OpcionB_proc endp

; ------------------- OPCION C : MULTIPLICAR MATRIZ ---------------- ;
    OpcionC_proc proc far

        clrscr                                      ; MACRO: Limpia pantalla
        salirPrograma

    OpcionC_proc endp

; ------------------- OPCION D : SUMA DIAGONAL ---------------- ;
    OpcionD_proc proc far

        clrscr                                      ; MACRO: Limpia pantalla

        cambiaColor 30h, 0,0,24,79                      ; Color Menu
        cambiaColor 03h, 0,0,06,79

        posicionaCursor 03, 20                          ; Posiciona cursor
        mov si, offset cadenaDiagonal                   ; Imprime la opcion seleccionada
        imprimir si  

        posicionaCursor 09, 5
        mov si, offset cadenaPideMatriz1
        imprimir si
        leerCadena cadMatriz1, 66

        separarCadena cadMatriz1, matriz1, OpcionD_Et1_1, OpcionD_Et2_1, OpcionD_Et3_1
        suma_obtieneDiagonal matriz1, vector, respuesta
        matriz_a_ASCII matriz1, matriz1_convertida, OpcionD_matriz_a_ASCII1_Salto1,OpcionD_matriz_a_ASCII1_Salto2
        matriz_a_ASCII vector, vector_convertido, OpcionD_matriz_a_ASCII2_Salto1,OpcionD_matriz_a_ASCII2_Salto2

    OpcionD_Imprime_Operacion:
        ocultaCursor
        imprime_matriz matriz1_convertida, 17, 33, OpcionD_Imprime1_Salto1, 4

        posicionaCursor 14, 22                   ; Muestra PRESIONA I PARA CONTINUAR 
        mov si, offset presionaContinuar
        imprimir si

        extraerPuerto60h_jne 17h, OpcionD_Imprime_Operacion  ; Espera letra I

    OpcionD_impresion:

        posicionaCursor 14, 19                   ; Muestra PRESIONA ESC PARA CONTINUAR 
        mov si, offset presionaESC
        imprimir si

    ; Hace CAST de numero a ASCII
        mov si, offset respuesta_convertida
        xor ax, ax
        mov al, respuesta                        ; Dividendo
        ;mov bl, 100                             ; Prepara division
        ;div bl                                  ; Divide
        ;xor al, 30h                             
        ;mov [si], al
        ;inc si
        ;mov al, ah
        ;xor ah, ah
        mov bl, 10
        div bl
        xor al, 30h
        mov [si], al
        inc si
        xor ah, 30h
        mov [si], ah

        posicionaCursor 23, 25
        mov si, offset cadenaRespuestaDiagonal
        imprimir si

        mov si, offset respuesta_convertida
        imprimir si

        extraerPuerto60h_jne_largo 01, OpcionD_Impresion, OpcionD_Et1, OpcionD_Sal1
        jmp far ptr Menu_Principal

    OpcionD_proc endp

; ------------------- OPCION E : SUMA DE COLUMNAS ---------------- ;
    OpcionE_proc proc far

        clrscr                                      ; MACRO: Limpia pantalla

        cambiaColor 50h, 0,0,24,79                      ; Color Menu
        cambiaColor 05h, 0,0,06,79

        posicionaCursor 03, 22
        mov si, offset cadenaColumnas
        imprimir si

        posicionaCursor 09, 05
        mov si, offset cadenaPideMatriz1
        imprimir si
        leerCadena cadMatriz1, 66

        separarCadena cadMatriz1, matriz1, OpcionE_Et1_1, OpcionE_Et2_1, OpcionE_Et3_1
        sumarColumnas matriz1, vector
        matriz_a_ASCII matriz1, matriz1_convertida, OpcionE_matriz_a_ASCII1_Salto1,OpcionE_matriz_a_ASCII1_Salto2
        matriz_a_ASCII vector, vector_convertido, OpcionE_matriz_a_ASCII2_Salto1,OpcionE_matriz_a_ASCII2_Salto2

    OpcionE_Imprime_Operacion:
        ocultaCursor
        imprime_matriz matriz1_convertida, 14, 33, OpcionE_Imprime1_Salto1, 4

        posicionaCursor 12, 22
        mov si, offset presionaContinuar
        imprimir si

        extraerPuerto60h_jne 17h, OpcionE_Imprime_Operacion         ; Espera la letra I
    
    OpcionE_Impresion:

        posicionaCursor 12, 16
        mov si, offset presionaESC
        imprimir si

        posicionaCursor 19, 30
        mov si, offset cadenaRespuestaColumnas
        imprimir si

        imprime_matriz vector_convertido, 21, 35, OpcionE_Imprime2_Salto1, 1

        extraerPuerto60h_jne_largo 01, OpcionE_Impresion, OpcionE_Et1, OpcionE_Sal1
        jmp far ptr Menu_Principal
    OpcionE_proc endp

; ------------------- OPCION F : SUMA DE RENGLONES ---------------- ;
    OpcionF_proc proc far

        clrscr                                      ; MACRO: Limpia pantalla

        cambiaColor 60h, 0,0,24,79                      ; Color Menu
        cambiaColor 06h, 0,0,06,79

        posicionaCursor 03, 24
        mov si, offset cadenaFilas
        imprimir si

        posicionaCursor 09,05
        mov si, offset cadenaPideMatriz1
        imprimir si
        leerCadena cadMatriz1, 66

        separarCadena cadMatriz1, matriz1, OpcionF_Et1_1, OpcionF_Et2_1, OpcionF_Et3_1
        sumarRenglones matriz1, vector
        matriz_a_ASCII matriz1, matriz1_convertida, OpcionF_matriz_a_ASCII1_Salto1,OpcionF_matriz_a_ASCII1_Salto2
        matriz_a_ASCII vector, vector_convertido, OpcionF_matriz_a_ASCII2_Salto1,OpcionF_matriz_a_ASCII2_Salto2

    OpcionF_Imprime_Operacion:

        ocultaCursor
        imprime_matriz matriz1_convertida, 14, 33, OpcionF_Imprime1_Salto1, 4

        posicionaCursor 12, 22
        mov si, offset presionaContinuar
        imprimir si

        extraerPuerto60h_jne 17h, OpcionF_Imprime_Operacion         ; Espera la letra I
    
    OpcionF_Impresion:

        posicionaCursor 12, 16
        mov si, offset presionaESC
        imprimir si

        posicionaCursor 20, 26
        mov si, offset cadenaRespuestaRenglones
        imprimir si

        imprime_matriz vector_convertido, 22, 33, OpcionF_Imprime2_Salto1, 1
        extraerPuerto60h_jne_largo 01, OpcionF_Impresion, OpcionF_Et1, OpcionF_Sal1
        jmp far ptr Menu_Principal

    OpcionF_proc endp

; ------------------------ SALIDA DEL PROGRAMA --------------------------- ;
salirPrograma
Inicio endp
end Inicio 