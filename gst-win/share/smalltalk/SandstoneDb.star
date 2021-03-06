PK
     �[h@�Q�=      package.xmlUT	 ��XO��XOux �  �  <package>
  <name>SandstoneDb</name>
  <namespace>SandstoneDb</namespace>
  <test>
    <namespace>SandstoneDb</namespace>
    <prereq>SandstoneDb</prereq>
    <prereq>SUnit</prereq>
    <sunit>
      SandstoneDb.SDFileStoreTest
      SandstoneDb.SDMemoryStoreTest
    </sunit>
  
    <filein>Tests/Extensions.st</filein>
    <filein>Tests/SDPersonMock.st</filein>
    <filein>Tests/SDManMock.st</filein>
    <filein>Tests/SDWomanMock.st</filein>
    <filein>Tests/SDChildMock.st</filein>
    <filein>Tests/SDGrandChildMock.st</filein>
    <filein>Tests/FooObject.st</filein>
    <filein>Tests/SDActiveRecordTest.st</filein>
    <filein>Tests/SDMemoryStoreTest.st</filein>
    <filein>Tests/SDFileStoreTest.st</filein>
  </test>
  <prereq>ObjectDumper</prereq>

  <filein>Core/Extensions.st</filein>
  <filein>Core/SDRecordMarker.st</filein>
  <filein>Core/SDAbstractStore.st</filein>
  <filein>Core/SDCachedStore.st</filein>
  <filein>Store/SDFileStore.st</filein>
  <filein>Store/SDMemoryStore.st</filein>
  <filein>Core/SDConcurrentDictionary.st</filein>
  <filein>Core/UUID.st</filein>
  <filein>Core/SDCheckPointer.st</filein>
  <filein>Core/SDActiveRecord.st</filein>
  <filein>Core/SDError.st</filein>
  <filein>Core/SDLoadError.st</filein>
  <filein>Core/SDCommitError.st</filein>
</package>PK
     �[h@              Tests/UT	 ��XO��XOux �  �  PK
     �Mh@�D��P  P    Tests/SDMemoryStoreTest.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDMemoryStoreTest class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



SDActiveRecordTest subclass: SDMemoryStoreTest [
    
    <comment: nil>
    <category: 'SandstoneDb-Tests'>

    SDMemoryStoreTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    defaultStore [
	<category: 'defaults'>
	^SDMemoryStore new
    ]
]

PK
     �Mh@|wF�/  /    Tests/SDActiveRecordTest.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDActiveRecordTest class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



TestCase subclass: SDActiveRecordTest [
    | mom kid store |
    
    <comment: 'Part of the reason I did this project was to force myself to
    learn to do more unit testing.  I''m starting to learn to like it.'>
    <category: 'SandstoneDb-Tests'>

    SDActiveRecordTest class >> isAbstract [
	<category: 'testing'>
	^true
    ]

    defaultStore [
	<category: 'running'>
	self subclassResponsibility
    ]

    flushAndReload [
	<category: 'running'>
	SDPersonMock
	    coolDown;
	    warmUp
    ]

    setUp [
	<category: 'running'>
	store := self defaultStore.
	SDPersonMock setStore: store.
	SDPersonMock warmUp.
	FooObject warmUp.
	SDPersonMock allSubclassesDo: [:each | each warmUp].
	mom := SDPersonMock testPerson.
	kid := SDPersonMock testPerson
    ]

    tearDown [
	<category: 'running'>
	SDPersonMock do: [:each | each delete].
	SDPersonMock coolDown.
	FooObject do: [:each | each delete].
	SDPersonMock allSubclassesDo: [:each | each coolDown].
	ObjectMemory compact
    ]

    testAbort [
	<category: 'running'>
	kid name: 'Joe'.
	kid save.
	kid name: 'Mary'.
	self assert: kid name = 'Mary'.
	kid abortChanges.
	self assert: kid name = 'Joe'
    ]

    testArraySerialization [
	<category: 'running'>
	kid save.
	mom children: {kid}.
	mom save.
	self flushAndReload.
	self assert: (mom refreshed children includes: kid refreshed)
    ]

    testAtIdSubclasses [
	<category: 'running'>
	| man woman |
	man := SDManMock testPerson save.
	woman := SDWomanMock testPerson save.
	mom save.
	self assert: (SDPersonMock atId: mom id) = mom.
	self assert: (SDPersonMock atId: man id) = man.
	self assert: (SDPersonMock atId: woman id) = woman.
	man delete.
	woman delete
    ]

    testBagSerialization [
	<category: 'running'>
	kid save.
	mom children: (Bag with: kid).
	mom save.
	self flushAndReload.
	self assert: (mom refreshed children includes: kid refreshed)
    ]

    testBigSave [
	<category: 'running'>
	| commitTime people deleteTime lookupTime |
	people := (1 to: 50) collect: [:it | SDPersonMock testPerson].
	commitTime := Time millisecondsToRun: [people do: [:each | each save]].
	lookupTime := Time millisecondsToRun: [people do: [:each | SDPersonMock atId: each id]].
	deleteTime := Time millisecondsToRun: [people do: [:each | each delete]].
	"Transcript
	    show: commitTime printString;
	    cr;
	    show: deleteTime printString;
	    cr;
	    show: lookupTime printString;
	    cr;
	    cr."
    ]

    testCollectionSerialization [
	<category: 'running'>
	kid save.
	mom children: (OrderedCollection with: kid).
	mom save.
	self flushAndReload.
	self assert: (mom refreshed children includes: kid refreshed)
    ]

    testCreatedOn [
	<category: 'running'>
	kid save.
	self assert: kid createdOn <= DateTime now
    ]

    testDeepCopy [
	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	 at which point the copying stops, and the actual references is returned."

	<category: 'running'>
	| copy obj |
	kid save.
	mom save.
	kid buddy: #not -> (#deeper -> mom).
	obj := Object new.
	kid father: obj.
	copy := kid sandstoneDeepCopy.
	self assert: copy buddy value value == mom.
	self deny: copy father == obj
    ]

    testDelete [
	<category: 'running'>
	kid save.
	self deny: kid isNew.
	self assert: kid version equals: 1.
	kid delete.
	self assert: kid isNew.
	self assert: kid version equals: 0.
	self flushAndReload.
	self assert: (SDPersonMock find: [:each | each id = kid id]) isNil
    ]

    testDeleteAndFind [
	<category: 'running'>
	kid name: 'zorgle'.
	kid save.
	self deny: kid isNew.
	kid delete.
	self assert: (SDPersonMock find: [:e | e name = 'zorgle']) isNil
    ]

    testDeleteSubclass [
	<category: 'running'>
	kid := SDManMock testPerson save.
	self deny: kid isNew.
	self assert: kid version equals: 1.
	kid delete.
	self assert: kid isNew.
	self assert: kid version equals: 0.
	self flushAndReload.
	self assert: (SDManMock find: [:each | each id = kid id]) isNil
    ]

    testDictionarySerialization [
	<category: 'running'>
	kid save.
	mom children: (Dictionary with: #son -> kid).
	mom save.
	self flushAndReload.
	self assert: (mom refreshed children at: #son) equals: kid refreshed
    ]

    testEquality [
	<category: 'running'>
	mom save.
	kid mother: mom.
	kid save.
	self flushAndReload.
	self assert: kid refreshed mother equals: mom refreshed
    ]

    testFind [
	<category: 'running'>
	kid save.
	self flushAndReload.
	self deny: (SDPersonMock find: [:each | each id = kid id]) isNil.
	self assert: (SDPersonMock find: [:each | each id = 'not']) isNil
    ]

    testFindAll [
	<category: 'running'>
	kid save.
	self flushAndReload.
	self assert: (SDPersonMock findAll class = Array).
	self assert: (SDPersonMock findAll: [:each | each id = 'not' ]) class = Array.
    ]

    testFindAllSubclasses [
	<category: 'running'>
	|man woman child grandchild |
	man := SDManMock testPerson save.
	woman := SDWomanMock testPerson save.
	child := SDChildMock testPerson save.
	grandchild := SDGrandChildMock testPerson save.
	mom save.
	self
	    assert: 5
	    equals: SDPersonMock findAll size.
	self assert: (SDPersonMock findAll contains: [:e | e class = SDManMock]).
	self
	    assert: 1
	    equals: SDManMock findAll size.
	self
	    assert: 2
	    equals: SDChildMock findAll size.
	self
	    assert: 1
	    equals: SDGrandChildMock findAll size.
	man delete.
	woman delete.
	child delete.
	grandchild delete
    ]

    testFindById [
	<category: 'running'>
	kid save.
	self deny: (SDPersonMock atId: kid id) isNil
    ]

    testFindIdentity [
	<category: 'running'>
	mom save.
	self flushAndReload.
	self assert: (SDPersonMock atId: mom id) = (SDPersonMock atId: mom id)
    ]

    testFindSubclasses [
	<category: 'running'>
	| man woman child grandchild |
	man := SDManMock testPerson save.
	woman := SDWomanMock testPerson save.
	child := SDChildMock testPerson save.
	grandchild := SDGrandChildMock testPerson save.
	self assert: man = (SDPersonMock find: [:e | e id = man id]).
	self assert: woman= (SDPersonMock find: [:e | e id = woman id]).
	self assert: child = (SDPersonMock find: [:e | e id = child id]).
	self assert: grandchild = (SDPersonMock find: [:e | e id = grandchild id]).
	man delete.
	woman delete.
	child delete.
	grandchild delete
    ]

    testIdentity [
	<category: 'running'>
	mom save.
	kid mother: mom.
	kid save.
	self flushAndReload.
	self assert: kid refreshed mother == mom refreshed
    ]

    testIsNew [
	<category: 'running'>
	self assert: kid isNew.
	kid save.
	self deny: kid isNew.
	kid delete.
	self assert: kid isNew
    ]

    testMarkReferences [
	<category: 'running'>
	kid mother: mom.
	mom save.
	kid sandstoneMarkReferences.
	self assert: (kid mother isKindOf: SDRecordMarker)
    ]

    testMarkReferencesCopies [
	<category: 'running'>
	kid save.
	mom children: {kid}.
	mom save.
	self assert: mom children first == kid
    ]

    testMarkReferencesRecursive [
	<category: 'running'>
	kid buddy: #not -> mom.
	mom save.
	kid sandstoneMarkReferences.
	self assert: (kid buddy value isKindOf: SDRecordMarker)
    ]

    testMarkReferencesRecursiveDeeper [
	<category: 'running'>
	kid buddy: #not -> (#deeper -> mom).
	mom save.
	kid sandstoneMarkReferences.
	self assert: (kid buddy value value isKindOf: SDRecordMarker)
    ]

    testMarkReferencesRecursiveDeeperInCollection [
	<category: 'running'>
	kid buddy: #not -> {#deeper -> mom}.
	mom save.
	kid sandstoneMarkReferences.
	self assert: (kid buddy value first value isKindOf: SDRecordMarker)
    ]

    testMarkReferencesRecursiveDeeperInDictionary [
	<category: 'running'>
	kid buddy: #not -> {Dictionary with: #deeper -> mom}.
	mom save.
	kid sandstoneMarkReferences.
	self 
	    assert: ((kid buddy value first at: #deeper) isKindOf: SDRecordMarker)
    ]

    testMarkReferencesRecursiveDeeperNestedList [
	<category: 'running'>
	kid buddy: #not -> (Array with: (Array with: mom)).
	mom save.
	kid sandstoneMarkReferences.
	self assert: (kid buddy value first first isKindOf: SDRecordMarker)
    ]

    testMarkReferencesRecursiveDeeperNotTouchedInOrig [
	<category: 'running'>
	| otherKid |
	kid buddy: #not -> (#deeper -> mom).
	otherKid := kid sandstoneDeepCopy.
	otherKid buddy value value save.
	otherKid sandstoneMarkReferences.
	self assert: (kid buddy value value isKindOf: mom class)
    ]

    testMarkReferencesStops [
	<category: 'running'>
	| other |
	other := SDManMock testPerson save.
	mom father: other.
	kid buddy: #some -> (#time -> mom).
	mom save.
	kid sandstoneMarkReferences.
	self assert: mom father == other
    ]

    testPeerIdentity [
	<category: 'running'>
	mom save.
	kid mother: mom.
	kid save.
	self flushAndReload.
	self assert: kid refreshed mother = mom refreshed
    ]

    testResolveReferences [
	<category: 'running'>
	mom save.
	kid mother: mom asReferenceMarker.
	kid sandstoneResolveReferences.
	self assert: (kid mother isKindOf: SDActiveRecord)
    ]

    testResolveReferencesRecursive [
	<category: 'running'>
	mom save.
	kid buddy: #not -> mom asReferenceMarker.
	kid sandstoneResolveReferences.
	self assert: (kid buddy value isKindOf: SDActiveRecord)
    ]

    testResolveReferencesRecursiveDeeperNestedList [
	<category: 'running'>
	mom save.
	kid buddy: #not -> (Array with: (Array with: mom asReferenceMarker)).
	kid sandstoneResolveReferences.
	self assert: (kid buddy value first first isKindOf: SDActiveRecord)
    ]

    testSetSerialization [
	<category: 'running'>
	kid save.
	mom children: (Set with: kid).
	mom save.
	self flushAndReload.
	self assert: (mom refreshed children includes: kid refreshed)
    ]

    testUpdatedOn [
	<category: 'running'>
	kid save.
	self assert: kid updatedOn <= DateTime now
    ]

    testVersion [
	<category: 'running'>
	self assert: kid version equals: 0.
	kid save.
	self assert: kid version equals: 1.
	kid save.
	self assert: kid version equals: 2
    ]

    testDictionaryWithArrays [
	<category: 'testing'>
	| foo |
	3 timesRepeat: [SDManMock new save].
	foo := (FooObject new)
		    dict: ((Dictionary new)
				at: #bar put: SDManMock findAll;
				at: #baz put: SDManMock findAll;
				yourself);
		    yourself.

	"Works fine before saving the object"
	foo dict 
	    keysAndValuesDo: [:key :value | value do: [:each | self assert: (each isKindOf: SDManMock)]].
	foo save.

	"now fails"
	foo dict 
	    keysAndValuesDo: [:key :value | value do: [:each | self assert: (each isKindOf: SDManMock)]]
    ]
]

PK
     �Mh@�<�E�  �    Tests/SDPersonMock.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDPersonMock class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



SDActiveRecord subclass: SDPersonMock [
    | name dateOfBirth description father mother children buddy |
    
    <comment: nil>
    <category: 'SandstoneDb-Tests'>

    SDPersonMock class >> testPerson [
	^(self new)
	    name: 'mzqfmmv zptnhli';
	    dateOfBirth: Date today;
	    description: 'Rxvalpv tdpqkvv ikjcscw bigjmeb vukntxj qxshdtt wkczzio bqpqacu whluhqv.  Lqlwajh!  Qknwpfd peeskqc oarthtv pfblwjj yndlxks.  .  Ucnlocq iuiiluk txkkzmh dshkhmq uokcwqy oiktkxl awxmpep rkkcmis xcgyoeg jodtjaf ntwijzp?  Bqpjsiq qthzwtx xcnqbag ausurqp xatoqar jytguon?  Bpigdij jgijxep bjgttpr kklsfaw rdoikwz!  Hzdbjxc?  Ehwflyy qfcqntk mlhcjql ecbtrtk egxldpk rypalvw ndngbdl jhhdxts zrfjtaz gccrnni dwuqxwm nmifzcq sxkgkxh.  Kwtzsjv ghvjqqm lfgibdt rufcowp kavabmi bpveqsr shjzsft xqaxivy fjqydns ryyggif.

Jshooyy jsyojlv miusnaj onpdiss hypkzzd qaunpqd rrvgnws ekiswyv?  Glhxkkk?  Pzyjuot raaefbv cnxmbsd?  Jabaniw uirjkcm jocxnhd!  Erwblox qikxfez.

Ezswaga cnrzhqi jrdikos kkcncxd eoewflm ylzilve viumpqm uiyqhvv azrezhc jjeesfd rfdgsgg wfmxfye iisisju vhjourb.

Yicqnqd zhaioos npnjjsc hxfwlfr ozynyjs!  Qavvubu uodeedp?  Fjdgbxu ryswazg ifumqpv jtlifnd?  Blciucl kypalot?  Dstnwqj kwzpxrk bgewcyp triddbr acvrkey pwgcleb sqtxajv svzpnwk unnlmtg oqnbpsq svtnxdo!

Ywodawk uikhwek kyqivqj iojkwiw.  Bjcsnpu jtfpmqd!  Crwlngk qeeeuci nnakbai hncfdkk kbhehju ttdsdcf zqulfpj pmvtmfa xrusxuy wbamfee opzjdia hcrfdnz tiasrqz wkwidbg?  Tzlwcst twaeuwm tfhreal igamlby saekozk tjnxohl ogcdhva fckbaii utqvhjg?  Nrynpjl dniycpm kkvytuu bnuxrev zrvbcph.  Awfbhgg xtyffnz lwjkhdo evmvogt vqfqppp chdtxcr ktiwujg vcgqoya thgkhac ncagoxy unuukan gntyowz obmiwmf!  Okwjujz tfghbxi jupstni xbzpgau zlxeblm!  Llxuwqc gupeurb ltwyzzj xxanyln qgrtigr?

Vudeenm hnfwxay rtaacau ymmyxbi lpcbamg ifopjuw guhctxx radytrh yubjcjc lnjucta qinzmlf.  Cnunlvp gdhcgrq oxeojsd?  Bbkjtne kzlvdso xtmgqhj pfyroxl brmqhkt gvqnftz aupxtsg.

Krzxaye!  Clhbjoq ubxtlsc jzhggvl updbzxe.

Vhtetst ruwpukn jdttpba?  Ctwactb ljoeiqa pubapwc cioporv?

Talkecn dbddhuw rxfybrf iwdxfdo spdbdyk vhxbgrm elqngon dytngbm knqxaqv zrltvgh snjkzig rzypaly ekabqcg.  Xxxmegt otxzkhh vxpyjkn pnhgpfx qsnrhjo ziftvuu ivvfacz nhdajef ezksurr gvfepxx.  Lqdldbo wegkzlk qxgqpux hfbtydd hbqfhea gxuksjm hvunuwa?  Lxqkddp bccukhy odljtnp nouapus dcqpkqz lgpxpcs fmaehsc cgybese gujcbqz icjzamy tvmvwlf dvtkpng!  !  Okqxkhh dfuulea?  Ratgmpz?  Pfmgfbk qhggllc.  Balobww?

Wqoyfli xlxenvi ngtdshb bhpmyhd.  Kxsidry wijdkem oyuutvw msunbhq vaektbt yfapmwl yjrwmxi xgzfpbk hxcmydy jgaybjh magjtcf.  Koxatqi ivvultq yptadcp ygqutkn dizybis nvsvfhx tdhcqfy ihvqsvs paakztf uzokxhk xlcfhbr wejdutf wywzrqs tnlswyo?  Glawqav nvndvdf cbqzhce iuygwer twyxquv pjklwnv tbnazjw vuvxvgi?

Rpyaiqq rnvfyzk fgbsbjc zhftunh uvmxaov vgvwzwq fpuurxc!  Zemojud eadzsas wzfdcuv vxvulbc ahtiijq yclzbvf rspxhrc lymmwja!  Mfmgrrb!  Cyfuuvp iabqntx volbiij ebjihqw ypxvukv wnghvwo fhqwyuh tlmeyrl oxcmotx uemizkc xvbgzqh xsdqtcj xfbzrgg?  Jmtauxu!  Kbigzux slwjszd manystg usxbiya kfgdygh wrclmih chqtyew orkrazt pekdcrh oexrivu bnbrerh?

Xbkcyvl xivutzr iitbwnm eouuiux iwaansa oxzygwa sosqxvi jkinurb bedwzss?  Uspwzru.  Eogmjki raowczb!  ?  Lfzhatu ldnvhfn rzfqfcl yzhbxpo evahsye eibcwlx ygknqms terepdi acvezip lyqydat bksesji.  Sncraae sropzde xdhuuuf?  ?

Vtcevnw dqwwzqe kqmakan wboltvp axuhsio eddpqvk hmaqsst kbqyeqg qjnlkph zjrrcdr glyqfak!  Ciofqeq qzfzdxn aumczcs yxzdrqu hxnlhmo ihnowav nqggjoi dfdxzqr.

Wiedtvt jpikavx hkxvzqi eyobbcb hxhktut qpgasux bnwnzhp xaceikr comlnmg jkdzrhn hctccgm zcjgqbc llklclt!

Bgyypck fvgaauj bzetcjo rqixcnx ggwuzax cnknyiv vbtnkxj zkmenql ynxyqpp vqnvihq qydzixk jvsbxhw qnbphdl uddayfe!  Glalnun gbtcspy kxnzokz ecdpgpr kcmvcdf ngczhkp oovhcik yvlzbgl?';
	    yourself
    ]

    buddy [
	<category: 'accessing'>
	^buddy
    ]

    buddy: anObject [
	<category: 'accessing'>
	buddy := anObject
    ]

    children [
	<category: 'accessing'>
	^children
    ]

    children: anObject [
	<category: 'accessing'>
	children := anObject
    ]

    dateOfBirth [
	<category: 'accessing'>
	^dateOfBirth
    ]

    dateOfBirth: anObject [
	<category: 'accessing'>
	dateOfBirth := anObject
    ]

    description [
	<category: 'accessing'>
	^description
    ]

    description: anObject [
	<category: 'accessing'>
	description := anObject
    ]

    father [
	<category: 'accessing'>
	^father
    ]

    father: anObject [
	<category: 'accessing'>
	father := anObject
    ]

    mother [
	<category: 'accessing'>
	^mother
    ]

    mother: anObject [
	<category: 'accessing'>
	mother := anObject
    ]

    name [
	<category: 'accessing'>
	^name
    ]

    name: anObject [
	<category: 'accessing'>
	name := anObject
    ]

    refreshed [
	<category: 'accessing'>
	^self class atId: id
    ]
]

PK
     �Mh@���N-  -    Tests/FooObject.stUT	 dqXO��XOux �  �  "======================================================================
|
|   Sandstone.FooObject class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"


SDActiveRecord subclass: FooObject [
    | dict |
    
    <comment: nil>
    <category: 'SandstoneDb-Tests'>

    dict [
	<category: 'accessing'>
	^dict
    ]

    dict: aDictionary [
	<category: 'accessing'>
	dict := aDictionary
    ]
]

PK
     �Mh@OZ�M�  �    Tests/SDWomanMock.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDWomanMock class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



SDPersonMock subclass: SDWomanMock [
    
    <comment: nil>
    <category: 'SandstoneDb-Tests'>
]

PK
     �Mh@آ��  �    Tests/SDChildMock.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDChildMock class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



SDWomanMock subclass: SDChildMock [
    
    <comment: nil>
    <category: 'SandstoneDb-Tests'>
]

PK
     �Mh@F���  �    Tests/SDGrandChildMock.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDGrandChildMock class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



SDChildMock subclass: SDGrandChildMock [
    
    <comment: nil>
    <category: 'SandstoneDb-Tests'>
]

PK
     �Mh@��C;�  �    Tests/SDFileStoreTest.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDFileStoreTest class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



SDActiveRecordTest subclass: SDFileStoreTest [
    
    <comment: nil>
    <category: 'SandstoneDb-Tests'>

    SDFileStoreTest class >> isAbstract [
	<category: 'testing'>
	^false
    ]

    defaultStore [
	<category: 'defaults'>
	^SDFileStore new
    ]

    testDeleteFailedCommits [
	<category: 'running'>
	kid save.
	((store dirForClass: kid class atId: kid id) at: kid id , '.obj.new') touch.
	self assert: ((store dirForClass: kid class atId: kid id) 
		    at: kid id , '.obj') exists.
	self assert: ((store dirForClass: kid class atId: kid id) 
		    at: kid id , '.obj.new') exists.
	store deleteFailedCommitsForClass: kid class.
	self assert: ((store dirForClass: kid class atId: kid id) 
		    at: kid id , '.obj') exists.
	self deny: ((store dirForClass: kid class atId: kid id) 
		    at: kid id , '.obj.new') exists
    ]

    testDeleteOldVersions [
	<category: 'running'>
	| id |
	kid save.
	kid save.
	id := kid id.
	kid delete.
	self 
	    assert: ((store dirForClass: kid class atId: id) 
		    filesMatching: id , '\.*') isEmpty
    ]

    testFinishPartialCommits [
	<category: 'running'>
	kid save.
	((store dirForClass: kid class atId: kid id) at: kid id , '.obj')
	    renameTo: ((store dirForClass: kid class atId: kid id) at: kid id , '.obj.new') name.
	self deny: ((store dirForClass: kid class atId: kid id) 
		    at: kid id , '.obj') exists.
	self assert: ((store dirForClass: kid class atId: kid id) 
		    at: kid id , '.obj.new') exists.
	store finishPartialCommitsForClass: kid class.
	self assert: ((store dirForClass: kid class atId: kid id) 
		    at: kid id , '.obj') exists.
	self deny: ((store dirForClass: kid class atId: kid id) 
		    at: kid id , '.obj.new') exists
    ]

    testLoadMissingFile [
	<category: 'running'>
	kid save.
	((store dirForClass: kid class atId: kid id) at: kid id, '.obj') remove. 
	self should: [store loadClass: kid class atId: kid id] raise: SDLoadError
    ]

    testLoadTime [
	<category: 'running'>
	| commitTime people lookupTime loadTime |
	people := (1 to: 100) collect: [:it | SDPersonMock testPerson].
	commitTime := Time millisecondsToRun: [people do: [:each | each save]].
	lookupTime := Time millisecondsToRun: [people do: [:each | SDPersonMock atId: each id]].
	loadTime := Time millisecondsToRun:
	[SDActiveRecord resetStoreForLoad.
	SDActiveRecord warmUpAllClasses].
	"Transcript
	    show: commitTime printString;
	    cr;
	    show: loadTime printString;
	    cr;
	    cr."
    ]

    testSaveMissingFile [
	<category: 'running'>
	self assert: kid isNew.
	kid save.
	self deny: kid isNew.
	((store dirForClass: kid class atId: kid id) at: kid id , '.obj') remove.
	kid save.
	self deny: kid isNew
    ]

    testStorageDir [
	"Active records id's must find a proper subdirectory entry in the defined structure"

	<category: 'running'>
	| ids legalNames |
	legalNames := (0 to: 9) collect: [:e | e printString].
	ids := Set new: 1000.
	1000 timesRepeat: [ids add: UUID new printString].
	ids add: 'abaoblwgnaydxokccorveamoq'.
	ids do: 
		[:anId | 
		self assert: (legalNames 
			includes: (store dirForClass: SDPersonMock atId: anId) stripPath)]
    ]
]

PK
     �Mh@���4c   c     Tests/Extensions.stUT	 dqXO��XOux �  �  TestCase extend [
    assert: expected equals: actual [
	^self assert: (expected = actual)
    ]
]
PK
     �Mh@js���  �    Tests/SDManMock.stUT	 dqXO��XOux �  �  "======================================================================
|
|   Sandstone.SDManMock class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



SDPersonMock subclass: SDManMock [
    
    <comment: nil>
    <category: 'SandstoneDb-Tests'>
]

PK
     �[h@              Store/UT	 ��XO��XOux �  �  PK
     �Mh@�Y��s  s    Store/SDMemoryStore.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDMemoryStore class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



SDCachedStore subclass: SDMemoryStore [
    | cache |
    
    <comment: 'I''m a store for persisting active records directly to a
    dictionary to show what a minimal implementation of a store must to
    do pass the unit tests.'>
    <category: 'SandstoneDb-Store'>

    Cache := nil.

    SDMemoryStore class >> initialize [
	"self initialize"
	<category: 'initialization'>

	Cache := Dictionary new.
    ]

     SDMemoryStore class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    abortChanges: anObject [
	<category: 'actions'>
	| diskVersion |
	anObject critical: 
		[self removeCachedOfClass: anObject class from: anObject id.
		diskVersion := self cachedLoadOfClass: anObject class from: anObject id.
		diskVersion ifNil: 
			[self 
			    addCachedOfClass: anObject class
			    at: anObject id
			    put: anObject]
		    ifNotNil: [anObject become: diskVersion]]
    ]

    addCachedOfClass: aClass at: anId put: anObject [
	<category: 'actions'>
	(cache at: aClass) at: anId put: anObject
    ]

    cachedLoadOfClass: aClass from: anId [
	<category:'actions'>
	^(cache at: aClass) at: anId
	    ifAbsent: 
		[([self loadClass: aClass atId: anId] on: SDLoadError do: [nil]) 
		    ifNotNil: 
			[:it | 
			"seems I have to make sure to cache the object before I can resolve
			 it's references so any backreferences to it don't try and load from
			 disk again''"

			(cache at: aClass) at: anId put: it.
			it sandstoneResolveReferences]]
    ]

    commit: aBlock [
	<category: 'actions'>
	self shouldNotImplement
    ]

    ensureForClass: aClass [
	<category: 'actions'>
	cache at: aClass ifAbsentPut: [Dictionary new: self defaultCacheSize]
    ]

    initialize [
	<category: 'actions'>
	super initialize.
	Cache := SDActiveRecord defaultDictionary new.
	cache := SDActiveRecord defaultDictionary new.
    ]

    loadClass: aClass atId: anId [
	<category: 'actions'>
	^(Cache at: anId) sandstoneResolveReferences
    ]

    recoverForClass: aClass [
	<category: 'actions'>
	Cache keysDo: [:e | self cachedLoadOfClass: aClass from: e]
    ]

    removeCachedOfClass: aClass from: anId [
	<category: 'actions'>
	^(cache at: aClass) removeKey: anId
	    ifAbsent: ["SDError signal: 'Deleted or new objects cannot be aborted'" nil]
    ]

    removeObject: anObject [
	<category: 'actions'>
	self removeCachedOfClass: anObject class from: anObject id.
	Cache removeKey: anObject id ifAbsent: []
    ]

    storeObject: anObject [
	<category: 'actions'>
	self 
	    addCachedOfClass: anObject class
	    at: anObject id
	    put: anObject.
	Cache at: anObject id
	    put: anObject sandstoneDeepCopy sandstoneMarkReferences
    ]

    updateObject: anObject [
	<category: 'actions'>
	self storeObject: anObject
    ]

    familyForClass: aClass [
	"I'm returing raw cache dictionary here because this read only copy
	 doesn't need concurrency protection, just a naked dictionary''"

	<category: 'queries'>
	^aClass allSubclasses inject: (cache at: aClass)
	    into: [:sum :subclass | sum addAll: (cache at: subclass). sum]
    ]
]


Eval [
    SDMemoryStore initialize
]

PK
     �Mh@�8u_$  _$    Store/SDFileStore.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDFileStore class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



SDCachedStore subclass: SDFileStore [
    | cache |
    
    <comment: 'I''m a store for persisting active records directly to disk via
    a SmartReference stream with a few extentions to make it non interactive.'''>
    <category: 'SandstoneDb-Store'>

    abortChanges: anObject [
	<category: 'actions'>
	| diskVersion |
	anObject critical: 
		[self removeCachedOfClass: anObject class from: anObject id.
		diskVersion := self cachedLoadOfClass: anObject class from: anObject id.
		diskVersion ifNil: 
			[self 
			    addCachedOfClass: anObject class
			    at: anObject id
			    put: anObject]
		    ifNotNil: [anObject becomeForward: diskVersion]]
    ]

    addCachedOfClass: aClass at: anId put: anObject [
	<category: 'actions'>
	(cache at: aClass) at: anId put: anObject
    ]

    commit: aBlock [
	<category: 'actions'>
	self shouldNotImplement
    ]

    ensureDown [
	<category: 'actions'>
	self initializeCache
    ]

    ensureForClass: aClass [
	<category: 'actions'>
	| dir |
	dir := (self dirForClass: aClass) createDirectories.
	0 to: 9 do: [:num | 
	    (File name: (dir nameAt: num printString)) createDirectories].
	cache at: aClass
	    ifAbsentPut: 
		[SDConcurrentDictionary on: (Dictionary new: self defaultCacheSize)]
    ]

    loadClass: aClass atId: anId [
	<category: 'actions'>
	| file stream obj |
	[file := (self dirForClass: aClass atId: anId) at: anId, '.obj'.
	stream := FileStream open: file name mode: FileStream read.
	obj := (ObjectDumper on: stream) load] 
	    on: Error
	    do: [:err | SDLoadError signal: err messageText].
	stream close.
	^obj
    ]

    recoverForClass: aClass [
	<category: 'actions'>
	self
	    finishPartialCommitsForClass: aClass;
	    deleteFailedCommitsForClass: aClass;
	    loadChangesForClass: aClass
    ]

    removeCachedOfClass: aClass from: anId [
	"calling delete multiple times shouldn't cause an error"

	<category: 'actions'>
	^(cache at: aClass) removeKey: anId ifAbsent: [nil]
    ]

    removeObject: anObject [
	<category: 'actions'>
	| dir |
	self removeCachedOfClass: anObject class from: anObject id.
	dir := self dirForClass: anObject class atId: anObject id.
	"(dir at: anObject id , '.obj') remove."
	"kill any other versions or failed commits of this object"
	dir 
	    allFilesMatching: anObject id , '.*'
	    do: [:each | each remove]
    ]

    storeObject: origObject [
	"The basic idea here is to make a save as atomic as possible and no data
	 is corrupted, no partial writes, thus renaming files as atomic."

	<category: 'actions'>
	| currentVersion newVersion oldVersion dir anObject stream |
	(cache at: origObject class) at: origObject id put: origObject.
	anObject := origObject sandstoneDeepCopy sandstoneMarkReferences.
	dir := self dirForClass: anObject class atId: anObject id.
	currentVersion := dir at: anObject id , '.obj'.
	newVersion := dir at: anObject id , '.obj.new'.
	oldVersion := dir at: anObject id , '.obj.old'.
	"just in case a previous commit failed and left junk around"
	oldVersion exists ifTrue: [oldVersion remove].
	"the flush ensures all data is actually written to disk before moving on"
	stream := FileStream open: newVersion name mode: FileStream write.
	(ObjectDumper on: stream) dump: anObject.
	stream close.
	"just in case any junk was lying around that failed to die on last commit"
	oldVersion exists ifTrue: [oldVersion remove].
	"the pre-commit, on first save there won't be a current version, and fileExists is
	 too expensive to check when it'll always be there except on first save"
	[currentVersion renameTo: oldVersion name] ifError: [].
	"now the actual commit"
	newVersion renameTo: currentVersion name.
	"clean up the junk (could fail if OS has lock on it for some reason)"
	oldVersion exists ifTrue: [oldVersion remove].
    ]

    updateObject: anObject [
	<category: 'actions'>
	self storeObject: anObject
    ]

    cachedLoadOfClass: aClass from: anId [
	<category: 'queries'>
	^(cache at: aClass) at: anId
	    ifAbsent: 
		[
		([self loadClass: aClass atId: anId] on: SDLoadError do: [nil]) 
		    ifNotNil: [:it | 
			"seems I have to make sure to cache the object before I can resolve
			 it's references so any backreferences to it don't try and load from
			 disk again''"
			(cache at: aClass) at: anId put: it.
			it sandstoneResolveReferences]]
    ]

    dirForClass: aClass [
	"compute the path of superclasses all the way up to ActiveRecord, storing
	 subclass records as a subdirectory of the superclasses directory
	 allows ActiveRecord to deal with inheritance"

	<category: 'queries'>
	| parentClass lineage |
	aClass == SDActiveRecord 
	    ifTrue: 
		[Error 
		    signal: 'ActiveRecord itself is abstract, you must only  
 store subclasses'].
	lineage := OrderedCollection with: aClass.
	parentClass := aClass superclass.
	[parentClass == SDActiveRecord] whileFalse: 
		[lineage addFirst: parentClass.
		parentClass := parentClass superclass].
	^lineage inject: self defaultBaseDirectory into: [:dir :each | 
	    File name: (dir nameAt: each name asString)]
    ]

    dirForClass: aClass atId: anId [
	"Grab the correct hashed subdirectory for this record"

	<category: 'queries'>
	^File name: ((self dirForClass: aClass) nameAt: (self dirNameFor: anId))
    ]

    dirNameFor: anId [
	"Answers a string with one decimal digit corresponding to anId.  There is a bug
	 in this that does not ever hash to the directory 1, but because of existing datasets
	 this must remain, do not want to rehash my databases and it is no big deal"

	<category: 'queries'>
	^(anId inject: 0 into: [:sum :e | sum + e asInteger]) asReducedSumOfDigits 
	    printString
    ]

    familyForClass: aClass [
	"I'm returing raw cache dictionary here because this read only copy
	 doesn't need concurrency protection, just a naked dictionary''"

	<category: 'queries'>
	^aClass allSubclasses 
	    inject: (cache at: aClass) dictionary
	    into: [:sum :subclass | 
		sum addAll: (cache at: subclass) dictionary. sum]
    ]

    defaultBaseDirectory [
	"you can override this if you want to force the db somewhere else"

	<category: 'defaults'>
	    ^File name: (File image asString, '.SandstoneDb')
    ]

    deleteFailedCommitsForClass: aClass [
	"all remaining .new files are failed commits, kill them"

	<category: 'crash recovery'>
	[(self dirForClass: aClass) 
	    allFilesMatching: '*.new' 
	    do: [:each | each remove]] 
		on: Error
		do: [:err | Transcript show: err]
    ]

    finishPartialCommitsForClass: aClass [
	"find where .new exists but .obj doesn't, rename .obj.new to
	 .obj to finish commit'"

	<category: 'crash recovery'>
	[(self dirForClass: aClass)  
	    allFilesMatching: '*.new' 
	    do: [:each || objFile dir |
		    objFile := File name: (each name copyReplacingAllRegex: '.new' with: '').
		    objFile exists ifFalse: [each renameTo: objFile name]]]
	    on: Error
	    do: [:err | Transcript show: err; cr].
    ]

    loadChangesForClass: aClass [
	<category: 'crash recovery'>
	| id obj |
	(self dirForClass: aClass) all do: [:each |
	    "there could be tens of thousands of entries, so using do with
	    a condition to avoid the copy a select would generate"
	    [each isDirectory ifFalse: [
		id := each stripPath copyUpTo: $..
		obj := (cache at: aClass) 
		    at: id 
		    ifAbsent: [nil].
		obj ifNil: [self cachedLoadOfClass: aClass from: id]
		    ifNotNil: [obj abortChanges]]] 
			on: Error
			do: [:err | Transcript show: err; cr]]
    ]

    initialize [
	<category: 'initialization'>
	super initialize.
	self initializeCache
    ]

    initializeCache [
	<category: 'initialization'>
	cache := SDConcurrentDictionary 
		    on: (SDActiveRecord defaultDictionary new: self defaultCacheSize)
    ]
]

PK
     �[h@              Core/UT	 ��XO��XOux �  �  PK
     �Mh@����  �    Core/SDCommitError.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDCommitError class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



SDError subclass: SDCommitError [
    
    <comment: 'Clearly, I''m thrown on a commit failure, duh!'''>
    <category: 'SandstoneDb-Core'>
]

PK
     �Mh@/���  �    Core/SDRecordMarker.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDRecordMarker class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"




Object subclass: SDRecordMarker [
    | id className environment |
    
    <category: 'SandstoneDb-Core'>
    <comment: 'I exist to mark a reference to another object in
    the serialized file, I''m replaced by a real object when I''m
    deserialized.  I''m basically a manually invoked proxy being
    used because getting a real proxy that inherits from ProtoObject
    to serialize seemed hurculean.'>

    asOriginalObject [
	"this needs to call cachedLoadFrom not findById in order to allow cycles in
	 the serialized graph this allows an object that references an unloaded object
	 during the loadAll to force it's load instead of failing"

	<category: 'converting'>
	| origClass |
	origClass := environment at: className.
	"I'm checking inheritsFrom: here so that any classes that used to be
	 activeRecords but aren't anymore that had serialized instances are
	 caught and return nil when resolved rather than blow up.  This happens
	 often during development when you're changing your model a lot"
	^(origClass inheritsFrom: SDActiveRecord) 
	    ifTrue: 
		[SDActiveRecord store cachedLoadOfClass: (environment at: className) from: id]
	    ifFalse: [nil]
    ]

    className [
	<category: 'accessing'>
	^className
    ]

    className: anObject [
	<category: 'accessing'>
	className := anObject
    ]

    environment [
	<category: 'accessing'>
	^environment
    ]

    environment: anObject [
	<category: 'accessing'>
	environment := anObject
    ]

    id [
	<category: 'accessing'>
	^id
    ]

    id: anObject [
	<category: 'accessing'>
	id := anObject
    ]

    deservesSandstoneReferenceMark [
	<category: 'testing'>
	^false
    ]

    isSandstoneMarker [
	<category: 'testing'>
	^true
    ]
]

PK
     �Mh@gXmİ  �    Core/SDError.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDError class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



Error subclass: SDError [
    
    <category: 'SandstoneDb-Core'>
    <comment: 'I''m just an abstract error'>
]

PK
     �Mh@G΁��  �    Core/SDConcurrentDictionary.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDConcurrentDictionary class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"


"PORTING : GST doesn't seem to have Monitors. Use RecursionLock instead..."


Object subclass: SDConcurrentDictionary [
    | lock dictionary |
    
    <category: 'SandstoneDb-Core'>
    <comment: 'A SDConcurrentDictionary is just a dictionary wrapper so I can
    wrap a critical around mutating methods I need in ActiveRecord'>

    SDConcurrentDictionary class >> on: aDictionary [
	<category: 'instance creation'>
	^(self new)
	    dictionary: aDictionary;
	    yourself
    ]

   SDConcurrentDictionary class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
   ]

    , aCollection [
	<category: 'copying'>
	^lock critical: [self class on: dictionary , aCollection]
    ]

    at: aKey [
	<category: 'accessing'>
	^dictionary at: aKey
    ]

    at: aKey ifAbsent: aBlock [
	<category: 'accessing'>
	lock critical: [^dictionary at: aKey ifAbsent: aBlock]
    ]

    at: aKey ifAbsentPut: aBlock [
	<category: 'accessing'>
	lock critical: [^dictionary at: aKey ifAbsentPut: aBlock]
    ]

    at: aKey put: aValue [
	<category: 'accessing'>
	lock critical: [^dictionary at: aKey put: aValue]
    ]

    dictionary [
	<category: 'accessing'>
	^dictionary
    ]

    dictionary: anObject [
	<category: 'accessing'>
	dictionary := anObject
    ]

    keys [
	<category: 'accessing'>
	^dictionary keys
    ]

    keysAndValuesDo: aBlock [
	<category: 'accessing'>
	^dictionary keysAndValuesDo: aBlock
    ]

    values [
	<category: 'accessing'>
	^dictionary values
    ]

    includesKey: aKey [
	<category: 'testing'>
	^dictionary includesKey: aKey
    ]

    initialize [
	<category: 'initialization'>
	"I'm using a Monitor rather than a Semaphor here because I need to support
	 reentrant operations by the same process, a Semaphor is too low level"
	lock := RecursionLock new
    ]

    removeAll [
	<category: 'removing'>
	^lock critical: [self keys copy do: [:e | self removeKey: e]]
    ]

    removeKey: aKey [
	<category: 'removing'>
	^lock critical: [dictionary removeKey: aKey]
    ]

    removeKey: aKey ifAbsent: aBlock [
	<category: 'removing'>
	^lock critical: [dictionary removeKey: aKey ifAbsent: aBlock]
    ]
]

PK
     �Mh@L�>  >    Core/SDCachedStore.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDCachedStore class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



SDAbstractStore subclass: SDCachedStore [
    
    <comment: nil>
    <category: 'SandstoneDb-Core'>

    addCachedOfClass: aClass at: anId put: anObject [
	<category: 'actions'>
	
    ]

    cachedLoadOfClass: aClass from: anId [
	<category: 'actions'>
	self subclassResponsibility
    ]

    removeCachedOfClass: aClass from: anId [
	<category: 'actions'>
	
    ]

    familyForClass: aClass [
	<category: 'delegated queries'>
	self subclassResponsibility
    ]

    forClass: aClass [
	<category: 'delegated queries'>
	^self familyForClass: aClass
    ]

    forClass: aClass at: anId ifAbsent: aHandler [
	<category: 'delegated queries'>
	^(self familyForClass: aClass) at: anId ifAbsent: aHandler
    ]

    forClass: aClass detect: aBlock ifFound: aHandler [
	<category: 'delegated queries'>
	^((self forClass: aClass) detect: aBlock ifNone: [nil]) 
	    ifNotNilDo: aHandler
    ]

    forClass: aClass detect: aBlock ifNone: aHandler [
	<category: 'delegated queries'>
	^(self forClass: aClass) detect: aBlock ifNone: aHandler
    ]

    forClass: aClass do: aBlock [
	<category: 'delegated queries'>
	(self forClass: aClass) do: aBlock
    ]

    forClass: aClass findAll: aBlock [
	<category: 'delegated queries'>
	^(self forClass: aClass) select: aBlock
    ]
]

PK
     �Mh@BC<s  s    Core/SDCheckPointer.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDCheckPointer class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



Object subclass: SDCheckPointer [
    
    <category: 'SandstoneDb-Core'>
    <comment: 'I run as a background process to ensure the database is loaded
    and periodically save the image when enough active records are found to be
    newer than the image.  This is essentially just like flushing the contents
    of a transaction log to the main database file.'>

    SDCheckPointer class >> update: aspect [
	"SDCheckPointer will act as the single agent to ensure all active record
	 subclasses are correctly initialized on start up."

	"self initialize"
	<category: 'initialization'>

	aspect == #returnFromSnapshot ifTrue: [
	    self startUp: true].
	aspect == #aboutToQuit ifTrue: [
	    self shutDown: true]
    ] 

    SDCheckPointer class >> shutDown: isDown [
	<category: 'system startup'>
	isDown 
	    ifTrue: 
		[SDActiveRecord store ensureDown.
		SDActiveRecord allSubclassesDo: [:each | each coolDown]]
    ]

    SDCheckPointer class >> startUp: isStarting [
	"Had problems reusing images from templated sites or existing sites
	 and accidently mixing old data or another db into this images data.
	 I want to ensure that any time an image starts up fresh from disk it
	 always reloads all the data; setting a fresh store on startup will
	 ensure this happens."

	<category: 'system startup'>
	SDActiveRecord store 
	    ifNil: [SDActiveRecord setStore: SDActiveRecord defaultStore]
	    ifNotNil: 
		[isStarting 
		    ifTrue: [SDActiveRecord resetStoreForLoad]].

	"Load records on a priority just higher than Seaside so db is loaded
	before requests start coming in, don't want users seeing missing data."
	
	[isStarting 
	    ifTrue: [SDActiveRecord warmUpAllClasses]] 
	    forkAt: Processor userBackgroundPriority + 1
	    "named: 'Loading sandstone'"
    ]
]

Eval [
    ObjectMemory addDependent: SDCheckPointer
]
PK
     �Mh@�<�_�  �    Core/UUID.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.UUID  class definition
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008, 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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



ByteArray subclass: UUID [
    
    <shape: #byte>
    <category: 'Sandstone'>
    <comment: 'I am a UUID.  Sending #new generates a UUIDv1.'>

    Node := nil.
    SequenceValue := nil.
    LastTime := nil.
    Generator := nil.
    GeneratorMutex := nil.

    UUID class >> timeValue [
	"Returns the time value for a UUIDv1, in 100 nanoseconds units
	 since 1-1-1601."
	^((Time utcSecondClock + (109572 * 86400)) * 1000
	    + Time millisecondClock) * 10000
    ]

    UUID class >> randomNodeValue [
	"Return the node value for a UUIDv1."
	| n |
	"TODO: use some kind of digest to produce cryptographically strong
	 random numbers."
	n := Generator between: 0 and: 16rFFFF.
	n := (n bitShift: 16) bitOr: (Generator between: 0 and: 16rFFFF).
	n := (n bitShift: 16) bitOr: (Generator between: 0 and: 16rFFFF).
	^n bitOr: 1
    ]

    UUID class >> update: aSymbol [
	"Update the sequence value of a UUIDv1 when an image is restarted."

	aSymbol == #returnFromSnapshot ifTrue: [
	    "You cannot be sure that the node ID is the same."
	    GeneratorMutex critical: [
		Generator := Random new.
		LastTime := self timeValue.
		Node := self randomNodeValue.
		SequenceValue := (SequenceValue + 1) bitAnd: 16383 ]].
    ]

    UUID class >> defaultSize [
	"Return the size of a UUIDv1."

	<category: 'private'>
	^16
    ]

    UUID class >> initialize [
	"Initialize the class."

	<category: 'initialization'>
	ObjectMemory addDependent: self.
	Generator := Random new.
	LastTime := self timeValue.
	Node := self randomNodeValue.
	SequenceValue := Generator between: 0 and: 16383.
	GeneratorMutex := Semaphore forMutualExclusion.
    ]

    UUID class >> new [
	"Return a new UUIDv1."

	<category: 'instance-creation'>
	^(self new: self defaultSize) initialize
    ]

    initialize [
	"Fill in the fields of a new UUIDv1."

	<category: 'private'>
	| t |
	GeneratorMutex critical: [
	    t := self class timeValue bitAnd: 16rFFFFFFFFFFFFFFF.
	    t <= LastTime
		ifTrue: [ SequenceValue := (SequenceValue + 1) bitAnd: 16383 ].

	    LastTime := t.
	    self at: 1 put: ((t bitShift: -24) bitAnd: 255).
	    self at: 2 put: ((t bitShift: -16) bitAnd: 255).
	    self at: 3 put: ((t bitShift: -8) bitAnd: 255).
	    self at: 4 put: (t bitAnd: 255).
	    self at: 5 put: ((t bitShift: -40) bitAnd: 255).
	    self at: 6 put: ((t bitShift: -32) bitAnd: 255).
	    self at: 7 put: (t bitShift: -56) + 16r10.
	    self at: 8 put: ((t bitShift: -48) bitAnd: 255).
	    self at: 9 put: (SequenceValue bitShift: -8) + 16r80.
	    self at: 10 put: (SequenceValue bitAnd: 255).
	    self at: 13 put: ((Node bitShift: -40) bitAnd: 255).
	    self at: 14 put: ((Node bitShift: -32) bitAnd: 255).
	    self at: 15 put: ((Node bitShift: -24) bitAnd: 255).
	    self at: 16 put: ((Node bitShift: -16) bitAnd: 255).
	    self at: 11 put: ((Node bitShift: -8) bitAnd: 255).
	    self at: 12 put: (Node bitAnd: 255)]
    ]

    printOn: aStream from: a to: b [
	<category: 'private'>
	self from: a to: b do: [:each |
	    aStream nextPut: (Character digitValue: (each bitShift: -4)).
	    aStream nextPut: (Character digitValue: (each bitAnd: 15)) ]
    ]

    printOn: aStream [
	"Print the bytes in the receiver in UUID format."
	<category: 'printing'>
	self printOn: aStream from: 1 to: 4.
	aStream nextPut: $-.
	self printOn: aStream from: 5 to: 6.
	aStream nextPut: $-.
	self printOn: aStream from: 7 to: 8.
	aStream nextPut: $-.
	self printOn: aStream from: 9 to: 10.
	aStream nextPut: $-.
	self printOn: aStream from: 11 to: 16.
    ]
]


Eval [
    UUID initialize.
]

PK
     �Mh@��K{)  )    Core/SDActiveRecord.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDActiveRecord class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"


"PORTING : GST doesn't seem to have Monitors. Use RecursionLock instead..."


Object subclass: SDActiveRecord [
    | id createdOn updatedOn version isNew |
    
    <category: 'SandstoneDb-Core'>
    <comment: 'I''m the core of a simple object database based upon a mix of
    several patterns intended for use with *small* Seaside based web
    applications.  I am not meant to scale to millions of records, just tens
    of thousands, but for prototyping and small office applications where the
    number of records are in the thousands and the number of concurrent users
    can be handled by a single Squeak image.  To use me, simply subclass me and
    restart your image that''s it.  For more information see
    http://onsmalltalk.com/programming/smalltalk/sandstonedb-simple-activerecord-style-persistence-in-squeak/'>

    SDActiveRecord class [
	| locks |
	
    Store := nil.
    ]

    SDActiveRecord class >> new [
	<category: 'instance creation'>
	^self basicNew initialize
    ]

    SDActiveRecord class >> atId: anId [
	"hitting this in a tight loop for a class with subclasses can be very
	expensive because allCaches has to concatenate all the subclasses
	caches into a new copy that contains all subclass records"
	<category: 'queries'>

	^self atId: anId ifAbsent: [nil]
    ]

    SDActiveRecord class >> atId: anId ifAbsent: aHandler [
	"hitting this in a tight loop for a class with subclasses can be very
	expensive because allCaches has to concatenate all the subclasses
	caches into a new copy that contains all subclass records"
	<category: 'queries'>

	^Store 
	    forClass: self
	    at: anId
	    ifAbsent: aHandler
    ]

    SDActiveRecord class >> do: aBlock [
	"do on a copy in case the do modifies the collection I'm trying
	to iterate'"
	<category: 'queries'>

	Store forClass: self do: aBlock
    ]

    SDActiveRecord class >> find: aBlock [
	<category: 'queries'>
	^self find: aBlock ifAbsent: [nil]
    ]

    SDActiveRecord class >> find: aBlock ifAbsent: aHandler [
	<category: 'queries'>
	^Store 
	    forClass: self
	    detect: aBlock
	    ifNone: aHandler
    ]

    SDActiveRecord class >> find: aBlock ifPresent: aHandler [
	<category: 'queries'>
	^Store 
	    forClass: self
	    detect: aBlock
	    ifFound: aHandler
    ]

    SDActiveRecord class >> findAll [
	<category: 'queries'>
	^(Store forClass: self) values
    ]

    SDActiveRecord class >> findAll: aBlock [
	<category: 'queries'>
	^(Store forClass: self findAll: aBlock) values
    ]

    SDActiveRecord class >> commit: aBlock [
	<category: 'actions'>
	^Store commit: aBlock
    ]

    SDActiveRecord class >> coolDown [
	<category: 'actions'>
	locks := nil.
	self ensureReady
    ]

    SDActiveRecord class >> resetStoreForLoad [
	<category: 'actions'>
	self setStore: self store class new
    ]

    SDActiveRecord class >> warmUp [
	<category: 'actions'>
	| loadTime |
	loadTime := Time millisecondsToRun: [
	    Store ensureForClass: self.
	    self ensureReady.
	    Store recoverForClass: self].
	"Transcript
	    show: self name , ' loaded in ' , loadTime printString;
	    cr"
    ]

    SDActiveRecord class >> warmUpAllClasses [
	<categroy: 'actions'>
	self allSubclassesDo: [:each | self store ensureForClass: each].
	self allSubclassesDo: [:each | each warmUp]
    ]

    SDActiveRecord class >> defaultStore [
	<category: 'defaults'>
	^SDFileStore new
    ]

    SDActiveRecord class >> ensureReady [
	<category: 'actions private'>
	locks 
	    ifNil: [locks := SDConcurrentDictionary on: (WeakKeyDictionary new: 10000)]
    ]

    SDActiveRecord class >> defaultDictionary [
	<categroy: 'defaults'>
	^Dictionary
    ]
   
    SDActiveRecord class >> defaultHashSize [
	<category: 'defaults'>
	^100
    ]

    SDActiveRecord class >> defaultIdentityDictionary [
	<category: 'defaults'>
	^IdentityDictionary
    ]
    
    SDActiveRecord class >> initialize [
	<category: 'initialization'>
	Store := self defaultStore
    ]

    SDActiveRecord class >> setStore: aStore [
	<category: 'initialization'>
	Store ifNotNil: [Store ensureDown].
	Store := aStore
    ]

    SDActiveRecord class >> lockFor: anInstance [
	<category: 'queries private'>
	^locks at: anInstance id ifAbsentPut: [RecursionLock new]
    ]

    SDActiveRecord class >> store [
	<category: 'accessing'>
	^Store
    ]

    initialize [
	<category: 'initialize-release'>
	id := UUID new printString.
	createdOn := updatedOn := DateTime now.
	version := 0.
	isNew := true
    ]

    = anObject [
	"asking the object isMemberOf ensures that if it's a proxy that message
	 will be forwarded to the real object.  Checking this condition in reverse
	 anObject class, will fail because anObject class will be the ProxyClass"
	<category: 'comparing'>

	^(anObject isMemberOf: self class) and: [id = anObject id]
    ]

    hash [
	<category: 'comparing'>
	^id hash
    ]

    abortChanges [
	"Rollback object to the last saved version"
	<category: 'actions'>

	Store abortChanges: self
    ]

    critical: aBlock [
	<category: 'actions'>
	^(self class lockFor: self) critical: aBlock
    ]

    delete [
	"I'm using monitors for locking so this can be wrapped in larger critical
	 in your application code if you want more scope on the critical'"
	<category: 'actions'>

	self critical: 
		[self onBeforeDelete.
		Store removeObject: self.
		self onAfterDelete.
		self initialize]
    ]

    save [
	"I'm using monitors for locking so this can be wrapped in larger critical
	 in your application code if you want more scope on the critical'"
	<category: 'actions'>

	| isFirstSave |
	self critical: 
		[self validate.
		isFirstSave := isNew.
		isFirstSave ifTrue: [self onBeforeFirstSave].
		self onBeforeSave.
		isFirstSave 
		    ifTrue: [Store storeObject: self]
		    ifFalse: [Store updateObject: self].
		isFirstSave ifTrue: [self onAfterFirstSave].
		self onAfterSave.
		^self]
    ]

    save: aBlock [
	<category: 'actions'>
	self critical: 
		[aBlock value.
		^self save]
    ]

    validate [
	"for subclasses to override and throw exceptions to prevent saves"
	<category: 'actions'>

	
    ]

    asReferenceMarker [
	<category: 'converting'>
	isNew 
	    ifTrue: 
		["Programmers may reach this point several times until they
		get the intended use of this solution. This is expected **by
		design** to make atomic saves really small and consistent.
		Commits of active records which have other active records as
		parts (at any deep) are restricted intentionally. They only are
		allowed when all its sub active records are previously commited.
		Only the programmer knows the proper logical commit order for
		his data!! This is not a relational database, if you absolutely
		need several objects to be atomically saved, then you should
		make them all part of a single aggregate, all of your objects
		should not be active records, only your aggregate roots are
		active records...
		http://domaindrivendesign.org/discussion/messageboardarchive/Aggregates.html'"

		SDCommitError 
		    signal: 'An object is being saved while referencing an unsaved peer of type ' 
			    , self class name , '.  You must save that record first!'].
	^(SDRecordMarker new)
	    id: id;
	    className: self class name;
	    environment: self class environment;
	    yourself
    ]

    createdOn [
	<category: 'accessing'>
	^createdOn
    ]

    id [
	<category: 'accessing'>
	^id
    ]

    indexString [
	"All instance variable's asStrings as a single delimeted string for
	easy searching"
	<category: 'accessing'>

	^String streamContents: 
		[:s | 
		self class allInstVarNames do: 
			[:each | 
			(self instVarNamed: each) ifNotNil: 
				[:value | 
				s
				    nextPutAll: value asString;
				    nextPutAll: '~~']]]
    ]

    updatedOn [
	<category: 'accessing'>
	^updatedOn
    ]

    version [
	<category: 'accessing'>
	^version
    ]

    isNew [
	"Only answers true before an objects first save."
	<category: 'testing'>

	^isNew ifNil: [isNew := true]
    ]

    isSandstoneActiveRecord [
	"Answers true if the receiver is a Sandstone Active Record."
	<category: 'testing'>

	^true
    ]

    onAfterDelete [
	"for overriding in subclasses to hook the objects lifecycle"
	<category: 'events'>

	
    ]

    onAfterFirstSave [
	"for overriding in subclasses to hook the objects lifecycle"
	<category: 'events'>

	
    ]

    onAfterSave [
	"for overriding in subclasses to hook the objects lifecycle"
	<category: 'events'>

	
    ]

    onBeforeDelete [
	"for overriding in subclasses to hook the objects lifecycle"
	<category: 'events'>

	
    ]

    onBeforeFirstSave [
	"for overriding in subclasses to hook the objects lifecycle"
	<category: 'events'>

	createdOn := DateTime now
    ]

    onBeforeSave [
	"for overriding in subclasses to hook the objects lifecycle"
	<category: 'events'>

	updatedOn := DateTime now.
	version := version + 1.
	isNew := false
    ]
]



Eval [
    SDActiveRecord initialize
]

PK
     �Mh@q��23  3    Core/Extensions.stUT	 dqXO��XOux �  �  Object extend [
    
    sandstoneDeepCopy [
	<category: '*sandstonedb-serialization'>
    
	"Replaces the receiver (sub) active records
	with Sandstone references where it is needed"
	^self sandstoneDeepCopyVisits: (SDActiveRecord defaultIdentityDictionary new: SDActiveRecord defaultHashSize)
    ]

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	at which point the copying stops, and the actual references is returned."
	| newObject class index value |
	visitedParts at: self ifPresent: [ :it | ^ it ].
	class := self class.
	class isVariable
	    ifTrue:
		[ index := self basicSize.
		newObject := class basicNew: index.
		[ index > 0 ] whileTrue:
		    [ newObject
			basicAt: index
			put: ((self basicAt: index) sandstoneDeepCopyVisits: visitedParts).
		    index := index - 1 ]]
		ifFalse: [ newObject := class basicNew ].
	    visitedParts at: self put: newObject.
	    index := class instSize.
	    [ index > 0 ] whileTrue:
		[ value := self instVarAt: index.
		newObject
		    instVarAt: index
		    put: (value isSandstoneActiveRecord
			ifTrue: [ value ]
			ifFalse: [ value sandstoneDeepCopyVisits: visitedParts ]).
		    index := index - 1].
		^newObject
    ]

    sandstoneMarkReferences [
	<category: '*sandstonedb-serialization'>

	"Replaces the receiver (sub) active records
	with Sandstone references where it is needed"
	^self sandstoneMarkReferencesVisits: 
	    (SDActiveRecord defaultIdentityDictionary new: 
		SDActiveRecord defaultHashSize)
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	"Make components of the introspectee which are
	Sandstone active records to become references.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^ it].
	visitedParts at: self put: self.
	self class allInstVarNames do:
	    [:name |
	    | var |
	    var := self instVarNamed: name.
	    var isSandstoneActiveRecord
		ifTrue:
		    [self
			instVarNamed: name
			put: var asReferenceMarker]
		ifFalse: [var sandstoneMarkReferencesVisits: visitedParts]].
	^self
    ]

    sandstoneResolveReferences [
	<category: '*sandstonedb-serialization'>
	"Replaces the receiver markers with
	active records where it is needed"
	^self sandstoneResolveReferencesVisits: (SDActiveRecord defaultIdentityDictionary new: SDActiveRecord defaultHashSize)
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	"Make components of the introspectee which are
	Sandstone references to active record to become active records.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^ it ].
	visitedParts at: self put: self.
	self class allInstVarNames do:
	    [:name |
	    | var |
	    var := self instVarNamed: name.
	    (var isSandstoneMarker)
		ifTrue:
		    [ self
			instVarNamed: name
			put: var asOriginalObject ]
		ifFalse: [var sandstoneResolveReferencesVisits: visitedParts ]].
	^self
    ]
    
    deservesSandstoneReferenceMark [
	<category: '*sandstonedb-testing'>
	^true
    ]

    isSandstoneActiveRecord [
	<category: '*sandstonedb'>

	"Answers true if the receiver is
	a Sandstone Active Record."
	^false
    ]

    isSandstoneMarker [
	<category: '*sandstonedb'>
	^false
    ]
]

