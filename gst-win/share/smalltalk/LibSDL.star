PK
     �Mh@M9��  �    SDL_endian.stUT	 dqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlEndian
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlEndian class methodsFor: 'C call-outs'!

sdlReadLE16: aCobject0 
    "I read an item of the specified endianness and answer in native
    format. My C function call prototype:

    extern DECLSPEC Uint16 SDLCALL SDL_ReadLE16(SDL_RWops *src);"
    <cCall: 'SDL_ReadLE16' returning: #uInt
        args: #( #cObject  )>!

sdlReadBE16: aCobject0 
    "I read an item of the specified endianness and answer in native
    format. My C function call prototype:

     extern DECLSPEC Uint16 SDLCALL SDL_ReadBE16(SDL_RWops *src);"
    <cCall: 'SDL_ReadBE16' returning: #uInt
        args: #( #cObject  )>!

sdlReadLE32: aCobject0 
    "I read an item of the specified endianness and answer in native
    format. My C function call prototype:

     extern DECLSPEC Uint32 SDLCALL SDL_ReadLE32(SDL_RWops *src);"
    <cCall: 'SDL_ReadLE32' returning: #uInt
        args: #( #cObject  )>!

sdlReadBE32: aCobject0 
    "I read an item of the specified endianness and answer in native
    format. My C function call prototype:

     extern DECLSPEC Uint32 SDLCALL SDL_ReadBE32(SDL_RWops *src);"
    <cCall: 'SDL_ReadBE32' returning: #uInt
        args: #( #cObject  )>!

sdlReadLE64: aCobject0 
    "I read an item of the specified endianness and answer in native
    format. My C function call prototype:

     extern DECLSPEC Uint64 SDLCALL SDL_ReadLE64(SDL_RWops *src);"
    <cCall: 'SDL_ReadLE64' returning: #uLong
        args: #( #cObject  )>!

sdlReadBE64: aCobject0 
    "I read an item of the specified endianness and answer in native
    format. My C function call prototype:

     extern DECLSPEC Uint64 SDLCALL SDL_ReadBE64(SDL_RWops *src);"
    <cCall: 'SDL_ReadBE64' returning: #uLong
        args: #( #cObject  )>!

sdlWriteLE16: aCobject0 value: aUshort
    "I write an item of native format to the specified endianness. My
    C function call prototype:

    extern DECLSPEC int SDLCALL SDL_WriteLE16(SDL_RWops *dst, Uint16 value);"
    <cCall: 'SDL_WriteLE16' returning: #int 
        args: #( #cObject #uInt )>!

sdlWriteBE16: aCobject0 value: aUshort
    "I write an item of native format to the specified endianness. My
    C function call prototype:

     extern DECLSPEC int SDLCALL SDL_WriteBE16(SDL_RWops *dst, Uint16 value);"
    <cCall: 'SDL_WriteBE16' returning: #int 
        args: #( #cObject #uInt )>!

sdlWriteLE32: aCobject0 value: aUint
    "I write an item of native format to the specified endianness. My
    C function call prototype:

    extern DECLSPEC int SDLCALL SDL_WriteLE32(SDL_RWops *dst, Uint32 value);"
    <cCall: 'SDL_WriteLE32' returning: #int 
        args: #( #cObject #uInt )>!

sdlWriteBE32: aCobject0 value: aUint
    "I write an item of native format to the specified endianness. My
    C function call prototype:

    extern DECLSPEC int SDLCALL SDL_WriteBE32(SDL_RWops *dst, Uint32 value);"
    <cCall: 'SDL_WriteBE32' returning: #int 
        args: #( #cObject #uInt )>!

sdlWriteLE64: aCobject0 value: aUlong
    "I write an item of native format to the specified endianness. My
    C function call prototype:

    extern DECLSPEC int SDLCALL SDL_WriteLE64(SDL_RWops *dst, Uint64 value);"
    <cCall: 'SDL_WriteLE64' returning: #int 
       args: #( #cObject #uLong )>!

sdlWriteBE64: aCobject0 value: aUlong
    "I write an item of native format to the specified endianness. My
    C function call prototype:

    extern DECLSPEC int SDLCALL SDL_WriteBE64(SDL_RWops *dst, Uint64 value);"
    <cCall: 'SDL_WriteBE64' returning: #int 
        args: #( #cObject #uLong )>! !
PK
     �Mh@ɗX�      SDL_rwops.stUT	 eqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlRWOps
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlRWOps class methodsFor: 'C call-outs'!

sdlRWFromFile: aString0 mode: aString1 
    "extern DECLSPEC SDL_RWops * SDLCALL SDL_RWFromFile(const char *file, 
         const char *mode);"
    <cCall: 'SDL_RWFromFile' returning: #cObject 
        args: #( #string #string  )>!

sdlRWFromFp: aCobject0 autoClose: aInt1 
    "extern DECLSPEC SDL_RWops * SDLCALL SDL_RWFromFP(FILE *fp, 
         int autoclose);"
    <cCall: 'SDL_RWFromFP' returning: #cObject 
        args: #( #cObject #int  )>!

sdlRWFromMem: aCobject0 size: aInt1 
    "extern DECLSPEC SDL_RWops * SDLCALL SDL_RWFromMem(void *mem, 
         int size);"
    <cCall: 'SDL_RWFromMem' returning: #cObject 
        args: #( #cObject #int  )>!

sdlRWFromConstMem: aCobject0 size: aInt1 
    "extern DECLSPEC SDL_RWops * SDLCALL SDL_RWFromConstMem(const void *mem, 
         int size);"
    <cCall: 'SDL_RWFromConstMem' returning: #cObject 
        args: #( #cObject #int  )>!

sdlAllocRW
    "extern DECLSPEC SDL_RWops * SDLCALL SDL_AllocRW(void);"
    <cCall: 'SDL_AllocRW' returning: #cObject 
        args: #( )>!

sdlFreeRW: aCobject0
    "extern DECLSPEC void SDLCALL SDL_FreeRW(SDL_RWops *area);"
    <cCall: 'SDL_FreeRW' returning: #void 
        args: #( #cObject )>! !
PK
     �Mh@U�c�  �    SDL_name.stUT	 eqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlName
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlName class methodsFor: 'Constants'!

needFunctionProtoTypes
    ^1! !
