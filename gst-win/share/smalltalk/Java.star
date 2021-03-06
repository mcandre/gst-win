PK
     �Mh@�1[Y  Y    java_net_InetAddress.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.net.InetAddress native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.net.InetAddress'!

java_net_InetAddress_aton_java_lang_String: arg1
    <javaNativeMethod: #'aton(Ljava/lang/String;)[B'
        for: #{Java.java.net.InetAddress} static: true>
    self notYetImplemented
!

java_net_InetAddress_lookup_java_lang_String: arg1 java_net_InetAddress: arg2 boolean: arg3
    <javaNativeMethod: #'lookup(Ljava/lang/String;Ljava/net/InetAddress;Z)[Ljava/net/InetAddress;'
        for: #{Java.java.net.InetAddress} static: true>
    self notYetImplemented
!

java_net_InetAddress_getFamily_byteArray: arg1
    <javaNativeMethod: #'getFamily([B)I'
        for: #{Java.java.net.InetAddress} static: true>
    self notYetImplemented
!

java_net_InetAddress_getLocalHostname
    <javaNativeMethod: #'getLocalHostname()Ljava/lang/String;'
        for: #{Java.java.net.InetAddress} static: true>
    self notYetImplemented
! !

PK
     �Mh@��
  �
    java_lang_System.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.System native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.System'!

java_lang_System_currentTimeMillis
    <javaNativeMethod: #'currentTimeMillis()J'
        for: #{Java.java.lang.System} static: true>
    ^Time millisecondClock javaAsLong
!

java_lang_System_arraycopy_java_lang_Object: arg1 int: arg2 java_lang_Object: arg3 int: arg4 int: arg5
    <javaNativeMethod: #'arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V'
        for: #{Java.java.lang.System} static: true>
    arg3 replaceFrom: arg4 + 1 to: arg4 + arg5 with: arg1 startingAt: arg2 + 1
!

java_lang_System_identityHashCode_java_lang_Object: arg1
    <javaNativeMethod: #'identityHashCode(Ljava/lang/Object;)I'
        for: #{Java.java.lang.System} static: true>
    ^arg1 identityHash
!

java_lang_System_isWordsBigEndian
    <javaNativeMethod: #'isWordsBigEndian()Z'
        for: #{Java.java.lang.System} static: true>
    ^Memory bigEndian ifTrue: [ 1 ] ifFalse: [ 0 ]
!

java_lang_System_setIn0_java_io_InputStream: arg1
    <javaNativeMethod: #'setIn0(Ljava/io/InputStream;)V'
        for: #{Java.java.lang.System} static: true>
    self in: arg1
!

java_lang_System_setOut0_java_io_PrintStream: arg1
    <javaNativeMethod: #'setOut0(Ljava/io/PrintStream;)V'
        for: #{Java.java.lang.System} static: true>
    self out: arg1
!

java_lang_System_setErr0_java_io_PrintStream: arg1
    <javaNativeMethod: #'setErr0(Ljava/io/PrintStream;)V'
        for: #{Java.java.lang.System} static: true>
    self err: arg1
! !

PK
     �Mh@�ʢ  �     java_nio_DirectByteBufferImpl.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.nio.DirectByteBufferImpl native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.nio.DirectByteBufferImpl'!

java_nio_DirectByteBufferImpl_allocateImpl_int: arg1
    <javaNativeMethod: #'allocateImpl(I)Lgnu/gcj/RawData;'
        for: #{Java.java.nio.DirectByteBufferImpl} static: true>
    "We map the gnu.gcj.RawData class to a Smalltalk CObject."
    ^CObject alloc: arg1 type: CByteType
!

java_nio_DirectByteBufferImpl_freeImpl_gnu_gcj_RawData: arg1
    <javaNativeMethod: #'freeImpl(Lgnu/gcj/RawData;)V'
        for: #{Java.java.nio.DirectByteBufferImpl} static: true>
    arg1 free
!

java_nio_DirectByteBufferImpl_getImpl_int: arg1
    <javaNativeMethod: #'getImpl(I)B'
        for: #{Java.java.nio.DirectByteBufferImpl} static: false>
    ^self address at: arg1
!

java_nio_DirectByteBufferImpl_putImpl_int: arg1 byte: arg2
    <javaNativeMethod: #'putImpl(IB)V'
        for: #{Java.java.nio.DirectByteBufferImpl} static: false>
    ^self address at: arg1 put: (arg2 bitAnd: 255)
! !
PK
     �Mh@���
  �
    java_lang_Float.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.Float native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.Float'!

java_lang_Float_floatToIntBits_float: arg1
    | v1 v12 |
    <javaNativeMethod: #'floatToIntBits(F)I'
        for: #{Java.java.lang.Float} static: true>

    "Handle NaN here."
    arg1 = arg1 ifFalse: [ ^16r7FC0_0000 ].
    v1 := ((arg1 at: 4) * 256 + (arg1 at: 3)) javaAsShort.
    v12 := (v1 * 256 + (arg1 at: 2)) * 256 + (arg1 at: 1).

    "Handle zero and infinity here."
    arg1 + arg1 = arg1 ifTrue: [ v12 := v12 bitAnd: 16r-80_0000 ].
    ^v12
!

java_lang_Float_floatToRawIntBits_float: arg1
    | v1 v2 |
    <javaNativeMethod: #'floatToRawIntBits(F)I'
        for: #{Java.java.lang.Float} static: true>
    v1 := ((arg1 at: 4) * 256 + (arg1 at: 3)) javaAsShort.
    v2 := (arg1 at: 2) * 256 + (arg1 at: 1).
    ^v1 * 65536 + v2
!

java_lang_Float_intBitsToFloat_int: arg1
    | s e m |
    <javaNativeMethod: #'intBitsToFloat(I)F'
        for: #{Java.java.lang.Float} static: true>

    "Extract sign and exponent"
    s := arg1 < 0 ifTrue: [ -1.0e ] ifFalse: [ 1.0e ].
    e := (arg1 bitShift: -23) bitAnd: 255.
    m := arg1 bitAnd: 16r7FFFFF.

    "Extract mantissa and check for infinity or NaN"
    e = 127 ifTrue: [
        ^m = 0
            ifTrue: [ 1.0e / (0.0e * s) ]
            ifFalse: [ (1.0e / 0.0e) - (1.0e / 0.0e) ].
    ].

    "Check for zero and denormals, then convert to a floating-point value"
    e = 0
        ifTrue: [ e := 1 ]
        ifFalse: [ m := m + 16r800000 ].

    ^m * s timesTwoPower: e - 150
! !
PK
     �Mh@�HD��	  �	    java_lang_Object.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.Object native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.Object'!

java_lang_Object_getClass
    <javaNativeMethod: #'getClass()Ljava/lang/Class;'
        for: #{Java.java.lang.Object} static: false>
    ^self class javaLangClass
!

java_lang_Object_hashCode
    <javaNativeMethod: #'hashCode()I'
        for: #{Java.java.lang.Object} static: false>
    ^self identityHash
!

java_lang_Object_notify
    | waitSemaphores |
    <javaNativeMethod: #'notify()V'
        for: #{Java.java.lang.Object} static: false>

    JavaMonitor notify: self!

java_lang_Object_notifyAll
    | waitSemaphores |
    <javaNativeMethod: #'notifyAll()V'
        for: #{Java.java.lang.Object} static: false>

    JavaMonitor notifyAll: self!

java_lang_Object_wait_long: arg1 int: arg2
    | s p waitSemaphores |
    <javaNativeMethod: #'wait(JI)V'
        for: #{Java.java.lang.Object} static: false>

    JavaMonitor waitOn: self timeout: arg1!

java_lang_Object_clone
    <javaNativeMethod: #'clone()Ljava/lang/Object;'
        for: #{Java.java.lang.Object} static: false>
    (self implementsInterface: Java.java.lang.Cloneable asJavaClass)
	ifFalse: [ JavaVM throw: Java.java.lang.CloneNotSupportedException ].

    ^self shallowCopy
! !

PK
     �Mh@&�N�  �    gnu_gcj_convert_IOConverter.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  gnu.gcj.convert.IOConverter native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'gnu.gcj.convert.IOConverter'!

gnu_gcj_convert_IOConverter_iconv_init
    <javaNativeMethod: #'iconv_init()Z'
        for: #{Java.gnu.gcj.convert.IOConverter} static: true>
    ^-1
! !

PK
     �Mh@x/���  �    gnu_gcj_runtime_StringBuffer.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  gnu.gcj.runtime.StringBuffer native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'gnu.gcj.runtime.StringBuffer'!

gnu_gcj_runtime_StringBuffer_append_int: arg1
    | s newValue needed |
    <javaNativeMethod: #'append(I)Lgnu/gcj/runtime/StringBuffer;'
        for: #{Java.gnu.gcj.runtime.StringBuffer} static: false>
    s := arg1 printString asByteArray.

    needed = self count + s size.
    self value size < needed ifTrue: [
        newValue := self value copyEmpty: (needed max: self value size * 2 + 2).
	newValue replaceFrom: 1 to: self count with: self value startingAt: 1.
	self value: newValue
    ].
    self value replaceFrom: self count + 1 to: needed with: s startingAt: 1.
    self count: needed.
    ^self
!

gnu_gcj_runtime_StringBuffer_toString
    <javaNativeMethod: #'toString()Ljava/lang/String;'
        for: #{Java.gnu.gcj.runtime.StringBuffer} static: false>
    ^Java.java.lang.String new
    	perform: #'<init>(Lgnu/gcj/runtime/StringBuffer;)V'
	with: self;

	yourself
! !
PK
     �Mh@����  �    java_lang_ConcreteProcess.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.ConcreteProcess native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.ConcreteProcess'!

java_lang_ConcreteProcess_destroy
    <javaNativeMethod: #'destroy()V'
        for: #{Java.java.lang.ConcreteProcess} static: false>
    self notYetImplemented
!

java_lang_ConcreteProcess_waitFor
    <javaNativeMethod: #'waitFor()I'
        for: #{Java.java.lang.ConcreteProcess} static: false>
    self notYetImplemented
!

java_lang_ConcreteProcess_startProcess_java_lang_StringArray: arg1 java_lang_StringArray: arg2 java_io_File: arg3
    <javaNativeMethod: #'startProcess([Ljava/lang/String;[Ljava/lang/String;Ljava/io/File;)V'
        for: #{Java.java.lang.ConcreteProcess} static: false>
    self notYetImplemented
! !

PK
     �Mh@jc  c  $  java_nio_channels_FileChannelImpl.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.nio.channels.FileChannelImpl native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.nio.channels.FileChannelImpl'!

java_nio_channels_FileChannelImpl_implPosition
    <javaNativeMethod: #'implPosition()J'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    ^self fd asFileDescriptor position
!

java_nio_channels_FileChannelImpl_implPosition_long: arg1
    | desc |
    <javaNativeMethod: #'implPosition(J)Ljava/nio/channels/FileChannel;'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    desc := self fd asFileDescriptor.
    desc position: (arg1 min: desc size)
!

java_nio_channels_FileChannelImpl_implTruncate_long: arg1
    | delta fd position |
    <javaNativeMethod: #'implTruncate(J)Ljava/nio/channels/FileChannel;'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    fd := self fd asFileDescriptor.
    delta := fd size - arg1.
    delta = 0 ifTrue: [ ^self ].
    delta < 0 ifTrue: [ fd position: arg1; truncate. ^self ].

    "If the file is too short, we extend it.  We can't rely on
     ftruncate() extending the file.  So we lseek() to 1 byte less
     than we want, and then we write a single byte at the end."
    position := fd position.
    fd position: arg1 - 1.
    fd write: #[0].
    fd position: position
!

java_nio_channels_FileChannelImpl_nio_mmap_file_long: arg1 long: arg2 int: arg3
    <javaNativeMethod: #'nio_mmap_file(JJI)Lgnu/gcj/RawData;'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    self notYetImplemented
!

java_nio_channels_FileChannelImpl_nio_unmmap_file_gnu_gcj_RawData: arg1 int: arg2
    <javaNativeMethod: #'nio_unmmap_file(Lgnu/gcj/RawData;I)V'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    self notYetImplemented
!

java_nio_channels_FileChannelImpl_nio_msync_gnu_gcj_RawData: arg1 int: arg2
    <javaNativeMethod: #'nio_msync(Lgnu/gcj/RawData;I)V'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    self notYetImplemented
!

java_nio_channels_FileChannelImpl_size
    <javaNativeMethod: #'size()J'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    ^self fd asFileDescriptor size
!

java_nio_channels_FileChannelImpl_implRead_byteArray: arg1 int: arg2 int: arg3
    | array count |
    <javaNativeMethod: #'implRead([BII)I'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    array := ByteArray new: arg3.
    count := self fd asFileDescriptor read: array from: 1 to: arg3.
    arg1 replaceFrom: arg1 + 1 to: arg1 + count with: array startingAt: 1.
    ^count
!

java_nio_channels_FileChannelImpl_implWrite_byteArray: arg1 int: arg2 int: arg3
    | array |
    <javaNativeMethod: #'implWrite([BII)I'
        for: #{Java.java.nio.channels.FileChannelImpl} static: false>
    array := ByteArray new: arg3.
    array replaceFrom: 1 to: arg3 with: arg1 startingAt: arg2 + 1.
    ^self fd asFileDescriptor write: array from: 1 to: arg3
! !

PK
     �Mh@Bd�  �     java_lang_reflect_Constructor.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.reflect.Constructor native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.reflect.Constructor'!

java_lang_reflect_Constructor_getModifiers
    <javaNativeMethod: #'getModifiers()I'
        for: #{Java.java.lang.reflect.Constructor} static: false>
    self notYetImplemented
!

java_lang_reflect_Constructor_newInstance_java_lang_ObjectArray: arg1
    <javaNativeMethod: #'newInstance([Ljava/lang/Object;)Ljava/lang/Object;'
        for: #{Java.java.lang.reflect.Constructor} static: false>
    self notYetImplemented
!

java_lang_reflect_Constructor_getType
    <javaNativeMethod: #'getType()V'
        for: #{Java.java.lang.reflect.Constructor} static: false>
    self notYetImplemented
! !

PK
     �Mh@-iWx�  �    gnu_java_nio_FileLockImpl.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  gnu.java.nio.FileLockImpl native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'gnu.java.nio.FileLockImpl'!

gnu_java_nio_FileLockImpl_releaseImpl
    <javaNativeMethod: #'releaseImpl()V'
        for: #{Java.gnu.java.nio.FileLockImpl} static: false>
    self notYetImplemented
! !
PK    �Mh@f,��  P    extract-native.awkUT	 dqXOd�XOux �  �  eTmO�0��_qu+JKH)�T�I�ڤ�d�˛l�����v����}o�=�҅�P&�]�xђ�r����L�U�-
bYd�)WxNR��.��R�H��.+Eln�g�P�b)y�a|UYx޷�˫�y�����0�6���t
�V�(ɗ��2
x&x�������o�z����<��F>0�[���-�y�{/_:c�tl ���牅�D�����p�C*�^�u �p��|�`�!3�w�m|�ø1>�1i�E��'��&�Rrc��`oFuiFP�]ň�H(����A�;�(����bC}�xZV��H�x'�9�1τ�Y�6�*E�ĉ�
x��)X�c_qP��k�%��`Y2� kic���m�9d�D���d�������IH��x���S�·���5�.�2�J�H������TwC�d���U����*i����h�7N�S�Ɓ%\.�L�8~A'�E"L1��*{dH�.���>��bz��1�QL7G W8�h���n|�1! ��K����`��b���_������Y��m���ݍM��ȑ,�r�;	{��)r{��4�<�ce[�P�G�%����h x�retL�b���d���?�Ag�3o�s���׍s�.
9�>����X����8K3+��Yz����H)�����c��H�E0�n�6@�1X��Z�'&��7�4`7n�'���}yg�DC^��B_ee*�E�(�H��t>�nXm����PK
     �Mh@��=��  �    java_lang_Math.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.Math native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.Math'!

java_lang_Math_sin_double: arg1
    <javaNativeMethod: #'sin(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 sin
!

java_lang_Math_cos_double: arg1
    <javaNativeMethod: #'cos(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 cos
!

java_lang_Math_tan_double: arg1
    <javaNativeMethod: #'tan(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 tan
!

java_lang_Math_asin_double: arg1
    <javaNativeMethod: #'asin(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 arcSin
!

java_lang_Math_acos_double: arg1
    <javaNativeMethod: #'acos(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 arcCos
!

java_lang_Math_atan_double: arg1
    <javaNativeMethod: #'atan(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 arcTan
!

java_lang_Math_atan2_double: arg1 double: arg2
    <javaNativeMethod: #'atan2(DD)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 arcTan: arg2
!

java_lang_Math_exp_double: arg1
    <javaNativeMethod: #'exp(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 exp
!

java_lang_Math_log_double: arg1
    <javaNativeMethod: #'log(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 ln
!

java_lang_Math_sqrt_double: arg1
    <javaNativeMethod: #'sqrt(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 sqrt
!

java_lang_Math_pow_double: arg1 double: arg2
    <javaNativeMethod: #'pow(DD)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 raisedTo: arg2
!

java_lang_Math_IEEEremainder_double: arg1 double: arg2
    <javaNativeMethod: #'IEEEremainder(DD)D'
        for: #{Java.java.lang.Math} static: true>
    arg2 = 0.0 ifTrue: [ ^FloatD nan ].
    arg1 = arg1 ifFalse: [ ^arg2 ].
    arg2 = arg2 ifFalse: [ ^arg2 ].
    ^arg1 rem: arg2
!

java_lang_Math_ceil_double: arg1
    <javaNativeMethod: #'ceil(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 ceiling
!

java_lang_Math_floor_double: arg1
    <javaNativeMethod: #'floor(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 floor
!

java_lang_Math_rint_double: arg1
    <javaNativeMethod: #'rint(D)D'
        for: #{Java.java.lang.Math} static: true>
    ^arg1 rounded
! !

PK
     �Mh@)qLc#  #    JavaExtensions.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  Extensions for base classes & JavaMetaobjects.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"

!JavaTranslatedExceptionHandlerTable methodsFor: 'finding exception handlers'!

value: context value: signal
    | pc low high mid first item |
    signal class == JavaException ifFalse: [ ^nil ].

    pc := context ip.
    low := 1.
    high := self size.

    "Do a binary search on the table to find a possible
     handler"
    [mid := (low + high) // 2.
    low > high ifTrue: [^nil].
    item := self at: mid.
    item includes: pc] whileFalse: 
	[item startpc < pc ifTrue: [low := mid + 1] ifFalse: [high := mid - 1]].

    "Go back to find the first one"
    first := mid.
    [ first > 1 and: [ (self at: first - 1) includes: pc ] ]
	whileTrue: [ first := first - 1 ].

    "Between the two, we can skip a range check"
    [
	item := self at: first.
	(item type isNil or: [ signal tag isKindOf: item type ])
	    ifTrue: [
		context at: self exceptionTemp put: signal tag.
		signal foundJavaHandler: item in: context.
		^#found ].

	first < mid
    ] whileTrue: [
	first := first + 1
    ].

    "Then we also have to check if the pc is ok."
    [
	first = self size ifTrue: [ ^nil ].
	first := first + 1.
	item := self at: first.
	(item includes: pc) ifFalse: [ ^nil ].
	(item type isNil or: [ signal tag isKindOf: item type ])
	    ifTrue: [
		context at: self exceptionTemp put: signal tag.
		signal foundJavaHandler: item in: context.
		^#found ].
    ] repeat.
! !

!JavaClass methodsFor: 'translation'!

install
    | theNamespace theSuperclass |
    self isLoaded ifFalse: [ self load ].

    theNamespace := self package asSmalltalkPackage.
    theSuperclass := self extends isNil 
    	ifTrue: [JavaObject]
    	ifFalse: 
    	    ["Try to reuse the namespace we found for this class, as
	      superclasses often reside in the same package as subclasses."
    	    self extends
    		asSmalltalkClassWithPackage: self package
    		associatedToNamespace: theNamespace].

    "Transcript show: 'Installing '; show: self fullName; nl."
    ^theSuperclass createSubclass: self into: theNamespace! !

!JavaClass methodsFor: 'translation'!

asSmalltalkClassWithPackage: knownPackage associatedToNamespace: smalltalkPackage
    | ourSmalltalkPackage smalltalkClass |
    ourSmalltalkPackage := package == knownPackage
        ifTrue: [ smalltalkPackage ]
        ifFalse: [ package asSmalltalkPackage ].

    smalltalkClass := ourSmalltalkPackage
	hereAt: self name asSymbol
	ifAbsent: [ nil ].

    smalltalkClass isNil ifTrue: [
	smalltalkClass := self install ].

    ^smalltalkClass!

asSmalltalkClass
    | smalltalkPackage smalltalkClass |
    smalltalkPackage := package asSmalltalkPackage.
    smalltalkClass := smalltalkPackage
	hereAt: self name asSymbol
	ifAbsent: [ nil ].

    smalltalkClass isNil ifTrue: [
	smalltalkClass := self install ].

    ^smalltalkClass! !

!JavaPackage methodsFor: 'translation'!

asSmalltalkPackage
    | containerSmalltalkPackage |
    self == Root ifTrue: [ ^Java ].

    containerSmalltalkPackage := self container asSmalltalkPackage.
    ^containerSmalltalkPackage
        at: self name asSymbol
        ifAbsent: [
            containerSmalltalkPackage addSubspace: self name asSymbol.
            containerSmalltalkPackage at: self name asSymbol ]
! !


!JavaStringPrototype methodsFor: 'bootstrap'!

convertToJavaLangString
    self makeReadOnly: false.
    ^self become: self stringValue asJavaString
! !

!String methodsFor: 'java'!

asJavaString
    ^Java.java.lang.String new
        perform: #'<init>([C)V' with: self
! !


!Number methodsFor: 'java conversion'!

javaCmpL: anInteger
    self = anInteger ifTrue: [ ^0 ].
    ^self > anInteger ifTrue: [ 1 ] ifFalse: [ -1 ]!

javaCmpG: anInteger
    self = anInteger ifTrue: [ ^0 ].
    ^self < anInteger ifTrue: [ -1 ] ifFalse: [ 1 ]!

javaAsByte
    | i |
    i := self asInteger bitAnd: 255.
    ^i < 128 ifTrue: [ i ] ifFalse: [ i - 256 ]!

javaAsShort
    | i |
    i := self asInteger bitAnd: 65535.
    ^i < 32768 ifTrue: [ i ] ifFalse: [ i - 65536 ]!

javaAsInt
    | i j |
    j := self asInteger.
    j size <= 4 ifTrue: [ ^j ].
    i := (j at: 4) < 128
	ifTrue: [ LargePositiveInteger new: 4 ]
	ifFalse: [ LargeNegativeInteger new: 4 ].

    i at: 1 put: (j at: 1).
    i at: 2 put: (j at: 2).
    i at: 3 put: (j at: 3).
    i at: 4 put: (j at: 4).
    ^i!

javaAsLong
    | i j |
    j := self asInteger.
    j size <= 8 ifTrue: [ ^j ].
    i := (j at: 8) < 128
	ifTrue: [ LargePositiveInteger new: 8 ]
	ifFalse: [ LargeNegativeInteger new: 8 ].

    i at: 1 put: (j at: 1).
    i at: 2 put: (j at: 2).
    i at: 3 put: (j at: 3).
    i at: 4 put: (j at: 4).
    i at: 5 put: (j at: 5).
    i at: 6 put: (j at: 6).
    i at: 7 put: (j at: 7).
    i at: 8 put: (j at: 8).
    ^i!

!Integer methodsFor: 'java arithmetic'!

javaCmp: anInteger
    self = anInteger ifTrue: [ ^0 ].
    ^self < anInteger ifTrue: [ -1 ] ifFalse: [ 1 ]!

javaAsByte
    | i |
    i := self bitAnd: 255.
    ^i < 128 ifTrue: [ i ] ifFalse: [ i - 256 ]!

javaAsShort
    | i |
    i := self bitAnd: 65535.
    ^i < 32768 ifTrue: [ i ] ifFalse: [ i - 65536 ]!

javaAsInt
    | i |
    i := (self at: 4) < 128
	ifTrue: [ LargePositiveInteger new: 4 ]
	ifFalse: [ LargeNegativeInteger new: 4 ].

    i at: 1 put: (self at: 1).
    i at: 2 put: (self at: 2).
    i at: 3 put: (self at: 3).
    i at: 4 put: (self at: 4).
    ^i!

javaAsLong
    | i |
    self size <= 8 ifTrue: [ ^self ].
    i := (self at: 8) < 128
	ifTrue: [ LargePositiveInteger new: 8 ]
	ifFalse: [ LargeNegativeInteger new: 8 ].

    i at: 1 put: (self at: 1).
    i at: 2 put: (self at: 2).
    i at: 3 put: (self at: 3).
    i at: 4 put: (self at: 4).
    i at: 5 put: (self at: 5).
    i at: 6 put: (self at: 6).
    i at: 7 put: (self at: 7).
    i at: 8 put: (self at: 8).
    ^i!

javaIushr: shift
    shift <= 0 ifTrue: [ ^self ].
    self > 0 ifTrue: [ ^self bitShift: 0 - shift ].
    ^(self bitShift: 0 - shift)
    	bitAnd: (16rFFFF_FFFF bitShift: 0 - shift)!

javaLushr: shift
    shift <= 0 ifTrue: [ ^self ].
    self > 0 ifTrue: [ ^self bitShift: 0 - shift ].
    ^(self bitShift: 0 - shift)
    	bitAnd: (16rFFFF_FFFF_FFFF_FFFF bitShift: 0 - shift)!

!SmallInteger methodsFor: 'java arithmetic'!

javaAsInt
    ^self!

javaAsLong
    ^self!

javaIushr: shift
    "Optimize the common case where we can avoid creating a
     LargeInteger."
    shift >= 2 ifTrue: [
        ^(self bitShift: 0 - shift)
    	    bitAnd: (16r3FFF_FFFF bitShift: 2 - shift) ].
    shift <= 0 ifTrue: [ ^self ].
    self > 0 ifTrue: [ ^self bitShift: 0 - shift ].
    ^(self bitShift: -1) bitAnd: 16r7FFF_FFFF!

javaLushr: shift
    "Optimize the case where we can avoid creating a LargeInteger."
    shift >= 34 ifTrue: [
        ^(self bitShift: 0 - shift)
    	    bitAnd: (16r3FFF_FFFF bitShift: 34 - shift) ].
    shift <= 0 ifTrue: [ ^self ].
    self > 0 ifTrue: [ ^self bitShift: 0 - shift ].
    ^(self bitShift: 0 - shift)
    	bitAnd: (16rFFFF_FFFF_FFFF_FFFF bitShift: 0 - shift)! !

!UndefinedObject methodsFor: 'JavaObject interoperability'!

checkCast: anObject
!

instanceOf: aClass
    ^0
! !

!Object class methodsFor: 'java arrays'!

javaNewArray: size
    <primitive: VMpr_Behavior_basicNewColon>
    size < 0 ifTrue: [
	^Java.gnu.smalltalk.JavaVM throw: Java.java.lang.NegativeArraySizeException ].
    self primitiveFailed!

!JavaType methodsFor: 'java arrays'!

javaMultiNewArray: sizes from: index
    | array size |
    (size := sizes at: index) < 0 ifTrue: [
	^JavaVM throw: Java.java.lang.NegativeArraySizeException ].

    array := self arrayClass new: size.
    index < sizes size ifTrue: [
	1 to: size do: [ :i |
	    array
		at: i
		put: (self subType javaMultiNewArray: sizes from: index + 1)]].
    ^array
! !
PK
     �Mh@F{      java_text_Collator.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.text.Collator native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.text.Collator'!

java_text_Collator_decomposeCharacter_char: arg1 java_lang_StringBuffer: arg2
    <javaNativeMethod: #'decomposeCharacter(CLjava/lang/StringBuffer;)V'
        for: #{Java.java.text.Collator} static: false>
    self notYetImplemented
! !

PK
     �Mh@%:{J      test.stUT	 dqXOe�XOux �  �  Namespace current: Java.gnu.smalltalk!
"FileStream fileIn: 'java/JavaRuntime.st'"!
Namespace current: Smalltalk!

(Java.java.lang.Math abs: -3) printNl!
(Java.java.lang.String valueOf: FloatD pi) asString printNl!
Java.java.lang.System out println: 'che figata'!
PK
     �Mh@�g `  `    gnu_gcj_runtime_StackTrace.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  gnu.gcj.runtime.StackTrace native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'gnu.gcj.runtime.StackTrace'!

gnu_gcj_runtime_StackTrace_classAt_int: arg1
    | ctx |
    <javaNativeMethod: #'classAt(I)Ljava/lang/Class;'
        for: #{Java.gnu.gcj.runtime.StackTrace} static: false>
    ctx := self addrs at: arg1 + 1 ifAbsent: [ nil ].
    ctx isNil ifTrue: [ ^nil ].
    "ctx receiver class gets the class or metaclass,
     asClass            gets the class also for static methods,
     javaLangClass      converts to a java.lang.Class"
    ^ctx receiver class asClass javaLangClass
!

gnu_gcj_runtime_StackTrace_methodAt_int: arg1
    | ctx |
    <javaNativeMethod: #'methodAt(I)Ljava/lang/String;'
        for: #{Java.gnu.gcj.runtime.StackTrace} static: false>
    ctx := self addrs at: arg1 + 1 ifAbsent: [ nil ].
    ctx isNil ifTrue: [ ^nil ].
    ^ctx selector asString
!

gnu_gcj_runtime_StackTrace_getClass_gnu_gcj_RawData: arg1
    <javaNativeMethod: #'getClass(Lgnu/gcj/RawData;)Ljava/lang/Class;'
        for: #{Java.gnu.gcj.runtime.StackTrace} static: true>
    self notYetImplemented
!

gnu_gcj_runtime_StackTrace_update
    <javaNativeMethod: #'update()V'
        for: #{Java.gnu.gcj.runtime.StackTrace} static: true>
!

gnu_gcj_runtime_StackTrace_fillInStackTrace_int: arg1 int: arg2
    | newAddrs ctx |
    <javaNativeMethod: #'fillInStackTrace(II)V'
        for: #{Java.gnu.gcj.runtime.StackTrace} static: false>
    newAddrs := Array new: (arg1 + arg2 - 1 max: self addrs size).
    newAddrs replaceFrom: 1 to: self addrs size with: self addrs startingAt: 1.
    self addrs: newAddrs.

    ctx := arg2 = 1 ifTrue: [ thisContext ] ifFalse: [ self addrs at: arg2 - 1 ].
    arg2 to: arg2 + arg1 - 1 do: [ :each |
	[
	    ctx := ctx parentContext.
	    ctx isNil ifTrue: [ self len: each - arg2 - 1. ^self len ].
	    ctx class isKindOf: JavaObject
	] whileFalse.
	newAddrs at: each put: ctx
    ].
    self len: arg1.
    ^arg1 + 1
!

gnu_gcj_runtime_StackTrace_getCompiledMethodRef_gnu_gcj_RawData: arg1
    <javaNativeMethod: #'getCompiledMethodRef(Lgnu/gcj/RawData;)Lgnu/gcj/runtime/MethodRef;'
        for: #{Java.gnu.gcj.runtime.StackTrace} static: true>
    self notYetImplemented
! !
PK
     �Mh@h@�&�% �%   JavaMetaobjects.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Metaobjects for Java: types, classes, methods, bytecodes
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Object subclass: #JavaReader
    instanceVariableNames: 'stream constantPool '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

Java.gnu.smalltalk.JavaReader comment: '
JavaReader is an abstract superclass for objects that deal with Java
data: it has methods for handling a constant pool and to read
big-endian or UTF8 values from a Stream.
 
Instance Variables:
    constantPool	<Collection>
	the constant pool from which to read strings and the like
    stream	<Stream>
	the Stream from which to read bytes

'!


Object subclass: #JavaProgramElement
    instanceVariableNames: 'flags name attributes '
    classVariableNames: 'Final Synthetic Protected FlagsStrings Private
    	Deprecated Volatile Synchronized Abstract Static Native Public
	Interface Transient ThreadSafe'
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaProgramElement comment: '
JavaProgramElement represents a Java class, field or method.  It
includes several methods to handle attributes and flags.

Subclasses should override #addAttribute: so that the most common
attributes are stored (more intuitively) in instance variables.

Instance Variables:
    attributes	<IdentityDictionary of: (Symbol -> JavaAttribute)>
	the attributes defined for this program element
    flags	<Integer>
	the access flags attached to this program element.
    name	<Symbol>
	the name of this program element.

'!


Object subclass: #JavaExceptionHandler
    instanceVariableNames: 'startpc length handlerpc type '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

Java.gnu.smalltalk.JavaExceptionHandler comment: '
JavaExceptionHandler represents one of the exception handlers that are
active within a method.

Instance Variables:
    handlerpc	<Integer>
	the program counter value at which the exception handler starts
    length	<Integer>
	the number of bytecodes for which the exception handler stays active.
    startpc	<Integer>
	the program counter value at which the exception handler becomes active.
    type	<JavaType | nil>
	the type of the exception that is caught, or nil for all exceptions

'!


JavaReader subclass: #JavaInstructionInterpreter
    instanceVariableNames: 'pc wide nPairs '
    classVariableNames: 'DecoderTable ArrayTypes'
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaInstructionInterpreter comment: '
JavaInstructionInterpreter knows the format of the bytecodes and
dispatches them to its own abstract methods.

Subclasses can override #interpret, for example to interpret only a
few bytecodes (see JavaEdgeCreator), or #dispatch: to execute
operations before and after the method for the bytecode is executed.

Instance Variables:
    nPairs	<Integer>
	used to parse lookupswitch
    pc	<Integer>
	the program counter at which the currently dispatched bytecode starts.
    wide	<Boolean>
	used to parse the ''wide'' opcode

'!


JavaProgramElement subclass: #JavaClass
    instanceVariableNames: 'fullName package extends implements methods fields constantPool sourceFile '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaClass comment: '
This class represent the full information available for a Java class,
read from a .class file.

Instance Variables:
    constantPool	<Array>
	the constant pool of the class, as read from the .class file
    extends	<JavaClass>
	the superclass of the class
    fields	<(Collection of: JavaField)>
	the list of fields in the class
    fullName	<String>
        the cached fully qualified name of the class
    implements	<(Collection of: JavaClass)>
	the list of interfaces that the class implements
    methods	<(Collection of: JavaMethod)>
	the list of methods that the class defines
    package	<JavaPackage>
	the package that holds the class
    sourceFile	<String>
	the Java source file in which the class is defined

'!


JavaProgramElement subclass: #JavaClassElement
    instanceVariableNames: 'signature javaClass '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaClassElement comment: '
JavaClassElement represents a Java field or method.  These both belong
to a class, and have a type or signature; however, they differ in the
set of supported attributes.

Instance Variables:
    javaClass	<Object>
	the class in which the field or method belongs.
    signature	<JavaType>
	the type or signature of the field or method.

'!


JavaClassElement subclass: #JavaMethod
    instanceVariableNames: 'maxStack maxLocals bytecodes exceptions handlers localVariables lines selector '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaMethod comment: '
JavaMethod represents a Java method.

Instance Variables:
    bytecodes	<ByteArray>
	see JavaCodeAttribute
    exceptions	<(Collection of: JavaClass)>
	see JavaCodeAttribute
    handlers	<(Collection of: JavaExceptionHandler)>
	see JavaCodeAttribute
    lines	<(SequenceableCollection of: Association)>
	see JavaLineNumberTableAttribute
    localVariables	<(Collection of: JavaLocalVariable)>
	see JavaLocalVariableTableAttribute
    maxLocals	<Integer>
	see JavaCodeAttribute
    maxStack	<Integer>
	see JavaCodeAttribute
    selector	<Symbol>
	the selector that is used in Smalltalk bytecodes.
'!


Object subclass: #JavaDescriptor
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaDescriptor comment: '
JavaDescriptor represents the constant-pool entries for names, types
or references to methods/fields.'!


JavaDescriptor subclass: #JavaRef
    instanceVariableNames: 'javaClass nameAndType '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaRef comment: '
JavaRef associates the class which defines it to the name and type of
a method or field.

Instance Variables:
    javaClass	<JavaClass>
	the class which defines the method or field
    nameAndType	<JavaDescriptor>
	the name and type of the method or field

'!


JavaRef subclass: #JavaFieldRef
    instanceVariableNames: 'getSelector putSelector'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaFieldRef comment: '
JavaFieldRef represents a reference to a Java field made within a method.
They are shared between methods in the same class, so the get/put
selectors are cached.

Instance Variables:
    getSelector		<Symbol>
        the selector used to do read accesses to the field
    putSelector		<Symbol>
        the selector used to do write accesses to the field'!

JavaRef subclass: #JavaMethodRef
    instanceVariableNames: 'selector'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaMethodRef comment: '
JavaMethodRef represents a reference to a Java method made from a
method invocation bytecode.

Instance Variables:
    selector		<Symbol>
        the selector used in the translated bytecodes'!

JavaDescriptor subclass: #JavaType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaType comment: '
JavaType is an abstract class for Java types or signatures.

Subclasses must implement the following messages:
    printing
    	printEncodingOn:		print the encoding of the type as found in .class files
'!


JavaType subclass: #JavaObjectType
    instanceVariableNames: 'javaClass '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaObjectType comment: '
JavaObjectType represents the type of instances of a Java class.

Instance Variables:
    javaClass	<JavaClass>
	the class whose type is represented by the object

'!


JavaType subclass: #JavaMethodType
    instanceVariableNames: 'returnType argTypes '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaMethodType comment: '
JavaMethodType represent the signature (types of the arguments, and
returned type) of a Java method.

Instance Variables:
    argTypes	<(Collection of: JavaType)>
	the method''s arguments'' type
    returnType	<JavaType>
	the method''s return type

'!


JavaType subclass: #JavaArrayType
    instanceVariableNames: 'subType '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaArrayType comment: '
JavaArrayType represents Java array types.

Instance Variables:
    subType	<JavaType>
	the type of each element of the array.

'!


JavaInstructionInterpreter subclass: #JavaInstructionPrinter
    instanceVariableNames: 'output localVariableTable lineNumberTable '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaInstructionPrinter comment: '
JavaInstructionPrinter can print a commented listing of Java bytecodes
on an output stream.

Instance Variables:
    output	<Stream>
	the stream on which to write
    lineNumberTable	<Stream>
	a stream on a sorted array of pc->line number pairs
    localVariableTable	<Array of: (SortedCollection of: JavaLocalVariable)>
	an array that groups the JavaLocalVariables for the method depending on the slot they refer to

'!


JavaDescriptor subclass: #JavaNameAndType
    instanceVariableNames: 'name type '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaNameAndType comment: '
JavaNameAndType associates the name of a field or method to its type.

Instance Variables:
    name	<Symbol>
	the name of the field or method
    type	<JavaType>
	the type or signature of the field or method

'!


JavaType subclass: #JavaPrimitiveType
    instanceVariableNames: 'id name wordSize zeroValue arrayClass '
    classVariableNames: 'JavaLong JavaShort JavaFloat JavaInt JavaChar
	JavaByte JavaVoid PrimitiveTypes JavaDouble JavaBoolean'
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaPrimitiveType comment: '
JavaPrimitiveType represents one of Java''s primitive types.
It has a fixed number of instances, all held in class variables.

Instance Variables:
    id	<Character>
	the one character representation of the type
    name	<String>
	the source code representation of the type (e.g. int)

'!


Object subclass: #JavaLocalVariable
    instanceVariableNames: 'startpc length name type slot '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

Java.gnu.smalltalk.JavaLocalVariable comment: '
JavaLocalVariable represents a local variable''s single liveness range
within a Java method.  If a Java compiler performs live range
splitting, in other words, there might be many JavaLocalVariable
instances for the same variable.

Instance Variables:

Instance Variables:
    length	<Integer>
	the number of bytecodes for which the variable becomes live
    name	<String>
	the name of the local variable
    slot	<Integer>
	the local variable slot in which the variable is stored
    startpc	<Integer>
	the program counter value at which the variable becomes live
    type	<JavaType>
	the type of the variable
'!


Object subclass: #JavaPackage
    instanceVariableNames: 'container contents name '
    classVariableNames: 'Root'
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaPackage comment: '
JavaPackage represents a Java package.

Instance Variables:
    container	<JavaPackage | nil>
	the package in which this package is contained
    contents	<Dictionary of: (Symbol -> (JavaPackage | JavaClass))>
	the contents of the package
    name	<Symbol>
	the name of the package

'!


JavaClassElement subclass: #JavaField
    instanceVariableNames: 'constantValue getSelector putSelector'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

Java.gnu.smalltalk.JavaField comment: '
JavaField represents a Java field within a class.

Instance Variables:
    constantValue	<Object | nil>
	the constant value for final fields, or nil
    getSelector		<Symbol>
        the selector used to do read accesses to the field
    putSelector		<Symbol>
        the selector used to do write accesses to the field'!


!JavaReader methodsFor: 'accessing'!

constantPool
    ^constantPool
!

constantPool: anObject
    constantPool := anObject
!

stream
    ^stream
!

stream: anObject
    stream := anObject.
! !

!JavaReader methodsFor: 'utility'!

next: n collect: aBlock
    ^self next: n collect: aBlock into: Array
!

next: n collect: aBlock into: aClass
    | result |
    result := aClass new: n.
    1 to: n do: [ :i | result at: i put: (aBlock value: result) ].
    ^result
! !

!JavaReader methodsFor: 'stream accessing'!

nextByte
    "Read a 32-bit quantity from the input stream."

    ^stream next asInteger
!

nextBytes: anInteger
    "Read a 32-bit quantity from the input stream."

    | ba |
    ba := ByteArray new: anInteger.
    1 to: anInteger do: [ :i | ba at: i put: stream next asInteger ].
    ^ba
!

nextConstant
    | index |
    index := self nextUshort.
    ^index = 0 ifTrue: [ nil ] ifFalse: [ self constantPool at: index ]
!

nextDouble
    "Read a 64-bit floating-point quantity from the input stream."

    | m1 m2 m3 m4 m5 m6 m7 m8 s e m |
    m1 := stream next asInteger.
    m2 := stream next asInteger.
    m3 := stream next asInteger.
    m4 := stream next asInteger.
    m5 := stream next asInteger.
    m6 := stream next asInteger.
    m7 := stream next asInteger.
    m8 := stream next asInteger.

    "Extract sign and exponent"
    s := m1 > 128 ifTrue: [ -1.0d ] ifFalse: [ 1.0d ].
    e := (m1 bitAnd: 127) * 16 + ((m2 bitAnd: 240) bitShift: -4).

    "Extract mantissa and check for infinity or NaN"
    m := (((((((m2 bitAnd: 15) bitShift: 8) + m3
        bitShift: 8) + m4
        bitShift: 8) + m5
        bitShift: 8) + m6
        bitShift: 8) + m7
        bitShift: 8) + m8.

    e = 16r7FF ifTrue: [
        ^m = 0
	    ifTrue: [ 1.0d / (0.0d * s) ]
	    ifFalse: [ (1.0d / 0.0d) - (1.0d / 0.0d) ].
    ].

    "Check for zero and denormals, then convert to a floating-point value"
    e = 0
        ifTrue: [ e := 1 ]
        ifFalse: [ m := m + 16r10000000000000 ].

    ^m * s timesTwoPower: e - 1075
!

nextFloat
    "Read a 32-bit floating-point quantity from the input stream."

    | m1 m2 m3 m4 s e m |
    m1 := stream next asInteger.
    m2 := stream next asInteger.
    m3 := stream next asInteger.
    m4 := stream next asInteger.

    "Extract sign and exponent"
    s := m1 > 128 ifTrue: [ -1.0e ] ifFalse: [ 1.0e ].
    e := m1 * 2 + ((m2 bitAnd: 128) bitShift: -7).

    "Extract mantissa and check for infinity or NaN"
    m := (((m2 bitAnd: 127) bitShift: 8) + m3 bitShift: 8) + m4.
    e = 127 ifTrue: [
        ^m = 0
	    ifTrue: [ 1.0e / (0.0e * s) ]
	    ifFalse: [ (1.0e / 0.0e) - (1.0e / 0.0e) ].
    ].

    "Check for zero and denormals, then convert to a floating-point value"
    e = 0
        ifTrue: [ e := 1 ]
        ifFalse: [ m := m + 16r800000 ].

    ^m * s timesTwoPower: e - 150
!

nextInt
    "Read a 32-bit quantity from the input stream."

    | m1 m2 m3 m4 |
    m1 := stream next asInteger.
    m2 := stream next asInteger.
    m3 := stream next asInteger.
    m4 := stream next asInteger.
    m1 >= 128 ifTrue: [m1 := m1 - 256].
    ^(((m1 bitShift: 8) + m2
        bitShift: 8) + m3
        bitShift: 8) + m4
!

nextLong
    "Read a 32-bit quantity from the input stream."

    | m1 m2 m3 m4 m5 m6 m7 m8 |
    m1 := stream next asInteger.
    m2 := stream next asInteger.
    m3 := stream next asInteger.
    m4 := stream next asInteger.
    m5 := stream next asInteger.
    m6 := stream next asInteger.
    m7 := stream next asInteger.
    m8 := stream next asInteger.
    m1 >= 128 ifTrue: [m1 := m1 - 256].
    ^(((((((m1 bitShift: 8) + m2
    	bitShift: 8) + m3
    	bitShift: 8) + m4 
    	bitShift: 8) + m5 
    	bitShift: 8) + m6 
    	bitShift: 8) + m7 
    	bitShift: 8) + m8
!

nextShort
    "Answer the next two bytes from the receiver as an Integer."

    | high low |
    high := stream next asInteger.
    low := stream next asInteger.
    high >= 128 ifTrue: [ high := high - 256 ].
    ^(high bitShift: 8) + low
!

nextSignedByte
    "Answer the next two bytes from the receiver as an Integer."

    | byte |
    byte := stream next asInteger.
    ^byte >= 128 ifTrue: [ byte - 256 ] ifFalse: [ byte ]
!

nextUint
    "Read a 32-bit quantity from the input stream."

    | m1 m2 m3 m4 |
    m1 := stream next asInteger.
    m2 := stream next asInteger.
    m3 := stream next asInteger.
    m4 := stream next asInteger.
    ^(((((m1 bitShift: 8) + m2) bitShift: 8) + m3) bitShift: 8) + m4
!

nextUlong
    "Read a 32-bit quantity from the input stream."

    | m1 m2 m3 m4 m5 m6 m7 m8 |
    m1 := stream next asInteger.
    m2 := stream next asInteger.
    m3 := stream next asInteger.
    m4 := stream next asInteger.
    m5 := stream next asInteger.
    m6 := stream next asInteger.
    m7 := stream next asInteger.
    m8 := stream next asInteger.
    ^(((((((m1 bitShift: 8) + m2
    	bitShift: 8) + m3
    	bitShift: 8) + m4 
    	bitShift: 8) + m5 
    	bitShift: 8) + m6 
    	bitShift: 8) + m7 
    	bitShift: 8) + m8
!

nextUshort
    "Answer the next two bytes from the receiver as an Integer."

    | high low |
    high := stream next asInteger.
    low := stream next asInteger.
    ^(high bitShift: 8) + low
!

nextUTF8Char
    "Read a 32-bit quantity from the input stream."

    ^self nextUTF8Value asCharacter
!

nextUTF8String
    "Read a 32-bit quantity from the input stream."
    | s bytes finalPosition |
    bytes := self nextUshort.
    s := (String new: bytes) writeStream.
    finalPosition := stream position + bytes.
    [ stream position < finalPosition ] whileTrue: [ s nextPut: self nextUTF8Char ].
    ^s contents
!

nextUTF8Value
    "Read a 32-bit quantity from the input stream."

    | first |
    first := stream next asInteger.
    first <= 2r01111111 ifTrue: [ ^first ].
    first <= 2r11011111 ifTrue: [ ^(first - 2r11000000) * 64 + (stream next asInteger bitAnd: 63) ].
    first <= 2r11101111 ifTrue: [ ^((first - 2r11100000) * 4096) + ((stream next asInteger bitAnd: 63) * 64) + (stream next asInteger bitAnd: 63) ].
    self error: 'invalid UTF-8 character'
! !

!JavaReader class methodsFor: 'instance creation'!

on: aStream
    ^self new
    stream: aStream;
    yourself
! !

!JavaProgramElement methodsFor: 'initializing'!

initialize
    self flags: 0.
! !

!JavaProgramElement methodsFor: 'accessing'!

addAttribute: aJavaAttribute 
    aJavaAttribute class == JavaDeprecatedAttribute 
    ifTrue: 
    [self addDeprecated.
    ^aJavaAttribute].
    attributes isNil ifTrue: [attributes := LookupTable new].
    attributes at: aJavaAttribute attributeName put: aJavaAttribute.
    ^aJavaAttribute
!

addFlag: aFlag 
    self flags: (self flags bitOr: aFlag)
!

attributes
    ^attributes
!

attributes: anObject
    attributes := nil.
    anObject do: [ :each | self addAttribute: each ]
!

flags
    ^flags
!

flags: allFlags
    flags := allFlags
!

is: flag
    ^(self flags bitAnd: flag) == flag
!

isAny: flag
    ^(self flags bitAnd: flag) > 0
!

name
    ^name
!

name: anObject
    name := anObject asSymbol
!

removeFlag: aFlag 
    self flags: (self flags bitAnd: aFlag bitInvert)
! !

!JavaProgramElement methodsFor: 'accessing flags'!

addAbstract
    self addFlag: Abstract
!

addDeprecated
    self addFlag: Deprecated
!

addFinal
    self addFlag: Final
!

addNative
    self addFlag: Native
!

addStatic
    self addFlag: Static
!

addSynchronized
    self addFlag: Synchronized
!

addSynthetic
    self addFlag: Synthetic
!

addTransient
    self addFlag: Transient
!

addVolatile
    self addFlag: Volatile
!

beClass
    self removeFlag: Interface
!

beInterface
    self addFlag: Interface
!

bePackageVisible
    self removeFlag: Protected.
    self removeFlag: Private.
    self removeFlag: Public
!

bePrivate
    self removeFlag: Protected.
    self removeFlag: Public.
    self addFlag: Private
!

beProtected
    self removeFlag: Private.
    self removeFlag: Public.
    self addFlag: Protected
!

bePublic
    self removeFlag: Protected.
    self removeFlag: Private.
    self addFlag: Public
!

isAbstract
    ^self is: Abstract
!

isDeprecated
    ^self is: Deprecated
!

isFinal
    ^self is: Final
!

isInterface
    ^self is: Interface
!

isNative
    ^self is: Native
!

isPackageVisible
    ^(self isAny: Protected + Private + Public) not
!

isPrivate
    ^self is: Private
!

isProtected
    ^self is: Protected
!

isPublic
    ^self is: Public
!

isStatic
    ^self is: Static
!

isSynchronized
    ^self is: Synchronized
!

isSynthetic
    ^self is: Synthetic
!

isThreadSafe
    ^self isAny: ThreadSafe
!

isTransient
    ^self is: Transient
!

isVolatile
    ^self is: Volatile
!

removeAbstract
    self removeFlag: Abstract
!

removeDeprecated
    self removeFlag: Deprecated
!

removeFinal
    self removeFlag: Final
!

removeNative
    self removeFlag: Native
!

removeStatic
    self removeFlag: Static
!

removeSynchronized
    self removeFlag: Synchronized
!

removeSynthetic
    self removeFlag: Synthetic
!

removeThreadSafe
    self removeFlag: ThreadSafe
!

removeTransient
    self removeFlag: Transient
!

removeVolatile
    self removeFlag: Volatile
! !

!JavaProgramElement methodsFor: 'printing'!

print: flag on: aStream
    (self is: flag) ifTrue: [
        aStream
            nextPutAll: (FlagsStrings at: flag);
            space
    ]
!

printFlagsOn: aStream 
    | bit |
    bit := 1.
    [FlagsStrings includesKey: bit] whileTrue: 
    		[self print: bit on: aStream.
    		bit := bit * 2]
!

printOn: aStream 
    self printFlagsOn: aStream
! !

!JavaProgramElement class methodsFor: 'initializing'!

initialize
    "self initialize"
    Public := 1.
    Private := 2.
    Protected := 4.
    Static := 8.
    Final := 16.
    Synchronized := 32.
    Volatile := 64.
    ThreadSafe := 96.
    Transient := 128.
    Native := 256.
    Interface := 512.
    Abstract := 1024.
    Synthetic := 2048.
    Deprecated := 4096.
    FlagsStrings := LookupTable new.
    self classPool keysAndValuesDo: [ :k :v |
        v isInteger
            ifTrue: [ FlagsStrings at: v put: k asString asLowercase ]
    ]
! !

!JavaProgramElement class methodsFor: 'instance creation'!

new
    ^self basicNew initialize
! !

!JavaExceptionHandler methodsFor: 'accessing'!

finalpc
    ^self startpc + self length
!

finalpc: anObject
    length := anObject - self startpc
!

handlerpc
    ^handlerpc
!

handlerpc: anObject
    handlerpc := anObject
!

includes: pc
    ^pc >= self startpc
	and: [ pc < (self startpc + self length) ]
!

isFinallyHandler
    ^self type isNil
!

length
    ^length
!

length: anObject
    length := anObject
!

startpc
    ^startpc
!

startpc: anObject
    startpc := anObject
!

type
    ^type
!

type: anObject
    type := anObject
! !

!JavaExceptionHandler methodsFor: 'printing'!

printOn: s
    s nextPutAll: 'handler for '.
    self type isNil
    	ifTrue: [ s nextPutAll: 'all exceptions' ]
	ifFalse: [
	    self type isClass
	    	ifTrue: [ self type storeOn: s ]
		ifFalse: [ self type printFullNameOn: s ] ].

    s nextPutAll: ' at '; print: self handlerpc.
    s nextPutAll: ', active between '; print: self startpc.
    s nextPutAll: ' and '; print: self finalpc
! !

!JavaExceptionHandler class methodsFor: 'instance creation'!

startpc: startpc finalpc: finalpc handlerpc: handlerpc type: type
    ^self new
    startpc: startpc;
    length: finalpc - startpc;
    handlerpc: handlerpc;
    type: type;
    yourself
! !

!JavaInstructionInterpreter methodsFor: 'interpretation'!

dispatch
    pc := stream position.
    self dispatch: self nextByte.
!

dispatch: insn 
    | op spec |
    spec := DecoderTable at: insn + 1 ifAbsent: [nil].
    spec isNil ifTrue: [spec := Array with: #invalid: with: insn].
    op := spec first.
    spec size = 1 
    	ifTrue: 
    		[self perform: op.
    		^op].
    spec size = 2 
    	ifTrue: 
[Smalltalk debug.
    		self perform: op with: (self getArg: (spec at: 2)).
    		^op].
    spec size = 3 
    	ifTrue: 
    		[self 
    			perform: op
    			with: (self getArg: (spec at: 2))
    			with: (self getArg: (spec at: 3)).
    		^op].
    spec size = 4 
    	ifTrue: 
    		[self 
    			perform: op
    			with: (self getArg: (spec at: 2))
    			with: (self getArg: (spec at: 3))
    			with: (self getArg: (spec at: 4)).
    		^op].
    self perform: op
    	withArguments: (Array 
    			with: (self getArg: (spec at: 2))
    			with: (self getArg: (spec at: 3))
    			with: (self getArg: (spec at: 4))
    			with: (self getArg: (spec at: 5))).
    ^op
!

interpret
    [stream atEnd] whileFalse: [self dispatch]
!

nextPC
    ^stream position
!

nextPC: position
    stream position: position
! !

!JavaInstructionInterpreter methodsFor: 'operand decoding'!

arrayTypeByte
    ^ArrayTypes at: self nextByte ifAbsent: [ #bad ]
!

constIndexByte
    ^self constantPool at: self nextByte
!

constIndexShort
    ^self constantPool at: self nextUshort
!

defaultSwitchAddress
    | newPC |
    newPC := pc.
    
    [newPC := newPC + 1.
    newPC \\ 4 > 0] whileTrue: [stream next].
    ^self nextInt + pc
!

getArg: n
    ^n isSymbol
    	ifFalse: [ n ]
    	ifTrue: [ self perform: n ]
!

highValue
    | value |
    value := self nextInt.
    nPairs := value - nPairs + 1.
    ^value
!

localIndexByte
    ^wide ifTrue: [ self nextUshort ] ifFalse: [ self nextByte ]
!

lookupSwitchBytes
    nPairs := self nextUint.
    ^(1 to: nPairs) collect: [ :each | self nextInt -> (self nextInt + pc) ]
!

lowValue
    ^nPairs := self nextInt
!

signedBranchShort
    ^self nextShort + pc
!

signedByte
    ^wide ifTrue: [ self nextShort ] ifFalse: [ self nextSignedByte ]
!

tableSwitchBytes
    ^(1 to: nPairs) collect: [ :each | self nextInt + pc ]
! !

!JavaInstructionInterpreter methodsFor: 'bytecodes'!

aaload!
aastore!
aconst: operand!
aload: operand!
anewarray: operand!
areturn!
arraylength!
astore: operand!
athrow!
baload!
bastore!
bipush: operand!
caload!
castore!
checkcast: operand!
d2f!
d2i!
d2l!
dadd!
daload!
dastore!
dcmpg!
dcmpl!
dconst: operand!
ddiv!
dload: operand!
dmul!
dneg!
drem!
dreturn!
dstore: operand!
dsub!
dup!
dup2!
dup2_x1!
dup2_x2!
dup_x1!
dup_x2!
f2d!
f2i!
f2l!
fadd!
faload!
fastore!
fcmpg!
fcmpl!
fconst: operand!
fdiv!
fload: operand!
fmul!
fneg!
frem!
freturn!
fstore: operand!
fsub!
getfield: operand!
getstatic: operand!
goto: operand!
i2d!
i2f!
i2l!
iadd!
iaload!
iand!
iastore!
iconst: operand!
idiv!
ifeq: operand!
ifge: operand!
ifgt: operand!
ifle: operand!
iflt: operand!
ifne: operand!
ifnonnull: operand!
ifnull: operand!
if_acmpeq: operand!
if_acmpne: operand!
if_icmpeq: operand!
if_icmpge: operand!
if_icmpgt: operand!
if_icmple: operand!
if_icmplt: operand!
if_icmpne: operand!
iinc: operand by: amount!
iload: operand!
imul!
ineg!
instanceof: operand!
int2byte!
int2char!
int2short!
invokeinterface: operand nargs: args reserved: reserved!
invokenonvirtual: operand!
invokestatic: operand!
invokevirtual: operand!
ior!
irem!
ireturn!
ishl!
ishr!
istore: operand!
isub!
iushr!
ixor!
jsr: operand!
l2d!
l2f!
l2i!
ladd!
laload!
land!
lastore!
lcmp!
lconst: operand!
ldc2: operand!
ldc: operand!
ldiv!
lload: operand!
lmul!
lneg!
lookupswitch: default destinations: dest!
lor!
lrem!
lreturn!
lshl!
lshr!
lstore: operand!
lsub!
lushr!
lxor!
monitorenter!
monitorexit!
multianewarray: operand dimensions: dimensions!
new: operand!
newarray: operand!
nop!
pop!
pop2!
putfield: operand!
putstatic: operand!
ret: operand!
return!
saload!
sastore!
sipush: operand!
swap!
tableswitch: default low: low high: high destinations: addresses!

wide
    "Unlike other methods in this protocol, this one need not be overridden by subclasses,
     and in fact subclasses should invoke this implementation ('super wide')"
    wide := true
! !

!JavaInstructionInterpreter methodsFor: 'initialization'!

initialize
    wide := false.
    pc := 0.
! !

!JavaInstructionInterpreter class methodsFor: 'interpreting'!

interpret: aJavaMethod
    (self onMethod: aJavaMethod) interpret
!

new
    ^super new initialize
!

onMethod: aJavaMethod
    ^(self on: aJavaMethod bytecodes readStream)
    	constantPool: aJavaMethod constantPool;
    	yourself
!

onSameMethodAs: aJavaInstructionInterpreter
    ^(self on: aJavaInstructionInterpreter stream copy)
    	constantPool: aJavaInstructionInterpreter constantPool;
    	yourself
! !

!JavaInstructionInterpreter class methodsFor: 'initializing'!

initialize
    ArrayTypes := Array new: 11.
    ArrayTypes at: 1 put: (JavaType fromString: 'Ljava/lang/Object;').
    ArrayTypes at: 4 put: JavaPrimitiveType boolean.
    ArrayTypes at: 5 put: JavaPrimitiveType char.
    ArrayTypes at: 6 put: JavaPrimitiveType float.
    ArrayTypes at: 7 put: JavaPrimitiveType double.
    ArrayTypes at: 8 put: JavaPrimitiveType byte.
    ArrayTypes at: 9 put: JavaPrimitiveType short.
    ArrayTypes at: 10 put: JavaPrimitiveType int.
    ArrayTypes at: 11 put: JavaPrimitiveType long.

    DecoderTable := #(
    (#nop)                                   "0"
    (#aconst: nil)                           "1"
    (#iconst: -1)                             "2"
    (#iconst: 0)                              "3"
    (#iconst: 1)                              "4"
    (#iconst: 2)                              "5"
    (#iconst: 3)                              "6"
    (#iconst: 4)                              "7"
    (#iconst: 5)                              "8"
    (#lconst: 0)                              "9"
    
    (#lconst: 1)                              "10"
    (#fconst: 0)                              "11"
    (#fconst: 1)                              "12"
    (#fconst: 2)                              "13"
    (#dconst: 0)                              "14"
    (#dconst: 1)                              "15"
    (#bipush: #signedByte)                     "16"
    (#sipush: #nextShort)                    "17"
    (#ldc: #constIndexByte)              "18"
    (#ldc: #constIndexShort)             "19"

    (#ldc2: #constIndexShort)            "20"
    (#iload: #localIndexByte)                  "21"
    (#lload: #localIndexByte)                  "22"
    (#fload: #localIndexByte)                  "23"
    (#dload: #localIndexByte)                  "24"
    (#aload: #localIndexByte)                  "25"
    (#iload: 0)                               "26"
    (#iload: 1)                               "27"
    (#iload: 2)                               "28"
    (#iload: 3)                               "29"

    (#lload: 0)                               "30"
    (#lload: 1)                               "31"
    (#lload: 2)                               "32"
    (#lload: 3)                               "33"
    (#fload: 0)                               "34"
    (#fload: 1)                               "35"
    (#fload: 2)                               "36"
    (#fload: 3)                               "37"
    (#dload: 0)                               "38"
    (#dload: 1)                               "39"

    (#dload: 2)                               "40"
    (#dload: 3)                               "41"
    (#aload: 0)                               "42"
    (#aload: 1)                               "43"
    (#aload: 2)                               "44"
    (#aload: 3)                               "45"
    (#iaload)                                "46"
    (#laload)                                "47"
    (#faload)                                "48"
    (#daload)                                "49"

    (#aaload)                                "50"
    (#baload)                                "51"
    (#caload)                                "52"
    (#saload)                                "53"
    (#istore: #localIndexByte)                 "54"
    (#lstore: #localIndexByte)                 "55"
    (#fstore: #localIndexByte)                 "56"
    (#dstore: #localIndexByte)                 "57"
    (#astore: #localIndexByte)                 "58"
    (#istore: 0)                              "59"

    (#istore: 1)                              "60"
    (#istore: 2)                              "61"
    (#istore: 3)                              "62"
    (#lstore: 0)                              "63"
    (#lstore: 1)                              "64"
    (#lstore: 2)                              "65"
    (#lstore: 3)                              "66"
    (#fstore: 0)                              "67"
    (#fstore: 1)                              "68"
    (#fstore: 2)                              "69"

    (#fstore: 3)                              "70"
    (#dstore: 0)                              "71"
    (#dstore: 1)                              "72"
    (#dstore: 2)                              "73"
    (#dstore: 3)                              "74"
    (#astore: 0)                              "75"
    (#astore: 1)                              "76"
    (#astore: 2)                              "77"
    (#astore: 3)                              "78"
    (#iastore)                               "79"

    (#lastore)                               "80"
    (#fastore)                               "81"
    (#dastore)                               "82"
    (#aastore)                               "83"
    (#bastore)                               "84"
    (#castore)                               "85"
    (#sastore)                               "86"
    (#pop)                                   "87"
    (#pop2)                                  "88"
    (#dup)                                   "89"

    (#dup_x1)                                "90"
    (#dup_x2)                                "91"
    (#dup2)                                  "92"
    (#dup2_x1)                               "93"
    (#dup2_x2)                               "94"
    (#swap)                                  "95"
    (#iadd)                                  "96"
    (#ladd)                                  "97"
    (#fadd)                                  "98"
    (#dadd)                                  "99"

    (#isub)                                  "100"
    (#lsub)                                  "101"
    (#fsub)                                  "102"
    (#dsub)                                  "103"
    (#imul)                                  "104"
    (#lmul)                                  "105"
    (#fmul)                                  "106"
    (#dmul)                                  "107"
    (#idiv)                                  "108"
    (#ldiv)                                  "109"

    (#fdiv)                                  "110"
    (#ddiv)                                  "111"
    (#irem)                                  "112"
    (#lrem)                                  "113"
    (#frem)                                  "114"
    (#drem)                                  "115"
    (#ineg)                                  "116"
    (#lneg)                                  "117"
    (#fneg)                                  "118"
    (#dneg)                                  "119"

    (#ishl)                                  "120"
    (#lshl)                                  "121"
    (#ishr)                                  "122"
    (#lshr)                                  "123"
    (#iushr)                                 "124"
    (#lushr)                                 "125"
    (#iand)                                  "126"
    (#land)                                  "127"
    (#ior)                                   "128"
    (#lor)                                   "129"

    (#ixor)                                  "130"
    (#lxor)                                  "131"
    (#iinc:by: #localIndexByte #signedByte)  "132"
    (#i2l)                                   "133"
    (#i2f)                                   "134"
    (#i2d)                                   "135"
    (#l2i)                                   "136"
    (#l2f)                                   "137"
    (#l2d)                                   "138"
    (#f2i)                                   "139"

    (#f2l)                                   "140"
    (#f2d)                                   "141"
    (#d2i)                                   "142"
    (#d2l)                                   "143"
    (#d2f)                                   "144"
    (#int2byte)                              "145"
    (#int2char)                              "146"
    (#int2short)                             "147"
    (#lcmp)                                  "148"
    (#fcmpl)                                 "149"

    (#fcmpg)                                 "150"
    (#dcmpl)                                 "151"
    (#dcmpg)                                 "152"
    (#ifeq: #signedBranchShort)                "153"
    (#ifne: #signedBranchShort)                "154"
    (#iflt: #signedBranchShort)                "155"
    (#ifge: #signedBranchShort)                "156"
    (#ifgt: #signedBranchShort)                "157"
    (#ifle: #signedBranchShort)                "158"
    (#if_icmpeq: #signedBranchShort)           "159"

    (#if_icmpne: #signedBranchShort)           "160"
    (#if_icmplt: #signedBranchShort)           "161"
    (#if_icmpge: #signedBranchShort)           "162"
    (#if_icmpgt: #signedBranchShort)           "163"
    (#if_icmple: #signedBranchShort)           "164"
    (#if_acmpeq: #signedBranchShort)           "165"
    (#if_acmpne: #signedBranchShort)           "166"
    (#goto: #signedBranchShort)                "167"
    (#jsr: #signedBranchShort)                 "168"
    (#ret: #localIndexByte)                    "169"

    (#tableswitch:low:high:destinations: #defaultSwitchAddress #lowValue #highValue #tableSwitchBytes)          "170"
    (#lookupswitch:destinations: #defaultSwitchAddress #lookupSwitchBytes)        "171"
    (#ireturn)                               "172"
    (#lreturn)                               "173"
    (#freturn)                               "174"
    (#dreturn)                               "175"
    (#areturn)                               "176"
    (#return)                                "177"
    (#getstatic: #constIndexShort)               "178"
    (#putstatic: #constIndexShort)               "179"

    (#getfield: #constIndexShort)                 "180"
    (#putfield: #constIndexShort)                 "181"
    (#invokevirtual: #constIndexShort)       "182"
    (#invokenonvirtual: #constIndexShort) "183"
    (#invokestatic: #constIndexShort)         "184"
    (#invokeinterface:nargs:reserved: #constIndexShort #nextByte #nextByte)"185"
    nil                           "186"
    (#new: #constIndexShort)      "187"
    (#newarray: #arrayTypeByte)                "188"
    (#anewarray: #constIndexShort)             "189"

    (#arraylength)                           "190"
    (#athrow)                "191"
    (#checkcast: #constIndexShort)             "192"
    (#instanceof: #constIndexShort)            "193"
    (#monitorenter)                          "194"
    (#monitorexit)                           "195"
    (#wide)                                  "196"
    (#multianewarray:dimensions: #constIndexShort #nextByte) "197"
    (#ifnull:    #signedBranchShort)           "198"
    (#ifnonnull: #signedBranchShort)           "199"

    (#goto: #signedBranchLong)            "200"
    (#jsr: #signedBranchShort))
! !

!JavaClass methodsFor: 'printing'!

fullName
    | stream |
    fullName isNil ifTrue: [
        stream := WriteStream on: (String new: 20).
        self printFullNameOn: stream.
        fullName := stream contents ].

    ^fullName
!

printEncodingOn: aStream
    self package printEncodingOn: aStream.
    aStream nextPut: $/; nextPutAll: self name.
    aStream nextPut: $;
!

printExtendsClauseOn: aStream 
    self isInterface ifTrue: [ ^nil ].
    self extends isNil ifTrue: [ ^nil ].
    aStream
    	nl;
    	nextPutAll: '    extends '.
    self extends printFullNameOn: aStream
!

printFieldsOn: aStream 
    (self fields isNil or: [self fields isEmpty]) ifTrue: [^self].
    aStream nl.
    self fields do: 
    		[:each | 
    		aStream
    			nextPutAll: '    ';
    			print: each]
!

printFullNameOn: aStream
    (self package isNil or: [ self package  == JavaPackage root ]) ifFalse: [
    self package printOn: aStream.
    aStream nextPut: $.
    ].
    aStream nextPutAll: self name
!

printImplementsClauseOn: aStream 
    (self implements isNil or: [self implements isEmpty]) ifTrue: [^self].
    aStream nl.
    self isInterface 
    	ifTrue: [aStream nextPutAll: '    extends ']
    	ifFalse: [aStream nextPutAll: '    implements '].
    self implements do: [:interface | interface printFullNameOn: aStream]
    	separatedBy: [aStream nextPutAll: ', ']
!

printMethodsOn: aStream 
    (self methods isNil or: [self methods isEmpty]) ifTrue: [^self].
    aStream nl.
    self methods do: 
    		[:each | 
    		aStream
    			nextPutAll: '    ';
    			print: each].
!

printOn: aStream 
    self printFlagsOn: aStream.
    self isInterface ifFalse: [aStream nextPutAll: 'class '].
    self printFullNameOn: aStream.
    self printExtendsClauseOn: aStream.
    self printImplementsClauseOn: aStream.
    aStream nl; nextPut: ${.
    self printFieldsOn: aStream.
    self printMethodsOn: aStream.
    aStream nextPut: $}
! !

!JavaClass methodsFor: 'private-accessing'!

package: anObject
    package := anObject
! !

!JavaClass methodsFor: 'accessing'!

classDefiningField: name
    | class |
    "Accesses to static fields of implemented interfaces are compiled as
     getstatic bytecodes for Intf.field, not for ClassImplementingIntf.field,
     so we need the (slower) recursion on the implemented interfaces only
     when we are in an interface."
    self isInterface ifTrue: [ ^self interfaceDefiningField: name ].

    class := self.
    [ class isNil or: [ (class definesField: name) ] ] whileFalse: [
    	class := class extends ].
    ^class
!

interfaceDefiningField: name
    (self definesField: name) ifTrue: [ ^self ].
    ^self implements
    	detect: [ :each | (each interfaceDefiningField: name) notNil ]
	ifNone: [ nil ]
!

implementsInterface: anInterface
    | c |
    c := self.
    [
	(c implements includes: anInterface) ifTrue: [ ^true ].
	(c implements anySatisfy: [ :each |
	     each implementsInterface: anInterface ]) ifTrue: [ ^true ].

	c := c extends.
	c isNil
    ] whileFalse.
    ^false!

constantPool
    ^constantPool
!

constantPool: anObject
    constantPool := anObject
!

extends
    ^extends
!

extends: anObject
    extends := anObject
!

fieldAt: aString
    ^fields at: aString
!

fieldAt: aString ifAbsent: aBlock
    ^fields at: aString ifAbsent: aBlock
!

definesField: aString
    fields isNil ifTrue: [ ^false ].
    ^fields includesKey: aString
!

fields
    ^fields
!

fields: aJavaFieldCollection
    fields := LookupTable new: aJavaFieldCollection size * 3 // 2.
    aJavaFieldCollection do: [ :each |
    	each javaClass: self.
	fields at: each name put: each ]
!

flags: allFlags
    "Reset the ACC_SUPER flag"
    flags := allFlags bitAnd: 32 bitInvert
!

implements
    ^implements
!

implements: anObject
    implements := anObject
!

isJavaClass
    ^true
!

isJavaPackage
    ^false
!

isLoaded
    ^constantPool notNil
!

methodAt: aString
    ^methods at: aString
!

methodAt: aString ifAbsent: aBlock
    ^methods at: aString ifAbsent: aBlock
!

definesMethod: aJavaNameAndType
    methods isNil ifTrue: [ ^false ].
    ^methods includesKey:
    	(JavaMethod
	    selectorFor: aJavaNameAndType name
	    type: aJavaNameAndType type)
!

methods
    ^methods
!

methods: aJavaMethodCollection
    methods := IdentityDictionary new: aJavaMethodCollection size * 3 // 2.
    aJavaMethodCollection do: [ :each |
    	each javaClass: self.
	methods at: each selector put: each ]
!

package
    ^package
!

sourceFile
    ^sourceFile
!

sourceFile: anObject
    sourceFile := anObject
! !

!JavaClass class methodsFor: 'instance creation'!

fromString: aString
    | path symbolName aPackage |
    path := aString subStrings: $/.
    aPackage := JavaPackage root.
    path from: 1 to: path size - 1 do: [ :each |
        aPackage := aPackage packageAt: each asSymbol ].

    symbolName := path last asSymbol.
    ^aPackage classAt: symbolName ifAbsentPut: [self new
        package: aPackage;
        name: symbolName;
        yourself]
!

package: aPackage name: className
    | symbolName |
    symbolName := className asSymbol.
    ^aPackage at: symbolName put: (self new
    package: aPackage;
    name: className;
    yourself)
! !

!JavaClassElement methodsFor: 'comparing'!

= anObject
    ^self class == anObject class and: [
	self flags == anObject flags and: [
	self javaClass == anObject javaClass and: [
	self name = anObject name ]]]
!

hash
    ^self name hash bitXor: self javaClass identityHash
! !

!JavaClassElement methodsFor: 'printing'!

printHeadingOn: aStream 
    self printFlagsOn: aStream.
    self signature printOn: aStream withName: name
!

printOn: aStream 
    self printHeadingOn: aStream
! !

!JavaClassElement methodsFor: 'accessing'!

addAttribute: aJavaAttribute 
    aJavaAttribute class == JavaSyntheticAttribute 
    ifTrue: 
	[self addSynthetic.
	^aJavaAttribute].
    ^super addAttribute: aJavaAttribute
!

javaClass
    ^javaClass
!

javaClass: anObject
    javaClass := anObject
!

signature
    ^signature
!

signature: anObject
    signature := anObject
! !

!JavaMethod methodsFor: 'accessing'!

addAttribute: aJavaAttribute 
    "This should handle the Code attribute's subattributes as well
     (JavaLineNumberTableAttribute and JavaLocalVariableTableAttribute);
     see also the #code: method."
    aJavaAttribute class == JavaCodeAttribute 
        ifTrue: 
            [self code: aJavaAttribute.
            ^aJavaAttribute].
    aJavaAttribute class == JavaLineNumberTableAttribute 
        ifTrue: 
            [self lines: aJavaAttribute lines.
            ^aJavaAttribute].
    aJavaAttribute class == JavaLocalVariableTableAttribute 
        ifTrue: 
            [self localVariables: aJavaAttribute localVariables.
            ^aJavaAttribute].
    aJavaAttribute class == JavaExceptionsAttribute 
        ifTrue: 
            [self exceptions: aJavaAttribute exceptions.
            ^aJavaAttribute].
    ^super addAttribute: aJavaAttribute
!

argTypes
    ^self signature argTypes
!

bytecodes
    ^bytecodes
!

bytecodes: anObject
    bytecodes := anObject
!

code: aJavaCodeAttribute
    self
        maxLocals: aJavaCodeAttribute maxLocals;
        maxStack: aJavaCodeAttribute maxStack;
        bytecodes: aJavaCodeAttribute bytecodes;
        handlers: aJavaCodeAttribute handlers.

    aJavaCodeAttribute attributes do: [ :each |
        self addAttribute: each ]
!

constantPool
    ^javaClass constantPool
!

exceptions
    ^exceptions
!

exceptions: anObject
    exceptions := anObject
!

handlers
    ^handlers
!

handlers: anObject
    handlers := anObject
!

lines
    ^lines
!

lines: anObject
    lines := anObject
!

localVariables
    ^localVariables
!

localVariables: anObject
    localVariables := anObject
!

maxLocals
    ^maxLocals
!

maxLocals: anObject
    maxLocals := anObject
!

maxStack
    ^maxStack
!

maxStack: anObject
    maxStack := anObject
!

numArgs
    ^self signature numArgs
!

returnType
    ^self signature returnType
! !

!JavaMethod methodsFor: 'printing'!

printBytecodesOn: s 
    s
    	tab;
    	nextPutAll: 'bytecodes: ';
    	nl.
    JavaInstructionPrinter print: self on: s
!

printHandlersOn: s 
    (self handlers notNil and: [self handlers notEmpty]) 
    	ifTrue: 
    		[self handlers do: 
    				[:each | 
    				s
    					tab;
    					print: each;
    					nl]]
!

printHeadingOn: s 
    super printHeadingOn: s.
    self exceptions isNil ifTrue: [^self].
    s
    	nl;
    	tab;
    	nextPutAll: 'throws '.
    self exceptions do: [:each | each printFullNameOn: s]
    	separatedBy: [s nextPutAll: ', ']
!

printLimitsOn: s 
    s
    	tab;
    	nextPutAll: 'maxStack: ';
    	print: self maxStack;
    	nextPutAll: ' maxLocals:';
    	print: self maxLocals;
    	nl
!

printOn: s 
    self printHeadingOn: s.
    self bytecodes isNil
    	ifTrue: 
    		[s nextPut: $;; nl.
    		^self].
    s
    	nextPutAll: ' {';
    	nl.
    self printLimitsOn: s.
    self printHandlersOn: s.
    self printBytecodesOn: s.
    s
    	nextPutAll: '    }';
    	nl
! !

!JavaMethod methodsFor: 'source'!

firstLine
    ^self lines first value
!

lastLine
    ^self lines inject: 0 into: [ :max :assoc | max max: assoc value ]
! !

!JavaMethod methodsFor: 'creating'!

selector
    selector isNil ifTrue: [
    	selector := self class selectorFor: self name type: self signature ].
    ^selector
! !

!JavaMethod class methodsFor: 'creating'!

selectorFor: name type: type
    ^(name, type asString) asSymbol
! !

!JavaDescriptor methodsFor: 'testing'!

isMethodSignature
    ^false
! !

!JavaRef methodsFor: 'accessing'!

isMethodSignature
    ^nameAndType isMethodSignature
!

javaClass
    ^javaClass
!

javaClass: anObject
    javaClass := anObject
!

name
    ^self nameAndType name
!

nameAndType
    ^nameAndType
!

nameAndType: anObject
    nameAndType := anObject
!

type
    ^self nameAndType type
!

wordSize
    ^self type wordSize
! !

!JavaRef methodsFor: 'printing'!

printOn: aStream 
    self nameAndType type
        printOn: aStream
        withName: self javaClass fullName , '.' , self nameAndType name
! !

!JavaRef class methodsFor: 'instance creation'!

javaClass: aJavaClass nameAndType: nameAndType
    ^self new
        javaClass: aJavaClass;
        nameAndType: nameAndType;
        yourself
! !

!JavaFieldRef methodsFor: 'accessing'!

getSelector
    getSelector isNil ifTrue: [
    	getSelector := JavaField
	    getSelectorFor: self name
	    in: (self javaClass classDefiningField: self name) ].
    ^getSelector!

putSelector
    putSelector isNil ifTrue: [
    	putSelector := JavaField
	    putSelectorFor: self name
	    in: (self javaClass classDefiningField: self name) ].
    ^putSelector! !

!JavaMethodRef methodsFor: 'accessing'!

argTypes
    ^self type argTypes
!

isVoid
    ^self returnType isVoid
!

numArgs
    ^self type numArgs
!

returnType
    ^self type returnType
!

selector
    selector isNil ifTrue: [
    	selector := JavaMethod selectorFor: self name type: self type ].
    ^selector
!

wordSize
    ^self returnType wordSize
! !

!JavaType methodsFor: 'accessing'!

initializationValue
    ^nil
!

isArrayType
    ^false
!

isPrimitiveType
    ^false
! !

!JavaType methodsFor: 'printing'!


asString
    | stream |
    stream := WriteStream on: (String new: 20).
    self printEncodingOn: stream.
    ^stream contents
!

fullName
    | stream |
    stream := WriteStream on: (String new: 20).
    self printFullNameOn: stream.
    ^stream contents
!

printEncodingOn: aStream
    self subclassResponsibility
!

printFullNameOn: aStream
    self printOn: aStream.
!

printOn: aStream withName: aString
    aStream print: self; space; nextPutAll: aString.
!

storeOn: aStream
    aStream
    nextPut: $(;
    print: self class;
    nextPutAll: ' fromString: ';
    store: self asString;
    nextPut: $)
! !

!JavaType methodsFor: 'jvm quirks'!

arrayClass
    ^Array
!

wordSize
    self subclassResponsibility
! !

!JavaType methodsFor: 'testing'!

isVoid
    ^false
!

isArrayType
    ^false
! !

!JavaType class methodsFor: 'instance creation'!

fromString: aString
    ^self readFrom: aString readStream
!

readFrom: aStream
    (aStream peek = $() ifTrue: [ ^JavaMethodType readFrom: aStream ].
    (aStream peek = $[) ifTrue: [ ^JavaArrayType readFrom: aStream ].
    (aStream peek = $L) ifTrue: [ ^JavaObjectType readFrom: aStream ].
    ^JavaPrimitiveType readFrom: aStream
! !

!JavaObjectType methodsFor: 'accessing'!

javaClass
    ^javaClass
!

javaClass: anObject
    javaClass := anObject
! !

!JavaObjectType methodsFor: 'printing'!

printEncodingOn: aStream
    aStream nextPut: $L.
    self javaClass printEncodingOn: aStream.
!

printOn: aStream
    self javaClass printFullNameOn: aStream! !

!JavaObjectType methodsFor: 'jvm quirks'!

wordSize
    ^1
! !

!JavaObjectType class methodsFor: 'instance creation'!

javaClass: aJavaClass
    ^self new javaClass: aJavaClass
!

readFrom: aStream
    (aStream peekFor: $L) ifFalse: [ self error: 'expected L' ].
    ^self javaClass: (JavaClass fromString: (aStream upTo: $;))
! !

!JavaMethodType methodsFor: 'printing'!

printEncodingOn: aStream
    aStream nextPut: $(.
    self argTypes do: [ :each | each printEncodingOn: aStream ].
    aStream nextPut: $).
    self returnType printEncodingOn: aStream
!

printOn: aStream
    self printOn: aStream withName: '*'
!

printOn: aStream withName: aString
    aStream
    print: self returnType;
    space;
    nextPutAll: aString;
    nextPutAll: ' ('.

    self argTypes
    do: [ :each | aStream print: each ]
    separatedBy: [ aStream nextPutAll: ', ' ].

    aStream nextPut: $)
! !

!JavaMethodType methodsFor: 'accessing'!

argTypes
    ^argTypes
!

argTypes: anObject
    argTypes := anObject
!

numArgs
    ^argTypes size
!

returnType
    ^returnType
!

returnType: anObject
    returnType := anObject
! !

!JavaMethodType methodsFor: 'testing'!

isMethodSignature
    ^true
! !

!JavaMethodType methodsFor: 'jvm quirks'!

wordSize
    self shouldNotImplement
! !

!JavaMethodType class methodsFor: 'instance creation'!

readFrom: aStream
    | argTypes returnType |
    argTypes := OrderedCollection new.
    (aStream peekFor: $() ifFalse: [ self error: 'expected (' ].
    [ aStream peekFor: $) ] whileFalse: [
    argTypes addLast: (JavaType readFrom: aStream) ].

    returnType := JavaType readFrom: aStream.
    ^self new
    argTypes: argTypes asArray;
    returnType: returnType;
    yourself
! !

!JavaArrayType methodsFor: 'accessing'!

arrayDimensionality
    | n t |
    n := 1.
    t := self subType.
    [ t isArrayType ] whileTrue: [
	n := n + 1.
        t := self subType ].
    ^n
!

isArrayType
    ^true
!

subType
    ^subType
!

subType: anObject
    subType := anObject
! !

!JavaArrayType methodsFor: 'printing'!

printEncodingOn: aStream
    aStream nextPut: $[.
    self subType printEncodingOn: aStream
!

printOn: aStream
    self subType printOn: aStream.
    aStream nextPutAll: '[]'
!

printOn: aStream withName: aString
    self subType printOn: aStream withName: aString.
    aStream nextPutAll: '[]'
! !

!JavaArrayType methodsFor: 'jvm quirks'!

wordSize
    ^1
! !

!JavaArrayType methodsFor: 'testing'!

isArrayType
    ^true
! !

!JavaArrayType class methodsFor: 'instance creation'!

readFrom: aStream
    (aStream peekFor: $[) ifFalse: [ self error: 'expected [' ].
    ^self new subType: (JavaType readFrom: aStream)
! !

!JavaInstructionPrinter methodsFor: 'accessing'!

output
    ^output
!

output: anObject
    output := anObject
! !

!JavaInstructionPrinter methodsFor: 'initialize'!

groupLocalVariables: localVariables 
    localVariables do: [:each || collection |
	(collection := localVariableTable at: each slot + 1) isNil 
    	    ifTrue: 
    		[collection := SortedCollection sortBlock: [:a :b | a startpc < b startpc].
		localVariableTable
		    at: each slot + 1
    		    put: collection ].
	collection add: each]
!

initialize: aJavaMethod 
    | sortedLineNumbers |
    self
    	stream: aJavaMethod bytecodes readStream;
    	constantPool: aJavaMethod constantPool.

    sortedLineNumbers := aJavaMethod lines isNil 
    	ifTrue: [#()]
    	ifFalse: [(aJavaMethod lines asSortedCollection: [:a :b | a value <= b value]) asArray].
    lineNumberTable := sortedLineNumbers readStream.

    localVariableTable := Array new: aJavaMethod maxLocals + 1.
    aJavaMethod localVariables isNil
    	ifFalse: [ self groupLocalVariables: aJavaMethod localVariables ]
! !

!JavaInstructionPrinter methodsFor: 'bytecodes'!

aaload
    output nextPutAll: 'aaload'.
!

aastore
    output nextPutAll: 'aastore'.
!

aconst: operand
    output nextPutAll: 'aconst '; print: operand.
!

aload: operand
    output nextPutAll: 'aload '.
    self printLocalVariable: operand.
!

anewarray: operand
    output nextPutAll: 'anewarray '.
    operand printFullNameOn: output
!

areturn
    output nextPutAll: 'areturn'.
!

arraylength
    output nextPutAll: 'arraylength'.
!

astore: operand
    output nextPutAll: 'astore '.
    self printLocalVariable: operand.
!

athrow
    output nextPutAll: 'athrow'.
!

baload
    output nextPutAll: 'baload'.
!

bastore
    output nextPutAll: 'bastore'.
!

bipush: operand
    output nextPutAll: 'bipush '; print: operand
!

caload
    output nextPutAll: 'caload'.
!

castore
    output nextPutAll: 'castore'.
!

checkcast: operand
    output nextPutAll: 'checkcast '.
    operand printFullNameOn: output
!

d2f
    output nextPutAll: 'd2f'
!

d2i
    output nextPutAll: 'd2i'
!

d2l
    output nextPutAll: 'd2l'
!

dadd
    output nextPutAll: 'dadd'
!

daload
    output nextPutAll: 'daload'.
!

dastore
    output nextPutAll: 'dastore'.
!

dcmpg
    output nextPutAll: 'dcmpg'
!

dcmpl
    output nextPutAll: 'dcmpl'
!

dconst: operand
    output nextPutAll: 'dconst '; print: operand
!

ddiv
    output nextPutAll: 'ddiv'
!

dload: operand
    output nextPutAll: 'dload '.
    self printLocalVariable: operand.
!

dmul
    output nextPutAll: 'dmul'
!

dneg
    output nextPutAll: 'dneg'
!

drem
    output nextPutAll: 'drem'
!

dreturn
    output nextPutAll: 'dreturn'
!

dstore: operand
    output nextPutAll: 'dstore '.
    self printLocalVariable: operand.
!

dsub
    output nextPutAll: 'dsub'
!

dup
    output nextPutAll: 'dup'
!

dup2
    output nextPutAll: 'dup2'
!

dup2_x1
    output nextPutAll: 'dup2_x1'
!

dup2_x2
    output nextPutAll: 'dup2_x2'
!

dup_x1
    output nextPutAll: 'dup_x1'
!

dup_x2
    output nextPutAll: 'dup_x2'
!

f2d
    output nextPutAll: 'f2d'
!

f2i
    output nextPutAll: 'f2i'
!

f2l
    output nextPutAll: 'f2l'
!

fadd
    output nextPutAll: 'fadd'
!

faload
    output nextPutAll: 'faload'.
!

fastore
    output nextPutAll: 'fastore'.
!

fcmpg
    output nextPutAll: 'fcmpg'
!

fcmpl
    output nextPutAll: 'fcmpl'
!

fconst: operand
    output nextPutAll: 'fconst '; print: operand
!

fdiv
    output nextPutAll: 'fdiv'
!

fload: operand
    output nextPutAll: 'fload '.
    self printLocalVariable: operand.
!

fmul
    output nextPutAll: 'fmul'
!

fneg
    output nextPutAll: 'fneg'
!

frem
    output nextPutAll: 'frem'
!

freturn
    output nextPutAll: 'freturn'
!

fstore: operand
    output nextPutAll: 'fstore '.
    self printLocalVariable: operand.
!

fsub
    output nextPutAll: 'fsub'
!

getfield: operand
    output nextPutAll: 'getfield <'; print: operand; nextPut: $>
!

getstatic: operand
    output nextPutAll: 'getstatic <'; print: operand; nextPut: $>
!

goto: operand
    output nextPutAll: 'goto '; print: operand
!

i2d
    output nextPutAll: 'i2d'
!

i2f
    output nextPutAll: 'i2f'
!

i2l
    output nextPutAll: 'i2l'
!

iadd
    output nextPutAll: 'iadd'
!

iaload
    output nextPutAll: 'iaload'.
!

iand
    output nextPutAll: 'iand'
!

iastore
    output nextPutAll: 'iastore'.
!

iconst: operand
    output nextPutAll: 'iconst '; print: operand
!

idiv
    output nextPutAll: 'idiv'
!

ifeq: operand
    output nextPutAll: 'ifeq '; print: operand
!

ifge: operand
    output nextPutAll: 'ifge '; print: operand
!

ifgt: operand
    output nextPutAll: 'ifgt '; print: operand
!

ifle: operand
    output nextPutAll: 'ifle '; print: operand
!

iflt: operand
    output nextPutAll: 'iflt '; print: operand
!

ifne: operand
    output nextPutAll: 'ifne '; print: operand
!

ifnonnull: operand
    output nextPutAll: 'ifnonnull '; print: operand
!

ifnull: operand
    output nextPutAll: 'ifnull '; print: operand
!

if_acmpeq: operand
    output nextPutAll: 'if_acmpeq '; print: operand
!

if_acmpne: operand
    output nextPutAll: 'if_acmpne '; print: operand
!

if_icmpeq: operand
    output nextPutAll: 'if_icmpeq '; print: operand
!

if_icmpge: operand
    output nextPutAll: 'if_icmpge '; print: operand
!

if_icmpgt: operand
    output nextPutAll: 'if_icmpgt '; print: operand
!

if_icmple: operand
    output nextPutAll: 'if_icmple '; print: operand
!

if_icmplt: operand
    output nextPutAll: 'if_icmplt '; print: operand
!

if_icmpne: operand
    output nextPutAll: 'if_icmpne '; print: operand
!

iinc: operand by: amount
    output nextPutAll: 'inc '.
    self printLocalVariable: operand.
    output nextPutAll: ', '; print: amount
!

iload: operand
    output nextPutAll: 'iload '.
    self printLocalVariable: operand.
!

imul
    output nextPutAll: 'imul'
!

ineg
    output nextPutAll: 'ineg'
!

instanceof: operand
    output nextPutAll: 'instanceof '.
    operand printFullNameOn: output
!

int2byte
    output nextPutAll: 'int2byte'
!

int2char
    output nextPutAll: 'int2char'
!

int2short
    output nextPutAll: 'int2short'
!

invokeinterface: operand nargs: args reserved: reserved 
    output
    nextPutAll: 'invokeinterface <';
    print: operand;
    nextPutAll: '> (';
    print: args;
    nextPutAll: ' arguments)'
!

invokenonvirtual: operand
    output nextPutAll: 'invokenonvirtual <'; print: operand; nextPut: $>
!

invokestatic: operand
    output nextPutAll: 'invokestatic <'; print: operand; nextPut: $>
!

invokevirtual: operand
    output nextPutAll: 'invokevirtual <'; print: operand; nextPut: $>
!

ior
    output nextPutAll: 'ior'
!

irem
    output nextPutAll: 'irem'
!

ireturn
    output nextPutAll: 'ireturn'
!

ishl
    output nextPutAll: 'ishl'
!

ishr
    output nextPutAll: 'ishr'
!

istore: operand
    output nextPutAll: 'istore '.
    self printLocalVariable: operand.
!

isub
    output nextPutAll: 'isub'
!

iushr
    output nextPutAll: 'iushr'
!

ixor
    output nextPutAll: 'ixor'
!

jsr: operand
    output nextPutAll: 'jsr '; print: operand
!

l2d
    output nextPutAll: 'l2d'
!

l2f
    output nextPutAll: 'l2f'
!

l2i
    output nextPutAll: 'l2i'
!

ladd
    output nextPutAll: 'ladd'
!

laload
    output nextPutAll: 'laload'.
!

land
    output nextPutAll: 'land'
!

lastore
    output nextPutAll: 'lastore'.
!

lcmp
    output nextPutAll: 'lcmp'.
!

lconst: operand
    output nextPutAll: 'lconst '; print: operand
!

ldc2: operand
    output nextPutAll: 'ldc2 '; print: operand
!

ldc: operand
    output nextPutAll: 'ldc '; print: operand
!

ldiv
    output nextPutAll: 'ldiv'
!

lload: operand
    output nextPutAll: 'lload '.
    self printLocalVariable: operand.
!

lmul
    output nextPutAll: 'lmul'
!

lneg
    output nextPutAll: 'lneg'
!

lookupswitch: default destinations: dest
    output nextPutAll: 'lookupswitch '; print: dest; nextPutAll: ', default '; print: default
!

lor
    output nextPutAll: 'lor'
!

lrem
    output nextPutAll: 'lrem'
!

lreturn
    output nextPutAll: 'lreturn'
!

lshl
    output nextPutAll: 'lshl'
!

lshr
    output nextPutAll: 'lshr'
!

lstore: operand
    output nextPutAll: 'lstore '.
    self printLocalVariable: operand.
!

lsub
    output nextPutAll: 'lsub'
!

lushr
    output nextPutAll: 'lushr'
!

lxor
    output nextPutAll: 'lxor'
!

monitorenter
    output nextPutAll: 'monitorenter'
!

monitorexit
    output nextPutAll: 'monitorexit'
!

multianewarray: operand dimensions: dimensions
    output nextPutAll: 'multianewarray '; print: operand; nextPutAll: ', '; print: dimensions
!

new: operand
    output nextPutAll: 'new '.
    operand printFullNameOn: output
!

newarray: operand
    output nextPutAll: 'newarray '; print: operand
!

nop
    output nextPutAll: 'nop'
!

pop
    output nextPutAll: 'pop'
!

pop2
    output nextPutAll: 'pop2'
!

putfield: operand
    output nextPutAll: 'putfield <'; print: operand; nextPut: $>
!

putstatic: operand
    output nextPutAll: 'putstatic <'; print: operand; nextPut: $>
!

ret: operand
    output nextPutAll: 'ret '; print: operand
!

return
    output nextPutAll: 'return'.
!

saload
    output nextPutAll: 'saload'.
!

sastore
    output nextPutAll: 'sastore'.
!

sipush: operand
    output nextPutAll: 'sipush '; print: operand
!

swap
    output nextPutAll: 'swap'
!

tableswitch: default low: low high: high destinations: addresses 
    ^self lookupswitch: default
    	destinations: ((1 to: high - low + 1) 
    			collect: [:i | low + i - 1 -> (addresses at: i)])
! !

!JavaInstructionPrinter methodsFor: 'interpretation'!

dispatch: insn 
    output
    	tab;
    	print: pc;
    	tab.
    super dispatch: insn.
    self printCurrentLine.
    output nl
!

printCurrentLine
    
    lineNumberTable atEnd ifTrue: [^self].
    lineNumberTable peek key > pc ifTrue: [ ^self ].
    output
    	tab;
    	nextPutAll: '// source line ';
    	print: lineNumberTable next value
!

printLocalVariable: index
    | coll low high mid item |
    index printOn: output.
    coll := localVariableTable at: index + 1.
    low := 1.
    high := coll size.
    
    [mid := (low + high) // 2.
    low > high ifTrue: [^nil].
    item := coll at: mid.
    item includes: pc] 
    		whileFalse: 
    			[item startpc < pc ifTrue: [low := mid + 1] ifFalse: [high := mid - 1]].

    output nextPutAll: ' ('; nextPutAll: item name; nextPut: $)
! !

!JavaInstructionPrinter class methodsFor: 'printing methods'!

print: aJavaMethod on: outputStream
    (self on: aJavaMethod bytecodes readStream)
    initialize: aJavaMethod;
    output: outputStream;
    interpret
! !

!JavaNameAndType methodsFor: 'accessing'!

isMethodSignature
    ^type isMethodSignature
!

name
    ^name
!

name: anObject
    name := anObject
!

type
    ^type
!

type: anObject
    type := anObject
! !

!JavaNameAndType methodsFor: 'printing'!

printOn: aStream
    self type printOn: aStream withName: self name
! !

!JavaNameAndType class methodsFor: 'instance creation'!

name: aSymbol type: aType
    ^self new
    name: aSymbol;
    type: aType;
    yourself
! !

!JavaPrimitiveType methodsFor: 'printing'!

printEncodingOn: aStream
    aStream nextPut: self id
!

printOn: aStream
    aStream nextPutAll: self name
! !

!JavaPrimitiveType methodsFor: 'accessing'!

arrayClass
    ^arrayClass
!

arrayClass: aClass
    arrayClass := aClass
!

id
    ^id
!

id: anObject
    id := anObject
!

initializationValue
    ^zeroValue
!

isPrimitiveType
    ^true
!

zeroValue: anObject
    zeroValue := anObject
!

name
    ^name
!

name: anObject
    name := anObject
!

wordSize
    ^wordSize
!

wordSize: anObject
    wordSize := anObject
! !

!JavaPrimitiveType methodsFor: 'copying'!

copy
    ^self
!

shallowCopy
    ^self
! !

!JavaPrimitiveType methodsFor: 'testing'!

isVoid
    ^self wordSize == 0
! !

!JavaPrimitiveType class methodsFor: 'initializing'!

initialize
    "self initialize"
    PrimitiveTypes := IdentityDictionary new: 32.
    PrimitiveTypes at: $B put: (JavaByte := self
	id: $B name: 'byte' wordSize: 1 arrayClass: JavaByteArray zeroValue: 0).
    PrimitiveTypes at: $C put: (JavaChar := self
	id: $C name: 'char' wordSize: 1 arrayClass: JavaCharArray zeroValue: 0).
    PrimitiveTypes at: $D put: (JavaDouble := self
	id: $D name: 'double' wordSize: 2 arrayClass: JavaDoubleArray zeroValue: 0.0d).
    PrimitiveTypes at: $F put: (JavaFloat := self
	id: $F name: 'float' wordSize: 1 arrayClass: JavaFloatArray zeroValue: 0.0e).
    PrimitiveTypes at: $I put: (JavaInt := self
	id: $I name: 'int' wordSize: 1 arrayClass: JavaIntArray zeroValue: 0).
    PrimitiveTypes at: $J put: (JavaLong := self
	id: $J name: 'long' wordSize: 2 arrayClass: JavaLongArray zeroValue: 0).
    PrimitiveTypes at: $S put: (JavaShort := self
	id: $S name: 'short' wordSize: 1 arrayClass: JavaShortArray zeroValue: 0).
    PrimitiveTypes at: $V put: (JavaVoid := self
	id: $V name: 'void' wordSize: 0 arrayClass: nil zeroValue: nil).
    PrimitiveTypes at: $Z put: (JavaBoolean := self
	id: $Z name: 'boolean' wordSize: 1 arrayClass: ByteArray zeroValue: 0)
! !

!JavaPrimitiveType class methodsFor: 'instance creation'!

boolean
    ^JavaBoolean
!

byte
    ^JavaByte
!

char
    ^JavaChar
!

double
    ^JavaDouble
!

float
    ^JavaFloat
!

id: aCharacter name: aString wordSize: anInteger arrayClass: aClass zeroValue: anObject
    ^self new
        id: aCharacter;
        name: aString;
        wordSize: anInteger;
	arrayClass: aClass;
	zeroValue: anObject;
        yourself
!

int
    ^JavaInt
!

long
    ^JavaLong
!

readFrom: aStream
    ^PrimitiveTypes at: aStream next
!

short
    ^JavaShort
!

void
    ^JavaVoid
! !

!JavaLocalVariable methodsFor: 'accessing'!

endpc
    ^startpc + length
!

length
    ^length
!

length: anObject
    length := anObject
!

name
    ^name
!

name: anObject
    name := anObject
!

slot
    ^slot
!

slot: anObject
    slot := anObject
!

startpc
    ^startpc
!

startpc: anObject
    startpc := anObject
!

type
    ^type
!

type: anObject
    type := anObject
! !

!JavaLocalVariable methodsFor: 'printing'!

printOn: s 
    self type printOn: s withName: self name.
    s
    	nextPutAll: ' (start pc: ';
    	print: self startpc;
    	nextPutAll: ' end pc: ';
    	print: self startpc + self length;
    	nextPutAll: ' slot: ';
    	print: self slot;
    	nextPut: $)
! !

!JavaLocalVariable methodsFor: 'testing'!

includes: pc
    ^self startpc <= pc and: [ pc < self endpc ]
! !

!JavaLocalVariable class methodsFor: 'instance creation'!

startpc: s length: l name: n type: typ slot: i
    ^self new
        startpc: s;
        length: l;
        name: n;
        type: typ;
        slot: i;
        yourself
! !

!JavaPackage methodsFor: 'printing'!

printEncodingOn: aStream
    self container isNil ifFalse: [
        self container printOn: aStream.
        aStream nextPut: $/
    ].
    aStream nextPutAll: self name
!

printOn: aStream
    (self container isNil or: [ self container == Root ]) ifFalse: [
        self container printOn: aStream.
        aStream nextPut: $.
    ].
    aStream nextPutAll: self name
! !

!JavaPackage methodsFor: 'initializing'!

initialize
    contents := IdentityDictionary new
! !

!JavaPackage methodsFor: 'accessing'!

at: aSymbol
    ^self contents at: aSymbol
!

at: aSymbol ifAbsentPut: aBlock
    ^self contents at: aSymbol ifAbsentPut: aBlock value
!

at: aSymbol put: anObject
    ^self contents at: aSymbol put: anObject
!

classAt: aSymbol
    | value |
    value := self contents at: aSymbol.
    value isJavaClass ifFalse: [ self error: 'class expected, found package' ].
    ^value
!

classAt: aSymbol ifAbsentPut: aBlock
    | value |
    value := self contents at: aSymbol ifAbsentPut: aBlock.
    value isJavaClass ifFalse: [ self error: 'class expected, found package' ].
    ^value
!

container
    ^container
!

container: anObject
    container := anObject
!

contents
    ^contents
!

isJavaClass
    ^false
!

isJavaPackage
    ^true
!

name
    ^name
!

name: anObject
    name := anObject asSymbol
!

packageAt: aSymbol
    | value |
    value := self contents at: aSymbol ifAbsentPut: [ self class name: aSymbol container: self ].
    value isJavaPackage ifFalse: [ self error: 'package expected, found class' ].
    ^value
! !

!JavaPackage class methodsFor: 'instance creation'!

name: aSymbol container: aJavaPackage
    ^self new
        name: aSymbol;
        container: aJavaPackage;
        yourself
!

new
    ^self basicNew initialize
!

root
    ^Root
! !

!JavaPackage class methodsFor: 'initializing'!

initialize
    "self initialize"
    Root := self new.
    Root name: 'JAVA'
! !

!JavaField methodsFor: 'accessing'!

addAttribute: aJavaAttribute 
    aJavaAttribute class == JavaConstantValueAttribute ifTrue: 
        [self constantValue: aJavaAttribute constant.
        ^aJavaAttribute].
    ^super addAttribute: aJavaAttribute
!

constantValue
    ^constantValue
!

constantValue: anObject
    constantValue := anObject
! !

!JavaField methodsFor: 'printing'!

printOn: aStream
    self printHeadingOn: aStream.
    self constantValue notNil ifTrue: [
    aStream nextPutAll: ' = '; print: self constantValue ].
    aStream nextPut: $;.
    aStream nl.
! !

!JavaField methodsFor: 'compiling'!

getSelector
    getSelector isNil ifTrue: [
    	getSelector := self class getSelectorFor: self name in: self javaClass ].
    ^getSelector!

putSelector
    putSelector isNil ifTrue: [
    	putSelector := self class putSelectorFor: self name in: self javaClass ].
    ^putSelector! !

!JavaField class methodsFor: 'compiling'!

getSelectorFor: name in: class
    | string className ch |
    className := class fullName.
    string := String new: className size + 1 + name size.
    1 to: className size do: [ :i |
        string
	    at: i
	    put: ((ch := className at: i) = $. ifTrue: [ $$ ] ifFalse: [ ch ]).
    ].
    string
    	at: className size + 1 put: $$.
    string
    	replaceFrom: className size + 2
	to: string size
	with: name
	startingAt: 1.

    ^string asSymbol!

putSelectorFor: name in: class
    | string className ch |
    className := class fullName.
    string := String new: className size + 2 + name size.
    1 to: className size do: [ :i |
        string
	    at: i
	    put: ((ch := className at: i) = $. ifTrue: [ $$ ] ifFalse: [ ch ]).
    ].
    string
    	at: className size + 1 put: $$.
    string
    	replaceFrom: className size + 2
	to: string size - 1
	with: name
	startingAt: 1.
    string
    	at: string size put: $:.

    ^string asSymbol! !

JavaProgramElement initialize!
JavaPrimitiveType initialize!
JavaPackage initialize!
JavaInstructionInterpreter initialize!
PK
     �Mh@ ̵_�  �    Java.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java support loading script
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Smalltalk addSubspace: #Java!
Java addSubspace: #gnu!

Java.gnu addSubspace: #smalltalk!
Java.gnu addSubspace: #gcj!
Java.gnu addSubspace: #java!
Java.gnu.gcj addSubspace: #convert!
Java.gnu.gcj addSubspace: #runtime!
Java.gnu.java addSubspace: #net!
Java.gnu.java addSubspace: #nio!

Java.gnu.gcj.convert at: #IOConverter put: nil!
Java.gnu.gcj.runtime at: #StackTrace put: nil!
Java.gnu.gcj.runtime at: #StringBuffer put: nil!
Java.gnu.java.net at: #PlainDatagramSocketImpl put: nil!
Java.gnu.java.net at: #PlainSocketImpl put: nil!
Java.gnu.java.nio at: #FileLockImpl put: nil!
Java.gnu.java.nio at: #SelectorImpl put: nil!

Java addSubspace: #java!
Java.java addSubspace: #lang!
Java.java addSubspace: #io!
Java.java addSubspace: #net!
Java.java addSubspace: #nio!
Java.java addSubspace: #text!
Java.java addSubspace: #util!
Java.java.lang addSubspace: #ref!
Java.java.lang addSubspace: #reflect!
Java.java.nio addSubspace: #channels!
Java.java.util addSubspace: #zip!

Java.java.io at: #File put: nil!
Java.java.io at: #FileDescriptor put: nil!
Java.java.io at: #IOException put: nil!
Java.java.io at: #ObjectInputStream put: nil!
Java.java.io at: #VMObjectStreamClass put: nil!

Java.java.lang at: #Character put: nil!
Java.java.lang at: #Class put: nil!
Java.java.lang at: #Cloneable put: nil!
Java.java.lang at: #ConcreteProcess put: nil!
Java.java.lang at: #Double put: nil!
Java.java.lang at: #Float put: nil!
Java.java.lang at: #Math put: nil!
Java.java.lang at: #Object put: nil!
Java.java.lang at: #Runtime put: nil!
Java.java.lang at: #String put: nil!
Java.java.lang at: #StringBuffer put: nil!
Java.java.lang at: #System put: nil!
Java.java.lang at: #Thread put: nil!
Java.java.lang at: #ThreadGroup put: nil!
Java.java.lang at: #VMClassLoader put: nil!

Java.java.lang at: #ArithmeticException put: nil!
Java.java.lang at: #ArrayIndexOutOfBoundsException put: nil!
Java.java.lang at: #ClassCastException put: nil!
Java.java.lang at: #CloneNotSupportedException put: nil!
Java.java.lang at: #IllegalThreadStateException put: nil!
Java.java.lang at: #NullPointerException put: nil!

Java.java.lang.ref at: #Reference put: nil!
Java.java.lang.reflect at: #Array put: nil!
Java.java.lang.reflect at: #Constructor put: nil!
Java.java.lang.reflect at: #Field put: nil!
Java.java.lang.reflect at: #Method put: nil!
Java.java.lang.reflect at: #Proxy put: nil!

Java.java.net at: #InetAddress put: nil!
Java.java.net at: #NetworkInterface put: nil!

Java.java.nio at: #DirectByteBufferImpl put: nil!
Java.java.nio.channels at: #FileChannelImpl put: nil!

Java.java.text at: #Collator put: nil!

Java.java.util at: #ResourceBundle put: nil!
Java.java.util at: #TimeZone put: nil!
Java.java.util.zip at: #Deflater put: nil!
Java.java.util.zip at: #Inflater put: nil!

Namespace current: Java.gnu.smalltalk!

FileStream fileIn: 'JavaRuntime.st'!
FileStream fileIn: 'JavaMetaobjects.st'!
FileStream fileIn: 'JavaClassFiles.st'!
FileStream fileIn: 'JavaTranslation.st'!
FileStream fileIn: 'JavaExtensions.st'!
FileStream fileIn: 'gnu_gcj_convert_IOConverter.st'!
FileStream fileIn: 'gnu_gcj_runtime_StackTrace.st'!
FileStream fileIn: 'gnu_gcj_runtime_StringBuffer.st'!
FileStream fileIn: 'gnu_java_net_PlainDatagramSocketImpl.st'!
FileStream fileIn: 'gnu_java_net_PlainSocketImpl.st'!
FileStream fileIn: 'gnu_java_nio_FileLockImpl.st'!
FileStream fileIn: 'gnu_java_nio_SelectorImpl.st'!
FileStream fileIn: 'java_io_File.st'!
FileStream fileIn: 'java_io_FileDescriptor.st'!
FileStream fileIn: 'java_io_ObjectInputStream.st'!
FileStream fileIn: 'java_io_VMObjectStreamClass.st'!
FileStream fileIn: 'java_lang_Character.st'!
FileStream fileIn: 'java_lang_Class.st'!
FileStream fileIn: 'java_lang_ConcreteProcess.st'!
FileStream fileIn: 'java_lang_Double.st'!
FileStream fileIn: 'java_lang_Float.st'!
FileStream fileIn: 'java_lang_Math.st'!
FileStream fileIn: 'java_lang_Object.st'!
FileStream fileIn: 'java_lang_Runtime.st'!
FileStream fileIn: 'java_lang_String.st'!
FileStream fileIn: 'java_lang_StringBuffer.st'!
FileStream fileIn: 'java_lang_System.st'!
FileStream fileIn: 'java_lang_Thread.st'!
FileStream fileIn: 'java_lang_VMClassLoader.st'!
FileStream fileIn: 'java_lang_ref_Reference.st'!
FileStream fileIn: 'java_lang_reflect_Array.st'!
FileStream fileIn: 'java_lang_reflect_Constructor.st'!
FileStream fileIn: 'java_lang_reflect_Field.st'!
FileStream fileIn: 'java_lang_reflect_Method.st'!
FileStream fileIn: 'java_lang_reflect_Proxy.st'!
FileStream fileIn: 'java_net_InetAddress.st'!
FileStream fileIn: 'java_net_NetworkInterface.st'!
FileStream fileIn: 'java_nio_DirectByteBufferImpl.st'!
FileStream fileIn: 'java_nio_channels_FileChannelImpl.st'!
FileStream fileIn: 'java_text_Collator.st'!
FileStream fileIn: 'java_util_ResourceBundle.st'!
FileStream fileIn: 'java_util_TimeZone.st'!
FileStream fileIn: 'java_util_zip_Deflater.st'!
FileStream fileIn: 'java_util_zip_Inflater.st'!

Namespace current: Smalltalk!

Java.gnu.smalltalk.JavaVM bootstrap!

"(Java.java.lang.Math abs: -3) printNl!"
"(Java.java.lang.String valueOf: FloatD pi) asString printNl!"
"Java.java.lang.System out println: 'che figata'!"
"Java.gnu.smalltalk.JavaVM run: 'prova_eccezioni'!"
"Java.gnu.smalltalk.JavaVM run: 'prova_thread'!"
"(Java.gnu.smalltalk.JavaClass fromString: 'prova6') install!"
"Java.gnu.smalltalk.JavaVM run: 'CaffeineMarkEmbeddedApp'!"
"Java.gnu.smalltalk.JavaVM run: 'JGFLoopBench'!"
PK
     V[h@��M�  �    package.xmlUT	 d�XOd�XOux �  �  <package>
  <name>Java</name>
  <prereq>Sockets</prereq>

  <filein>Java.st</filein>
  <file>JavaClassFiles.st</file>
  <file>JavaMetaobjects.st</file>
  <file>JavaTranslation.st</file>
  <file>JavaRuntime.st</file>
  <file>JavaExtensions.st</file>
  <file>extract-native.awk</file>
  <file>gnu_gcj_convert_IOConverter.st</file>
  <file>gnu_gcj_runtime_StackTrace.st</file>
  <file>gnu_gcj_runtime_StringBuffer.st</file>
  <file>gnu_java_net_PlainDatagramSocketImpl.st</file>
  <file>gnu_java_net_PlainSocketImpl.st</file>
  <file>gnu_java_nio_FileLockImpl.st</file>
  <file>gnu_java_nio_SelectorImpl.st</file>
  <file>java_io_File.st</file>
  <file>java_io_FileDescriptor.st</file>
  <file>java_io_ObjectInputStream.st</file>
  <file>java_io_VMObjectStreamClass.st</file>
  <file>java_lang_Character.st</file>
  <file>java_lang_Class.st</file>
  <file>java_lang_ConcreteProcess.st</file>
  <file>java_lang_Double.st</file>
  <file>java_lang_Float.st</file>
  <file>java_lang_Math.st</file>
  <file>java_lang_Object.st</file>
  <file>java_lang_Runtime.st</file>
  <file>java_lang_String.st</file>
  <file>java_lang_StringBuffer.st</file>
  <file>java_lang_System.st</file>
  <file>java_lang_Thread.st</file>
  <file>java_lang_VMClassLoader.st</file>
  <file>java_lang_ref_Reference.st</file>
  <file>java_lang_reflect_Array.st</file>
  <file>java_lang_reflect_Constructor.st</file>
  <file>java_lang_reflect_Field.st</file>
  <file>java_lang_reflect_Method.st</file>
  <file>java_lang_reflect_Proxy.st</file>
  <file>java_net_InetAddress.st</file>
  <file>java_net_NetworkInterface.st</file>
  <file>java_nio_DirectByteBufferImpl.st</file>
  <file>java_nio_channels_FileChannelImpl.st</file>
  <file>java_text_Collator.st</file>
  <file>java_util_ResourceBundle.st</file>
  <file>java_util_TimeZone.st</file>
  <file>java_util_zip_Deflater.st</file>
  <file>java_util_zip_Inflater.st</file>
  <file>test.st</file>
  <file>ChangeLog</file>
</package>PK
     �Mh@���݆  �    java_lang_Character.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.Character native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.Character'!

java_lang_Character_readChar_char: arg1
    <javaNativeMethod: #'readChar(C)C'
        for: #{Java.java.lang.Character} static: true>
    self notYetImplemented
!

java_lang_Character_toLowerCase_char: arg1
    <javaNativeMethod: #'toLowerCase(C)C'
        for: #{Java.java.lang.Character} static: true>
    arg1 < 65 ifTrue: [ ^arg1 ].
    arg1 > 90 ifTrue: [ ^arg1 ].
    ^arg1 + 32
!

java_lang_Character_toUpperCase_char: arg1
    <javaNativeMethod: #'toUpperCase(C)C'
        for: #{Java.java.lang.Character} static: true>
    arg1 < 97 ifTrue: [ ^arg1 ].
    arg1 > 122 ifTrue: [ ^arg1 ].
    ^arg1 - 32
!

java_lang_Character_toTitleCase_char: arg1
    <javaNativeMethod: #'toTitleCase(C)C'
        for: #{Java.java.lang.Character} static: true>
    arg1 < 97 ifTrue: [ ^arg1 ].
    arg1 > 122 ifTrue: [ ^arg1 ].
    ^arg1 - 32
!

java_lang_Character_digit_char: arg1 int: arg2
    | value |
    <javaNativeMethod: #'digit(CI)I'
        for: #{Java.java.lang.Character} static: true>
    "Get the numeric value..."
    arg1 < 48 ifTrue: [ value := -1 ] ifFalse: [
    arg1 <= 57 ifTrue: [ value := arg1 - 48 ] ifFalse: [
    arg1 < 65 ifTrue: [ value := -1 ] ifFalse: [
    arg1 <= 90 ifTrue: [ value := arg1 - 55 ] ifFalse: [
    arg1 < 97 ifTrue: [ value := -1 ] ifFalse: [
    arg1 <= 122 ifTrue: [ value := arg1 - 87 ]]]]]].

    "... then compare it against the radix."
    value >= arg2 ifTrue: [ value := -1 ].
    ^value
!

java_lang_Character_getNumericValue_char: arg1
    <javaNativeMethod: #'getNumericValue(C)I'
        for: #{Java.java.lang.Character} static: true>
    arg1 < 48 ifTrue: [ ^-1 ].
    arg1 <= 57 ifTrue: [ ^arg1 - 48 ].
    arg1 < 65 ifTrue: [ ^-1 ].
    arg1 <= 90 ifTrue: [ ^arg1 - 55 ].
    arg1 < 97 ifTrue: [ ^-1 ].
    arg1 <= 122 ifTrue: [ ^arg1 - 87 ].
    ^-1
!

java_lang_Character_getType_char: arg1
    <javaNativeMethod: #'getType(C)I'
        for: #{Java.java.lang.Character} static: true>
    self notYetImplemented
!

java_lang_Character_getDirectionality_char: arg1
    <javaNativeMethod: #'getDirectionality(C)B'
        for: #{Java.java.lang.Character} static: true>
    self notYetImplemented
! !

PK
     �Mh@����  �  '  gnu_java_net_PlainDatagramSocketImpl.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  gnu.java.net.PlainDatagramSocketImpl native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'gnu.java.net.PlainDatagramSocketImpl'!

gnu_java_net_PlainDatagramSocketImpl_bind_int: arg1 java_net_InetAddress: arg2
    <javaNativeMethod: #'bind(ILjava/net/InetAddress;)V'
        for: #{Java.gnu.java.net.PlainDatagramSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainDatagramSocketImpl_connect_java_net_InetAddress: arg1 int: arg2
    <javaNativeMethod: #'connect(Ljava/net/InetAddress;I)V'
        for: #{Java.gnu.java.net.PlainDatagramSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainDatagramSocketImpl_disconnect
    <javaNativeMethod: #'disconnect()V'
        for: #{Java.gnu.java.net.PlainDatagramSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainDatagramSocketImpl_create
    <javaNativeMethod: #'create()V'
        for: #{Java.gnu.java.net.PlainDatagramSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainDatagramSocketImpl_peek_java_net_InetAddress: arg1
    <javaNativeMethod: #'peek(Ljava/net/InetAddress;)I'
        for: #{Java.gnu.java.net.PlainDatagramSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainDatagramSocketImpl_peekData_java_net_DatagramPacket: arg1
    <javaNativeMethod: #'peekData(Ljava/net/DatagramPacket;)I'
        for: #{Java.gnu.java.net.PlainDatagramSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainDatagramSocketImpl_setTimeToLive_int: arg1
    <javaNativeMethod: #'setTimeToLive(I)V'
        for: #{Java.gnu.java.net.PlainDatagramSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainDatagramSocketImpl_getTimeToLive
    <javaNativeMethod: #'getTimeToLive()I'
        for: #{Java.gnu.java.net.PlainDatagramSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainDatagramSocketImpl_send_java_net_DatagramPacket: arg1
    <javaNativeMethod: #'send(Ljava/net/DatagramPacket;)V'
        for: #{Java.gnu.java.net.PlainDatagramSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainDatagramSocketImpl_receive_java_net_DatagramPacket: arg1
    <javaNativeMethod: #'receive(Ljava/net/DatagramPacket;)V'
        for: #{Java.gnu.java.net.PlainDatagramSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainDatagramSocketImpl_setOption_int: arg1 java_lang_Object: arg2
    <javaNativeMethod: #'setOption(ILjava/lang/Object;)V'
        for: #{Java.gnu.java.net.PlainDatagramSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainDatagramSocketImpl_getOption_int: arg1
    <javaNativeMethod: #'getOption(I)Ljava/lang/Object;'
        for: #{Java.gnu.java.net.PlainDatagramSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainDatagramSocketImpl_mcastGrp_java_net_InetAddress: arg1 java_net_NetworkInterface: arg2 boolean: arg3
    <javaNativeMethod: #'mcastGrp(Ljava/net/InetAddress;Ljava/net/NetworkInterface;Z)V'
        for: #{Java.gnu.java.net.PlainDatagramSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainDatagramSocketImpl_close
    <javaNativeMethod: #'close()V'
        for: #{Java.gnu.java.net.PlainDatagramSocketImpl} static: false>
    self notYetImplemented
! !
PK
     �Mh@�Eq��  �    java_lang_Thread.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.Thread native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.Thread'!

java_lang_Thread_countStackFrames
    <javaNativeMethod: #'countStackFrames()I'
        for: #{Java.java.lang.Thread} static: false>
    self notYetImplemented
!

java_lang_Thread_currentThread
    <javaNativeMethod: #'currentThread()Ljava/lang/Thread;'
        for: #{Java.java.lang.Thread} static: true>
    "The system thread 'main' is assumed to be allways running.
    currentThread will either be main or a thread in Threads"

    ^ThreadAccessMutex critical: [
        Threads at: Processor activeProcess ifAbsent: [ MainThread ] ]
!

java_lang_Thread_destroy
    <javaNativeMethod: #'destroy()V'
        for: #{Java.java.lang.Thread} static: false>
    self notYetImplemented
!

java_lang_Thread_gen_name
    <javaNativeMethod: #'gen_name()Ljava/lang/String;'
        for: #{Java.java.lang.Thread} static: true>
    ^('Thread ', (Time millisecondClock printString: 36)) asJavaString
!

java_lang_Thread_initialize_native
    <javaNativeMethod: #'initialize_native()V'
        for: #{Java.java.lang.Thread} static: false>
!

java_lang_Thread_interrupt
    <javaNativeMethod: #'interrupt()V'
        for: #{Java.java.lang.Thread} static: false>
    self notYetImplemented
!

java_lang_Thread_join_long: arg1 int: arg2
    | s p joinSet |
    <javaNativeMethod: #'join(JI)V'
        for: #{Java.java.lang.Thread} static: false>

    s := Semaphore new.
    JoinMutex critical: [
        joinSet := JoinedThreads at: self ifAbsentPut: [ IdentitySet new ].
        joinSet add: s
    ].

    arg1 = 0 ifFalse: [
	p := JavaVM startDelayProcessFor: arg1 semaphore: s ].

    s wait.
    JoinMutex critical: [
        p notNil ifTrue: [ p terminate ].

        joinSet remove: s.
        joinSet isEmpty
            ifTrue: [ JoinedThreads removeKey: self ]
    ]
!

java_lang_Thread_resume
    | process |
    <javaNativeMethod: #'resume()V'
        for: #{Java.java.lang.Thread} static: false>
    ThreadAccessMutex critical: [
        process := Threads keyAtValue: self ifAbsent: [ ^self ]
    ].
    process resume
!

java_lang_Thread_setPriority_int: arg1
    | process |
    <javaNativeMethod: #'setPriority(I)V'
        for: #{Java.java.lang.Thread} static: false>
    ThreadAccessMutex critical: [
        process := Threads keyAtValue: self ifAbsent: [ ^self ]
    ].
    process priority: (JavaVM convertPriority: arg1)
!

java_lang_Thread_sleep_long: arg1 int: arg2
    <javaNativeMethod: #'sleep(JI)V'
        for: #{Java.java.lang.Thread} static: true>
    arg1 = 0
        ifTrue: [
            (Threads
                keyAtValue: self
                ifAbsent: [ ^self error: 'no process for thread' ] ) suspend ]
        ifFalse: [
            (Delay forMilliseconds: arg1) wait ]
!

java_lang_Thread_start
    | p priority |
    <javaNativeMethod: #'start()V'
        for: #{Java.java.lang.Thread} static: false>
    p := [
        JavaVM
	    invokeJavaSelector: #'run()V' withArguments: #() on: self;
	    removeThread: self
    ] newProcess.

    priority := self perform: #'getPriority()I'.
    JavaVM addThread: self for: p.
    p priority: (JavaVM convertPriority: priority).
    p resume
!

java_lang_Thread_stop_java_lang_Throwable: arg1
    <javaNativeMethod: #'stop(Ljava/lang/Throwable;)V'
        for: #{Java.java.lang.Thread} static: false>
    arg1 isNil ifFalse: [ self notYetImplemented ].
    JavaVM removeThread: self
!

java_lang_Thread_suspend
    | process |
    <javaNativeMethod: #'suspend()V'
        for: #{Java.java.lang.Thread} static: false>
    ThreadAccessMutex critical: [
        process := Threads keyAtValue: self ifAbsent: [ ^self ]
    ].
    process suspend
!

java_lang_Thread_yield
    <javaNativeMethod: #'yield()V'
        for: #{Java.java.lang.Thread} static: true>
    Processor yield
! !

PK
     �Mh@�͉�      java_io_VMObjectStreamClass.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  java.io.VMObjectStreamClass native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.io.VMObjectStreamClass'!

java_io_VMObjectStreamClass_hasClassInitializer_java_lang_Class: arg1
    <javaNativeMethod: #'hasClassInitializer(Ljava/lang/Class;)Z'
        for: #{Java.java.io.VMObjectStreamClass} static: true>
    self notYetImplemented
! !

PK
     �Mh@�Įq-  -    java_lang_reflect_Method.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.reflect.Method native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.reflect.Method'!

java_lang_reflect_Method_getName
    <javaNativeMethod: #'getName()Ljava/lang/String;'
        for: #{Java.java.lang.reflect.Method} static: false>
    self notYetImplemented
!

java_lang_reflect_Method_getModifiers
    <javaNativeMethod: #'getModifiers()I'
        for: #{Java.java.lang.reflect.Method} static: false>
    self notYetImplemented
!

java_lang_reflect_Method_invoke_java_lang_Object: arg1 java_lang_ObjectArray: arg2
    <javaNativeMethod: #'invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;'
        for: #{Java.java.lang.reflect.Method} static: false>
    self notYetImplemented
!

java_lang_reflect_Method_getType
    <javaNativeMethod: #'getType()V'
        for: #{Java.java.lang.reflect.Method} static: false>
    self notYetImplemented
! !

PK
     �Mh@��:�  �    java_lang_ref_Reference.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.ref.Reference native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.ref.Reference'!

java_lang_ref_Reference_create_java_lang_Object: arg1
    <javaNativeMethod: #'create(Ljava/lang/Object;)V'
        for: #{Java.java.lang.ref.Reference} static: false>
    self notYetImplemented
! !

PK
     �Mh@���  �    java_lang_Runtime.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.Runtime native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.Runtime'!

java_lang_Runtime_availableProcessors
    <javaNativeMethod: #'availableProcessors()I'
        for: #{Java.java.lang.Runtime} static: false>
    ^1
!

java_lang_Runtime_freeMemory
    <javaNativeMethod: #'freeMemory()J'
        for: #{Java.java.lang.Runtime} static: false>
    self notYetImplemented
!

java_lang_Runtime_totalMemory
    <javaNativeMethod: #'totalMemory()J'
        for: #{Java.java.lang.Runtime} static: false>
    self notYetImplemented
!

java_lang_Runtime_maxMemory
    <javaNativeMethod: #'maxMemory()J'
        for: #{Java.java.lang.Runtime} static: false>
    self notYetImplemented
!

java_lang_Runtime_gc
    <javaNativeMethod: #'gc()V'
        for: #{Java.java.lang.Runtime} static: false>
    ObjectMemory globalGarbageCollect
!

java_lang_Runtime_init
    <javaNativeMethod: #'init()V'
        for: #{Java.java.lang.Runtime} static: false>
!

java_lang_Runtime_runFinalization
    <javaNativeMethod: #'runFinalization()V'
        for: #{Java.java.lang.Runtime} static: false>
!

java_lang_Runtime_traceInstructions_boolean: arg1
    <javaNativeMethod: #'traceInstructions(Z)V'
        for: #{Java.java.lang.Runtime} static: false>
    self notYetImplemented
!

java_lang_Runtime_traceMethodCalls_boolean: arg1
    <javaNativeMethod: #'traceMethodCalls(Z)V'
        for: #{Java.java.lang.Runtime} static: false>
    self notYetImplemented
!

java_lang_Runtime_exitInternal_int: arg1
    <javaNativeMethod: #'exitInternal(I)V'
        for: #{Java.java.lang.Runtime} static: false>
    ObjectMemory quit: arg1
!

java_lang_Runtime_execInternal_java_lang_StringArray: arg1 java_lang_StringArray: arg2 java_io_File: arg3
    <javaNativeMethod: #'execInternal([Ljava/lang/String;[Ljava/lang/String;Ljava/io/File;)Ljava/lang/Process;'
        for: #{Java.java.lang.Runtime} static: false>
    self notYetImplemented
!

java_lang_Runtime_insertSystemProperties_java_util_Properties: arg1
    | host cpu os dash1 dash2 fullVer tmpDir put |

    <javaNativeMethod: #'insertSystemProperties(Ljava/util/Properties;)V'
        for: #{Java.java.lang.Runtime} static: true>

    put := [ :k :v |
	arg1
	    perform: #'put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;'
	    with: k asJavaString
	    with: v asJavaString ].

    host := Smalltalk hostSystem.
    dash1 := host indexOf: $-.
    dash2 := host indexOf: $- startingAt: dash1 + 1.
    cpu := host copyFrom: 1 to: dash1 - 1.
    os := host copyFrom: dash2 + 1 to: host size.
    ('i#86' match: cpu) ifTrue: [ cpu := 'ix86' ].

    fullVer := 'GNU Smalltalk version ', Smalltalk version.
    tmpDir := Smalltalk getenv: 'TMPDIR'.
    tmpDir isNil ifTrue: [
	tmpDir := Smalltalk getenv: 'TEMP'.
        tmpDir isNil ifTrue: [
	    tmpDir := Smalltalk getenv: 'TMP'.
            tmpDir isNil ifTrue: [ tmpDir := '/tmp' ]]].

    put value: 'java.class.version' value: '46.0'.
    put value: 'java.version'       value: Smalltalk version.
    put value: 'java.vendor'        value: 'Free Software Foundation'.
    put value: 'java.vendor.url'    value: 'http://www.gnu.org'.
    put value: 'java.fullversion'   value: fullVer.
    put value: 'java.vm.info'       value: fullVer.
    put value: 'java.vm.name'       value: 'GNU Smalltalk'.
    put value: 'java.vm.version'    value: Smalltalk version.
    put value: 'java.vm.vendor'     value: 'Free Software Foundation'.

    put value: 'java.specification.version'    value: '1.3'.
    put value: 'java.specification.name'       value: 'Java(tm) Platform API Specification'.
    put value: 'java.specification.vendor'     value: 'Sun Microsystems Inc.'.
    put value: 'java.vm.specification.version' value: '1.0'.
    put value: 'java.vm.specification.name'    value: 'Java(tm) Virtual Machine Specification'.
    put value: 'java.vm.specification.vendor'  value: 'Sun Microsystems Inc.'.

    put value: 'java.class.path'    value: JavaClassFileReader classPath.
    put value: 'java.home'          value: Directory image name.
    put value: 'os.name'            value: os.
    put value: 'os.arch'            value: cpu.
    put value: 'os.version'         value: '1'.
    put value: 'file.separator'     value: '/'.
    put value: 'path.separator'     value: ':'.
    put value: 'line.separator'     value: (Character nl asString).
    put value: 'user.name'          value: (Smalltalk getenv: 'USER').
    put value: 'user.home'          value: Directory home name.
    put value: 'user.dir'           value: Directory home name.

    put value: 'java.io.tmpdir'     value: tmpDir.
    put value: 'java.tmpdir'        value: tmpDir! !
PK
     �Mh@��+��  �    java_util_zip_Inflater.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.util.zip.Inflater native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.util.zip.Inflater'!

java_util_zip_Inflater_end
    <javaNativeMethod: #'end()V'
        for: #{Java.java.util.zip.Inflater} static: false>
    self notYetImplemented
!

java_util_zip_Inflater_getAdler
    <javaNativeMethod: #'getAdler()I'
        for: #{Java.java.util.zip.Inflater} static: false>
    self notYetImplemented
!

java_util_zip_Inflater_getRemaining
    <javaNativeMethod: #'getRemaining()I'
        for: #{Java.java.util.zip.Inflater} static: false>
    self notYetImplemented
!

java_util_zip_Inflater_getTotalIn
    <javaNativeMethod: #'getTotalIn()I'
        for: #{Java.java.util.zip.Inflater} static: false>
    self notYetImplemented
!

java_util_zip_Inflater_getTotalOut
    <javaNativeMethod: #'getTotalOut()I'
        for: #{Java.java.util.zip.Inflater} static: false>
    self notYetImplemented
!

java_util_zip_Inflater_inflate_byteArray: arg1 int: arg2 int: arg3
    <javaNativeMethod: #'inflate([BII)I'
        for: #{Java.java.util.zip.Inflater} static: false>
    self notYetImplemented
!

java_util_zip_Inflater_init_boolean: arg1
    <javaNativeMethod: #'init(Z)V'
        for: #{Java.java.util.zip.Inflater} static: false>
    self notYetImplemented
!

java_util_zip_Inflater_reset
    <javaNativeMethod: #'reset()V'
        for: #{Java.java.util.zip.Inflater} static: false>
    self notYetImplemented
!

java_util_zip_Inflater_setDictionary_byteArray: arg1 int: arg2 int: arg3
    <javaNativeMethod: #'setDictionary([BII)V'
        for: #{Java.java.util.zip.Inflater} static: false>
    self notYetImplemented
!

java_util_zip_Inflater_setInput_byteArray: arg1 int: arg2 int: arg3
    <javaNativeMethod: #'setInput([BII)V'
        for: #{Java.java.util.zip.Inflater} static: false>
    self notYetImplemented
! !

PK
     �Mh@�]>;      java_util_zip_Deflater.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.util.zip.Deflater native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.util.zip.Deflater'!

java_util_zip_Deflater_deflate_byteArray: arg1 int: arg2 int: arg3
    <javaNativeMethod: #'deflate([BII)I'
        for: #{Java.java.util.zip.Deflater} static: false>
    self notYetImplemented
!

java_util_zip_Deflater_init_int: arg1 boolean: arg2
    <javaNativeMethod: #'init(IZ)V'
        for: #{Java.java.util.zip.Deflater} static: false>
    self notYetImplemented
!

java_util_zip_Deflater_update
    <javaNativeMethod: #'update()V'
        for: #{Java.java.util.zip.Deflater} static: false>
    self notYetImplemented
!

java_util_zip_Deflater_end
    <javaNativeMethod: #'end()V'
        for: #{Java.java.util.zip.Deflater} static: false>
    self notYetImplemented
!

java_util_zip_Deflater_finish
    <javaNativeMethod: #'finish()V'
        for: #{Java.java.util.zip.Deflater} static: false>
    self notYetImplemented
!

java_util_zip_Deflater_getAdler
    <javaNativeMethod: #'getAdler()I'
        for: #{Java.java.util.zip.Deflater} static: false>
    self notYetImplemented
!

java_util_zip_Deflater_getTotalIn
    <javaNativeMethod: #'getTotalIn()I'
        for: #{Java.java.util.zip.Deflater} static: false>
    self notYetImplemented
!

java_util_zip_Deflater_getTotalOut
    <javaNativeMethod: #'getTotalOut()I'
        for: #{Java.java.util.zip.Deflater} static: false>
    self notYetImplemented
!

java_util_zip_Deflater_needsInput
    <javaNativeMethod: #'needsInput()Z'
        for: #{Java.java.util.zip.Deflater} static: false>
    self notYetImplemented
!

java_util_zip_Deflater_reset
    <javaNativeMethod: #'reset()V'
        for: #{Java.java.util.zip.Deflater} static: false>
    self notYetImplemented
!

java_util_zip_Deflater_setDictionary_byteArray: arg1 int: arg2 int: arg3
    <javaNativeMethod: #'setDictionary([BII)V'
        for: #{Java.java.util.zip.Deflater} static: false>
    self notYetImplemented
!

java_util_zip_Deflater_setInput_byteArray: arg1 int: arg2 int: arg3
    <javaNativeMethod: #'setInput([BII)V'
        for: #{Java.java.util.zip.Deflater} static: false>
    self notYetImplemented
! !

PK
     �Mh@�p7�z  �z    JavaClassFiles.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java .class file loading
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU General Public License along 
| with the GNU Smalltalk class library; see the file COPYING.  If not, 
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor, 
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Object subclass: #JavaAttribute
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaAttribute comment: '
This class is an abstract superclass for attributes read from a .class file.
'!


Array variableSubclass: #JavaConstantPool
    instanceVariableNames: 'complete javaClassReader '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaConstantPool comment: '
JavaConstantPool represents the constant pool in a class file before
it has been loaded completely.  It has two phases, one in which the
constant pool is being build and one afterwards.  When it is being
built, forward references (instances of JavaConstantProxy) return nil;
afterwards, they invoke #resolve: on the JavaConstantProxy object so
that the classes, strings, nameAndTypes and references are put
together correctly.

The use of this class is usually completely transparent.
JavaClassReader uses it temporarily inside #readConstantPool, which in
the end returns a simple (and more efficient) Array.

Instance Variables:
    complete	<Boolean>
	true if the whole constant pool has been filled
    javaClassReader	<Object>
	the javaClassReader which will be passed to JavaConstantPool
'!


JavaAttribute subclass: #JavaConstantValueAttribute
    instanceVariableNames: 'constant '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaConstantValueAttribute comment: '
JavaCodeAttribute is a representation of the ConstantValue attribute
in .class files.  It represents the value of final fields in a class.

Instance Variables:
    constant	<Object>
	the value of the field

'!


Smalltalk.Object subclass: #JavaConstantProxy
    instanceVariableNames: 'message '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaConstantProxy comment: '
JavaConstantProxy is a helper object to resolve forward references in
a .class file''s constant pool.

Instance Variables:
    message	<Message>
	message to be sent to recreate the constant, with constant pool indices instead of arguments

'!


JavaAttribute subclass: #JavaFlagAttribute
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaFlagAttribute comment: '
JavaFlagAttribute is an abstract class for attributes that have no
data field attached to them.

'!


JavaFlagAttribute subclass: #JavaSyntheticAttribute
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaSyntheticAttribute comment: '
JavaFlagAttribute represents the Synthetic attribute in a .class file.'!


JavaAttribute subclass: #JavaLocalVariableTableAttribute
    instanceVariableNames: 'localVariables '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaLocalVariableTableAttribute comment: '
JavaLocalVariableTableAttribute represents the LocalVariableTable
attribute in a .class file, which maps local variable slots to
variable names in the .java file.

Instance Variables:
    locals	<(Collection of: JavaLocalVariable)>
	the collection of local variable names for the method.

'!


JavaAttribute subclass: #JavaExceptionsAttribute
    instanceVariableNames: 'exceptions '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaExceptionsAttribute comment: '
JavaExceptionsAttribute is a representation of the Exceptions
attribute in .class files.  It represents the exceptions that a method
can throw.

Instance Variables:
    exceptions	<(Collection of: JavaClass)>
	the list of exceptions in the throws clause.

'!


JavaFlagAttribute subclass: #JavaDeprecatedAttribute
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaDeprecatedAttribute comment: '
JavaFlagAttribute represents the Deprecated attribute in a .class file.

'!


JavaAttribute subclass: #JavaUnknownAttribute
    instanceVariableNames: 'attributeName bytes '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaUnknownAttribute comment: '
JavaUnknownAttribute represents an attribute which is not known to the
system.

Instance Variables:
    attributeName	<String>
	the name of the attribute
    bytes	<ByteArray>
	the raw bytes that compose the attribute

'!


JavaAttribute subclass: #JavaCodeAttribute
    instanceVariableNames: 'maxStack maxLocals bytecodes handlers attributes '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaCodeAttribute comment: '
JavaCodeAttribute is a representation of the Code attribute in .class
files.  It includes most of the information about a method, either
directly or through its own subattributes

Instance Variables:
    attributes	<(Collection of: JavaAttribute)>
	description of attributes
    bytecodes	<ByteArray>
	the method''s bytecodes
    handlers	<(Collection of: JavaExceptionHandler)>
	the ranges of program counter values for the method''s exception handlers
    maxLocals	<Integer>
	the number of local variables used by the method
    maxStack	<Integer>
	the number of stack slots used by the method

'!


JavaAttribute subclass: #JavaLineNumberTableAttribute
    instanceVariableNames: 'lines '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaLineNumberTableAttribute comment: '
JavaLineNumberTableAttribute represents the LineNumberTable attribute
in a .class file, which maps program counter values to line numbers in
the .java file.

Instance Variables:
    lines	<(Collection of: (Integer->Integer))>
	associations that map a PC value to a line number

'!


Smalltalk.Object subclass: #JavaStringPrototype
    instanceVariableNames: 'stringValue '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Metaobjects'!

JavaStringPrototype comment: '
JavaStringPrototype is a placeholder for instances of java.lang.String
that are created before the class is loaded, during system
bootstrap.'!


JavaAttribute subclass: #JavaSourceFileAttribute
    instanceVariableNames: 'fileName '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaSourceFileAttribute comment: '
JavaSourceFileAttribute represents the SourceFile attribute in a .class file.

Instance Variables:
    fileName	<String>
		the file from which the compiled .class file was generated.

'!


JavaReader subclass: #JavaClassFileReader
    instanceVariableNames: ''
    classVariableNames: 'ClassDirectories'
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaClassFileReader comment: '
JavaClassFileReader is an abstract superclass for objects that deal
with Java class files: it has methods for handling attributes and type
descriptors

Subclasses must implement the following messages:
    building-utility
    	typeFromString:

'!


JavaClassFileReader subclass: #JavaClassReader
    instanceVariableNames: 'tag '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaClassReader comment: '
JavaClassReader reads a .class file and invokes its own abstract
methods to communicate the results of reading the file.

Subclasses must implement the following messages:
    building the class
    	accessFlags:
    	attributes:
    	extends:
    	fields:
    	implements:
    	methods:
    	thisClass:
    building-utility
    	class:nameAndType:
    	fieldFromFlags:name:signature:attributes:
    	methodFromFlags:name:signature:attributes:
    	name:type:

'!


JavaClassFileReader subclass: #JavaAttributeReader
    instanceVariableNames: 'classReader '
    classVariableNames: 'AttributeNames'
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaAttributeReader comment: '
JavaAttributeReader mediates between other JavaClassFileReaders and
JavaAttribute for reading attributes.  It handles a table of attribute
names vs. JavaAttribute subclasses, and ensures that these cannot go
beyond the end of the attribute data.

Instance Variables:
    classReader	<JavaClassFileReader>
	the object that asked to read an attribute.

'!


JavaClassReader subclass: #JavaClassBuilder
    instanceVariableNames: 'thisClass '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Class files'!

JavaClassBuilder comment: '
JavaClassBuilder uses JavaClassReader''s services to create a
JavaClass (and its containing JavaPackages) from its .class file.

Instance Variables:
    thisClass	<JavaClass>
	description of thisClass

'!






!JavaAttribute methodsFor: 'testing'!

isLineAttribute
    ^false
!

isLocalsAttribute
    ^false
! !

!JavaAttribute class methodsFor: 'reading'!

attributeName
    ^nil
!

readFrom: aJavaClassReader
    ^JavaAttributeReader new readFrom: aJavaClassReader
!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    self subclassResponsibility
! !

!JavaConstantPool methodsFor: 'accessing'!

at: anIndex
    | obj |
    obj := super at: anIndex.
    obj class == JavaConstantProxy ifFalse: [ ^obj ].
    self complete ifFalse: [ ^nil ].

    obj := obj resolve: self.
    self at: anIndex put: obj.
    ^obj
!

complete
    ^complete
!

complete: anObject
    complete := anObject
!

javaClassReader
    ^javaClassReader
!

javaClassReader: anObject
    javaClassReader := anObject
! !

!JavaConstantPool methodsFor: 'converting'!

asArray
    | a |
    a := Array new: self size.
    "This automatically resolves everything"
    1 to: self size do: [ :each | a at: each put: (self at: each) ].
    ^a
! !

!JavaConstantPool methodsFor: 'copying'!

copyEmpty
    ^Array new: self size
!

copyEmpty: size
    ^Array new: size
!

species
    ^Array
! !

!JavaConstantPool class methodsFor: 'instance creation'!

new: size
    ^(self basicNew: size)
    	complete: false;
    	yourself
! !

!JavaConstantValueAttribute methodsFor: 'printing'!

printOn: s
    "Print that this is a constant"

    s nextPutAll:'constant value '; print: self constant; nl.
! !

!JavaConstantValueAttribute methodsFor: 'accessing'!

constant
    ^constant
!

constant: i
    "Set the index in the pool we are pointing to"

    constant := i
! !

!JavaConstantValueAttribute class methodsFor: 'instance creation'!

constant: i
    "Return an initialized instance"

    ^self new constant: i
! !

!JavaConstantValueAttribute class methodsFor: 'reading'!

attributeName
    ^'ConstantValue'
!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    | constant |
    constant := aJavaAttributeReader nextConstant.
    ^self constant: constant
! !

!JavaConstantProxy methodsFor: 'resolving'!

resolve: constantPool
    ^constantPool javaClassReader
    	perform: message selector
    	withArguments: (message arguments collect: [ :each | constantPool at: each ])
! !

!JavaConstantProxy methodsFor: 'accessing'!

message
    ^message
!

message: anObject
    message := anObject
! !

!JavaConstantProxy class methodsFor: 'instance creation'!

selector: aSymbol arguments: anArray
    ^self new message: (Message selector: aSymbol arguments: anArray)
! !

!JavaFlagAttribute class methodsFor: 'reading'!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    ^self new
! !

!JavaSyntheticAttribute class methodsFor: 'reading'!

attributeName
    ^'Synthetic'
! !

!JavaLocalVariableTableAttribute methodsFor: 'accessing'!

localVariables
    ^localVariables
!

localVariables: l
    localVariables := l
! !

!JavaLocalVariableTableAttribute methodsFor: 'printing'!

printOn: s
    self localVariables do: [:l | s print: l; nl ]
! !

!JavaLocalVariableTableAttribute methodsFor: 'testing'!

isLocalsAttribute
    ^true
! !

!JavaLocalVariableTableAttribute class methodsFor: 'instance creation'!

localVariables: i
    "Return a new instance with the lines set"

    ^self new localVariables: i
! !

!JavaLocalVariableTableAttribute class methodsFor: 'reading'!

attributeName
    ^'LocalVariableTable'
!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    | vars var |
    vars := Array new: aJavaAttributeReader  nextUshort.
    1 to: vars size do: [ :i |
    var := JavaLocalVariable
        startpc: aJavaAttributeReader nextUshort
        length: aJavaAttributeReader nextUshort
        name: aJavaAttributeReader nextConstant
        type: aJavaAttributeReader nextType
        slot: aJavaAttributeReader nextUshort.

    vars at: i put: var ].
    ^self localVariables: vars
! !

!JavaExceptionsAttribute methodsFor: 'accessing'!

exceptions
    ^exceptions
!

exceptions: e
    "Set the exceptions"

    exceptions := e
! !

!JavaExceptionsAttribute methodsFor: 'printing'!

printOn: s
    "Print the code on the stream"

    s nextPutAll:'exceptions: '; nl.
    exceptions
    do:[:e| e printFullNameOn: s]
    separatedBy: [ s nextPutAll: ', ' ]
! !

!JavaExceptionsAttribute class methodsFor: 'instance creation'!

exceptions: e
    "Return an initialized instance"

    ^self new exceptions: e
! !

!JavaExceptionsAttribute class methodsFor: 'reading'!

attributeName
    ^'Exceptions'
!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    | exceptions |
    exceptions := Array new: aJavaAttributeReader nextUshort.
    1 to: exceptions size do: [ :i |
    exceptions at: i put: aJavaAttributeReader nextConstant ].
    ^self exceptions: exceptions
! !

!JavaDeprecatedAttribute class methodsFor: 'reading'!

attributeName
    ^'Deprecated'
! !

!JavaUnknownAttribute methodsFor: 'printing'!

printOn: s
    "Prit unknown attribute"

    s nextPutAll:'unknown attribute named: '; print: self attributeName; nl.
! !

!JavaUnknownAttribute methodsFor: 'accessing'!

attributeName
    ^attributeName
!

attributeName: n
    "Set the name"

    attributeName := n
!

bytes
    ^bytes
!

bytes: b
    "Set the bytes"

    bytes := b
! !

!JavaUnknownAttribute class methodsFor: 'instance creation'!

name: n bytes: b
    "return an initialized instance"

    ^self new
    	attributeName: n;
    	bytes: b;
    	yourself
! !

!JavaUnknownAttribute class methodsFor: 'reading'!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    ^self name: attributeName bytes: aJavaAttributeReader rawBytes
! !

!JavaCodeAttribute methodsFor: 'printing'!

printOn: s
    s nextPutAll:'bytecodes: '; nl.
    JavaInstructionPrinter print: self bytecodes on: s.
    s nextPutAll:' maxStack: '; print: self maxStack; nextPutAll: ' maxLocals:'; print: self maxLocals; nl.
    self attributes do:[:a|
    	s nextPutAll:' attribute: '; nl; tab.
    	a printOn: s].
! !

!JavaCodeAttribute methodsFor: 'accessing'!

attributes
    ^attributes
!

attributes: a
    "Set the other attributes"

    attributes := a
!

bytecodes
    ^bytecodes
!

bytecodes: anObject
    bytecodes := anObject
!

handlers
    ^handlers
!

handlers: anObject
    handlers := anObject
!

lines
    ^attributes detect: [:a | a isLineAttribute ] ifNone: [nil]
!

localVariables
    ^attributes detect: [:a | a isLocalsAttribute ] ifNone: [nil]
!

maxLocals
    ^maxLocals
!

maxLocals: l
    "Set max locals"

    maxLocals := l.
!

maxStack
    ^maxStack
!

maxStack: m
    "Set max stack"

    maxStack := m
! !

!JavaCodeAttribute class methodsFor: 'instance creation'!

maxStack: ms maxLocals: ml bytecodes: bc handlers: h attributes: a
    "Return a new instance"

    ^self new
    	maxStack: ms;
    	maxLocals: ml;
    	bytecodes: bc;
    	handlers: h;
    	attributes: a;
    	yourself
! !

!JavaCodeAttribute class methodsFor: 'reading'!

attributeName
    ^'Code'
!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    | maxStack maxLocals bytecodes handlers handler attributes |
    maxStack := aJavaAttributeReader nextUshort.
    maxLocals := aJavaAttributeReader nextUshort.
    bytecodes := aJavaAttributeReader nextBytes: aJavaAttributeReader nextUint.
    handlers := Array new: aJavaAttributeReader nextUshort.
    1 to: handlers size do: [ :i |
        handler := JavaExceptionHandler
            startpc: aJavaAttributeReader nextUshort
            finalpc: aJavaAttributeReader nextUshort "+ 1   include final byte"
            handlerpc: aJavaAttributeReader nextUshort
            type: aJavaAttributeReader nextConstant.

        handlers at: i put: handler ].

    attributes := aJavaAttributeReader readAttributes.
    ^self
    	maxStack: maxStack
	maxLocals: maxLocals
	bytecodes: bytecodes
	handlers: handlers
	attributes: attributes.
! !

!JavaLineNumberTableAttribute methodsFor: 'printing'!

printOn: s
    "Print the size of the line numbers on the stream"

    s nextPutAll:'line number table: '; print: self lines; nl.
! !

!JavaLineNumberTableAttribute methodsFor: 'testing'!

isLineAttribute
    ^true
! !

!JavaLineNumberTableAttribute methodsFor: 'accessing'!

lines
    ^lines
!

lines: l
    "Set the lines"

    lines := l
! !

!JavaLineNumberTableAttribute class methodsFor: 'instance creation'!

lines: i
    "Return a new instance with the lines set"

    ^self new lines: i
! !

!JavaLineNumberTableAttribute class methodsFor: 'reading'!

attributeName
    ^'LineNumberTable'
!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    | lines |
    lines := Array new: aJavaAttributeReader  nextUshort.
    1 to: lines size do: [ :i |
    lines at: i put: (aJavaAttributeReader nextUshort -> aJavaAttributeReader nextUshort) ].
    ^self lines: lines
! !

!JavaStringPrototype methodsFor: 'accessing'!

stringValue
    ^stringValue
!

stringValue: anObject
    stringValue := anObject
! !

!JavaStringPrototype methodsFor: 'printing'!

printOn: aStream 
    aStream
    	nextPutAll: '<java.lang.String: ';
    	store: self stringValue;
    	nextPut: $>
! !

!JavaStringPrototype class methodsFor: 'instance creation'!

stringValue: aString
    ^self new stringValue: aString
! !

!JavaSourceFileAttribute methodsFor: 'printing'!

printOn: s
    "Print the name of the source file on the stream"

    s nextPutAll: '// source file: '; print: fileName.
! !

!JavaSourceFileAttribute methodsFor: 'accessing'!

fileName
    ^fileName
!

fileName: anObject
    fileName := anObject
! !

!JavaSourceFileAttribute class methodsFor: 'instance creation'!

filename: i
    "Return an initialized instance"

    ^self new filename: i
! !

!JavaSourceFileAttribute class methodsFor: 'reading'!

attributeName
    ^'SourceFile'
!

readFrom: aJavaAttributeReader name: attributeName length: attributeLength
    ^self new fileName: aJavaAttributeReader nextConstant
! !

!JavaClassFileReader class methodsFor: 'class path'!

classDirectories
    ^ClassDirectories
!

classDirectories: aCollection
    ClassDirectories := aCollection
!

classPath
    ^self classDirectories fold: [ :a :b | a, ':', b ]
!

classPath: pathList
    self classDirectories: (pathList subStrings: $:)
!

findClassFile: aClass 
    | path |
    path := (aClass copyReplacing: $. withObject: $/) , '.class'.
    self classDirectories isNil
	ifTrue: [ self error: 'CLASSPATH not set' ].
    self classDirectories do: [:dir || file |
        file := dir / path.
        file exists ifTrue: [ ^file ]].

    ^nil
! !

!JavaClassFileReader methodsFor: 'stream accessing'!

nextType
    ^self typeFromString: self nextConstant
! !

!JavaClassFileReader methodsFor: 'building-utility'!

typeFromString: aString
    self subclassResponsibility
! !

!JavaClassFileReader methodsFor: 'reading structures'!

readAttribute: list 
    ^JavaAttribute readFrom: self
!

readAttributes
    ^self next: (self nextUshort) collect: [ :attrList | self readAttribute: attrList ].
! !

!JavaClassReader methodsFor: 'reading structures'!

readConstantPool
    | cp |
    cp := self 
    	next: self nextUshort - 1
    	collect: [:pool | self readConstant: pool]
    	into: JavaConstantPool.

    "Now resolve the forward references"
    cp
    	complete: true;
    	javaClassReader: self.
    ^cp asArray
!

readField
    ^self 
    	fieldFromFlags: self nextUshort
    	name: self nextConstant
    	signature: self nextType
    	attributes: self readAttributes
!

readFields
    ^self next: (self nextUshort) collect: [ :fieldList | self readField ].
!

readFile
    | accessFlags |
    self magic: self nextUint.
    self minor: self nextUshort major: self nextUshort.

    "These two are before the class name, so we load them into
     a temporary or instance variable."
    self constantPool: self readConstantPool.
    accessFlags := self nextUshort.

    "After creating the class, assign the already-read flags"
    self thisClass: self nextConstant.
    self accessFlags: accessFlags.

    self extends: self nextConstant.
    self implements: self readInterfaces.
    self fields: self readFields.
    self methods: self readMethods.
    self attributes: self readAttributes
!

readInterfaces
    ^self next: (self nextUshort) collect: [ :intfList | self nextConstant ].
!

readMethod
    ^self 
    	methodFromFlags: self nextUshort
    	name: self nextConstant
    	signature: self nextType
    	attributes: self readAttributes
!

readMethods
    ^self next: (self nextUshort) collect: [ :mthList | self readMethod ].
! !

!JavaClassReader methodsFor: 'reading constants'!

readBad: cp
    ^self error: 'invalid constant pool entry'
!

readClass: cp
    | constant index |
    index := self nextUshort.
    constant := cp at: index.
    ^constant isNil
    	ifTrue: [ JavaConstantProxy selector: #classFromString: arguments: (Array with: index) ]
    	ifFalse: [ self classFromString: constant ]
!

readConstant: cp
    | selector |
    "Work around the brainlessness of Java: constant pool entries for
     long and doubles take two slots."
    (tag == 5 or: [ tag == 6 ]) ifTrue: [ tag := nil. ^nil ].

    tag := self nextByte.
    (tag between: 1 and: 12) ifFalse: [ ^self error: 'invalid constant pool entry' ].
    selector := #(#readUTF8String: #readBad: #readInt: #readFloat: #readLong:
    #readDouble: #readClass: #readString: #readRef: #readMethodRef: #readMethodRef:
    #readNameAndType:)
    at: tag.

   ^self perform: selector with: cp
!

readDouble: cp
    ^self nextDouble
!

readFloat: cp
    ^self nextFloat
!

readInt: cp
    ^self nextInt
!

readLong: cp
    ^self nextLong
!

readMethodRef: cp 
    | classConstant nameTypeConstant classIndex nameTypeIndex |
    classIndex := self nextUshort.
    nameTypeIndex := self nextUshort.
    classConstant := cp at: classIndex.
    nameTypeConstant := cp at: nameTypeIndex.
    ^(classConstant isNil or: [nameTypeConstant isNil]) 
    	ifTrue: 
    		[JavaConstantProxy
    			selector: #class:methodNameAndType:
    			arguments: (Array with: classIndex with: nameTypeIndex)]
    	ifFalse:
    		[self
    			class: classConstant
    			methodNameAndType: nameTypeConstant]
!

readNameAndType: cp 
    | nameConstant typeConstant nameIndex typeIndex |
    nameIndex := self nextUshort.
    typeIndex := self nextUshort.
    nameConstant := cp at: nameIndex.
    typeConstant := cp at: typeIndex.
    ^(nameConstant isNil or: [typeConstant isNil]) 
    	ifTrue: 
    		[JavaConstantProxy
    			selector: #nameString:typeString:
    			arguments: (Array with: nameIndex with: typeIndex)]
    	ifFalse:
    		[self
    			nameString: nameConstant
    			typeString: typeConstant]
!

readRef: cp 
    | classConstant nameTypeConstant classIndex nameTypeIndex |
    classIndex := self nextUshort.
    nameTypeIndex := self nextUshort.
    classConstant := cp at: classIndex.
    nameTypeConstant := cp at: nameTypeIndex.
    ^(classConstant isNil or: [nameTypeConstant isNil]) 
    	ifTrue: 
    		[JavaConstantProxy
    			selector: #class:nameAndType:
    			arguments: (Array with: classIndex with: nameTypeIndex)]
    	ifFalse:
    		[self
    			class: classConstant
    			nameAndType: nameTypeConstant]
!

readString: cp
    | constant index |
    index := self nextUshort.
    constant := cp at: index.
    ^constant isNil
    	ifTrue: [ JavaConstantProxy selector: #javaLangString: arguments: (Array with: index) ]
    	ifFalse: [ self javaLangString: constant ]
!

readUTF8String: cp
    ^self nextUTF8String
! !

!JavaClassReader methodsFor: 'building the class'!

accessFlags: flags
    self subclassResponsibility
!

attributes: attributes
    self subclassResponsibility
!

extends: superclass
    self subclassResponsibility
!

fields: fields
    self subclassResponsibility
!

implements: interfaces
    self subclassResponsibility
!

magic
    ^16rCAFEBABE
!

magic: wannabeMagicValue 
    wannabeMagicValue = self magic 
    	ifFalse: [self error: 'invalid class magic value']
!

methods: methods
    self subclassResponsibility
!

minor: minorVersion major: majorVersion
    | version |
    version := majorVersion * 65536 + minorVersion.
    (version between: 45 * 65536 and: 46 * 65536) 
    	ifFalse: [self error: 'unsupported class version']
!

thisClass: aJavaClass
    self subclassResponsibility
! !

!JavaClassReader methodsFor: 'building-utility'!

class: aJavaClass methodNameAndType: nameAndType
    self subclassResponsibility
!

class: aJavaClass nameAndType: nameAndType
    self subclassResponsibility
!

classFromString: aString
    self subclassResponsibility
!

javaLangString: utf8 
    self subclassResponsibility
!

fieldFromFlags: flags name: name signature: signature attributes: attributes 
    self subclassResponsibility
!

methodFromFlags: flags name: name signature: signature attributes: attributes 
    self subclassResponsibility
!

name: aString type: aType
    self subclassResponsibility
!

nameString: nameString typeString: typeString
    ^self
        name: nameString asSymbol
        type: (self typeFromString: typeString)
! !

!JavaAttributeReader methodsFor: 'reading'!

rawBytes
    ^stream upToEnd
!

readFrom: aJavaClassReader
    | attributeName length |
    self classReader: aJavaClassReader.
    self constantPool: aJavaClassReader constantPool.
    attributeName  := self constantPool at: aJavaClassReader nextUshort.
    length := aJavaClassReader nextUint.
    stream := (aJavaClassReader nextBytes: length) readStream.
    ^(AttributeNames at: attributeName ifAbsent: [ JavaUnknownAttribute ])
        readFrom: self name: attributeName length: length
! !

!JavaAttributeReader methodsFor: 'accessing'!

classReader
    ^classReader
!

classReader: anObject
    classReader := anObject
! !

!JavaAttributeReader methodsFor: 'building-utility'!

typeFromString: aString
    ^self classReader typeFromString: aString
! !

!JavaAttributeReader class methodsFor: 'initialization'!

initialize
    "self initialize"
    AttributeNames := LookupTable new: 32.
    JavaAttribute allSubclasses do: [ :each |
    | attributeName |
    attributeName := each attributeName.
    attributeName isNil ifFalse: [ self registerAttribute: attributeName withClass: each ]]
!

registerAttribute: attrName withClass: class
    AttributeNames at: attrName put: class
! !

!JavaClassBuilder methodsFor: 'building the class'!

accessFlags: flags
    thisClass flags: flags
!

attributes: attributes
    thisClass attributes: attributes
!

extends: superclass
    thisClass extends: superclass
!

fields: fields
    thisClass fields: fields
!

implements: interfaces
    thisClass implements: interfaces
!

methods: methods
    thisClass methods: methods
! !

!JavaClassBuilder methodsFor: 'accessing'!

thisClass
    ^thisClass
!

thisClass: aJavaClass 
    thisClass := aJavaClass.
    thisClass constantPool: self constantPool
! !

!JavaClassBuilder methodsFor: 'building-utility'!

class: aJavaClass methodNameAndType: nameAndType
    ^JavaMethodRef
        javaClass: aJavaClass
        nameAndType: nameAndType
!

class: aJavaClass nameAndType: nameAndType
    ^JavaFieldRef
        javaClass: aJavaClass
        nameAndType: nameAndType
!

classFromString: aString
    ^aString first= $[
    	ifTrue: [ JavaArrayType fromString: aString ]
    	ifFalse: [ JavaClass fromString: aString ]
!

javaLangString: utf8 
    ^JavaVM bootstrapped
    	ifFalse: [JavaStringPrototype stringValue: utf8]
    	ifTrue: [utf8 asJavaString]
!

fieldFromFlags: flags name: name signature: signature attributes: attributes 
    ^(JavaField new)
    	flags: flags;
    	name: name;
    	signature: signature;
    	attributes: attributes;
    	yourself
!

methodFromFlags: flags name: name signature: signature attributes: attributes 
    ^(JavaMethod new)
    	flags: flags;
    	name: name;
    	signature: signature;
    	attributes: attributes;
    	yourself
!

name: aSymbol type: aType
    ^JavaNameAndType
        name: aSymbol
        type: aType
!

typeFromString: aString
    aString isNil ifTrue: [ ^nil ].
    ^JavaType fromString: aString
! !

!JavaClass class methodsFor: 'instance creation'!

loadFile: aString
    | stream |
    stream := FileStream open: aString mode: FileStream read.
    ^[ self readFrom: stream ] ensure: [ stream close ]
! !

!JavaClass methodsFor: 'loading'!

load
    self isLoaded ifTrue: [ ^self ].
    self class loadClass: self fullName.
    self extends isNil ifFalse: [ self extends load ].
! !

!JavaClass methodsFor: 'accessing'!

addAttribute: aJavaAttribute
    aJavaAttribute class == JavaSourceFileAttribute
    ifTrue:
    [self sourceFile: aJavaAttribute fileName.
    ^aJavaAttribute].
    ^super addAttribute: aJavaAttribute
! !

!JavaClass class methodsFor: 'instance creation'!

loadClass: aString
    | file stream |
    file := JavaClassFileReader findClassFile: aString.
    file isNil ifTrue: [ self error: 'class not found: ', aString ].
    "Transcript show: 'Loading '; show: aString; nl."
    stream := file readStream.
    ^[ self readFrom: stream ] ensure: [ stream close ]
!

loadFile: aString
    | stream |
    stream := FileStream open: aString mode: FileStream read.
    ^[ self readFrom: stream ] ensure: [ stream close ]
!

readFrom: aStream
    | reader |
    "aStream binary; lineEndTransparent."   "VW requires these."
    reader := JavaClassBuilder on: aStream.
    reader readFile.
    ^reader thisClass
! !

JavaAttributeReader initialize!
PK
     �Mh@P5���  �    JavaRuntime.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  Everything except native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"

Object subclass: #JavaObject
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Runtime'!

JavaObject class instanceVariableNames: 'javaClass javaLangClass initialized '!

JavaObject comment: '
The JavaObject class is the superclass of Java objects.
java.lang.Object is a subclass of JavaObject, which defines some
methods called back by the translated bytecodes.

'!

Object subclass: #JavaMonitor
	instanceVariableNames: 'semaphore process count waitSemaphores '
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

JavaMonitor class
	instanceVariableNames: 'monitors mutex lastMonitor lastObject'!

ArrayedCollection variable: #int8 subclass: #JavaByteArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

ArrayedCollection variable: #short subclass: #JavaShortArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

ArrayedCollection variable: #ushort subclass: #JavaCharArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

ArrayedCollection variable: #float subclass: #JavaFloatArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

ArrayedCollection variable: #double subclass: #JavaDoubleArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

ArrayedCollection variable: #int subclass: #JavaIntArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

ArrayedCollection variable: #int64 subclass: #JavaLongArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: ''!

MethodInfo variableSubclass: #JavaMethodInfo
    instanceVariableNames: 'javaMethod '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Runtime'!

CompiledMethod variableByteSubclass: #JavaCompiledMethod
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Runtime'!

CompiledMethod subclass: #JavaSynchronizedMethodWrapper
    instanceVariableNames: 'wrappedMethod '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Runtime'!

CompiledMethod subclass: #JavaUntranslatedMethod
    instanceVariableNames: 'javaMethod '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Runtime'!

JavaUntranslatedMethod comment: '
JavaUntranslatedMethod is a placeholder that triggers translation of
the Java bytecodes the first time the method is invoked.

Instance Variables:
    javaMethod	<Object>	description of javaMethod

'!

Error subclass: #JavaException
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Runtime'!


FileDescriptor subclass: #JavaFileDescriptor
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Runtime'!


Object subclass: #JavaVM
    instanceVariableNames: 'instVar1 instVar2 instVar3 instVar4'
    classVariableNames: 'IntClass ByteClass ShortClass
	LongClass FloatClass DoubleClass VoidClass BooleanClass
	CharClass Bootstrapped

	OpenFileTable

	TopGroup MainGroup MainThread
	JoinMutex JoinedThreads ThreadAccessMutex Threads'
    poolDictionaries: ''
    category: 'Java-Runtime'!

JavaVM comment: '
JavaVM is a single huge class that includes all the native methods in the
Java-on-Smalltalk virtual machine implementation.

The methods are on the instance side for ease of browsing, but they are
actually swizzled to other classes when the system bootstraps, according
to their <javaNativeMethod: ... for: ...> attribute.  Their state must
be kept entirely with class variables, so that it can be accessed globally.'!

!JavaMonitor class methodsFor: 'initialization'!

initialize
    mutex := Semaphore forMutualExclusion.
    monitors := WeakKeyIdentityDictionary new!

!JavaMonitor class methodsFor: 'private'!

delayProcessFor: mils semaphore: s
    ^[
        (Delay forMilliseconds: mils) wait.
        s signal.
	Processor activeProcess suspend ]!

monitorFor: anObject
    "Retrieve the monitor for anObject, without locking Mutex (the sender
     should take care of locking it).  We cache the last monitor, because
     the cache hits in two very common cases: 1) a synchronized method 
     calls another synchronized method on the same object, and 2) in the
     sequential case, there are no thread switches (and accesses to monitors)
     between the time the monitor is entered and the time the monitor is
     exited."

    lastObject == anObject ifTrue: [ ^lastMonitor ].

    lastObject := anObject.
    lastMonitor := monitors at: anObject ifAbsent: [ nil ].
    ^lastMonitor isNil
	ifFalse: [ lastMonitor ]
	ifTrue: [ monitors at: anObject put: (lastMonitor := self new)]! !

!JavaMonitor class methodsFor: 'locking'!

enter: anObject
    "Of course, we wait on the monitor *after* relinquishing the mutex."
    | monitor |
    mutex wait.
    monitor := self monitorFor: anObject.
    mutex signal.
    monitor wait!

exit: anObject
    "Note that we signal the monitor *before* relinquishing the mutex."
    mutex wait.
    (self monitorFor: anObject) signal.
    mutex signal!

notifyAll: anObject
    mutex wait.
    (self monitorFor: anObject) notifyAll.
    mutex signal!

notify: anObject
    mutex wait.
    (self monitorFor: anObject) notify.
    mutex signal!

waitOn: anObject timeout: msec
    | monitor count process waitSemaphores sema |
    "Note that we unlock the monitor *before* relinquishing the mutex."
    sema := Semaphore new.

    "Grab the monitor, unlock it and register the semaphore we'll wait on."
    mutex wait.
    monitor := (self monitorFor: anObject).
    count := monitor unlock.
    waitSemaphores := monitor waitSemaphores.
    waitSemaphores addLast: sema.
    mutex signal.

    "If there's a timeout, start a process to exit the wait anticipatedly."
    msec > 0 ifTrue: [
	process := (self delayProcessFor: msec semaphore: sema) fork ].

    sema wait.

    "Also if there's a timeout, ensure that the semaphore is removed from
     the list.  If there's no timeout we do not even need to reacquire the
     monitor afterwards (see also #exit:, which waits after getting the
     monitor and relinquishing the mutex)."
    process notNil ifTrue: [
        mutex wait.
        waitSemaphores remove: sema ifAbsent: [].
        process terminate.
        mutex signal ].

    monitor lock: count!

!JavaMonitor class methodsFor: 'instance creation'!

new
    ^super new initialize!

!JavaMonitor methodsFor: 'initialize-release'!

initialize
    count := 0.
    semaphore := Semaphore forMutualExclusion! !

!JavaMonitor methodsFor: 'accessing'!

waitSemaphores
    waitSemaphores isNil ifTrue: [ waitSemaphores := OrderedCollection new ].
    ^waitSemaphores! !

!JavaMonitor methodsFor: 'control'!

notifyAll
    process == Processor activeProcess
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalThreadStateException ].

    waitSemaphores isNil ifTrue: [ ^self ].
    waitSemaphores size timesRepeat: [ waitSemaphores removeFirst signal ]!

notify
    process == Processor activeProcess
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalThreadStateException ].

    waitSemaphores isNil ifTrue: [ ^self ].
    waitSemaphores isEmpty ifFalse: [ waitSemaphores removeFirst signal ]!

unlock
    | oldCount |
    process == Processor activeProcess
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalThreadStateException ].

    oldCount := count.
    count := 0.
    process := nil.
    semaphore signal.
    ^oldCount!

lock: saveCount
    | activeProcess |
    activeProcess := Processor activeProcess.
    process == activeProcess
	ifFalse: [
	    semaphore wait.
	    process := activeProcess ].
    count := count + saveCount!
    
signal
    (count := count - 1) == 0
	ifTrue: [ process := nil. semaphore signal ]!

wait
    | activeProcess |
    activeProcess := Processor activeProcess.
    process == activeProcess
	ifFalse: [
	    semaphore wait.
	    process := activeProcess ].
    count := count + 1! !

!JavaObject class methodsFor: 'message sending'!

convertArgsToJava: argArray withSignature: argSignature
    "given a smalltalk argument array, convert to java objects as appropriate.
     Currently, only Strings and booleans are converted."

    ^argArray with: argSignature collect: [:arg :type |
        self convertToJava: arg type: type ].
!

check: args against: signature
    | arg type goodness |
    goodness := 100.
    1 to: args size do: [ :i |
	arg := args at: i.
	type := signature at: i.
	goodness := goodness min: (self goodnessOfMapping: arg to: type).
    ].
    ^goodness
!

convertToJava: arg type: type
    ^self
	convertToJava: arg
	type: type
	ifFail: [ self error: 'invalid argument' ]
!

goodnessOfMapping: arg to: type
    "Given a Smalltalk argument, check if it belongs to the
     correct Java type and convert as appropriate."

    type == JavaPrimitiveType boolean ifTrue:[
        arg == true ifTrue: [ ^5 ].
	arg == false ifTrue: [ ^5 ].
        ^0
    ].
    type == JavaPrimitiveType int ifTrue:[
        arg isInteger ifTrue: [
            (arg class == SmallInteger or: [
                arg between: -16r8000000 and:16r7FFFFFFF ]) ifTrue:[ ^4 ].
        ].
        ^0
    ].
    type == JavaPrimitiveType long ifTrue:[
        arg isInteger ifTrue: [
            (arg class == SmallInteger or: [
                arg between: -16r8000000_00000000 and:16r7FFFFFFF_FFFFFFFF ])
		    ifTrue:[ ^3 ].
        ].
        ^0
    ].
    type == JavaPrimitiveType float ifTrue:[
        arg isFloat ifTrue: [ ^2 ].
        ^0
    ].
    type == JavaPrimitiveType double ifTrue:[
        arg isFloat ifTrue: [ ^1 ].
        ^0
    ].
    type == JavaPrimitiveType char ifTrue:[
        arg isCharacter ifTrue: [ ^5 ].
        ^0
    ].

    arg isNil ifTrue: [ ^5 ].
    type isArrayType ifTrue: [
        arg isString ifTrue: [ ^0 ].
        (arg isKindOf: SequenceableCollection) ifTrue: [ ^5 ].
        ^0
    ].
    arg isString ifTrue: [ ^5 ].
    (arg isKindOf: JavaObject) ifTrue: [ ^5 ].
    ^0
!

convertToSmalltalk: javaObject type: type
    "Given a Java return value, convert to a Smalltalk object as appropriate.
     Currently, only a few types are converted."

    type == JavaPrimitiveType boolean ifTrue: [ ^javaObject == 1 ].
    type == JavaPrimitiveType void ifTrue:[ ^nil ].
    ^javaObject
!

convertToJava: arg type: type ifFail: errorBlock
    "Given a Smalltalk argument, check if it belongs to the
     correct Java type and convert as appropriate."

    type == JavaPrimitiveType boolean ifTrue:[
        arg == true ifTrue: [ ^1 ].
	arg == false ifTrue: [ ^0 ].
        ^errorBlock value
    ].
    type == JavaPrimitiveType int ifTrue:[
        arg isInteger ifTrue: [
            (arg class == SmallInteger or: [
                arg between: -16r8000000 and:16r7FFFFFFF ]) ifTrue:[ ^arg ].
        ].
        ^errorBlock value
    ].
    type == JavaPrimitiveType long ifTrue:[
        arg isInteger ifTrue: [
            (arg class == SmallInteger or: [
                arg between: -16r8000000_00000000 and:16r7FFFFFFF_FFFFFFFF ]) ifTrue:[ ^arg ].
        ].
        ^errorBlock value
    ].
    type == JavaPrimitiveType float ifTrue:[
        arg isFloat ifTrue: [ ^arg asFloatE ].
        ^errorBlock value
    ].
    type == JavaPrimitiveType double ifTrue:[
        arg isFloat ifTrue: [ ^arg asFloatD ].
        ^errorBlock value
    ].
    type == JavaPrimitiveType char ifTrue:[
        arg isCharacter ifTrue: [ ^arg value ].
        ^errorBlock value
    ].

    arg isNil ifTrue: [ ^arg ].
    type isArrayType ifTrue: [
        arg isString ifTrue: [ ^errorBlock value ].
        (arg isKindOf: SequenceableCollection) ifTrue: [ ^arg ].
        ^errorBlock value
    ].
    arg isString ifTrue: [ ^arg asJavaString ].
    (arg isKindOf: JavaObject) ifTrue: [ ^arg ].
    ^errorBlock value
!

convertToSmalltalk: javaObject type: type
    "Given a Java return value, convert to a Smalltalk object as appropriate.
     Currently, only a few types are converted."

    type == JavaPrimitiveType boolean ifTrue: [ ^javaObject == 1 ].
    type == JavaPrimitiveType void ifTrue:[ ^nil ].
    ^javaObject
!

lookupMethod: selector args: args static: static
    | name method goodness jc |
    name := selector last == $:
	ifTrue: [ selector copyFrom: 1 to: (selector indexOf: $:) - 1 ]
	ifFalse: [ selector ].

    name := name asSymbol.
    name == #init_ ifTrue: [ name := #'<init>' ].

    goodness := 0.
    method := nil.
    jc := javaClass.
    [
        javaClass methods do: [ :each || newGoodness |
	    (each name == name
                and: [ static == each isStatic
	        and: [ each numArgs = args size ]])
	        ifTrue: [
	            newGoodness := self check: args against: each argTypes.
		    newGoodness > goodness
		        ifTrue: [ method := each. goodness := newGoodness ]]
	].
	jc := jc extends.
	jc isNil
    ] whileFalse.
		
    ^method
!

doesNotUnderstand: aMessage
    "As a courtesy to the Smalltalker, try to map methods"
    | javaMethod |
    javaMethod := self
	lookupMethod: aMessage selector
	args: aMessage arguments
	static: true.

    javaMethod isNil ifTrue: [
        ^super doesNotUnderstand: aMessage ].

    ^self
	invokeJavaMethod: javaMethod
	withArguments: aMessage arguments
	on: self
!

invokeJavaMethod: javaMethod withArguments: args on: receiver
    | retVal javaArgs |
    javaArgs := args isEmpty
	ifTrue: [ args ]
	ifFalse: [
            self
                convertArgsToJava: args
                withSignature: javaMethod argTypes ].

    retVal := JavaVM
	invokeJavaSelector: javaMethod selector
	withArguments: javaArgs
	on: receiver.

    ^self convertToSmalltalk: retVal type: javaMethod returnType! !

!JavaObject methodsFor: 'message sending'!

doesNotUnderstand: aMessage
    "As a courtesy to the Smalltalker, try to map methods"
    | javaMethod |
    javaMethod := self class
	lookupMethod: aMessage selector
	args: aMessage arguments
	static: false.

    javaMethod isNil ifTrue: [
        ^super doesNotUnderstand: aMessage ].

    ^self class
	invokeJavaMethod: javaMethod
	withArguments: aMessage arguments
	on: self
! !


!JavaObject methodsFor: 'conversion'!

asJavaObject
    ^self!

!JavaObject methodsFor: 'interfaces'!

checkCast: anObject
    | message exception |
    (self isKindOf: anObject) ifTrue: [ ^self ].
    message := 'invalid cast' asJavaString.
    exception := Java.java.lang.ClassCastException new.
    exception perform: #'<init>(Ljava/lang/String;)V' with: message.
    exception throw!

initialize
!

instanceOf: anObject
    ^(self isKindOf: anObject) ifTrue: [ 1 ] ifFalse: [ 0 ]!

isKindOf: anObject
    ^anObject isClass
    	ifTrue: [
	    self class == anObject
		or: [ self class inheritsFrom: anObject ] ]
    	ifFalse: [
	    self implementsInterface: anObject ]!

implementsInterface: anInterface
    | class |
    class := self class.
    [
	(class asJavaClass implements includes: anInterface) ifTrue: [ ^true ].
	class := class superclass.
	class == JavaObject
    ] whileFalse.
    ^false!

monitorEnter
    "JavaMonitor enter: self"! "MONITOR!!!"

monitorExit
    "JavaMonitor exit: self"! "MONITOR!!!"
    
throw
    JavaException signal: self! !

!JavaObject class methodsFor: 'compiling'!

initializationString
    ^'initialized ifFalse: [
	initialized := true.
	self initialize ].'!

isConstant: aJavaField
    ^aJavaField isFinal and: [ aJavaField isStatic and: [ aJavaField constantValue notNil ]]!

needToInitialize: aJavaField
    "If a field is not static, it is initialized in the constructor
     even if it is final and has a constant value."
    ^(self isConstant: aJavaField) not
	and: [ aJavaField signature initializationValue notNil ]!

compileFieldInitializer
    | instanceStream classStream stream |
    instanceStream := WriteStream on: (String new: 40).
    classStream := WriteStream on: (String new: 40).
    instanceStream
	nextPutAll: 'initialize ['; nl; tab;
	nextPutAll: 'super initialize.'.

    classStream
	nextPutAll: 'initialize ['.

    javaClass fields do: [ :each |
	(self needToInitialize: each) ifTrue: [
	    stream := each isStatic
		ifTrue: [ classStream ]
		ifFalse: [ instanceStream ].

	    stream
		nl; tab;
		nextPutAll: each name; 
		nextPutAll: ' := ';
		store: each signature initializationValue;
		nextPut: $. ]].

    (self class includesSelector: #'<clinit>()V') ifTrue: [
	classStream
	    "nl; tab; nextPutAll: 'Transcript';
	    nl; tab; tab; nextPutAll: 'show: ''Initializing '';';
	    nl; tab; tab; nextPutAll: 'display: (self nameIn: Java); nl.';"
	    nl; tab; nextPutAll: 'self perform: #''<clinit>()V''.' ].

    (self includesSelector: #'finalize()V') ifTrue: [
	instanceStream
	    nl; tab; nextPutAll: 'self addToBeFinalized' ].

    instanceStream nextPutAll: ' ]'.
    classStream nextPutAll: ' ]'.
    self compile: instanceStream contents.
    self class compile: classStream contents!

compileSetterFor: field in: destClass
    | stream method auxName |
    stream := WriteStream on: (String new: 60).
    stream
    	nextPutAll: field putSelector;
    	nextPutAll: ' assignedValue$ [';
    	nl;
    	tab;
    	nextPutAll: field name;
    	nextPutAll: ' := assignedValue$';
	nl;
	nextPut: $].

    method := destClass compile: stream contents.
    auxName := (field name copyWith: $:) asSymbol.
    (JavaObject respondsTo: auxName) ifFalse: [
	destClass addSelector: auxName withMethod: method ]!

compileGetterFor: field in: destClass
    | stream method auxName |
    stream := WriteStream on: (String new: 100).
    stream
    	nextPutAll: field getSelector;
	nextPutAll: ' [';
    	nl.

    field isStatic ifTrue: [
	stream
	    tab;
	    nextPutAll: self initializationString;
	    nl ].

    stream
    	tab;
    	nextPut: $^;
    	nextPutAll: field name;
	nl;
	nextPut: $].

    method := destClass compile: stream contents.
    auxName := field name asSymbol.
    (JavaObject respondsTo: auxName) ifFalse: [
	destClass addSelector: auxName withMethod: method ]!

compileConstantFieldAccessor: constantField in: destClass
    | stream method auxName |
    stream := WriteStream on: (String new: 40).
    stream
    	nextPutAll: constantField getSelector;
	nextPutAll: ' [';
    	nl;
    	tab;
    	nextPutAll: '^##(';
    	store: constantField constantValue;
	nextPut: $);
	nl;
	nextPut: $].

    method := destClass compile: stream contents.
    auxName := constantField name asSymbol.
    (JavaObject respondsTo: auxName) ifFalse: [
	self class addSelector: auxName withMethod: method ]!

compileAccessors
    javaClass fields do: [:each || destClass |
	destClass := each isStatic 
	    ifTrue: [ self class ] ifFalse: [ self ].

        (self isConstant: each)
	    ifTrue: [
		self compileConstantFieldAccessor: each in: destClass ]
	    ifFalse: [
		self compileGetterFor: each in: destClass.
	    	self compileSetterFor: each in: destClass]]!

createMethodProxies
    javaClass methods do: [:each | 
	| selector method homeClass |
	each isNative ifFalse: [
	    homeClass := each isStatic ifTrue: [self class] ifFalse: [self].
	    selector := each selector.
    	    method := JavaUntranslatedMethod
		for: each
		selector: selector
		class: homeClass.

	    homeClass addSelector: selector withMethod: method]]!

createSubclass: aJavaClass into: theNamespace
    | meta theClass instVars classVars |
    "Classify fields into instance variables, class variables, and constants."
    instVars := self allInstVarNames asOrderedCollection.
    classVars := BindingDictionary new.
    aJavaClass fields do: [:each | 
	(self isConstant: each) ifFalse: [
	    each isStatic 
    		ifTrue: [classVars at: each name asSymbol put: nil]
    		ifFalse: [instVars add: each name asSymbol]]].

    "Add a hook from the java.lang.Class object back to the Smalltalk class."
    aJavaClass fullName = 'java.lang.Class' ifTrue: [
    	instVars add: #smalltalkClass ].

    meta := Metaclass subclassOf: self class.
    theClass := meta
    	name: aJavaClass name
    	environment: theNamespace
    	subclassOf: self
    	instanceVariableArray: instVars asArray
    	shape: nil
    	classPool: classVars
    	poolDictionaries: #()
    	category: 'Java'.

    ^theClass
    	javaClass: aJavaClass;
    	compileAccessors;
    	createMethodProxies;	
	compileFieldInitializer;
	yourself! !

!JavaObject class methodsFor: 'initializing'!

maybeInitialize
    initialized ifFalse: [
	initialized := true.
	self initialize ]!

new
    "We inline maybeInitialize for speed."
    initialized ifFalse: [
	initialized := true.
	self initialize ].
    ^self basicNew initialize!

main
    | args |
    args := Smalltalk arguments collect: [ :each | each asJavaString ].
    ^JavaVM
	invokeJavaSelector: #'main([Ljava/lang/String;)V'
	withArguments: { args }
	on: self
!

initialized
    ^initialized!

initialize
!

!JavaObject class methodsFor: 'accessing'!

asJavaClass
    ^javaClass!

asJavaObject
    ^self javaLangClass!

implements: anInterface
    ^self javaClass implementsInterface: anInterface!

javaClass
    ^javaClass!

javaLangClass
    javaLangClass isNil ifTrue: [
	javaLangClass := Java.java.lang.Class new javaClass: javaClass ].
    ^javaLangClass!

javaClass: anObject
    javaClass := anObject.
    initialized := false! !

!JavaSynchronizedMethodWrapper methodsFor: 'forwarding'!

valueWithReceiver: receiver withArguments: args
    ^[
    	JavaMonitor enter: receiver asJavaObject.
    	receiver perform: self wrappedMethod withArguments: args
    ] ensure: [ JavaMonitor exit: receiver asJavaObject ]! !

!JavaSynchronizedMethodWrapper methodsFor: 'accessing'!

javaMethod
    ^self wrappedMethod javaMethod!

wrappedMethod
    ^wrappedMethod!

wrappedMethod: anObject

    self descriptor
	selector: anObject selector;
	methodClass: anObject methodClass.

    wrappedMethod := anObject! !

!JavaSynchronizedMethodWrapper class methodsFor: 'instance creation'!

for: aCompiledMethod
    ^(self numArgs: aCompiledMethod numArgs)
	wrappedMethod: aCompiledMethod; yourself! !

!JavaMethodInfo class methodsFor: 'instance creation'!

copyFrom: descriptor
    ^(self new: descriptor size)
    	copyFrom: descriptor! !

!JavaMethodInfo methodsFor: 'accessing'!

copyFrom: descriptor
    sourceCode := descriptor sourceCode.
    category := descriptor category.
    class := descriptor methodClass.
    selector := descriptor selector.
    1 to: descriptor size do: [ :i |
    	self at: i put: (descriptor at: i) ]!

javaMethod
    ^javaMethod!

javaMethod: aJavaMethod
    javaMethod := aJavaMethod! !

!JavaCompiledMethod methodsFor: 'accessing'!

javaMethod
    ^self descriptor javaMethod! !

!JavaUntranslatedMethod methodsFor: 'translation'!

valueWithReceiver: receiver withArguments: args
    | trans cm |
    trans := JavaMethodTranslator onMethod: self javaMethod.
    trans translate.

    cm := trans compiledMethod.
    cm makeReadOnly: false.
    cm descriptor methodClass: self methodClass.
    cm descriptor selector: self selector.
    cm descriptor: (JavaMethodInfo copyFrom: cm descriptor).
    cm descriptor javaMethod: self javaMethod.

    "javaMethod isSynchronized
    	ifTrue: [ cm := JavaSynchronizedMethodWrapper for: cm ]."  "MONITOR!!!"

    self become: cm.
    Behavior flushCache.

    "Here, self is the translated method!!!"
    self methodClass asClass maybeInitialize.
    self makeReadOnly: true.

    ^receiver perform: self withArguments: args! !

!JavaUntranslatedMethod methodsFor: 'accessing'!

javaMethod
    ^javaMethod!

javaMethod: anObject
    javaMethod := anObject! !

!JavaUntranslatedMethod class methodsFor: 'instance creation'!

for: aJavaMethod selector: selector class: homeClass
    | descriptor |
    descriptor := MethodInfo new
    	selector: selector;
	methodClass: homeClass;
	yourself.

    ^(self numArgs: aJavaMethod numArgs)
    	descriptor: descriptor;
	javaMethod: aJavaMethod;
	yourself! !

!JavaException class methodsFor: 'signal'!

resignal: ex as: anObject
    ex resignalAs: (self new
	tag: anObject;
	yourself)!

signal: anObject
    ^self new
	tag: anObject;
	signal!

!JavaException methodsFor: 'signal'!

messageText
    | msg |
    self tag isNil
    	ifFalse: [
	    msg := self tag detailMessage.
	    msg := msg isNil
		ifTrue: [ 'A ', (self tag class nameIn: Java), ' was thrown' ]
		ifFalse: [ msg asString ] ]
	ifTrue: [
	    msg := 'A Java program threw an exception.' ].

    ^msg
!

javaException
    ^self tag
!

foundJavaHandler: handler in: context
    self
        onDoBlock: nil
        handlerBlock: handler handlerpc
        onDoContext: context
        previousState: nil!

activateHandler: resumeBoolean
    "Run the handler, passing to it aSignal, an instance of Signal.  aBoolean
     indicates the action (either resuming the receiver of #on:do:... or
     exiting it) to be taken upon leaving from the handler block."

    | result baseSP |
    <exceptionHandlingInternal: true>

    "If in a Smalltalk exception handler, no problem."
    handlerBlock isInteger
	ifFalse: [ ^super activateHandler: resumeBoolean ].

    baseSP := context method numTemps + context method numArgs.
    result := context at: baseSP.
    context ip: handlerBlock.

    "There is no method to continue without adjusting the stack.  Simulate
     this by `returning' what the return value would overwrite, that is, the
     the value of the last temporary or argument."
    context
	sp: baseSP - 1;
	continue: result
! !

!JavaFileDescriptor methodsFor: 'error checking'!

checkError
    | exception msg errno |
    errno := File errno.
    errno < 1 ifTrue: [ ^0 ].
    msg := (self stringError: errno) asJavaString.
    exception := Java.java.io.IOException new.
    exception perform: #'<init>(Ljava/lang/String;)V' with: msg.
    exception throw! !

!JavaVM class methodsFor: 'starting'!

invokeJavaSelector: selector withArguments: args on: receiver
    "Invoke receiver's Java method with the given arguments,
     mapping Smalltalk's MessageNotUnderstood and ZeroDivide
     exceptions to Java's NullPointerException and
     ArithmeticException."

    ^[ receiver perform: selector withArguments: args ]
	on: SystemExceptions.IndexOutOfRange
	do: [ :ex || exception |
	    exception := Java.java.lang.ArrayIndexOutOfBoundsException new.
	    exception perform: #'<init>(I)V' with: ex value - 1.
	    JavaException resignal: ex as: exception ]

        on: ZeroDivide
        do: [ :ex |
            JavaVM
                resignal: ex
                as: Java.java.lang.ArithmeticException
                message: 'division by zero' ]

        on: MessageNotUnderstood
        do: [ :ex |
            ex receiver isNil ifFalse: [ ex pass ].
            JavaVM
                resignal: ex
                as: Java.java.lang.NullPointerException ]!

run: className
    | path |
    path := className asString copyReplacing: $. withObject: $/.
    (JavaClass fromString: path) asSmalltalkClass main! !

!JavaVM class methodsFor: 'files'!

fileDescriptorFor: fd
    | fdObj |
    fd < 0 ifTrue: [ ^nil ].
    fd >= OpenFileTable size ifTrue: [
	fd - OpenFileTable size + 1 timesRepeat: [
	    OpenFileTable addLast: nil ] ].
    fdObj := OpenFileTable at: fd + 1.
    fdObj isNil ifTrue: [
	OpenFileTable
	    at: fd + 1
	    put: (fdObj := JavaFileDescriptor on: fd) ].
    ^fdObj! !

!JavaVM class methodsFor: 'native methods'!

installNativeMethods
    self methodDictionary do: [ :each |
	| attr javaMethodName destClass static |
	each descriptor size > 0 ifTrue: [
	    attr := each descriptor at: 1.
	    attr selector == #javaNativeMethod:for:static: ifTrue: [
	        javaMethodName := attr arguments at: 1.
	        destClass := attr arguments at: 2.
	        static := attr arguments at: 3.
	        destClass value isNil ifTrue: [ self load: destClass ].

		destClass := destClass value.
		static ifTrue: [ destClass := destClass class ].
	        destClass addSelector: javaMethodName withMethod: each
	    ]
	]
    ]!

load: class
    | className |
    "Convert '#{Java.java.lang.Object}' into 'java.lang.Object'."
    className := class storeString.
    className := className copyFrom: 8 to: className size - 1.
    (JavaClass loadClass: className) install! !

!JavaVM class methodsFor: 'bootstrapping'!

bootstrap
    | classPath |
    Bootstrapped := false.
    JavaClassFileReader classDirectories isNil
	ifTrue: [
	    classPath := Smalltalk getenv: 'CLASSPATH'.
	    classPath isNil ifTrue: [ self error: 'CLASSPATH not set' ].
	    JavaClassFileReader classPath: classPath ].

    Transcript show: 'Installing native methods...'; nl.
    self installNativeMethods.

    Transcript show: 'Initializing core classes...'; nl.
    self initializePrimitiveClasses.
    self installMoreClasses.
    Java.java.lang.String maybeInitialize.
    JavaStringPrototype	allInstances
	do: [ :each | each convertToJavaLangString ].

    Transcript show: 'Starting the system...'; nl.
    Bootstrapped := true.
    Java.java.lang.Runtime maybeInitialize.
    ObjectMemory addDependent: self.
    self update: #returnFromSnapshot!

bootstrapped
    ^Bootstrapped!

installMoreClasses
    "Classes needed to initialize the system"
    (JavaClass fromString: 'java/lang/ThreadGroup') install.
    (JavaClass fromString: 'java/lang/Thread') install.

    "Classes needed by the native methods"
    (JavaClass fromString: 'java/lang/Cloneable') install.
    (JavaClass fromString: 'java/lang/Byte') install.
    (JavaClass fromString: 'java/lang/Integer') install.
    (JavaClass fromString: 'java/lang/Float') install.
    (JavaClass fromString: 'java/lang/Double') install.
    (JavaClass fromString: 'java/lang/Void') install.
    (JavaClass fromString: 'java/lang/Boolean') install.
    (JavaClass fromString: 'java/lang/Short') install.
    (JavaClass fromString: 'java/lang/Long') install.

    "Exceptions that we want to throw"
    (JavaClass fromString: 'java/lang/ClassCastException') install.
    (JavaClass fromString: 'java/lang/ArrayIndexOutOfBoundsException') install.
    (JavaClass fromString: 'java/lang/StringIndexOutOfBoundsException') install.
    (JavaClass fromString: 'java/lang/IllegalThreadStateException') install.
    (JavaClass fromString: 'java/lang/ClassCastException') install.
    (JavaClass fromString: 'java/lang/NullPointerException') install.
    (JavaClass fromString: 'java/lang/ArithmeticException') install.
    (JavaClass fromString: 'java/lang/CloneNotSupportedException') install.
    (JavaClass fromString: 'java/io/IOException') install!

initializePrimitiveClasses
    IntClass := Java.java.lang.Class new javaType: JavaPrimitiveType int.
    ByteClass := Java.java.lang.Class new javaType: JavaPrimitiveType byte.
    ShortClass := Java.java.lang.Class new javaType: JavaPrimitiveType short.
    LongClass := Java.java.lang.Class new javaType: JavaPrimitiveType long.
    FloatClass := Java.java.lang.Class new javaType: JavaPrimitiveType float.
    DoubleClass := Java.java.lang.Class new javaType: JavaPrimitiveType double.
    VoidClass := Java.java.lang.Class new javaType: JavaPrimitiveType void.
    BooleanClass := Java.java.lang.Class new javaType: JavaPrimitiveType boolean.
    CharClass := Java.java.lang.Class new javaType: JavaPrimitiveType char!

!JavaVM class methodsFor: 'restarting'!

update: event
    event == #aboutToSnapshot ifTrue: [
	self stopThreads
    ].
    event == #returnFromSnapshot ifTrue: [
	OpenFileTable := OrderedCollection new.
	self startMainThread
    ]! !

!JavaVM class methodsFor: 'managing Threads'!

cleanup
    JoinedThreads := IdentityDictionary new.
    Threads := Dictionary new!

stopThreads
    ThreadAccessMutex critical: [ | process |
	Threads do: [ :each | each terminate ].
	self cleanup ]!

startMainThread
    | mainString |

    ThreadAccessMutex := RecursionLock new.
    self cleanup.

    TopGroup := Java.java.lang.ThreadGroup new.
    MainGroup := Java.java.lang.ThreadGroup new.
    MainThread := Java.java.lang.Thread new.
    mainString := 'main' asJavaString.

    TopGroup perform: #'<init>()V'.

    MainGroup
	perform: #'<init>(Ljava/lang/ThreadGroup;Ljava/lang/String;)V'
	with: TopGroup with: mainString.

    MainThread
	perform: #'<init>(Ljava/lang/ThreadGroup;Ljava/lang/String;)V'
	with: MainGroup with: mainString.

    MainThread perform: #'setDaemon(Z)V' with: 1.
    MainThread perform: #'setPriority(I)V' with: 5! !

!JavaVM class methodsFor: 'exception support'!

resignal: ex as: class message: msg
    JavaException resignal: ex as: (class new
	perform: #'<init>(Ljava/lang/String;)V' with: msg;
	yourself)!

resignal: ex as: class
    JavaException resignal: ex as: (class new
	perform: #'<init>()V';
	yourself)!

throw: class message: msg
    JavaException signal: (class new
	perform: #'<init>(Ljava/lang/String;)V' with: msg;
	yourself)!

throw: class
    JavaException signal: (class new
	perform: #'<init>()V';
	yourself)!

!JavaVM class methodsFor: 'private'!

addThread: aThread for: aProcess
    ThreadAccessMutex critical: [
	(Threads includesKey: aThread)
	     ifTrue: [
		 ^self throw: Java.java.lang.IllegalThreadStateException ].
	Threads at: aThread put: aProcess ]!

removeThread: aThread
    | joinSemaphores |
    ThreadAccessMutex critical: [ | process |
	process := Threads
	    at: aThread
	    ifAbsent: [ ^self error: 'not a Java thread' ].

	Threads removeKey: aThread.
	JoinMutex wait.
        joinSemaphores := JoinedThreads at: aThread ifAbsent: [ nil ].
        joinSemaphores isNil ifFalse: [ 
	    joinSemaphores do: [ :each | each signal ] ].

	JoinMutex signal.
	process terminate ]!

convertPriority: javaPrio
    ^javaPrio // 3 + Processor userBackgroundPriority! !

JavaMonitor initialize!
PK
     �Mh@�[��  �    java_util_TimeZone.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.util.TimeZone native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.util.TimeZone'!

java_util_TimeZone_getDefaultTimeZoneId
    <javaNativeMethod: #'getDefaultTimeZoneId()Ljava/lang/String;'
        for: #{Java.java.util.TimeZone} static: true>
    self notYetImplemented
! !

PK
     �Mh@��r�y  y    java_lang_reflect_Proxy.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.reflect.Proxy native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"

!JavaVM methodsFor: 'java.lang.reflect.Proxy'!

java_lang_reflect_Proxy_getProxyClass0_java_lang_ClassLoader: arg1 java_lang_ClassArray: arg2
    <javaNativeMethod: #'getProxyClass0(Ljava/lang/ClassLoader;[Ljava/lang/Class;)Ljava/lang/Class;'
        for: #{Java.java.lang.reflect.Proxy} static: true>
    ^nil
!

java_lang_reflect_Proxy_getProxyData0_java_lang_ClassLoader: arg1 java_lang_ClassArray: arg2
    <javaNativeMethod: #'getProxyData0(Ljava/lang/ClassLoader;[Ljava/lang/Class;)Ljava/lang/reflect/Proxy$ProxyData;'
        for: #{Java.java.lang.reflect.Proxy} static: true>
    ^nil
!

java_lang_reflect_Proxy_generateProxyClass0_java_lang_ClassLoader: arg1 java_lang_reflect_Proxy$ProxyData: arg2
    <javaNativeMethod: #'generateProxyClass0(Ljava/lang/ClassLoader;Ljava/lang/reflect/Proxy$ProxyData;)Ljava/lang/Class;'
        for: #{Java.java.lang.reflect.Proxy} static: true>
    ^nil
! !
PK
     �Mh@���r�  �    java_net_NetworkInterface.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.net.NetworkInterface native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.net.NetworkInterface'!

java_net_NetworkInterface_getRealNetworkInterfaces
    <javaNativeMethod: #'getRealNetworkInterfaces()Ljava/util/Vector;'
        for: #{Java.java.net.NetworkInterface} static: true>
    self notYetImplemented
! !

PK    �Mh@�~�F�   j  	  ChangeLogUT	 dqXOe�XOux �  �  ���j�@���S�V�٘BK!�=�TRz�-���%c�&�O_;y��6�}3�[�|Q��x'�G�/X�/j�J*th�Yvu���oj���Ė;=2DO���Є�ɰj|�5"�VdY9#\��7:��Y̫Xaq����,���̤ m��"I����k�Xqϙ���U����)���T�B��i��q��ڠ��X���d��v�M}���K�k���~�*���/PK
     �Mh@R����  �    java_lang_reflect_Field.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.reflect.Field native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.reflect.Field'!

java_lang_reflect_Field_getName
    <javaNativeMethod: #'getName()Ljava/lang/String;'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_getType
    <javaNativeMethod: #'getType()Ljava/lang/Class;'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_getModifiers
    <javaNativeMethod: #'getModifiers()I'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_getBoolean_java_lang_Class: arg1 java_lang_Object: arg2
    <javaNativeMethod: #'getBoolean(Ljava/lang/Class;Ljava/lang/Object;)Z'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_getChar_java_lang_Class: arg1 java_lang_Object: arg2
    <javaNativeMethod: #'getChar(Ljava/lang/Class;Ljava/lang/Object;)C'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_getByte_java_lang_Class: arg1 java_lang_Object: arg2
    <javaNativeMethod: #'getByte(Ljava/lang/Class;Ljava/lang/Object;)B'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_getShort_java_lang_Class: arg1 java_lang_Object: arg2
    <javaNativeMethod: #'getShort(Ljava/lang/Class;Ljava/lang/Object;)S'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_getInt_java_lang_Class: arg1 java_lang_Object: arg2
    <javaNativeMethod: #'getInt(Ljava/lang/Class;Ljava/lang/Object;)I'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_getLong_java_lang_Class: arg1 java_lang_Object: arg2
    <javaNativeMethod: #'getLong(Ljava/lang/Class;Ljava/lang/Object;)J'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_getFloat_java_lang_Class: arg1 java_lang_Object: arg2
    <javaNativeMethod: #'getFloat(Ljava/lang/Class;Ljava/lang/Object;)F'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_getDouble_java_lang_Class: arg1 java_lang_Object: arg2
    <javaNativeMethod: #'getDouble(Ljava/lang/Class;Ljava/lang/Object;)D'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_get_java_lang_Class: arg1 java_lang_Object: arg2
    <javaNativeMethod: #'get(Ljava/lang/Class;Ljava/lang/Object;)Ljava/lang/Object;'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_setByte_java_lang_Class: arg1 java_lang_Object: arg2 byte: arg3
    <javaNativeMethod: #'setByte(Ljava/lang/Class;Ljava/lang/Object;B)V'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_setShort_java_lang_Class: arg1 java_lang_Object: arg2 short: arg3
    <javaNativeMethod: #'setShort(Ljava/lang/Class;Ljava/lang/Object;S)V'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_setInt_java_lang_Class: arg1 java_lang_Object: arg2 int: arg3
    <javaNativeMethod: #'setInt(Ljava/lang/Class;Ljava/lang/Object;I)V'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_setLong_java_lang_Class: arg1 java_lang_Object: arg2 long: arg3
    <javaNativeMethod: #'setLong(Ljava/lang/Class;Ljava/lang/Object;J)V'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_setFloat_java_lang_Class: arg1 java_lang_Object: arg2 float: arg3
    <javaNativeMethod: #'setFloat(Ljava/lang/Class;Ljava/lang/Object;F)V'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_setDouble_java_lang_Class: arg1 java_lang_Object: arg2 double: arg3
    <javaNativeMethod: #'setDouble(Ljava/lang/Class;Ljava/lang/Object;D)V'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_setChar_java_lang_Class: arg1 java_lang_Object: arg2 char: arg3
    <javaNativeMethod: #'setChar(Ljava/lang/Class;Ljava/lang/Object;C)V'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_setBoolean_java_lang_Class: arg1 java_lang_Object: arg2 boolean: arg3
    <javaNativeMethod: #'setBoolean(Ljava/lang/Class;Ljava/lang/Object;Z)V'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
!

java_lang_reflect_Field_set_java_lang_Class: arg1 java_lang_Object: arg2 java_lang_Object: arg3 java_lang_Class: arg4
    <javaNativeMethod: #'set(Ljava/lang/Class;Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Class;)V'
        for: #{Java.java.lang.reflect.Field} static: false>
    self notYetImplemented
! !

PK
     �Mh@Q��6  6    java_lang_Double.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.Double native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.Double'!

java_lang_Double_parseDouble_java_lang_String: arg1
    <javaNativeMethod: #'parseDouble(Ljava/lang/String;)D'
        for: #{Java.java.lang.Double} static: true>
    ^arg1 asString asNumber asFloatD
!

java_lang_Double_doubleToLongBits_double: arg1
    | exp mantissa expField |
    <javaNativeMethod: #'doubleToLongBits(D)J'
        for: #{Java.java.lang.Double} static: true>

    "Handle NaN here."
    arg1 = arg1 ifFalse: [ ^16r7FF8_0000_0000_0000 ].
    exp := arg1 exponent.
    mantissa := arg1 negative
        ifTrue: [ expField := exp - 1026. arg1 * -1 ]
        ifFalse: [ expField := exp + 1022. arg1 ].

    "Handle zero and infinity"
    arg1 = 0
	ifTrue: [ expField := exp - 1024. mantissa := 0 ]
	ifFalse: [
	    arg1 + arg1 = arg1
		ifTrue: [ expField := expField + 1026. mantissa := 0 ]
		ifFalse: [ mantissa := mantissa timesTwoPower: 52 - exp ].
	].

    ^mantissa asInteger + (expField * 16r10_0000_0000_0000)
!

java_lang_Double_doubleToRawLongBits_double: arg1
    | v1 v2 v3 v4 v12 v34 |
    <javaNativeMethod: #'doubleToRawLongBits(D)J'
        for: #{Java.java.lang.Double} static: true>
    v1 := ((arg1 at: 8) * 256 + (arg1 at: 7)) javaAsShort.
    v2 := (arg1 at: 6) * 256 + (arg1 at: 5).
    v3 := (arg1 at: 4) * 256 + (arg1 at: 3).
    v4 := (arg1 at: 2) * 256 + (arg1 at: 1).
    v12 := v1 * 65536 + v2.
    v34 := v3 * 65536 + v4.
    ^(v12 bitShift: 32) + v34
!

java_lang_Double_longBitsToDouble_long: arg1
    | s e m |
    <javaNativeMethod: #'longBitsToDouble(J)D'
        for: #{Java.java.lang.Double} static: true>
    s := arg1 < 0 ifTrue: [ -1.0d ] ifFalse: [ 1.0d ].
    e := (arg1 bitShift: -52) bitAnd: 16r7FF.
    m := arg1 bitAnd: 16rF_FFFF_FFFF_FFFF.

    e = 16r7FF ifTrue: [
        ^m = 0
            ifTrue: [ 1.0d / (0.0d * s) ]
            ifFalse: [ (1.0d / 0.0d) - (1.0d / 0.0d) ].
    ].

    "Check for zero and denormals, then convert to a floating-point value"
    e = 0
        ifTrue: [ e := 1 ]
        ifFalse: [ m := m + 16r10_0000_0000_0000 ].

    ^m * s timesTwoPower: e - 1075
!

java_lang_Double_toString_double: arg1 boolean: arg2
    <javaNativeMethod: #'toString(DZ)Ljava/lang/String;'
        for: #{Java.java.lang.Double} static: true>
    ^arg2 = 1
	ifTrue: [ arg1 asFloatE printString asJavaString ]
	ifFalse: [ arg1 asFloatD printString asJavaString ]
! !

PK
     �Mh@C���e(  e(    java_lang_reflect_Array.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.reflect.Array native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.reflect.Array'!

java_lang_reflect_Array_newInstance_java_lang_Class: arg1 int: arg2
    | arrayClass |
    <javaNativeMethod: #'newInstance(Ljava/lang/Class;I)Ljava/lang/Object;'
        for: #{Java.java.lang.reflect.Array} static: true>
    arg1 == VoidClass ifTrue: [
	^JavaVM throw: Java.java.lang.IllegalArgumentException ].
    arg2 < 0 ifTrue: [
	^JavaVM throw: Java.java.lang.NegativeArraySizeException ].

    arrayClass := arg1 javaType arrayClass.
    ^arrayClass new: arg2!

java_lang_reflect_Array_newInstance_java_lang_Class: arg1 intArray: arg2
    <javaNativeMethod: #'newInstance(Ljava/lang/Class;[I)Ljava/lang/Object;'
        for: #{Java.java.lang.reflect.Array} static: true>
    (arg1 javaType isArrayType and: [
	(arg1 javaType arrayDimensionality >= arg2 size) ]) ifFalse: [
	    ^JavaVM throw: Java.java.lang.IllegalArgumentException ].

    ^arg1 javaType javaMultiNewArray: arg2 from: 1
!

java_lang_reflect_Array_getLength_java_lang_Object: arg1
    <javaNativeMethod: #'getLength(Ljava/lang/Object;)I'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 isKindOf: JavaObject)
	ifTrue: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifFalse: [ arg1 size ]
!

java_lang_reflect_Array_get_java_lang_Object: arg1 int: arg2
    | desiredClass |
    <javaNativeMethod: #'get(Ljava/lang/Object;I)Ljava/lang/Object;'
        for: #{Java.java.lang.reflect.Array} static: true>
    arg1 class == Array
	ifTrue: [ ^arg1 javaAt: arg2 ].

    arg1 class == JavaBooleanArray ifTrue: [
	^(arg1 javaAt: arg2) = 0
	    ifTrue: [ Java.java.lang.Boolean FALSE ]
	    ifFalse: [ Java.java.lang.Boolean TRUE ]].
 
    desiredClass :=
        arg1 class == JavaIntArray ifTrue: [ Java.java.lang.Integer ] ifFalse: [
        arg1 class == JavaShortArray ifTrue: [ Java.java.lang.Short ] ifFalse: [
        arg1 class == JavaByteArray ifTrue: [ Java.java.lang.Byte ] ifFalse: [
        arg1 class == JavaLongArray ifTrue: [ Java.java.lang.Long ] ifFalse: [
        arg1 class == JavaFloatArray ifTrue: [ Java.java.lang.Float ] ifFalse: [
        arg1 class == JavaDoubleArray ifTrue: [ Java.java.lang.Double ] ifFalse: [
        Java.java.lang.Char ]]]]]].

    ^desiredClass new
	perform: #'<init>()V';
	value: (arg1 javaAt: arg2)
!

java_lang_reflect_Array_getChar_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getChar(Ljava/lang/Object;I)C'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^arg1 class == JavaCharArray
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifTrue: [ arg1 javaAt: arg2 ]
!

java_lang_reflect_Array_getByte_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getByte(Ljava/lang/Object;I)B'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^arg1 class == JavaByteArray
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifTrue: [ arg1 javaAt: arg2 ]
!

java_lang_reflect_Array_getShort_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getShort(Ljava/lang/Object;I)S'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == JavaByteArray 
	or: [ arg1 class == JavaShortArray ])
	    ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	    ifTrue: [ arg1 javaAt: arg2 ]
!

java_lang_reflect_Array_getInt_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getInt(Ljava/lang/Object;I)I'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == JavaByteArray 
	or: [ arg1 class == JavaCharArray
	or: [ arg1 class == JavaIntArray
	or: [ arg1 class == JavaShortArray ]]])
	    ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	    ifTrue: [ arg1 javaAt: arg2 ]
!

java_lang_reflect_Array_getLong_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getLong(Ljava/lang/Object;I)J'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == Array
	or: [ arg1 class == ByteArray 
	or: [ arg1 class == JavaDoubleArray 
	or: [ arg1 class == JavaFloatArray ]]])
	    ifTrue: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	    ifFalse: [ arg1 javaAt: arg2 ]
!

java_lang_reflect_Array_getFloat_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getFloat(Ljava/lang/Object;I)F'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == Array
	or: [ arg1 class == ByteArray 
	or: [ arg1 class == JavaDoubleArray ]])
	ifTrue: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifFalse: [ (arg1 javaAt: arg2) asFloatE ]
!

java_lang_reflect_Array_getDouble_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getDouble(Ljava/lang/Object;I)D'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == Array or: [ arg1 class == ByteArray ])
	ifTrue: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifFalse: [ (arg1 javaAt: arg2) asFloatD ]
!

java_lang_reflect_Array_getBoolean_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getBoolean(Ljava/lang/Object;I)Z'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^arg1 class == ByteArray
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifTrue: [ arg1 javaAt: arg2 ]
!

java_lang_reflect_Array_getElementType_java_lang_Object: arg1 int: arg2
    <javaNativeMethod: #'getElementType(Ljava/lang/Object;I)Ljava/lang/Class;'
        for: #{Java.java.lang.reflect.Array} static: true>
    self notYetImplemented
!

java_lang_reflect_Array_set_java_lang_Object: arg1 int: arg2 java_lang_Object: arg3 java_lang_Class: arg4
    <javaNativeMethod: #'set(Ljava/lang/Object;ILjava/lang/Object;Ljava/lang/Class;)V'
        for: #{Java.java.lang.reflect.Array} static: true>

    (arg3 isKindOf: arg4 asSmalltalkClass)
	ifFalse: [ ^JavaVM throw: Java.java.lang.IllegalArgumentException ]

    arg1 javaAt: arg2 put: arg3
!

java_lang_reflect_Array_setByte_java_lang_Object: arg1 int: arg2 byte: arg3
    <javaNativeMethod: #'setByte(Ljava/lang/Object;IB)V'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == Array
	or: [ arg1 class == ByteArray
	or: [ arg1 class == JavaCharArray ]])
	ifTrue: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifFalse: [ arg1 javaAt: arg2 put: arg3 ]
!

java_lang_reflect_Array_setShort_java_lang_Object: arg1 int: arg2 short: arg3
    <javaNativeMethod: #'setShort(Ljava/lang/Object;IS)V'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == Array
	or: [ arg1 class == JavaByteArray
	or: [ arg1 class == ByteArray
	or: [ arg1 class == JavaCharArray ]]])
	ifTrue: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifFalse: [ arg1 javaAt: arg2 put: arg3 ]
!

java_lang_reflect_Array_setInt_java_lang_Object: arg1 int: arg2 int: arg3
    <javaNativeMethod: #'setInt(Ljava/lang/Object;II)V'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == JavaDoubleArray
	or: [ arg1 class == JavaFloatArray
	or: [ arg1 class == JavaIntArray
	or: [ arg1 class == JavaLong Array ]]])
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifTrue: [ arg1 javaAt: arg2 put: arg3 ]
!

java_lang_reflect_Array_setLong_java_lang_Object: arg1 int: arg2 long: arg3
    <javaNativeMethod: #'setLong(Ljava/lang/Object;IJ)V'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == JavaDoubleArray
	or: [ arg1 class == JavaFloatArray
	or: [ arg1 class == JavaLong Array ]])
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifTrue: [ arg1 javaAt: arg2 put: arg3 ]
!

java_lang_reflect_Array_setFloat_java_lang_Object: arg1 int: arg2 float: arg3
    <javaNativeMethod: #'setFloat(Ljava/lang/Object;IF)V'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == JavaDoubleArray or: [ arg1 class == JavaFloatArray ])
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifTrue: [ arg1 javaAt: arg2 put: arg3 ]
!

java_lang_reflect_Array_setDouble_java_lang_Object: arg1 int: arg2 double: arg3
    <javaNativeMethod: #'setDouble(Ljava/lang/Object;ID)V'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^arg1 class == JavaDoubleArray
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifTrue: [ arg1 javaAt: arg2 put: arg3 ]
!

java_lang_reflect_Array_setChar_java_lang_Object: arg1 int: arg2 char: arg3
    <javaNativeMethod: #'setChar(Ljava/lang/Object;IC)V'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^(arg1 class == Array
	or: [ arg1 class == ByteArray
	or: [ arg1 class == JavaShortArray
	or: [ arg1 class == JavaCharArray ]]])
	ifTrue: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifFalse: [ arg1 javaAt: arg2 put: arg3 ]
!

java_lang_reflect_Array_setBoolean_java_lang_Object: arg1 int: arg2 boolean: arg3
    <javaNativeMethod: #'setBoolean(Ljava/lang/Object;IZ)V'
        for: #{Java.java.lang.reflect.Array} static: true>
    ^arg1 class == ByteArray
	ifFalse: [ JavaVM throw: Java.java.lang.IllegalArgumentException ]
	ifTrue: [ arg1 javaAt: arg2 put: arg3 ]
! !

PK
     �Mh@��~�)  )    java_io_File.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  java.io.File native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.io.File'!

java_io_File_attr_int: arg1
    <javaNativeMethod: #'attr(I)J'
        for: #{Java.java.io.File} static: false>
    self notYetImplemented
!

java_io_File__access_int: arg1
    <javaNativeMethod: #'_access(I)Z'
        for: #{Java.java.io.File} static: false>
    self notYetImplemented
!

java_io_File__stat_int: arg1
    <javaNativeMethod: #'_stat(I)Z'
        for: #{Java.java.io.File} static: false>
    self notYetImplemented
!

java_io_File_init_native
    <javaNativeMethod: #'init_native()V'
        for: #{Java.java.io.File} static: true>
    self notYetImplemented
!

java_io_File_performCreate
    <javaNativeMethod: #'performCreate()Z'
        for: #{Java.java.io.File} static: false>
    self notYetImplemented
!

java_io_File_performDelete
    <javaNativeMethod: #'performDelete()Z'
        for: #{Java.java.io.File} static: false>
    self notYetImplemented
!

java_io_File_getCanonicalPath
    <javaNativeMethod: #'getCanonicalPath()Ljava/lang/String;'
        for: #{Java.java.io.File} static: false>
    self notYetImplemented
!

java_io_File_isAbsolute
    <javaNativeMethod: #'isAbsolute()Z'
        for: #{Java.java.io.File} static: false>
    self notYetImplemented
!

java_io_File_performList_java_io_FilenameFilter: arg1 java_io_FileFilter: arg2 java_lang_Class: arg3
    <javaNativeMethod: #'performList(Ljava/io/FilenameFilter;Ljava/io/FileFilter;Ljava/lang/Class;)[Ljava/lang/Object;'
        for: #{Java.java.io.File} static: false>
    self notYetImplemented
!

java_io_File_performMkdir
    <javaNativeMethod: #'performMkdir()Z'
        for: #{Java.java.io.File} static: false>
    self notYetImplemented
!

java_io_File_performSetReadOnly
    <javaNativeMethod: #'performSetReadOnly()Z'
        for: #{Java.java.io.File} static: false>
    self notYetImplemented
!

java_io_File_performListRoots
    <javaNativeMethod: #'performListRoots()[Ljava/io/File;'
        for: #{Java.java.io.File} static: true>
    self notYetImplemented
!

java_io_File_performRenameTo_java_io_File: arg1
    <javaNativeMethod: #'performRenameTo(Ljava/io/File;)Z'
        for: #{Java.java.io.File} static: false>
    self notYetImplemented
!

java_io_File_performSetLastModified_long: arg1
    <javaNativeMethod: #'performSetLastModified(J)Z'
        for: #{Java.java.io.File} static: false>
    self notYetImplemented
! !

PK
     �Mh@$e��      java_io_ObjectInputStream.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  java.io.ObjectInputStream native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.io.ObjectInputStream'!

java_io_ObjectInputStream_allocateObject_java_lang_Class: arg1
    <javaNativeMethod: #'allocateObject(Ljava/lang/Class;)Ljava/lang/Object;'
        for: #{Java.java.io.ObjectInputStream} static: false>
    ^arg1 new
!

java_io_ObjectInputStream_callConstructor_java_lang_Class: arg1 java_lang_Object: arg2
    <javaNativeMethod: #'callConstructor(Ljava/lang/Class;Ljava/lang/Object;)V'
        for: #{Java.java.io.ObjectInputStream} static: false>
    ^arg2 perform: (arg1 >> #'<init>()V')
! !

PK
     �Mh@7���p  p    gnu_java_net_PlainSocketImpl.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  gnu.java.net.PlainSocketImpl native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'gnu.java.net.PlainSocketImpl'!

gnu_java_net_PlainSocketImpl_setOption_int: arg1 java_lang_Object: arg2
    <javaNativeMethod: #'setOption(ILjava/lang/Object;)V'
        for: #{Java.gnu.java.net.PlainSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainSocketImpl_getOption_int: arg1
    <javaNativeMethod: #'getOption(I)Ljava/lang/Object;'
        for: #{Java.gnu.java.net.PlainSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainSocketImpl_shutdownInput
    <javaNativeMethod: #'shutdownInput()V'
        for: #{Java.gnu.java.net.PlainSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainSocketImpl_shutdownOutput
    <javaNativeMethod: #'shutdownOutput()V'
        for: #{Java.gnu.java.net.PlainSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainSocketImpl_create_boolean: arg1
    <javaNativeMethod: #'create(Z)V'
        for: #{Java.gnu.java.net.PlainSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainSocketImpl_connect_java_net_SocketAddress: arg1 int: arg2
    <javaNativeMethod: #'connect(Ljava/net/SocketAddress;I)V'
        for: #{Java.gnu.java.net.PlainSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainSocketImpl_bind_java_net_InetAddress: arg1 int: arg2
    <javaNativeMethod: #'bind(Ljava/net/InetAddress;I)V'
        for: #{Java.gnu.java.net.PlainSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainSocketImpl_listen_int: arg1
    <javaNativeMethod: #'listen(I)V'
        for: #{Java.gnu.java.net.PlainSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainSocketImpl_accept_gnu_java_net_PlainSocketImpl: arg1
    <javaNativeMethod: #'accept(Lgnu/java/net/PlainSocketImpl;)V'
        for: #{Java.gnu.java.net.PlainSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainSocketImpl_available
    <javaNativeMethod: #'available()I'
        for: #{Java.gnu.java.net.PlainSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainSocketImpl_close
    <javaNativeMethod: #'close()V'
        for: #{Java.gnu.java.net.PlainSocketImpl} static: false>
    self notYetImplemented
!

gnu_java_net_PlainSocketImpl_sendUrgentData_int: arg1
    <javaNativeMethod: #'sendUrgentData(I)V'
        for: #{Java.gnu.java.net.PlainSocketImpl} static: false>
    self notYetImplemented
! !
PK
     �Mh@����  �    java_lang_VMClassLoader.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.VMClassLoader native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.VMClassLoader'!

java_lang_VMClassLoader_defineClass_java_lang_ClassLoader: arg1 java_lang_String: arg2 byteArray: arg3 int: arg4 int: arg5 java_security_ProtectionDomain: arg6
    <javaNativeMethod: #'defineClass(Ljava/lang/ClassLoader;Ljava/lang/String;[BIILjava/security/ProtectionDomain;)Ljava/lang/Class;'
        for: #{Java.java.lang.VMClassLoader} static: true>
    self notYetImplemented
!

java_lang_VMClassLoader_linkClass0_java_lang_Class: arg1
    <javaNativeMethod: #'linkClass0(Ljava/lang/Class;)V'
        for: #{Java.java.lang.VMClassLoader} static: true>
    self notYetImplemented
!

java_lang_VMClassLoader_markClassErrorState0_java_lang_Class: arg1
    <javaNativeMethod: #'markClassErrorState0(Ljava/lang/Class;)V'
        for: #{Java.java.lang.VMClassLoader} static: true>
    self notYetImplemented
!

java_lang_VMClassLoader_getPrimitiveClass_char: arg1
    <javaNativeMethod: #'getPrimitiveClass(C)Ljava/lang/Class;'
        for: #{Java.java.lang.VMClassLoader} static: true>
    arg1 == $I asInteger ifTrue: [ ^IntClass ].
    arg1 == $B asInteger ifTrue: [ ^ByteClass ].
    arg1 == $S asInteger ifTrue: [ ^ShortClass ].
    arg1 == $J asInteger ifTrue: [ ^LongClass ].
    arg1 == $F asInteger ifTrue: [ ^FloatClass ].
    arg1 == $D asInteger ifTrue: [ ^DoubleClass ].
    arg1 == $V asInteger ifTrue: [ ^VoidClass ].
    arg1 == $Z asInteger ifTrue: [ ^BooleanClass ].
    arg1 == $C asInteger ifTrue: [ ^CharClass ].
    ^nil
!

java_lang_VMClassLoader_getSystemClassLoaderInternal
    <javaNativeMethod: #'getSystemClassLoaderInternal()Ljava/lang/ClassLoader;'
        for: #{Java.java.lang.VMClassLoader} static: true>
    self notYetImplemented
! !
PK
     �Mh@89mN:  :    java_lang_String.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.String native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.String'!

convertJavaString
    <javaNativeMethod: #asString for: #{Java.java.lang.String} static: false>
    (self boffset = 0 and: [ self count = self data size ])
	ifTrue: [ ^self data ].

    ^self data copyFrom: self boffset + 1 to: self boffset + self count!

java_lang_String_charAt_int: arg1
    <javaNativeMethod: #'charAt(I)C'
        for: #{Java.java.lang.String} static: false>
    arg1 < 0 ifTrue: [
	^JavaVM stringIndexOutOfBounds: self index: arg1 ].
    arg1 >= self count ifTrue: [
	^JavaVM stringIndexOutOfBounds: self index: arg1 ].
    ^(self data at: arg1 + self boffset + 1) value
!

java_lang_String_getChars_int: arg1 int: arg2 charArray: arg3 int: arg4
    | ofs |
    <javaNativeMethod: #'getChars(II[CI)V'
        for: #{Java.java.lang.String} static: false>

    arg1 < 0 ifTrue: [
	^JavaVM stringIndexOutOfBounds: self index: arg1 ].
    arg1 >= self count ifTrue: [
	^JavaVM stringIndexOutOfBounds: self index: arg1 ].
    arg4 + (arg2 - arg1) > arg3 size ifTrue: [
	^JavaVM arrayIndexOutOfBounds: self index: arg3 size + 1 ].

    ofs := arg1 - arg4 + self boffset.
    arg4 + 1 to: arg4 + (arg2 - arg1) do: [ :destIndex |
    	arg3 at: destIndex put: (self data at: destIndex + ofs) value ].
!

java_lang_String_getBytes_int: arg1 int: arg2 byteArray: arg3 int: arg4
    <javaNativeMethod: #'getBytes(II[BI)V'
        for: #{Java.java.lang.String} static: false>

    arg1 < 0 ifTrue: [
	^JavaVM stringIndexOutOfBounds: self index: arg1 ].
    arg1 >= self count ifTrue: [
	^JavaVM stringIndexOutOfBounds: self index: arg1 ].
    arg4 + (arg2 - arg1) > arg3 size ifTrue: [
	^JavaVM arrayIndexOutOfBounds: self index: arg3 size + 1 ].

    arg3
	replaceFrom: arg4 + 1
	to: arg4 + (arg2 - arg1)
	with: self data
	startingAt: arg1 + 1.
!

java_lang_String_getBytes_java_lang_String: arg1
    <javaNativeMethod: #'getBytes(Ljava/lang/String;)[B'
        for: #{Java.java.lang.String} static: false>

    ^(ByteArray new: self count)
	replaceFrom: 1 to: self count
	with: self data
	startingAt: self boffset + 1;

	yourself
!

java_lang_String_equals_java_lang_Object: arg1
    | left thisOfs thatOfs |
    <javaNativeMethod: #'equals(Ljava/lang/Object;)Z'
        for: #{Java.java.lang.String} static: false>
    self class = arg1 class ifFalse: [ ^0 ].
    self count = arg1 count ifFalse: [ ^0 ].
    self count = 0 ifTrue: [ ^1 ].
    left := self count.
    thisOfs := self boffset.
    thatOfs := arg1 boffset.
    [
	(self data at: thisOfs + left) = (arg1 data at: thatOfs + left)
	    ifFalse: [ ^0 ].

        (left := left - 1) = 0 ] whileFalse.

    ^1
!

java_lang_String_contentEquals_java_lang_StringBuffer: arg1
    <javaNativeMethod: #'contentEquals(Ljava/lang/StringBuffer;)Z'
        for: #{Java.java.lang.String} static: false>
    self notYetImplemented
!

java_lang_String_equalsIgnoreCase_java_lang_String: arg1
    | left thisOfs thatOfs |
    <javaNativeMethod: #'equalsIgnoreCase(Ljava/lang/String;)Z'
        for: #{Java.java.lang.String} static: false>

    self class = arg1 class ifFalse: [ ^0 ].
    self count = arg1 count ifFalse: [ ^0 ].
    self count = 0 ifTrue: [ ^1 ].
    left := self count.
    thisOfs := self boffset.
    thatOfs := arg1 boffset.
    [
	(self data at: thisOfs + left) asLowercase
	    = (arg1 data at: thatOfs + left) asLowercase
	        ifFalse: [ ^0 ].

        (left := left - 1) = 0 ] whileFalse.

    ^1
!

java_lang_String_compareTo_java_lang_String: arg1
    | left thisOfs thatOfs delta |
    <javaNativeMethod: #'compareTo(Ljava/lang/String;)I'
        for: #{Java.java.lang.String} static: false>

    self count < arg1 count
	ifTrue: [
	    (left := self count) = 0 ifTrue: [ ^0 - arg1 count ] ]
	ifFalse: [
	    (left := arg1 count) = 0 ifTrue: [ ^self count ] ].
	    
    thisOfs := self boffset.
    thatOfs := arg1 boffset.
    [
	delta := (self data at: thisOfs + left)-(arg1 data at: thatOfs + left).
	delta = 0 ifFalse: [ ^delta ].

        (left := left - 1) = 0 ] whileFalse.

    ^self count - arg1 count
!

java_lang_String_regionMatches_int: arg1 java_lang_String: arg2 int: arg3 int: arg4
    | ofs left thisOfs thatOfs |
    <javaNativeMethod: #'regionMatches(ILjava/lang/String;II)Z'
        for: #{Java.java.lang.String} static: false>

    arg1 < 0 ifTrue: [ ^0 ].
    arg3 < 0 ifTrue: [ ^0 ].
    arg4 < 0 ifTrue: [ ^0 ].
    arg4 >= self count - arg1 ifTrue: [ ^0 ].
    arg4 >= arg2 count - arg3 ifTrue: [ ^0 ].

    left := arg4.
    thisOfs := self boffset + arg1.
    thatOfs := arg2 boffset + arg3.
    [
	(self data at: thisOfs + left) = (arg1 data at: thatOfs + left)
	    ifFalse: [ ^0 ].

        (left := left - 1) = 0 ] whileFalse.

    ^1
!

java_lang_String_regionMatches_boolean: arg1 int: arg2 java_lang_String: arg3 int: arg4 int: arg5
    | ofs left thisOfs thatOfs |
    <javaNativeMethod: #'regionMatches(ZILjava/lang/String;II)Z'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0 ifTrue: [ ^0 ].
    arg4 < 0 ifTrue: [ ^0 ].
    arg5 < 0 ifTrue: [ ^0 ].
    arg5 >= self count - arg2 ifTrue: [ ^0 ].
    arg5 >= arg3 count - arg4 ifTrue: [ ^0 ].

    left := arg5.
    thisOfs := self boffset + arg2.
    thatOfs := arg3 boffset + arg4.
    arg1 = 0
	ifTrue: [
	    [
		(self data at: thisOfs + left) = (arg1 data at: thatOfs + left)
		    ifFalse: [ ^0 ].

        	(left := left - 1) = 0 ] whileFalse ]
	ifFalse: [
	    [
		(self data at: thisOfs + left) asLowercase
		    = (arg1 data at: thatOfs + left) asLowercase
		    ifFalse: [ ^0 ].

        	(left := left - 1) = 0 ] whileFalse ].

    ^1
!

java_lang_String_startsWith_java_lang_String: arg1 int: arg2
    | ofs left result |
    <javaNativeMethod: #'startsWith(Ljava/lang/String;I)Z'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0 ifTrue: [ ^0 ].
    arg1 count >= self count - arg2 ifTrue: [ ^0 ].
    ofs := (self boffset + arg2) - arg1 boffset.
    self boffset + arg2 + 1 to: self boffset + arg1 count do: [ :index |
	(self data at: index) = (arg1 data at: index + ofs) ifFalse: [^0] ].

    ^1
!

java_lang_String_hashCode
    | hash |
    <javaNativeMethod: #'hashCode()I'
        for: #{Java.java.lang.String} static: false>

    (hash := self cachedHashCode) = 0
	ifTrue: [
	    self boffset + 1 to: self boffset + self count do: [ :index |
		"Complicated way to multiply hash by 31 and reasonably
		 try to avoid LargeIntegers..."
		hash := ((hash bitAnd: 16r7FFFFFF)
			    bitShift: 5) - hash + (self data at: index) value.
	    ].
	    self cachedHashCode: hash ].

    ^hash 
!

java_lang_String_indexOf_int: arg1 int: arg2
    | ch |
    <javaNativeMethod: #'indexOf(II)I'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0 ifTrue: [ ^-1 ].
    arg2 >= self count ifTrue: [ ^-1 ].
    ch := arg1 asCharacter.
    self boffset + arg2 + 1 to: self boffset + self count do:
	[ :index |
	    (self data at: index) = ch ifTrue: [ ^index - self boffset - 1 ] ].

    ^-1
!

java_lang_String_lastIndexOf_int: arg1 int: arg2
    | ch |
    <javaNativeMethod: #'lastIndexOf(II)I'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0 ifTrue: [ ^-1 ].
    arg2 >= self count ifTrue: [ ^-1 ].
    ch := arg1 asCharacter.
    self boffset + self count to: self boffset + arg2 + 1 by: -1 do:
	[ :index |
	    (self data at: index) = ch ifTrue: [ ^index - self boffset - 1 ] ].

    ^-1
!

java_lang_String_indexOf_java_lang_String: arg1 int: arg2

    | firstCh ofs left result |
    <javaNativeMethod: #'indexOf(Ljava/lang/String;I)I'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0 ifTrue: [ ^-1 ].
    arg2 >= self count ifTrue: [ ^-1 ].
    arg1 count = 0 ifTrue: [ ^arg2 ].

    ofs := arg1 boffset + 1.
    firstCh := arg1 data at: ofs.
    self boffset + arg2 + 1 to: self boffset + self count - (arg1 count - 1) do:
	[ :first |
	    (self data at: first) = firstCh ifTrue: [
		left := arg1 count.
		[
		    (left := left - 1) = 0 ifTrue: [ ^first - self boffset - 1 ].
		    (self data at: first + left) = (arg1 data at: ofs + left)
		] whileTrue.
	    ]
	].

    ^-1
!

java_lang_String_substring_int: arg1 int: arg2
    <javaNativeMethod: #'substring(II)Ljava/lang/String;'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0
	ifTrue: [ ^JavaVM stringIndexOutOfBounds: self index: arg2 ].
    arg2 >= self count
	ifTrue: [ ^JavaVM stringIndexOutOfBounds: self index: arg2 ].

    ^Java.java.lang.String new
	perform: #'<init>([CIIZ)V'
	with: self data
	with: self boffset + arg1
	with: (arg2 - arg1 min: self count)
	with: true
!

java_lang_String_concat_java_lang_String: arg1

    | result |
    <javaNativeMethod: #'concat(Ljava/lang/String;)Ljava/lang/String;'
        for: #{Java.java.lang.String} static: false>

    result := String new: self count + arg1 count.
    result
	replaceFrom: 1 to: self count
	with: self data
	startingAt: self boffset + 1.

    result
	replaceFrom: self count + 1 to: self size
	with: arg1 data
	startingAt: arg1 boffset + 1.

    ^Java.java.lang.String new
	perform: #'<init>([CIIZ)V'
	with: result
	with: 0
	with: result size
	with: true
!

java_lang_String_replace_char: arg1 char: arg2
    <javaNativeMethod: #'replace(CC)Ljava/lang/String;'
        for: #{Java.java.lang.String} static: false>

    ^Java.java.lang.String new
	perform: #'<init>([CIIZ)V'
	with: (self data
		  copyReplacing: arg1 asCharacter
		  withObject: arg2 asCharacter)
	with: self boffset
        with: self count
	with: true
!

java_lang_String_toLowerCase_java_util_Locale: arg1
    <javaNativeMethod: #'toLowerCase(Ljava/util/Locale;)Ljava/lang/String;'
        for: #{Java.java.lang.String} static: false>

    ^Java.java.lang.String new
	perform: #'<init>([CIIZ)V'
	with: self data asLowercase
	with: self boffset
        with: self count
	with: true
!

java_lang_String_toUpperCase_java_util_Locale: arg1
    <javaNativeMethod: #'toUpperCase(Ljava/util/Locale;)Ljava/lang/String;'
        for: #{Java.java.lang.String} static: false>

    ^Java.java.lang.String new
	perform: #'<init>([CIIZ)V'
	with: self data asUppercase
	with: self boffset
        with: self count
	with: true
!

java_lang_String_trim
    <javaNativeMethod: #'trim()Ljava/lang/String;'
        for: #{Java.java.lang.String} static: false>

    1 to: self size do: [ :first |
	(self data at: first) isSeparator ifFalse: [
	    self size to: first by: -1 do: [ :last |
		(self data at: last) isSeparator ifFalse: [
		    ^Java.java.lang.String new
			perform: #'<init>([CIIZ)V'
			with: self data
			with: first - 1
			with: last - first + 1
			with: true ]]]].

    ^Java.java.lang.String new
	perform: #'<init>()V'
!

java_lang_String_toCharArray
    <javaNativeMethod: #'toCharArray()[C'
        for: #{Java.java.lang.String} static: false>

    ^(ByteArray new: self count)
        replaceFrom: 1 to: self count
	with: self data
	startingAt: self boffset + 1;

	asArray
!

java_lang_String_valueOf_charArray: arg1 int: arg2 int: arg3
    <javaNativeMethod: #'valueOf([CII)Ljava/lang/String;'
        for: #{Java.java.lang.String} static: true>

    ^Java.java.lang.String new
	perform: #'<init>([CII)V'
	with: arg1
	with: arg2
	with: arg3
!

java_lang_String_valueOf_char: arg1
    <javaNativeMethod: #'valueOf(C)Ljava/lang/String;'
        for: #{Java.java.lang.String} static: true>

    ^Java.java.lang.String new
	perform: #'<init>([C)V'
	with: { arg1 }
!

java_lang_String_valueOf_int: arg1
    <javaNativeMethod: #'valueOf(I)Ljava/lang/String;'
        for: #{Java.java.lang.String} static: true>

    ^Java.java.lang.String new
	perform: #'<init>([C)V'
	with: arg1 printString
!

java_lang_String_intern
    <javaNativeMethod: #'intern()Ljava/lang/String;'
        for: #{Java.java.lang.String} static: false>
    self notYetImplemented
!

java_lang_String_init_charArray: arg1 int: arg2 int: arg3 boolean: arg4
    <javaNativeMethod: #'init([CIIZ)V'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0
	ifTrue: [ ^JavaVM arrayIndexOutOfBounds: self index: arg2 ].
    arg2 + arg3 > arg1 size
	ifTrue: [ ^JavaVM arrayIndexOutOfBounds: self index: arg2 ].

    arg1 isString
	ifTrue: [
	    self data: arg1.
	    self boffset: arg2.
	    arg4 = 0 ifTrue: [ self data: self data copy ] ]
	ifFalse: [
	    self data: (String new: arg3).
	    self boffset: 0.
	    1 to: arg3 do: [ :i |
		self data at: i put: (arg1 at: arg2 + i) asCharacter ] ].

    self count: arg3.
!

java_lang_String_init_byteArray: arg1 int: arg2 int: arg3 int: arg4
    <javaNativeMethod: #'init([BIII)V'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0
	ifTrue: [ ^JavaVM arrayIndexOutOfBounds: self index: arg2 ].
    arg2 + arg3 > arg1 size
	ifTrue: [ ^JavaVM arrayIndexOutOfBounds: self index: arg2 ].

    self data: arg1 asString.
    self boffset: arg2.
    self count: arg3.
!

java_lang_String_init_byteArray: arg1 int: arg2 int: arg3 java_lang_String: arg4
    <javaNativeMethod: #'init([BIILjava/lang/String;)V'
        for: #{Java.java.lang.String} static: false>

    arg2 < 0
	ifTrue: [ ^JavaVM arrayIndexOutOfBounds: self index: arg2 ].
    arg2 + arg3 > arg1 size
	ifTrue: [ ^JavaVM arrayIndexOutOfBounds: self index: arg2 ].

    self data: arg1 asString.
    self boffset: arg2.
    self count: arg3.
!

java_lang_String_init_gnu_gcj_runtime_StringBuffer: arg1
    <javaNativeMethod: #'init(Lgnu/gcj/runtime/StringBuffer;)V'
        for: #{Java.java.lang.String} static: false>
    self notYetImplemented
!

java_lang_String_rehash
    <javaNativeMethod: #'rehash()V'
        for: #{Java.java.lang.String} static: true>
! !

PK
     �Mh@W��[  [    java_lang_StringBuffer.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.StringBuffer native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.StringBuffer'!

java_lang_StringBuffer_append_int: arg1
    | s newValue needed |
    <javaNativeMethod: #'append(I)Ljava/lang/StringBuffer;'
        for: #{Java.java.lang.StringBuffer} static: false>
    s := arg1 printString asByteArray.

    needed := self count + s size.
    self value size < needed ifTrue: [
        newValue := self value copyEmpty: (needed max: self value size * 2 + 2).
        newValue replaceFrom: 1 to: self count with: self value startingAt: 1.
	self value: newValue.
    ].
    self value replaceFrom: self count + 1 to: needed with: s startingAt: 1.
    self count: needed.
    ^self
!

java_lang_StringBuffer_regionMatches_int: arg1 java_lang_String: arg2
    <javaNativeMethod: #'regionMatches(ILjava/lang/String;)Z'
        for: #{Java.java.lang.StringBuffer} static: false>
    self notYetImplemented
! !

PK
     �Mh@���R�  �    java_util_ResourceBundle.stUT	 dqXOe�XOux �  �  "======================================================================
|
|   Java run-time support.  java.util.ResourceBundle native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.util.ResourceBundle'!

java_util_ResourceBundle_getCallingClassLoader
    <javaNativeMethod: #'getCallingClassLoader()Ljava/lang/ClassLoader;'
        for: #{Java.java.util.ResourceBundle} static: true>
    self notYetImplemented
! !
PK
     �Mh@�k�O      gnu_java_nio_SelectorImpl.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  gnu.java.nio.SelectorImpl native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'gnu.java.nio.SelectorImpl'!

gnu_java_nio_SelectorImpl_implSelect_intArray: arg1 intArray: arg2 intArray: arg3 long: arg4
    <javaNativeMethod: #'implSelect([I[I[IJ)I'
        for: #{Java.gnu.java.nio.SelectorImpl} static: true>
    self notYetImplemented
! !
PK
     �Mh@���  �    java_io_FileDescriptor.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  java.io.FileDescriptor native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.io.FileDescriptor'!

convertToSmalltalkFD
    <javaNativeMethod: #asFileDescriptor
        for: #{Java.java.io.FileDescriptor} static: false>
    ^JavaVM fileDescriptorFor: self fd!

java_io_FileDescriptor_init
    <javaNativeMethod: #'init()V'
        for: #{Java.java.io.FileDescriptor} static: true>
    self in: self new.
    self in perform: #'<init>(I)V' with: 0.
    self out: self new.
    self out perform: #'<init>(I)V' with: 1.
    self err: self new.
    self err perform: #'<init>(I)V' with: 2.
!

java_io_FileDescriptor_sync
    <javaNativeMethod: #'sync()V'
        for: #{Java.java.io.FileDescriptor} static: false>
    "TODO: use fsync ..."
!

java_io_FileDescriptor_valid
    <javaNativeMethod: #'valid()Z'
        for: #{Java.java.io.FileDescriptor} static: false>
    ^self fd >= 0 "TODO: check with fstat ..."
!

java_io_FileDescriptor_open_java_lang_String: arg1 int: arg2
    | mode |
    <javaNativeMethod: #'open(Ljava/lang/String;I)I'
        for: #{Java.java.io.FileDescriptor} static: false>
    mode := #('w' 'r' 'w' 'w+' 'a' 'a+' 'a' 'a+')
        at: arg2 \\ 8 + 1.

    ^JavaFileDescriptor fopen: arg1 mode: mode ifFail: [
        | exception msg errno |
        errno := File errno.
        errno < 1 ifTrue: [ ^0 ].
        msg := (self stringError: errno) asJavaString.
        exception := Java.java.io.FileNotFoundException new.
        exception perform: #'<init>(Ljava/lang/String;)V' with: msg.
        exception throw ]
!

java_io_FileDescriptor_write_int: arg1
    <javaNativeMethod: #'write(I)V'
        for: #{Java.java.io.FileDescriptor} static: false>
    ^self asFileDescriptor
	write: (ByteArray with: arg1) from: 1 to: 1
!

java_io_FileDescriptor_write_byteArray: arg1 int: arg2 int: arg3
    | array |
    <javaNativeMethod: #'write([BII)V'
        for: #{Java.java.io.FileDescriptor} static: false>
    array := ByteArray new: arg3.
    array replaceFrom: 1 to: arg3 with: arg1 startingAt: arg2 + 1.
    ^self asFileDescriptor write: array from: 1 to: arg3
!

java_io_FileDescriptor_close
    <javaNativeMethod: #'close()V'
        for: #{Java.java.io.FileDescriptor} static: false>
    self asFileDescriptor close
!

java_io_FileDescriptor_setLength_long: arg1
    | delta fd position |
    <javaNativeMethod: #'setLength(J)V'
        for: #{Java.java.io.FileDescriptor} static: false>
    fd := self asFileDescriptor.
    delta := fd size - arg1.
    delta = 0 ifTrue: [ ^self ].
    delta < 0 ifTrue: [ fd position: arg1; truncate. ^self ].

    "If the file is too short, we extend it.  We can't rely on
     ftruncate() extending the file.  So we lseek() to 1 byte less
     than we want, and then we write a single byte at the end."
    position := fd position.
    fd position: arg1 - 1.
    fd write: #[0].
    fd position: position
!

java_io_FileDescriptor_seek_long: arg1 int: arg2 boolean: arg3
    | pos fd |
    <javaNativeMethod: #'seek(JIZ)I'
        for: #{Java.java.io.FileDescriptor} static: false>
    fd := self asFileDescriptor.
    pos := arg1.
    arg2 = 0 ifFalse: [ pos := pos + fd position ].
    arg3 = 1 ifTrue: [ pos := pos min: fd size  ].
    fd position: pos.
    ^pos
!

java_io_FileDescriptor_getLength
    <javaNativeMethod: #'getLength()J'
        for: #{Java.java.io.FileDescriptor} static: false>
    ^self asFileDescriptor size
!

java_io_FileDescriptor_getFilePointer
    <javaNativeMethod: #'getFilePointer()J'
        for: #{Java.java.io.FileDescriptor} static: false>
    ^self asFileDescriptor position
!

java_io_FileDescriptor_read
    <javaNativeMethod: #'read()I'
        for: #{Java.java.io.FileDescriptor} static: false>
    ^self asFileDescriptor next value
!

java_io_FileDescriptor_read_byteArray: arg1 int: arg2 int: arg3
    | array count |
    <javaNativeMethod: #'read([BII)I'
        for: #{Java.java.io.FileDescriptor} static: false>
    array := ByteArray new: arg3.
    count := self asFileDescriptor read: array from: 1 to: arg3.
    arg1 replaceFrom: arg1 + 1 to: arg1 + count with: array startingAt: 1.
    ^count
!

java_io_FileDescriptor_available
    <javaNativeMethod: #'available()I'
        for: #{Java.java.io.FileDescriptor} static: false>
    ^self asFileDescriptor canRead
	ifTrue: [ 1 ]
	ifFalse: [ 0 ]
! !

PK
     �Mh@*h�Y~p ~p   JavaTranslation.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java to Smalltalk bytecode translator
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003, 2006 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"

LookupTable variableSubclass: #LiteralTable
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

LiteralTable comment: '
This class is like a LookupTable, but objects that are of different classes
are never merged together even if they are equal.'!

Object subclass: #JavaMethodTranslator
    instanceVariableNames: 'javaMethod localMap basicBlocks literals numTemps
	currentEntryBasicBlock pcToBasicBlockMap compiledMethod exceptionTemp'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaMethodTranslator comment: '
JavaMethodTranslator keeps together the pieces (basic blocks) of a
method that is being compiled.

Instance Variables:
    basicBlocks	<(Collection of: JavaBasicBlock)>
	collection of basic blocks that make up this method.
    currentEntryBasicBlock <JavaEntryBasicBlock>
	the entry point from which we started translating the current batch of basic block
    javaMethod	<JavaClassElement>
	the JavaMethod which is being translated
    compiledMethod	<JavaCompiledMethod>
	the translated method
    literals	<Dictionary>
	literals that are part of the current method
    localMap	<(SequenceableCollection of: Integer)>
	the map from Java local variable slots to Smalltalk temporary variable slots (except for self)
    numTemps	<Integer>
	number of temporaries currently allocated
    pcToBasicBlockMap	<Object>
	an array which associates each program counter value with a basic block that starts there
'!


JavaInstructionInterpreter subclass: #JavaUntypedInterpreter
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaUntypedInterpreter comment: '
JavaUntypedInterpreter is similar to JavaInstructionInterpreter, but
the typed Java instructions are converted to similar yet untyped
instructions.  The size of the argument (2 for doubles and longs, 1
for the rest) is passed, but it can be discarded by subclasses that
are not interested at all in the types (those that manipulate the
stack, are).  '!


JavaUntypedInterpreter subclass: #JavaEdgeCreator
    instanceVariableNames: 'basicBlocks pcToBasicBlockMap currentBasicBlock '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaEdgeCreator comment: '
JavaEdgeCreator reads again the last instruction in each basic block
in order to create the control-flow graph edges between the blocks.

Instance Variables:
    basicBlocks	<(Collection of: JavaBasicBlock)>
	an ordered collection of basic blocks
    currentBasicBlock	<JavaBasicBlock>
	the current basic block
    pcToBasicBlockMap	<Object>
	an array which associates each program counter value with a basic block that starts there

'!


JavaUntypedInterpreter subclass: #JavaBytecodeTranslator
    instanceVariableNames: 'stack spills destination javaMethod minimumStackDepth '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaBytecodeTranslator comment: '
JavaBytecodeTranslator does the translation from Java to Smalltalk
bytecodes.  It symbolically executes bytecodes, creating a stack of
JavaProgramNodes.  The actual emission of the code for the node is
delayed until: a pop or pop2 bytecode ends the current statement; a
dup* bytecode forces the code to be executed so that the result can be
saved in a temporary and repushed; the current basic block ends, in
which case the translator ensures that the (Smalltalk) stack items are
spilled to temporaries and the stack is emptied.  (Non-empty stacks
are the result of the ?: ternary operator).

A single instance of this class is reused for all the basic block in a
method/exception handler/subroutine, so that the same Smalltalk
temporary will be used every time a particular stack slot is spilled,
and also every time the spill has to be restored back on the stack.

Instance Variables:
    destination	<JavaBasicBlock>
	the basic block which is being translated.
    javaMethod	<JavaMethod>
	the method which is being translated.
    minimumStackDepth	<Integer>
	the index of the lowest slot in the stack that is written to
	by the basic block
    spills	<(Array of: JavaSpillNode)>
	an Array holding the nodes used to spill the various stack
	slots.  As noted above, the same node is reused every time a
	particular stack slot is spilled or pushed back on the stack.
    stack	<(OrderedCollection of: JavaProgramNode)>
	the stack for symbolic execution.

'!


Array variableSubclass: #JavaTranslatedExceptionHandlerTable
    instanceVariableNames: 'exceptionTemp'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaTranslatedExceptionHandlerTable comment: '
JavaTranslatedExceptionHandlerTable is the table of exception handlers
in a translated Java method.  It is a different class from Array so
that we can plug it in the #exceptionHandlerSearch:reset: pragma and
define a #value:value:value: method to search in the table.'!

Object subclass: #JavaBasicBlock
    instanceVariableNames: 'startpc length translatedpc translationSize bytecodes methodTranslator outEdge knownPcValues '
    classVariableNames: 'SpecialSelectorMap'
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaBasicBlock comment: '
JavaBasicBlock represents an interval of bytecodes in a Java method
that can only have a single entry and a single exit.

Instance Variables:
    bytecodes	<Stream>
	the Smalltalk bytecodes corresponding to the basic block
    methodTranslator	<JavaMethodTranslator>
	the object that coordinates the translation of the various basic block
    length	<Integer>
	the number of Java bytecodes in this basic block
    outEdge	<JavaEdge>
	an object describing what happens at the end of the basic block
    startpc	<Integer>
	the first Java bytecode in the basic block
    translatedpc	<Integer>
	the first Smalltalk bytecode in the basic block
    translationSize	<Object>
	the number of Smalltalk bytecodes in the basic block, not counting the translation of outEdge
    knownPcValues	<(Array of: Integer)>
	same as above, but also includes the places where a line number starts.
'!


JavaUntypedInterpreter subclass: #JavaBytecodeAnalyzer
    instanceVariableNames: 'javaMethod basicBlocks usedLocals pcToBasicBlockMap nextStartsBasicBlock currentBasicBlock knownBasicBlockStarts knownPcValues '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaBytecodeAnalyzer comment: '
JavaBytecodeAnalyzer splits the Java source code into basic blocks,
then uses a JavaEdgeCreator to connect them.  It also finds out which
local variable slots are never referenced directly (because they are
the second part of a double or a long), and uses this information to
compute a map from Java local variable slots to Smalltalk temporary
variable slots.

Instance Variables:
    basicBlocks	<OrderedCollection>
	an ordered collection of basic blocks
    currentBasicBlock	<JavaBasicBlock>
	the current basic block
    javaMethod	<JavaMethod>
	the JavaMethod which we are analyzing
    knownBasicBlockStarts	<(SortedCollection of: Integer)>
	the pc values at which we know that a basic block starts
    knownPcValues	<(SortedCollection of: Integer)>
	same as above, but also includes the places where a line number starts.
    nextStartsBasicBlock	<Boolean>
	set when a bytecode is found that ends a basic block, to limit operation on knownBasicBlockStarts
    pcToBasicBlockMap	<(Array of: JavaBasicBlock)>
	an array which associates each program counter value with a basic block that starts there
    usedLocals	<ByteArray>
	holds a 1 if a local variable slot is used, 0 if it is not used.

'!


Object subclass: #JavaProgramNode
    instanceVariableNames: 'wordSize '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaProgramNode comment: '
JavaProgramNode is the abstract superclass for nodes of the bytecode
translator''s IR.  The IR is necessary because invokestatic bytecodes
don''t push the receiver (if it were not for them, it would be
possible to do a simple one-bytecode-at-a-time translation!).

Instance Variables:
    wordSize	<Integer>
	1 or 2, depending on how many stack slots the item takes in Java''s stack.

'!


JavaProgramNode subclass: #JavaConstantNode
    instanceVariableNames: 'object '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaConstantNode comment: '
JavaConstantNode is the IR node for pushing a constant object.

Instance Variables:
    object	<Object>
	the literal object being pushed

'!


JavaProgramNode subclass: #JavaLocalNode
    instanceVariableNames: 'id '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaLocalNode comment: '
JavaLocalNode is the IR node for pushing a Java local variable.

Instance Variables:
    id	<Integer>
	Java local variable slot'!


JavaLocalNode subclass: #JavaSpillNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaSpillNode comment: '
JavaSpillNode is the IR node for pushing back a Java stack slot that
has been spilled to a Smalltalk temporary variable.  It is a separate
class, a) to easily avoid pushing them and spill them back, and b) in
order to distinguish invokenonvirtual bytecodes which are sends to
super (to the JavaLocalNode for `this''), from those that are sends to
constructors (to the dup''ed result of an instance creation bytecode,
which is a JavaSpillNode).

Instance Variables:
    id	<Integer>
	Smalltalk temporary variable slot'!


JavaProgramNode variableSubclass: #JavaArrayNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaArrayNode comment: '
JavaArrayNode creates an array at run time, similar to the Smalltalk
construction { 1. 2. a. b }.  It is used when multidimensional arrays
are created, as the argument that is passed to the run-time routine
that creates the array.

Indexed instance variables hold JavaProgramNodes for the items of the array.'!


JavaProgramNode variableSubclass: #JavaMessageSendNode
    instanceVariableNames: 'selector '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaMessageSendNode comment: '
JavaMessageSendNode is the IR node for doing a Smalltalk message send.
As Smalltalk programs are almost exclusively made of message sends,
this also implements bytecodes such as monitorenter, or checkcast.
The only message sends that do not pass through a JavaMessageSendNode
are those created by JavaConditionalEdges (that is, by if* bytecodes)
and those created by JavaThrowExceptionEdges (by athrow bytecodes).

Instance Variables:
    selector	<Object>
	description of selector

Indexed instance variables hold JavaProgramNodes for the receiver and arguments of the message send.
'!


JavaMessageSendNode variableSubclass: #JavaSuperMessageSendNode
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaSuperMessageSendNode comment: '
JavaSuperMessageSendNode is the IR node for doing a message send to
super.  '!


JavaBasicBlock subclass: #JavaEntryBasicBlock
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaEntryBasicBlock comment: '
JavaEntryBasicBlock is a special class for basic blocks that are
entry-points of the method, its exception handlers, or its
subroutines.  They are useful to associate jsr instructions with try
and catch blocks (respectively, JavaEntryBasicBlock and
JavaExceptionHandlerBasicBlock -- no need to create a subclass), and to
associate ret instruction with the subroutine they belong to
(represented by a JavaSubroutineEntryBasicBlock).

The reference to the current JavaEntryBasicBlock is maintained by the
JavaMethodTranslator that coordinates the compilation of edges.'!


JavaEntryBasicBlock subclass: #JavaExceptionHandlerBasicBlock
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaExceptionHandlerBasicBlock comment: '
JavaExceptionHandlerBasicBlock provides a single method that
automatically retrieves a one-word item from a special temporary
and puts it on the stack.'!


JavaExceptionHandlerBasicBlock subclass: #JavaFinallyHandlerBasicBlock
    instanceVariableNames: 'exceptionLocal '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaFinallyHandlerBasicBlock comment: '
JavaFinallyHandlerBasicBlock represents the block that implements the
implicit exception handler added when a try block has a corresponding
finally.  It assumes that the exception is stored on the stack at the
start of the basic-block, and remembers the local that it was stored
into so that the emulation of jsr can push it back.

Instance Variables:
    exceptionLocal	<Integer>
	the local variable slot in which the exception is stored

'!


JavaEntryBasicBlock subclass: #JavaSubroutineEntryBasicBlock
    instanceVariableNames: 'returnPoint '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaSubroutineEntryBasicBlock comment: '
JavaSubroutineEntryBasicBlock represents the entry point of a
subroutine.  When a JavaJumpToFinallyEdge that lives out of an
exception handler is translated, it also stores where to return from.

Note that our translation scheme is wrong if there are two or more
non-exception paths to a finally handlers, which can happen in
the presence of multilevel break or continue statements.

Instance Variables:
    returnPoint	<JavaBasicBlock>
	description of returnPoint
'!


Object subclass: #JavaEdge
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaEdge comment: '
JavaEdge represents the edges out of a JavaBasicBlock in a method''s
control-flow graph.

Subclasses must implement the following messages:
    cfg iteration
	successorsDo:

'!


JavaEdge subclass: #JavaGotoEdge
    instanceVariableNames: 'successor '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaGotoEdge comment: '
JavaGotoEdge represents a single edge going out of a JavaBasicBlock in
a method''s control-flow-graph.

Instance Variables:
    successor	<JavaBasicBlock>
	description of successor

'!


JavaGotoEdge subclass: #JavaFallThroughEdge
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaFallThroughEdge comment: '
JavaFallThroughEdge represents a single edge going out of a
JavaBasicBlock in a method''s control-flow-graph.  This edge is added
when there are exception handlers and try-catch blocks, because every
statement in the try-catch block can have more than one successor and
so needs to be treated specially.  '!


JavaGotoEdge subclass: #JavaJumpToFinallyEdge
    instanceVariableNames: 'entryBlock returnPoint '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaJumpToFinallyEdge comment: '
JavaJumpToFinallyEdge represents an edge that jumps to a subroutine.
The subroutine executes the finally block of an exception handler.

Subroutines are emulated in the bytecodes: an exception or nil is
pushed, and a normal jump is executed.  Then, the ret bytecode is
translated by checking if an exception was pushed and if so,
rethrowing it.  Otherwise, we jump back to after the try block.

The successor instance variable of JumpToFinallyEdge points to the
subroutine (a JavaSubroutineEntryBasicBlock), while the returnPoint
instance variable points back to the main flow of execution.  During
the translation of JavaJumpToFinallyEdges that are not coming from an
exception handler, the returnPoint is propagated to the
JavaSubroutineEntryBasicBlock, and from there it will be fetched by
the JavaSubroutineReturnEdge.

Instance Variables:
    entryBlock	<JavaEntryBasicBlock>
	the entry point of the sequence of basic blocks which includes this edge
    returnPoint	<JavaBasicBlock | JavaExceptionHandler | JavaLocalVariable>
	description of returnPoint

'!


JavaEdge subclass: #JavaReturnEdge
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaReturnEdge class instanceVariableNames: 'soleInstance '!

JavaReturnEdge comment: '
JavaReturnEdges are attached to JavaBasicBlocks when they return a
value to the caller.

JavaReturnEdge is a Singleton.'!


JavaReturnEdge subclass: #JavaThrowExceptionEdge
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaThrowExceptionEdge comment: '
JavaThrowExceptionEdge are attached to JavaBasicBlocks when they end
by throwing an exception.

JavaThrowExceptionEdge is a Singleton.'!


JavaEdge subclass: #JavaSwitchStatementEdge
    instanceVariableNames: 'currentLabel jumpTargets basicBlocks defaultSuccessor '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaSwitchStatementEdge comment: '
JavaSwitchStatementReturnEdges are attached to JavaBasicBlocks that
end with a switch bytecode (tableswitch or lookupswitch).  It includes
code to translated them to a binary search.

Subclasses must implement the following messages:
    accessing
	values

Instance Variables:
    basicBlocks	<SequenceableCollection>
	collection of basic blocks to which the switch statement jumps. basicBlocks size = self values size
    defaultSuccessor	<JavaBasicBlock>
	basic block for the ''default:'' part of the switch statement
    currentLabel	<Integer>
	description of currentLabel
    jumpTargets	<(OrderedCollection of: Integer)>
	description of jumpTargets
'!


JavaSwitchStatementEdge subclass: #JavaTableSwitchStatementEdge
    instanceVariableNames: 'low high '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaTableSwitchStatementEdge comment: '
JavaLookupSwitchStatementReturnEdges are attached to JavaBasicBlocks
that end with a lookupswitch bytecode.

Instance Variables:
    low	<Integer>
	value of the lowest ''case'' label in the switch statement
'!


JavaSwitchStatementEdge subclass: #JavaLookupSwitchStatementEdge
    instanceVariableNames: 'values '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaLookupSwitchStatementEdge comment: '
JavaLookupSwitchStatementReturnEdges are attached to JavaBasicBlocks
that end with a lookupswitch bytecode.

Instance Variables:
    values	<Array>
	values for the ''case'' labels in the switch statement.

'!


JavaReturnEdge subclass: #JavaVoidReturnEdge
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaVoidReturnEdge comment: '
JavaVoidReturnEdges are attached to JavaBasicBlocks in a
void-returning method that return to the caller.

Like JavaReturnEdge, JavaVoidReturnEdge is a Singleton.'!


JavaEdge subclass: #JavaConditionalEdge
    instanceVariableNames: 'condition negated successorTrue successorFalse '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaConditionalEdge comment: '
JavaConditionalEdge represents two edges going out of a JavaBasicBlock
in a method''s control-flow-graph.

Instance Variables:
    condition	<Symbol>
	the condition to be tested on the item(s) at the top of the stack
    negated	<Boolean>
	whether to jump on false
    successorFalse	<JavaBasicBlock>
	the successor when the condition is false
    successorTrue	<JavaBasicBlock>
	the successor when the condition is true

'!


JavaLocalNode subclass: #JavaLocalStoreNode
    instanceVariableNames: 'value '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaLocalStoreNode comment: '
JavaLocalStoreNode is the IR node for storing a value into a Java
local variable.  Unlike Java''s *store bytecodes, this operation does
not pop the stored value off the stack (because all JavaProgramNodes
have a value).

Instance Variables:
    value	<JavaProgramNode>
	description of value

'!


JavaGotoEdge subclass: #JavaSubroutineReturnEdge
    instanceVariableNames: 'exceptionLocal '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

JavaSubroutineReturnEdge comment: '
JavaSubroutineReturnEdges are attached to JavaBasicBlocks that are
part of a method''s subroutine and that return to the caller.  These
are converted to gotos, so they are a subclass of JavaGotoEdge.  '!

Object subclass: #TargetInstructionPrinter
    instanceVariableNames: 'literals bytecodes base stream '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Java-Translation'!

!LiteralTable methodsFor: 'literals'!

keysClass
    "Answer the class answered by #keys"
    ^IdentitySet
!

hashFor: anObject
    "Return an hash value for the item, anObject"
    ^anObject hash bitXor: anObject class identityHash
!

findIndex: anObject
    "Tries to see if anObject exists as an indexed variable. As soon as nil
    or anObject is found, the index of that slot is answered"

    | index size element |
    self beConsistent.

    "Sorry for the lack of readability, but I want speed... :-)"
    index := ((self hashFor: anObject) scramble
                bitAnd: (size := self primSize) - 1) + 1.

    [
        ((element := self primAt: index) isNil
            or: [ element class == anObject class and: [ element = anObject ]])
                ifTrue: [ ^index ].

        index == size
            ifTrue: [ index := 1 ]
            ifFalse: [ index := index + 1 ]
    ] repeat
! !

!JavaMethodTranslator methodsFor: 'literals'!

addLiteral: anObject
    ^self literals at: anObject ifAbsentPut: [ self literals size ]
!

literalArray
    | a |
    a := Array new: self literals size.
    self literals keysAndValuesDo: [ :lit :index |
	a at: index + 1 put: lit ].
    ^a
!

printOn: aStream
    self javaMethod printHeadingOn: aStream.
    aStream nl.
    basicBlocks do: [ :each | each printOn: aStream ]
! !

!JavaMethodTranslator methodsFor: 'initializing'!

initialize
    literals := LiteralTable new
! !

!JavaMethodTranslator methodsFor: 'temporaries'!

allocTemporary
    ^(numTemps := numTemps + 1) - 1
!

exceptionTemp
    ^exceptionTemp
!

temporaryAt: local
    ^localMap at: local
! !

!JavaMethodTranslator methodsFor: 'accessing'!

basicBlocks
    ^basicBlocks
!

basicBlocks: bb
    basicBlocks := bb.
    basicBlocks do: [ :each | each methodTranslator: self ]
!

compiledMethod
    ^compiledMethod
!

currentEntryBasicBlock
    ^currentEntryBasicBlock
!

currentEntryBasicBlock: anObject
    currentEntryBasicBlock := anObject
!

javaClass
    ^javaMethod javaClass
!

javaMethod
    ^javaMethod
!

javaMethod: anObject
    | anal |
    javaMethod := anObject.
    anal := JavaBytecodeAnalyzer onMethod: javaMethod.
    self basicBlocks: anal basicBlocks.
    pcToBasicBlockMap := anal pcToBasicBlockMap.
    localMap := anal localMap.
    numTemps := localMap isEmpty ifTrue: [ 0 ] ifFalse: [ localMap last + 1 ].
    javaMethod handlers isEmpty ifFalse: [ exceptionTemp := self allocTemporary ]
!

literals
    ^literals
!

numTemps
    ^numTemps
! !

!JavaMethodTranslator methodsFor: 'translation'!

translate
    | size pc |
    "First, translate the instructions in a block.  Skip isolated
     JavaBasicBlocks."
    basicBlocks do: [:each | each translate].

    pc := 0.
    basicBlocks do: [:each |
	each translatedpc: pc.
        each hasBeenTranslated ifTrue: [ pc := pc + each size ] ].

    size := self translateEdges.
    self buildCompiledMethod: size.
!

translateEdges
    "Translate the CFG edges (jumps) doing as many
     passes as needed for their lengths to converge, plus
     one more to fix the destination addresses (passesLeft is
     always set to 2 except at the start, because the very
     first pass has already been done above, in
     #removeDeadBasicBlock)."
    | passesLeft pc |
    passesLeft := 1.

    [pc := 0.
    passesLeft := passesLeft - 1.
    basicBlocks do: [:each | 
	each translatedpc = pc ifFalse: [passesLeft := 2].
	each translatedpc: pc.
        each hasBeenTranslated ifTrue: [
	    each translateEdge.
	    pc := pc + each size ] ].
    passesLeft = 0] whileFalse.
    ^pc
! !

!JavaMethodTranslator methodsFor: 'building the CompiledMethod'!

attributesForHandlers
    javaMethod handlers isNil ifTrue: [ ^#() ].

    "For now, put nil in the first parameter; it will be patched
     later, after peephole optimization is done by the VM."
    ^Array with: (Message selector: #exceptionHandlerSearch:reset:
	arguments: { nil. [ :context | ] })
!

programCounterMap
    "Use the line number bytecodes put in by JavaBytecodeTranslator
     to build a map from Java program counters to Smalltalk program
     counters.  This is used for exception handlers and finding out
     line numbers."
    | programCounterMap last |
    programCounterMap := Array new: pcToBasicBlockMap size.
    last := 0.
    compiledMethod allByteCodeIndicesDo: [ :pc :bytecode :operand |
        bytecode = 54 ifTrue: [
	    "Hmmm, I really hate all this adjusting of 0-based vs.
	     1-based values."
	    last + 1 to: (last := operand + 1) do: [ :each |
	         programCounterMap at: each put: pc - 1 ] ]
    ].

    ^programCounterMap
!
   
buildCompiledMethod: size
    | mappedHandlers bytecodes |
    bytecodes := ByteArray new: size.
    basicBlocks do: [ :each |
        each hasBeenTranslated
	    ifTrue: [
	        bytecodes
	            replaceFrom: each translatedpc + 1
	            to: each translatedpc + each size
	            with: each bytecodes
	            startingAt: 1 ] ].

    compiledMethod := JavaCompiledMethod
	literals: self literalArray
	numArgs: self javaMethod numArgs
	numTemps: self numTemps
        attributes: self attributesForHandlers
	bytecodes: bytecodes
	depth: self javaMethod maxStack + self numTemps + 1.

    "After the method has been compiled, patch the exception
     handler table."

    compiledMethod descriptor size > 0 ifTrue: [
        mappedHandlers := JavaTranslatedExceptionHandlerTable
	    translateFrom: javaMethod handlers
	    withProgramCounterMap: self programCounterMap.

        mappedHandlers exceptionTemp: self exceptionTemp.
	(compiledMethod descriptor at: 1) arguments
	    at: 1 put: mappedHandlers
    ].
! !

!JavaMethodTranslator methodsFor: 'testing'!

isStatic
    ^self javaMethod isStatic
! !

!JavaMethodTranslator class methodsFor: 'instance creation'!

new
    ^super new initialize
!

onMethod: aJavaMethod
    ^self new
	javaMethod: aJavaMethod; 
	yourself
! !

!JavaUntypedInterpreter methodsFor: 'bytecodes'!

aaload
    self arrayLoad: 1
!

aastore
    self arrayStore: 1
!

aconst: operand 
    self constant: operand size: 1
!

aload: operand
    self load: operand size: 1
!

areturn
    self valueReturn: 1
!

astore: operand 
    self store: operand size: 1
!

baload
    self arrayLoad: 1
!

bastore
    self arrayStore: 1
!

bipush: operand 
    self constant: operand size: 1
!

caload
    self arrayLoad: 1
!

castore
    self arrayStore: 1
!

d2f
    self unary: #asFloatE delta: 1
!

d2i
    self unary: #javaAsInt delta: 1
!

d2l
    self unary: #javaAsLong delta: 0
!

dadd
    self binary: #+ delta: 2
!

daload
    self arrayLoad: 2
!

dastore
    self arrayStore: 2
!

dcmpg
    self binaryCompare: #javaCmpG: delta: 3
!

dcmpl
    self binaryCompare: #javaCmpL: delta: 3
!

dconst: operand 
    self constant: operand size: 2
!

ddiv
    ^self binary: #/ delta: 2
!

dload: operand 
    self load: operand size: 2
!

dmul
    ^self binary: #* delta: 2
!

dneg
    ^self unary: #negated delta: 0
!

drem
    ^self binary: #rem: delta: 2
!

dreturn
    self valueReturn: 2
!

dstore: operand 
    self store: operand size: 2
!

dsub
    self binary: #- delta: 2
!

f2d
    ^self unary: #asFloatD delta: 1
!

f2i
    self unary: #javaAsInt delta: 0
!

f2l
    self unary: #javaAsLong delta: 1
!

fadd
    self binary: #+ delta: 1
!

faload
    self arrayLoad: 1
!

fastore
    self arrayStore: 1
!

fcmpg
    self binaryCompare: #javaCmpG: delta: 1
!

fcmpl
    self binaryCompare: #javaCmpL: delta: 1
!

fconst: operand 
    self constant: operand size: 1
!

fdiv
    ^self binary: #/ delta: 1
!

fload: operand
    self load: operand size: 1
!

fmul
    ^self binary: #* delta: 1
!

fneg
    ^self unary: #negated delta: 0
!

frem
    ^self binary: #rem: delta: 1
!

freturn
    self valueReturn: 1
!

fstore: operand 
    self store: operand size: 1
!

fsub
    self binary: #- delta: 1
!

i2d
    ^self unary: #asFloatD delta: 1
!

i2f
    ^self unary: #asFloatE delta: 0
!

i2l
!

iadd
    self
	binary: #+ delta: 1;
	unary: #javaAsInt delta: 0
!

iaload
    self arrayLoad: 1
!

iand
    self binary: #bitAnd: delta: 1
!

iastore
    self arrayStore: 1
!

iconst: operand 
    self constant: operand size: 1
!

idiv
    ^self binary: #quo: delta: 1
!

ifeq: operand
    self constant: 0 size: 1.
    self if: #= goto: operand
!

ifge: operand
    self constant: 0 size: 1.
    self if: #>= goto: operand
!

ifgt: operand
    self constant: 0 size: 1.
    self if: #> goto: operand
!

ifle: operand
    self constant: 0 size: 1.
    self if: #<= goto: operand
!

iflt: operand
    self constant: 0 size: 1.
    self if: #< goto: operand
!

ifne: operand
    self constant: 0 size: 1.
    self if: #~= goto: operand
!

ifnonnull: operand
    self constant: nil size: 1.
    self if: #~~ goto: operand
!

ifnull: operand
    self constant: nil size: 1.
    self if: #== goto: operand
!

if_acmpeq: operand
    self if: #== goto: operand
!

if_acmpne: operand
    self if: #~~ goto: operand
!

if_icmpeq: operand
    self if: #= goto: operand
!

if_icmpge: operand
    self if: #>= goto: operand
!

if_icmpgt: operand
    self if: #> goto: operand
!

if_icmple: operand
    self if: #<= goto: operand
!

if_icmplt: operand
    self if: #< goto: operand
!

if_icmpne: operand
    self if: #~= goto: operand
!

iinc: operand by: amount 
    self
	load: operand size: 1;
	constant: amount size: 1;
	iadd;
	store: operand size: 1
!

iload: operand
    self load: operand size: 1
!

imul
    ^self
	binary: #* delta: 1;
	unary: #javaAsInt delta: 0
!

ineg
    ^self unary: #negated delta: 0
!

instanceof: operand
    | checkAgainst |
    operand isLoaded ifFalse: [ operand load ].

    checkAgainst := operand isInterface
	ifTrue: [ operand ]
	ifFalse: [ operand asSmalltalkClass ].

    self constant: checkAgainst size: 1.
    ^self binary: #instanceOf: delta: 1
!

int2byte
    self unary: #javaAsByte delta: 0
!

int2char
    self
	constant: 65535 size: 1;
	binary: #bitAnd: delta: 1
!

int2short
    self unary: #javaAsShort delta: 0
!

invokeinterface: operand nargs: args reserved: reserved
    self invoke: operand virtual: true
!

invokenonvirtual: operand
    self invoke: operand virtual: false
!

invokevirtual: operand
    self invoke: operand virtual: true
!

ior
    self binary: #bitOr: delta: 1
!

irem
    ^self binary: #rem: delta: 1
!

ireturn
    self valueReturn: 1
!

ishl
    self
	binary: #bitShift: delta: 1;
	unary: #javaAsInt delta: 0
!

ishr
    self
	unary: #negated delta: 0;
	binary: #bitShift: delta: 1
!

istore: operand 
    self store: operand size: 1
!

isub
    self
	binary: #- delta: 1;
	unary: #javaAsInt delta: 0
!

iushr
    self binary: #javaIushr: delta: 1
!

ixor
    self binary: #bitXor: delta: 1
!

l2d
    ^self unary: #asFloatD delta: 0
!

l2f
    ^self unary: #asFloatE delta: 1
!

l2i
    self unary: #javaAsInt delta: 1
!

ladd
    self binary: #+ delta: 2;
	unary: #javaAsLong delta: 0
!

laload
    self arrayLoad: 2
!

land
    self binary: #bitAnd: delta: 2
!

lastore
    self arrayStore: 2
!

lcmp
    self binaryCompare: #javaCmp: delta: 3
!

lconst: operand 
    self constant: operand size: 2
!

ldc2: operand 
    self constant: operand size: 2
!

ldc: operand 
    self constant: operand size: 1
!

ldiv
    ^self binary: #quo: delta: 2
!

lload: operand 
    self load: operand size: 2
!

lmul
    ^self binary: #* delta: 2;
	unary: #javaAsLong delta: 0
!

lneg
    ^self unary: #negated delta: 0;
	unary: #javaAsLong delta: 0
!

lor
    self binary: #bitOr: delta: 2
!

lrem
    ^self binary: #rem: delta: 1
!

lreturn
    self valueReturn: 2
!

lshl
    self binary: #bitShift: delta: 2;
	unary: #javaAsLong delta: 0
!

lshr
    self
	unary: #negated delta: 0;
	binary: #bitShift: delta: 2
!

lstore: operand 
    self store: operand size: 2
!

lsub
    self binary: #- delta: 2;
	unary: #javaAsLong delta: 0
!

lushr
    self binary: #javaLushr: delta: 2
!

lxor
    self binary: #bitXor: delta: 2
!

saload
    self arrayLoad: 1
!

sastore
    self arrayStore: 1
!

sipush: operand 
    self constant: operand size: 1
! !

!JavaUntypedInterpreter methodsFor: 'untyped bytecodes'!

binaryCompare: selector delta: delta
    ^self binary: selector delta: delta!

arrayLoad: size!
arrayStore: size!
binary: selector delta: delta!
constant: constant size: n!
if: aSelector goto: dest!
invoke: signature virtual: virtual!
load: localSlot size: n!
store: localSlot size: n!
unary: selector delta: delta!
valueReturn: size! !

!JavaEdgeCreator methodsFor: 'untyped bytecodes'!

if: aSelector goto: dest 
    | successorTrue successorFalse |
    successorFalse := self basicBlockAt: self nextPC.
    successorTrue := self basicBlockAt: dest.
    currentBasicBlock outEdge: (JavaConditionalEdge 
	condition: aSelector
	successorTrue: successorTrue
	successorFalse: successorFalse)
!

valueReturn: size
    currentBasicBlock 
	outEdge: JavaReturnEdge soleInstance
! !

!JavaEdgeCreator methodsFor: 'bytecodes'!

athrow
    currentBasicBlock 
	outEdge: JavaThrowExceptionEdge soleInstance
!

goto: operand 
    currentBasicBlock 
	outEdge: (JavaGotoEdge successor: (self basicBlockAt: operand))
!

jsr: operand 
    | destBB fallThroughBB |
    destBB := self basicBlockAt: operand.
    fallThroughBB := self basicBlockAt: self nextPC.
    currentBasicBlock outEdge: (JavaJumpToFinallyEdge successor: destBB returnPoint: fallThroughBB)
!

lookupswitch: default destinations: dest 
    | defaultBB |
    defaultBB := self basicBlockAt: default.
    currentBasicBlock outEdge: (JavaLookupSwitchStatementEdge 
			basicBlocks: (self getLookupSwitchDestinations: dest)
			defaultSuccessor: defaultBB
			values: (self getLookupSwitchValues: dest))
!

ret: operand
    currentBasicBlock 
	outEdge: (JavaSubroutineReturnEdge exceptionLocal: operand)
!

return
    currentBasicBlock 
	outEdge: JavaVoidReturnEdge soleInstance
!

tableswitch: default low: low high: high destinations: addresses
    | defaultBB |
    defaultBB := self basicBlockAt: default.
    currentBasicBlock outEdge: (JavaTableSwitchStatementEdge 
			basicBlocks: (self getTableSwitchDestinations: addresses)
			defaultSuccessor: defaultBB
			low: low)
! !

!JavaEdgeCreator methodsFor: 'edge creation'!

addFallThroughEdge
    "We also need to add the last instruction to the basic block if there is a forced edge"
    currentBasicBlock
	outEdge: (JavaFallThroughEdge
		     successor: (self basicBlockAt: self nextPC))
!

interpret
    basicBlocks do: [:each | 
	self nextPC: each finalpc.
	currentBasicBlock := each.
	self dispatch.

	"Now add the final instruction to the basic block.  We need it
	 for example to generate the second argument of the comparison
	 in icmp* bytecodes."
        currentBasicBlock length: self nextPC - currentBasicBlock startpc.
	currentBasicBlock outEdge isNil
	    ifTrue: [self addFallThroughEdge]].
! !

!JavaEdgeCreator methodsFor: 'accessing'!

basicBlockAt: dest 
    ^pcToBasicBlockMap at: dest + 1
!

basicBlocks
    ^basicBlocks
!

basicBlocks: anObject
    basicBlocks := anObject
!

pcToBasicBlockMap
    ^pcToBasicBlockMap
!

pcToBasicBlockMap: anObject
    pcToBasicBlockMap := anObject
! !

!JavaEdgeCreator methodsFor: 'utilty-switch bytecodes'!

getLookupSwitchDestinations: dest
    ^dest collect: [ :each | self basicBlockAt: each value ]
!

getLookupSwitchValues: dest
    ^dest collect: [ :each | each key ]
!

getTableSwitchDestinations: dest
    ^dest collect: [ :each | self basicBlockAt: each ]
! !

!JavaEdgeCreator class methodsFor: 'interpretation'!

onSameMethodAs: aJavaBytecodeAnalyzer 
    ^(super onSameMethodAs: aJavaBytecodeAnalyzer)
	basicBlocks: aJavaBytecodeAnalyzer basicBlocks;
	pcToBasicBlockMap: aJavaBytecodeAnalyzer pcToBasicBlockMap;
	yourself
! !

!JavaBytecodeTranslator methodsFor: 'accessing'!

javaMethod
    ^javaMethod
!

javaMethod: anObject
    javaMethod := anObject.
    spills := Array new: javaMethod maxStack + 1.

    "Push a dummy node for the pointer to this."
    (javaMethod isStatic not and: [ stack isEmpty ]) ifTrue: [
	self stackPush: (JavaProgramNode new wordSize: 1; yourself).
	minimumStackDepth := 1]
!

stack
    ^stack
!

stack: anObject
    stack := anObject.
    minimumStackDepth := stack size.
!

methodTranslator
    ^destination methodTranslator
! !

!JavaBytecodeTranslator methodsFor: 'initialization'!

initialize
    super initialize.
    stack := OrderedCollection new.
    minimumStackDepth := 0.
! !

!JavaBytecodeTranslator methodsFor: 'untyped bytecodes'!

arrayLoad: n 
    self stackInvokeArray: #at: numArgs: 1 size: n
!

arrayStore: n
    self stackInvokeArray: #at:put: numArgs: 2 size: n; stackPop
!

binaryCompare: selector delta: delta
    "If we are before an iflt/le/ge/gt/eq/ne bytecode, we can
     fold the comparison and the following bytecode into the
     JavaEdge.  This requires some care because of the separate
     dcmpl/dcmpg bytecodes, and this is handled by
     #applyComparison:."
    (stream peek between: 153 and: 158)
	ifTrue: [
	    destination outEdge applyComparison: selector.
	    stream position: destination finalpc.
	    ^self ].

    self binary: selector delta: delta
!
    
binary: selector delta: delta
    | top wordSize |
    top := stack last.
    wordSize := (top wordSize = 1 or: [ delta odd ]) ifTrue: [ 1 ] ifFalse: [ 2 ].
    self stackInvoke: selector numArgs: 1 size: wordSize
!

constant: constant size: n 
    self stackPushConstant: constant size: n
!

invoke: signature virtual: virtual
    | numArgs selector toSuper |
    selector := signature selector.
    numArgs := signature numArgs.
    toSuper := virtual not
	and: [ javaMethod isStatic not
	and: [ signature javaClass ~= javaMethod javaClass
	and: [ (stack at: stack size - numArgs) isLocal
	and: [ (stack at: stack size - numArgs) id = 0 ]]]].

    toSuper 
	ifTrue: [self stackSuperInvoke: selector numArgs: numArgs size: signature returnType wordSize]
	ifFalse: [self stackInvoke: selector numArgs: numArgs size: signature returnType wordSize].

    "Pop the return value for void methods, Smalltalk does not have them."
    signature isVoid ifTrue: [self stackPop]
!

load: localSlot size: n 
    self stackPushLocal: localSlot size: n
!

store: localSlot size: n 
    self stackStoreLocal: localSlot
!

unary: selector delta: delta
    | top wordSize |
    top := stack last.
    wordSize := (top wordSize = 1 or: [ delta < 0 ]) ifTrue: [ 1 ] ifFalse: [ 2 ].
    self stackInvoke: selector numArgs: 0 size: wordSize
! !

!JavaBytecodeTranslator methodsFor: 'bytecodes'!

anewarray: operand
    self stackInvoke: #new: receiver: Array numArgs: 1 size: 1
!

arraylength
    self stackInvoke: #size numArgs: 0 size: 1
!

checkcast: operand
    | checkAgainst |
    operand isLoaded ifFalse: [ operand load ].

    checkAgainst := operand isInterface
	ifTrue: [ operand ]
	ifFalse: [ operand asSmalltalkClass ].

    self stackPushConstant: checkAgainst size: 1.
    self stackInvoke: #checkCast: numArgs: 1 size: 1
!

dup
    | spill |
    self stackSpillAll.
    spill := self stackPop.
    self stackPush: spill.
    self stackPush: spill
!

dup2
    | s1b s1a |
    self stackSpillAll.
    stack last wordSize = 2 
	ifTrue: 
		[s1a := self stackPop.
		self stackPush: s1a.
		self stackPush: s1a]
	ifFalse: 
		[s1b := self stackPop.
		s1a := self stackPop.
		self stackPush: s1a.
		self stackPush: s1b.
		self stackPush: s1a.
		self stackPush: s1b]
!

dup2_x1
    | s1a s2a s2b |
    self stackSpillAll.
    stack last wordSize = 2 
	ifTrue: 
		[s2a := self stackPop.
		s1a := self stackPop.
		self stackPush: s2a.
		self stackPush: s1a.
		self stackPush: s2a]
	ifFalse: 
		[s2b := self stackPop.
		s2a := self stackPop.
		s1a := self stackPop.
		self stackPush: s2a.
		self stackPush: s2b.
		self stackPush: s1a.
		self stackPush: s2a.
		self stackPush: s2b]
!

dup2_x2
    | s1a s1b s2a s2b |
    self stackSpillAll.
    stack last wordSize = 2 
	ifTrue: 
		[s2a := self stackPop]
	ifFalse: 
		[s2b := self stackPop.
		s2a := self stackPop].

    stack last wordSize = 2 
	ifTrue: 
		[s1a := self stackPop]
	ifFalse: 
		[s1b := self stackPop.
		s1a := self stackPop].

    self stackPush: s2a.
    s2b isNil ifFalse: [self stackPush: s2b].
    self stackPush: s1a.
    s1b isNil ifFalse: [self stackPush: s1b].
    self stackPush: s2a.
    s2b isNil ifFalse: [self stackPush: s2b].
!

dup_x1
    | s1a s2a |
    self stackSpillAll.
    s2a := self stackPop.
    s1a := self stackPop.
    self stackPush: s2a.
    self stackPush: s1a.
    self stackPush: s2a.
!

dup_x2
    | s1a s1b s2a |
    self stackSpillAll.
    s2a := self stackPop.
    s2a wordSize = 2 
	ifTrue: 
		[s1a := self stackPop.
		self stackPush: s2a.
		self stackPush: s1a.
		self stackPush: s2a]
	ifFalse: 
		[s1b := self stackPop.
		s1a := self stackPop.
		self stackPush: s2a.
		self stackPush: s1a.
		self stackPush: s1b.
		self stackPush: s2a]
!

getfield: operand
    operand javaClass isLoaded ifFalse: [ operand javaClass load ].

    self 
	stackInvoke: operand getSelector
	numArgs: 0
	size: operand wordSize
!

getstatic: operand
    operand javaClass isLoaded ifFalse: [ operand javaClass load ].

    self 
	stackInvoke: operand getSelector
	receiver: operand javaClass asSmalltalkClass
	numArgs: 0
	size: operand wordSize
!

invokestatic: signature 
    | numArgs selector |
    selector := signature selector.
    numArgs := signature numArgs.
    self 
	stackInvoke: selector
	receiver: signature javaClass asSmalltalkClass
	numArgs: numArgs
	size: signature returnType wordSize.

    "Pop the return value for void methods, Smalltalk does not have them."
    signature isVoid ifTrue: [self stackPop]
!

monitorenter
    self
	stackInvoke: #monitorEnter numArgs: 0 size: 1;
	stackPop
!

monitorexit
    self
	stackInvoke: #monitorExit numArgs: 0 size: 1;
	stackPop
!

multianewarray: operand dimensions: dimensions 
    | countsNode primitiveType |
    "Create an array with the dimensions"
    countsNode := JavaArrayNode new: dimensions.
    dimensions to: 1
	by: -1
	do: [:each | countsNode at: each put: stack removeLast].

    self constant: operand size: 1.
    self stackPush: countsNode.
    self constant: 1 size: 1.
    self stackInvoke: #javaMultiNewArray:from: numArgs: 2 size: 1
!

new: operand
    self 
	stackInvoke: #new
	receiver: operand asSmalltalkClass
	numArgs: 0
	size: 1
!

newarray: operand
    self
	stackInvoke: #javaNewArray:
	receiver: operand arrayClass
	numArgs: 1
	size: 1
!

pop
    self stackPop.
!

pop2
    stack last wordSize = 1 ifTrue: [ self stackPop ].
    self stackPop
!

putfield: operand 
    operand javaClass isLoaded ifFalse: [ operand javaClass load ].

    self
	stackInvoke: operand putSelector
		numArgs: 1
		size: operand wordSize;
	stackPop
!

putstatic: operand 
    operand javaClass isLoaded ifFalse: [ operand javaClass load ].

    self
	stackInvoke: operand putSelector
		receiver: operand javaClass asSmalltalkClass
		numArgs: 1
		size: operand wordSize;
	stackPop
!

swap
    | s2 s1 |
    self stackSpillAll.
    s2 := self stackPop.
    s1 := self stackPop.
    self stackPush: s2.
    self stackPush: s1.
! !

!JavaBytecodeTranslator methodsFor: 'translating'!

convertMathSelector: javaSelector
    | s |
    javaSelector == #'sin(D)D' ifTrue: [ ^#sin ].
    javaSelector == #'cos(D)D' ifTrue: [ ^#cos ].
    javaSelector == #'tan(D)D' ifTrue: [ ^#tan ].
    javaSelector == #'asin(D)D' ifTrue: [ ^#arcSin ].
    javaSelector == #'acos(D)D' ifTrue: [ ^#arcCos ].
    javaSelector == #'atan(D)D' ifTrue: [ ^#arcTan ].
    javaSelector == #'atan2(DD)D' ifTrue: [ ^#arcTan: ].
    javaSelector == #'exp(D)D' ifTrue: [ ^#exp ].
    javaSelector == #'log(D)D' ifTrue: [ ^#ln ].
    javaSelector == #'sqrt(D)D' ifTrue: [ ^#sqrt ].
    javaSelector == #'pow(DD)D' ifTrue: [ ^#raisedTo: ].
    javaSelector == #'ceil(D)D' ifTrue: [ ^#ceiling ].
    javaSelector == #'floor(D)D' ifTrue: [ ^#floor ].
    javaSelector == #'rint(D)D' ifTrue: [ ^#rounded ].
    s := javaSelector copyFrom: 1 to: 3.
    s = 'abs' ifTrue: [ ^#abs ].
    s = 'min' ifTrue: [ ^#min: ].
    s = 'max' ifTrue: [ ^#max: ].
    ^nil
!

finishTranslation
    | edgeStackBalance |
    edgeStackBalance := destination outEdge edgeStackBalance.

    "Spill the slots that are part of a message send done elsewhere,
     but not if all the slots are actually consumed by the edge."
    self stackSpillAllButLast: edgeStackBalance.

    "Push on the stack those slots that are needed to translate the edge"
    stack size + edgeStackBalance + 1 to: stack size
	do: [:slot | (stack at: slot) emitForValue: destination].
    edgeStackBalance to: -1 do: [:unused | stack removeLast]
!

translateBasicBlock: aBasicBlock
    | finalpc knownPcValues knownPcIndex pc |
    stream position: aBasicBlock startpc.
    finalpc := aBasicBlock finalpc .
    destination := aBasicBlock.
    knownPcValues := aBasicBlock knownPcValues.
    knownPcIndex := 1.
    [(pc := stream position) < finalpc] whileTrue: [
	(knownPcValues at: knownPcIndex) = pc
	    ifTrue: [
		aBasicBlock lineNumber: pc.
		knownPcIndex := knownPcIndex + 1
	    ].

	self dispatch].

    self finishTranslation
! !

!JavaBytecodeTranslator methodsFor: 'stack manipulation'!

stackInvokeArray: selector numArgs: args size: n
    | invoc index |
    invoc := JavaMessageSendNode new: args + 1.
    args + 1 to: 1
	by: -1
	do: [:each | invoc at: each put: stack removeLast].

    invoc
	wordSize: n;
	selector: selector;
	at: 2 put: (invoc at: 2) incremented.	"first element is the receiver"

    stack addLast: invoc
!

stackInvoke: selector numArgs: args size: n 
    | invoc |
    invoc := JavaMessageSendNode new: args + 1.
    args + 1 to: 1
	by: -1
	do: [:each | invoc at: each put: stack removeLast].
    invoc
	wordSize: n;
	selector: selector.
    stack addLast: invoc
!

stackInvoke: selector receiver: receiver numArgs: args size: n 
    | invoc |
    (receiver == Java.java.lang.Math and: [
	self stackInvokeMath: selector numArgs: args size: n ])
	    ifTrue: [ ^self ].

    invoc := JavaMessageSendNode new: args + 1.
    args + 1 to: 2
	by: -1
	do: [:each | invoc at: each put: stack removeLast].
    invoc
	at: 1 put: (JavaConstantNode object: receiver wordSize: 1);
	wordSize: n;
	selector: selector.
    stack addLast: invoc
!

stackInvokeMath: selector numArgs: args size: n 
    | stSelector |
    stSelector := self convertMathSelector: selector.
    stSelector notNil ifTrue: [
	self stackInvoke: stSelector numArgs: args - 1 size: n.
	^true ].
    ^false
!

stackPop
    "Overall, remove the number of items that is contained
     in the topmost stack item"
    | last |
    last := stack removeLast.
    last emitForEffect: destination.
    stack size < minimumStackDepth ifTrue: [ minimumStackDepth := stack size ].
    ^last
!

stackPush: node
    stack addLast: node
!

stackPushConstant: object size: n 
    stack addLast: (JavaConstantNode object: object wordSize: n)
!

stackPushLocal: num size: n 
    stack addLast: (JavaLocalNode id: num wordSize: n)
!

stackSpill: slot 
    | spill spilledNode |
    spill := spills at: slot.
    spill isNil 
	ifTrue: [spills at: slot put: (spill := self methodTranslator allocTemporary)].
    spilledNode := stack at: slot.

    "If there's already a spill, no need to re-emit it."
    (spilledNode isSpill and: [ spilledNode id = spill ])
	ifTrue: [ ^spilledNode ].

    "Else store it."
    spilledNode emitForValue: destination.
    destination
	storeTemporary: spill;
	popStackTop.
    ^JavaSpillNode id: spill wordSize: spilledNode wordSize
!

stackSpillAll
    minimumStackDepth + 1 to: stack size
	do: [:slot | stack at: slot put: (self stackSpill: slot)]
!

stackSpillAllButLast: edgeStackBalance 
    minimumStackDepth + 1 to: stack size + edgeStackBalance
	do: [:slot | stack at: slot put: (self stackSpill: slot)]
!

stackStoreLocal: num
    | value |
    value := stack removeLast.

    "Spill here, so that
	iload 2
	iinc 2 1
    loads before incrementing."

    self stackSpillAll.
    (JavaLocalStoreNode id: num value: value) emitForEffect: destination
!

stackSuperInvoke: selector numArgs: args size: n 
    | invoc |
    invoc := JavaSuperMessageSendNode new: args + 1.
    args + 1 to: 1 by: -1 do: [ :each | invoc at: each put: stack removeLast ].
    invoc
	wordSize: n;
	selector: selector.
    stack addLast: invoc
! !

!JavaBytecodeTranslator class methodsFor: 'interpretation'!

onMethod: aJavaMethod
    ^(super onMethod: aJavaMethod)
	javaMethod: aJavaMethod
	yourself
! !


!JavaExceptionHandler methodsFor: 'translation'!

mappedThrough: pcMap
    | newStartPC newFinalPC newHandlerPC |
    "We adjust by two the finalpc, because the VM advances the
     program counter *before* executing the instruction."
    newStartPC := (pcMap at: self startpc + 1).
    newFinalPC := (pcMap at: self finalpc + 1) + 2.
    newHandlerPC := (pcMap at: self handlerpc + 1).
    ^JavaExceptionHandler new
        startpc: newStartPC;
        finalpc: newFinalPC;
        handlerpc: newHandlerPC;
        type: (self type isNil ifTrue: [ nil ] ifFalse: [ self type asSmalltalkClass ]);
        yourself
! !


!JavaTranslatedExceptionHandlerTable class methodsFor: 'instance creation'!

translateFrom: excHandlerTable withProgramCounterMap: pcMap
    | result |
    result := self new: excHandlerTable size.
    1 to: result size do: [ :i |
	result
	    at: i
	    put: ((excHandlerTable at: i) mappedThrough: pcMap) ].

    ^result
! !

!JavaTranslatedExceptionHandlerTable methodsFor: 'accessing'!

exceptionTemp
    ^exceptionTemp
!

exceptionTemp: anInteger
    exceptionTemp := anInteger
! !

!JavaBasicBlock methodsFor: 'accessing'!

bytecodes
    ^bytecodes contents
!

finalpc
    ^self startpc + self length
!

initialAStore: local
    "Do nothing; subclasses are interested in astore's to associate each
     subroutines with the return address, and catch blocks with the
     local holding the exception."
!

javaClass
    ^self methodTranslator javaClass
!

javaMethod
    ^self methodTranslator javaMethod
!

knownPcValues
    ^knownPcValues
!

knownPcValues: anObject
    knownPcValues := anObject.
!

length
    ^length
!

length: anObject
    length := anObject
!

outEdge
    ^outEdge
!

outEdge: anObject
    outEdge := anObject
!

size
    ^bytecodes size
!

startpc
    ^startpc
!

startpc: anObject
    startpc := anObject
!

methodTranslator
    ^methodTranslator
!

methodTranslator: anObject
    methodTranslator := anObject
!

translatedpc
    ^translatedpc
!

translatedpc: anObject
    translatedpc := anObject
! !

!JavaBasicBlock methodsFor: 'printing'!

printBytecodesOn: aStream 
    bytecodes isNil ifTrue: [^nil].
    TargetInstructionPrinter 
	print: bytecodes contents
	literals: self methodTranslator literalArray
	base: self translatedpc
	on: aStream
!

printOn: aStream 
    self printPcRangeOn: aStream.
    self printBytecodesOn: aStream
!

printPcRangeOn: aStream 
    aStream
	nextPutAll: 'pc ';
	print: self startpc;
	nextPutAll: '..';
	print: self finalpc;
	space;
	print: self outEdge;
	nl
! !

!JavaBasicBlock methodsFor: 'target instruction set'!

compileByte: byte
    bytecodes nextPut: byte; nextPut: 0
!

compileByte: byte with: arg 
    "First emit the extension bytes"
    arg > 16rFF 
	ifTrue: 
		[arg > 16rFFFF 
			ifTrue: 
				[arg > 16rFFFFFF 
					ifTrue: 
						[bytecodes
							nextPut: 55;
							nextPut: (arg bitShift: -24)].
				bytecodes
					nextPut: 55;
					nextPut: ((arg bitShift: -16) bitAnd: 255)].
		bytecodes
			nextPut: 55;
			nextPut: ((arg bitShift: -8) bitAnd: 255)].

    "Then the real opcode."
    bytecodes
	nextPut: byte;
	nextPut: (arg bitAnd: 255)
!

compileByte: byte with: arg with: arg2 
    "First emit the extension bytes"
    arg > 16rFF 
	ifTrue: 
		[arg > 16rFFFF 
			ifTrue: 
				[bytecodes
					nextPut: 55;
					nextPut: (arg bitShift: -16)].
		bytecodes
			nextPut: 55;
			nextPut: ((arg bitShift: -8) bitAnd: 255)].

    "Then the extension byte for the first argument, and the real opcode."
    bytecodes
	nextPut: 55;
	nextPut: (arg bitAnd: 255);
	nextPut: byte;
	nextPut: (arg2 bitAnd: 255)
!

dupStackTop
    self compileByte: 52
!

goto: dest 
    | offset |
    offset := dest - (self translatedpc + bytecodes size) - 2.
    offset < 0 
	ifTrue: 
		[offset <= -256 
			ifTrue: 
				[offset := offset - 2.
				offset <= -65536 
					ifTrue: 
						[offset := offset - 2.
						offset <= -16777216 ifTrue: [offset := offset - 2]]].
		self compileByte: 40 with: offset negated]
	ifFalse:
		[offset >= 256 
			ifTrue: 
				[offset := offset - 2.
				offset >= 65536 
					ifTrue: 
						[offset := offset - 2.
						offset >= 16777216 ifTrue: [offset := offset - 2]]].
		self compileByte: 41 with: offset]
!

lineNumber: line
    self compileByte: 54 with: line
!

popIntoArray: index
    self compileByte: 47 with: index
!

popJumpIfFalseTo: dest 
    self 
	popJumpTo: dest
	conditionBytecode: 43
	inverseBytecode: 42
!

popJumpIfTrueTo: dest 
    self 
	popJumpTo: dest
	conditionBytecode: 42
	inverseBytecode: 43
!

popJumpTo: dest conditionBytecode: jumpForwardBytecode inverseBytecode: jumpAroundBytecode 
    | jumpAroundOfs offset |
    offset := dest - (self translatedpc + bytecodes size) - 2.
    offset < 0 
	ifTrue: 
		[jumpAroundOfs := offset > -254 
					ifTrue: [2]
					ifFalse: 
						[offset > -65534 
							ifTrue: [4]
							ifFalse: [offset > -16777214 ifTrue: [6] ifFalse: [8]]].
		self compileByte: jumpAroundBytecode with: jumpAroundOfs.
		self compileByte: 40 with: offset negated + jumpAroundOfs]
	ifFalse: 
		[offset >= 256 
			ifTrue: 
				[offset := offset - 2.
				offset >= 65536 
					ifTrue: 
						[offset := offset - 2.
						offset >= 16777216 ifTrue: [offset := offset - 2]]].
		self compileByte: jumpForwardBytecode with: offset]
!

popStackTop
    self compileByte: 48
!

pushBlock: object
    object flags = 0 ifTrue: [ ^self pushLiteral: (BlockClosure block: object) ].
    self pushLiteral: object.
    self compileByte: 49
!

pushBoolean: aBoolean 
    ^self compileByte: 45 with: (aBoolean ifTrue: [1] ifFalse: [2])
!

pushGlobal: binding
    | literalIndex |
    literalIndex := self methodTranslator addLiteral: binding.
    self compileByte: 34 with: literalIndex
!

pushInstanceVariable: index
    self compileByte: 35 with: index
!

pushLiteral: object
    | literalIndex |
    (object isInteger and: [ object between: 0 and: 16r3FFFFFFF ])
	ifTrue: [ ^self compileByte: 44 with: object ].

    object isNil ifTrue: [ ^self compileByte: 45 with: 0 ].
    object == true ifTrue: [ ^self compileByte: 45 with: 1 ].
    object == false ifTrue: [ ^self compileByte: 45 with: 2 ].
    literalIndex := self methodTranslator addLiteral: object.
    self compileByte: 46 with: literalIndex
!

pushNil
    ^self compileByte: 45 with: 0
!

pushSelf
    self compileByte: 56
!

pushTemporary: index
    self compileByte: 32 with: index
!

pushTemporary: index outer: scopes 
    self 
	compileByte: 33
	with: index
	with: scopes
!

return
    self compileByte: 51
!

returnFromMethod
    self compileByte: 50
!

send: aSymbol numArgs: numArgs 
    | specialBytecode literalIndex |
    specialBytecode := SpecialSelectorMap at: aSymbol ifAbsent: [nil].
    specialBytecode isNil 
	ifTrue: 
		[literalIndex := self methodTranslator addLiteral: aSymbol.
		self 
			compileByte: 28
			with: literalIndex
			with: numArgs]
	ifFalse: 
		[specialBytecode <= 26 ifTrue: [^self compileByte: specialBytecode].
		self compileByte: 30 with: specialBytecode]
!

storeGlobal: binding
    | literalIndex |
    literalIndex := self methodTranslator addLiteral: binding.
    self compileByte: 38 with: literalIndex
!

storeInstanceVariable: index
    self compileByte: 39 with: index
!

storeTemporary: index
    self compileByte: 36 with: index
!

storeTemporary: index outer: scopes 
    self 
	compileByte: 37
	with: index
	with: scopes
!

superSend: aSymbol numArgs: numArgs 
    | specialBytecode literalIndex |
    self pushLiteral: self javaClass asSmalltalkClass superclass.
    specialBytecode := SpecialSelectorMap at: aSymbol ifAbsent: [nil].
    specialBytecode isNil 
	ifTrue: 
		[literalIndex := self methodTranslator addLiteral: aSymbol.
		self 
			compileByte: 29
			with: literalIndex
			with: numArgs]
	ifFalse: [self compileByte: 31 with: specialBytecode]
! !

!JavaBasicBlock methodsFor: 'translating'!

prepareStackOf: translator
!

translate
    "Do nothing.  All basic blocks should be reached from a
     JavaEntryBasicBlock, else they are dead code."
!

translateEdge
    bytecodes position: translationSize.
    bytecodes truncate.
    self outEdge translateFor: self
!

translateSuccessorsWith: translator 
    | stack |
    stack := translator stack.
    self successorsDo: 
		[:each | 
		translator stack: stack copy.
		each translateWith: translator]
!

translateWith: translator 
    self hasBeenTranslated ifTrue: [ ^self ].
    bytecodes := WriteStream on: (ByteArray new: 16).
    self prepareStackOf: translator.
    translator translateBasicBlock: self.
    translationSize := bytecodes size.
    self outEdge entryBlock: self methodTranslator currentEntryBasicBlock.
    self translateSuccessorsWith: translator
! !

!JavaBasicBlock methodsFor: 'temporaries'!

allocTemporary
    ^self methodTranslator allocTemporary
! !

!JavaBasicBlock methodsFor: 'iterating'!

successorsDo: aBlock
    self outEdge successorsDo: aBlock
! !

!JavaBasicBlock methodsFor: 'testing'!

hasBeenTranslated
    ^bytecodes notNil
! !

!JavaBasicBlock methodsFor: 'java bytecodes'!

pushLocal: localSlot 
    "Static methods in Java do not have a this pointer, so locals
     are 0-based there; instead, they are 1-based in non-static
     methods.  In Smalltalk bytecodes, they are 0-based."

    | tempSlot |
    tempSlot := self javaMethod isStatic 
			ifTrue: [localSlot + 1]
			ifFalse: [localSlot].
    tempSlot = 0 
	ifTrue: [self pushSelf]
	ifFalse: [self pushTemporary: (self methodTranslator temporaryAt: tempSlot) ]
!

storeLocal: localSlot 
    "Static methods in Java do not have a this pointer, so locals
     are 0-based there; instead, they are 1-based in non-static
     methods.  In Smalltalk bytecodes, they are 0-based."

    | tempSlot |
    tempSlot := self javaMethod isStatic 
			ifTrue: [localSlot + 1]
			ifFalse: [localSlot].
    self storeTemporary: (self methodTranslator temporaryAt: tempSlot)
! !

!JavaBasicBlock class methodsFor: 'initialization'!

initialize
    SpecialSelectorMap := LookupTable new.
    CompiledCode specialSelectors keysAndValuesDo: [ :i :each |
	each isNil ifFalse: [SpecialSelectorMap at: each put: i - 1 ]]
! !

!JavaBytecodeAnalyzer methodsFor: 'bytecodes'!

astore: n
    "Identify an astore at the beginning of each subroutine."
    pc = currentBasicBlock startpc
	ifTrue: [ currentBasicBlock initialAStore: n ].

    super astore: n
!

athrow
    nextStartsBasicBlock := true
!

goto: operand
    nextStartsBasicBlock := true.
    self startBasicBlock: JavaBasicBlock at: operand
!

jsr: operand 
    nextStartsBasicBlock := true.
    self startBasicBlock: JavaSubroutineEntryBasicBlock at: operand
!

lookupswitch: default destinations: dest 
    nextStartsBasicBlock := true.
    self startBasicBlock: JavaBasicBlock at: default.
    dest do: [:each | 
	self startBasicBlock: JavaBasicBlock at: each value]
!

ret: operand
    self useLocal: operand.
    nextStartsBasicBlock := true
!

return
    nextStartsBasicBlock := true
!

tableswitch: default low: low high: high destinations: addresses 
    nextStartsBasicBlock := true.
    self startBasicBlock: JavaBasicBlock at: default.
    addresses do: [:each |
	self startBasicBlock: JavaBasicBlock at: each]
! !

!JavaBytecodeAnalyzer methodsFor: 'untyped bytecodes'!

if: aSelector goto: dest
    nextStartsBasicBlock := true.
    self startBasicBlock: JavaBasicBlock at: dest
!

load: localSlot size: n
    self useLocal: localSlot.
!

store: localSlot size: n 
    self useLocal: localSlot.
!

valueReturn: size
    nextStartsBasicBlock := true
! !

!JavaBytecodeAnalyzer methodsFor: 'accessing'!

basicBlocks
    basicBlocks isEmpty ifTrue: [ self interpret ].
    ^basicBlocks
!

javaMethod
    ^javaMethod
!

localMap
    | last |
    last := 0.
    ^usedLocals collect: [:each | 
	| old |
	old := last.
	last := last + each.
	old]
!

pcToBasicBlockMap
    ^pcToBasicBlockMap
!

useLocal: localSlot
    | tempSlot |
    tempSlot := self javaMethod isStatic 
			ifTrue: [localSlot + 1]
			ifFalse: [localSlot].
    tempSlot > 0 ifTrue: [usedLocals at: tempSlot put: 1]
! !

!JavaBytecodeAnalyzer methodsFor: 'basic block creation'!

addExceptionHandlingBoundaries: aJavaMethod
    aJavaMethod handlers do: 
		[:each || handlerBBClass |
		each handlerpc < each startpc
			ifTrue: [ self error: 'sorry, I''m assuming that try blocks come before exception handlers' ].

		handlerBBClass := each isFinallyHandler
			ifTrue: [ JavaFinallyHandlerBasicBlock ]
			ifFalse: [ JavaExceptionHandlerBasicBlock ].

		self
			startBasicBlock: JavaEntryBasicBlock at: each startpc;
			startBasicBlock: JavaBasicBlock at: each finalpc;
			startBasicBlock: handlerBBClass at: each handlerpc]
!

currentBasicBlock: aBasicBlock 
    basicBlocks add: aBasicBlock.
    currentBasicBlock := aBasicBlock
!

dispatch: op 
    | startBasicBlockAfterThis |
    startBasicBlockAfterThis := nextStartsBasicBlock.
    nextStartsBasicBlock := false.
    super dispatch: op.

    self maybeStartBasicBlock: startBasicBlockAfterThis.
    pcToBasicBlockMap at: pc + 1 put: currentBasicBlock.

    "Note that as a result of this, the jump instruction is not included in a
     basic block.  This is only provisional, the jump is added after the
     JavaEdgeCreator interprets it."
    currentBasicBlock length: pc - currentBasicBlock startpc.
!

interpret
    super interpret.
    self setKnownPcValuesForBasicBlocks.
    (JavaEdgeCreator onSameMethodAs: self) interpret.
!

maybeStartBasicBlock: always
    | class |
    class := always ifTrue: [ JavaBasicBlock ] ifFalse: [ nil ].

    "Always check knownBasicBlockStarts, because it may tell us to
     create a subclass of JavaBasicBlock."
    [knownBasicBlockStarts notEmpty 
	and: [knownBasicBlockStarts first key == pc]] whileTrue: [
		class := knownBasicBlockStarts removeFirst value ].

    class isNil ifFalse: [ self startBasicBlock: class ]
!

pcValueBefore: destPC
    | result |
    result := destPC.
    "Instead of decrementing at the head of the loop, at then
     adding 1 when accessing pcToBasicBlockMap, decrement at
     the bottom of the loop."
    [ (pcToBasicBlockMap at: result) isNil ]
	whileTrue: [ result := result - 1 ].

    ^result - 1
!

setKnownPcValuesForBasicBlocks
    "Go through the knownPcValues, and add a subset of this
     table to each basic block."
    | lastPC lastBB destIndex knownPcValuesArray |
    destIndex := 1.
    knownPcValuesArray := Array new: knownPcValues size + 1.
    lastBB := pcToBasicBlockMap at: 1.

    knownPcValues do: [ :each || bb |
	each = lastPC ifFalse: [
	    knownPcValuesArray at: destIndex put: each.
	    bb := pcToBasicBlockMap at: each + 1.

	    bb == lastBB
		ifFalse: [
		    lastBB knownPcValues: (knownPcValuesArray copyFrom: 1 to: destIndex).
		    lastBB := bb.
		    knownPcValuesArray at: 1 put: each.
		    destIndex := 2 ]
		ifTrue: [
		    destIndex := destIndex + 1 ].

	    lastPC := each.
	]
    ].
    knownPcValuesArray at: destIndex put: lastPC.
    lastBB knownPcValues: (knownPcValuesArray copyFrom: 1 to: destIndex).
!

startBasicBlock: class
    self currentBasicBlock: (class new
	    			startpc: pc;
				length: 0;
				knownPcValues: #[0];
				yourself)
!

startBasicBlock: aClass at: destPC
    | currentBB newBB endPC nextBB |
    currentBB := pcToBasicBlockMap at: destPC + 1.
    knownPcValues add: destPC.

    "It may be a forward reference..."
    currentBB isNil
	ifTrue: [ knownBasicBlockStarts add: destPC->aClass. ^self ].

    "How lucky, we already start a basic block there.  We're done."
    currentBB startpc = destPC
	ifTrue: [ ^self ].

    "Nope, we have to split an existing basic block."
    newBB := aClass new
	startpc: destPC;
	yourself.

    currentBB length = 0
	ifFalse: [
	    newBB length: currentBB finalpc - destPC.
	    endPC := currentBB finalpc ].

    currentBB
	length: (self pcValueBefore: destPC) - currentBB startpc.

    "The new basic block might even be the current one."
    newBB length = ((self pcValueBefore: pc) - destPC)
	ifTrue: [
	    self currentBasicBlock: newBB.
	    endPC := pc ]
	ifFalse: [
	    basicBlocks add: newBB after: currentBB ].

    "Also adjust the pc -> bb map."
    destPC + 1 to: endPC + 1 do: [ :i |
        nextBB := pcToBasicBlockMap at: i.
	nextBB isNil ifFalse: [ pcToBasicBlockMap at: i put: newBB ]].
! !

!JavaBytecodeAnalyzer methodsFor: 'initialization'!

initialize
    super initialize.
    nextStartsBasicBlock := false.
    basicBlocks := OrderedCollection new.
    "Put subclasses after superclasses"
    knownBasicBlockStarts :=
	SortedCollection sortBlock: [:a :b | 
	    a key < b key or: [a key = b key and: [b value inheritsFrom: a value]]]
!

javaMethod: aJavaMethod
    javaMethod := aJavaMethod.
    usedLocals := aJavaMethod isStatic
	ifTrue: [ ByteArray new: aJavaMethod maxLocals ]
	ifFalse: [ ByteArray new: aJavaMethod maxLocals - 1 ].

    self addExceptionHandlingBoundaries: aJavaMethod.

    aJavaMethod lines isNil ifFalse: [
        aJavaMethod lines do: [ :each | knownPcValues add: each key ]
    ]
!

stream: aStream
    knownPcValues := SortedCollection new.
    super stream: aStream.
    pcToBasicBlockMap := Array new: aStream size + 1.
    self startBasicBlock: JavaEntryBasicBlock at: 0
! !

!JavaBytecodeAnalyzer class methodsFor: 'interpretation'!

onMethod: aJavaMethod
    ^(super onMethod: aJavaMethod)
	javaMethod: aJavaMethod;
	yourself
! !

!JavaProgramNode methodsFor: 'accessing'!

wordSize
    ^wordSize
!

wordSize: anObject
    wordSize := anObject
! !

!JavaProgramNode methodsFor: 'translating'!

incremented
    ^(JavaMessageSendNode new: 2)
	at: 1 put: self;
	at: 2 put: (JavaConstantNode new wordSize: self wordSize; object: 1);
	wordSize: self wordSize;
	selector: #+;
	yourself
!

emitForEffect: aJavaBasicBlock
!

emitForValue: aJavaBasicBlock
! !

!JavaProgramNode methodsFor: 'testing'!

isLocal
    ^false
!

isSpill
    ^false
! !

!JavaProgramNode class methodsFor: 'translation'!

emitForValue: destinationBasicBlock
! !

!JavaConstantNode methodsFor: 'accessing'!

object
    ^object
!

object: anObject
    object := anObject
! !

!JavaConstantNode methodsFor: 'translating'!

incremented
    ^JavaConstantNode new
	wordSize: self wordSize;
	object: self object + 1;
	yourself
!

emitForValue: aJavaBasicBlock
    aJavaBasicBlock pushLiteral: self object
! !

!JavaConstantNode class methodsFor: 'instance creation'!

object: anObject wordSize: n
    ^self new object: anObject; wordSize: n; yourself
! !

!JavaLocalNode methodsFor: 'accessing'!

id
    ^id
!

id: anObject
    id := anObject
! !

!JavaLocalNode methodsFor: 'translating'!

emitForValue: aJavaBasicBlock
    aJavaBasicBlock pushLocal: self id
! !

!JavaLocalNode methodsFor: 'testing'!

isLocal
    ^true
! !

!JavaLocalNode class methodsFor: 'instance creation'!

id: anIndex wordSize: n
    ^self new id: anIndex; wordSize: n; yourself
! !

!JavaSpillNode methodsFor: 'translating'!

emitForValue: aJavaBasicBlock
    aJavaBasicBlock pushTemporary: self id
! !

!JavaSpillNode methodsFor: 'testing'!

isLocal
    ^false
!

isSpill
    ^true
! !

!JavaArrayNode methodsFor: 'translation'!

emitForEffect: aBasicBlock
    1 to: self size do: [ :index |
	(self at: index) emitForEffect: aBasicBlock ].
!

emitForValue: aBasicBlock
    aBasicBlock
	pushLiteral: Array;
	pushLiteral: self size;
	send: #new: numArgs: 1.

    1 to: self size do: [ :index |
	(self at: index) emitForValue: aBasicBlock.
	aBasicBlock popIntoArray: index - 1 ].
! !

!JavaMessageSendNode methodsFor: 'translating'!

emitForEffect: aJavaBasicBlock
    self emitForValue: aJavaBasicBlock.
    aJavaBasicBlock popStackTop
!

emitForValue: aJavaBasicBlock
    1 to: self size do: [ :each | (self at: each) emitForValue: aJavaBasicBlock ].
    aJavaBasicBlock send: self selector numArgs: self size - 1
! !

!JavaMessageSendNode methodsFor: 'accessing'!

selector
    ^selector
!

selector: anObject
    selector := anObject
! !

!JavaSuperMessageSendNode methodsFor: 'translating'!

emitForValue: aJavaBasicBlock
    1 to: self size do: [ :each | (self at: each) emitForValue: aJavaBasicBlock ].
    aJavaBasicBlock superSend: self selector numArgs: self size - 1
! !

!JavaEntryBasicBlock methodsFor: 'translating'!

translate
    methodTranslator currentEntryBasicBlock: self.
    self translateWith: (JavaBytecodeTranslator onMethod: self javaMethod)
! !

!JavaEntryBasicBlock methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: 'entry point, '.
    self printPcRangeOn: aStream.
    self printBytecodesOn: aStream
! !

!JavaEntryBasicBlock methodsFor: 'accessing'!

exceptionLocal
    ^nil
! !

!JavaExceptionHandlerBasicBlock methodsFor: 'translating'!

prepareStackOf: translator
    translator stackPush: (JavaSpillNode new
			       id: methodTranslator exceptionTemp;
			       wordSize: 1;
			       yourself)
! !

!JavaFinallyHandlerBasicBlock methodsFor: 'accessing'!

exceptionLocal
    ^exceptionLocal
!

exceptionLocal: anObject
    exceptionLocal := anObject
!

initialAStore: local
    self exceptionLocal: local
! !

!JavaFinallyHandlerBasicBlock methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: 'catch-all exception handler, '.
    self exceptionLocal isNil 
	ifFalse: 
		[aStream
			nextPutAll: 'exception in ';
			print: self exceptionLocal;
			nextPutAll: ', '].

    self printPcRangeOn: aStream.
    self printBytecodesOn: aStream
! !

!JavaSubroutineEntryBasicBlock methodsFor: 'translating'!

prepareStackOf: translator
    "Pushing a JavaProgramNode results in no generated code;
     the push was done for real by the JavaJumpToFinallyEdge,
     and since this compiles to an unconditional jump
     bytecode, this is not in violation of the verification
     constraints (unlike in JavaExceptionHandlerBasicBlocks,
     where the JVM's automatic push of the exception must be
     mapped to a store into a temporary."
    translator stackPush: (JavaProgramNode new wordSize: 1; yourself).
! !

!JavaSubroutineEntryBasicBlock methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: 'jsr target, '.
    self returnPoint isNil 
	ifFalse: 
		[aStream
			nextPutAll: 'non-exception return to ';
			print: self returnPoint startpc;
			nextPutAll: ', '].

    self printPcRangeOn: aStream.
    self printBytecodesOn: aStream
! !

!JavaSubroutineEntryBasicBlock methodsFor: 'accessing'!

returnPoint
    ^returnPoint
!

returnPoint: anObject
    returnPoint := anObject
! !

!JavaEdge methodsFor: 'cfg iteration'!

successorsDo: aBlock
    self subclassResponsibility
! !

!JavaEdge methodsFor: 'translation'!

edgeStackBalance
    ^0
!

translateFor: aBasicBlock
    self subclassResponsibility
! !

!JavaEdge methodsFor: 'accessing'!

entryBlock: anObject 
    "Do nothing, present for subclasses"
! !

!JavaGotoEdge methodsFor: 'accessing'!

successor
    ^successor
!

successor: anObject
    successor := anObject
! !

!JavaGotoEdge methodsFor: 'cfg iteration'!

successorsDo: aBlock
    aBlock value: successor
! !

!JavaGotoEdge methodsFor: 'printing'!

printOn: aStream 
    aStream
	nextPutAll: 'goto ';
	print: self successor startpc
! !

!JavaGotoEdge methodsFor: 'translation'!

translateFor: aBasicBlock
    aBasicBlock goto: successor translatedpc
! !

!JavaGotoEdge class methodsFor: 'instance creation'!

successor: successor
    ^self new
	successor: successor
! !

!JavaFallThroughEdge methodsFor: 'printing'!

printOn: aStream 
    aStream
	nextPutAll: 'fall through to ';
	print: self successor startpc
! !

!JavaFallThroughEdge methodsFor: 'translation'!

translateFor: aBasicBlock
    "Do nothing!"
! !

!JavaJumpToFinallyEdge methodsFor: 'accessing'!

entryBlock
    ^entryBlock
!

entryBlock: anObject 
    entryBlock := anObject.

    "This is a very nice point to complete the initialization of the
     JavaSubroutineEntryBasicBlock: try blocks come before
     handlers, so we set the subroutine's return point only if we are in
     the scope of a try block: then the subroutine will come back to our
     fall-through basic block when there will be no exception."
    self successor returnPoint isNil 
	ifTrue: [self successor returnPoint: self returnPoint]
!

exceptionLocal
    ^self entryBlock exceptionLocal
!

returnPoint
    ^returnPoint
!

returnPoint: anObject
    returnPoint := anObject
! !

!JavaJumpToFinallyEdge methodsFor: 'printing'!

printOn: aStream 
    aStream
	nextPutAll: 'jsr ';
	print: self successor startpc.

    self exceptionLocal isNil
	ifTrue: [ aStream nextPutAll: ' fall through to '; print: self returnPoint startpc ]
	ifFalse: [ aStream nextPutAll: ' with exception in '; print: self exceptionLocal ]
! !

!JavaJumpToFinallyEdge methodsFor: 'translation'!

translateFor: aBasicBlock 
    | exceptionLocal |

    "The jump to a `finally' block is actually a jsr.  We mimic it by
     pushing an exception to be thrown at the end of the execution,
     instead of a return address.  Likewise, ret will throw an
     exception instead of jumping to an address (similar to athrow),
     or jump to a single exit-point (the end of the try block) if the
     exception is nil."
    exceptionLocal := self exceptionLocal.
    exceptionLocal isNil
	ifFalse: [aBasicBlock pushLocal: exceptionLocal]
	ifTrue: [aBasicBlock pushLiteral: nil].
    aBasicBlock
	goto: successor translatedpc
! !

!JavaJumpToFinallyEdge methodsFor: 'cfg iteration'!

successorsDo: aBlock
    self exceptionLocal isNil
	ifTrue: [ aBlock value: self returnPoint ]
! !

!JavaJumpToFinallyEdge class methodsFor: 'instance creation'!

successor: destBB returnPoint: fallThroughBB
    ^(self successor: destBB)
	returnPoint: fallThroughBB;
	yourself
! !

!JavaReturnEdge methodsFor: 'cfg iteration'!

successorsDo: aBlock
! !

!JavaReturnEdge methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: 'return'
! !

!JavaReturnEdge methodsFor: 'translation'!

edgeStackBalance
    ^-1
!

translateFor: aBasicBlock
    aBasicBlock return
! !

!JavaReturnEdge class methodsFor: 'singleton'!

soleInstance
    soleInstance isNil ifTrue: [ soleInstance := self basicNew ].
    ^soleInstance
! !

!JavaReturnEdge class methodsFor: 'instance creation'!

new
    self error: 'this class is a singleton, send #soleInstance to instantiate it.'
! !

!JavaThrowExceptionEdge methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: 'throw exception'
! !

!JavaThrowExceptionEdge methodsFor: 'translation'!

translateFor: aBasicBlock
    "Use a return bytecode (instead of a pop) to keep the stack
     balanced, so that the optimizer does not combine anything
     after the throw statement."
    aBasicBlock
	send: #throw numArgs: 0;
	return.
! !

!JavaSwitchStatementEdge methodsFor: 'accessing'!

basicBlocks
    ^basicBlocks
!

basicBlocks: anObject
    basicBlocks := anObject
!

defaultSuccessor
    ^defaultSuccessor
!

defaultSuccessor: anObject
    defaultSuccessor := anObject
!

size
    ^basicBlocks size
!

values
    self subclassResponsibility
!

valuesAt: anIndex
    ^self values at: anIndex
! !

!JavaSwitchStatementEdge methodsFor: 'cfg iteration'!

successorsDo: aBlock
    basicBlocks do: aBlock.
    aBlock value: defaultSuccessor
! !

!JavaSwitchStatementEdge methodsFor: 'printing'!

printOn: aStream
    aStream
	nextPutAll: 'switch ';
	print: (self basicBlocks with: self values collect: [:a :b | b -> a startpc]);
	nextPutAll: ', default ';
	print: self defaultSuccessor startpc
! !

!JavaSwitchStatementEdge methodsFor: 'translation'!

edgeStackBalance
    ^-1
!

nextLabel
    currentLabel = jumpTargets size
	ifTrue: [ jumpTargets addLast: nil ].

    ^currentLabel := currentLabel + 1
!

translateFor: aBasicBlock
    jumpTargets isNil ifTrue: [
	jumpTargets := OrderedCollection new: self size].
    currentLabel := 0.
    self translateFor: aBasicBlock between: 1 and: self size
!

translateFor: aBasicBlock between: low and: high 
    "Check if the recursion has ended."

    | label mid midIndex |
    low >= high 
	ifTrue: 
		[self translateFor: aBasicBlock case: low.
		^self].

    "If not, create the bytecodes for a binary search."
    mid := self valuesAt: (midIndex := (low + high) // 2).
    label := self translateSplitFor: aBasicBlock at: mid.

    "Recursively compile the first half,..."
    self 
	translateFor: aBasicBlock
	between: low
	and: midIndex.

    "... set up the label for the next pass, and recursively compile the second half."
    jumpTargets at: label put: aBasicBlock translatedpc + aBasicBlock size.
    self 
	translateFor: aBasicBlock
	between: midIndex + 1
	and: high
!

translateFor: aBasicBlock case: case 
    "Check if the value is really the one we meant, and if so,
     jump to the case; else, jump to the default label."

    | destPC |
    destPC := (self basicBlocks at: case) translatedpc.
    aBasicBlock
	pushLiteral: (self valuesAt: case);
	send: #= numArgs: 1;
	popJumpIfTrueTo: destPC;
	goto: self defaultSuccessor translatedpc
!

translateSplitFor: aBasicBlock at: mid
    | target label |
    label := self nextLabel.
    "Make sure we do not alter the stack height before making the final decision."
    aBasicBlock
	dupStackTop;
	pushLiteral: mid;
	send: #<= numArgs: 1.
    target := jumpTargets at: label.
    target isNil 
	ifTrue: [aBasicBlock popStackTop]
	ifFalse: [aBasicBlock popJumpIfFalseTo: target].
    ^label
! !

!JavaSwitchStatementEdge class methodsFor: 'instance creation'!

basicBlocks: aCollection defaultSuccessor: defaultSuccessor 
    ^self new
	basicBlocks: aCollection;
	defaultSuccessor: defaultSuccessor;
	yourself
! !

!JavaTableSwitchStatementEdge methodsFor: 'accessing'!

high
    ^low + self basicBlocks size - 1
!

low
    ^low
!

low: anObject
    low := anObject.
    high := low + self basicBlocks size - 1
!

values
    ^self low to: self high
!

valuesAt: anIndex
    ^self low + anIndex - 1
! !

!JavaTableSwitchStatementEdge methodsFor: 'printing'!

printOn: aStream
    aStream nextPutAll: 'table'.
    super printOn: aStream.
! !

!JavaTableSwitchStatementEdge methodsFor: 'translation'!

translateFor: aBasicBlock case: case 
    "For the extrema, add an equality check that jumps to the default label."
    | destPC |
    (case = 1 or: [case = self size]) 
	ifTrue: 
		[super translateFor: aBasicBlock case: case.
		^self].

    "Else we're sure that the values are consecutive: we can jump right to the destination"
    destPC := (self basicBlocks at: case) translatedpc.
    aBasicBlock popStackTop.
    aBasicBlock goto: destPC
! !

!JavaTableSwitchStatementEdge class methodsFor: 'instance creation'!

basicBlocks: aCollection defaultSuccessor: defaultSuccessor low: low
    ^(self basicBlocks: aCollection defaultSuccessor: defaultSuccessor)
	low: low;
	yourself
! !

!JavaLookupSwitchStatementEdge methodsFor: 'accessing'!

values
    ^values
!

values: anObject
    values := anObject
! !

!JavaLookupSwitchStatementEdge methodsFor: 'printing'!

printOn: aStream
    aStream nextPutAll: 'lookup'.
    super printOn: aStream.
! !

!JavaLookupSwitchStatementEdge class methodsFor: 'instance creation'!

basicBlocks: aCollection defaultSuccessor: defaultSuccessor values: values
    ^(self basicBlocks: aCollection defaultSuccessor: defaultSuccessor)
	values: values;
	yourself
! !

!JavaVoidReturnEdge methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: 'return void'
! !

!JavaVoidReturnEdge methodsFor: 'translation'!

edgeStackBalance
    ^0
!

translateFor: aBasicBlock
    aBasicBlock pushSelf; return
! !

!JavaConditionalEdge methodsFor: 'accessing'!

applyComparison: aSymbol
    "Modify the condition (inverting the direction of the jump *and*
     the operator) so that NaNs are properly handled when the
     [fd]cmp[lg] bytecodes are stripped.  fcmpl and dcmpl jump if one 
     of the operands is a NaN and their result is examined with iflt/ifle:
     this is the same as jumping if !(a >= b) or !(a > b) respectively.
     On the other hand, fcmpg and dcmpj jump if one of the operands
     is a NaN and their result is examined with ifgt/ifge: this is
     the same as jumping if !(a <= b) or !(a < b) respectively."

    aSymbol == #javaCmpL:
	ifTrue: [
	    condition == #< ifTrue: [ self negate. condition := #>= ].
	    condition == #<= ifTrue: [ self negate. condition := #> ].
	    ^self ].
    aSymbol == #javaCmpG:
	ifTrue: [
	    condition == #> ifTrue: [ self negate. condition := #<= ].
	    condition == #>= ifTrue: [ self negate. condition := #< ].
	    ^self ].
!

condition
    ^condition
!

condition: anObject
    condition := anObject.

    "These are slow in Smalltalk."
    anObject == #~~ ifTrue: [ self negate. condition := #== ].
    anObject == #~= ifTrue: [ self negate. condition := #= ].
!

negated
    ^negated
!

negate
    negated := negated not
!

negated: aBoolean
    negated := aBoolean
!

successorFalse
    ^successorFalse
!

successorFalse: anObject
    successorFalse := anObject
!

successorTrue
    ^successorTrue
!

successorTrue: anObject
    successorTrue := anObject
! !

!JavaConditionalEdge methodsFor: 'cfg iteration'!

successorsDo: aBlock
    aBlock value: successorTrue.
    aBlock value: successorFalse
! !

!JavaConditionalEdge methodsFor: 'printing'!

printOn: aStream 
    aStream
	nextPutAll: (self negated ifTrue: [ 'if not ' ] ifFalse: [ 'if ' ]);
	nextPutAll: self condition;
	nextPutAll: ' goto ';
	print: self successorTrue startpc;
	nextPutAll: ' else goto ';
	print: self successorFalse startpc
! !

!JavaConditionalEdge methodsFor: 'translation'!

edgeStackBalance
    ^-2
!

translateFor: aBasicBlock
    aBasicBlock send: condition numArgs: 1.
    negated
	ifFalse: [ aBasicBlock popJumpIfTrueTo: successorTrue translatedpc ]
	ifTrue: [ aBasicBlock popJumpIfFalseTo: successorTrue translatedpc ]
    "Else, fall through to successorFalse"
! !

!JavaConditionalEdge class methodsFor: 'instance creation'!

condition: aSelector successorTrue: successorTrue successorFalse: successorFalse
    ^self new
	negated: false;
	condition: aSelector;
	successorTrue: successorTrue;
	successorFalse: successorFalse;
	yourself
! !

!JavaLocalStoreNode methodsFor: 'accessing'!

value
    ^value
!

value: anObject
    value := anObject
! !

!JavaLocalStoreNode methodsFor: 'translating'!

emitForEffect: aJavaBasicBlock
    self emitForValue: aJavaBasicBlock.
    aJavaBasicBlock popStackTop
!

emitForValue: aJavaBasicBlock
    self value emitForValue: aJavaBasicBlock.
    aJavaBasicBlock storeLocal: self id
! !

!JavaLocalStoreNode class methodsFor: 'instance creation'!

id: anIndex value: aNode
    ^self new id: anIndex; value: aNode; wordSize: aNode wordSize; yourself
! !

!JavaSubroutineReturnEdge methodsFor: 'printing'!

printOn: aStream 
    aStream
	nextPutAll: 'return from subroutine '
! !

!JavaSubroutineReturnEdge methodsFor: 'translation'!

entryBlock: aBasicBlock
    "This is a nice place to get the basic block to which we return, because
     it has already been set in the JavaSubroutineEntryBasicBlock by
     the JavaJumpToFinallyEdge in the method's main flow of execution."
    self successor: aBasicBlock returnPoint
!

translateFor: aBasicBlock
    aBasicBlock
	pushLocal: exceptionLocal;
	send: #isNil numArgs: 0;
	popJumpIfTrueTo: self successor translatedpc;
	pushLocal: exceptionLocal;
	send: #throw numArgs: 0;
	return.
! !

!JavaSubroutineReturnEdge methodsFor: 'accessing'!

exceptionLocal
    ^exceptionLocal
!

exceptionLocal: anObject
    exceptionLocal := anObject
! !

!JavaSubroutineReturnEdge methodsFor: 'cfg iteration'!

successorsDo: aBlock
! !

!JavaSubroutineReturnEdge class methodsFor: 'instance creation'!

exceptionLocal: exceptionLocal
    ^self new
	exceptionLocal: exceptionLocal
! !

!TargetInstructionPrinter methodsFor: 'printing'!

bytecodeIndex: byte
    "Private - Print the bytecode index for byte"

    | s |
    s := (byte + base) printString.
    stream
        space: 5 - s size;
        nextPut: $[;
        nextPutAll: s;
        nextPut: $].
!

dupStackTop
    stream tab; nextPutAll: 'dup stack top'; nl
!

exitInterpreter
    stream tab; nextPutAll: 'exit interpreter'; nl
!

invalidOpcode
    stream tab; nextPutAll: 'invalid opcode'; nl
!

jumpTo: destination
    stream tab; nextPutAll: 'jump to '; print: (base + destination); nl
!

lineNo: n
    stream tab; nextPutAll: 'source code line number '; print: n; nl
!

makeDirtyBlock
    stream tab; nextPutAll: 'make dirty block'; nl
!

popIntoArray: anIndex
    stream tab; nextPutAll: ('pop and store into array element[%1]' % { anIndex }); nl
!

popJumpIfFalseTo: destination
    stream tab; nextPutAll: 'pop and if false jump to '; print: (base + destination); nl
!

popJumpIfTrueTo: destination
    stream tab; nextPutAll: 'pop and if true jump to '; print: (base + destination); nl
!

popStackTop
    stream tab; nextPutAll: 'pop stack top'; nl
!

printOn: aStream 
    "Disassemble the bytecodes and tell self about them in the form
     of message sends.  param is given as an argument to every message
     send."

    | lastOfs |
    stream := aStream.
    lastOfs := -1.
    self allByteCodeIndicesDo: [:i :byte :arg | 
	lastOfs = i 
	    ifFalse: 
		[self bytecodeIndex: i.
		lastOfs := i].
	self 
	    dispatchByte: byte
	    with: arg
	    at: i].
    stream := nil
!

pushGlobal: anObject
    stream tab; nextPutAll: 'push Global Variable '; print: anObject; nl
!

pushInstVar: anIndex
    stream tab; nextPutAll: ('push Instance Variable[%1]' % { anIndex }); nl
!

pushLiteral: anObject
    | printString |
    printString := [ anObject printString ] on: Error do: [ :ex | ex return: nil ].
    (printString isNil or: [ printString size > 40 ]) ifTrue: [
        printString := anObject isClass
	    ifTrue: [ anObject name displayString ]
	    ifFalse: [ '%1 %2' % { anObject class article. anObject class name } ]].

    stream tab; nextPutAll: 'push '; nextPutAll: printString; nl
!

pushSelf
    stream tab; nextPutAll: 'push self'; nl
!

pushTemporary: anIndex
    stream tab; nextPutAll: ('push Temporary[%1]' % { anIndex }); nl
!

pushTemporary: anIndex outer: scopes
    stream tab; nextPutAll: ('push Temporary[%1] from outer context #%2' % { anIndex. scopes }); nl
!

returnFromContext
    stream tab; nextPutAll: 'return stack top'; nl
!

returnFromMethod
    stream tab; nextPutAll: 'return from method'; nl
!

send: aSymbol numArgs: anInteger
    stream tab; nextPutAll: ('send %2 args message %1' % { aSymbol storeString. anInteger }); nl
!

storeGlobal: anObject
    stream tab; nextPutAll: 'store into Global Variable '; print: anObject; nl
!

storeInstVar: anIndex
    stream tab; nextPutAll: ('store into Instance Variable[%1]' % { anIndex }); nl
!

storeTemporary: anIndex
    stream tab; nextPutAll: ('store into Temporary[%1]' % { anIndex }); nl
!

storeTemporary: anIndex outer: scopes
    stream tab; nextPutAll: ('store into Temporary[%1] from outer context #%2' % { anIndex. scopes }); nl
!

superSend: aSymbol numArgs: anInteger
    stream tab; nextPutAll: ('send %2 args message %1 to super' % { aSymbol. anInteger }); nl
! !

!TargetInstructionPrinter methodsFor: 'decoding bytecodes'!

dispatchByte: byte with: operand at: anIndex
    "Private - Print the byte bytecode (starting at anIndex) on param"

    byte <= 26 ifTrue: [ ^self dispatchSend: 30 with: byte ].
    byte < 32 ifTrue: [ ^self dispatchSend: byte with: operand ].
    byte < 40 ifTrue: [ ^self dispatchVariableOp: byte with: operand ].
    byte < 44 ifTrue: [ ^self dispatchJump: byte at: anIndex ].
    byte < 48 ifTrue: [ ^self dispatchOtherStack: byte with: operand ].
    byte < 54 ifTrue: [ ^self dispatchOneByte: byte ].
    byte = 54 ifTrue: [ ^self lineNo: operand ].
    byte = 56 ifTrue: [ ^self pushSelf ].
    ^self invalidOpcode
!

dispatchJump: byte at: anIndex
    | destination |
    destination := self jumpDestinationAt: anIndex.

    byte < 42 ifTrue: [ ^self jumpTo: destination ].
    byte = 42 ifTrue: [ ^self popJumpIfTrueTo: destination ].
    byte = 43 ifTrue: [ ^self popJumpIfFalseTo: destination ].
!

dispatchOneByte: byte
    byte == 48 ifTrue: [ ^self popStackTop ].
    byte == 49 ifTrue: [ ^self makeDirtyBlock ].
    byte == 50 ifTrue: [ ^self returnFromMethod ].
    byte == 51 ifTrue: [ ^self returnFromContext ].
    byte == 52 ifTrue: [ ^self dupStackTop ].
    byte == 53 ifTrue: [ ^self exitInterpreter ].
!

dispatchOtherStack: byte with: operand
    byte = 44 ifTrue: [ ^self pushLiteral: operand ].
    byte = 46 ifTrue: [ ^self pushLiteral: (literals at: operand + 1) ].
    byte = 47 ifTrue: [ ^self popIntoArray: operand ].
    operand = 0 ifTrue: [ ^self pushLiteral: nil ].
    operand = 1 ifTrue: [ ^self pushLiteral: true ].
    operand = 2 ifTrue: [ ^self pushLiteral: false ].
    ^self invalidOpcode
!

dispatchSend: byte with: operand
    byte = 28 ifTrue: [
        ^self
	    send: (literals at: operand // 256 + 1)
	    numArgs: operand \\ 256
    ].
    byte = 29 ifTrue: [
        ^self
            superSend: (literals at: operand // 256 + 1)
            numArgs: operand \\ 256
    ].
    byte = 30 ifTrue: [
        ^self
            send: (CompiledCode specialSelectors at: operand + 1)
            numArgs: (CompiledCode specialSelectorsNumArgs at: operand + 1)
    ].
    byte = 31 ifTrue: [
        ^self
            superSend: (CompiledCode specialSelectors at: operand + 1)
            numArgs: (CompiledCode specialSelectorsNumArgs at: operand + 1)
    ].
    ^self invalidOpcode
!

dispatchVariableOp: byte with: operand
    byte = 32 ifTrue:
	[ ^self pushTemporary: operand ].
    byte = 33 ifTrue:
	[ ^self pushTemporary: (operand // 256) outer: (operand \\ 256) ].
    byte = 34 ifTrue:
	[ ^self pushGlobal: (literals at: operand + 1) ].
    byte = 35 ifTrue:
	[ ^self pushInstVar: operand ].
    byte = 36 ifTrue:
	[ ^self storeTemporary: operand ].
    byte = 37 ifTrue:
	[ ^self storeTemporary: (operand // 256) outer: (operand \\ 256) ].
    byte = 38 ifTrue:
	[ ^self storeGlobal: (literals at: operand + 1) ].
    byte = 39 ifTrue:
	[ ^self storeInstVar: operand ]
! !

!TargetInstructionPrinter methodsFor: 'accessing'!

base
    ^base
!

base: anObject
    base := anObject - 1.
!

bytecodes
    ^bytecodes
!

bytecodes: anObject
    bytecodes := anObject
!

literals
    ^literals
!

literals: anObject
    literals := anObject
! !

!TargetInstructionPrinter methodsFor: 'private'!

allByteCodeIndicesDo: aBlock
    "Private - Evaluate aBlock passing each of the index where a
     new bytecode instruction starts"

    | i byte operand ofs |
    i := 1.
    [ i <= bytecodes size ] whileTrue: [
        ofs := i.
        operand := 0.
        [
            byte := bytecodes at: i.
            operand := operand * 256 + (bytecodes at: i + 1).
            i := i + 2.
            byte = 55 
        ] whileTrue.

        aBlock
            value: ofs
            value: byte
            value: operand
    ]
!

jumpDestinationAt: anIndex
    "Answer where the jump at bytecode index `anIndex' lands"
    | result ofs byte |
    ofs := anIndex.
    [ anIndex > 2 and: [ (bytecodes at: ofs - 2) = 55 ] ]
    whileTrue: [ ofs := ofs - 2 ].

    result := 0.
    [ result := result * 256 + (bytecodes at: ofs + 1).
      byte := bytecodes at: ofs.
      ofs := ofs + 2.
      byte = 55 ] whileTrue.

    ^byte = 40
        ifTrue: [ ofs - result ]
        ifFalse: [ ofs + result ].
! !

!TargetInstructionPrinter class methodsFor: 'printing'!

print: bytecodes literals: literals base: anInteger on: aStream
    self new
	bytecodes: bytecodes;
	literals: literals;
	base: (anInteger isNil ifTrue: [0] ifFalse: [anInteger]);
	printOn: aStream
!

print: bytecodes literals: literals on: aStream 
    self 
	print: bytecodes
	literals: literals
	base: 0
	on: aStream
! !

JavaBasicBlock initialize!
PK
     �Mh@ ���)  �)    java_lang_Class.stUT	 dqXOd�XOux �  �  "======================================================================
|
|   Java run-time support.  java.lang.Class native methods.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2003 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of GNU Smalltalk.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU General Public License
| as published by the Free Software Foundation; either version 2, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
| Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.  If not,
| write to the Free Software Foundation, 51 Franklin Street, Fifth Floor,
| Boston, MA 02110-1301, USA.  
|
 ======================================================================"


!JavaVM methodsFor: 'java.lang.Class'!

convertJavaLangClassToJavaClass
    <javaNativeMethod: #asJavaClass
        for: #{Java.java.lang.Class} static: false>
    ^instVar1 javaClass
!

convertJavaLangClassToJavaType
    <javaNativeMethod: #asJavaType
        for: #{Java.java.lang.Class} static: false>
    ^instVar1
!

convertJavaLangClassToSmalltalkClass
    <javaNativeMethod: #asSmalltalkClass
        for: #{Java.java.lang.Class} static: false>
    ^instVar1 javaClass asSmalltalkClass
!

associateJavaLangClass: aJavaClass
    <javaNativeMethod: #javaClass:
        for: #{Java.java.lang.Class} static: false>
    instVar1 := JavaObjectType javaClass: aJavaClass
!

associateJavaType: aJavaType
    <javaNativeMethod: #javaType:
        for: #{Java.java.lang.Class} static: false>
    instVar1 := aJavaType
!

java_lang_Class_forName_java_lang_String: arg1
    | path |
    <javaNativeMethod: #'forName(Ljava/lang/String;)Ljava/lang/Class;'
        for: #{Java.java.lang.Class} static: true>
    path := arg1 asString copyReplacing: $. withObject: $/.
    ^(JavaClass fromString: path) asSmalltalkClass javaLangClass
!

java_lang_Class_forName_java_lang_String: arg1 boolean: arg2 java_lang_ClassLoader: arg3
    <javaNativeMethod: #'forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;'
        for: #{Java.java.lang.Class} static: true>
    self notYetImplemented
!

java_lang_Class_getClasses
    <javaNativeMethod: #'getClasses()[Ljava/lang/Class;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getClassLoader
    <javaNativeMethod: #'getClassLoader()Ljava/lang/ClassLoader;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getComponentType
    <javaNativeMethod: #'getComponentType()Ljava/lang/Class;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getConstructor_java_lang_ClassArray: arg1
    <javaNativeMethod: #'getConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class__getConstructors_boolean: arg1
    <javaNativeMethod: #'_getConstructors(Z)[Ljava/lang/reflect/Constructor;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getDeclaredConstructor_java_lang_ClassArray: arg1
    <javaNativeMethod: #'getDeclaredConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getDeclaredClasses
    <javaNativeMethod: #'getDeclaredClasses()[Ljava/lang/Class;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getDeclaredField_java_lang_String: arg1
    <javaNativeMethod: #'getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getDeclaredFields
    <javaNativeMethod: #'getDeclaredFields()[Ljava/lang/reflect/Field;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class__getDeclaredMethod_java_lang_String: arg1 java_lang_ClassArray: arg2
    <javaNativeMethod: #'_getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getDeclaredMethods
    <javaNativeMethod: #'getDeclaredMethods()[Ljava/lang/reflect/Method;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getDeclaringClass
    <javaNativeMethod: #'getDeclaringClass()Ljava/lang/Class;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getField_java_lang_String: arg1 int: arg2
    <javaNativeMethod: #'getField(Ljava/lang/String;I)Ljava/lang/reflect/Field;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class__getFields_java_lang_reflect_FieldArray: arg1 int: arg2
    <javaNativeMethod: #'_getFields([Ljava/lang/reflect/Field;I)[Ljava/lang/reflect/Field;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getFields
    <javaNativeMethod: #'getFields()[Ljava/lang/reflect/Field;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getInterfaces
    <javaNativeMethod: #'getInterfaces()[Ljava/lang/Class;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getSignature_java_lang_StringBuffer: arg1
    <javaNativeMethod: #'getSignature(Ljava/lang/StringBuffer;)V'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getSignature_java_lang_ClassArray: arg1 boolean: arg2
    <javaNativeMethod: #'getSignature([Ljava/lang/Class;Z)Ljava/lang/String;'
        for: #{Java.java.lang.Class} static: true>
    self notYetImplemented
!

java_lang_Class__getMethod_java_lang_String: arg1 java_lang_ClassArray: arg2
    <javaNativeMethod: #'_getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class__getMethods_java_lang_reflect_MethodArray: arg1 int: arg2
    <javaNativeMethod: #'_getMethods([Ljava/lang/reflect/Method;I)I'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getMethods
    <javaNativeMethod: #'getMethods()[Ljava/lang/reflect/Method;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getModifiers
    <javaNativeMethod: #'getModifiers()I'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_getName
    <javaNativeMethod: #'getName()Ljava/lang/String;'
        for: #{Java.java.lang.Class} static: false>
    ^self asSmalltalkClass name asJavaString
!

java_lang_Class_getSuperclass
    <javaNativeMethod: #'getSuperclass()Ljava/lang/Class;'
        for: #{Java.java.lang.Class} static: false>
    ^self asSmalltalkClass superclass javaLangClass
!

java_lang_Class_isArray
    <javaNativeMethod: #'isArray()Z'
        for: #{Java.java.lang.Class} static: false>
    ^0 "FIXME"
!

java_lang_Class_isAssignableFrom_java_lang_Class: arg1
    | isAssignable type1 type2 |
    <javaNativeMethod: #'isAssignableFrom(Ljava/lang/Class;)Z'
        for: #{Java.java.lang.Class} static: false>

    "Go inside array types."
    type1 := self javaType.
    type2 := arg1 javaType.
    [
	"A type is always assignable from itself."
	self == arg1 ifTrue: [ ^1 ].

	"Trivial case: one is primitive, the other is not."
	type1 isPrimitiveType ifTrue: [ ^0 ].
	type2 isPrimitiveType ifTrue: [ ^0 ].

	type1 isArrayType == type2 isArrayType ifFalse: [ ^0 ].
	type1 isArrayType ] whileTrue: [
	    type1 := type1 subType.
	    type2 := type2 subType ].

    isAssignable := type1 javaClass isInterface
    	ifTrue: [ type1 javaClass implementsInterface: type2 javaClass ]
    	ifFalse: [ type1 javaClass inheritsFrom: type2 javaClass ].

    ^isAssignable ifTrue: [ 1 ] ifFalse: [ 0 ]
!

java_lang_Class_isInstance_java_lang_Object: arg1
    | isInstance |
    <javaNativeMethod: #'isInstance(Ljava/lang/Object;)Z'
        for: #{Java.java.lang.Class} static: false>
    (arg1 class inheritsFrom: JavaObject)
	ifTrue: [ ^self isAssignableFrom: arg1 javaLangClass ].

    self javaType isArrayType ifFalse: [ ^0 ].

    isInstance := false.
    arg1 class == Array ifTrue: [
	isInstance := self javaType subType isPrimitiveType not ].
    arg1 class == JavaByteArray ifTrue: [
	isInstance := self javaType subType == JavaPrimitiveType byte ].
    arg1 class == JavaShortArray ifTrue: [
	isInstance := self javaType subType == JavaPrimitiveType short ].
    arg1 class == JavaIntArray ifTrue: [
	isInstance := self javaType subType == JavaPrimitiveType int ].
    arg1 class == JavaLongArray ifTrue: [
	isInstance := self javaType subType == JavaPrimitiveType long ].
    arg1 class == JavaFloatArray ifTrue: [
	isInstance := self javaType subType == JavaPrimitiveType float ].
    arg1 class == JavaDoubleArray ifTrue: [
	isInstance := self javaType subType == JavaPrimitiveType double ].
    arg1 class == ByteArray ifTrue: [
	isInstance := self javaType subType == JavaPrimitiveType boolean ].
    ^isInstance ifTrue: [ 1 ] ifFalse: [ 0 ]
!

java_lang_Class_isInterface
    <javaNativeMethod: #'isInterface()Z'
        for: #{Java.java.lang.Class} static: false>
    ^self javaClass isInterface
!

java_lang_Class_isPrimitive
    <javaNativeMethod: #'isPrimitive()Z'
        for: #{Java.java.lang.Class} static: false>
    ^self javaType isPrimitiveType
!

java_lang_Class_newInstance
    <javaNativeMethod: #'newInstance()Ljava/lang/Object;'
        for: #{Java.java.lang.Class} static: false>
    ^self asSmalltalkClass new
    	perform: #'<init>()V';
	yourself
!

java_lang_Class_getProtectionDomain0
    <javaNativeMethod: #'getProtectionDomain0()Ljava/security/ProtectionDomain;'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
!

java_lang_Class_initializeClass
    <javaNativeMethod: #'initializeClass()V'
        for: #{Java.java.lang.Class} static: false>
    self notYetImplemented
! !

PK
     �Mh@�1[Y  Y            ��    java_net_InetAddress.stUT dqXOux �  �  PK
     �Mh@��
  �
            ���  java_lang_System.stUT dqXOux �  �  PK
     �Mh@�ʢ  �             ���  java_nio_DirectByteBufferImpl.stUT dqXOux �  �  PK
     �Mh@���
  �
            ���  java_lang_Float.stUT dqXOux �  �  PK
     �Mh@�HD��	  �	            ���'  java_lang_Object.stUT dqXOux �  �  PK
     �Mh@&�N�  �            ���1  gnu_gcj_convert_IOConverter.stUT dqXOux �  �  PK
     �Mh@x/���  �            ���7  gnu_gcj_runtime_StringBuffer.stUT dqXOux �  �  PK
     �Mh@����  �            ���@  java_lang_ConcreteProcess.stUT dqXOux �  �  PK
     �Mh@jc  c  $          ���H  java_nio_channels_FileChannelImpl.stUT dqXOux �  �  PK
     �Mh@Bd�  �             ��OY  java_lang_reflect_Constructor.stUT dqXOux �  �  PK
     �Mh@-iWx�  �            ��-a  gnu_java_nio_FileLockImpl.stUT dqXOux �  �  PK    �Mh@f,��  P           ��Vg  extract-native.awkUT dqXOux �  �  PK
     �Mh@��=��  �            ���j  java_lang_Math.stUT dqXOux �  �  PK
     �Mh@)qLc#  #            ���x  JavaExtensions.stUT dqXOux �  �  PK
     �Mh@F{              ���  java_text_Collator.stUT dqXOux �  �  PK
     �Mh@%:{J              ��g�  test.stUT dqXOux �  �  PK
     �Mh@�g `  `            ����  gnu_gcj_runtime_StackTrace.stUT dqXOux �  �  PK
     �Mh@h@�&�% �%           ��f�  JavaMetaobjects.stUT dqXOux �  �  PK
     �Mh@ ̵_�  �            ��O� Java.stUT dqXOux �  �  PK
     V[h@��M�  �            ��n� package.xmlUT d�XOux �  �  PK
     �Mh@���݆  �            ��P� java_lang_Character.stUT dqXOux �  �  PK
     �Mh@����  �  '          ��& gnu_java_net_PlainDatagramSocketImpl.stUT dqXOux �  �  PK
     �Mh@�Eq��  �            �� java_lang_Thread.stUT dqXOux �  �  PK
     �Mh@�͉�              ��#- java_io_VMObjectStreamClass.stUT dqXOux �  �  PK
     �Mh@�Įq-  -            ���3 java_lang_reflect_Method.stUT dqXOux �  �  PK
     �Mh@��:�  �            ��< java_lang_ref_Reference.stUT dqXOux �  �  PK
     �Mh@���  �            ��NB java_lang_Runtime.stUT dqXOux �  �  PK
     �Mh@��+��  �            ���Y java_util_zip_Inflater.stUT dqXOux �  �  PK
     �Mh@�]>;              ���e java_util_zip_Deflater.stUT dqXOux �  �  PK
     �Mh@�p7�z  �z            ��>s JavaClassFiles.stUT dqXOux �  �  PK
     �Mh@P5���  �            ��=� JavaRuntime.stUT dqXOux �  �  PK
     �Mh@�[��  �            ���w java_util_TimeZone.stUT dqXOux �  �  PK
     �Mh@��r�y  y            ���} java_lang_reflect_Proxy.stUT dqXOux �  �  PK
     �Mh@���r�  �            ��}� java_net_NetworkInterface.stUT dqXOux �  �  PK    �Mh@�~�F�   j  	         ��ь ChangeLogUT dqXOux �  �  PK
     �Mh@R����  �            ��� java_lang_reflect_Field.stUT dqXOux �  �  PK
     �Mh@Q��6  6            ��� java_lang_Double.stUT dqXOux �  �  PK
     �Mh@C���e(  e(            ���� java_lang_reflect_Array.stUT dqXOux �  �  PK
     �Mh@��~�)  )            ��M� java_io_File.stUT dqXOux �  �  PK
     �Mh@$e��              ���� java_io_ObjectInputStream.stUT dqXOux �  �  PK
     �Mh@7���p  p            ��,� gnu_java_net_PlainSocketImpl.stUT dqXOux �  �  PK
     �Mh@����  �            ��� java_lang_VMClassLoader.stUT dqXOux �  �  PK
     �Mh@89mN:  :            ��� java_lang_String.stUT dqXOux �  �  PK
     �Mh@W��[  [            ��=I java_lang_StringBuffer.stUT dqXOux �  �  PK
     �Mh@���R�  �            ���Q java_util_ResourceBundle.stUT dqXOux �  �  PK
     �Mh@�k�O              ��8X gnu_java_nio_SelectorImpl.stUT dqXOux �  �  PK
     �Mh@���  �            ���^ java_io_FileDescriptor.stUT dqXOux �  �  PK
     �Mh@*h�Y~p ~p           ���t JavaTranslation.stUT dqXOux �  �  PK
     �Mh@ ���)  �)            ��Q� java_lang_Class.stUT dqXOux �  �  PK    1 1 �  e   