Collection extend [
    
    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
    
	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	at which point the copying stops, and the actual references is returned."
	| newObject |
	visitedParts at: self ifPresent: [:it | ^it ].
	newObject := self copy.
	newObject do:
	    [:each |
	    each isSandstoneActiveRecord ifFalse:
		[ newObject remove: each.
		newObject add: (each sandstoneDeepCopyVisits: visitedParts) ]].
	^newObject
    ]
    
    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>

	"Make components of the introspectee which are
	Sandstone active records to become references.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^self ].
	visitedParts at: self put: self.
	self copy do: [:each |
	    each isSandstoneActiveRecord
		ifTrue: [ self remove: each; add: each asReferenceMarker ]
		ifFalse: [ each sandstoneMarkReferencesVisits: visitedParts ]].
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
    
	"Make components of the introspectee which are
	Sandstone references to active record to become active records.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	"It is crucial to modify the introspectee by iterating a copy of it"
	self copy doWithIndex:
	    [:each :index |
	    each isSandstoneMarker
		ifTrue: [self at: index put: each asOriginalObject ]
		ifFalse: [ each sandstoneResolveReferencesVisits: visitedParts ]].
	^self
    ]
]

Array extend [
    
    deservesSandstoneReferenceMark [
	<category: '*sandstonedb'>
	^ {Array. WeakArray } includes: self class
    ]
]