PK
     �Mh@����  �    SDL_syswm.stUT	 eqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlSysWM
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlSysWMMsg
    declaration: #(
        (#version (#ptr #CObject))
        (#data #int))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlSysWMInfo
    declaration: #(
        (#version (#ptr #CObject))
        (#data #int))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlSysWM class methodsFor: 'c wrappers'!

sdlGetWMInfo: aCobject0
    "extern DECLSPEC int SDLCALL SDL_GetWMInfo(SDL_SysWMinfo *info);"
    <cCall: 'SDL_GetWMInfo' returning: #int 
        args: #( #cObject )>! !
PK
     �Mh@+(��0  0    SDL_joystick.stUT	 dqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlJoystick
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlJoystick class methodsFor: 'Constants'!

sdlHatCentered
    ^16r00!

sdlHatUp
    ^16r01!

sdlHatRight
    ^16r02!

sdlHatDown
    ^16r04!

sdlHatLeft
    ^16r08!

sdlHatRightUp
    ^16r03!

sdlHatRightDown
    ^16r06!

sdlHatLeftUp
    ^16r09!

sdlHatLeftDown
    ^16r0c!

!SdlJoystick class methodsFor: 'C call-outs'!

sdlNumJoysticks
    "I answer the number of joysticks attached to the system. My C
    function prototype:

    extern DECLSPEC int SDLCALL SDL_NumJoysticks(void);"
    <cCall: 'SDL_NumJoysticks' returning: #int 
        args: #( )>!

sdlJoystickName: aInt0
    "I answer the name of a joystick. My C function call prototype:

    extern DECLSPEC const char * SDLCALL SDL_JoystickName(int device_index);"
    <cCall: 'SDL_JoystickName' returning: #string 
        args: #( #int )>!

sdlJoystickOpen: aInt0 
    "I open the the system joystick instance given to me. My C
    function call prototype:

    extern DECLSPEC SDL_Joystick * SDLCALL SDL_JoystickOpen(int device_index);"
    <cCall: 'SDL_JoystickOpen' returning: #cObject 
        args: #( #int  )>!

sdlJoystickOpened: aInt0
    "I answer whether or not the system joystick instance given to me
    is open. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_JoystickOpened(int device_index);"
    <cCall: 'SDL_JoystickOpened' returning: #int 
        args: #( #int )>!

sdlJoystickIndex: aCobject0
    "I answer the device index of an opened joystick. My C function
    call prototype:

    extern DECLSPEC int SDLCALL SDL_JoystickIndex(SDL_Joystick *joystick);"
    <cCall: 'SDL_JoystickIndex' returning: #int 
        args: #( #cObject )>!

sdlJoystickNumAxes: cObject
    "I answer the number of general axis controls on a joystick. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_JoystickNumAxes(SDL_Joystick *joystick);"
    <cCall: 'SDL_JoystickNumAxes' returning: #int 
        args: #( #cObject )>!

sdlJoystickNumBalls: aCobject0
    "I answer the number of balls on a joystick. My C function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_JoystickNumBalls(SDL_Joystick *joystick);"
    <cCall: 'SDL_JoystickNumBalls' returning: #int 
        args: #( #cObject )>!

sdlJoystickNumHats: aCobject0
    "I answer the number of hats on a joystick. My C function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_JoystickNumHats(SDL_Joystick *joystick);"
    <cCall: 'SDL_JoystickNumHats' returning: #int 
        args: #( #cObject )>!

sdlJoystickNumButtons: aCobject0
    "I answer the number of buttonss on a joystick. My C function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_JoystickNumButtons(SDL_Joystick *joystick);"
    <cCall: 'SDL_JoystickNumButtons' returning: #int 
        args: #( #cObject )>!

sdlJoystickUpdate
    "I update the current state of the open joysticks. My C function
    call prototype:

    extern DECLSPEC void SDLCALL SDL_JoystickUpdate(void);"
    <cCall: 'SDL_JoystickUpdate' returning: #void 
        args: #( #void)>!

sdlJoystickEventState: aInt0
    "I enable or disable joystick event polling. My C function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_JoystickEventState(int state);"
    <cCall: 'SDL_JoystickEventState' returning: #int 
        args: #( #int )>!

sdlJoystickGetAxis: aCobject0 axis: aInt1 
    "I answer the current state of an axis control on a joystick. My C function call prototype:

    extern DECLSPEC Sint16 SDLCALL SDL_JoystickGetAxis(SDL_Joystick *joystick, int axis);"
    <cCall: 'SDL_JoystickGetAxis' returning: #int
        args: #( #cObject #int  )>!

sdlJoystickGetHat: aCobject0 hat: aInt1 
    "I answer the current state of the hat on a joystick. My C function call prototype:

    extern DECLSPEC Uint8 SDLCALL SDL_JoystickGetHat(SDL_Joystick *joystick, int hat);"
    <cCall: 'SDL_JoystickGetHat' returning: #char 
        args: #( #cObject #int  )>!

sdlJoystickGetBall: aCobject0 ball: aInt1 dx: aCobject2 dy: aCobject3
    "I answer the ball axis change since the last poll. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_JoystickGetBall(SDL_Joystick *joystick, int ball, int *dx, int *dy);"
    <cCall: 'SDL_JoystickGetBall' returning: #int 
        args: #( #cObject #int #cObject #cObject )>!

sdlJoystickGetButton: aCobject0 button: aInt1 
    "I answer the current state of a button on a joystick. My C function call prototype:

    extern DECLSPEC Uint8 SDLCALL SDL_JoystickGetButton(SDL_Joystick *joystick, int button);"
    <cCall: 'SDL_JoystickGetButton' returning: #char
        args: #( #cObject #int  )>!

sdlJoystickClose: aCobject0
   "I close a previously opened joystick. My C function call prototype: 

    extern DECLSPEC void SDLCALL SDL_JoystickClose(SDL_Joystick *joystick);"
    <cCall: 'SDL_JoystickClose' returning: #void 
        args: #( #cObject )>! !
PK
     �Mh@�����  �    SDL.stUT	 dqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #Sdl
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!Sdl class methodsFor: 'Constants'!

sdlInitTimer
    ^16r00000001!

sdlInitAudio
    ^16r00000010!

sdlInitVideo
    ^16r00000020!

sdlInitCdrom
    ^16r00000100!

sdlInitJoystick
    ^16r00000200!

sdlInitNoParachute
    ^16r00100000!

sdlInitEventThread
    ^16r01000000!

sdlInitEverything
    ^16r0000FFFF!

!Sdl class methodsFor: 'C call-outs'!

sdlForkEventLoop: aBlock
    "Execute aBlock within an SDL event loop.  Returns only when
     #sdlStopEventLoop is called, but forks aBlock in a separate Smalltalk
     process."

    | s |
    s := Semaphore new.
    self sdlStartEventLoop: [
	[aBlock ensure: [s signal]] fork].
    s wait!

sdlStartEventLoop: aBlock
    "Execute aBlock within an SDL event loop.  Returns only #sdlStopEventLoop
     is called, but calls aBlock."

    <cCall: 'SDL_StartEventLoop' returning: #void 
        args: #( #smalltalk )>!

sdlStopEventLoop
    "Tell SDL to stop the event loop."

    <cCall: 'SDL_StopEventLoop' returning: #void 
        args: #( )>!

sdlInit: aUint
    "I Initialize SDL. My c function call prototype:

    extern DECLSPEC int SDLCALL SDL_Init(Uint32 flags);"
    <cCall: 'SDL_Init' returning: #int 
        args: #( #uInt )>!

sdlInitSubSystem: aUint
    "I can initialize uninitialized subsystems My c function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_InitSubSystem(Uint32 flags);"
    <cCall: 'SDL_InitSubSystem' returning: #int 
        args: #( #uInt )>!

sdlQuitSubSystem
    "I shut down a subsystem that has been previously initialized by
    SDL_Init or SDL_InitSubSystem. My c function call prototype is:

    extern DECLSPEC void SDLCALL SDL_QuitSubSystem(Uint32 flags);"
    <cCall: 'SDL_QuitSubSystem' returning: #void 
        args: #( #uInt )>!

sdlWasInit: aCobject0 
    "I answer which SDL subsytems have been initialized. My c function
    call prototype is:

     extern DECLSPEC Uint32 SDLCALL SDL_WasInit(Uint32 flags);"
    <cCall: 'SDL_WasInit' returning: #int 
        args: #( #uInt  )>!

sdlQuit
    "I shut down all SDL subsystems and free the resources allocated
    to them. My c function call prototype is:

     extern DECLSPEC void SDLCALL SDL_Quit(void);"
    <cCall: 'SDL_Quit' returning: #void 
        args: #( )>! !
PK
     �[h@d9�_&  &    package.xmlUT	 ӉXOӉXOux �  �  <package>
  <name>LibSDL</name>
  <namespace>SDL</namespace>
  <library>libSDL</library>
  <module>sdl</module>

  <filein>SDL.st</filein>
  <filein>SDL_active.st</filein>
  <filein>SDL_byteorder.st</filein>
  <filein>SDL_cpuinfo.st</filein>
  <filein>SDL_endian.st</filein>
  <filein>SDL_error.st</filein>
  <filein>SDL_events.st</filein>
  <filein>SDL_joystick.st</filein>
  <filein>SDL_keyboard.st</filein>
  <filein>SDL_keysym.st</filein>
  <filein>SDL_loadso.st</filein>
  <filein>SDL_mouse.st</filein>
  <filein>SDL_mutex.st</filein>
  <filein>SDL_name.st</filein>
  <filein>SDL_rwops.st</filein>
  <filein>SDL_syswm.st</filein>
  <filein>SDL_thread.st</filein>
  <filein>SDL_timer.st</filein>
  <filein>SDL_video.st</filein>
  <filein>Display.st</filein>
  <filein>EventSource.st</filein>
</package>PK
     �Mh@>�`Z�  �    SDL_byteorder.stUT	 dqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlByteOrder
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlByteOrder class methodsFor: 'Constants'!

sdlLilEndian
    ^1234!

sdlBigEndian
    ^4321!

sdlByteOrder
    ^4321! !
PK
     �Mh@(�/q      SDL_mutex.stUT	 dqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlMutex
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlMutex class methodsFor: 'Constants'!

sdlMutexTimedOut
    ^1!

sdlMutexMaxWait
    ^-1!

!SdlMutex class methodsFor: 'C call-outs'!

sdlCreateMutex
    "I create a mutex, initialized unlocked. My C function call
    prototype:

    extern DECLSPEC SDL_mutex * SDLCALL SDL_CreateMutex(void);"
    <cCall: 'SDL_CreateMutex' returning: #cObject 
        args: #( )>!

sdlMutexP: aCobject0
    "I Lock the mutex given to me. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_mutexP(SDL_mutex *mutex);"
    <cCall: 'SDL_mutexP' returning: #int 
        args: #( #cObject )>!

sdlMutexV: aCobject0
    "I unlock the mutex given to me. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_mutexV(SDL_mutex *mutex);"
    <cCall: 'SDL_mutexV' returning: #int  
        args: #( #cObject )>!

sdlDestroyMutex: aCobject0
    "I destroy the mutex given to me. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_DestroyMutex(SDL_mutex *mutex);"
    <cCall: 'SDL_DestroyMutex' returning: #void 
        args: #( #cObject )>!

sdlCreateSemaphore: aUint
    "I create a semaphore, initialized with value. My C function call
    prototype:

    extern DECLSPEC SDL_sem * SDLCALL SDL_CreateSemaphore(Uint32 initial_value);"
    <cCall: 'SDL_CreateSemaphore' returning: #cObject 
        args: #( #uInt  )>!

sdlDestroySemaphore: aCobject0
    "I destroy the semaphore given to me. My C function call
    prototype:

    extern DECLSPEC void SDLCALL SDL_DestroySemaphore(SDL_sem *sem);"
    <cCall: 'SDL_DestroySemaphore' returning: #void 
        args: #( #cObject )>!

sdlSemWait: aCobject0
    "I suspend the calling thread until the semaphore given to me has
    a positive count. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_SemWait(SDL_sem *sem);"
    <cCall: 'SDL_SemWait' returning: #int 
        args: #( #cObject )>!

sdlSemTryWait: aCobject0
    "I answer whether or the the semaphore given to me has a positive
    count. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_SemTryWait(SDL_sem *sem);"
    <cCall: 'SDL_SemTryWait' returning: #int 
        args: #( #cObject )>!

sdlSemWaitTimeout: aCobject0 ms: aUint
    "I suspend the calling thread until the semaphore given to me has
    a positive count or the timeout given to me occurs. My C function
    call prototype:

    extern DECLSPEC int SDLCALL SDL_SemWaitTimeout(SDL_sem *sem, Uint32 ms);"
    <cCall: 'SDL_SemWaitTimeout' returning: #int 
        args: #( #cObject #uInt )>!

sdlSemPost: aCobject0
    "I atomically increase the count of the semaphore given to me. My
    C function call prototype:

    extern DECLSPEC int SDLCALL SDL_SemPost(SDL_sem *sem);"
    <cCall: 'SDL_SemPost' returning: #int 
        args: #( #cObject )>!

sdlSemValue: aCobject0 
    "I answer the current count of the semaphore given to me. My C
    function call prototype:

     extern DECLSPEC Uint32 SDLCALL SDL_SemValue(SDL_sem *sem);"
    <cCall: 'SDL_SemValue' returning: #uInt 
        args: #( #cObject  )>!

sdlCreateCond
    "I create a condition variable. My C function call prototype:

    extern DECLSPEC SDL_cond * SDLCALL SDL_CreateCond(void);"
    <cCall: 'SDL_CreateCond' returning: #cObject 
        args: #( )>!

sdlDestroyCond: aCobject0
    "I destroy a condition variable. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_DestroyCond(SDL_cond *cond);"
    <cCall: 'SDL_DestroyCond' returning: #void 
        args: #( #cObject )>!

sdlCondSignal: aCobject0
    "I restart the thread that is waiting on the condition variable
    given to me. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_CondSignal(SDL_cond *cond);"
    <cCall: 'SDL_CondSignal' returning: #int 
        args: #( #cObject )>!

sdlCondBroadcast: aCobject0
    "I restart all threads that are waiting on the condition variable
    given to me. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_CondBroadcast(SDL_cond *cond);"
    <cCall: 'SDL_CondBroadcast' returning: #int 
        args: #( #cObject )>!

sdlCondWait: aCobject0 mutex: aCobject1
    "I wait on the condition variable given to me, unlocking the mutex
    given to me. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_CondWait(SDL_cond *cond, SDL_mutex *mut);"
    <cCall: 'SDL_CondWait' returning: #int 
        args: #( #cObject #cObject )>!

sdlCondWaitTimeOut: aCobject0 mutex: aCobject1 ms: aUint
    "I wait up to the number of ms given to me on the condition
    variable given to me, unlocking the mutex given to me. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_CondWaitTimeout(SDL_cond *cond, 
         SDL_mutex *mutex, Uint32 ms);"
    <cCall: 'SDL_CondWaitTimeout' returning: #int 
        args: #( #cObject #cObject #uInt )>! !
PK
     �Mh@�p���  �    SDL_active.stUT	 dqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlActive
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlActive class methodsFor: 'Constants'!

sdlAppMouseFocus
    ^16r01!

sdlAppInputFocus
    ^16r02!

sdlAppActive
    ^16r04!

!SdlActive class methodsFor: 'C call-outs'!

sdlGetAppState
    "I answer the current state of the application. My C function call
    prototype:

    extern DECLSPEC Uint8 SDLCALL SDL_GetAppState(void);"
    <cCall: 'SDL_GetAppState' returning: #char
        args: #( )>! !
PK
     �Mh@�P{�-#  -#    SDL_events.stUT	 dqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlEvents
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlEvent
    declaration: #()
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlGenericEvent
    declaration: #(
        (#type #uchar)
        (#filler (#array #uchar 256)))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlActiveEvent
    declaration: #(
        (#type #uChar)
        (#gain #uChar)
        (#state #uChar))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlKeyBoardEvent
    declaration: #(
        (#type #uChar)
        (#which #uChar)
        (#state #uChar)
	(#unused #uChar)
        (#scanCode #uchar)
        (#sym #int)
        (#mod #int)
        (#unicode #uShort))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlMouseMotionEvent
    declaration: #(
        (#type #uChar)
        (#which #uChar)
        (#state #uChar)
        (#x #uShort)
        (#y #uShort)
        (#xRel #uShort)
        (#yRel #uShort))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlMouseButtonEvent
    declaration: #(
        (#type #uChar)
        (#which #uChar)
        (#button #uChar)
        (#state #uChar)
        (#x #uShort)
        (#y #uShort))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlJoyAxisEvent
    declaration: #(
        (#type #uChar)
        (#which #uChar)
        (#axis #uChar)
        (#value #short))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlJoyBallEvent
    declaration: #(
        (#type #uChar)
        (#which #uChar)
        (#ball #uChar)
        (#xrel #short)
        (#yrel #short))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlJoyHatEvent
    declaration: #(
        (#type #uChar)
        (#which #uChar)
        (#hat #uChar)
        (#value #uChar))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlJoyButtonEvent
    declaration: #(
        (#type #uChar)
        (#which #uChar)
        (#button #uChar)
        (#state #uChar))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlResizeEvent
    declaration: #(
        (#type #uChar)
        (#w #int)
        (#h #int))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlExposeEvent
    declaration: #(
        (#type #uChar))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlQuitEvent
    declaration: #(
        (#type #uChar))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlUserEvent
    declaration: #(
        (#type #uChar)
        (#code #int)
        (#data1 (#ptr #CObject))
        (#data2 (#ptr #CObject)))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

SdlEvent subclass: #SdlSysWmEvent
    declaration: #(
        (#type #uChar)
        (#msg (#ptr #CObject)))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlEvents class methodsFor: 'Constants'!

sdlNoEvent
    ^0!

sdlActiveEvent
    ^1!

sdlKeyDown
    ^2!

sdlKeyUp
    ^3!

sdlMouseMotion
    ^4!

sdlMouseButtonDown
    ^5!

sdlMouseButtonUp
    ^6!

sdlJoyAxisMotion
    ^7!

sdlJoyBallMotion
    ^8!

sdlJoyHatMotion
    ^9!

sdlJoyButtonDown
    ^10!

sdlJoyButtonUp
    ^11!

sdlQuit
    ^12!

sdlSysWMEvent
    ^13!

sdlEventReservedA
    ^14!

sdlEventReservedB
    ^15!

sdlVideoResize
    ^16!

sdlVideoExpose
    ^17!

sdlEventReserved2
    ^18!

sdlEventReserved3
    ^19!

sdlEventReserved4
    ^20!

sdlEventReserved5
    ^21!

sdlEventReserved6
    ^22!

sdlEventReserved7
    ^23!

sdlUserEvent
    ^24!

sdlNumEvents
    ^32!

sdlActiveEventMask
    ^(1 bitShift: 1)!

sdlKeyDownMask
    ^1 bitShift: 2!

sdlKeyUpMask
    ^1 bitShift: 3!

sdlMouseMotionMask
    ^1 bitShift: 4!

sdlMouseButtonDownMask
    ^1 bitShift: 5!

sdlMouseButtonUpMask
    ^1 bitShift: 6!

sdlMouseEventMask
    ^((1 bitShift: 4) bitOr: (1 bitShift: 5)) bitOr: (1 bitShift: 6)!

sdlJoyAxisMotionMask
    ^1 bitShift: 7!

sdlJoyBallMotionMask
    ^1 bitShift: 8!

sdlJoyHatMotionMask
    ^1 bitShift: 9!

sdlJoyButtonDownMask
    ^1 bitShift: 10!

sdlJoyButtonUpMask
    ^1 bitShift: 11!

sdlJoyEventMask
    ^((((1 bitShift: 7) bitOr: (1 bitShift: 8)) bitOr: (1 bitShift: 9)) bitOr: (1 bitShift: 10)) bitOr: (1 bitShift: 11)!

sdlVideoResizeMask
    ^1 bitShift: 16!

sdlVideoExposeMask
    ^1 bitShift: 17!

sdlUserMask
    ^1 bitShift: 24!

sdlQuitMask
    ^1 bitShift: 12!

sdlSysWMEventMask
    ^1 bitShift: 13!

sdlAllEvents
    ^16rFFFFFFFF!

sdlAddEvent
    ^0!

sdlPeekEvent
    ^1!

sdlGetEvent
    ^2!

sdlQuery
    ^-1!

sdlIgnore
    ^0!

sdlDisable
    ^0!

sdlEnable
    ^1!

!SdlEvents class methodsFor: 'C call-outs'!

sdlPumpEvents
    "I gather events from the input devices. My C function call
    prototype:

    extern DECLSPEC void SDLCALL SDL_PumpEvents(void);"
    <cCall: 'SDL_PumpEvents' returning: #void 
        args: #( )>!

sdlPeepEvents: aCobject0 numEvents: aInt1 action: aInt3 mask: aUint4
    "I check the event queue for messages. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_PeepEvents(SDL_Event *events, 
         int numevents, SDL_eventaction action, Uint32 mask);"
    <cCall: 'SDL_PeepEvents' returning: #int 
        args: #( #cObject #int #int #uInt )>!

sdlPollEvent: aCobject0
    "I poll for currently pending events, and answer whether or not
    there are. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_PollEvent(SDL_Event *event);"
    <cCall: 'SDL_PollEvent' returning: #int 
        args: #( #cObject )>!

sdlWaitEvent: aCobject0
    "I wait indefinitely for the next available event, and answer
    whether or not an error occured while waiting for it. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_WaitEvent(SDL_Event *event);"
    <cCall: 'SDL_WaitEvent' returning: #int 
        args: #( #cObject )>!

sdlPushEvent: aCobject0
    "I add an event to the event queue. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_PushEvent(SDL_Event *event);"
    <cCall: 'SDL_PushEvent' returning: #int 
        args: #( #cObject )>!

sdlSetEventFilter: aCobject0
    "I set up a an internal event queue filter to process all events. My
    C function call prototype:

    extern DECLSPEC void SDLCALL SDL_SetEventFilter(SDL_EventFilter filter);"
    <cCall: 'SDL_SetEventFilter' returning: #void 
        args: #( #cObject )>!

sdlGetEventFilter
    "I answer wituh the current event filter. My C function call
    prototype:

    extern DECLSPEC SDL_EventFilter SDLCALL SDL_GetEventFilter(void);"
    <cCall: 'SDL_GetEventFilter' returning: #cObject 
        args: #( )>!

sdlEventState: aCobject0 state: aInt1 
    "I configure how events will be presented. My C function call prototype:

    extern DECLSPEC Uint8 SDLCALL SDL_EventState(Uint8 type, int state);"
    <cCall: 'SDL_EventState' returning: #cObject 
        args: #( #cObject #int  )>! !
PK
     �Mh@�n�K9	  9	    SDL_error.stUT	 dqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlError
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlError class methodsFor: 'Constants'!

sdlEnoMem
    ^0!

sdlEfRead
    ^1!

sdlEfWrite
    ^2!

sdlEfSeek
    ^3!

sdlLastError
    ^4!

sdlSetError: aString0 args1: aVariadic1
    "extern DECLSPEC void SDLCALL SDL_SetError(const char *fmt, ...);"
    <cCall: 'SDL_SetError' returning: #void 
        args: #( #string #variadic )>!

sdlGetError
    "extern DECLSPEC char * SDLCALL SDL_GetError(void);"
    <cCall: 'SDL_GetError' returning: #string 
        args: #( )>!

sdlClearError
    "extern DECLSPEC void SDLCALL SDL_ClearError(void);"
    <cCall: 'SDL_ClearError' returning: #void 
        args: #( )>!

sdlError: aInt0
    "extern DECLSPEC void SDLCALL SDL_Error(SDL_errorcode code);"
    <cCall: 'SDL_Error' returning: #void 
        args: #( #int )>! !
PK
     �Mh@���Ǥ  �    SDL_mouse.stUT	 dqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlMouse
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlCursor
    declaration: #(
        (#area (#ptr #CObject))
        (#hotX #short)
        (#hotY #short)
        (#data (#ptr #CObject))
        (#mask (#ptr #CObject))
        (#save (#ptr #CObject))
        (#wmCursor (#ptr #CObject)))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlMouse class methodsFor: 'Constants'!

sdlButtonLeft
    ^1!

sdlButtonMiddle
    ^2!

sdlButtonRight
    ^3!

sdlButtonWheelUp
    ^4!

sdlButtonWheelDown
    ^5!

sdlButtonLMask
    ^16r01!

sdlButtonMMask
    ^16r02!

sdlButtonRMask
    ^16r04!

!SdlMouse class methodsFor: 'C call-outs'!

sdlGetMouseState: aCobject0 y: aCobject1 
    "I answer the current state of the mouse. The C function call
    prototype:

    extern DECLSPEC Uint8 SDLCALL SDL_GetMouseState(int *x, int *y);"
    <cCall: 'SDL_GetMouseState' returning: #char 
        args: #( #cObject #cObject  )>!

sdlGetRelativeMouseState: aCobject0 y: aCobject1 
    "I answer the current state of the mouse. The C function call
    prototype:

    extern DECLSPEC Uint8 SDLCALL SDL_GetRelativeMouseState(int *x, int *y);"
    <cCall: 'SDL_GetRelativeMouseState' returning: #char
        args: #( #cObject #cObject  )>!

sdlWarpMouse: aInt0 y: aInt1
    "I set the position of the mouse cursor. My C function call
    prototype:

    extern DECLSPEC void SDLCALL SDL_WarpMouse(Uint16 x, Uint16 y);"
    <cCall: 'SDL_WarpMouse' returning: #void 
        args: #( #int #int )>!

sdlCreateCursor: aCobject0 mask: aCobject1 w: aInt2 h: aInt3 hotX: aInt4 hotY: aInt5 
    "I create a cursor using the data and mask given to me. My C
    function call prototype:

    extern DECLSPEC SDL_Cursor * SDLCALL SDL_CreateCursor (Uint8 *data, Uint8 *mask, int w, int h, int hot_x, int hot_y);"
    <cCall: 'SDL_CreateCursor' returning: #cObject 
        args: #( #cObject #cObject #int #int #int #int  )>!

sdlSetCursor: aCobject0
    "I set the currently active cursor to the one given to me. My C
    function call prototype:

    extern DECLSPEC void SDLCALL SDL_SetCursor(SDL_Cursor *cursor);"
    <cCall: 'SDL_SetCursor' returning: #void 
        args: #( #cObject )>!

sdlGetCursor
    "I answer the currently active cursor. My C function call
    prototype:

    extern DECLSPEC SDL_Cursor * SDLCALL SDL_GetCursor(void);"
    <cCall: 'SDL_GetCursor' returning: #cObject 
        args: #( )>!

sdlFreeCursor: aCobject0
    "I deallocate a cursor created with SDL_CreateCursor(). My C
    function call prototype:

    extern DECLSPEC void SDLCALL SDL_FreeCursor(SDL_Cursor *cursor);"
    <cCall: 'SDL_FreeCursor' returning: #void 
        args: #( #cObject )>!

sdlShowCursor: aInt0
    "I toggle whether or not the cursor is shown on the screen. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_ShowCursor(int toggle);"
    <cCall: 'SDL_ShowCursor' returning: #int 
        args: #( #int )>! !
PK
     �Mh@ΡX�@_  @_    SDL_video.stUT	 eqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlVideo
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlRect
    declaration: #(
        (#x #short)
        (#y #short)
        (#w #ushort)
        (#h #ushort))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlColor
    declaration: #(
        (#r #char)
        (#g #char)
        (#b #char)
        (#unused #char))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlPalette
    declaration: #(
        (#ncolors #int)
        (#colors (#ptr #CObject)))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlPixelformat
    declaration: #(
        (#palette (#ptr #{SdlPalette}))
        (#bitsPerPixel #char)
        (#bytesPerPixel #char)
        (#rLoss #char)
        (#gLoss #char)
        (#bLoss #char)
        (#aLoss #char)
        (#rShift #char)
        (#gShift #char)
        (#bShift #char)
        (#aShift #char)
        (#rMask #uInt)
        (#gMask #uInt)
        (#bMask #uInt)
        (#aMask #uInt)
        (#colorKey #uInt)
        (#alpha #char))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlSurface
    declaration: #(
        (#flags #uInt)
        (#format (#ptr #{SdlPixelformat}))
        (#w #int)
        (#h #int)
        (#pitch #ushort)
        (#pixels (#ptr #CObject))
        (#offset #int)
        (#hwData (#ptr #CObject))
        (#clipRect #{SdlRect})
        (#unused1 #uInt)
        (#locked #uInt)
        (#map (#ptr #CObject))
        (#formatVersion #uInt)
        (#refCount #int))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !
CStruct subclass: #SdlVideoInfo
    declaration: #(
        (#hwAvailable #uInt)
        (#wmAvailable #uInt)
        (#unusedBits1 #uInt)
        (#unusedBits2 #uInt)
        (#blitHw #uInt)
        (#blitHwCc #uInt)
        (#blitHwA #uInt)
        (#blitSw #uInt)
        (#blitSwCc #uInt)
        (#blitSwA #uInt)
        (#blitFill #uInt)
        (#unusedBits3 #uInt)
        (#videoMem #uInt)
        (#vFmt (#ptr #CObject)))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlOverlay
    declaration: #(
        (#format #uInt)
        (#w #int)
        (#h #int)
        (#planes #int)
        (#pitches (#ptr #CObject))
        (#pixels (#ptr #CObject))
        (#hwFuncs (#ptr #CObject))
        (#hwData (#ptr #CObject))
        (#hwOverlay #uInt)
        (#unusedBits #uInt))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlVideo class methodsFor: 'Constants'!

sdlAlphaOpaque
    ^255!

sdlAlphaTransparent
    ^0!

sdlSwSurface
    ^16r00000000!

sdlHwSurface
    ^16r00000001!

sdlAsyncBlit
    ^16r00000004!

sdlAnyFormat
    ^16r10000000!

sdlHwPalette
    ^16r20000000!

sdlDoubleBuf
    ^16r40000000!

sdlFullScreen
    ^16r80000000!

sdlOpenGL
    ^16r00000002!

sdlOpenGLBlit
    ^16r0000000A!

sdlResizable
    ^16r00000010!

sdlNoFrame
    ^16r00000020!

sdlHwAccel
    ^16r00000100!

sdlSrcColorKey
    ^16r00001000!

sdlRleAccelOk
    ^16r00002000!

sdlRleAccel
    ^16r00004000!

sdlSrcAlpha
    ^16r00010000!

sdlPreAlloc
    ^16r01000000!

sdlYV12Overlay
    ^16r32315659!

sdlIYUVOverlay
    ^16r56555949!

sdlYUY2Overlay
    ^16r32595559!

sdlUYVYOverlay
    ^16r59565955!

sdlYVYUOverlay
    ^16r55595659!

sdlGLRedSize
    ^0!

sdlGLGreenSize
    ^1!

sdlGLBlueSize
    ^2!

sdlGLAlphaSize
    ^3!

sdlGLBufferSize
    ^4!

sdlGLDoublebuffer
    ^5!

sdlGLDepthSize
    ^6!

sdlGLStencilSize
    ^7!

sdlGLAccumRedSize
    ^8!

sdlGLAccumGreenSize
    ^9!

sdlGLAccumBlueSize
    ^10!

sdlGLAccumAlphaSize
    ^11!

sdlGLStereo
    ^12!

sdlGLMultiSampleBuffers
    ^13!

sdlGLMultiSampleSamples
    ^14!

sdlLogPal
    ^16r01!

sdlPhysPal
    ^16r02!

sdlGrabQuery
    ^-1!

sdlGrabOff
    ^0!

sdlGrabOn
    ^1!

sdlGrabFullscreen
    ^0!

!SdlVideo class methodsFor: 'C call-outs'!

sdlVideoInit: aString0 flags: aUint1
    "I initialize the video subsystem. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_VideoInit(const char *driver_name, 
         Uint32 flags);"
    <cCall: 'SDL_VideoInit' returning: #int 
        args: #( #string #uInt )>!

sdlVideoQuit
    "I shutdown the video subsystem. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_VideoQuit(void);"
    <cCall: 'SDL_VideoQuit' returning: #void 
        args: #( )>!

sdlVideoDriverName: aString0 maxLen: aInt1
    "I answer with the name of the video driver. My C function call
    prototype:

    extern DECLSPEC char * SDLCALL SDL_VideoDriverName(char *namebuf, 
         int maxlen);"
    <cCall: 'SDL_VideoDriverName' returning: #string 
        args: #( #string #int )>!

sdlGetVideoSurface
    "I answer a pointer to the current display surface. My C function
    call prototype:

     extern DECLSPEC SDL_Surface * SDLCALL SDL_GetVideoSurface(void);"
    <cCall: 'SDL_GetVideoSurface' returning: #{SdlSurface}
        args: #( )>!

sdlGetVideoInfo
    "I answer with a pointer to information about the video
    hardware. My C function call prototype:

    extern DECLSPEC const SDL_VideoInfo * SDLCALL SDL_GetVideoInfo(void);"
    <cCall: 'SDL_GetVideoInfo' returning: #{SdlVideoInfo}
        args: #( )>!

sdlVideoModeOk: aInt0 height: aInt1 bpp: aInt2 flags: aUint3
    "I answer whether or not a particular video mode is supported. My
    C function call prototype:

    extern DECLSPEC int SDLCALL SDL_VideoModeOK(int width, int height, 
         int bpp, Uint32 flags);"
    <cCall: 'SDL_VideoModeOK' returning: #int 
        args: #( #int #int #int #int )>!

sdlListModes: aCobject0 flags: aUint1
    "I return a pointer to an array of available screen dimensions for
    the given format and video flags, sorted largest to smallest. My C
    function call prototype:

    extern DECLSPEC SDL_Rect ** SDLCALL SDL_ListModes(SDL_PixelFormat *format, 
         Uint32 flags);"
    <cCall: 'SDL_ListModes' returning: #cObjectPtr
        args: #( #cObject #uInt  )>!

sdlSetVideoMode: aInt0 height: aInt1 bpp: aInt2 flags: aUint3 
    "I set up a video mode with the specified width, height and
    bits-per-pixel. My C function call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL SDL_SetVideoMode (int width, int height, 
         int bpp, Uint32 flags);"
    <cCall: 'SDL_SetVideoMode' returning: #{SdlSurface}
        args: #( #int #int #int #uInt  )>!

sdlUpdateRects: aCobject0 numRects: aInt1 rects: aCobject2
    "I update a list of rectangles. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_UpdateRects (SDL_Surface *screen, int numrects, 
         SDL_Rect *rects);"
    <cCall: 'SDL_UpdateRects' returning: #void 
        args: #( #cObject #int #cObject )>!

sdlUpdateRect: aCobject0 x: aInt1 y: aInt2 w: aInt3 h: aInt4
    "I update the entire screen. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_UpdateRect (SDL_Surface *screen, Sint32 x, 
         Sint32 y, Uint32 w, Uint32 h);"
    <cCall: 'SDL_UpdateRect' returning: #void 
        args: #( #cObject #int #int #int #int )>!

sdlFlip: aCobject0
    "I set up a flip and return on hardware that supports
    double-buffering, or perform a SDL_UpdateRect on hardware that
    doesn't. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_Flip(SDL_Surface *screen);"
    <cCall: 'SDL_Flip' returning: #int 
        args: #( #cObject )>!

sdlSetGamma: aFloat0 green: aFloat1 blue: aFloat2
    "I set the gamma correction for each of the color channels. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_SetGamma(float red, float green, float blue);"
    <cCall: 'SDL_SetGamma' returning: #int 
        args: #( #float #float #float )>!

sdlSetGammaRamp: aCobject0 green: aCobject1 blue: aCobject2
    "I set the gamma translation table for the red, green, and blue
    channels of the video hardware. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_SetGammaRamp(const Uint16 *red, 
         const Uint16 *green, const Uint16 *blue);"
    <cCall: 'SDL_SetGammaRamp' returning: #int 
        args: #( #cObject #cObject #cObject )>!

sdlGetGammaRamp: aCobject0 green: aCobject1 blue: aCobject2
    "I retrieve the current values of the gamma translation tables. My
    C function call prototype:

    extern DECLSPEC int SDLCALL SDL_GetGammaRamp(Uint16 *red, 
         Uint16 *green, Uint16 *blue);"
    <cCall: 'SDL_GetGammaRamp' returning: #int 
        args: #( #cObject #cObject #cObject )>!

sdlSetColors: aCobject0 colors: aCobject1 firstColor: aInt2 nColors: aInt3
    "I set a portion of the colormap for the given 8-bit surface. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_SetColors(SDL_Surface *surface, 
         SDL_Color *colors, int firstcolor, int ncolors);"
    <cCall: 'SDL_SetColors' returning: #int 
        args: #( #cObject #cObject #int #int )>!

sdlSetPalette: aCobject0 flags: aInt1 colors: aCobject2 firstColor: aInt3 nColors: aInt4
    "I set a portion of the colormap for a given 8-bit surface. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_SetPalette(SDL_Surface *surface, 
         int flags, SDL_Color *colors, int firstcolor, int ncolors);"
    <cCall: 'SDL_SetPalette' returning: #int 
        args: #( #cObject #int #cObject #int #int )>!

sdlMapRGB: aCobject0 r: aChar1 g: aChar2 b: aChar3 
    "I map a RGB triple to an opaque pixel value for a given pixel
    format. My C function call prototype:

    extern DECLSPEC Uint32 SDLCALL SDL_MapRGB (SDL_PixelFormat *format, 
         Uint8 r, Uint8 g, Uint8 b);"
    <cCall: 'SDL_MapRGB' returning: #uInt
        args: #( #cObject #char #char #char  )>!

sdlMapRGBA: aCobject0 r: aChar1 g: aChar2 b: aChar3 a: aChar4 
    "I map a RGBA quadruple to a pixel value for a given pixel
    format. My C function call prototype:

    extern DECLSPEC Uint32 SDLCALL SDL_MapRGBA(SDL_PixelFormat *format, 
         Uint8 r, Uint8 g, Uint8 b, Uint8 a);"
    <cCall: 'SDL_MapRGBA' returning: #uInt
        args: #( #cObject #char #char #char #char  )>!

sdlGetRGB: aUint0 fmt: aCobject1 r: aCobject2 g: aCobject3 b: aCobject4
    "I map a pixel value into the RGB components for a given pixel
    format. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_GetRGB(Uint32 pixel, SDL_PixelFormat *fmt, 
         Uint8 *r, Uint8 *g, Uint8 *b);"
    <cCall: 'SDL_GetRGB' returning: #void 
        args: #( #uInt #cObject #cObject #cObject #cObject )>!

sdlGetRGBA: aUint0 fmt: aCobject1 r: aCobject2 g: aCobject3 b: aCobject4 a: aCobject5
    "I map a pixel value into the RGBA components for a given pixel
    format. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_GetRGBA(Uint32 pixel, SDL_PixelFormat *fmt, 
         Uint8 *r, Uint8 *g, Uint8 *b, Uint8 *a);"
    <cCall: 'SDL_GetRGBA' returning: #void 
        args: #( #uInt #cObject #cObject #cObject #cObject #cObject )>!

sdlCreateRGBSurface: aUint0 width: aInt1 height: aInt2 depth: aInt3 rmask: aUint4 
        gmask: aUint5 bmask: aUint6 amask: aUint7
    "I allocate an RGB surface (must be called after
    SDL_SetVideoMode). My C function call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL SDL_CreateRGBSurface (Uint32 flags, 
         int width, int height, int depth, Uint32 Rmask, Uint32 Gmask, Uint32 Bmask, 
         Uint32 Amask);"
    <cCall: 'SDL_CreateRGBSurface' returning: #{SdlSurface}
        args: #( #uInt #int #int #int #uInt #uInt #uInt #uInt  )>!

sdlCreateRGBSurfaceFrom: aCobject0 width: aInt1 height: aInt2 depth: aInt3 pitch: aInt4 
        rmask: aUint5 gmask: aUint6 bmask: aUint7 amask: aUint8 
    "I allocate an RGB surface. My C function call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL SDL_CreateRGBSurfaceFrom(void *pixels, 
         int width, int height, int depth, int pitch, Uint32 Rmask, Uint32 Gmask, Uint32 Bmask, 
         Uint32 Amask);"
    <cCall: 'SDL_CreateRGBSurfaceFrom' returning: #{SdlSurface}
        args: #( #cObject #int #int #int #int #uInt #uInt #uInt #uInt  )>!

sdlFreeSurface: aCobject0
    "I free an RGB surface. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_FreeSurface(SDL_Surface *surface);"
    <cCall: 'SDL_FreeSurface' returning: #void 
        args: #( #cObject )>!

sdlLockSurface: aCobject0
    "I set up a surface for directly accessing the pixels. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_LockSurface(SDL_Surface *surface);"
    <cCall: 'SDL_LockSurface' returning: #int 
        args: #( #cObject )>!

sdlUnlockSurface: aCobject0
    "I release a surface that was locked for directly accessing
    pixels. My C function prototype:

    extern DECLSPEC void SDLCALL SDL_UnlockSurface(SDL_Surface *surface);"
    <cCall: 'SDL_UnlockSurface' returning: #void 
        args: #( #cObject )>!

sdlLoadBMPRW: aCobject0 freesrc: aInt1 
    "I load a surface from a seekable SDL data source. My C function
    call prototype:

     extern DECLSPEC SDL_Surface * SDLCALL SDL_LoadBMP_RW(SDL_RWops *src, 
         int freesrc);"
    <cCall: 'SDL_LoadBMP_RW' returning: #{SdlSurface}
        args: #( #cObject #int  )>!

sdlSaveBMPRW: aCobject0 dst: aCobject1 freeDst: aInt2
    "I save a surface to a seekable SDL data source. My C function
    call prototype:

    extern DECLSPEC int SDLCALL SDL_SaveBMP_RW (SDL_Surface *surface, 
         SDL_RWops *dst, int freedst);"
    <cCall: 'SDL_SaveBMP_RW' returning: #int 
        args: #( #cObject #cObject #int )>!

sdlSetColorKey: aObject0 flag: aUint1 key: aUint2
    "I set the color key (transparent pixel) in a blittable
    surface. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_SetColorKey (SDL_Surface *surface, 
         Uint32 flag, Uint32 key);"
    <cCall: 'SDL_SetColorKey' returning: #int
        args: #( #cObject #int #int )>!

sdlSetAlpha: aCobject0 flag: aUint alpha: aUchar
    "I set the alpha value for the entire surface. My C function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_SetAlpha(SDL_Surface *surface, 
         Uint32 flag, Uint8 alpha);"
    <cCall: 'SDL_SetAlpha' returning: #int 
        args: #( #cObject #uInt #char )>!

sdlSetClipRect: aCobject0 rect: aCobject1 
    "I set the clipping rectangle for the destination surface in a
    blit. My C function call prototype:

     extern DECLSPEC SDL_bool SDLCALL SDL_SetClipRect(SDL_Surface *surface, 
         const SDL_Rect *rect);"
    <cCall: 'SDL_SetClipRect' returning: #boolean
        args: #( #cObject #cObject  )>!

sdlGetClipRect: aCobject0 rect: aCobject1
    "I get the clipping rectangle for the destination surface in a
    blit. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_GetClipRect(SDL_Surface *surface, 
         SDL_Rect *rect);"
    <cCall: 'SDL_GetClipRect' returning: #void 
        args: #(  #cObject #cObject )>!

sdlConvertSurface: aCobject0 fmt: aCobject1 flags: aUint2 
    "I create a new surface of the specified format, and then copy and
    map the given surface to it so the blit of the converted surface
    will be as fast as possible. My C function call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL SDL_ConvertSurface (SDL_Surface *src, 
         SDL_PixelFormat *fmt, Uint32 flags);"
    <cCall: 'SDL_ConvertSurface' returning: #{SdlSurface}
        args: #( #cObject #cObject #uInt  )>!

sdlUpperBlit: aCobject0 srcRect: aCobject1 dst: aCobject2 dstRect: aCobject3
    "I perform a fast blit from the source surface to the destination
    surface. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_UpperBlit (SDL_Surface *src, SDL_Rect *srcrect, 
         SDL_Surface *dst, SDL_Rect *dstrect);"
    <cCall: 'SDL_UpperBlit' returning: #int 
        args: #( #cObject #cObject #cObject #cObject )>!

sdlLowerBlit: aCobject0 srcRect: aCobject1 dst: aCobject2 dstRect: aCobject3
    "I perform a fast blit from the source surface to the destination
    surface. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_LowerBlit (SDL_Surface *src, SDL_Rect *srcrect, 
         SDL_Surface *dst, SDL_Rect *dstrect);"
    <cCall: 'SDL_LowerBlit' returning: #int 
        args: #( #cObject #cObject #cObject #cObject )>!

sdlFillRect: aCobject0 dstRect: aCobject1 color: aUint
    "extern DECLSPEC int SDLCALL SDL_FillRect (SDL_Surface *dst, 
         SDL_Rect *dstrect, Uint32 color);"
    <cCall: 'SDL_FillRect' returning: #int 
        args: #( #cObject #cObject #uInt )>!

sdlDisplayFormat: aCobject0 
    "I take a surface and copy it to a new surface of the pixel
    format and colors of the video framebuffer, suitable for fast
    blitting onto the display surface. My C function call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL SDL_DisplayFormat(SDL_Surface *surface);"
    <cCall: 'SDL_DisplayFormat' returning: #{SdlSurface}
        args: #( #cObject  )>!

sdlDisplayFormatAlpha: aCobject0 
    "I take a surface and copy it to a new surface of the pixel
    format and colors of the video framebuffer (if possible), suitable
    for fast alpha blitting onto the display surface. My C function
    call prototype:

    extern DECLSPEC SDL_Surface * SDLCALL SDL_DisplayFormatAlpha(SDL_Surface *surface);"
    <cCall: 'SDL_DisplayFormatAlpha' returning: #{SdlSurface}
        args: #( #cObject  )>!

sdlCreateYUVOverlay: aInt0 height: aInt1 format: aUint2 display: aCobject3
    "I create a video output overlay. My C function call prototype:

    extern DECLSPEC SDL_Overlay * SDLCALL SDL_CreateYUVOverlay(int width, int height, 
         Uint32 format, SDL_Surface *display);"
    <cCall: 'SDL_CreateYUVOverlay' returning: #{SdlOverlay}
        args: #( #int #int #uInt #cObject  )>!

sdlLockYUVOverlay: cObject0
    "I lock an overlay for direct access. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_LockYUVOverlay(SDL_Overlay *overlay);"
    <cCall: 'SDL_LockYUVOverlay' returning: #int 
        args: #( #cObject )>!

sdlUnlockYUVOverlay: aCobject0
    "I unlock an overlay. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_UnlockYUVOverlay(SDL_Overlay *overlay);"
    <cCall: 'SDL_UnlockYUVOverlay' returning: #void 
        args: #( #cObject )>!

sdlDisplayYUVOverlay: aCobject0 dstRect: aCobject1
    "I blit a video overlay to the display surface. My C function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_DisplayYUVOverlay(SDL_Overlay *overlay, 
         SDL_Rect *dstrect);"
    <cCall: 'SDL_DisplayYUVOverlay' returning: #int 
        args: #( #cObject #cObject )>!

sdlFreeYUVOverlay: aCobject0
    "I free a video overlay. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_FreeYUVOverlay(SDL_Overlay *overlay);"
    <cCall: 'SDL_FreeYUVOverlay' returning: #void 
        args: #( #cObject )>!

sdlGLLoadLibrary: aString0
    "I dynamically load a GL driver. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_GL_LoadLibrary(const char *path);"
    <cCall: 'SDL_GL_LoadLibrary' returning: #int 
        args: #( #string )>!

sdlGLGetProcAddress: aString0
    "I get the address of a GL function. My C function call prototype:

    extern DECLSPEC void * SDLCALL SDL_GL_GetProcAddress(const char* proc);"
    <cCall: 'SDL_GL_GetProcAddress' returning: #cObject 
        args: #( #string )>!

sdlGLSetAttributes: aCobject0 value: aInt1
    "I set an attribute of the OpenGL subsystem before
    intialization. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_GL_SetAttribute(SDL_GLattr attr, int value);"
    <cCall: 'SDL_GL_SetAttribute' returning: #int 
        args: #( #cObject #int )>!

sdlGLGetAttributes: aCobject0 value: aCobject1
    "I get an attribute of the OpenGL subsystem from the windowing
    interface. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_GL_GetAttribute(SDL_GLattr attr, int* value);"
    <cCall: 'SDL_GL_GetAttribute' returning: #int 
       args: #( #cObject #cObject )>!

sdlGLSwapBuffers
    "I swap the OpenGL buffers, if double-buffering is supported. My C
    function call prototype:

    extern DECLSPEC void SDLCALL SDL_GL_SwapBuffers(void);"
    <cCall: 'SDL_GL_SwapBuffers' returning: #void 
        args: #( )>!

sdlGLUpdateRects: aInt0 rects: aCobject1
    "I am a low-level private function. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_GL_UpdateRects(int numrects, SDL_Rect* rects);"
    <cCall: 'SDL_GL_UpdateRects' returning: #void 
        args: #( #int #cObject )>!

sdlGLLock
    "I am a low-level private function. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_GL_Lock(void);"
    <cCall: 'SDL_GL_Lock' returning: #void 
        args: #( )>!

sdlGLUnlock
    "I am a low-level private function. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_GL_Unlock(void);"
    <cCall: 'SDL_GL_Unlock' returning: #void 
        args: #( )>!

sdlWMSetCaption: aString0 icon: aString2
    "I set the title and icon text of the display window. My C
    function call prototype:

    extern DECLSPEC void SDLCALL SDL_WM_SetCaption(const char *title, 
         const char *icon);"
    <cCall: 'SDL_WM_SetCaption' returning: #void 
        args: #( #string #string )>!

sdlWMGetCaption: aCobjectPtr0 icon: cObjectPtr1
    "I get the title and icon text of the display window. My C
    function call prototype:

    extern DECLSPEC void SDLCALL SDL_WM_GetCaption(char **title, 
         char **icon);"
    <cCall: 'SDL_WM_GetCaption' returning: #void 
        args: #( #cObjectPtr #cObjectPtr )>!

sdlWMSetIcon: aObject0 mask: aCobject1
    "I set the icon for the display window. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_WM_SetIcon(SDL_Surface *icon, 
         Uint8 *mask);"
    <cCall: 'SDL_WM_SetIcon' returning: #void 
        args: #( #cObject #cObject )>!

sdlWMIconifyWindow
    "I iconify a window. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_WM_IconifyWindow(void);"
    <cCall: 'SDL_WM_IconifyWindow' returning: #int 
        args: #( )>!

sdlWMToggleFullScreen: aCobject0
    "I toggle the fullscreen mode without changing the contents of the
    screen. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_WM_ToggleFullScreen(SDL_Surface *surface);"
    <cCall: 'SDL_WM_ToggleFullScreen' returning: #int 
        args: #( #cObject )>!

sdlWMGrabInput: aCobject0
    "I confine nearly all of the mouse and keyboard input to the
    application window. My C function call prototype:

    extern DECLSPEC SDL_GrabMode SDLCALL SDL_WM_GrabInput(SDL_GrabMode mode);"
    <cCall: 'SDL_WM_GrabInput' returning: #int
        args: #( #int  )>! !
PK
     �Mh@o��sl  l    SDL_keysym.stUT	 dqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlKeySym
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlKeySym class methodsFor: 'Constants'!

sdlkUnknown
    ^0!

sdlkFirst
    ^0!

sdlkBackspace
    ^8!

sdlkTab
    ^9!

sdlkClear
    ^12!

sdlkReturn
    ^13!

sdlkPause
    ^19!

sdlkEscape
    ^27!

sdlkSpace
    ^32!

sdlkExclaim
    ^33!

sdlkQuotedbl
    ^34!

sdlkHash
    ^35!

sdlkDollar
    ^36!

sdlkAmpersand
    ^38!

sdlkQuote
    ^39!

sdlkLeftparen
    ^40!

sdlkRightparen
    ^41!

sdlkAsterisk
    ^42!

sdlkPlus
    ^43!

sdlkComma
    ^44!

sdlkMinus
    ^45!

sdlkPeriod
    ^46!

sdlkSlash
    ^47!

sdlk0
    ^48!

sdlk1
    ^49!

sdlk2
    ^50!

sdlk3
    ^51!

sdlk4
    ^52!

sdlk5
    ^53!

sdlk6
    ^54!

sdlk7
    ^55!

sdlk8
    ^56!

sdlk9
    ^57!

sdlkColon
    ^58!

sdlkSemicolon
    ^59!

sdlkLess
    ^60!

sdlkEquals
    ^61!

sdlkGreater
    ^62!

sdlkQuestion
    ^63!

sdlkAt
    ^64!

sdlkLeftbracket
    ^91!

sdlkBackslash
    ^92!

sdlkRightbracket
    ^93!

sdlkCaret
    ^94!

sdlkUnderscore
    ^95!

sdlkBackquote
    ^96!

sdlkA
    ^97!

sdlkB
    ^98!

sdlkC
    ^99!

sdlkD
    ^100!

sdlkE
    ^101!

sdlkF
    ^102!

sdlkG
    ^103!

sdlkH
    ^104!

sdlkI
    ^105!

sdlkJ
    ^106!

sdlkK
    ^107!

sdlkL
    ^108!

sdlkM
    ^109!

sdlkN
    ^110!

sdlkO
    ^111!

sdlkP
    ^112!

sdlkQ
    ^113!

sdlkR
    ^114!

sdlkS
    ^115!

sdlkT
    ^116!

sdlkU
    ^117!

sdlkV
    ^118!

sdlkW
    ^119!

sdlkX
    ^120!

sdlkY
    ^121!

sdlkZ
    ^122!

sdlkDelete
    ^127!

sdlkWorld0
    ^160!

sdlkWorld1
    ^161!

sdlkWorld2
    ^162!

sdlkWorld3
    ^163!

sdlkWorld4
    ^164!

sdlkWorld5
    ^165!

sdlkWorld6
    ^166!

sdlkWorld7
    ^167!

sdlkWorld8
    ^168!

sdlkWorld9
    ^169!

sdlkWorld10
    ^170!

sdlkWorld11
    ^171!

sdlkWorld12
    ^172!

sdlkWorld13
    ^173!

sdlkWorld14
    ^174!

sdlkWorld15
    ^175!

sdlkWorld16
    ^176!

sdlkWorld17
    ^177!

sdlkWorld18
    ^178!

sdlkWorld19
    ^179!

sdlkWorld20
    ^180!

sdlkWorld21
    ^181!

sdlkWorld22
    ^182!

sdlkWorld23
    ^183!

sdlkWorld24
    ^184!

sdlkWorld25
    ^185!

sdlkWorld26
    ^186!

sdlkWorld27
    ^187!

sdlkWorld28
    ^188!

sdlkWorld29
    ^189!

sdlkWorld30
    ^190!

sdlkWorld31
    ^191!

sdlkWorld32
    ^192!

sdlkWorld33
    ^193!

sdlkWorld34
    ^194!

sdlkWorld35
    ^195!

sdlkWorld36
    ^196!

sdlkWorld37
    ^197!

sdlkWorld38
    ^198!

sdlkWorld39
    ^199!

sdlkWorld40
    ^200!

sdlkWorld41
    ^201!

sdlkWorld42
    ^202!

sdlkWorld43
    ^203!

sdlkWorld44
    ^204!

sdlkWorld45
    ^205!

sdlkWorld46
    ^206!

sdlkWorld47
    ^207!

sdlkWorld48
    ^208!

sdlkWorld49
    ^209!

sdlkWorld50
    ^210!

sdlkWorld51
    ^211!

sdlkWorld52
    ^212!

sdlkWorld53
    ^213!

sdlkWorld54
    ^214!

sdlkWorld55
    ^215!

sdlkWorld56
    ^216!

sdlkWorld57
    ^217!

sdlkWorld58
    ^218!

sdlkWorld59
    ^219!

sdlkWorld60
    ^220!

sdlkWorld61
    ^221!

sdlkWorld62
    ^222!

sdlkWorld63
    ^223!

sdlkWorld64
    ^224!

sdlkWorld65
    ^225!

sdlkWorld66
    ^226!

sdlkWorld67
    ^227!

sdlkWorld68
    ^228!

sdlkWorld69
    ^229!

sdlkWorld70
    ^230!

sdlkWorld71
    ^231!

sdlkWorld72
    ^232!

sdlkWorld73
    ^233!

sdlkWorld74
    ^234!

sdlkWorld75
    ^235!

sdlkWorld76
    ^236!

sdlkWorld77
    ^237!

sdlkWorld78
    ^238!

sdlkWorld79
    ^239!

sdlkWorld80
    ^240!

sdlkWorld81
    ^241!

sdlkWorld82
    ^242!

sdlkWorld83
    ^243!

sdlkWorld84
    ^244!

sdlkWorld85
    ^245!

sdlkWorld86
    ^246!

sdlkWorld87
    ^247!

sdlkWorld88
    ^248!

sdlkWorld89
    ^249!

sdlkWorld90
    ^250!

sdlkWorld91
    ^251!

sdlkWorld92
    ^252!

sdlkWorld93
    ^253!

sdlkWorld94
    ^254!

sdlkWorld95
    ^255!

sdlkKp0
    ^256!

sdlkKp1
    ^257!

sdlkKp2
    ^258!

sdlkKp3
    ^259!

sdlkKp4
    ^260!

sdlkKp5
    ^261!

sdlkKp6
    ^262!

sdlkKp7
    ^263!

sdlkKp8
    ^264!

sdlkKp9
    ^265!

sdlkKpPeriod
    ^266!

sdlkKpDivide
    ^267!

sdlkKpMultiply
    ^268!

sdlkKpMinus
    ^269!

sdlkKpPlus
    ^270!

sdlkKpEnter
    ^271!

sdlkKpEquals
    ^272!

sdlkUp
    ^273!

sdlkDown
    ^274!

sdlkRight
    ^275!

sdlkLeft
    ^276!

sdlkInsert
    ^277!

sdlkHome
    ^278!

sdlkEnd
    ^279!

sdlkPageup
    ^280!

sdlkPagedown
    ^281!

sdlkF1
    ^282!

sdlkF2
    ^283!

sdlkF3
    ^284!

sdlkF4
    ^285!

sdlkF5
    ^286!

sdlkF6
    ^287!

sdlkF7
    ^288!

sdlkF8
    ^289!

sdlkF9
    ^290!

sdlkF10
    ^291!

sdlkF11
    ^292!

sdlkF12
    ^293!

sdlkF13
    ^294!

sdlkF14
    ^295!

sdlkF15
    ^296!

sdlkNumlock
    ^300!

sdlkCapslock
    ^301!

sdlkScrollock
    ^302!

sdlkRshift
    ^303!

sdlkLshift
    ^304!

sdlkRctrl
    ^305!

sdlkLctrl
    ^306!

sdlkRalt
    ^307!

sdlkLalt
    ^308!

sdlkRmeta
    ^309!

sdlkLmeta
    ^310!

sdlkLsuper
    ^311!

sdlkRsuper
    ^312!

sdlkMode
    ^313!

sdlkCompose
    ^314!

sdlkHelp
    ^315!

sdlkPrint
    ^316!

sdlkSysreq
    ^317!

sdlkBreak
    ^318!

sdlkMenu
    ^319!

sdlkPower
    ^320!

sdlkEuro
    ^321!

sdlkUndo
    ^322!

sdlkLast
    ^0!

kmodNone
    ^16r0000!

kmodLshift
    ^16r0001!

kmodRshift
    ^16r0002!

kmodLctrl
    ^16r0040!

kmodRctrl
    ^16r0080!

kmodLalt
    ^16r0100!

kmodRalt
    ^16r0200!

kmodLmeta
    ^16r0400!

kmodRmeta
    ^16r0800!

kmodNum
    ^16r1000!

kmodCaps
    ^16r2000!

kmodMode
    ^16r4000!

kmodReserved
    ^16r8000!

kmodCtrl
    ^16r0040 | 16r0080!

kmodShift
    ^16r0002 | 16r0040!

kmodAlt
    ^16r0100 | 16r0200!

kmodMeta
    ^16r0400 | 16r0800! !
PK
     �Mh@�e4�o  o    SDL_timer.stUT	 eqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlTimer
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlTimer class methodsFor: 'Constants'!

sdlTimeSlice
    ^10!

timerResolution
    ^10!

!SdlTimer class methodsFor: 'C call-outs'!

sdlGetTicks
    "I answer the number of milliseconds since the SDL library
    initialization. My C function call prototype:

    extern DECLSPEC Uint32 SDLCALL SDL_GetTicks(void);"
    <cCall: 'SDL_GetTicks' returning: #uInt
        args: #( )>!

sdlDelay: aUint
    "I wait a specified number of milliseconds. My C function call
    prototype:

    extern DECLSPEC void SDLCALL SDL_Delay(Uint32 ms);"
    <cCall: 'SDL_Delay' returning: #void 
        args: #( #uInt )>!

sdlSetTimer: aUint callback: aCobject2
    "I set a callback to run after the specified number of
    milliseconds has elapsed. My C function call prototype:

    extern DECLSPEC int SDLCALL SDL_SetTimer(Uint32 interval, 
         SDL_TimerCallback callback);"
    <cCall: 'SDL_SetTimer' returning: #int 
        args: #( #int #cObject )>!

sdlAddTimer: aUint0 callback: aCobject1 param: aCobject2 
    "I add a new timer to the pool of timers already running. My C
    function call prototype:

    extern DECLSPEC SDL_TimerID SDLCALL SDL_AddTimer(Uint32 interval, 
         SDL_NewTimerCallback callback, void *param);"
    <cCall: 'SDL_AddTimer' returning: #cObject 
        args: #( #uInt #cObject #cObject  )>!

sdlRemoveTimer: aCobject0 
    "I remove the timer with the ID given to me. My C function call
    prototype:

    extern DECLSPEC SDL_bool SDLCALL SDL_RemoveTimer(SDL_TimerID t);"
    <cCall: 'SDL_RemoveTimer' returning: #boolean
        args: #( #cObject  )>! !
PK
     �Mh@d(IYX+  X+  
  Display.stUT	 dqXOӉXOux �  �  "======================================================================
|
|   SdlDisplay wrapper class for libsdl
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Tony Garnock-Jones and Michael Bridgen.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Object subclass: SdlDisplayFormat [
    | caption iconCaption extent resizable fullScreen |

    flags [
	<category: 'private'>
	self fullScreen ifTrue: [ ^SdlVideo sdlFullScreen ].
	self resizable ifTrue: [ ^SdlVideo sdlResizable ].
	^0
    ]

    caption [
        "Answer the caption of the window when it is not minimized."

	<category: 'accessing'>
	caption ifNil: [ caption := 'GNU Smalltalk' ].
	^caption
    ]

    caption: aString [
        "Set the caption of the window when it is not minimized."

	<category: 'accessing'>
	caption := aString.
    ]

    iconCaption [
        "Answer the caption of the window when it is minimized."

	<category: 'accessing'>
	^iconCaption ifNil: [ caption ].
    ]

    iconCaption: aString [
        "Set the caption of the window when it is minimized.  A value of nil
	 means the caption will not change when the window is minimized."

	<category: 'accessing'>
	iconCaption := aString
    ]

    extent [
	"Return the size of the window."

	<category: 'accessing'>
	extent ifNil: [ extent := 640 @ 480 ].
	^extent
    ]

    extent: aPoint [
	"Set the size of the window."

	<category: 'accessing'>
	extent := aPoint
    ]

    fullScreen [
	"Answer whether the SDL surface will be full-screen."

	<category: 'accessing'>
	fullScreen ifNil: [ fullScreen := false ].
	^fullScreen
    ]

    fullScreen: aBoolean [
	"Set whether the SDL surface will be full-screen."

	<category: 'accessing'>
	fullScreen := aBoolean
    ]

    resizable [
	"Answer whether the SDL surface will be resizable.  If it is, the
	 program will have to send the #resize: method to the display when
	 it gets a resize event (the default SdlEventHandler does this)."

	<category: 'accessing'>
	resizable ifNil: [ resizable := false ].
	^resizable
    ]

    resizable: aBoolean [
	"Set whether the SDL surface will be resizable.  If it is, the
	 program will have to send the #resize: method to the display when
	 it gets a resize event (the default SdlEventHandler does this)."

	<category: 'accessing'>
	resizable := aBoolean
    ]
]

Object subclass: SdlDisplay [
    <category: 'LibSDL-Wrapper'>
    <comment: 'I provide an object-oriented wrapper for some SDL_video
functions.  A Display can be connected to an EventSource and be used
as the destination for a Cairo surface.'>

    | surface flags extent caption iconCaption eventSource |

    CurrentDisplay := nil.
    DefaultFormat := nil.
    SdlDisplay class >> current [
	"Return the default display, creating one if none exists."

	<category: 'accessing'>
	"Creating the display will set CurrentDisplay too."
	CurrentDisplay isNil ifTrue: [ ^self new ].
	^CurrentDisplay
    ]

    SdlDisplay class >> current: aDisplay [
	"Set the default display."

	<category: 'accessing'>
	CurrentDisplay := aDisplay
    ]

    SdlDisplay class >> initialize [
        "Initialize the class, and initialize SDL when the library is loaded."

        <category: 'initialization'>
        ObjectMemory addDependent: self.
        self sdlInit.
    ]

    SdlDisplay class >> update: aspect [
        "Tie the event loop to image quit and restart."

        <category: 'initialization'>
        aspect == #returnFromSnapshot ifTrue: [ self sdlInit ].
	self changed: aspect
    ]

    SdlDisplay class >> sdlInit [
        "Initialize the SDL video subsystem, which is needed to get events."
        Sdl sdlInit: (Sdl sdlInitVideo bitOr: Sdl sdlInitNoParachute).
    ]

    SdlDisplay class >> defaultFormat [
	"Return the default format of the display, which is also the
	 format used when #current is called and there is no default
	 display."

	<category: 'accessing'>
	DefaultFormat isNil ifTrue: [ DefaultFormat := SdlDisplayFormat new ].
	^ DefaultFormat
    ]

    SdlDisplay class >> defaultSize [
	"Return the default size of the display, which is also the
	 size used when #current is called and there is no default
	 display."

	<category: 'accessing'>
	 ^ self defaultFormat extent
    ]

    SdlDisplay class >> defaultFormat: aDisplayFormat [
	"Set the default format of the display."

	<category: 'accessing'>
	DefaultFormat := aDisplayFormat
    ]

    SdlDisplay class >> defaultSize: aPoint [
	"Set the default size of the display."

	<category: 'accessing'>
	self defaultFormat extent: aPoint
    ]

    SdlDisplay class >> format: aSdlDisplayFormat [
	"Return an SdlDisplay with the given format."

	<category: 'instance creation'>
	^self basicNew initialize: aSdlDisplayFormat
    ]

    SdlDisplay class >> extent: aPoint [
	"Return an SdlDisplay with the given width and height."

	<category: 'instance creation'>
	^self format: (self defaultFormat copy extent: aPoint; yourself)
    ]

    SdlDisplay class >> new [
	"Return an SdlDisplay with the default width and height."

	<category: 'instance creation'>
	^self format: self defaultFormat
    ]

    sdlSurface [
	<category: 'private - accessing'>
	^surface
    ]

    sdlSurface: anSdlSurface [
	<category: 'private - accessing'>
	surface := anSdlSurface
    ]

    mapRed: r green: g blue: b [
	"Return an SDL color index for the given red/green/blue triplet."

	<category: 'drawing-SDL'>
	^ SdlVideo sdlMapRGB: surface format value r: r g: g b: b
    ]

    fillRect: aRect color: aColorNumber [
	"Fill a rectangle in the display with the color whose index is in
	 aColorNumber."

	<category: 'drawing-SDL'>
	| r |
	r := SDL.SdlRect gcNew.
	r x value: aRect left.
	r y value: aRect top.
	r w value: aRect width.
	r h value: aRect height.
	SdlVideo sdlFillRect: surface dstRect: r color: aColorNumber
    ]

    critical: aBlock [
	"Execute aBlock while the surface is locked.  This must be
	 called while drawing on the surface directly (e.g. via Cairo)"

	<category: 'drawing-direct'>
	(SdlVideo sdlLockSurface: surface) == 0 ifFalse: [
	    self error: 'Could not lock surface ', surface].
	^ aBlock ensure: [SdlVideo sdlUnlockSurface: surface]
    ]

    extent [
	"Return the size of the display."
	^ extent
    ]

    initialize: aFormat [
	"Initialize the display by hooking it up to the SdlEventSource."

	<category: 'initialization'>
	caption := aFormat caption.
	iconCaption := aFormat iconCaption.
	extent := aFormat extent.
	flags := aFormat flags.

	self class addDependent: self.

	"It's our first run - simulate returning from a saved image in
	order to set up the display window etc."
	CurrentDisplay isNil ifTrue: [ self class current: self ].
	self create
    ]

    update: aspect [
        "Tie the event loop to image quit and restart."

        <category: 'initialization'>
        aspect == #returnFromSnapshot ifTrue: [
	    self create.
            self eventSource handler isNil ifFalse: [ self eventSource startEventLoop ].
            self changed: #returnFromSnapshot.
            ^self].
        aspect == #aboutToQuit ifTrue: [
	    self shutdown.
            self eventSource interruptEventLoop.
            ^self].
    ]

    shutdown [
	self sdlSurface: nil.
    ]

    eventSource [
	"Return the EventSource associated to this display."
	eventSource isNil ifTrue: [ eventSource := SdlEventSource new ].
	^eventSource
    ]

    caption [
	"Return the caption of the window when it is not minimized."

	<category: 'accessing'>
	^caption
    ]

    iconCaption [
	"Return the caption of the window when it is minimized."

	<category: 'accessing'>
	^iconCaption
    ]

    caption: aString [
	"Set the caption of the window when it is not minimized."

	<category: 'accessing'>
	caption := aString.
	self setCaptions.
    ]

    iconCaption: aString [
	"Set the caption of the window when it is minimized."

	<category: 'accessing'>
	iconCaption := aString.
	self setCaptions.
    ]

    caption: aCaptionString iconCaption: anIconCaptionString [
	"Set up the window to use aCaptionString as its caption when it is
	 not minimized, and anIconCaptionString when it is."

	<category: 'accessing'>
	caption := aCaptionString.
	iconCaption := anIconCaptionString.
	self setCaptions.
    ]

    create [
	"Private - Actually create the display.

	TODO: add more accessors to match SDL flags (e.g. fullscreen, double
	buffer, resizable, h/w surfaces)."

	<category: 'initialization'>
	| flags screen |
	screen := SdlVideo sdlSetVideoMode: extent x height: extent y bpp: 32 flags: self flags.
	self sdlSurface: screen.
	self setCaptions.
    ]

    resize: newSize [
	"Change the extent of the display to newSize."

	<category: 'resize'>
	self shutdown.
	extent := newSize.
	self create.
	self changed: #resize
    ]

    flags [
	"Private - Return the SDL_SetVideoMode flags."

	<category: 'private'>
	^flags " bitOr: SdlVideo sdlFullScreen."
    ]

    setCaptions [
	"Private - sets captions from my instance variables."

	<category: 'private'>
	SdlVideo sdlWMSetCaption: self caption icon: self iconCaption.
    ]
	
    flip [
	"Move the contents of the surface to the screen.  Optimized for
	 double-buffered surfaces, but always works."

	<category: 'drawing'>
	SdlVideo sdlFlip: self sdlSurface.
    ]

    isGLDisplay [
	"Return true if this is an OpenGL display and graphics should be
	 performed using OpenGL calls."

	<category: 'testing'>
	^false
    ]

    updateRectangle: aRect [
	"Move the contents of the given rectangle from the surface to the
	 screen."

	<category: 'drawing'>
	| x y |
        SdlVideo sdlUpdateRect: self sdlSurface
                 x: (x := aRect left floor)
                 y: (y := aRect top floor)
                 w: aRect right ceiling - x
                 h: aRect height ceiling - y.
    ]

    updateRectangles: upTo rects: sdlrects [
	"Private - Move the contents of the given SdlRect objects from the
	 surface to the screen."

	<category: 'drawing-SDL'>
	SdlVideo sdlUpdateRects: self sdlSurface
		 numRects: upTo
		 rects: sdlrects.
    ]
].

Eval [
    SdlDisplay initialize
]
PK
     �Mh@#^�ǵ  �    SDL_thread.stUT	 eqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlThread
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlThread class methodsFor: 'C call-outs'!

sdlCreateThread: aCobject0 data: aCobject1 
    "I create a thread. My C function call prototype:

    extern DECLSPEC SDL_Thread * SDLCALL SDL_CreateThread(int (SDLCALL *fn)(void *), 
         void *data);"
    <cCall: 'SDL_CreateThread' returning: #cObject 
        args: #( #cObject #cObject  )>!

sdlThreadId
    "I answer the 32-bit thread identifier for the current thread. My
    C function call prototype:

    extern DECLSPEC Uint32 SDLCALL SDL_ThreadID(void);"
    <cCall: 'SDL_ThreadID' returning: #uInt
        args: #( )>!

sdlGetThreadId: aCobject0 
    "I answer the 32-bit thread identifier for the thread given to
    me. My C function call prototype:

    extern DECLSPEC Uint32 SDLCALL SDL_GetThreadID(SDL_Thread *thread);"
    <cCall: 'SDL_GetThreadID' returning: #uInt 
        args: #( #cObject  )>!

sdlWaitThread: aCobject0 status: aCobject1
    "I wait for the thread given to me to finish. My C function call
    prototype:

    extern DECLSPEC void SDLCALL SDL_WaitThread(SDL_Thread *thread, 
         int *status);"
    <cCall: 'SDL_WaitThread' retuning: #void 
        args: #( #cObject #cObject )>!

sdlKillThread: aCobject0
    "I kill a thread. My C function call prototype:

    extern DECLSPEC void SDLCALL SDL_KillThread(SDL_Thread *thread);"
    <cCall: 'SDL_KillThread' returning: #void 
        args: #( #cObject )>! !
PK
     �Mh@a�%��	  �	    SDL_loadso.stUT	 dqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlLoadSo
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlLoadSo class methodsFor: 'C call-outs'!

sdlLoadObject: aString0 
    "I load a shared object and answer with the address for it.  My C
    function call prototype:

    extern DECLSPEC void * SDLCALL SDL_LoadObject(const char *sofile);"
    <cCall: 'SDL_LoadObject' returning: #cObject 
        args: #( #string )>!

sdlLoadFunction: aCobject name: aString1
    "I answer the address of the function whose name and shared object
    are given to me in.  My C function call prototype:

    extern DECLSPEC void * SDLCALL SDL_LoadFunction(void *handle, const char *name);"
    <cCall: 'SDL_LoadFunction' returning: #cObject 
        args: #( #cObject #string )>!

sdlUnloadObject: aCobject0
    "I unload a shared object from memory. My C function call
    prototype:

    extern DECLSPEC void SDLCALL SDL_UnloadObject(void *handle);"
    <cCall: 'SDL_UnloadObject' returning: #void 
        args: #( #cObject )>! !
PK
     �Mh@8�w��)  �)    EventSource.stUT	 dqXOӉXOux �  �  "======================================================================
|
|   SdlEventSource and related classes
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Tony Garnock-Jones and Michael Bridgen.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


Notification subclass: SdlEventLoopStop [
    <category: 'LibSDL-Wrappers'>
    <comment: 'This exception is used internally to stop the SDL event loop.'>
]

Object subclass: SdlEventHandler [
    <category: 'LibSDL-Wrappers'>
    <comment: 'This is a basic class for SDL event handlers.  It declares
all event handlers as no-ops, guaranteeing backwards compatibility in
case future versions add more event handlers.'>

    handleMouseMotion: which state: state at: aPoint rel: relPoint [
	<category: 'event handlers'>
    ]

    handleMouseButton: which button: button state: state at: aPoint [
	<category: 'event handlers'>
    ]

    handleFocusLoss [
	<category: 'event handlers'>
    ]

    handleFocusGain [
	<category: 'event handlers'>
    ]

    handleKey: key state: aBoolean scanCode: scanCode sym: symCharacter mod: anInteger unicode: aCharacter [
	<category: 'event handlers'>
    ]

    handleExpose [
	<category: 'event handlers'>
    ]

    handleResize: sizePoint [
	"Unlike other handlers, this one by default tells the display to
	 resize itself."
	<category: 'event handlers'>
	SdlDisplay current resize: sizePoint
    ]

    handleQuit [
	<category: 'event handlers'>
	ObjectMemory quit
    ]

    eventMask [
	^ #(#{SdlActiveEvent} #{SdlKeyBoardEvent} #{SdlMouseMotionEvent}
	    #{SdlMouseButtonEvent} #{SdlResizeEvent} #{SdlExposeEvent}
	    #{SdlQuitEvent})
    ]
]

SdlEvent extend [
    EventTypeMap := nil.

    SdlEvent class >> initialize [
	EventTypeMap := Dictionary new.
	EventTypeMap at: SdlEvents sdlActiveEvent put: SdlActiveEvent.
	EventTypeMap at: SdlEvents sdlKeyDown put: SdlKeyBoardEvent.
	EventTypeMap at: SdlEvents sdlKeyUp put: SdlKeyBoardEvent.
	EventTypeMap at: SdlEvents sdlMouseMotion put: SdlMouseMotionEvent.
	EventTypeMap at: SdlEvents sdlMouseButtonDown put: SdlMouseButtonEvent.
	EventTypeMap at: SdlEvents sdlMouseButtonUp put: SdlMouseButtonEvent.
	EventTypeMap at: SdlEvents sdlJoyAxisMotion put: SdlJoyAxisEvent.
	EventTypeMap at: SdlEvents sdlJoyBallMotion put: SdlJoyBallEvent.
	EventTypeMap at: SdlEvents sdlJoyHatMotion put: SdlJoyHatEvent.
	EventTypeMap at: SdlEvents sdlJoyButtonDown put: SdlJoyButtonEvent.
	EventTypeMap at: SdlEvents sdlJoyButtonUp put: SdlJoyButtonEvent.
	EventTypeMap at: SdlEvents sdlQuit put: SdlQuitEvent.
	EventTypeMap at: SdlEvents sdlSysWMEvent put: SdlSysWmEvent.
	EventTypeMap at: SdlEvents sdlVideoResize put: SdlResizeEvent.
	EventTypeMap at: SdlEvents sdlVideoExpose put: SdlExposeEvent.
	EventTypeMap at: SdlEvents sdlUserEvent put: SdlUserEvent.
    ]

    SdlEvent class >> lookupEventType: aTypeNumber [
	^EventTypeMap at: aTypeNumber ifAbsent: [SdlEvent]
    ]

    becomeCorrectClass [
	<category: 'dispatch'>
	| correctClass |
	correctClass := SdlEvent lookupEventType: self type value asInteger.
	self changeClassTo: correctClass.
	^ self
    ]

    dispatchTo: handler [
	<category: 'dispatch'>
	Transcript << 'Unhandled event, ' << self; nl.
    ]
].

SdlActiveEvent extend [
    SdlActiveEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlActiveEventMask
    ]

    dispatchTo: handler [
	<category: 'dispatch'>
	self gain value asInteger == 0
	    ifTrue: [ handler handleFocusLoss ]
	    ifFalse: [ handler handleFocusGain ]
    ]
].

SdlMouseMotionEvent extend [
    SdlMouseMotionEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlMouseMotionMask
    ]

    dispatchTo: handler [
	<category: 'dispatch'>
	handler handleMouseMotion: self which value asInteger
		state: self state value asInteger
		at: self x value @ self y value
		rel: self xRel value @ self yRel value
    ]
].

SdlMouseButtonEvent extend [
    SdlMouseButtonEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlMouseButtonDownMask bitOr: SdlEvents sdlMouseButtonUpMask
    ]

    dispatchTo: handler [
	<category: 'dispatch'>
	handler handleMouseButton: self which value asInteger
		button: self button value asInteger
		state: self state value asInteger ~= 0
		at: self x value @ self y value
    ]
].

SdlExposeEvent extend [
    SdlExposeEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlVideoExposeMask
    ]

    dispatchTo: handler [
	<category: 'dispatch'>
	handler handleExpose
    ]
].

SdlResizeEvent extend [
    SdlResizeEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlVideoResizeMask
    ]

    dispatchTo: handler [
	<category: 'dispatch'>
	handler handleResize: self w value @ self h value
    ]
].

SdlKeyBoardEvent extend [
    SdlKeyBoardEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlKeyDownMask bitOr: SdlEvents sdlKeyUpMask
    ]
    keyboardModifiers [
	| v r |
	v := self mod value.
	v = 0 ifTrue: [ ^#() ].
	r := Set new.
	(v bitAnd: SdlKeySym kmodLshift) ~= 0 ifTrue: [ r add: #lshift. r add: #shift ].
	(v bitAnd: SdlKeySym kmodRshift) ~= 0 ifTrue: [ r add: #rshift. r add: #shift ].
	(v bitAnd: SdlKeySym kmodLctrl) ~= 0 ifTrue: [ r add: #lctrl. r add: #ctrl ].
	(v bitAnd: SdlKeySym kmodRctrl) ~= 0 ifTrue: [ r add: #rctrl. r add: #ctrl ].
	(v bitAnd: SdlKeySym kmodLalt) ~= 0 ifTrue: [ r add: #lalt. r add: #alt ].
	(v bitAnd: SdlKeySym kmodRalt) ~= 0 ifTrue: [ r add: #ralt. r add: #alt ].
	(v bitAnd: SdlKeySym kmodLmeta) ~= 0 ifTrue: [ r add: #lmeta. r add: #meta ].
	(v bitAnd: SdlKeySym kmodRmeta) ~= 0 ifTrue: [ r add: #rmeta. r add: #meta ].
	(v bitAnd: SdlKeySym kmodNum) ~= 0 ifTrue: [ r add: #num ].
	(v bitAnd: SdlKeySym kmodCaps) ~= 0 ifTrue: [ r add: #caps ].
	(v bitAnd: SdlKeySym kmodMode) ~= 0 ifTrue: [ r add: #mode ].
	^ r
    ]

    keySym [
	| s |
	s := self sym value.
	^ (s > 127)
	    ifTrue: [s]
	    ifFalse: [Character value: s]
    ]

    dispatchTo: handler [
	<category: 'dispatch'>
	handler handleKey: self which value asInteger
		state: self state value asInteger ~= 0
		scanCode: self scanCode value asInteger
		sym: self keySym
		mod: self keyboardModifiers
		unicode: (Character codePoint: self unicode value)
    ]
].

SdlJoyAxisEvent extend [
    SdlJoyAxisEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlJoyAxisMask
    ]
]

SdlJoyBallEvent extend [
    SdlJoyBallEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlJoyBallMask
    ]
]

SdlJoyHatEvent extend [
    SdlJoyHatEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlJoyHatMask
    ]
]

SdlJoyButtonEvent extend [
    SdlJoyButtonEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlJoyButtonDownMask bitOr: SdlEvents sdlJoyButtonUpMask
    ]
]

SdlSysWmEvent extend [
    SdlSysWmEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlSysWMEventMask
    ]
]

SdlUserEvent extend [
    SdlUserEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlUserMask
    ]
]

SdlQuitEvent extend [
    SdlQuitEvent class >> eventMask [
        <category: 'dispatch'>
	^SdlEvents sdlQuitMask
    ]

    dispatchTo: handler [
	<category: 'dispatch'>
	handler handleQuit
    ]
].

Object subclass: SdlEventSource [
    <category: 'LibSDL-Wrappers'>

    | handler pollDelay eventMask |

    SdlEventSource class >> new [
	"Create a new event source.  This is private, because an event source
	 is only created from an SdlDisplay."
	^ super new initialize
    ]

    handler [
	"Return the SdlEventHandler that will manage events for the display."

	<category: 'accessing'>
	^ handler
    ]

    handler: aHandler [
	"Set the SdlEventHandler that will manage events for the display."

	<category: 'accessing'>
	handler := aHandler.
	eventMask := handler eventMask
	     inject: 0 into: [:mask :assoc | mask bitOr: assoc value eventMask]
    ]

    initialize [
	<category: 'private-initialize'>
	pollDelay := Delay forMilliseconds: self defaultPollDelayMilliseconds.
	eventMask := 0.
    ]

    defaultPollDelayMilliseconds [
	<category: 'accessing'>
	^ 30 "which gives about 33 polls per second"
    ]

    waitEvent: anSdlEvent [
	<category: 'private-dispatch'>
	| peepResult |
	[
	    SdlEvents sdlPumpEvents.
	    peepResult := SdlEvents sdlPeepEvents: anSdlEvent
				    numEvents: 1
				    action: SdlEvents sdlGetEvent
				    mask: SdlEvents sdlAllEvents.
	    peepResult == -1 ifTrue: [ ^self error: 'SDL_PeepEvents error' ].
	    peepResult == 1 ifTrue: [ ^true ].
	    peepResult == 0 ifFalse: [ ^self error: 'Unexpected result from SDL_PeepEvents' ].
	    "0 - no event yet. Sleep and retry."
	    pollDelay wait.
	] repeat.
    ]

    waitEvent [
	<category: 'private-dispatch'>
	| e |
	[e := SdlGenericEvent new.
	self waitEvent: e.
	e becomeCorrectClass.
	e class eventMask anyMask: eventMask] whileFalse.
	^ e
    ]

    dispatchEvent: e [
	<category: 'private-dispatch'>
	handler ifNil: [^self].
	[e dispatchTo: handler]
	    on: Error
	    do: [ :ex |
		ex printNl.
		thisContext parentContext backtrace.
		ex return.
	    ].
    ]

    eventLoop [
	<category: 'private-dispatch'>
	Sdl sdlStartEventLoop: [
	    | e |
	    [
		[e := self waitEvent.
	        self dispatchEvent: e]
		    repeat
	    ] on: SdlEventLoopStop do: [ :ex |
		Sdl sdlStopEventLoop.
		ex return ].
	]
    ]

    startEventLoop [
	SdlKeyboard sdlEnableUnicode: 1.
	[ self eventLoop ] fork name: 'SdlEventSource eventLoop'.
    ]

    interruptEventLoop [
	SdlEventLoopStop signal
    ]
].

Eval [
    SdlEvent initialize.
    SdlEventSource initialize
]
PK
     �Mh@ n��  �    SDL_cpuinfo.stUT	 dqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlCPUInfo
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlCPUInfo class methodsFor: 'C call-outs'!

sdlHasRDTSC
    <cCall: 'SDL_HasRDTSC' returning: #boolean
        args: #( )>!

sdlHasMMX
    <cCall: 'SDL_HasMMX' returning: #boolean
        args: #( )>!

sdlHasMMXExt
    <cCall: 'SDL_HasMMXExt' returning: #boolean
        args: #( )>!

sdlHas3DNow
    <cCall: 'SDL_Has3DNow' returning: #boolean
        args: #( )>!

sdlHas3DNowExt
    <cCall: 'SDL_Has3DNowExt' returning: #boolean
        args: #( )>!

sdlHasSSE
    <cCall: 'SDL_HasSSE' returning: #boolean
        args: #( )>!

sdlHasSSE2
    <cCall: 'SDL_HasSSE2' returning: #boolean
        args: #( )>!

sdlHasAltiVec
    <cCall: 'SDL_HasAltiVec' returning: #boolean
        args: #( )>! !
PK
     �Mh@��I�  �    SDL_keyboard.stUT	 dqXOӉXOux �  �  "======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlKeyboard
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

CStruct subclass: #SdlKeysym
    declaration: #(
        (#scanCode #char)
        (#sym #int)
        (#mod #int)
        (#unicode #short))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlKeyboard class methodsFor: 'Constants'!

sdlAllHotkeys
    ^16rFFFFFFFF!

sdlDefaultRepeatDelay
    ^500!

sdlDefaultRepeatInterval
    ^30!

!SdlKeyboard class methodsFor: 'C call-outs'!

sdlEnableUnicode: aInt0
    "I enable or disable UNICODE translation of keyboard input. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDL_EnableUNICODE(int enable);"
    <cCall: 'SDL_EnableUNICODE' returning: #int 
        args: #( #int )>!

sdlEnableKeyRepeat: aInt0 interval: aInt1
    "I enable or disable keyboard repeat. My C function call
    prototype:

    extern DECLSPEC int SDLCALL SDL_EnableKeyRepeat(int delay, int interval);"
    <cCall: 'SDL_EnableKeyRepeat' returning: #int 
        args: #( #int #int )>!

sdlGetKeyState: aCobject0
    "I answer the current state of the keyboard. My C function call
    prototype:

    extern DECLSPEC Uint8 * SDLCALL SDL_GetKeyState(int *numkeys);"
    <cCall: 'SDL_GetKeyState' returning: #string 
        args: #( #cObject )>!

sdlGetModState 
    "I answer the current key modifier state. My C function call prototype:

    extern DECLSPEC SDLMod SDLCALL SDL_GetModState(void);"
    <cCall: 'SDL_GetModState' returning: #cObject 
        args: #( #void )>!

sdlGetKeyName: aInt0 "needs a c wrapper"
    "I answer the name of an SDL virtual keysym. My C function call prototype:

    extern DECLSPEC char * SDLCALL SDL_GetKeyName(SDLKey key);"
    <cCall: 'SDL_GetKeyName' returning: #string 
        args: #( #int )>! !
PK
     �Mh@M9��  �            ��    SDL_endian.stUT dqXOux �  �  PK
     �Mh@ɗX�              ��E  SDL_rwops.stUT eqXOux �  �  PK
     �Mh@U�c�  �            ���  SDL_name.stUT eqXOux �  �  PK
     �Mh@����  �            ��c&  SDL_syswm.stUT eqXOux �  �  PK
     �Mh@+(��0  0            ��:/  SDL_joystick.stUT dqXOux �  �  PK
     �Mh@�����  �            ���H  SDL.stUT dqXOux �  �  PK
     �[h@d9�_&  &            ���W  package.xmlUT ӉXOux �  �  PK
     �Mh@>�`Z�  �            ��N[  SDL_byteorder.stUT dqXOux �  �  PK
     �Mh@(�/q              ��Pb  SDL_mutex.stUT dqXOux �  �  PK
     �Mh@�p���  �            ���{  SDL_active.stUT dqXOux �  �  PK
     �Mh@�P{�-#  -#            ����  SDL_events.stUT dqXOux �  �  PK
     �Mh@�n�K9	  9	            ��1�  SDL_error.stUT dqXOux �  �  PK
     �Mh@���Ǥ  �            ����  SDL_mouse.stUT dqXOux �  �  PK
     �Mh@ΡX�@_  @_            ����  SDL_video.stUT eqXOux �  �  PK
     �Mh@o��sl  l            �� " SDL_keysym.stUT dqXOux �  �  PK
     �Mh@�e4�o  o            ���= SDL_timer.stUT eqXOux �  �  PK
     �Mh@d(IYX+  X+  
          ���J Display.stUT dqXOux �  �  PK
     �Mh@#^�ǵ  �            ��$v SDL_thread.stUT eqXOux �  �  PK
     �Mh@a�%��	  �	            �� � SDL_loadso.stUT dqXOux �  �  PK
     �Mh@8�w��)  �)            ��9� EventSource.stUT dqXOux �  �  PK
     �Mh@ n��  �            ��M� SDL_cpuinfo.stUT dqXOux �  �  PK
     �Mh@��I�  �            ���� SDL_keyboard.stUT dqXOux �  �  PK        ��   