Boolean extend [

    sandstoneDeepCopy [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]
]

Bag extend [

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	at which point the copying stops, and the actual references is returned."
	| newObject |
	visitedParts at: self ifPresent: [:it | ^ it ].
	newObject := self deepCopy.
	newObject contents sandstoneDeepCopyVisits: visitedParts.
	^newObject
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	"Make components of the introspectee which are
	Sandstone active records to become references.
	Do this deeply (sub components)."
	<category: '*sandstonedb'>

	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	self contents sandstoneMarkReferencesVisits: visitedParts.
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category:'*sandstonedb'>
	"Make components of the introspectee which are
	Sandstone references to active record to become active records.
	Do this deeply (sub components)."

	self class isMeta ifTrue: [^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	self copy contents sandstoneResolveReferencesVisits: visitedParts.
	^self
    ]
]


Character extend [

    sandstoneDeepCopy [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]
]

Dictionary extend [
    
    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>

	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	at which point the copying stops, and the actual references is returned."
	|newObject|
	visitedParts at: self ifPresent: [ :it | ^it].
	newObject := self copy.
	newObject keysAndValuesDo:
	    [:key :each |
	    each isSandstoneActiveRecord ifFalse:
		[newObject 
		    at: key
		    put: (each sandstoneDeepCopyVisits: visitedParts)]].
	^newObject
    ]	

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	
	"Make components of the instrospectee which are
	Sandstone active records to become references.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	self keysAndValuesDo:
	    [:key :each |
	    each isSandstoneActiveRecord
		ifTrue: [self at: key put: each asReferenceMarker]
		ifFalse: [each sandstoneMarkReferencesVisits:  visitedParts]].
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	
	"Make components of the introspectee which are
	Sandstone references to active record to become active records.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	"It is crucial to modify the introspectee by iterating a copy of it"
	self copy keysAndValuesDo:
	    [ :key :each |
	    each isSandstoneMarker
		ifTrue: [self at: key put: each asOriginalObject]
		ifFalse: [each sandstoneResolveReferencesVisits: visitedParts]].
	^self
    ]
]

Integer extend [
    
    asReducedSumOfDigits [
	"Answers the sum of the digits present in the
	decimal representation of the receiver
	but also repeating the procedure if the answers is greater than 9."
	
	^10 <= self
	    ifFalse: [self]
	    ifTrue:
		[self = 10
		    ifTrue: [0]
		    ifFalse:
			[(self printString
			    inject: 0
			    into: [:sum :e | sum + e digitValue ]) asReducedSumOfDigits ]]
    ]
]

LookupKey extend [

    deservesSandstoneReferenceMark [
    <category: '*sandstonedb'>
    ^true
    ]
]

Magnitude extend [
    
    deservesSandstoneReferenceMark [
	<category: '*sandstonedb'>
	^false
    ]
]

Number extend [
    
    sandstoneDeepCopy [
	<category: '*sandstonedb'>
	^self
    ]
	
    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]
    
    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]
]

SequenceableCollection extend [

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	
	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	at which point the copying stops, and the actual references is returned."
	| newObject |
	visitedParts at: self ifPresent: [:it | ^it ].
	newObject := self copy.
	"optimized implementation taking advantaged of ordering"
	newObject doWithIndex:
	    [:each :index |
	    each isSandstoneActiveRecord ifFalse:
		[ newObject at: index put: (each sandstoneDeepCopyVisits: visitedParts)]].
	^newObject
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	
	"Make components of the introspectee which are
	Sandstone active records to become references.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	self doWithIndex:
	    [:each :index |
	    each isSandstoneActiveRecord
		ifTrue: [self at: index put: each asReferenceMarker]
		ifFalse: [each sandstoneMarkReferencesVisits: visitedParts]].
	^self
    ]	
]

Set extend [

    doWithIndex: aBlock [
	<category: 'enumerating'>
	"Support Set enumeration with a counter, even though not ordered"
	| index |
	index := 0.
	self do: [:item | aBlock value: item value: (index := index+1)]
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	
	"Make components of the introspectee which are
	Sandstone references to active record to become active records.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	"It is crucial to modify the introspectee by iterating a copy of it"
	self copy doWithIndex:
	    [:each :index |
	    each isSandstoneMarker
		ifTrue: [self remove: each; add: each asOriginalObject]
		ifFalse: [each sandstoneResolveReferencesVisits: visitedParts]].
	^self
    ]
]

String extend [
    
    sandstoneDeepCopy [
	<category: '*sandstonedb-serialization'>
	^self shallowCopy
    ]

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	^self shallowCopy
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	^self
    ]
]

UndefinedObject extend [
    
    sandstoneDeepCopy [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]
]
PK
     �Mh@�yF��  �    Core/SDAbstractStore.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDAbstractStore class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



Object subclass: SDAbstractStore [
    
    <category: 'SandstoneDb-Core'>
    <comment: 'I''m an abstract store to define what''s necessary to plug in a
    new method of storing active records.  When records are stored, they are
    already sliced out of the graph and have markers for any other references
    placed in them.  The store can serialize however it sees fit, but when
    loading, before returning the version from the store, it should resolve
    the references.'''>

    SDAbstractStore class >> new [
	<category: 'initialize-release'>
	^self basicNew initialize
    ]

    initialize []

    abortChanges: anObject [
	<category: 'actions'>
	self subclassResponsibility
    ]

    commit: aBlock [
	<category: 'actions'>
	self subclassResponsibility
    ]

    ensureDown [
	<category: 'actions'>
	
    ]

    ensureForClass: aClass [
	"at startUp, the store is sent this message to tell it to make sure it's ready to run, a
	 file store for instance may want to make sure it's directories exist"

	<category: 'actions'>
	self subclassResponsibility
    ]

    loadClass: aClass atId: anId [
	"Given a class and an Id, the store is expected to load a fresh copy of the object
	 from it's persistent medium'"

	<category: 'actions'>
	self subclassResponsibility
    ]

    recoverForClass: aClass [
	"The store is expected to loop through all it's stored instances of a class and
	 load them via cachedLoadFrom: on the class which will dispatch back to
	 loadObjectOfClass:atId on the store when a cached version of the object is not found.
	 This happens once per class at system startup"

	<category: 'actions'>
	self subclassResponsibility
    ]

    removeObject: anObject [
	<category: 'actions'>
	self subclassResponsibility
    ]

    storeObject: anObject [
	<category: 'actions'>
	self subclassResponsibility
    ]

    updateObject: anObject [
	<category: 'actions'>
	self subclassResponsibility
    ]

    defaultCacheSize [
	<category: 'defaults'>
	^10000
    ]

    forClass: aClass [
	<category: 'delegated queries'>
	self subclassResponsibility
    ]

    forClass: aClass at: anId ifAbsent: aHandler [
	<category: 'delegated queries'>
	self subclassResponsibility
    ]

    forClass: aClass detect: aBlock ifFound: aHandler [
	<category: 'delegated queries'>
	self subclassResponsibility
    ]

    forClass: aClass detect: aBlock ifNone: aHandler [
	<category: 'delegated queries'>
	self subclassResponsibility
    ]

    forClass: aClass do: aBlock [
	<category: 'delegated queries'>
	
    ]

    forClass: aClass findAll: aBlock [
	<category: 'delegated queries'>
	self subclassResponsibility
    ]
]

PK
     �Mh@{#��      Core/SDLoadError.stUT	 dqXO��XOux �  �  "======================================================================
|
|   SandstoneDb.SDLoadError class definition
|
 ======================================================================"

"======================================================================
|
| Copyright (c) 2008-2009 
| Ramon Leon <ramon.leon@allresnet.com>,
| 
|  Ported by:
|
| Sebastien Audier <sebastien.audier@gmail.com>
| Nicolas Petton   <petton.nicolas@gmail.com>
|
| Permission is hereby granted, free of charge, to any person obtaining
| a copy of this software and associated documentation files (the 
| 'Software'), to deal in the Software without restriction, including 
| without limitation the rights to use, copy, modify, merge, publish, 
| distribute, sublicense, and/or sell copies of the Software, and to 
| permit persons to whom the Software is furnished to do so, subject to 
| the following conditions:
|
| The above copyright notice and this permission notice shall be 
| included in all copies or substantial portions of the Software.
|
| THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, 
| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.  
|
 ======================================================================"



SDError subclass: SDLoadError [
    
    <comment: 'I''m thrown when an object fails to load from disk, either
    because the file was corrupt or because it was deleted.'>
    <category: 'SandstoneDb-Core'>
]

PK
     �[h@�Q�=              ��    package.xmlUT ��XOux �  �  PK
     �[h@                     �AW  Tests/UT ��XOux �  �  PK
     �Mh@�D��P  P            ���  Tests/SDMemoryStoreTest.stUT dqXOux �  �  PK
     �Mh@|wF�/  /            ��;  Tests/SDActiveRecordTest.stUT dqXOux �  �  PK
     �Mh@�<�E�  �            ���<  Tests/SDPersonMock.stUT dqXOux �  �  PK
     �Mh@���N-  -            ���U  Tests/FooObject.stUT dqXOux �  �  PK
     �Mh@OZ�M�  �            ��E]  Tests/SDWomanMock.stUT dqXOux �  �  PK
     �Mh@آ��  �            ��9d  Tests/SDChildMock.stUT dqXOux �  �  PK
     �Mh@F���  �            ��,k  Tests/SDGrandChildMock.stUT dqXOux �  �  PK
     �Mh@��C;�  �            ��.r  Tests/SDFileStoreTest.stUT dqXOux �  �  PK
     �Mh@���4c   c             ���  Tests/Extensions.stUT dqXOux �  �  PK
     �Mh@js���  �            ����  Tests/SDManMock.stUT dqXOux �  �  PK
     �[h@                     �A��  Store/UT ��XOux �  �  PK
     �Mh@�Y��s  s            ���  Store/SDMemoryStore.stUT dqXOux �  �  PK
     �Mh@�8u_$  _$            ����  Store/SDFileStore.stUT dqXOux �  �  PK
     �[h@                     �AZ�  Core/UT ��XOux �  �  PK
     �Mh@����  �            ����  Core/SDCommitError.stUT dqXOux �  �  PK
     �Mh@/���  �            ����  Core/SDRecordMarker.stUT dqXOux �  �  PK
     �Mh@gXmİ  �            ���  Core/SDError.stUT dqXOux �  �  PK
     �Mh@G΁��  �            ����  Core/SDConcurrentDictionary.stUT dqXOux �  �  PK
     �Mh@L�>  >            ���  Core/SDCachedStore.stUT dqXOux �  �  PK
     �Mh@BC<s  s            ����  Core/SDCheckPointer.stUT dqXOux �  �  PK
     �Mh@�<�_�  �            ��\ Core/UUID.stUT dqXOux �  �  PK
     �Mh@��K{)  )            ��� Core/SDActiveRecord.stUT dqXOux �  �  PK
     �Mh@q��23  3            ���D Core/Extensions.stUT dqXOux �  �  PK
     �Mh@�yF��  �            ��[x Core/SDAbstractStore.stUT dqXOux �  �  PK
     �Mh@{#��              ��A� Core/SDLoadError.stUT dqXOux �  �  PK      c	  ��   