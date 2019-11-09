'From Objectworks for Smalltalk-80(tm), Version 2.5 of 29 July 1989 on 10 April 1999 at 6:46:24 pm'!

((CxxSystemOrganization tree childNamed: 'spaces') ~= nil) ifTrue: [
	(CxxSystemOrganization tree childNamed: 'spaces') destroyFiles]!

Heaper subclass: #Arrangement
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-arrange'!
Arrangement comment:
'Generally represents a pair of an OrderSpec and a Region.  Arrangements map between regions and primArrays.'!

(Arrangement getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #DEFERRED; add: #COPY; yourself)!

!Arrangement methodsFor: 'accessing'!

{void} copyElements: toArray {PrimArray} with: toDsp {Dsp}
	with: fromArray {PrimArray} with: fromArrange {Arrangement} with: fromRegion {XnRegion}
	
	"Copy elements into toArray arranged according to the receiver. 
	 Copy them from fromArray arranged according to fromArrange.  
	 The source region is fromRegion.  It gets tranformed by toDsp
	 into the toArray."
	
	fromRegion stepper forEach: 
		[:key {Position} |
		toArray at: (self indexOf: (toDsp of: key)) DOTasLong
			storeValue: (fromArray fetchValue: (fromArrange indexOf: key) DOTasLong)]!

{IntegerVar} indexOf: position {Position unused}
	"Return the index of position into my Region according to my OrderSpec."

	self subclassResponsibility!

{IntegerRegion} indicesOf: region {XnRegion}
	"Return the region of all the indices corresponding to positions in region."

	self subclassResponsibility!

{XnRegion} keysOf: start {Int32} with: stop {Int32}
	"Return the region that corresponds to a range of indices."

	self subclassResponsibility!

{XnRegion} region
	"The region of positions in the arrangement"
	
	self subclassResponsibility! !

!Arrangement methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^Heaper takeOop! !

!Arrangement methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !Arrangement subclass: #ExplicitArrangement
	instanceVariableNames: 'myPositions {PtrArray of: Position}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!

(ExplicitArrangement getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!ExplicitArrangement methodsFor: 'create'!

create: positions {PtrArray of: Position}

	super create.
	myPositions := positions.! !

!ExplicitArrangement methodsFor: 'accessing'!

{IntegerVar} indexOf: position {Position}

	Int32Zero almostTo: myPositions count do: [ :i {Int32} |
		(position isEqual: (myPositions fetch: i)) ifTrue:
			[^i]].
	Heaper BLAST: #NotFound.
	^ -1 "compiler fodder"!

{IntegerRegion} indicesOf: region {XnRegion}

	| result {IntegerRegion} |
	result := IntegerRegion make.
	Int32Zero almostTo: myPositions count do: [ :i {Int32} |
		(region hasMember: ((myPositions fetch: i) cast: Position)) ifTrue:
			[result := (result with: i integer) cast: IntegerRegion]].
	^result!

{XnRegion} keysOf: start {Int32} with: stop {Int32}

	| result {XnRegion} |
	result := NULL.
	start almostTo: stop do: [ :i {Int32} |
		result == NULL ifTrue:
			[result := ((myPositions fetch: i) cast: Position) asRegion]
		ifFalse:
			[result := result with: ((myPositions fetch: i) cast: Position)]].
	result == NULL ifTrue:
		[Heaper BLAST: #IndexOutOfBounds].
	^result!

{XnRegion} region

	| result {XnRegion} |
	result := (myPositions get: Int32Zero) cast: XnRegion.
	1 almostTo: myPositions count do: [ :i {Int32} |
		result := result with: ((myPositions get: i) cast: Position)].
	^result! !

!ExplicitArrangement methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^ myPositions contentsHash!

{UInt32} hashForEqual
	^ myPositions contentsHash!

{BooleanVar} isEqual: other {Heaper}
	other cast: ExplicitArrangement
		  into: [:o {ExplicitArrangement} |
		  	^ myPositions contentsEqual: o positions]
		  others: [^ false ].
	^ false "fodder"! !

!ExplicitArrangement methodsFor: 'private: accessing'!

{PtrArray} positions
	^ myPositions! !

!ExplicitArrangement methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myPositions _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myPositions.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ExplicitArrangement class
	instanceVariableNames: ''!

(ExplicitArrangement getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!ExplicitArrangement class methodsFor: 'create'!

{Arrangement} make: positions {PtrArray of: Position} 
	^self create: positions! !Arrangement subclass: #IntegerArrangement
	instanceVariableNames: '
		myOrdering {OrderSpec}
		myRegion {IntegerRegion}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Integers'!

(IntegerArrangement getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!IntegerArrangement methodsFor: 'accessing'!

{void} copyElements: toArray {PrimArray} with: toDsp {Dsp}
	with: fromArray {PrimArray} with: fromArrange {Arrangement} with: fromRegion {XnRegion}
	
	| other {IntegerArrangement} start {Int32} stop {Int32} toStart {Int32} |
	other _ fromArrange cast: IntegerArrangement.
	(myOrdering isEqual: other ordering) ifFalse: [self unimplemented].
	(myRegion isSimple and: [other region isSimple and: [fromRegion isSimple]]) ifFalse: [self unimplemented].
	self knownBug.  "Assume ascending for the moment."
	start _ (fromArrange indexOf: (fromRegion chooseOne: myOrdering)) DOTasLong.
	stop _ (fromArrange indexOf: (fromRegion chooseOne: myOrdering reversed)) DOTasLong.
	toStart _ (self indexOf: (toDsp of: (fromRegion chooseOne: myOrdering))) DOTasLong.
	"stop < start ifTrue: [| tmp {Int32} | tmp _ start.  start _ stop.  stop _ tmp]."
	toArray at: toStart
		storeMany: fromArray 
		with: stop + 1 - start
		with: start!

{IntegerVar} indexOf: position {Position}
	"Return the index of position into my Region according to my OrderSpec."

	| sum {IntegerVar} intPos {IntegerVar} |
	sum _ IntegerVar0.
	intPos _ (position cast: IntegerPos) asIntegerVar.
	(myRegion simpleRegions: myOrdering) forEach: 
		[:region {IntegerRegion} |
		(region hasIntMember: intPos)
			ifTrue: [^sum + (intPos - ((region chooseOne: myOrdering) cast: IntegerPos) asIntegerVar) abs]
			ifFalse: [sum _ sum + region count]].
	Heaper BLAST: #NotInTable.
	^ -1 "compiler fodder"!

{IntegerRegion} indicesOf: region {XnRegion}
	"Return the region of all the indices corresponding to positions in region."

	Someone shouldImplement.
	^NULL "fodder"!

{XnRegion} keysOf: start {Int32} with: stop {Int32}
	"Return the region that corresponds to a range of indices."

	| offset {Int32} left {Int32} right {Int32} | 
	offset _ start.
	left _ -1.
	(myRegion simpleRegions: myOrdering) forEach: 
		[:region {XnRegion} |
		region count <= offset 
			ifTrue: [offset _ offset - region count DOTasLong]
			ifFalse:
				[left == -1 
					ifTrue: 
						[left _ ((region chooseOne: myOrdering) cast: IntegerPos) asIntegerVar DOTasLong + offset.
						offset _ stop - (start - offset).
						offset <= region count DOTasLong ifTrue: 
							[^IntegerRegion make: left 
									with: (((region chooseOne: myOrdering) cast: IntegerPos) asIntegerVar + offset)]]
					ifFalse:
						[right _ ((region chooseOne: myOrdering) cast: IntegerPos) asIntegerVar DOTasLong + offset.
						^IntegerRegion make: left with: right]]].
	Heaper BLAST: #NotInTable.
	^ NULL "compiler fodder"!

{OrderSpec} ordering
	^myOrdering!

{XnRegion} region
	^myRegion! !

!IntegerArrangement methodsFor: 'printing'!

{void} printOn: oo {ostream reference}
	oo << self getCategory name << '(' << myRegion << ', ' << myOrdering << ')'! !

!IntegerArrangement methodsFor: 'protected: creation'!

create: region {XnRegion} with: ordering {OrderSpec}
	super create.
	region isFinite ifFalse: [Heaper BLAST: #MustBeFinite].
	myRegion _ region cast: IntegerRegion.
	myOrdering _ ordering! !

!IntegerArrangement methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^ myOrdering hashForEqual + myRegion hashForEqual!

{UInt32} hashForEqual
	^ myOrdering hashForEqual + myRegion hashForEqual!

{BooleanVar} isEqual: other {Heaper}
	other cast: IntegerArrangement
		  into: [:o {IntegerArrangement} |
		  	^ (myOrdering isEqual: o ordering) and: [myRegion isEqual: o region]]
		  others: [^ false].
	^ false "fodder"! !

!IntegerArrangement methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myOrdering _ receiver receiveHeaper.
	myRegion _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myOrdering.
	xmtr sendHeaper: myRegion.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

IntegerArrangement class
	instanceVariableNames: ''!

(IntegerArrangement getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!IntegerArrangement class methodsFor: 'creation'!

make: region {XnRegion} with: ordering {OrderSpec} 
	^self create: region with: ordering! !Stepper subclass: #AscendingIntegerStepper
	instanceVariableNames: '
		myEdges {IntegerVarArray}
		myIndex {UInt32}
		myCount {UInt32}
		myPosition {IntegerVar}'
	classVariableNames: 'SomeSteppers {InstanceCache} '
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Integers'!

(AscendingIntegerStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; yourself)!

!AscendingIntegerStepper methodsFor: 'protected: creation'!

create: edges {IntegerVarArray} with: count {UInt32}

	super create.
	myEdges _ edges.
	myIndex _ 1.
	myCount _ count.
	myCount > Int32Zero
		ifTrue: [myPosition _ myEdges integerVarAt: Int32Zero]
		ifFalse: [myPosition _ IntegerVar0]!

create: edges {IntegerVarArray} with: index {UInt32} with: count {UInt32} with: position {IntegerVar}
	super create.
	myEdges _ edges.
	myIndex _ index.
	myCount _ count.
	myPosition _ position! !

!AscendingIntegerStepper methodsFor: 'creation'!

{Stepper} copy
	| result {Heaper} |
	result := SomeSteppers fetch.
	result == NULL
		ifTrue: [^AscendingIntegerStepper create: myEdges with: myIndex with: myCount with: myPosition]
		ifFalse:[^(AscendingIntegerStepper new.Become: result) create: myEdges with: myIndex with: myCount with: myPosition]!

{void} destroy
	(SomeSteppers store: self) ifFalse: [super destroy]! !

!AscendingIntegerStepper methodsFor: 'accessing'!

{Heaper wimpy} fetch
	self hasValue ifTrue: [^myPosition integer] ifFalse: [^NULL]!

{BooleanVar} hasValue
	^myIndex <= myCount!

{void} step
	myPosition _ myPosition + 1.
	(myIndex < myCount and: [myPosition = (myEdges integerVarAt: myIndex)]) ifTrue:
		[myIndex _ myIndex + 2.
		myIndex <= myCount ifTrue:
			[myPosition _ myEdges integerVarAt: myIndex - 1]]! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AscendingIntegerStepper class
	instanceVariableNames: ''!

(AscendingIntegerStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; yourself)!

!AscendingIntegerStepper class methodsFor: 'smalltalk: init'!

initTimeNonInherited
	SomeSteppers := InstanceCache make: 16!

linkTimeNonInherited
	SomeSteppers := NULL! !

!AscendingIntegerStepper class methodsFor: 'creation'!

{Stepper} make: edges {IntegerVarArray} with: count {UInt32}
	| result {Heaper} |
	result := SomeSteppers fetch.
	result == NULL
		ifTrue: [^ self create: edges with: count]
		ifFalse: [^ (self new.Become: result) create: edges with: count]! !Accumulator subclass: #BoxAccumulator
	instanceVariableNames: '
		mySpace {CrossSpace}
		myRegions {PtrArray of: XnRegion}
		myIndex {Int32}'
	classVariableNames: 'SomeAccumulators {InstanceCache} '
	poolDictionaries: ''
	category: 'Xanadu-cross'!
BoxAccumulator comment:
'was NOT.A.TYPE but this prevented compilation '!

(BoxAccumulator getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; yourself)!

!BoxAccumulator methodsFor: 'creation'!

{Accumulator} copy
	| result {Heaper} |
	result := SomeAccumulators fetch.
	result == NULL
		ifTrue: [^BoxAccumulator create: mySpace with: (myRegions copy cast: PtrArray) with: myIndex]
		ifFalse: [^(BoxAccumulator new.Become: result) create: mySpace with: (myRegions copy cast: PtrArray) with: myIndex]! !

!BoxAccumulator methodsFor: 'protected: creation'!

create: region {GenericCrossRegion}

	super create.
	mySpace := region crossSpace.
	myRegions := region secretRegions copy cast: PtrArray.
	myIndex := region boxCount.!

create: space {CrossSpace} with: expectedBoxCount {Int32}

	super create.
	mySpace := space.
	myRegions := PtrArray nulls: space axisCount * expectedBoxCount.
	myIndex := Int32Zero.!

create: space {CrossSpace}
	with: regions {PtrArray unused of: XnRegion}
	with: expectedBoxCount {Int32}

	super create.
	mySpace := space.
	myRegions := PtrArray nulls: space axisCount * expectedBoxCount.
	myIndex := Int32Zero.
	Ravi shouldImplement. "shouldn't we be doing something with the 'regios' argument?"! !

!BoxAccumulator methodsFor: 'private:'!

{void} aboutToAdd
	"Make sure there is room to add a box"
	
	myIndex * mySpace axisCount < myRegions count ifFalse:
		[myRegions := (myRegions copyGrow: (myIndex + 1) * mySpace axisCount) cast: PtrArray].!

{Int32} addSubstitutedBox: current {Int32} with: dimension {Int32}
	with: newRegion {XnRegion}
	"Add a new box which is just like a current one except for the projection on one dimension. Return its index"
	
	self aboutToAdd.
	myRegions at: myIndex * mySpace axisCount
		storeMany: myRegions
		with: mySpace axisCount
		with: current * mySpace axisCount.
	myRegions at: myIndex * mySpace axisCount + dimension
		store: newRegion.
	myIndex := myIndex + 1.
	^myIndex - 1!

{Int32} boxCount

	self knownBug. "includes deleted boxes"
	^myIndex!

{XnRegion} boxProjection: box {Int32} with: dimension {Int32}
	"Change a projection of a box"
	
	^(myRegions fetch: box * mySpace axisCount + dimension) cast: XnRegion!

{void} deleteBox: box {Int32}
	"Mark a box as deleted"
	
	myRegions at: box * mySpace axisCount store: NULL!

{BooleanVar} distributeUnion: added {Int32}
	with: start {Int32}
	with: stop {Int32}
	
	"Take my box at added
		and distribute it over my existing boxes from start to stop - 1
		meanwhile taking pieces out of my box at remainder
			and delete it if it becomes empty
	Return true if there is still something left in the remainder"
	
	start almostTo: stop do: [ :index {Int32} |
		(self splitUnion: added with: index with: stop)
			ifFalse: [^false]].
	^true!

{Int32} index

	^myIndex!

{BooleanVar} isDeleted: box {Int32}
	"Whether the box has been deleted"
	
	^(myRegions fetch: box * mySpace axisCount) == NULL!

{PtrArray of: XnRegion} secretRegions

	^myRegions!

{BooleanVar} splitUnion: added {Int32}
	with: current {Int32}
	with: stop {Int32}
	
	"Take my box at added
		and union it with my box at current
		delete it if it becomes empty
	Return true if there is still something left in the added box"
	
	| dimension {Int32} addedRegion {XnRegion} currentRegion {XnRegion} common {XnRegion}
	  newAdded {Int32} extraCurrent {XnRegion} extraAdded {XnRegion} |
	
	(self isDeleted: current) ifTrue: [^true].
	dimension := Int32Zero.
	[dimension + 1 < mySpace axisCount] whileTrue:
		["see if the added intersects the current in this dimension"
		addedRegion := self boxProjection: added with: dimension.
		currentRegion := self boxProjection: current with: dimension.
		self thingToDo. "Add protocol for tri-delta: gives triple (a-b, a&b, b-a)"
		common := addedRegion intersect: currentRegion.
		common isEmpty ifTrue:
			[^true].
		
		"split out the part of current that doesn't intersect"
		extraCurrent := currentRegion minus: common.
		extraCurrent isEmpty ifFalse:
			[self addSubstitutedBox: current
				with: dimension with: extraCurrent.
			self storeBoxProjection: current with: dimension with: common].
		
		"split out the part of the added that doesn't intersect"
		extraAdded := addedRegion minus: common.
		extraAdded isEmpty ifFalse:
			[newAdded := self addSubstitutedBox: added
				with: dimension with: extraAdded.
			self distributeUnion: newAdded with: current + 1 with: stop.
			self storeBoxProjection: added with: dimension with: common].
		
		dimension := dimension + 1].
	
	"union the added into the last dimension of the current box"
	addedRegion := self boxProjection: added with: dimension.
	currentRegion := self boxProjection: current with: dimension.
	self storeBoxProjection: current with: dimension with: (currentRegion unionWith: addedRegion).
	self deleteBox: added.
	^false!

{void} storeBoxProjection: box {Int32} with: dimension {Int32} with: region {XnRegion}
	"Change a projection of a box"
	
	myRegions at: box * mySpace axisCount + dimension store: region!

{void} tryMergeBoxes: i {Int32} with: j {Int32}
	"If two boxes differ by only one projection, union the second into the first and delete the second"
	
	| unequal {Int32} |
	unequal := -1.
	Int32Zero almostTo: mySpace axisCount do: [ :dim {Int32} |
		((self boxProjection: i with: dim) isEqual: (self boxProjection: j with: dim))
			ifFalse:
				[unequal >= Int32Zero
					ifTrue: [^VOID].
				unequal := dim]].
	self storeBoxProjection: i with: unequal
		with: ((self boxProjection: i with: unequal)
			unionWith: (self boxProjection: j with: unequal)).
	self deleteBox: j.! !

!BoxAccumulator methodsFor: 'operations'!

{void} addAccumulatedBoxes: other {BoxAccumulator}
	"Add in all the boxes in another accumulator"
	
	Int32Zero almostTo: other index do: [ :box {Int32} |
		(other isDeleted: box) ifFalse:
			[self aboutToAdd.
			myRegions at: myIndex * mySpace axisCount
				storeMany: other secretRegions
				with: mySpace axisCount
				with: box * mySpace axisCount.
			myIndex := myIndex + 1]]!

{Int32} addBox: box {BoxStepper}
	"Add the current box to the end of the array"
	
	^self addProjections: box region secretRegions
		with: box boxIndex!

{void} addInverseTransformedBox: box {BoxStepper} with: dsp {GenericCrossDsp}
	"Add the current box, transformed by the inverse of the dsp"
	
	| base {Int32} |
	self aboutToAdd.
	base := mySpace axisCount * myIndex.
	Int32Zero almostTo: mySpace axisCount do: [ :dimension {Int32} |
		myRegions at: base + dimension
			store: ((dsp subMapping: dimension) inverseOfAll: (box projection: dimension))].
	myIndex := myIndex + 1.!

{Int32} addProjections: projections {PtrArray of: XnRegion}
	with: boxIndex {Int32}
	"Add a box to the end of the array"
	
	self aboutToAdd.
	myRegions at: myIndex * mySpace axisCount
		storeMany: projections
		with: mySpace axisCount
		with: boxIndex * mySpace axisCount.
	myIndex := myIndex + 1.
	^myIndex - 1!

{void} addTransformedBox: box {BoxStepper} with: dsp {GenericCrossDsp}
	"Add the current box, transformed by the dsp"
	
	| base {Int32} |
	self aboutToAdd.
	base := myIndex * mySpace axisCount.
	Int32Zero almostTo: mySpace axisCount do: [ :dimension {Int32} |
		myRegions at: base + dimension
			store: ((dsp subMapping: dimension) ofAll: (box projection: dimension))].
	myIndex := myIndex + 1.!

{void} intersectWithBox: box {BoxStepper}
	"Intersect the current region with a box. May leave the result uncanonicalized"
	
	Int32Zero almostTo: myIndex do: [ :i {Int32} |
		(box intersectBoxInto: myRegions with: i) ifFalse:
			[self deleteBox: i]].!

{void} mergeBoxes
	"merge boxes which differ in only one projection"
	
	Ravi thingToDo. "hash lookup"
	Int32Zero almostTo: myIndex do: [ :i {Int32} |
		(self isDeleted: i) ifFalse:
			[Int32Zero almostTo: myIndex do: [ :j {Int32} |
				(i == j or: [self isDeleted: j]) ifFalse:
					[self tryMergeBoxes: i with: j]]]]!

{XnRegion} region
	"The current region in the accumulator. CLIENT MUST KNOW THAT IT IS CANONICAL"
	
	^GenericCrossRegion make: mySpace
		with: myIndex
		with: ((myRegions copy: myIndex * mySpace axisCount) cast: PtrArray)!

{void} removeDeleted
	"Remove boxes which have been deleted"
	
	| to {Int32} from {Int32} |
	from := to := Int32Zero.
	[from < myIndex] whileTrue:
		[(self isDeleted: from)  ifFalse:
			[from > to ifTrue:
				[myRegions at: to * mySpace axisCount
					storeMany: myRegions
					with: mySpace axisCount
					with: from * mySpace axisCount].
			to := to + 1].
		from := from + 1].
	myIndex := to!

{void} step: someObj {Heaper}

	self unionWithBoxes: (someObj cast: GenericCrossRegion) boxStepper!

{void} unionWithBox: box {BoxStepper}
	"Add the current box to the accumulator"
	
	| initialIndex {Int32} addedIndex {Int32} |
	initialIndex := myIndex.
	addedIndex := self addBox: box.
	self distributeUnion: addedIndex with: Int32Zero with: initialIndex.!

{void} unionWithBoxes: boxes {BoxStepper}
	"Add a sequence of disjoint boxes to the accumulator"
	
	myIndex = Int32Zero ifTrue:
		[[boxes hasValue] whileTrue:
			[self addBox: boxes.
			boxes step]]
	ifFalse:
		[[boxes hasValue]
			whileTrue:
				[self unionWithBox: boxes.
				boxes step]]!

{Heaper} value

	^self region! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

BoxAccumulator class
	instanceVariableNames: ''!

(BoxAccumulator getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; yourself)!

!BoxAccumulator class methodsFor: 'smalltalk: init'!

initTimeNonInherited
	SomeAccumulators := InstanceCache make: 8!

linkTimeNonInherited
	SomeAccumulators := NULL! !

!BoxAccumulator class methodsFor: 'creation'!

make: region {GenericCrossRegion}
	| result {Heaper} |
	result := SomeAccumulators fetch.
	result == NULL
		ifTrue: [^ self create: region]
		ifFalse: [^ (self new.Become: result) create: region]!

make: space {CrossSpace} with: expectedBoxCount {Int32}
	| result {Heaper} |
	result := SomeAccumulators fetch.
	result == NULL
		ifTrue: [^ self create: space with: expectedBoxCount]
		ifFalse: [^ (self new.Become: result) create: space with: expectedBoxCount]! !Stepper subclass: #BoxProjectionStepper
	instanceVariableNames: '
		myRegion {GenericCrossRegion}
		myBoxIndex {Int32}
		myBoxLimit {Int32}
		myDimension {Int32}'
	classVariableNames: 'SomeSteppers {InstanceCache} '
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Cross'!
BoxProjectionStepper comment:
'Steps over all projections of some boxes. was not.a.type but this prevented compilation'!

(BoxProjectionStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; yourself)!

!BoxProjectionStepper methodsFor: 'create'!

{Stepper} copy
	"Return a new stepper which steps independently of me, but whose current 
	value is the same as mine, and which must produce a future history of values 
	which satisfies the same obligation that my contract obligates me to produce 
	now. Typically, this will mean that he must produce the same future history 
	that I'm going to produce. However, let's say that I am enumerating the 
	elements of a partial order in some full order which is consistent with the 
	partial order. If a copy of me is made after I'm part way through, then me 
	and my copy may produce any future history compatable both with the partial 
	order and the elements I've already produced by the time of the copy. Of 
	course, a subclass or a Stepper creating message (like 
	IntegerRegion::stepper()) may specify the more stringent requirement (that a 
	copy must produce the same sequence). 
	
	To prevent aliasing, Steppers should typically be passed by copy. See class 
	comment."

	Someone shouldImplement.
	^NULL "fodder"!

{void} destroy
	(SomeSteppers store: self) ifFalse: [super destroy]! !

!BoxProjectionStepper methodsFor: 'protected: create'!

create: region {GenericCrossRegion}
	
	super create.
	myRegion := region.
	myBoxIndex := Int32Zero.
	myBoxLimit := region boxCount.
	myDimension := Int32Zero.!

create: region {GenericCrossRegion}
	with: boxIndex {Int32}
	with: boxLimit {Int32}
	
	super create.
	myRegion := region.
	myBoxIndex := boxIndex.
	myBoxLimit := boxLimit.
	myDimension := Int32Zero.!

create: region {GenericCrossRegion}
	with: boxIndex {Int32}
	with: boxLimit {Int32}
	with: dimension {Int32}
	
	super create.
	myRegion := region.
	myBoxIndex := boxIndex.
	myBoxLimit := boxLimit.
	myDimension := dimension.! !

!BoxProjectionStepper methodsFor: 'operations'!

{Heaper wimpy} fetch

	myBoxIndex < myBoxLimit ifFalse:
		[^NULL].
	^self projection!

{BooleanVar} hasValue

	^myBoxIndex < myBoxLimit!

{void} step

	myBoxIndex < myBoxLimit ifTrue:
		[myDimension := myDimension + 1.
		myDimension < myRegion crossSpace axisCount ifFalse:
			[myBoxIndex := myBoxIndex + 1.
			myDimension := Int32Zero]].! !

!BoxProjectionStepper methodsFor: 'accessing'!

{Int32} dimension

	^myDimension!

{XnRegion} projection

	^myRegion boxProjection: myBoxIndex with: myDimension! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

BoxProjectionStepper class
	instanceVariableNames: ''!

(BoxProjectionStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; yourself)!

!BoxProjectionStepper class methodsFor: 'create'!

make: region {GenericCrossRegion}
	| result {Heaper} |
	result := SomeSteppers fetch.
	result == NULL
		ifTrue: [^ self create: region]
		ifFalse: [^ (self new.Become: result) create: region]!

make: region {GenericCrossRegion}
	with: boxIndex {Int32}
	with: boxLimit {Int32}
	| result {Heaper} |
	result := SomeSteppers fetch.
	result == NULL
		ifTrue: [^ self create: region with: boxIndex with: boxLimit]
		ifFalse: [^ (self new.Become: result) create: region with: boxIndex with: boxLimit]! !

!BoxProjectionStepper class methodsFor: 'smalltalk: init'!

initTimeNonInherited
	SomeSteppers := InstanceCache make: 8!

linkTimeNonInherited
	SomeSteppers := NULL! !Stepper subclass: #BoxStepper
	instanceVariableNames: '
		myRegion {GenericCrossRegion}
		myIndex {Int32}
		myValue {XnRegion | NULL}'
	classVariableNames: 'SomeSteppers {InstanceCache} '
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Cross'!
BoxStepper comment:
'Steps over all boxes. was NOT.A.TYPE but this prevented compilation'!

(BoxStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; yourself)!

!BoxStepper methodsFor: 'operations'!

{Heaper wimpy} fetch

	myIndex >= myRegion boxCount
		ifTrue: [^NULL].
	myValue == NULL ifTrue:
		[myValue := GenericCrossRegion
						make: myRegion crossSpace
						with: 1
						with: ((myRegion secretRegions
											copy: myRegion crossSpace axisCount
											with: myIndex * myRegion crossSpace axisCount) cast: PtrArray)].
	^myValue!

{BooleanVar} hasValue

	^myIndex < myRegion boxCount!

{void} step

	myIndex < myRegion boxCount ifTrue:
		[myIndex := myIndex + 1.
		myValue := NULL]! !

!BoxStepper methodsFor: 'create'!

{Stepper} copy
	| result {Heaper} |
	result := SomeSteppers fetch.
	result == NULL
		ifTrue: [^BoxStepper create: myRegion with: myIndex with: myValue]
		ifFalse: [^(BoxStepper new.Become: result) create: myRegion with: myIndex with: myValue]!

{void} destroy
	(SomeSteppers store: self) ifFalse: [super destroy]! !

!BoxStepper methodsFor: 'protected: create'!

create: region {GenericCrossRegion}
	
	super create.
	myRegion := region.
	myIndex := Int32Zero.
	myValue := NULL.!

create: region {GenericCrossRegion} with: index {Int32} with: value {XnRegion | NULL}
	
	super create.
	myRegion := region.
	myIndex := index.
	myValue := value.! !

!BoxStepper methodsFor: 'accessing'!

{GenericCrossRegion} boxComplement
	"The complement of this box"
	
	| result {BoxAccumulator} extrusion {PtrArray of: XnRegion} |
	result := BoxAccumulator make: myRegion crossSpace
		with: myRegion crossSpace axisCount.
	Int32Zero almostTo: myRegion crossSpace axisCount do:
		[ :dimension {Int32} | | special {XnRegion} |
		extrusion := PtrArray nulls: myRegion crossSpace axisCount.
		Int32Zero almostTo: dimension do: [ :i {Int32} |
			extrusion at: i store: (self projection: i)].
		special := (self projection: dimension) complement.
		special isEmpty ifFalse:
			[extrusion at: dimension store: special.
			dimension + 1 almostTo: myRegion crossSpace axisCount do: [ :i {Int32} |
				extrusion at: i store: (myRegion crossSpace axis: i) fullRegion].
			result addProjections: extrusion with: Int32Zero]].
	^result region cast: GenericCrossRegion!

{BoxAccumulator} boxComplementAccumulator
	"The complement of this box"
	
	| result {BoxAccumulator} extrusion {PtrArray of: XnRegion} |
	result := BoxAccumulator make: myRegion crossSpace
		with: myRegion crossSpace axisCount.
	Int32Zero almostTo: myRegion crossSpace axisCount do: [ :dimension {Int32} |
		extrusion := PtrArray nulls: myRegion crossSpace axisCount.
		Int32Zero almostTo: dimension do: [ :i {Int32} |
			extrusion at: i store: (self projection: i)].
		extrusion at: dimension store: (self projection: dimension) complement.
		dimension + 1 almostTo: myRegion crossSpace axisCount do: [ :i {Int32} |
			extrusion at: i store: (myRegion crossSpace axis: i) fullRegion].
		result addProjections: extrusion with: Int32Zero].
	^result!

{UInt32} boxHash

	| result {UInt32} |
	result := UInt32Zero.
	self projectionStepper forEach: [ :sub {XnRegion} |
		result := result bitXor: sub hashForEqual].
	^result!

{BooleanVar} boxHasMember: tuple {ActualTuple}
	"Whether my current box contains a position"
	
	| mine {BoxProjectionStepper} |
	mine := self projectionStepper.
	[mine hasValue] whileTrue:
		[(mine projection hasMember: (tuple positionAt: mine dimension)) ifFalse:
			[^false].
		mine step].
	mine destroy.
	^true!

{Int32} boxIndex

	^myIndex!

{BooleanVar} boxIntersects: other {BoxStepper}
	"Whether my current box intersects others current box"
	
	| mine {BoxProjectionStepper} others {BoxProjectionStepper} |
	mine := self projectionStepper.
	others := other projectionStepper.
	[mine hasValue] whileTrue:
		[(mine projection intersects: others projection) ifFalse:
			[^false].
		mine step.
		others step].
	mine destroy.
	others destroy.
	^true!

{BooleanVar} boxIsEqual: other {BoxStepper}
	"Whether my current box isEqual others current box"
	
	| mine {BoxProjectionStepper} others {BoxProjectionStepper} |
	mine := self projectionStepper.
	others := other projectionStepper.
	[mine hasValue] whileTrue:
		[(mine projection isEqual: others projection) ifFalse:
			[^false].
		mine step.
		others step].
	mine destroy.
	others destroy.
	^true!

{BooleanVar} boxIsSubsetOf: other {BoxStepper}
	"Whether my current box isSubsetOf others current box"
	
	| mine {BoxProjectionStepper} others {BoxProjectionStepper} |
	mine := self projectionStepper.
	others := other projectionStepper.
	[mine hasValue] whileTrue:
		[(mine projection isSubsetOf: others projection) ifFalse:
			[^false].
		mine step.
		others step].
	mine destroy.
	others destroy.
	^true!

{BooleanVar} intersectBoxInto: result {PtrArray of: XnRegion} with: boxIndex {Int32}
	"Intersect each projection in the box into the array. Return false if the result is empty, stopping at the first dimension for which the intersection is empty."
	
	| mine {BoxProjectionStepper} proj {XnRegion} base {Int32} |
	base := myRegion crossSpace axisCount * boxIndex.
	mine := self projectionStepper.
	[mine hasValue] whileTrue:
		[result at: base + mine dimension
			store: (proj := ((result fetch: base + mine dimension) cast: XnRegion)
				intersect: mine projection).
		proj isEmpty ifTrue: [^false].
		mine step].
	mine destroy.
	^true!

{BooleanVar} isBoxOf: other {GenericCrossRegion}
	"Whether my box is also a box in the other region"
	
	| others {BoxStepper} |
	others := other boxStepper.
	[others hasValue] whileTrue:
		[(self boxIsEqual: others)
			ifTrue: [^true].
		others step].
	^false!

{XnRegion} projection: dimension {Int32}
	"The projection of my current box into one dimension"
	
	^myRegion boxProjection: myIndex with: dimension!

{BoxProjectionStepper} projectionStepper
	"A stepper over all the projections in the current box"
	
	^BoxProjectionStepper make: myRegion
		with: myIndex
		with: myIndex + 1!

{GenericCrossRegion} region

	^myRegion!

{void} unionBoxInto: result {PtrArray of: XnRegion} with: boxIndex {Int32}
	"Union each projection in the box into the array"
	
	| mine {BoxProjectionStepper} base {Int32} |
	base := myRegion crossSpace axisCount * boxIndex.
	mine := self projectionStepper.
	[mine hasValue] whileTrue:
		[result at: base + mine dimension
			store: (((result fetch: base + mine dimension) cast: XnRegion)
				unionWith: mine projection).
		mine step].
	mine destroy.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

BoxStepper class
	instanceVariableNames: ''!

(BoxStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; yourself)!

!BoxStepper class methodsFor: 'smalltalk: init'!

initTimeNonInherited
	SomeSteppers := InstanceCache make: 8!

linkTimeNonInherited
	SomeSteppers := NULL! !

!BoxStepper class methodsFor: 'create'!

make: region {GenericCrossRegion}
	| result {Heaper} |
	result := SomeSteppers fetch.
	result == NULL
		ifTrue: [^ self create: region]
		ifFalse: [^ (self new.Become: result) create: region]! !Heaper subclass: #CoordinateSpace
	instanceVariableNames: '
		myEmptyRegion {XnRegion}
		myFullRegion {XnRegion}
		myIdentityDsp {Dsp}
		myAscending {OrderSpec | NULL}
		myDescending {OrderSpec | NULL}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Basic'!
CoordinateSpace comment:
'A coordinate space represents (among other things) the domain space of a table. Corresponding to each coordinate space will be a set of objects of the following kinds:
	
	Position -- The elements of the coordinate space.
	Mapping -- (Add a description.)
	OrderSpec -- The ways of specifying partial orders of this coordinate space''s Positions.
	XuRegion -- An XuRegion represents a set of Positions.  The domain of a table is an XuRegion.
	
	When defining a new coordinate space class, one generally defines new corresponing subclasses of each of the above classes.  A kind of any of the above classes knows what coordinate space it is a part of (the "coordinateSpace()" message will yield an appropriate kind of CoordinateSpace).  CoordinateSpace objects exist mostly just to represent this commonality.  Coordinate spaces are disjoint--it is an error to use any of the generic protocol of any of the above classes if the objects in question are of two different coordinate spaces.  For example, "dsp->of (pos)" is not an error iff "dsp->coordinateSpace()->isEqual (pos->coordinateSpace())".
	
Note that this class is not COPY or even PSEUDO_COPY.  All of the instance variables for CoordinateSpace are basically cached
quantities that require vary little actual state from the derived classes in order to be constructed.  This realization allows a knot
to be untangled when reading these objects from external storage.'!

(CoordinateSpace getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; yourself)!

!CoordinateSpace methodsFor: 'accessing'!

{UInt32} actualHashForEqual

	^Heaper takeOop!

{OrderSpec CLIENT INLINE} ascending
	"Essential.  The natural full-ordering of the coordinate space."
	
	^self getAscending!

{Mapping CLIENT INLINE} completeMapping: range {XnRegion}
	"Essential. A Mapping which maps each position in this space to every position in the range region. The region can be from any CoordinateSpace."
	
	^Mapping make.CoordinateSpace: self with.Region: range!

{OrderSpec CLIENT INLINE} descending
	"The mirror image of the partial order returned by 'CoordinateSpace::ascending'."
	
	^self getDescending!

{XnRegion CLIENT INLINE} emptyRegion
	"Essential.  An empty region in this coordinate space"
	
	^myEmptyRegion!

{(OrderSpec | NULL) INLINE} fetchAscending
	"The natural full-ordering of the coordinate space."

	^myAscending!

{(OrderSpec | NULL) INLINE} fetchDescending
	"The mirror image of the partial order returned by 
	'CoordinateSpace::fetchAscending'."

	^myDescending!

{XnRegion CLIENT INLINE} fullRegion
	"A full region in this coordinate space"
	
	^myFullRegion!

{OrderSpec} getAscending
	"Essential.  The natural full-ordering of the coordinate space."
	
	| result {OrderSpec | NULL} |
	result := self fetchAscending.
	result == NULL ifTrue:
		[Heaper BLAST: #NoFullOrder].
	^result!

{OrderSpec} getDescending
	"The mirror image of the partial order returned by 'CoordinateSpace::getAscending'."
	
	| result {OrderSpec | NULL} |
	result := self fetchDescending.
	result == NULL ifTrue:
		[Heaper BLAST: #NoFullOrder].
	^result!

{Dsp INLINE} identityDsp
	"A Dsp which maps all positions in the coordinate space onto themselves"
	
	^myIdentityDsp!

{Mapping CLIENT INLINE} identityMapping
	"Essential.  A Mapping which maps all positions in the coordinate space onto themselves"
	
	^self identityDsp!

{BooleanVar} isEqual: other{Heaper}

	self subclassResponsibility!

{BooleanVar} verify: thing {Heaper}
	"tell whether this is a valid Position/XuRegion/Dsp/OrderSpec for this space"

	thing cast: (Position | XnRegion | Dsp | OrderSpec) into: [:t |
			^self isEqual: t coordinateSpace].
	"cast into blasts here."
	^false! !

!CoordinateSpace methodsFor: 'smalltalk: defaults'!

create: emptyRegion {XnRegion}
	with: fullRegion {XnRegion}
	with: identityDsp {Dsp}
	
	self create: emptyRegion with: fullRegion with: identityDsp with: NULL with: NULL!

create: emptyRegion {XnRegion}
	with: fullRegion {XnRegion}
	with: identityDsp {Dsp}
	with: ascending {OrderSpec default: NULL}
	
	self create: emptyRegion with: fullRegion with: identityDsp with: ascending with: NULL! !

!CoordinateSpace methodsFor: 'protected: create followup'!

{void} finishCreate: emptyRegion {XnRegion}
	with: fullRegion {XnRegion}
	with: identityDsp {Dsp}
	with: ascending {OrderSpec default: NULL}
	with: descending {OrderSpec default: NULL}
	
	myEmptyRegion := emptyRegion.
	myFullRegion := fullRegion.
	myIdentityDsp := identityDsp.
	myAscending := ascending.
	(descending == NULL and: [ascending ~~ NULL]) ifTrue:
		[myDescending := ascending reversed]
	ifFalse:
		[myDescending := descending].! !

!CoordinateSpace methodsFor: 'create'!

create
	
	super create.
	myEmptyRegion := NULL.
	myFullRegion := NULL.
	myIdentityDsp := NULL.
	myAscending := NULL.
	myDescending := NULL.!

create: emptyRegion {XnRegion}
	with: fullRegion {XnRegion}
	with: identityDsp {Dsp}
	with: ascending {OrderSpec default: NULL}
	with: descending {OrderSpec default: NULL}
	
	super create.
	myEmptyRegion := emptyRegion.
	myFullRegion := fullRegion.
	myIdentityDsp := identityDsp.
	myAscending := ascending.
	(descending == NULL and: [ascending ~~ NULL]) ifTrue:
		[myDescending := ascending reversed]
	ifFalse:
		[myDescending := descending].! !

!CoordinateSpace methodsFor: 'smalltalk: passe'!

{Mapping} importMapping: data {PrimArray} with: rangeSpace {CoordinateSpace default: NULL}

	self passe!

{OrderSpec} importOrderSpec: data {PrimArray}

	self passe!

{XnRegion} importRegion: data {PrimArray}

	self passe!

{Mapping} mapping: data {PrimArray}

	self passe!

{Mapping} mapping: data {PrimArray} with: rangeSpace {CoordinateSpace default: NULL}

	self passe!

{OrderSpec} orderSpec: data {PrimArray}

	self passe!

{XnRegion} region: data {PrimArray}

	self passe! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

CoordinateSpace class
	instanceVariableNames: ''!

(CoordinateSpace getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; yourself)!

!CoordinateSpace class methodsFor: 'smalltalk: system'!

info.stProtocol
"{OrderSpec CLIENT} ascending
{Mapping CLIENT} completeMapping: range {XuRegion}
{OrderSpec CLIENT} descending
{XuRegion CLIENT} emptyRegion
{XuRegion CLIENT} fullRegion
{Mapping CLIENT} identityMapping
"! !CoordinateSpace subclass: #BasicSpace
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Basic'!
BasicSpace comment:
'BasicSpace versus CoordinateSpace is not a type distinction in that there is no difference in contract with the client.  BasicSpace exists as a convenience to the definer of new CoordinateSpaces.  A new subclass of CoordinateSpace should be a subclass of BasicSpace iff there is only one coordinateSpace that corresponds to the new class.  I.e., that the instances are not parameterized to yield different coordinate spaces.  BasicSpace provides some conveniences (especially in Smalltalk) for defining a single canonical instance at dynamic initialization time, and always using it.
	
	As this class is irrelevent to CoordinateSpace clients, but is useful to those defining other kinds of coordinate spaces, it is an exellent example of something that would be classified as a "protected" class--something to be persued if we try to make modules more like classes.'!

(BasicSpace getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #OBSOLETE; add: #SMALLTALK.ONLY; add: #CONCRETE; add: #NOT.A.TYPE; yourself)!

!BasicSpace methodsFor: 'testing'!

{UInt32} actualHashForEqual
	"is equal to any basic space on the same category of positions"

	^self getCategory hashForEqual + 1!

{BooleanVar} isEqual: anObject {Heaper}
	"is equal to any basic space on the same category of positions"

	^anObject getCategory == self getCategory! !

!BasicSpace methodsFor: 'creation'!

create: emptyRegion {XnRegion}
	with: fullRegion {XnRegion}
	with: identityDsp {Dsp}
	with: ascending {OrderSpec default: NULL}
	with: descending {OrderSpec default: NULL}
	
	super create: emptyRegion with: fullRegion with: identityDsp with: ascending with: descending.! !

!BasicSpace methodsFor: 'smalltalk: defaults'!

create: emptyRegion {XnRegion}
	with: fullRegion {XnRegion}
	with: identityDsp {Dsp}
	
	self create: emptyRegion with: fullRegion with: identityDsp with: NULL with: NULL!

create: emptyRegion {XnRegion}
	with: fullRegion {XnRegion}
	with: identityDsp {Dsp}
	with: ascending {OrderSpec default: NULL}
	
	self create: emptyRegion with: fullRegion with: identityDsp with: ascending with: NULL! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

BasicSpace class
	instanceVariableNames: 'theSpace {BasicSpace star} '!

(BasicSpace getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #OBSOLETE; add: #SMALLTALK.ONLY; add: #CONCRETE; add: #NOT.A.TYPE; yourself)!

!BasicSpace class methodsFor: 'smalltalk: initialization'!

initTimeInherited

	self REQUIRES: PrimSpec.
	theSpace _ (self new.AllocType: #PERSISTENT) create.!

linkTimeInherited

	theSpace _ NULL.!

suppressInitTimeInherited!

suppressLinkTimeInherited! !CoordinateSpace subclass: #CrossSpace
	instanceVariableNames: 'mySubSpaces {PtrArray of: CoordinateSpace}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Cross'!
CrossSpace comment:
'Represents the cross of several coordinate spaces.  '!

(CrossSpace getOrMakeCxxClassDescription)
	friends:
'friend class BoxAccumulator;
friend class BoxStepper;
friend class GenericCrossSpace;
friend class GenericCrossRegion;
friend class BoxProjectionStepper;';
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; yourself)!

!CrossSpace methodsFor: 'accessing'!

{PtrArray CLIENT of: CoordinateSpace} axes
	"Essential.  The base spaces that I am a cross of."

	^mySubSpaces copy cast: PtrArray!

{CoordinateSpace CLIENT} axis: dimension {Int32}
	"The sub coordinate space on the given axis"
	
	^(mySubSpaces fetch: dimension) cast: CoordinateSpace!

{Int32 CLIENT INLINE} axisCount
	"The number of dimensions in this space"
	
	^mySubSpaces count! !

!CrossSpace methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^mySubSpaces contentsHash bitXor: #cat.U.CrossSpace hashForEqual!

{BooleanVar} isEqual: other {Heaper}
	
	other 
		cast: CrossSpace into: [:cross |
			^cross secretSubSpaces contentsEqual: mySubSpaces]
		others: [^false].
	^ false "compiler fodder"! !

!CrossSpace methodsFor: 'making'!

{Mapping CLIENT} crossOfMappings: subMappings {(PtrArray of: Mapping | NULL) default: NULL}
	"Essential.  Map each coordinate according to the mapping from its space.  NULLs mean 'use the identity mapping'"
	
	self subclassResponsibility!

{CrossOrderSpec CLIENT} crossOfOrderSpecs: subOrderings {(PtrArray of: OrderSpec | NULL) default: NULL}
	with: subSpaceOrdering {PrimIntArray default: NULL}
	"Essential.  Make a lexical ordering of all elements in the space, using the given ordering for each sub space. If no sub space ordering is given, then it is in the order they are in the array.
	
	subSpaceOrdering lists the lexicographic order in which each dimension should be processed.  Every dimension should be listed exactly one, from most significant (at index 0) to least significant.

	subOrderings are indexed by *dimension*, not by lexicographic order.  In order to index by lex order, look up the dimension in subSpaceOrdering, and then look up the resulting dimension number in subOrderings."
	
	self subclassResponsibility!

{Tuple CLIENT} crossOfPositions: coordinates {PtrArray of: Position}
	"Essential. Make an individual position"
	
	self subclassResponsibility!

{CrossRegion CLIENT} crossOfRegions: subRegions {PtrArray of: XnRegion | NULL}
	"Essential. Make a 'rectangular' region as a cross of all the given regions"
	
	self subclassResponsibility!

{CrossRegion CLIENT} extrusion: dimension {Int32} with: subRegion {XnRegion}
	"Return a region whose projection is 'subRegion' along 'dimension', but is full on all other dimensions"
	
	self subclassResponsibility! !

!CrossSpace methodsFor: 'smalltalk: passe'!

{IntegerVar} count

	self passe "axisCount"!

{Int32} intCount

	self passe "axisCount"!

{CrossMapping} makeCrossMapping: subMappings {PtrArray of: Mapping}
	
	self passe!

{CrossOrderSpec} makeCrossOrderSpec: subOrderings {PtrArray of: OrderSpec | NULL}
	with: subSpaceOrdering {Int32Array default: NULL}
	"Make a lexical ordering of all elements in the space, using the given ordering for each sub space. If no sub space ordering is given, then it is in the order they are in the array"
	
	self passe!

{CrossRegion} makeCrossRegion: subRegions {PtrArray of: XnRegion | NULL}
	"Make a 'rectangular' region as a cross of all the given regions"
	
	self passe!

{Tuple} makeTuple: coordinates {PtrArray of: Position}
	"Make an individual position"
	
	self passe!

{CoordinateSpace} subSpace: dimension {Int32}

	self passe "axis"!

{PtrArray of: CoordinateSpace} subSpaces

	self passe "axes"! !

!CrossSpace methodsFor: 'smalltalk: defaults'!

{Mapping CLIENT} crossOfMappings

	^self crossOfMappings: NULL!

{CrossOrderSpec CLIENT} crossOfOrderSpecs

	^self crossOfOrderSpecs: NULL with: NULL!

{CrossOrderSpec CLIENT} crossOfOrderSpecs: subOrderings {(PtrArray of: OrderSpec | NULL) default: NULL}


	^self crossOfOrderSpecs: subOrderings with: NULL! !

!CrossSpace methodsFor: 'protected: accessing'!

{PtrArray INLINE of: CoordinateSpace} secretSubSpaces
	"The actual array of sub spaces. DO NOT MODIFY"
	
	^mySubSpaces! !

!CrossSpace methodsFor: 'protected: creation'!

create
	
	super create.
	mySubSpaces := NULL.!

create: subSpaces {PtrArray of: CoordinateSpace}
	
	super create.
	mySubSpaces := subSpaces.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

CrossSpace class
	instanceVariableNames: ''!

(CrossSpace getOrMakeCxxClassDescription)
	friends:
'friend class BoxAccumulator;
friend class BoxStepper;
friend class GenericCrossSpace;
friend class GenericCrossRegion;
friend class BoxProjectionStepper;';
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; yourself)!

!CrossSpace class methodsFor: 'creation'!

{CrossSpace CLIENT} make: subSpaces {PtrArray of: CoordinateSpace}
	"Make a cross space with the given list of subspaces"
	 "Should use middlemen.  Just hard code special cases for now"
	 
	^GenericCrossSpace make: (subSpaces copy cast: PtrArray)!

make: zeroSpace {CoordinateSpace} with: oneSpace {CoordinateSpace}
	"Cross two sub spaces"
	
	^GenericCrossSpace create: ((PrimSpec pointer
		arrayWithTwo: zeroSpace with: oneSpace) cast: PtrArray)! !

!CrossSpace class methodsFor: 'smalltalk: system'!

info.stProtocol
"{PtrArray CLIENT of: CoordinateSpace} axes
{CoordinateSpace CLIENT} axis: dimension {Int32}
{Int32 CLIENT} axisCount
{Mapping CLIENT} crossOfMappings
{Mapping CLIENT} crossOfMappings: subMappings {(PtrArray of: Mapping | NULL)
		default: NULL}
{CrossOrderSpec CLIENT} crossOfOrderSpecs
{CrossOrderSpec CLIENT} crossOfOrderSpecs: subOrderings {(PtrArray of: OrderSpec | NULL)
		default: NULL}
{CrossOrderSpec CLIENT} crossOfOrderSpecs: subOrderings {(PtrArray of: OrderSpec | NULL)
		default: NULL} with: subSpaceOrdering {Int32Array default: NULL}
{Tuple CLIENT} crossOfPositions: coordinates {PtrArray of: Position}
{CrossRegion CLIENT} crossOfRegions: subRegions {PtrArray of: XuRegion | NULL}
{CrossRegion CLIENT} extrusion: dimension {Int32} with: subRegion {XuRegion}
"! !CrossSpace subclass: #GenericCrossSpace
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Cross'!
GenericCrossSpace comment:
'Default implementation of cross coordinate space.
was NOT.A.TYPE but that prevented compilation'!

(GenericCrossSpace getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #PSEUDO.COPY; yourself)!

!GenericCrossSpace methodsFor: 'making'!

{Mapping} crossOfMappings: subMappings {(PtrArray of: Mapping | NULL) default: NULL}

	subMappings == NULL ifTrue:
		[^CrossMapping make: self].
	Int32Zero almostTo: subMappings count do: [:i {Int32} |
		| subM {Mapping | NULL} |
		subM := (subMappings fetch: i) cast: Mapping.
		(subM ~~ NULL and: [(subM isKindOf: Dsp) not]) ifTrue:
			[MarkM shouldImplement]].
	^CrossMapping make: self with: subMappings!

{CrossOrderSpec} crossOfOrderSpecs: subOrderings {(PtrArray of: OrderSpec | NULL) default: NULL}
	with: subSpaceOrdering {PrimIntArray default: NULL}
	
	^CrossOrderSpec make: self with: subOrderings with: subSpaceOrdering!

{Tuple} crossOfPositions: coordinates {PtrArray of: Position}
	
	^ActualTuple make: coordinates!

{CrossRegion} crossOfRegions: subRegions {PtrArray of: XnRegion | NULL}
	
	| result {PtrArray of: XnRegion} |
	result := subRegions copy cast: PtrArray.
	Int32Zero almostTo: result count do: [ :dimension {Int32} |
		(result fetch: dimension) == NULL ifTrue:
			[result at: dimension
				store: (self axis: dimension) fullRegion]
		ifFalse: [((result fetch: dimension) cast: XnRegion) isEmpty ifTrue:
			[^self emptyRegion cast: CrossRegion]]].
	^GenericCrossRegion make: self with: 1 with: result!

{CrossRegion} extrusion: dimension {Int32} with: subRegion {XnRegion}
	
	| projs {PtrArray of: XnRegion} |
	subRegion isEmpty ifTrue: [^self emptyRegion cast: CrossRegion].
	projs := PtrArray nulls: mySubSpaces count.
	Int32Zero almostTo: mySubSpaces count do: [ :i {Int32} |
		i = dimension ifTrue:
			[projs at: i store: subRegion]
		ifFalse:
			[projs at: i
				store: ((mySubSpaces fetch: i) cast: CoordinateSpace) fullRegion]].
	^GenericCrossRegion make: self with: 1 with: projs! !

!GenericCrossSpace methodsFor: 'private: creation'!

create: subSpaces {PtrArray of: CoordinateSpace}
	
	super create: subSpaces.
	self finishCreate: (GenericCrossRegion empty: self)
		with: (GenericCrossRegion full: self with: subSpaces)
		with: (GenericCrossDsp identity: self with: subSpaces)
		with: (CrossOrderSpec fetchAscending: self with: subSpaces)
		with: (CrossOrderSpec fetchDescending: self with: subSpaces).! !

!GenericCrossSpace methodsFor: 'printing'!

{void} printOn: oo {ostream reference}

	oo << '<'.
	Int32Zero almostTo: mySubSpaces count do: [ :i {Int32} |
		i > Int32Zero ifTrue: [oo << ' x '].
		oo << (mySubSpaces fetch: i)].
	oo << '>'! !

!GenericCrossSpace methodsFor: 'hooks:'!

{void SEND.HOOK} sendGenericCrossSpaceTo: xmtr {Xmtr}

	xmtr sendHeaper: mySubSpaces.! !

!GenericCrossSpace methodsFor: 'generated:'!

{void} sendSelfTo: xmtr {Xmtr}
	
	self sendGenericCrossSpaceTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GenericCrossSpace class
	instanceVariableNames: ''!

(GenericCrossSpace getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #PSEUDO.COPY; yourself)!

!GenericCrossSpace class methodsFor: 'rcvr pseudoconstructors'!

{Heaper} make.Rcvr: rcvr {Rcvr}

	^(GenericCrossSpace new.Become: ((rcvr cast: SpecialistRcvr) makeIbid: GenericCrossSpace))
		 create: (rcvr receiveHeaper cast: PtrArray)! !

!GenericCrossSpace class methodsFor: 'pseudoconstructors'!

{CrossSpace} make: subSpaces {PtrArray of: CoordinateSpace}

	^GenericCrossSpace create: subSpaces! !CoordinateSpace subclass: #FilterSpace
	instanceVariableNames: 'myBaseSpace {CoordinateSpace}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Filter'!
FilterSpace comment:
'A FilterSpace can be described mathematically as a power space of its baseSpace, i.e. the set of all subsets of the baseSpace. Each position in a FilterSpace is a Region in the baseSpace, and each Filter is a set of Regions taken from the baseSpace. See Filter for more detail.'!

(FilterSpace getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #PSEUDO.COPY; add: #CONCRETE; add: #ON.CLIENT; yourself)!

!FilterSpace methodsFor: 'creation'!

create: base {CoordinateSpace}
	super create.
	self finishCreate: (ClosedFilter make: self)
		with: (OpenFilter make: self)
		with: (FilterDsp make: self)
		with: NULL
		with: NULL.
	myBaseSpace := base! !

!FilterSpace methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^myBaseSpace hashForEqual + 1!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: FilterSpace into: [:fs |
			^fs baseSpace isEqual: myBaseSpace]
		others: [^false].
	^false "fodder"! !

!FilterSpace methodsFor: 'accessing'!

{CoordinateSpace CLIENT INLINE} baseSpace
	"Essential.  The CoordinateSpace of the Regions that are the input to Filters in this FilterSpace."
	
	^myBaseSpace! !

!FilterSpace methodsFor: 'printing'!

{void} printOn: oo {ostream reference}
	oo << self getCategory name << '(' << myBaseSpace << ')'! !

!FilterSpace methodsFor: 'making'!

{Filter CLIENT INLINE} allFilter: region {XnRegion}
	"Essential. A region that matches any region that contains all the Positions in, i.e. is a superset of, the given region."
	
	^Filter supersetFilter: self with: region!

{Filter CLIENT INLINE} anyFilter: baseRegion {XnRegion}
	"Essential. A filter that matches any region that intersects the given region."
	
	^Filter intersectionFilter: self with: baseRegion!

{Filter INLINE} intersectionFilter: region {XnRegion}
	"Essential. A filter that matches any region that intersects the given region."
	
	^Filter intersectionFilter: self with: region!

{Filter INLINE} notSubsetFilter: region {XnRegion}
	"A filter matching any regions that is not a subset of the given region."
	
	^Filter notSubsetFilter: self with: region!

{Filter INLINE} notSupersetFilter: region {XnRegion}
	"A filter that matches any region that is not a superset of the given region."
	
	^Filter notSupersetFilter: self with: region!

{Filter INLINE} orFilter: subs {ScruSet of: Filter}
	"A filter that matches any region that any of the filters in the set would have matched."
	
	^Filter orFilter: self with: subs!

{FilterPosition CLIENT INLINE} position: baseRegion {XnRegion}
	"Essential. Given a Region in the baseSpace, make a Position which corresponds to it, so that
		filter->hasMember (this->position (baseRegion)) iff filter->match (baseRegion)"
	
	^FilterPosition make: baseRegion!

{Filter INLINE} subsetFilter: region {XnRegion}
	"A filter that matches any region that is a subset of the given region."
	
	^Filter subsetFilter: self with: region!

{Filter INLINE} supersetFilter: region {XnRegion}
	"Essential. A region that matches any region that is a superset of the given region."
	
	^Filter supersetFilter: self with: region! !

!FilterSpace methodsFor: 'hooks:'!

{void SEND.HOOK} sendFilterSpaceTo: xmtr {Xmtr}
	xmtr sendHeaper: myBaseSpace.! !

!FilterSpace methodsFor: 'generated:'!

{void} sendSelfTo: xmtr {Xmtr}
	
	self sendFilterSpaceTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

FilterSpace class
	instanceVariableNames: ''!

(FilterSpace getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #PSEUDO.COPY; add: #CONCRETE; add: #ON.CLIENT; yourself)!

!FilterSpace class methodsFor: 'creation'!

{FilterSpace CLIENT} make: base {CoordinateSpace}
	"A FilterSpace on the given base space."
	
	^FilterSpace create: base! !

!FilterSpace class methodsFor: 'smalltalk: system'!

info.stProtocol
"{Filter CLIENT} andFilter: baseRegion {XnRegion}
{Filter CLIENT} anyFilter: baseRegion {XnRegion}
{CoordinateSpace CLIENT} baseSpace
{FilterPosition CLIENT} position: baseRegion {XnRegion}
"! !

!FilterSpace class methodsFor: 'rcvr pseudo constructors'!

{Heaper} make.Rcvr: rcvr {Rcvr}
	^(FilterSpace new.Become: ((rcvr cast: SpecialistRcvr) makeIbid: FilterSpace))
		 create: (rcvr receiveHeaper cast: CoordinateSpace)! !CoordinateSpace subclass: #HeaperSpace
	instanceVariableNames: ''
	classVariableNames: 'TheHeaperSpace {HeaperSpace} '
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Unordered'!
HeaperSpace comment:
'A HeaperSpace is one whose positions represent the identity of individual Heapers.  Identity of a Heaper is determined according by its response to "isEqual" and "hashForEqual" (see "The Equality of Decisions" for a bunch of surprising issues regarding Heaper equality).  A region is a HeaperSpace is a SetRegion (see SetRegion).  As a result of having HeaperSpaces, one can use the identity of Heapers to index into hash tables, and still obey the convention that a table maps from positions in some coordinate space.
	
	HeaperSpaces cannot (yet?) be used as the domain space for Xanadu Stamps, and therefore also not as the domain space of an IndexedWaldo.  In order to do this, the Heapers in question would have to persist in a way that Xanadu doesn''t provide for.
	
	As is typical for an unordered space, the only Dsp for this space is the identity Dsp.  No type or pseudo-constructor is exported however--the Dsp is gotten by converting a HeaperSpace to a Dsp.  Similarly, no heaper-specific type or pseudo-constructor is exported for my regions.  The conversions are sufficient.  The resulting regions are guaranteed to be SetRegions.'!

(HeaperSpace getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #PSEUDO.COPY; yourself)!

!HeaperSpace methodsFor: 'creation'!

create

	super create: HeaperRegion make
		with: HeaperRegion make complement
		with: HeaperDsp make
		with: NULL
		with: NULL! !

!HeaperSpace methodsFor: 'testing'!

{UInt32} actualHashForEqual
	"is equal to any basic space on the same category of positions"

	^self getCategory hashForEqual + 1!

{BooleanVar} isEqual: anObject {Heaper}
	"is equal to any basic space on the same category of positions"

	^anObject getCategory == self getCategory! !

!HeaperSpace methodsFor: 'generated:'!

{void} sendSelfTo: xmtr {Xmtr}! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HeaperSpace class
	instanceVariableNames: ''!

(HeaperSpace getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #PSEUDO.COPY; yourself)!

!HeaperSpace class methodsFor: 'smalltalk: init'!

initTimeNonInherited

	TheHeaperSpace := self create!

linkTimeNonInherited

	TheHeaperSpace := NULL! !

!HeaperSpace class methodsFor: 'pseudo constructors'!

{HeaperSpace INLINE} make
	"Return the one instance of HeaperSpace"
	
	^TheHeaperSpace! !

!HeaperSpace class methodsFor: 'rcvr pseudo constructor'!

{Heaper} make.Rcvr: rcvr {Rcvr}
	(rcvr cast: SpecialistRcvr) registerIbid: TheHeaperSpace.
	^TheHeaperSpace! !CoordinateSpace subclass: #IntegerSpace
	instanceVariableNames: ''
	classVariableNames: 'TheIntegerSpace {IntegerSpace} '
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Integers'!
IntegerSpace comment:
'The space of all integers.  See the class comments in IntegerRegion, XuInteger, and IntegerDsp for interesting properties of this space.  Especially IntegerRegion.
	
	IntegerSpaces are the most frequently used of the coordinate spaces.  XuArrays are an efficient data structure which we provide as a table whose domain space is an integer space.  In so doing, the notion of an array is made to be simply a particular case of a table indexed by the positions of a coordinate space.  However, IntegerSpaces and XuArrays are both expected to be more efficient than other spaces and tables built on other spaces.  See XuArray'!

(IntegerSpace getOrMakeCxxClassDescription)
	friends:
'/* friends for class IntegerSpace */

friend class IntegerRegion;
friend class IntegerDsp;
';
	attributes: ((Set new) add: #PSEUDO.COPY; add: #CONCRETE; add: #ON.CLIENT; yourself)!

!IntegerSpace methodsFor: 'creation'!

create

	super create: (IntegerRegion usingx: false with: Int32Zero
			with: (IntegerVarArray zeros: Int32Zero))
		with: (IntegerRegion usingx: true with: Int32Zero
			with: (IntegerVarArray zeros: Int32Zero))
		with: IntegerMapping identity
		with: IntegerUpOrder make! !

!IntegerSpace methodsFor: 'making'!

{IntegerRegion CLIENT} above: start {IntegerPos} with: inclusive {BooleanVar}
	"Essential. Make a region that contains all integers greater than (or equal if inclusive is true) to start."
	| after {IntegerVar} |
	after _ start asIntegerVar.
	inclusive ifFalse: [after _ after + 1].
	^IntegerRegion after: after!

{IntegerRegion CLIENT} below: stop {IntegerPos} with: inclusive {BooleanVar}
	"Make a region that contains all integers less than (or equal if inclusive is true) to stop."
	| after {IntegerVar} |
	after _ stop asIntegerVar.
	inclusive ifTrue: [after _ after + 1].
	^IntegerRegion before: after!

{IntegerRegion CLIENT} interval: start {IntegerPos} with: stop {IntegerPos}
	"Make a region that contains all integers greater than or equal to start and less than stop."
	
	^IntegerRegion make: start asIntegerVar with: stop asIntegerVar!

{IntegerPos CLIENT INLINE} position: value {IntegerVar}
	"Essential. Make an integer Position object"
	
	^value integer!

{IntegerMapping CLIENT} translation: value {IntegerVar}
	"Essential. Make a Mapping which adds a fixed amount to any value.
	Should this just be supplanted by CoordinateSpace::mapping ()?"
	
	value = IntegerVarZero ifTrue:
		[^self identityDsp cast: IntegerMapping].
	^IntegerMapping make: value! !

!IntegerSpace methodsFor: 'testing'!

{UInt32} actualHashForEqual
	"is equal to any basic space on the same category of positions"

	^self getCategory hashForEqual + 1!

{BooleanVar} isEqual: anObject {Heaper}
	"is equal to any basic space on the same category of positions"

	^anObject getCategory == self getCategory! !

!IntegerSpace methodsFor: 'smalltalk: passe'!

{IntegerPos} integer: value {IntegerVar}

	self passe "position"! !

!IntegerSpace methodsFor: 'generated:'!

{void} sendSelfTo: xmtr {Xmtr}! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

IntegerSpace class
	instanceVariableNames: ''!

(IntegerSpace getOrMakeCxxClassDescription)
	friends:
'/* friends for class IntegerSpace */

friend class IntegerRegion;
friend class IntegerDsp;
';
	attributes: ((Set new) add: #PSEUDO.COPY; add: #CONCRETE; add: #ON.CLIENT; yourself)!

!IntegerSpace class methodsFor: 'creation'!

{IntegerSpace INLINE} implicitReceiver
	"Get the receievr for wire requests."
	
	^TheIntegerSpace!

{IntegerSpace CLIENT INLINE} make
	"return the one integer space"
	
	^TheIntegerSpace! !

!IntegerSpace class methodsFor: 'rcvr pseudo constructor'!

{Heaper} make.Rcvr: rcvr {Rcvr}
	(rcvr cast: SpecialistRcvr) registerIbid: TheIntegerSpace.
	^TheIntegerSpace! !

!IntegerSpace class methodsFor: 'smalltalk: init'!

initTimeNonInherited

	TheIntegerSpace := self create!

linkTimeNonInherited

	TheIntegerSpace := NULL! !

!IntegerSpace class methodsFor: 'smalltalk: system'!

info.stProtocol
"{IntegerRegion CLIENT} above: start {IntegerVar} with: inclusive {BooleanVar}
{IntegerRegion CLIENT} below: start {IntegerVar} with: inclusive {BooleanVar}
{IntegerRegion CLIENT} interval: start {IntegerVar} with: stop {IntegerVar}
{XuInteger CLIENT} position: value {IntegerVar}
{IntegerMapping CLIENT} translation: value {IntegerVar}
"! !CoordinateSpace subclass: #RealSpace
	instanceVariableNames: ''
	classVariableNames: 'TheRealSpace {RealSpace} '
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!
RealSpace comment:
'Non-arithmetic space of real numbers in which only certain positions are explicitly representable.  In this release, the only exactly representable numbers are those real numbers which can be represented in IEEE64 (double precision) format.  Future releases may make more real numbers representable.'!

(RealSpace getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #PSEUDO.COPY; add: #CONCRETE; add: #ON.CLIENT; yourself)!

!RealSpace methodsFor: 'create'!

create
	
	super create: (RealRegion make: false with: PtrArray empty)
		with: (RealRegion make: true with: PtrArray empty)
		with: RealDsp make
		with: RealUpOrder make! !

!RealSpace methodsFor: 'making'!

{RealRegion CLIENT} above: val {RealPos} with: inclusive {BooleanVar}
	"The region consisting of all positions >= val if inclusive, or all > val if not inclusive."

	inclusive ifTrue:
		[^RealRegion make: false
			with: (PrimSpec pointer arrayWith: (BeforeReal make: val))]
	ifFalse:
		[^RealRegion make: false
			with: (PrimSpec pointer arrayWith: (AfterReal make: val))]!

{RealRegion CLIENT} below: val {RealPos} with: inclusive {BooleanVar}
	"The region consisting of all positions <= val if inclusive, or all < val if not inclusive."

	inclusive ifTrue:
		[^RealRegion make: true
			with: (PrimSpec pointer arrayWith: (AfterReal make: val))]
	ifFalse:
		[^RealRegion make: true
			with: (PrimSpec pointer arrayWith: (BeforeReal make: val))]!

{RealRegion CLIENT} interval: start {RealPos} with: stop {RealPos}
	"Return a region of all numbers >= lower and < upper."
	
	MarkM thingToDo. "use a single constructor"
	^((self above: start with: true) intersect: (self below: stop with: false)) cast: RealRegion!

{RealPos CLIENT INLINE} position: val {IEEE64}
	"The XuReal representing the same real number as that exactly represented by 'val'.  If 'val' doesn't represent a real number (i.e., it is an infinity or a NAN), then this message BLASTs.  If 'val' is a negative zero, it is silently converted to a positive zero"
	
	^RealPos make: val! !

!RealSpace methodsFor: 'obsolete:'!

{RealRegion} after: val {IEEE64}
	"The region consisting of all position >= val.
	Should this just be supplanted by CoordinateSpace::region ()?"

	self thingToDo. "update clients"
	^RealRegion make: false
		with: (PrimSpec pointer arrayWith: (BeforeReal make: (RealPos make: val)))!

{RealRegion} before: val {IEEE64}
	"The region consisting of all position <= val
	Should this just be supplanted by CoordinateSpace::region ()?"

	self thingToDo. "update clients"
	^RealRegion make: true
		with: (PrimSpec pointer arrayWith: (AfterReal make: (RealPos make: val)))!

{RealRegion} strictlyAfter: val {IEEE64}
	"The region consisting of all position > val
	Should this just be supplanted by CoordinateSpace::region ()?
	Add Boolean to after to say whether its inclusive?"

	self thingToDo. "update clients"
	^RealRegion make: false
		with: (PrimSpec pointer arrayWith: (AfterReal make: (RealPos make: val)))!

{RealRegion} strictlyBefore: val {IEEE64}
	"The region consisting of all position < val
	Should this just be supplanted by CoordinateSpace::region ()?
	Add Boolean to before to say whether its inclusive?"

	self thingToDo. "update clients"
	^RealRegion make: true
		with: (PrimSpec pointer arrayWith: (AfterReal make: (RealPos make: val)))! !

!RealSpace methodsFor: 'testing'!

{UInt32} actualHashForEqual
	"is equal to any basic space on the same category of positions"

	^self getCategory hashForEqual + 1!

{BooleanVar} isEqual: anObject {Heaper}
	"is equal to any basic space on the same category of positions"

	^anObject getCategory == self getCategory! !

!RealSpace methodsFor: 'generated:'!

{void} sendSelfTo: xmtr {Xmtr}! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

RealSpace class
	instanceVariableNames: ''!

(RealSpace getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #PSEUDO.COPY; add: #CONCRETE; add: #ON.CLIENT; yourself)!

!RealSpace class methodsFor: 'creation'!

{RealSpace CLIENT INLINE} make

	^TheRealSpace! !

!RealSpace class methodsFor: 'rcvr pseudo constructors'!

{Heaper} make.Rcvr: rcvr {Rcvr}
	(rcvr cast: SpecialistRcvr) registerIbid: TheRealSpace.
	^TheRealSpace! !

!RealSpace class methodsFor: 'smalltalk: init'!

initTimeNonInherited

	self REQUIRES: PrimSpec.
	TheRealSpace := self create!

linkTimeNonInherited

	TheRealSpace := NULL! !

!RealSpace class methodsFor: 'smalltalk: system'!

info.stProtocol
"{RealRegion CLIENT} above: val {IEEE64} with: inclusive {BooleanVar}
{RealRegion CLIENT} below: val {IEEE64} with: inclusive {BooleanVar}
{RealRegion CLIENT} interval: lower {XuRegion} with: upper {XuReal}
{XuReal CLIENT} position: val {IEEE64}
"! !CoordinateSpace subclass: #SequenceSpace
	instanceVariableNames: ''
	classVariableNames: 'TheSequenceSpace {SequenceSpace} '
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!
SequenceSpace comment:
'The space of all Sequences'!

(SequenceSpace getOrMakeCxxClassDescription)
	friends:
'/* friends for class SequenceSpace */

friend class Sequence;
';
	attributes: ((Set new) add: #PSEUDO.COPY; add: #CONCRETE; add: #ON.CLIENT; yourself)!

!SequenceSpace methodsFor: 'create'!

create
	
	super create: (SequenceRegion usingx: false with: PtrArray empty)
		with: (SequenceRegion usingx: true with: PtrArray empty)
		with: (SequenceMapping make: IntegerVarZero with: Sequence zero)
		with: SequenceUpOrder make! !

!SequenceSpace methodsFor: 'temporary'!

{Sequence CLIENT login INLINE} position: numbers {PrimArray}

	^self position: numbers with: IntegerVarZero! !

!SequenceSpace methodsFor: 'making'!

{SequenceRegion CLIENT} above: sequence {Sequence} with: inclusive {BooleanVar}
	"Essential. All sequences >= sequence if inclusive, > sequence if not."
	
	inclusive ifTrue:
		[^SequenceRegion usingx: false
			with: ((PrimSpec pointer arrayWith: (BeforeSequence make: sequence)) cast: PtrArray)]
	ifFalse:
		[^SequenceRegion usingx: false
			with: ((PrimSpec pointer arrayWith: (AfterSequence make: sequence)) cast: PtrArray)]!

{SequenceRegion CLIENT} below: sequence {Sequence} with: inclusive {BooleanVar}
	"Essential. All sequences <= sequence if inclusive, < sequence if not."
	
	inclusive ifTrue:
		[^SequenceRegion usingx: true
			with: ((PrimSpec pointer arrayWith: (AfterSequence make: sequence)) cast: PtrArray)]
	ifFalse:
		[^SequenceRegion usingx: true
			with: ((PrimSpec pointer arrayWith: (BeforeSequence make: sequence)) cast: PtrArray)]!

{SequenceRegion CLIENT} interval: start {Sequence} with: stop {Sequence}
	"Return a region of all sequence >= lower and < upper."
	
	"Ravi thingToDo." "use a single constructor" "Performance"
	^((self above: start with: true)
		intersect: (self below: stop with: false)) cast: SequenceRegion!

{SequenceMapping CLIENT} mapping: shift {IntegerVar}
	with: translation {Sequence default: NULL}
	"A transformation which shifts a value by some number of places and then adds a translation to it."
	
	self thingToDo. "better name for this method"
	translation == NULL ifTrue:
		[^SequenceMapping make: shift with: Sequence zero].
	^SequenceMapping make: shift with: translation!

{Sequence CLIENT login} position: arg {PrimArray}
	with: shift {IntegerVar}
	"Essential. A sequence using the given numbers and shift. Leading and trailing zeros will be stripped, and a copy will be made so that noone modifies it"
	"IntegerVars cannot have default arguments"
	
	| numbers {PrimIntegerArray} |
	numbers _ arg cast: PrimIntegerArray.
	numbers == NULL ifTrue:
		[^Sequence usingx: shift with: (IntegerVarArray zeros: Int32Zero)].
	^Sequence usingx: shift with: (numbers copy cast: PrimIntegerArray)!

{SequenceRegion CLIENT} prefixedBy: sequence {Sequence}
	with: limit {IntegerVar}
	"Essential. All sequences which match the given one up to and including the given index."
	
	^SequenceRegion usingx: false
		with: ((PrimSpec pointer
			arrayWithTwo: (BeforeSequencePrefix below: sequence with: limit)
			with: (BeforeSequencePrefix above: sequence with: limit)) cast: PtrArray)! !

!SequenceSpace methodsFor: 'smalltalk: passe'!

{Sequence} sequence: numbers {PrimIntegerArray | NULL}
	with: shift {IntegerVar | IntegerVarZero}

	self passe "position"!

{SequenceRegion} sequencesAfter: sequence {Sequence}
	"Essential. All sequences greater than or equal to the given sequence.
	Should this just be supplanted by CoordinateSpace::region ()?"
	self passe.
	^SequenceRegion usingx: false
		with: (PrimSpec pointer arrayWith: (BeforeSequence make: sequence))!

{SequenceRegion} sequencesBefore: sequence {Sequence}
	"Essential. All sequences less than or equal to the given sequence.
	Should this just be supplanted by CoordinateSpace::region ()?"
	
	self passe.
	^SequenceRegion usingx: true
		with: (PrimSpec pointer arrayWith: (AfterSequence make: sequence))!

{SequenceRegion} sequencesPrefixedBy: sequence {Sequence}
	with: limit {IntegerVar}
	"Essential. All sequences which match the given one up to and including the given index.
	Should this just be supplanted by CoordinateSpace::region ()?"
	self passe.
	^SequenceRegion usingx: false
		with: (PrimSpec pointer
			arrayWithTwo: (BeforeSequencePrefix below: sequence with: limit)
			with: (BeforeSequencePrefix above: sequence with: limit))!

{SequenceMapping} shiftAndTranslation

	self passe!

{SequenceDsp} shiftAndTranslation: shift {IntegerVar}

	self passe!

{SequenceDsp} shiftAndTranslation: shift {IntegerVar}
	with: translation {Sequence}

	self passe! !

!SequenceSpace methodsFor: 'testing'!

{UInt32} actualHashForEqual
	"is equal to any basic space on the same category of positions"

	^self getCategory hashForEqual + 1!

{BooleanVar} isEqual: anObject {Heaper}
	"is equal to any basic space on the same category of positions"

	^anObject getCategory == self getCategory! !

!SequenceSpace methodsFor: 'smalltalk: defaults'!

{SequenceMapping CLIENT} mapping: shift {IntegerVar}
	"A transformation which shifts a value by some number of places and then adds a translation to it."
	
	^self mapping: shift with: NULL! !

!SequenceSpace methodsFor: 'generated:'!

{void} sendSelfTo: xmtr {Xmtr}! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SequenceSpace class
	instanceVariableNames: ''!

(SequenceSpace getOrMakeCxxClassDescription)
	friends:
'/* friends for class SequenceSpace */

friend class Sequence;
';
	attributes: ((Set new) add: #PSEUDO.COPY; add: #CONCRETE; add: #ON.CLIENT; yourself)!

!SequenceSpace class methodsFor: 'rcvr creation'!

{Heaper} make.Rcvr: rcvr {Rcvr}
	(rcvr cast: SpecialistRcvr) registerIbid: TheSequenceSpace.
	^TheSequenceSpace! !

!SequenceSpace class methodsFor: 'creation'!

{SequenceSpace INLINE} implicitReceiver
	"Get the receiver for wire requests."
	^TheSequenceSpace!

{SequenceSpace CLIENT login INLINE} make
	^TheSequenceSpace! !

!SequenceSpace class methodsFor: 'smalltalk: init'!

initTimeNonInherited

	self REQUIRES: Sequence.
	TheSequenceSpace := self create!

linkTimeNonInherited

	TheSequenceSpace := NULL! !

!SequenceSpace class methodsFor: 'smalltalk: system'!

info.stProtocol
"{SequenceRegion CLIENT} above: sequence {Sequence} with: inclusive {BooleanVar}
{SequenceRegion CLIENT} below: sequence {Sequence} with: inclusive {BooleanVar}
{SequenceRegion CLIENT} interval: lower {Region} with: upper {Sequence}
{SequenceMapping CLIENT} mapping: shift {IntegerVar} with: translation {Sequence}
{Sequence CLIENT} position: numbers {PrimIntegerArray}
{Sequence CLIENT} position: numbers {PrimIntegerArray | NULL} with: shift {IntegerVar | IntegerVarZero}
{SequenceRegion CLIENT} prefixedBy: sequence {Sequence} with: limit {IntegerVar}
"! !Stepper subclass: #DescendingIntegerStepper
	instanceVariableNames: '
		myEdges {IntegerVarArray}
		myIndex {Int32}
		myPosition {IntegerVar}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Integers'!

(DescendingIntegerStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; yourself)!

!DescendingIntegerStepper methodsFor: 'protected: create'!

create: edges {IntegerVarArray} with: count {UInt32}
	super create.
	myEdges _ edges.
	myIndex _ count - 2.
	myIndex >= -1
		ifTrue: [myPosition _ (myEdges integerVarAt: myIndex + 1) - 1]
		ifFalse: [myPosition _ IntegerVar0]!

create: edges {IntegerVarArray} with: index {Int32} with: position {IntegerVar}
	super create.
	myEdges _ edges.
	myIndex _ index.
	myPosition _ position! !

!DescendingIntegerStepper methodsFor: 'creation'!

{Stepper} copy
	^DescendingIntegerStepper create: myEdges with: myIndex with: myPosition! !

!DescendingIntegerStepper methodsFor: 'accessing'!

{Heaper wimpy} fetch
	self hasValue ifTrue: [^myPosition integer] ifFalse: [^NULL]!

{BooleanVar} hasValue
	^myIndex >= -1!

{void} step
	myPosition _ myPosition - 1.
	(myIndex >= Int32Zero and: [myPosition < (myEdges integerVarAt: myIndex)]) ifTrue:
		[myIndex _ myIndex - 2.
		myIndex >= -1 ifTrue:
			[myPosition _ (myEdges integerVarAt: myIndex + 1) - 1]]! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

DescendingIntegerStepper class
	instanceVariableNames: ''!

(DescendingIntegerStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; yourself)!

!DescendingIntegerStepper class methodsFor: 'creation'!

{Stepper} make: edges {IntegerVarArray} with: count {UInt32}
	^ self create: edges with: count! !Stepper subclass: #DisjointRegionStepper
	instanceVariableNames: '
		myValue {XnRegion}
		myRegion {XnRegion}
		myOrder {OrderSpec}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Collection-Steppers'!

(DisjointRegionStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; yourself)!

!DisjointRegionStepper methodsFor: 'accessing'!

{Heaper wimpy} fetch
	^myValue!

{BooleanVar} hasValue
	^myValue ~~ NULL!

{void} step
	myValue _ (myRegion simpleRegions: myOrder) fetch cast: XnRegion.
	myValue == NULL
		ifTrue: [myRegion isEmpty 
					ifFalse: [Heaper BLAST: #RegionReturnedNullStepperEvenThoughNonEmpty]]
		ifFalse: [myRegion _ myRegion minus: myValue]! !

!DisjointRegionStepper methodsFor: 'instance creation'!

{Stepper} copy
	^DisjointRegionStepper make: (myValue unionWith: myRegion) with: myOrder!

create: region {XnRegion} with: order {OrderSpec}
	super create.
	myValue _ NULL.
	myRegion _ region.
	myOrder _ order.
	myRegion isEmpty ifFalse:
		[self step].! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

DisjointRegionStepper class
	instanceVariableNames: ''!

(DisjointRegionStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; yourself)!

!DisjointRegionStepper class methodsFor: 'instance creation'!

{Stepper} make: region {XnRegion} with: order {OrderSpec}
	^DisjointRegionStepper create: region with: order! !Accumulator subclass: #EdgeAccumulator
	instanceVariableNames: '
		myManager {EdgeManager}
		myStartsInside {BooleanVar}
		myEdges {PtrArray of: TransitionEdge}
		myIndex {Int32}
		myPending {TransitionEdge}
		myResultGiven {BooleanVar NOCOPY}'
	classVariableNames: 'SomeAccumulators {InstanceCache} '
	poolDictionaries: ''
	category: 'Xanadu-EdgeRegion'!

(EdgeAccumulator getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!EdgeAccumulator methodsFor: 'protected: create'!

create: manager {EdgeManager} with: startsInside {BooleanVar}
	
	super create.
	myManager := manager.
	myStartsInside := startsInside.
	myEdges := PtrArray nulls: 4.
	myIndex := -1.
	myPending := NULL.
	myResultGiven := false!

create: manager {EdgeManager}
	with: startsInside {BooleanVar}
	with: edges {PtrArray of: TransitionEdge}
	with: index {Int32}
	with: pending {TransitionEdge}
	
	super create.
	myManager := manager.
	myStartsInside _ startsInside.
	myEdges _ edges.
	myIndex := index.
	myPending _ pending.
	myResultGiven := false! !

!EdgeAccumulator methodsFor: 'creation'!

{Accumulator} copy
	| result {Heaper} |
	result := SomeAccumulators fetch.
	myResultGiven := true.
	result == NULL
		ifTrue: [
			^EdgeAccumulator create: myManager
				with: myStartsInside
				with: myEdges
				with: myIndex
				with: myPending]
		ifFalse: [
			^(EdgeAccumulator new.Become: result) create: myManager
				with: myStartsInside
				with: myEdges
				with: myIndex
				with: myPending]!

{void} destroy
	(SomeAccumulators store: self) ifFalse: [super destroy]! !

!EdgeAccumulator methodsFor: 'operations'!

{void} step: someObj {Heaper}
	self edge: (someObj cast: TransitionEdge)!

{Heaper} value
	^self region! !

!EdgeAccumulator methodsFor: 'edge operations'!

{void} edge: x {TransitionEdge}
	"add a transition at the given position. doing it again cancels it"
	myPending == NULL ifTrue:
		[myPending := x]
	ifFalse:
		[(myPending isEqual: x) ifTrue:
			[myPending := NULL]
		ifFalse:
			[self storeStep: myPending.
			myPending := x]].!

{void} edges: stepper {EdgeStepper}
	"add a whole bunch of edges at once, assuming that they are sorted and there are no duplicates"
	
	"do the first step manually in case it is the same as the current edge
	then do all the rest without checking for repeats"
		
	stepper hasValue ifTrue:
		[|edge {TransitionEdge} |
		self edge: stepper fetchEdge.
		stepper step.
		[(edge := stepper fetch cast: TransitionEdge) ~~ NULL] whileTrue: [
			myPending ~~ NULL ifTrue:
				[self storeStep: myPending].
			myPending := edge.
			stepper step]]!

{XnRegion} region
	"make a region out of the accumulated edges"

	myPending ~~ NULL ifTrue:
		[self storeStep: myPending.
		myPending := NULL].
	myResultGiven := true.
	^myManager makeNew: myStartsInside with: myEdges with: myIndex + 1! !

!EdgeAccumulator methodsFor: 'private:'!

{void} storeStep: edge {TransitionEdge}
	"Just store an edge into the array and increment the count"
	
	myIndex := myIndex + 1.
	myIndex = myEdges count
		ifTrue: [
			myEdges := (myEdges copyGrow: myEdges count) cast: PtrArray.
			myResultGiven := false]
		ifFalse: [
			myResultGiven ifTrue: [
				myEdges := myEdges copy cast: PtrArray.
				myResultGiven := false]].
	myEdges at: myIndex store: edge.! !

!EdgeAccumulator methodsFor: 'hooks:'!

{void RECEIVE.HOOK} restartEdgeAccumulator: rcvr {Rcvr unused}
	myResultGiven := false! !

!EdgeAccumulator methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myManager _ receiver receiveHeaper.
	myStartsInside _ receiver receiveBooleanVar.
	myEdges _ receiver receiveHeaper.
	myIndex _ receiver receiveInt32.
	myPending _ receiver receiveHeaper.
	self restartEdgeAccumulator: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myManager.
	xmtr sendBooleanVar: myStartsInside.
	xmtr sendHeaper: myEdges.
	xmtr sendInt32: myIndex.
	xmtr sendHeaper: myPending.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

EdgeAccumulator class
	instanceVariableNames: ''!

(EdgeAccumulator getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!EdgeAccumulator class methodsFor: 'smalltalk: init'!

initTimeNonInherited
	SomeAccumulators := InstanceCache make: 8!

linkTimeNonInherited
	SomeAccumulators := NULL! !

!EdgeAccumulator class methodsFor: 'create'!

make: manager {EdgeManager} with: startsInside {BooleanVar}
	| result {Heaper} |
	result := SomeAccumulators fetch.
	result == NULL
		ifTrue: [^ self create: manager with: startsInside]
		ifFalse: [^ (self new.Become: result) create: manager with: startsInside]! !Heaper subclass: #EdgeManager
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-edge'!
EdgeManager comment:
'Manages the common code for regions which are represented as a sequence of EdgeTransitions. Each coordinate space should define a subclass which implements the appropriate methods, and then use it to do the various region operations. Clients of the region do not need to see any of these classes.'!

(EdgeManager getOrMakeCxxClassDescription)
	friends:
'friend class EdgeSimpleRegionStepper;
friend class EdgeAccumulator;
';
	attributes: ((Set new) add: #DEFERRED; add: #EQ; yourself)!

!EdgeManager methodsFor: 'private:'!

{EdgeAccumulator} edgeAccumulator: startsInside {BooleanVar}
	"Create an accumulator which takes edges and creates a region"
	
	^EdgeAccumulator
		make: self
		with: startsInside!

{EdgeStepper} edgeStepper: region {XnRegion}
	"Create a stepper for iterating through the edges of the region"
	
	^EdgeStepper make: (self startsInside: region) not
		with: (self transitions: region)
		with: (self transitionsCount: region)!

{TransitionEdge} lowerEdge: region {XnRegion}

	| transitions {PtrArray of: TransitionEdge} |
	transitions := self transitions: region.
	((self startsInside: region)
			or: [(self transitionsCount: region) = Int32Zero])
		ifTrue: [Heaper BLAST: #InvalidRequest].
	^(transitions fetch: Int32Zero) cast: TransitionEdge!

{EdgeStepper} singleEdgeStepper: pos {Position}
	"Create a stepper for iterating through the edges of the region"
	
	^EdgeStepper make: false not
		with: (self posTransitions: pos)!

{TransitionEdge} upperEdge: region {XnRegion}

	| transitions {PtrArray of: TransitionEdge} transitionsCount {Int32} |
	transitions := self transitions: region.
	transitionsCount := self transitionsCount: region.
	((self isBoundedRight: region) not
			or: [transitionsCount == Int32Zero])
		ifTrue: [Heaper BLAST: #InvalidRequest].
	^(transitions fetch: (transitionsCount - 1)) cast: TransitionEdge! !

!EdgeManager methodsFor: 'testing'!

{BooleanVar} hasMember: region {XnRegion} with: pos {Position}

	| edges {EdgeStepper} edge {TransitionEdge} result {BooleanVar} |
	edges := self edgeStepper: region.
	[(edge := edges fetch cast: TransitionEdge) ~~ NULL] whileTrue:
		[(edge follows: pos) ifTrue:
			[result := edges isEntering not.
			edges destroy.
			^ result].
		edges step].
	result := edges isEntering not.
	edges destroy.
	^ result!

{BooleanVar} isBoundedLeft: region {XnRegion}
	"Same meaning as IntegerRegion::isBoundedLeft"
	
	^(self startsInside: region) not!

{BooleanVar} isBoundedRight: region {XnRegion}
	"Same meaning as IntegerRegion::isBoundedRight"
	
	^(((self transitionsCount: region) bitAnd: 1) == Int32Zero)
		~~ (self startsInside: region)!

{BooleanVar} isEmpty: region {XnRegion}

	^(self startsInside: region) not
		and: [(self transitionsCount: region) = Int32Zero]!

{BooleanVar} isFinite: region {XnRegion}
	"Here is one place where the *infinite* of the infinite divisibility assumed by OrderedRegion about the full ordering comes in (see class comment).  
	An interval whose left edge is not the same as the right edge is assumed to contain an infinite number of positions"
	
	| transitions {PtrArray of: TransitionEdge} transitionsCount {Int32} |
	transitions := self transitions: region.
	transitionsCount := self transitionsCount: region.
	((self startsInside: region) or: [(transitionsCount bitAnd: 1) ~~ Int32Zero]) ifTrue:
		[^false].
	Int32Zero almostTo: transitionsCount by: 2 do: [ :i {Int32} |
		(((transitions fetch: i) cast: TransitionEdge)
				isFollowedBy: ((transitions fetch: i + 1) cast: TransitionEdge))
			ifFalse: [^false]].
	^true!

{BooleanVar} isFull: region {XnRegion}

	^(self startsInside: region)
		and: [(self transitionsCount: region) = Int32Zero]!

{BooleanVar} isSimple: region {XnRegion}
	| testVal {Int32} |
	(self startsInside: region) ifTrue: [testVal _ 1] ifFalse: [testVal _ 2].
	^(self transitionsCount: region) <= testVal!

{BooleanVar} isSubsetOf: me {XnRegion} with: other {XnRegion}

	| mine {EdgeStepper} others {EdgeStepper} result {BooleanVar} |
	(self isEmpty: other)
		ifTrue: [^self isEmpty: me].
	mine := self edgeStepper: me.
	others := self edgeStepper: other.
	(mine hasValue or: [others hasValue])
		ifFalse: [
			result := mine isEntering or: [others isEntering not].
			mine destroy.
			others destroy.
			^ result].
	(mine isEntering not and: [others isEntering]) ifTrue: [mine destroy. others destroy. ^false].
	[mine hasValue and: [others hasValue]]
		whileTrue: 
			[(others getEdge isGE: mine getEdge) not
				ifTrue: 
					[(others isEntering not and: [mine isEntering not]) ifTrue: [mine destroy. others destroy. ^false].
					others step]
				ifFalse: 
					[(mine getEdge isGE: others getEdge) not
						ifTrue: 
							[(others isEntering and: [mine isEntering]) ifTrue: [mine destroy. others destroy. ^false].
							mine step]
						ifFalse: 
							[others isEntering ~~ mine isEntering ifTrue: [mine destroy. others destroy. ^false].
							others step.
							mine step]]].
	result := ((mine hasValue and: [others isEntering])
		or: [others hasValue and: [mine isEntering not]]) not.
	mine destroy.
	others destroy.
	^ result! !

!EdgeManager methodsFor: 'enumerating'!

{IntegerVar} count: region {XnRegion}
	"Because Edge Regions should only be used on infinitely divisible spaces (like rationals), if it's finite then it is bounded on both sides, and all the internal intervals are singletons"

	(self isFinite: region) ifFalse: [Heaper BLAST: #MustBeFinite].
	^(self transitionsCount: region) // 2! !

!EdgeManager methodsFor: 'accessing'!

{XnRegion} asSimpleRegion: region {XnRegion}

	(self isSimple: region) ifTrue: [^region].
	(self isBoundedLeft: region)
		ifTrue: [(self isBoundedRight: region)
			ifTrue: [^self makeNew: false with: ((PrimSpec pointer
				arrayWithTwo: (self lowerEdge: region) with: (self upperEdge: region)) cast: PtrArray)]
			ifFalse: [^self makeNew: false with: ((PrimSpec pointer
				arrayWith: (self lowerEdge: region)) cast: PtrArray)]]
		ifFalse: [(self isBoundedRight: region)
			ifTrue: [^self makeNew: true with: ((PrimSpec pointer
				arrayWith: (self upperEdge: region)) cast: PtrArray)]
			ifFalse: [^self makeNew: true with: PtrArray empty]]!

{Position} greatestLowerBound: region {XnRegion}
	"The largest position such that no other positions in the region are any less than it. In other words, this is the lower bounding element. We choose to avoid the terms 'lowerBound' and 'upperBound' as their meanings in IntegerRegion are significantly different. Here, both 'all numbers >= 3' and 'all numbers > 3' have a 'greatestLowerBound' of 3 even though the latter doesn't include 3. To tell whether a bound is included, good old 'hasMember' should do a fine job."

	^self edgePosition: (self lowerEdge: region)!

{Position} leastUpperBound: region {XnRegion}
	"The smallest position such that no other positions in the region are 
	any greater than it. In other words, this is the upper bounding element. 
	We choose to avoid the terms 'lowerBound' and 'upperBound' as 
	their meanings in IntegerRegion are significantly different. Here, both 
	'all numbers <= 3' and 'all numbers < 3' have a 'leastUpperBound' 
	of 3 even though the latter doesn't include 3. To tell whether a 
	bound is included, good old 'hasMember' should do a fine job."

	^self edgePosition: (self upperEdge: region)!

{XnRegion} simpleUnion: me {XnRegion} with: other {XnRegion}

	(self isEmpty: me) ifTrue: [^self asSimpleRegion: other].
	(self isEmpty: other) ifTrue: [^self asSimpleRegion: me].
	((self isBoundedLeft: me) and: [self isBoundedLeft: other])
		ifTrue: [((self isBoundedRight: me) and: [self isBoundedRight: other])
			ifTrue: [^self makeNew: false with: ((PrimSpec pointer
				arrayWithTwo: ((self lowerEdge: me) floor: (self lowerEdge: other))
				with: ((self upperEdge: me) ceiling: (self upperEdge: other))) cast: PtrArray)]
			ifFalse: [^self makeNew: false with: ((PrimSpec pointer arrayWith: ((self lowerEdge: me) floor: (self lowerEdge: other))) cast: PtrArray)]]
		ifFalse: [((self isBoundedRight: me) and: [self isBoundedRight: other])
			ifTrue: [^self makeNew: true with: ((PrimSpec pointer arrayWith: ((self upperEdge: me) ceiling: (self upperEdge: other))) cast: PtrArray)]
			ifFalse: [^self makeNew: true with: PtrArray empty]]! !

!EdgeManager methodsFor: 'printing'!

{void} printRegionOn: region {XnRegion} with: oo {ostream reference}

	(self isEmpty: region) ifTrue:
		[oo << '{}']
	ifFalse:
		[ | edges {EdgeStepper} previous {TransitionEdge} |
		edges := self edgeStepper: region.
		(self isSimple: region) ifFalse: [oo << '{'].
		edges isEntering ifFalse: [oo << '(-inf'].
		previous := NULL.
		edges forEach: [ :edge {TransitionEdge} |
			edge printTransitionOn: oo
				with: edges isEntering
				with: (previous ~~ NULL and: [previous touches: edge]).
			previous := edge].
		(self isBoundedRight: region) ifFalse: [oo << ' +inf)'].
		(self isSimple: region) ifFalse: [oo << '}']]! !

!EdgeManager methodsFor: 'operations'!

{XnRegion} complement: region {XnRegion}

	^self makeNew: (self startsInside: region) not with: (self transitions: region) with: (self transitionsCount: region)!

{ScruSet of: XnRegion} distinctions: region {XnRegion}

	| result {MuSet} |
	(self isSimple: region) ifFalse:
		[Heaper BLAST: #InvalidRequest].
	(self isEmpty: region) ifTrue:
		[^ImmuSet make with: region].
	(self isFull: region) ifTrue:
		[^ImmuSet make].
	(self transitionsCount: region) = 1 ifTrue:
		[^ImmuSet make with: region].
	result := MuSet make.
	result store: (self makeNew: false with: ((PrimSpec pointer arrayWith: (self lowerEdge: region)) cast: PtrArray)).
	result store: (self makeNew: true with: ((PrimSpec pointer arrayWith: (self upperEdge: region)) cast: PtrArray)).
	^result asImmuSet!

{XnRegion} intersect: meRegion {XnRegion} with: otherRegion {XnRegion}

	| mine {EdgeStepper} others {EdgeStepper} result {EdgeAccumulator} resultReg {XnRegion} |
	(self isEmpty: otherRegion)
		ifTrue: [^otherRegion].
	mine := self edgeStepper: meRegion.
	others := self edgeStepper: otherRegion.
	result := self edgeAccumulator: ((self startsInside: meRegion)
			and: [self startsInside: otherRegion]).
	[mine hasValue and: [others hasValue]] whileTrue:
		[ | me {TransitionEdge} other {TransitionEdge} |
		me := mine getEdge.
		other := others getEdge.
		(me isGE: other) not
			ifTrue:
				[others isEntering not ifTrue: [result edge: me].
				mine step]
			ifFalse:
				[mine isEntering not ifTrue: [result edge: other].
				others step]].
	(mine hasValue and: [others isEntering not]) ifTrue: [result edges: mine].
	(others hasValue and: [mine isEntering not]) ifTrue: [result edges: others].
	mine destroy.
	others destroy.
	resultReg := result region.
	result destroy.
	^ resultReg!

{Stepper} simpleRegions: region {XnRegion} with: order {OrderSpec default: NULL}

	order ~~ NULL ifTrue: 
		[self unimplemented].
	^EdgeSimpleRegionStepper make: self
		with: (self edgeStepper: region)!

{XnRegion} unionWith: meRegion {XnRegion} with: otherRegion {XnRegion}

	| mine {EdgeStepper} others {EdgeStepper} result {EdgeAccumulator} resultReg {XnRegion} |
	(self isEmpty: otherRegion)
		ifTrue: [^meRegion].
	mine := self edgeStepper: meRegion.
	others := self edgeStepper: otherRegion.
	result := self edgeAccumulator: ((self startsInside: meRegion)
			or: [self startsInside: otherRegion]).
	[mine hasValue and: [others hasValue]] whileTrue:
		[ | me {TransitionEdge} other {TransitionEdge} |
		me := mine getEdge.
		other := others getEdge.
		(me isGE: other) not
			ifTrue:
				[others isEntering ifTrue: [result edge: me].
				mine step]
			ifFalse:
				[mine isEntering ifTrue: [result edge: other].
				others step]].
	(mine hasValue and: [others isEntering]) ifTrue: [result edges: mine].
	(others hasValue and: [mine isEntering]) ifTrue: [result edges: others].
	mine destroy.
	others destroy.
	resultReg := result region.
	result destroy.
	^ resultReg!

{XnRegion} with: meRegion {XnRegion} with: newPos {Position}

	| mine {EdgeStepper} others {EdgeStepper} result {EdgeAccumulator} resultReg {XnRegion} |
	mine := self edgeStepper: meRegion.
	others := self singleEdgeStepper: newPos.
	result := self edgeAccumulator: (self startsInside: meRegion).
	[mine hasValue and: [others hasValue]] whileTrue:
		[ | me {TransitionEdge} other {TransitionEdge} |
		me := mine getEdge.
		other := others getEdge.
		(me isGE: other) not
			ifTrue:
				[others isEntering ifTrue: [result edge: me].
				mine step]
			ifFalse:
				[mine isEntering ifTrue: [result edge: other].
				others step]].
	(mine hasValue and: [others isEntering]) ifTrue: [result edges: mine].
	(others hasValue and: [mine isEntering]) ifTrue: [result edges: others].
	mine destroy.
	others destroy.
	resultReg := result region.
	result destroy.
	^ resultReg! !

!EdgeManager methodsFor: 'protected:'!

{Position} edgePosition: edge {TransitionEdge}
	"The position associated with the given edge. Blast if there is none"
	
	self subclassResponsibility!

{XnRegion} makeNew: startsInside {BooleanVar} with: transitions {PtrArray of: TransitionEdge}
	"Make a new region of the right type"
	
	self subclassResponsibility!

{XnRegion} makeNew: startsInside {BooleanVar} with: transitions {PtrArray of: TransitionEdge} with: count {Int32}
	"Make a new region of the right type"
	
	self subclassResponsibility!

{PtrArray of: TransitionEdge} posTransitions: pos {Position}

	self subclassResponsibility!

{BooleanVar} startsInside: region {XnRegion}

	self subclassResponsibility!

{PtrArray of: TransitionEdge} transitions: region {XnRegion}

	self subclassResponsibility!

{Int32} transitionsCount: region {XnRegion}

	self subclassResponsibility! !

!EdgeManager methodsFor: 'generated:'!

actualHashForEqual ^self asOop!

isEqual: other ^self == other! !EdgeManager subclass: #RealManager
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!

(RealManager getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!RealManager methodsFor: 'protected:'!

{Position} edgePosition: edge {TransitionEdge}
	
	^(edge cast: RealEdge) position!

{XnRegion} makeNew: startsInside {BooleanVar} with: transitions {PtrArray of: TransitionEdge}

	^RealRegion make: startsInside with: transitions!

{XnRegion} makeNew: startsInside {BooleanVar} with: transitions {PtrArray of: TransitionEdge} with: count {Int32}

	^self makeNew: startsInside with: ((transitions copy: count) cast: PtrArray)!

{PtrArray of: TransitionEdge} posTransitions: pos {Position}

	self unimplemented.
	^NULL "fodder"!

{BooleanVar} startsInside: region {XnRegion}

	^(region cast: RealRegion) startsInside!

{PtrArray of: TransitionEdge} transitions: region {XnRegion}

	^(region cast: RealRegion) secretTransitions!

{Int32 INLINE} transitionsCount: region {XnRegion}

	^(region cast: RealRegion) secretTransitions count! !

!RealManager methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !EdgeManager subclass: #SequenceManager
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!
SequenceManager comment:
'Specialized object for managing TumblerSpace objects. Is a type so that inlining could potentially be used.'!

(SequenceManager getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!SequenceManager methodsFor: 'protected:'!

{Position} edgePosition: edge {TransitionEdge}

	^(edge cast: SequenceEdge) sequence!

{XnRegion} makeNew: startsInside {BooleanVar} with: transitions {PtrArray of: TransitionEdge}

	^self makeNew: startsInside with: transitions with: transitions count!

{XnRegion} makeNew: startsInside {BooleanVar} with: transitions {PtrArray of: TransitionEdge} with: count {Int32}

	^SequenceRegion create: startsInside with: transitions with: count!

{PtrArray of: TransitionEdge} posTransitions: pos {Position}

	^ (PrimSpec pointer
		arrayWithTwo: (BeforeSequence make: (pos cast: Sequence))
		with: (AfterSequence make: (pos cast: Sequence))) cast: PtrArray!

{BooleanVar} startsInside: region {XnRegion}

	^(region cast: SequenceRegion) startsInside!

{PtrArray of: TransitionEdge} transitions: region {XnRegion}

	^(region cast: SequenceRegion) secretTransitions!

{Int32} transitionsCount: region {XnRegion}

	^(region cast: SequenceRegion) secretTransitionsCount! !

!SequenceManager methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !Stepper subclass: #EdgeSimpleRegionStepper
	instanceVariableNames: '
		myManager {EdgeManager}
		myEdges {EdgeStepper}
		mySimple {XnRegion}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-EdgeRegion'!
EdgeSimpleRegionStepper comment:
'Consider this a "protected" class.  See class comment in EdgeAccumulator'!

(EdgeSimpleRegionStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; yourself)!

!EdgeSimpleRegionStepper methodsFor: 'accessing'!

{Heaper wimpy} fetch
	^mySimple!

{BooleanVar} hasValue
	^mySimple ~~ NULL!

{void} step

	| startsInside {BooleanVar} one {TransitionEdge} two {TransitionEdge} |
	"if there are no more edges
		then the stepper is empty
		
	remember whether we're entering or leaving the region
	fetch the first edge
	if there is no first edge
		then remember the edges are gone
		if we were already in the region
			then there is the full region
			else we're empty
	else there is a first edge, so
		if we start outside and there is another edge
			then get it and make a two-sided region
			else make a one-side region"
	
	myEdges == NULL ifTrue:
		[mySimple := NULL.
		^VOID].
	
	startsInside := myEdges isEntering not.
	one := myEdges fetchEdge.
	one == NULL ifTrue:
		[myEdges := NULL.
		(startsInside and: [mySimple == NULL]) ifTrue:
			[mySimple := myManager makeNew: true with: PtrArray empty]
		ifFalse:
			[mySimple := NULL]]
	ifFalse:
		[myEdges step.
		(startsInside not and: [myEdges hasValue]) ifTrue:
			[two := myEdges fetchEdge.
			myEdges step.
			mySimple := myManager makeNew: startsInside
				with: ((PrimSpec pointer arrayWithTwo: one with: two) cast: PtrArray)]
		ifFalse:
			[mySimple := myManager makeNew: startsInside
				with: ((PrimSpec pointer arrayWith: one) cast: PtrArray)]].! !

!EdgeSimpleRegionStepper methodsFor: 'create'!

{Stepper} copy
	| step {EdgeStepper} |
	"can't to ?: with SPTRs"
	step := myEdges.
	step ~~ NULL ifTrue:
		[step := myEdges copy cast: EdgeStepper].
	^ EdgeSimpleRegionStepper create: myManager with: step with: mySimple! !

!EdgeSimpleRegionStepper methodsFor: 'protected: create'!

create: manager {EdgeManager} with: edges {EdgeStepper}

	super create.
	myManager := manager.
	myEdges := edges.
	mySimple := NULL.
	self step.!

create: manager {EdgeManager}
	with: edges {EdgeStepper | NULL}
	with: simple {XnRegion | NULL}
	
	super create.
	myManager := manager.
	myEdges := edges.
	mySimple := simple! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

EdgeSimpleRegionStepper class
	instanceVariableNames: ''!

(EdgeSimpleRegionStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; yourself)!

!EdgeSimpleRegionStepper class methodsFor: 'create'!

make: manager {EdgeManager} with: edges {EdgeStepper}
	^ self create: manager with: edges! !Stepper subclass: #EdgeStepper
	instanceVariableNames: '
		myEntering {BooleanVar}
		myEdges {PtrArray of: TransitionEdge}
		myEdgesCount {Int32}
		myIndex {Int32}'
	classVariableNames: 'SomeEdgeSteppers {InstanceCache} '
	poolDictionaries: ''
	category: 'Xanadu-EdgeRegion'!
EdgeStepper comment:
'A single instance of this class is cached.  To take advantage of this, a method
that uses EdgeSteppers should explicitly destroy at least one of them.
Consider this a "protected" class.  See class comment in EdgeAccumulator.'!

(EdgeStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; yourself)!

!EdgeStepper methodsFor: 'accessing'!

{Heaper wimpy} fetch

	myIndex < myEdgesCount
		ifTrue: [^myEdges fetch: myIndex]
		ifFalse: [^NULL]!

{BooleanVar} hasValue

	^myIndex < myEdgesCount!

{void} step

	self hasValue ifTrue:
		[myEntering := myEntering not.
		myIndex := myIndex + 1]! !

!EdgeStepper methodsFor: 'edge accessing'!

{TransitionEdge | NULL} fetchEdge

	myIndex < myEdgesCount
		ifTrue: [^(myEdges fetch: myIndex) cast: TransitionEdge]
		ifFalse: [^NULL]!

{TransitionEdge} getEdge

	myIndex < myEdgesCount
		ifTrue: [^(myEdges fetch: myIndex) cast: TransitionEdge]
		ifFalse: [Heaper BLAST: #EmptyStepper].
	^NULL "fodder"!

{BooleanVar} isEntering
	"whether the current transition is entering or leaving the set"
	^myEntering! !

!EdgeStepper methodsFor: 'protected: create'!

create: entering {BooleanVar} with: edges {PtrArray of: TransitionEdge} with: count {Int32}

	super create.
	myEntering := entering.
	myEdges := edges.
	myEdgesCount := count.
	myIndex := Int32Zero!

create: entering {BooleanVar} with: edges {PtrArray of: TransitionEdge} with: count {Int32} with: index {Int32}

	super create.
	myEntering := entering.
	myEdges := edges.
	myEdgesCount := count.
	myIndex := index! !

!EdgeStepper methodsFor: 'create'!

{Stepper} copy

	^EdgeStepper create: myEntering
		with: myEdges
		with: myEdgesCount
		with: myIndex! !

!EdgeStepper methodsFor: 'destroy'!

{void} destroy
	(SomeEdgeSteppers store: self) ifFalse:
		[super destroy]! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

EdgeStepper class
	instanceVariableNames: ''!

(EdgeStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; yourself)!

!EdgeStepper class methodsFor: 'create'!

make: entering {BooleanVar} with: edges {PtrArray of: TransitionEdge}
	| result {Heaper} |
	result := SomeEdgeSteppers fetch.
	result == NULL ifTrue: [
		^ self create: entering with: edges with: edges count]
	ifFalse: [
		^ (self new.Become: result) create: entering with: edges with: edges count]!

make: entering {BooleanVar} with: edges {PtrArray of: TransitionEdge} with: count {Int32}
	| result {Heaper} |
	result := SomeEdgeSteppers fetch.
	result == NULL ifTrue: [
		^ self create: entering with: edges with: count]
	ifFalse: [
		^ (self new.Become: result) create: entering with: edges with: count]! !

!EdgeStepper class methodsFor: 'smalltalk: init'!

initTimeNonInherited
	SomeEdgeSteppers := InstanceCache make: 16!

linkTimeNonInherited
	SomeEdgeSteppers := NULL! !Stepper subclass: #GenericCrossSimpleRegionStepper
	instanceVariableNames: '
		mySpace {CrossSpace}
		myBoxes {Stepper of: CrossRegion}
		mySimples {PtrArray of: (Stepper of: XnRegion)}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-cross'!

(GenericCrossSimpleRegionStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #EQ; add: #NOT.A.TYPE; yourself)!

!GenericCrossSimpleRegionStepper methodsFor: 'operations'!

{Heaper wimpy} fetch

	| result {PtrArray} |
	self hasValue ifFalse:
		[^NULL].
	result := PtrArray nulls: mySpace axisCount.
	Int32Zero almostTo: mySpace axisCount do: [ :i {Int32} |
		result at: i store: ((mySimples get: i) cast: Stepper) get].
	^mySpace crossOfRegions: result!

{BooleanVar} hasValue

	^myBoxes hasValue!

{void} step

	| index {Int32} |
	myBoxes hasValue ifTrue: [
		index := mySpace axisCount - 1.
		[index >= Int32Zero] whileTrue:
			[ | sub {Stepper} |
			sub := (mySimples get: index) cast: Stepper.
			sub step.
			sub hasValue ifTrue:
				[self replenishSteppers: index + 1.
				^VOID].
			index := index - 1].
		myBoxes step.
		myBoxes hasValue ifTrue:
			[self replenishSteppers: Int32Zero]]! !

!GenericCrossSimpleRegionStepper methodsFor: 'private:'!

{void} replenishSteppers: index {Int32}
	"Replenish all steppers starting at index"
	
	| box {CrossRegion} |
	box := myBoxes get cast: CrossRegion.
	index almostTo: mySpace axisCount do: [ :i {Int32} |
		mySimples at: i store: (box projection: i) simpleRegions]! !

!GenericCrossSimpleRegionStepper methodsFor: 'create'!

{Stepper} copy

	| simples {PtrArray} |
	simples := PtrArray nulls: mySimples count.
	Int32Zero almostTo: simples count do: [ :i {Int32} |
		simples at: i store: ((mySimples get: i) cast: Stepper) copy].
	^GenericCrossSimpleRegionStepper create: mySpace with: myBoxes copy with: simples! !

!GenericCrossSimpleRegionStepper methodsFor: 'protected: create'!

create: space {CrossSpace} with: boxes {Stepper}

	super create.
	mySpace := space.
	myBoxes := boxes.
	boxes hasValue ifTrue:
		[mySimples := PtrArray nulls: space axisCount.
		self replenishSteppers: Int32Zero]!

create: space {CrossSpace} with: boxes {Stepper} with: simples {PtrArray}

	super create.
	mySpace := space.
	myBoxes := boxes.
	mySimples := simples.! !

!GenericCrossSimpleRegionStepper methodsFor: 'generated:'!

actualHashForEqual ^self asOop!

isEqual: other ^self == other! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GenericCrossSimpleRegionStepper class
	instanceVariableNames: ''!

(GenericCrossSimpleRegionStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #EQ; add: #NOT.A.TYPE; yourself)!

!GenericCrossSimpleRegionStepper class methodsFor: 'create'!

{Stepper} make: space {CrossSpace} with: boxes {Stepper}

	^self create: space with: boxes! !Accumulator subclass: #IntegerEdgeAccumulator
	instanceVariableNames: '
		myStartsInside {BooleanVar}
		myEdges {IntegerVarArray}
		myIndex {UInt32}
		havePending {BooleanVar}
		myPending {IntegerVar}'
	classVariableNames: 'SomeAccumulators {InstanceCache} '
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Integers'!

(IntegerEdgeAccumulator getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; yourself)!

!IntegerEdgeAccumulator methodsFor: 'protected: creation'!

create: startsInside {BooleanVar} with: count {UInt32}
	super create.
	myStartsInside _ startsInside.
	myEdges _ IntegerVarArray zeros: count.
	myIndex _ Int32Zero.
	havePending _ false.
	myPending _ IntegerVar0!

create: startsInside {BooleanVar} with: edges {IntegerVarArray} with: index {UInt32} with: hasPending {BooleanVar} with: pending {IntegerVar}
	super create.
	myStartsInside _ startsInside.
	myEdges _ edges.
	myIndex _ index.
	havePending _ hasPending.
	myPending _ pending! !

!IntegerEdgeAccumulator methodsFor: 'creation'!

{Accumulator} copy
	| result {Heaper} |
	result := SomeAccumulators fetch.
	result == NULL
		ifTrue: [
			^IntegerEdgeAccumulator create: myStartsInside with: myEdges with: myIndex with: havePending with: myPending]
		ifFalse: [	
				^(IntegerEdgeAccumulator new.Become: result)
					create: myStartsInside with: myEdges with: myIndex with: havePending with: myPending]!

{void} destroy
	(SomeAccumulators store: self) ifFalse: [super destroy]! !

!IntegerEdgeAccumulator methodsFor: 'operations'!

{void} step: someObj {Heaper}
	self edge: (someObj cast: IntegerPos) asIntegerVar!

{Heaper} value
	^self region! !

!IntegerEdgeAccumulator methodsFor: 'printing'!

{void} printOn: oo {ostream reference}
	oo << self getCategory name << '(' << self region << ')'! !

!IntegerEdgeAccumulator methodsFor: 'edge operations'!

{void} edge: x {IntegerVar}
	"add a transition at the given position. doing it again cancels it.  This particular coding is used for C++ inlinability"
	havePending ifTrue:
		[myPending = x
			ifTrue:
				[havePending _ false]
			ifFalse:
				[myEdges at: myIndex storeIntegerVar: myPending.
				myIndex _ myIndex + 1.
				myPending _ x]]
	ifFalse:
		[havePending _ true.
		myPending _ x].!

{void} edges: stepper {IntegerEdgeStepper}
	"add a whole bunch of edges at once, assuming that they are sorted and there are no duplicates"
	stepper hasValue ifTrue:
		[self edge: stepper edge.
		stepper step.
		stepper hasValue ifTrue:
			[havePending ifFalse:
				[myPending _ stepper edge.
				havePending _ true.
				stepper step].
			[stepper hasValue] whileTrue:
				[myEdges at: myIndex storeIntegerVar: myPending.
				myIndex _ myIndex + 1.
				myPending _ stepper edge.
				stepper step]]]!

{IntegerRegion} region
	"make a region out of the accumulated edges"
	
	havePending ifTrue:
		[myEdges at: myIndex storeIntegerVar: myPending.
		^IntegerRegion create: myStartsInside with: myIndex + 1 with: myEdges]
	ifFalse:
		[myIndex == Int32Zero ifTrue:
			[myStartsInside
				ifTrue: [^IntegerRegion allIntegers]
				ifFalse: [^IntegerRegion make]]
		ifFalse: 
			[^IntegerRegion create: myStartsInside with: myIndex with: myEdges]]! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

IntegerEdgeAccumulator class
	instanceVariableNames: ''!

(IntegerEdgeAccumulator getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; yourself)!

!IntegerEdgeAccumulator class methodsFor: 'creation'!

make: startsInside {BooleanVar} with: count {UInt32}
	| result {Heaper} |
	result := SomeAccumulators fetch.
	result == NULL
		ifTrue: [^ self create: startsInside with: count]
		ifFalse: [^ (self new.Become: result) create: startsInside with: count]! !

!IntegerEdgeAccumulator class methodsFor: 'smalltalk: init'!

initTimeNonInherited
	SomeAccumulators := InstanceCache make: 16!

linkTimeNonInherited
	SomeAccumulators := NULL! !Stepper subclass: #IntegerEdgeStepper
	instanceVariableNames: '
		myEntering {BooleanVar}
		myIndex {UInt32}
		myCount {UInt32}
		myEdges {IntegerVarArray}'
	classVariableNames: 'SomeEdgeSteppers {InstanceCache} '
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Integers'!
IntegerEdgeStepper comment:
'A single instance of this class is cached.  To take advantage of this, a method
that uses IntegerEdgeSteppers should explicitly destroy at least one of them.'!

(IntegerEdgeStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; yourself)!

!IntegerEdgeStepper methodsFor: 'operations'!

{Heaper wimpy} fetch
	self hasValue ifTrue: [^IntegerPos make: self edge] ifFalse: [^NULL]!

{BooleanVar INLINE} hasValue
	^myIndex < myCount!

{void INLINE} step
	myEntering _ myEntering not.
	myIndex _ myIndex + 1! !

!IntegerEdgeStepper methodsFor: 'edge accessing'!

{IntegerVar INLINE} edge
	"the current transition"
	(myIndex >= myCount) ifTrue: [ IntegerEdgeStepper outOfBounds ].
	^myEdges integerVarAt: myIndex!

{BooleanVar INLINE} isEntering
	"whether the current transition is entering or leaving the set"
	^myEntering! !

!IntegerEdgeStepper methodsFor: 'protected: create'!

create: entering {BooleanVar} with: count {UInt32} with: edges {IntegerVarArray}
	super create.
	myEntering _ entering.
	myIndex _ Int32Zero.
	myCount _ count.
	myEdges _ edges!

create: entering {BooleanVar} with: index {UInt32} with: count {UInt32} with: edges {IntegerVarArray}
	super create.
	myEntering _ entering.
	myIndex _ index.
	myCount _ count.
	myEdges _ edges! !

!IntegerEdgeStepper methodsFor: 'destroy'!

{void} destroy
	(SomeEdgeSteppers store: self) ifFalse:
		[super destroy]! !

!IntegerEdgeStepper methodsFor: 'create'!

{Stepper} copy
	^IntegerEdgeStepper create: myEntering with: myIndex with: myCount with: myEdges! !

!IntegerEdgeStepper methodsFor: 'printing'!

{void} printOn: oo {ostream reference}
	oo << self getCategory name << '('.
	self hasValue ifTrue:
		[self isEntering ifTrue: 
			[oo << 'entering ']
		ifFalse: 
			[oo << 'leaving '].
		oo << self edge].
	oo << ')'.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

IntegerEdgeStepper class
	instanceVariableNames: ''!

(IntegerEdgeStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; yourself)!

!IntegerEdgeStepper class methodsFor: 'errors'!

{void} outOfBounds
	self BLAST: #OutOfBounds! !

!IntegerEdgeStepper class methodsFor: 'create'!

make: entering {BooleanVar} with: count {UInt32} with: edges {IntegerVarArray}
	| result {Heaper} |
	result := SomeEdgeSteppers fetch.
	result == NULL ifTrue: [
		^ self create: entering with: count with: edges]
	ifFalse: [
		^ (self new.Become: result) create: entering with: count with: edges]! !

!IntegerEdgeStepper class methodsFor: 'smalltalk: init'!

initTimeNonInherited
	SomeEdgeSteppers := InstanceCache make: 2!

linkTimeNonInherited
	SomeEdgeSteppers := NULL! !Stepper subclass: #IntegerSimpleRegionStepper
	instanceVariableNames: '
		myEdges {IntegerVarArray}
		myIndex {UInt32}
		myCount {UInt32}
		isLeftBounded {BooleanVar}
		mySimple {IntegerRegion}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Integers'!

(IntegerSimpleRegionStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; yourself)!

!IntegerSimpleRegionStepper methodsFor: 'operations'!

{Heaper wimpy} fetch
	^mySimple!

{BooleanVar} hasValue
	^mySimple ~~ NULL!

{void} step
	isLeftBounded ifTrue: [myIndex _ myIndex + 2] ifFalse: [myIndex _ myIndex + 1].
	isLeftBounded _ true.
	myIndex < myCount
		ifTrue: [myIndex < (myCount - 1)
			ifTrue: [mySimple _ IntegerRegion make: (myEdges integerVarAt: myIndex)
				with: (myEdges integerVarAt: myIndex + 1)]
			ifFalse: [mySimple _ IntegerRegion after: (myEdges integerVarAt: myIndex)]]
		ifFalse: [mySimple _ NULL]! !

!IntegerSimpleRegionStepper methodsFor: 'unprotected create'!

create: edges {IntegerVarArray} with: count {UInt32} with: leftBounded {BooleanVar}
	super create.
	myEdges _ edges.
	myIndex _ Int32Zero.
	myCount _ count.
	isLeftBounded _ leftBounded.  
	count == Int32Zero ifTrue:
		[leftBounded ifTrue: [mySimple _ NULL] ifFalse: [mySimple _ IntegerRegion allIntegers]]
	ifFalse: [leftBounded not ifTrue:
		[mySimple _ IntegerRegion before: (edges integerVarAt: Int32Zero)]
	ifFalse: [count = 1 ifTrue:
		[mySimple _ IntegerRegion after: (edges integerVarAt: Int32Zero)]
	ifFalse:
		[mySimple _ IntegerRegion make: (edges integerVarAt: Int32Zero) with: (edges integerVarAt: 1)]]]!

create: edges {IntegerVarArray} with: index {UInt32} with: count {UInt32} with: leftBounded {BooleanVar} with: simple {IntegerRegion}
	super create.
	myEdges _ edges.
	myIndex _ index.
	myCount _ count.
	isLeftBounded _ leftBounded.
	mySimple _ simple! !

!IntegerSimpleRegionStepper methodsFor: 'create'!

{Stepper} copy
	^IntegerSimpleRegionStepper create: myEdges
		with: myIndex
		with: myCount
		with: isLeftBounded
		with: mySimple! !

!IntegerSimpleRegionStepper methodsFor: 'printing'!

{void} printOn: oo {ostream reference}
	oo << self getCategory name << '('.
	self hasValue ifTrue: [oo << self fetch].
	oo << ')'! !Heaper subclass: #Joint
	instanceVariableNames: '
		myUnioned {XnRegion}
		myIntersected {XnRegion}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-filter'!
Joint comment:
'Joints are used to prune searches through trees of Regions. Each Joint summarizes the Joints and Regions at its node and its children using their intersection and union. If you maintain this information at each each node in the tree, then you can search for Regions in the tree efficiently using Filter::pass() to adapt the search criteria to the contents of the subtree. See also Filter::pass(Joint *).'!

(Joint getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!Joint methodsFor: 'creation'!

create: unioned {XnRegion} with:  intersected{XnRegion}
	super create.
	myUnioned _ unioned.
	myIntersected _ intersected.! !

!Joint methodsFor: 'printing'!

{void} printOn: oo {ostream reference}
	oo << self getCategory name << '(union: ' << myUnioned << '; intersected: ' << myIntersected << ')'! !

!Joint methodsFor: 'accessing'!

{XnRegion INLINE} intersected
	"The intersection of the regions at all child nodes in the tree."

	^myIntersected!

{Joint INLINE} join: other {Joint}
	"A Joint that is a parent of this Joint and the given one."
	
	^Joint make.Joint: self with: other!

{XnRegion INLINE} unioned
	"The union of the regions at all child nodes in the tree."

	^myUnioned!

{Joint} with: region {XnRegion}
	"A Joint that is a parent of this one and the given region."
	
	^Joint make.XnRegion: (myUnioned unionWith: region)
		with: (myIntersected intersect: region)! !

!Joint methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^myUnioned hashForEqual + myIntersected hashForEqual!

{BooleanVar} isEqual: other {Heaper}
	
	other cast: Joint into: [:o {Joint} |
			^(myUnioned isEqual: o unioned) and:
				[myIntersected isEqual: o intersected]]
		others: [^false].
	^false "fodder"! !

!Joint methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myUnioned _ receiver receiveHeaper.
	myIntersected _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myUnioned.
	xmtr sendHeaper: myIntersected.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Joint class
	instanceVariableNames: ''!

(Joint getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!Joint class methodsFor: 'pseudo constructors'!

make.CoordinateSpace: space {CoordinateSpace}
	"An empty Joint in the given coordinate space."
	
	^Joint create: space emptyRegion with: space fullRegion!

make.Joint: left {Joint} with: right {Joint}
	"A joint that is a parent of the two given Joints."
	
	^Joint create: (left unioned unionWith: right unioned)
		with: (left intersected intersect: right intersected)!

make.ScruSet: subs {ScruSet of: Joint}
	"A Joint that is a parent of all of the Joints in the set."
	
	| unioned {XnRegion} intersected {XnRegion} subStepper {Stepper} |
	subStepper _ subs stepper.
	unioned _ (subStepper get cast: Joint) unioned.
	intersected _ (subStepper fetch cast: Joint) intersected.
	subStepper step.
	subStepper forEach: [ :sub {Joint} |
		unioned _ unioned unionWith: sub unioned.
		intersected _ intersected intersect: sub intersected].
	^Joint create: unioned with: intersected!

make.XnRegion: both {XnRegion}
	"A Joint containing only the given region."
	
	^Joint create: both with: both!

make.XnRegion: unioned {XnRegion} with: intersected {XnRegion}
	"A Joint with the given union and intersection regions."
	
	^Joint create: unioned with: intersected! !

!Joint class methodsFor: 'smalltalk: smalltalk defaults'!

make: something
	(something isKindOf: XnRegion) ifTrue:
		[^self make.XnRegion: something].
	(something isKindOf: CoordinateSpace) ifTrue:
		[^self make.CoordinateSpace: something].
	^self make.ScruSet: (something cast: ScruSet)!

make: something with: other
	(something isKindOf: Joint) ifTrue:
		[^self make.Joint: something with: other].
	^self make.XnRegion: (something cast: XnRegion) with: other! !Heaper subclass: #Mapping
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Basic'!
Mapping comment:
'A mapping is a general mapping from one coordinate space to another, with few of the guarantees provided by Dsps.  In particular, the source and destination coordinate spaces can be different, and the mapping doesn''t have to be everywhere defined (but it has to say where it is defined via "domain" and "range" messages).  A mapping doesn''t have to be unique--the same domain position may map to multiple range positions and vice versa.  A mapping of a XuRegion must yield another XuRegion, but a mapping of a simple region doesn''t have to yield a simple region.
	
	A useful and valid way to think of a Mapping is as a (possibly infinite) set of pairs (a mathematical set, not a ScruSet).  The domain region consists of the first elements of each pair, and the range region consists of the second elements.
	
	A mapping is most useful as a representation of a version comparison of two different organizations of common elements.  The mapping would tell how positions in one organization correspond to positions in the other.'!

(Mapping getOrMakeCxxClassDescription)
	friends:
'/* friends for class Mapping */
friend void storeMapping (Mapping *, MuSet *);
friend class SimpleMapping;
';
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; yourself)!

!Mapping methodsFor: 'accessing'!

{CoordinateSpace} coordinateSpace
	"the coordinate space of the domain of the Mapping"

	self subclassResponsibility!

{XnRegion CLIENT} domain
	"Essential.  region in which it is valid."
	
	self subclassResponsibility!

{CoordinateSpace CLIENT INLINE} domainSpace
	"The coordinate space of the domain of the Mapping"

	^self coordinateSpace!

{Dsp | NULL} fetchDsp
	"if this is a Dsp or a Dsp retricted to some domain, return the underlying Dsp.  Otherwise NULL."
	self subclassResponsibility!

{BooleanVar CLIENT} isComplete
	"Essential. Return true if each Position in the domain is mapped to every Position in the range."
	
	Ravi thingToDo. "Decide what to do if it is not simple enough"
	self subclassResponsibility!

{BooleanVar CLIENT} isIdentity
	"Essential. True if this is the identify mapping on the entire space."
	
	Ravi thingToDo. "Decide about domain"
	self subclassResponsibility!

{XnRegion CLIENT} range
	"Essential.  region in which inverse is valid.  Same as the region that the domain region maps to. For you mathematicians, it is the image of the domain under the mapping."
	
	self subclassResponsibility!

{CoordinateSpace CLIENT} rangeSpace
	"The coordinate space of the range of the transformation"
	
	self subclassResponsibility!

{ImmuSet of: Mapping} simpleMappings
	"return a set of simple mappings that would combine to this one"
	self subclassResponsibility!

{ImmuSet of: Mapping} simpleRegionMappings
	"return a set of mappings with simple regions as their domains that would combine 
	to this one."
	
	self subclassResponsibility!

{Stepper CLIENT of: Mapping} simplerMappings
	"Essential. Break this Mapping up into simpler Mappings which can be combined together to get this one."
	
	^self simpleMappings stepper!

{Mapping CLIENT} unrestricted
	"Essential. If this is a 'simpler' Mapping, and not isFull, then return a yet simpleMapping of some class from which you can get more information. Note that m->restrict (region)->unrestricted () is not necessarily the same as m, since information may be lost."
	
	self fetchDsp == NULL ifTrue:
		[Heaper BLAST: #NotSimpleEnough].
	^self fetchDsp! !

!Mapping methodsFor: 'mapping'!

{Position} inverseOf: after {Position}
	"Inverse transform a position.  Must BLAST if there isn't a unique inverse.
	'a->isEqual (this->of (b))' iff 'b->isEqual (this->inverseOf (a))'."

	self subclassResponsibility!

{XnRegion} inverseOfAll: after {XnRegion}
	"Inverse transform of a region.
	'a->isEqual (this->of (b))' iff 'b->isEqual (this->inverseOf (a))'."

	self subclassResponsibility!

{IntegerVar} inverseOfInt: pos {IntegerVar} 
	"Unboxed version of 'this->inverseOf (xuInteger(pos))'. See 
	discussion in the XuInteger class comment about boxed and unboxed 
	protocols"

	^((self inverseOf: pos integer) cast: IntegerPos) asIntegerVar!

{Position CLIENT} of: before {Position} 
	"Transform a position. 'before' must be a Position of my domain space. Iff 'before' is in the domain region over which I am defined and it maps to a unique range Position then the result will be that Position. Otherwise BLAST. For example, if I map 1 to 4, 1 to 5, and 2 to 5 (and nothing else), then this method will yield 5 given 2, but BLAST given anything else. To find all the values 1 maps to, use the 'ofAll' operation on the singleton region whose member is 1."

	self subclassResponsibility!

{XnRegion CLIENT} ofAll: before {XnRegion} 
	"Essential.  Transform a region. The result region has exactly those positions which are the mappings of the positions in 'before'. This must be the case even if these positions cannot be enumerated. If the mapping for a given position is multiply defined, then (if that position is in 'before') all position it maps to must be in the result. Because of this property, the behavior of this method must be taken as really defining the nature of a particular mapping (with other method's behavior being defined in terms of this one), despite the fact that it would have been more natural to take Mapping::of(Position *) as the defining behavior."

	self subclassResponsibility!

{IntegerVar} ofInt: pos {IntegerVar}
	"Unboxed version of 'this->of (xuInteger(pos))'.  See discussion in the XuInteger class 
	comment about boxed and unboxed protocols"

	^ ((self of: pos integer) quickCast: IntegerPos) asIntegerVar! !

!Mapping methodsFor: 'operations'!

{Mapping} appliedAfter: dsp {Dsp}
	"Defined by the equivalence:
		M->transformedBy(D)->of(R) isEqual (M->of(D->of(R)))
	for all regions R in the domainSpace of M. Equivalent to Dsp::compose, except that it is between a Mapping and a Dsp."
	
	self subclassResponsibility!

{Mapping CLIENT} combine: other {Mapping}
	"Essential.  Result will do both mine and other's mappings.  It will do my mapping where I am defined, and it will do the other's where his is defined.  If we are both defined over some domain positions, then the result is a multi-valued mapping.  If you think of a Mapping simply as a set of pairs (see class comment), then 'combine' yields a Mapping consisting of the union of these two sets."
	
	| result {Mapping} |
	result _ self fetchCombine: other.
	result ~~ NULL ifTrue: [^result].
	result _ other fetchCombine: self.
	result ~~ NULL
		ifTrue: [^result]
	ifFalse:
		[| set {MuSet of: Mapping} |
		set _ MuSet make.
		set store: self.
		set store: other.
		^CompositeMapping 
			privateMakeMapping: self domainSpace
			with: self rangeSpace
			with: set asImmuSet]!

{Mapping CLIENT} inverse
	"Essential. Return the inverse of this transformation. Considering the Mapping as a set of pairs (see class comment), return the Dsp which has the mirror image of all my pairs."
	
	self subclassResponsibility!

{Mapping} preCompose: dsp {Dsp}
	"There is no sensible explanation for what this message does on Mappings 
	which aren't Dsps.  In the future, we will probably retire this message,
	so don't use it."

	self subclassResponsibility!

{Mapping CLIENT} restrict: region {XnRegion}
	"Essential.  Restrict the domain.  The domain of the result will be the intersection of my domain and 'region'.  Otherwise we are the same."
	
	self subclassResponsibility!

{Mapping} restrictRange: region {XnRegion}
	"Restrict the range.  The range of the result will be the intersection of my range and 'region'.  Otherwise we are the same."
	
	self subclassResponsibility!

{Mapping} transformedBy: dsp {Dsp}
	"Defined by the equivalence:
		M->transformedBy(D)->of(R) isEqual (D->of(M->of(R)))
	for all regions R in the domainSpace of M. Equivalent to Dsp::preCompose, except that it is between a Mapping and a Dsp."
	
	self subclassResponsibility! !

!Mapping methodsFor: 'vulnerable: accessing'!

{Mapping} fetchCombine: mapping {Mapping}
	"if I know how to combine the two into a single mapping, then I do so"
	self subclassResponsibility! !

!Mapping methodsFor: 'smalltalk: passe'!

{PrimArray} export

	self passe! !

!Mapping methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^Heaper takeOop! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Mapping class
	instanceVariableNames: ''!

(Mapping getOrMakeCxxClassDescription)
	friends:
'/* friends for class Mapping */
friend void storeMapping (Mapping *, MuSet *);
friend class SimpleMapping;
';
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; yourself)!

!Mapping class methodsFor: 'pseudo constructors'!

{Mapping INLINE} make.CoordinateSpace: cs {CoordinateSpace} 
	with.CoordinateSpace: rs {CoordinateSpace} 
	"Make an empty mapping from cs to rs. The domain will consist of an 
	empty region in cs, and the range will consist of an empty region in rs"

	^EmptyMapping make: cs with: rs!

make.CoordinateSpace: cs {CoordinateSpace} with.Region: values {XnRegion}
	"Make a constant mapping from all positions in cs to all positions in values."
	
	values isEmpty
		ifTrue: [^Mapping make.CoordinateSpace: cs
			with.CoordinateSpace: values coordinateSpace]
		ifFalse: [^ConstantMapping create: cs with: values]!

{Mapping} make: cs {CoordinateSpace} 
	with: rs {CoordinateSpace} 
	with: mappings {ImmuSet of: Mapping}
	"The combine of all the mappings in 'mappings'  All domains must be 
	in cs and all ranges in rs.  cs and rs must be provided in case 
	'mappings' is empty."
	
	mappings isEmpty
		ifTrue: [^EmptyMapping make: cs with: rs ]
		ifFalse:
			[| result {MuSet of: Mapping} |
			result _ MuSet make.
			mappings stepper forEach: [ :each {Mapping} |
				CompositeMapping storeMapping: each with: result].
			^CompositeMapping privateMakeMapping: cs with: rs with: mappings]! !

!Mapping class methodsFor: 'smalltalk: smalltalk defaults'!

make: a with: b
	a cast: CoordinateSpace.
	(b isKindOf: CoordinateSpace) ifTrue:
		[^self make.CoordinateSpace: a with.CoordinateSpace: b].
	^self make.CoordinateSpace: a with.Region: (b cast: XnRegion)! !

!Mapping class methodsFor: 'smalltalk: passe'!

make.Region: region {XnRegion} with: mapping {Mapping}
	self passe! !

!Mapping class methodsFor: 'smalltalk: system'!

info.stProtocol
"{Mapping CLIENT} combine: other {Mapping}
{XuRegion CLIENT} domain
{CoordinateSpace CLIENT} domainSpace
{Mapping CLIENT} inverse
{BooleanVar CLIENT} isComplete
{BooleanVar CLIENT} isIdentity
{Position CLIENT} of: before {Position}
{XuRegion CLIENT} ofAll: before {XuRegion}
{XuRegion CLIENT} range
{CoordinateSpace CLIENT} rangeSpace
{Mapping CLIENT} restrict: region {XuRegion}
{Stepper CLIENT of: Mapping} simplerMappings
{Mapping CLIENT} unrestricted
"! !Mapping subclass: #CompositeMapping
	instanceVariableNames: '
		myCS {CoordinateSpace}
		myRS {CoordinateSpace}
		myMappings {ImmuSet of: Mapping}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces'!

(CompositeMapping getOrMakeCxxClassDescription)
	friends:
'/* friends for class CompositeMapping */
friend SPTR(Mapping) mapping(Mapping*, Mapping*);
friend SPTR(Mapping)  privateMakeMapping (CoordinateSpace *, CoordinateSpace *, ImmuSet OF1(Mapping) *);';
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!CompositeMapping methodsFor: 'operations'!

{Mapping} appliedAfter: dsp {Dsp}

	| result {SetAccumulator of: Mapping} |
	result _ SetAccumulator make.
	myMappings stepper forEach: [ :each {Mapping} |
		result step: (each appliedAfter: dsp)].
	^CompositeMapping
		privateMakeMapping: self coordinateSpace
		with: self rangeSpace
		with: (result value cast: ImmuSet)!

{Mapping} inverse

	| result {Mapping} |
	Ravi thingToDo. "can this be done more efficiently by taking advantage of invariants?"
	result := Mapping make.CoordinateSpace: self rangeSpace with: self domainSpace.
	myMappings stepper forEach: [ :sub {Mapping} |
		result := result combine: sub inverse].
	^result!

{Mapping} preCompose: dsp {Dsp}

	| result {SetAccumulator of: Mapping} |
	result _ SetAccumulator make.
	myMappings stepper forEach: [ :each {Mapping} |
		result step: (each preCompose: dsp)].
	^CompositeMapping
		privateMakeMapping: self coordinateSpace
		with: self rangeSpace
		with: (result value cast: ImmuSet)!

{Mapping} restrict: region {XnRegion}

	| result {MuSet of: Mapping} |
	result _ MuSet make.
	myMappings stepper forEach: [ :each {Mapping} | 
		| restricted {Mapping} |
		restricted _ each restrict: region.
		restricted domain isEmpty ifFalse:
			[result store: restricted]].
	^CompositeMapping
		privateMakeMapping: self coordinateSpace
		with: self rangeSpace
		with: result asImmuSet!

{Mapping} restrictRange: region {XnRegion}

	| result {MuSet of: Mapping} |
	result _ MuSet make.
	myMappings stepper forEach: [ :each {Mapping} | 
		| restricted {Mapping} |
		restricted _ each restrictRange: region.
		restricted domain isEmpty ifFalse:
			[result store: restricted]].
	^CompositeMapping
		privateMakeMapping: self coordinateSpace
		with: self rangeSpace
		with: result asImmuSet!

{Mapping} transformedBy: dsp {Dsp}

	| result {SetAccumulator of: Mapping} |
	result _ SetAccumulator make.
	myMappings stepper forEach: [ :each {Mapping} |
		result step: (each transformedBy: dsp)].
	^CompositeMapping
		privateMakeMapping: self coordinateSpace
		with: self rangeSpace
		with: (result value cast: ImmuSet)! !

!CompositeMapping methodsFor: 'accessing'!

{CoordinateSpace} coordinateSpace

	^myCS!

{XnRegion} domain
	
	| result {XnRegion} |
	result _ self coordinateSpace emptyRegion.
	myMappings stepper forEach: [ :each {Mapping} |
		result _ result unionWith: each domain].
	^result!

{Dsp | NULL} fetchDsp
	^NULL!

{BooleanVar} isComplete

	^false "blast?"!

{BooleanVar} isIdentity

	^false!

{XnRegion} range
	| result {XnRegion} |
	result _ self rangeSpace emptyRegion.
	myMappings stepper forEach: [ :each {Mapping} |
		result _ result unionWith: each range].
	^result!

{CoordinateSpace} rangeSpace

	^myRS!

{ImmuSet of: Mapping} simpleMappings
	^myMappings!

{ImmuSet of: Mapping} simpleRegionMappings

	| simpleMappings {MuSet of: Mapping} eachSimple {Mapping} |
	
	simpleMappings _ MuSet make.
	myMappings stepper forEach: [ :each {Mapping} | 
		each domain isSimple 
			ifTrue:
				[simpleMappings store: each]
			ifFalse:
				[each domain simpleRegions forEach: [:simpleRegion {XnRegion} |
					eachSimple _ each restrict: simpleRegion.
					simpleMappings store: eachSimple]]].
	^(ImmuSet make.MuSet: simpleMappings)! !

!CompositeMapping methodsFor: 'transforming'!

{Position} inverseOf: pos {Position}

	| result {Position} |
	result _ NULL.
	myMappings stepper forEach: [ :each {Mapping} |
		(each range hasMember: pos) ifTrue:
			[result == NULL
				ifTrue: [result _ each inverseOf: pos]
				ifFalse: [Heaper BLAST: #MultiplePreImages]]].
	result == NULL
		ifTrue: [Heaper BLAST: #NotInRange].
	^result!

{XnRegion} inverseOfAll: reg {XnRegion}

	| result {XnRegion} |
	result _ self coordinateSpace emptyRegion.
	myMappings stepper forEach: [ :each {Mapping} |
		result _ result unionWith: (each inverseOfAll: reg)].
	^result!

{Position} of: pos {Position}

	| result {Position} |
	result _ NULL.
	myMappings stepper forEach: [ :each {Mapping} |
		(each domain hasMember: pos) ifTrue:
			[result == NULL
				ifTrue: [result _ each of: pos]
				ifFalse: [Heaper BLAST: #MultipleImages]]].
	result == NULL
		ifTrue: [Heaper BLAST: #NotInDomain].
	^result!

{XnRegion} ofAll: reg {XnRegion}

	| result {XnRegion} |
	result _ self rangeSpace emptyRegion.
	myMappings stepper forEach: [ :each {Mapping} |
		result _ result unionWith: (each ofAll: reg)].
	^result! !

!CompositeMapping methodsFor: 'printing'!

{void} printOn: stream {ostream reference}

	stream << self getCategory name.
	myMappings printOnWithSimpleSyntax: stream with: '(' with: ', ' with: ')'! !

!CompositeMapping methodsFor: 'private: private creation'!

create: cs {CoordinateSpace} with: rs {CoordinateSpace} with: mappings {ImmuSet of: Mapping}
	super create.
	myCS _ cs.
	myRS _ rs.
	myMappings _ mappings! !

!CompositeMapping methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^#cat.U.CompositeMapping hashForEqual bitXor: myMappings hashForEqual!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: CompositeMapping into: [:cm |
			^cm simpleMappings isEqual: myMappings]
		others: [^false].
	^false "fodder"! !

!CompositeMapping methodsFor: 'protected: protected'!

{Mapping} fetchCombine: mapping {Mapping}

	(mapping isKindOf: EmptyMapping)
		ifTrue: [  ^ self ]
		ifFalse:
			[| result {MuSet of: Mapping} |
			result _ myMappings asMuSet.
			(mapping isKindOf: CompositeMapping) ifTrue:
				[mapping simpleMappings stepper forEach: [ :each {Mapping} |
					CompositeMapping storeMapping: each with: result]]
				ifFalse:
					[CompositeMapping storeMapping: mapping with: result].
			^CompositeMapping privateMakeMapping: myCS with: myRS with: result asImmuSet]! !

!CompositeMapping methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myCS _ receiver receiveHeaper.
	myRS _ receiver receiveHeaper.
	myMappings _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myCS.
	xmtr sendHeaper: myRS.
	xmtr sendHeaper: myMappings.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

CompositeMapping class
	instanceVariableNames: ''!

(CompositeMapping getOrMakeCxxClassDescription)
	friends:
'/* friends for class CompositeMapping */
friend SPTR(Mapping) mapping(Mapping*, Mapping*);
friend SPTR(Mapping)  privateMakeMapping (CoordinateSpace *, CoordinateSpace *, ImmuSet OF1(Mapping) *);';
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!CompositeMapping class methodsFor: 'functions'!

{Mapping} privateMakeMapping: cs {CoordinateSpace} 
	with: rs {CoordinateSpace} 
	with: mappings {ImmuSet of: Mapping}
	
	mappings isEmpty
		ifTrue: [^EmptyMapping make: cs with: rs]
		ifFalse:
			[mappings count = 1
				ifTrue: [^mappings theOne cast: Mapping]
				ifFalse: [^CompositeMapping create: cs with: rs with: mappings]]!

{void} storeMapping: map {Mapping} with: maps {MuSet of: Mapping}
	"store a map into the set, checking to see if it can be combined with another"
	maps stepper forEach: [ :each {Mapping} | | combined {Mapping} |
		combined _ map fetchCombine: each.
		combined ~~ NULL ifTrue:
			[combined _ each fetchCombine: map].
		combined ~~ NULL ifTrue:
			[maps remove: each.
			maps introduce: combined.
			^VOID]].
	maps introduce: map! !Mapping subclass: #ConstantMapping
	instanceVariableNames: '
		myCoordinateSpace {CoordinateSpace}
		myValues {XnRegion}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces'!

(ConstantMapping getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!ConstantMapping methodsFor: 'creation'!

create: cs {CoordinateSpace} with: values {XnRegion}
	super create.
	myCoordinateSpace _ cs.
	myValues _ values! !

!ConstantMapping methodsFor: 'transforming'!

{Position} inverseOf: pos {Position unused}

	Heaper BLAST: #MultiplePreImages.
	^NULL!

{XnRegion} inverseOfAll: reg {XnRegion}

	(reg intersects: myValues)
		ifTrue: [^self domain]
		ifFalse: [^self coordinateSpace emptyRegion]!

{Position} of: pos {Position unused}

	(myValues isFinite and: [myValues count == 1])
		ifTrue: [^myValues theOne]
		ifFalse: [Heaper BLAST: #MultipleImages].
	^NULL "fodder"!

{XnRegion} ofAll: reg {XnRegion}

	reg isEmpty
		ifTrue: [^self rangeSpace emptyRegion]
		ifFalse: [^self range]! !

!ConstantMapping methodsFor: 'accessing'!

{Mapping} appliedAfter: dsp {Dsp unused}

	^self!

{CoordinateSpace} coordinateSpace

	^ myCoordinateSpace!

{XnRegion} domain
	
	^myCoordinateSpace fullRegion!

{Dsp | NULL} fetchDsp
	^ NULL!

{BooleanVar} isComplete

	^true!

{BooleanVar} isIdentity

	^false!

{Mapping} preCompose: dsp {Dsp}

	^Mapping make.CoordinateSpace: myCoordinateSpace 
		with.Region: (dsp ofAll: myValues)!

{XnRegion} range
	^myValues!

{CoordinateSpace} rangeSpace

	^myValues coordinateSpace!

{ImmuSet of: Mapping} simpleMappings
	^ ImmuSet make with: self.!

{ImmuSet of: Mapping} simpleRegionMappings

	^ ImmuSet make with: self.!

{Mapping} transformedBy: dsp {Dsp}

	^Mapping make.CoordinateSpace: myCoordinateSpace 
		with.Region: (dsp ofAll: myValues)! !

!ConstantMapping methodsFor: 'printing'!

{void} printOn: oo {ostream reference}

	oo << self getCategory name << '(' << myValues << ')'! !

!ConstantMapping methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^myCoordinateSpace hashForEqual + myValues hashForEqual!

{BooleanVar} isEqual: other {Heaper}
	other
		cast: ConstantMapping into: [:cm |
			^(cm coordinateSpace isEqual: myCoordinateSpace)
			 and: [cm values isEqual: myValues]]
		others: [^false].
	^false "fodder"! !

!ConstantMapping methodsFor: 'private: private'!

{XnRegion} values
	^myValues! !

!ConstantMapping methodsFor: 'operations'!

{Mapping} inverse

	^(Mapping make.CoordinateSpace: self rangeSpace
		with.Region: self domainSpace fullRegion) restrict: self range!

{Mapping} restrict: region {XnRegion}

	^SimpleMapping restrictTo: region with: self!

{Mapping} restrictRange: region {XnRegion}

	^Mapping make.CoordinateSpace: myCoordinateSpace
		with.Region: (myValues intersect: region)! !

!ConstantMapping methodsFor: 'protected'!

{Mapping} fetchCombine: aMapping {Mapping}

	aMapping 
		cast: ConstantMapping into: [:cm |
			^Mapping make.CoordinateSpace: self coordinateSpace
				with.Region: (myValues unionWith: cm values)]
		others: [^NULL].
	^NULL "fodder"! !

!ConstantMapping methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myCoordinateSpace _ receiver receiveHeaper.
	myValues _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myCoordinateSpace.
	xmtr sendHeaper: myValues.! !Mapping subclass: #Dsp
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Basic'!
Dsp comment:
'A Dsp is a mapping from a coordinate space to itself that preserves simple regions.  Every coordinate space must have an identity Dsp (which maps all positions of that space onto themselves). Dsps are necessarily invertable and composable.

(Removed from CoordinateSpace because Dsps are still internal.:
Dsp -- The transformations that can be applied to positions and regions of this cordinate space.  A Dsp is necessarily invertible but generally not order-preserving. The composition of two Dsps is always a Dsp. If you can subtract two Dsps, the result will be another Dsp.  The Dsp of a Position in this space is always another Position in this space.  The Dsp of a simple region is always another simple region.)
	
	
	Considering a Mapping as a set of pairs, a Dsp is one for which each position appears exactly once in the first elements of the pairs, and exactly once in the second elements.  Composition of Dsps isn''t necessarily commutative, though there are currently no counter-examples.  Therefore we must be extra careful to avoid embodying commutativity assumptions in our code, as we currently have no way of finding such bugs.'!

(Dsp getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #DEFERRED; yourself)!

!Dsp methodsFor: 'accessing'!

{Mapping INLINE} appliedAfter: dsp {Dsp}
	"For Dsp's, it is identical to compose."
	
	^self compose: dsp!

{CoordinateSpace} coordinateSpace
	"the coordinate space of the domain and range of the Dsp"

	self subclassResponsibility!

{XnRegion} domain
	"Must be valid everywhere in the domain for a Dsp."
	
	^self coordinateSpace fullRegion!

{(Dsp | NULL) INLINE} fetchDsp
	^ self!

{BooleanVar INLINE} isComplete

	^false!

{BooleanVar} isIdentity
	"Says whether this Dsp maps every Position onto itself"
	
	self subclassResponsibility!

{Mapping} preCompose: dsp {Dsp} 
	"a->compose(b) is the same as b->preCompose(a).  Don't use it, use
	compose instead."

	^dsp compose: self!

{XnRegion} range
	
	^self coordinateSpace fullRegion!

{CoordinateSpace INLINE} rangeSpace
	"Same as the domain space"
	^ self coordinateSpace!

{ImmuSet of: Mapping} simpleMappings
	"A Dsp is a simpleMapping already, so this just returns the singleton set containing me"
	^ ImmuSet make with: self.!

{ImmuSet of: Mapping} simpleRegionMappings
	"The domain of a Dsp is the simple region covering the whole coordinate space, so
	I just return a singleton set containing myself"

	^ ImmuSet make with: self.!

{Mapping INLINE} transformedBy: dsp {Dsp}
	"For Dsp's, it is identical to preCompose."
	
	^dsp compose: self! !

!Dsp methodsFor: 'combining'!

{Dsp} compose: other {Dsp}
	"Return the composition of the two Dsps. Two Dsps of the same space are always composable.
	(a->compose(b) ->minus(b))->isEqual (a)
	(a->compose(b) ->of(pos))->isEqual (a->of (b->of (pos))"

	self subclassResponsibility!

{Mapping} inverse
	"Return the inverse of this transformation. Considering the Dsp as a set of pairs 
	(see class comment), return the Dsp which has the mirror image of all my 
	pairs."

	self subclassResponsibility!

{Dsp} minus: other {Dsp}
	"Return the difference of the two Dsps.
	(a->compose(b) ->minus(b))->isEqual (a)"

	self subclassResponsibility! !

!Dsp methodsFor: 'transforming'!

{XnRegion} ofAll: reg {XnRegion}
	"If 'reg' is a simple region, then the result must also be simple"
	
	self subclassResponsibility! !

!Dsp methodsFor: 'operations'!

{Mapping INLINE} restrict: region {XnRegion}

	^SimpleMapping restrictTo: region with: self!

{Mapping} restrictRange: region {XnRegion}

	^SimpleMapping restrictTo: (self inverseOfAll: region) with: self! !

!Dsp methodsFor: 'protected:'!

{Mapping} fetchCombine: mapping {Mapping}

	(self isEqual: mapping)
		ifTrue: [^self]
		ifFalse: [^NULL]! !

!Dsp methodsFor: 'deferred transforming'!

{Position} inverseOf: pos {Position}
	"Since Dsps always represent a unique mapping in either direction, the permission to BLAST
	in the Mapping constract no longer applies.
	a->inverseOf(b) ->isEqual (a->inverse()->of(b))"
	
	^(self inverse cast: Dsp) of: pos!

{XnRegion} inverseOfAll: reg {XnRegion}
	"Inverse transform a region.  A simple region must yield a simple region.
	a->inverseOfAll(b) ->isEqual (a->inverseAll()->of(b))"

	^(self inverse cast: Dsp) ofAll: reg!

{Position} of: pos {Position}
	"Since Dsps always represent a unique mapping in either direction, the permission to BLAST
	in the Mapping constract no longer applies."
	
	^(self ofAll: pos asRegion) theOne! !

!Dsp methodsFor: 'deferred combining'!

{Dsp} inverseCompose: other {Dsp}
	"Return the composition of my inverse with the other.
	a->inverseCompose(b) ->isEqual (a->inverse()->compose(b))"

	^(self inverse cast: Dsp) compose: other! !Dsp subclass: #CrossMapping
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-cross'!
CrossMapping comment:
'All other crossed mappings must be gotten by factoring the non-dsp aspects out into the generic non-dsp mapping objects.  This class represents what remains after the factoring.'!

(CrossMapping getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; yourself)!

!CrossMapping methodsFor: 'transforming'!

{XnRegion} ofAll: reg {XnRegion}
	
	self subclassResponsibility! !

!CrossMapping methodsFor: 'combining'!

{Dsp} compose: other {Dsp}
	
	self subclassResponsibility!

{Mapping} inverse

	self subclassResponsibility!

{Dsp} minus: other {Dsp}

	self subclassResponsibility! !

!CrossMapping methodsFor: 'accessing'!

{CoordinateSpace} coordinateSpace
	
	self subclassResponsibility!

{BooleanVar} isIdentity
	
	self subclassResponsibility!

{Dsp CLIENT} subMapping: index {Int32}
	"The Dsp applied to Positions in the given subspace."
	
	self subclassResponsibility!

{PtrArray CLIENT of: Dsp} subMappings
	"The Mappings applied to Positions in each of the subspaces. Each of these is already simple enough that it is either the identityMapping or a visible subclass like IntegerMapping."
	
	self subclassResponsibility! !

!CrossMapping methodsFor: 'smalltalk: passe'!

{Dsp} subDsp: index {Int32}

	self passe!

{PtrArray of: Dsp} subDsps

	self passe "subMappings"! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

CrossMapping class
	instanceVariableNames: ''!

(CrossMapping getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; yourself)!

!CrossMapping class methodsFor: 'pseudoconstructors'!

make: space {CrossSpace} with: subDsps {(PtrArray of: Dsp | NULL) default: NULL}

	| subDs {PtrArray of: Dsp} |
	subDs := PtrArray nulls: space axisCount.
	Int32Zero almostTo: subDs count do: [:i {Int32} |
		subDs at: i store: (space axis: i) identityDsp].
	
	subDsps ~~ NULL ifTrue:
		[Int32Zero almostTo: subDs count do: [:i {Int32} |
			| subDsp {Dsp | NULL} |
			(subDsp := (subDsps fetch: i) cast: Dsp) ~~ NULL ifTrue:
				[subDs at: i store: subDsp]]].
	
	^GenericCrossDsp create: space with: subDs! !

!CrossMapping class methodsFor: 'smalltalk: defaults'!

make: space

	^self make: space with: NULL! !

!CrossMapping class methodsFor: 'smalltalk: system'!

info.stProtocol
"{Dsp CLIENT} subMapping: index {Int32}
{PtrArray CLIENT of: Dsp} subMappings
"! !CrossMapping subclass: #GenericCrossDsp
	instanceVariableNames: '
		mySpace {CrossSpace}
		mySubDsps {PtrArray of: Dsp}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-cross'!
GenericCrossDsp comment:
' Was NOT.A.TYPE but that obstructed compilation.'!

(GenericCrossDsp getOrMakeCxxClassDescription)
	friends:
'friend class GenericCrossSpace;
';
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!GenericCrossDsp methodsFor: 'accessing'!

{CoordinateSpace} coordinateSpace
	
	^mySpace!

{BooleanVar} isIdentity
	
	Int32Zero almostTo: mySubDsps count do: [:i {Int32} |
		(self subMapping: i) isIdentity ifFalse:
			[^false]].
	^true!

{Dsp} subMapping: index {Int32}

	^(mySubDsps fetch: index) cast: Dsp!

{PtrArray of: Dsp} subMappings

	^mySubDsps copy cast: PtrArray! !

!GenericCrossDsp methodsFor: 'private: creation'!

create: space {CrossSpace} with: subDsps {PtrArray of: Dsp}
	
	super create.
	mySpace := space.
	mySubDsps := subDsps! !

!GenericCrossDsp methodsFor: 'transforming'!

{Position} inverseOf: position {Position}

	position cast: ActualTuple into: [ :tuple | | result {PtrArray of: Position} |
		result := PtrArray nulls: tuple count.
		Int32Zero almostTo: tuple count do: [ :dimension {Int32} |
			result at: dimension
				store: ((self subMapping: dimension) inverseOf: (tuple positionAt: dimension))].
		^ActualTuple make: result].
	^ NULL "compiler fodder"!

{XnRegion} inverseOfAll: region {XnRegion}
	
	region cast: GenericCrossRegion into:
		[ :cross | | result {BoxAccumulator} boxes {BoxStepper} |
		result := BoxAccumulator make: mySpace with: cross boxCount.
		boxes := cross boxStepper.
		[boxes hasValue] whileTrue:
			[result addInverseTransformedBox: boxes with: self.
			boxes step].
		^result region].
	^ NULL "compiler fodder"!

{Position} of: position {Position}

	position cast: ActualTuple into: [ :tuple | | result {PtrArray of: Position} |
		result := PtrArray nulls: tuple count.
		Int32Zero almostTo: tuple count do: [ :dimension {Int32} |
			result at: dimension
				store: ((self subMapping: dimension) of: (tuple positionAt: dimension))].
		^ActualTuple make: result].
	^ NULL "compiler fodder"!

{XnRegion} ofAll: region {XnRegion}
	
	region cast: GenericCrossRegion into:
		[ :cross | | result {BoxAccumulator} boxes {BoxStepper} |
		result := BoxAccumulator make: mySpace with: cross boxCount.
		boxes := cross boxStepper.
		[boxes hasValue] whileTrue:
			[result addTransformedBox: boxes with: self.
			boxes step].
		^result region].
	^ NULL "compiler fodder"! !

!GenericCrossDsp methodsFor: 'combining'!

{Dsp} compose: other {Dsp}
	
	| newSubDsps {PtrArray of: Dsp} |
	newSubDsps := PtrArray nulls: mySubDsps count.
	other cast: CrossMapping into: [ :cross |
		Int32Zero almostTo: newSubDsps count do: [ :dimension {Int32} |
			newSubDsps at: dimension
				store: ((self subMapping: dimension) compose: (cross subMapping: dimension))].
		^GenericCrossDsp make: mySpace with: newSubDsps].
	^ NULL "compiler fodder"!

{Mapping} inverse
	
	| newSubDsps {PtrArray of: Dsp} |
	newSubDsps := PtrArray nulls: mySubDsps count.
	Int32Zero almostTo: newSubDsps count do: [ :dimension {Int32} |
		newSubDsps at: dimension
			store: ((self subMapping: dimension) inverse cast: Dsp)].
	^GenericCrossDsp create: mySpace with: newSubDsps!

{Dsp} inverseCompose: other {Dsp}
	
	| newSubDsps {PtrArray of: Dsp} |
	newSubDsps := PtrArray nulls: mySubDsps count.
	other cast: CrossMapping into: [ :cross |
		Int32Zero almostTo: newSubDsps count do: [ :dimension {Int32} |
			newSubDsps at: dimension
				store: ((self subMapping: dimension) inverseCompose: (cross subMapping: dimension))].
		^GenericCrossDsp make: mySpace with: newSubDsps].
	^ NULL "compiler fodder"!

{Dsp} minus: other {Dsp}
	
	| newSubDsps {PtrArray of: Dsp} |
	newSubDsps := PtrArray nulls: mySubDsps count.
	other cast: CrossMapping into: [ :cross |
		Int32Zero almostTo: newSubDsps count do: [ :dimension {Int32} |
			newSubDsps at: dimension
				store: ((self subMapping: dimension) minus: (cross subMapping: dimension))].
		^GenericCrossDsp make: mySpace with: newSubDsps].
	^ NULL "compiler fodder"! !

!GenericCrossDsp methodsFor: 'private: accessing'!

{PtrArray of: Dsp} secretSubDsps
	"The actual array of sub Dsps. DO NOT MODIFY"
	
	^mySubDsps! !

!GenericCrossDsp methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^(mySpace hashForEqual
		bitXor: mySubDsps contentsHash)
		bitXor: self getCategory hashForEqual!

{BooleanVar} isEqual: other {Heaper}

	other cast: GenericCrossDsp into: [ :cross |
		^mySubDsps contentsEqual: cross secretSubDsps]
	others:
		[^false].
	^ false "compiler fodder"! !

!GenericCrossDsp methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	mySpace _ receiver receiveHeaper.
	mySubDsps _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: mySpace.
	xmtr sendHeaper: mySubDsps.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GenericCrossDsp class
	instanceVariableNames: ''!

(GenericCrossDsp getOrMakeCxxClassDescription)
	friends:
'friend class GenericCrossSpace;
';
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!GenericCrossDsp class methodsFor: 'smalltalk: defaults'!

make: space

	^self make: space with: NULL! !

!GenericCrossDsp class methodsFor: 'private: pseudoconstructors'!

{GenericCrossDsp} identity: space {GenericCrossSpace}
	with: subSpaces {PtrArray of: CoordinateSpace}
	"Only used during construction; must pass the array in explicitly since the space isnt initialized yet"

	| result {PtrArray of: Dsp} |
	result := PtrArray nulls: subSpaces count.
	Int32Zero almostTo: result count do: [ :dimension {Int32} |
		result at: dimension store: ((subSpaces fetch: dimension) cast: CoordinateSpace) identityDsp].
	^self create: space with: result! !Dsp subclass: #IdentityDsp
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Unordered'!
IdentityDsp comment:
'An implementation sharing convenience for Dsp classes which only provide the identity mapping functionality for their coordinate spaces.  This provides everything except the coordinate space itself (which must be provided by the subclass).  Will eventually be declared NOT_A_TYPE, so don''t use it in type declarations.  
	
	Assumes that if a given space uses it as its identity Dsp, then the one cached instance will be the only identity Dsp for that space.  I.e., I do equality comparison as an EQ object.  If this assumpsion isn''t true, please override isEqual and hashForEqual.  See PathDsp.
	
	IdentityDsp is in module "unorder" because typically unordered spaces will only have an identity Dsp and so want to subclass this class.  Non-unordered spaces should also feel free to use this as appropriate.'!

(IdentityDsp getOrMakeCxxClassDescription)
	friends:
'/* friends for class IdentityDsp */
friend SPTR(Dsp) dsp(CoordinateSpace*);
friend SPTR(Dsp) dsp(IntegerVar);';
	attributes: ((Set new) add: #NOT.A.TYPE; add: #DEFERRED; yourself)!

!IdentityDsp methodsFor: 'creation'!

create
	super create! !

!IdentityDsp methodsFor: 'transforming'!

{Position} inverseOf: pos {Position}

	^pos!

{XnRegion} inverseOfAll: reg {XnRegion}

	^reg!

{Position} of: pos {Position}

	^pos!

{XnRegion} ofAll: reg {XnRegion}

	^reg! !

!IdentityDsp methodsFor: 'combining'!

{Dsp} compose: other {Dsp}

	^ other!

{Mapping} inverse

	^ self!

{Dsp} inverseCompose: other {Dsp}

	^ other!

{Dsp} minus: other {Dsp}

	^other inverse cast: Dsp! !

!IdentityDsp methodsFor: 'printing'!

{void} printOn: oo {ostream reference}

	oo << self getCategory name << '(' << self coordinateSpace << ')'! !

!IdentityDsp methodsFor: 'accessing'!

{BooleanVar} isIdentity
	^ true! !

!IdentityDsp methodsFor: 'deferred accessing'!

{CoordinateSpace} coordinateSpace

	self subclassResponsibility! !

!IdentityDsp methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^Heaper takeOop!

{BooleanVar} isEqual: other {Heaper}
	^self == other! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

IdentityDsp class
	instanceVariableNames: 'theDsp {IdentityDsp star} '!

(IdentityDsp getOrMakeCxxClassDescription)
	friends:
'/* friends for class IdentityDsp */
friend SPTR(Dsp) dsp(CoordinateSpace*);
friend SPTR(Dsp) dsp(IntegerVar);';
	attributes: ((Set new) add: #NOT.A.TYPE; add: #DEFERRED; yourself)!

!IdentityDsp class methodsFor: 'smalltalk: smalltalk initialization'!

initTimeInherited

	theDsp _ (self new.AllocType: #PERSISTENT) create.!

linkTimeInherited

	theDsp _ NULL.!

suppressInitTimeInherited!

suppressLinkTimeInherited! !IdentityDsp subclass: #FilterDsp
	instanceVariableNames: 'myCS {FilterSpace}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Filter'!
FilterDsp comment:
'There are no non-trivial Dsps currently defined on a FilterSpace.

It would be possible to define them with reference to a Dsp in the baseSpace, as
	filterDsp->of(filter)->match(R) iff filter->match(filterDsp->baseDsp()->inverseOf(R))
		for all R in the base space.
However, we have not yet found a use for them.'!

(FilterDsp getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!FilterDsp methodsFor: 'creation'!

create: cs {CoordinateSpace}
	super create.
	myCS _ cs cast: FilterSpace.! !

!FilterDsp methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^myCS hashForEqual + #cat.U.FilterDsp hashForEqual!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: FilterDsp into: [:fd |
			^fd coordinateSpace isEqual: myCS]
		others: [^false].
	^false "fodder"! !

!FilterDsp methodsFor: 'accessing'!

{CoordinateSpace} coordinateSpace

	^myCS! !

!FilterDsp methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myCS _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myCS.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

FilterDsp class
	instanceVariableNames: ''!

(FilterDsp getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!FilterDsp class methodsFor: 'pseudo constructors'!

make: cs {FilterSpace}
	"An identity Dsp on the given FilterSpace."
	
	^FilterDsp create: cs! !

!FilterDsp class methodsFor: 'smalltalk: initialization'!

suppressInitTimeInherited!

suppressLinkTimeInherited! !IdentityDsp subclass: #HeaperDsp
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Unordered'!

(HeaperDsp getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #PSEUDO.COPY; add: #CONCRETE; add: #NOT.A.TYPE; yourself)!

!HeaperDsp methodsFor: 'accessing'!

{CoordinateSpace} coordinateSpace

	^HeaperSpace make! !

!HeaperDsp methodsFor: 'creation'!

create
	super create! !

!HeaperDsp methodsFor: 'generated:'!

{void} sendSelfTo: xmtr {Xmtr}! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HeaperDsp class
	instanceVariableNames: ''!

(HeaperDsp getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #PSEUDO.COPY; add: #CONCRETE; add: #NOT.A.TYPE; yourself)!

!HeaperDsp class methodsFor: 'pseudo constructors'!

{Dsp} make 
	^(theDsp basicCast: IdentityDsp) basicCast: HeaperDsp!

{Heaper} make.Rcvr: rcvr {Rcvr}
	(rcvr cast: SpecialistRcvr) registerIbid: theDsp.
	^theDsp! !IdentityDsp subclass: #RealDsp
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Filter'!

(RealDsp getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!RealDsp methodsFor: 'deferred accessing'!

{CoordinateSpace} coordinateSpace

	^RealSpace make! !

!RealDsp methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

RealDsp class
	instanceVariableNames: ''!

(RealDsp getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!RealDsp class methodsFor: 'creation'!

{Dsp} make
	
	^self create! !Dsp subclass: #IntegerMapping
	instanceVariableNames: 'myTranslation {IntegerVar}'
	classVariableNames: 'TheIdentityIntegerMapping {IntegerMapping star} '
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Integers'!
IntegerMapping comment:
'Transforms integers by adding a (possibly negative) offset.  In addition to the Dsp protocol, an IntegerDsp will respond to "translation" with the offset that it is adding.  
	
	Old documentation indicated a possibility of a future upgrade of IntegerDsp which would also optionally reflect (or negate) its input in addition to offsetting.  This would however be a non-upwards compatable change in that current clients already assume that the answer to "translation" fully describes the IntegerDsp.  If such a possibility is introduced, it should be as a super-type of IntegerDsp, since it would have a weaker contract.  Then compatability problems can be caught by the type checker.'!

(IntegerMapping getOrMakeCxxClassDescription)
	friends:
'/* friends for class IntegerDsp */
friend class IntegerSpace;
';
	attributes: ((Set new) add: #PSEUDO.COPY; add: #CONCRETE; add: #ON.CLIENT; yourself)!

!IntegerMapping methodsFor: 'unprotected for init creation'!

create: translation {IntegerVar}
	"Initialize instance variables"
	super create.
	myTranslation _ translation.! !

!IntegerMapping methodsFor: 'printing'!

{void} printOn: aStream {ostream reference}
	aStream << self getCategory name << '(' << myTranslation << ')'! !

!IntegerMapping methodsFor: 'transforming'!

{Position} inverseOf: pos {Position} 

	(pos ~~ NULL) assert.
	"shouldn't be necessary, but the old code used to check for NULL 
	so I want to make sure I haven't broken anything"
	self == TheIdentityIntegerMapping
		ifTrue: [^pos]
		ifFalse: [^((pos cast: IntegerPos) asIntegerVar - myTranslation) integer]!

{XnRegion} inverseOfAll: reg {XnRegion} 

	| region {IntegerRegion} result {IntegerEdgeAccumulator} edges {IntegerEdgeStepper} resultReg {XnRegion} |
	self == TheIdentityIntegerMapping
		ifTrue: [^reg]
		ifFalse: 
			[region _ reg cast: IntegerRegion.
			"Transform an interval by transforming the endpoints"
			result _ IntegerEdgeAccumulator make: region isBoundedBelow not with: region transitionCount.
			edges _ region edgeStepper.
			[edges hasValue]
				whileTrue: [result edge: (self inverseOfInt: edges edge).
					edges step].
			edges destroy.
			resultReg _ result region.
			result destroy.
			^ resultReg]!

{IntegerVar} inverseOfInt: pos {IntegerVar}

	self == TheIdentityIntegerMapping ifTrue: [^pos].
	^pos - myTranslation!

{Position} of: pos {Position} 

	(pos ~~ NULL) assert.
	"shouldn't be necessary, but the old code used to check for NULL 
	so I want to make sure I haven't broken anything"
	
	self == TheIdentityIntegerMapping
		ifTrue: [^pos]
		ifFalse: [^(myTranslation + (pos cast: IntegerPos) asIntegerVar) integer]!

{XnRegion} ofAll: reg {XnRegion} 

	| region {IntegerRegion} 
	  result {IntegerEdgeAccumulator} 
	  edges {IntegerEdgeStepper}
	  resultReg {XnRegion} |
	  
	self == TheIdentityIntegerMapping
		ifTrue: [^reg]
		ifFalse: 
			[region _ reg cast: IntegerRegion.
			"Transform an interval by transforming the endpoints"
			result _ IntegerEdgeAccumulator 
						make: region isBoundedBelow not 
						with: region transitionCount.
			edges _ region edgeStepper.
			[edges hasValue]
				whileTrue: [result edge: (self ofInt: edges edge).
					edges step].
			edges destroy.
			resultReg _ result region.
			result destroy.
			^ resultReg]!

{IntegerVar} ofInt: pos {IntegerVar}

	self == TheIdentityIntegerMapping ifTrue: [^pos].
	^ myTranslation + pos! !

!IntegerMapping methodsFor: 'accessing'!

{CoordinateSpace INLINE} coordinateSpace

	^ IntegerSpace make!

{BooleanVar INLINE} isIdentity
	^ myTranslation = IntegerVar0!

{IntegerVar CLIENT INLINE} translation
	"The offset which I add to a position.  
	If my translation is 7, then this->of(4) is 11."
	
	^myTranslation! !

!IntegerMapping methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^ (myTranslation) DOTasLong + #cat.U.IntegerMapping hashForEqual!

{BooleanVar} isEqual: other {Heaper}
	"Should have same offset and reversal"

	other
		cast: IntegerMapping into: [:iDsp |
			^iDsp translation = myTranslation]
		others: [^false].
	^ false "compiler fodder"! !

!IntegerMapping methodsFor: 'combining'!

{Dsp} compose: other {Dsp} 

	self == TheIdentityIntegerMapping
		ifTrue: [^ other]
		ifFalse: [other == TheIdentityIntegerMapping ifTrue: [^ self]].
	^IntegerMapping make: (myTranslation + (other quickCast: IntegerMapping) translation)!

{Mapping} inverse

	self == TheIdentityIntegerMapping ifTrue: [^self].
	^IntegerMapping make: myTranslation negated!

{Dsp} inverseCompose: other {Dsp}

	self == TheIdentityIntegerMapping
		ifTrue: [ ^ other ]
		ifFalse: [ ^ other minus: self ]!

{Dsp} minus: other {Dsp} 

	other == TheIdentityIntegerMapping
		ifTrue: [ ^self ]
		ifFalse: [ ^IntegerMapping make: (myTranslation - (other cast: IntegerMapping) translation)]! !

!IntegerMapping methodsFor: 'sender'!

{void SEND.HOOK} sendIntegerMapping: xmtr {Xmtr}
	xmtr sendIntegerVar: myTranslation.! !

!IntegerMapping methodsFor: 'generated:'!

{void} sendSelfTo: xmtr {Xmtr}
	
	self sendIntegerMapping: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

IntegerMapping class
	instanceVariableNames: ''!

(IntegerMapping getOrMakeCxxClassDescription)
	friends:
'/* friends for class IntegerDsp */
friend class IntegerSpace;
';
	attributes: ((Set new) add: #PSEUDO.COPY; add: #CONCRETE; add: #ON.CLIENT; yourself)!

!IntegerMapping class methodsFor: 'smalltalk: init'!

initTimeNonInherited
	TheIdentityIntegerMapping _ (IntegerMapping new.AllocType: #PERSISTENT) create: IntegerVar0!

linkTimeNonInherited
	TheIdentityIntegerMapping _ NULL! !

!IntegerMapping class methodsFor: 'pseudo constructors'!

make

	^IntegerSpace make identityDsp cast: IntegerMapping!

{Heaper} make.Rcvr: rcvr {Rcvr}
	| translate {IntegerVar} result {Heaper} |
	translate _ rcvr receiveIntegerVar.
	translate == IntegerVarZero
		ifTrue: [result _ TheIdentityIntegerMapping]
		ifFalse: [result _ self create: translate].
	(rcvr cast: SpecialistRcvr) registerIbid: result.
	^result!

make: translate {IntegerVar}

	translate == IntegerVar0
		ifTrue: [^self make]
		ifFalse: [^self create: translate]! !

!IntegerMapping class methodsFor: 'private: for create'!

{Dsp} identity

	^self create: IntegerVarZero! !

!IntegerMapping class methodsFor: 'smalltalk: system'!

info.stProtocol
"{IntegerVar CLIENT} translation
"! !Dsp subclass: #SequenceMapping
	instanceVariableNames: '
		myShift {IntegerVar}
		myTranslation {Sequence}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!
SequenceMapping comment:
'Transforms a Sequence by shifting some amount, and then adding another Sequence to it.'!

(SequenceMapping getOrMakeCxxClassDescription)
	friends:
'/* friends for class SequenceDsp */
friend class SequenceSpace;
';
	attributes: ((Set new) add: #CONCRETE; add: #ON.CLIENT; add: #COPY; yourself)!

!SequenceMapping methodsFor: 'accessing'!

{CoordinateSpace INLINE} coordinateSpace

	^SequenceSpace make!

{BooleanVar} isIdentity

	^myShift == IntegerVarZero and: [myTranslation isZero]!

{IntegerVar CLIENT INLINE} shift
	"The amount by which it shifts a sequence"
	
	^myShift!

{Sequence CLIENT INLINE} translation
	"What it adds to a sequence after shifting it"
	
	^myTranslation! !

!SequenceMapping methodsFor: 'transforming'!

{Position} inverseOf: position {Position}

	position cast: Sequence into: [ :sequence |
		^(sequence minus: myTranslation) shift: myShift negated].
	^ NULL "compiler fodder"!

{XnRegion} inverseOfAll: reg {XnRegion}

	Ravi thingToDo. "make this more efficient"
	^self inverse ofAll: reg!

{Position} of: position {Position}

	position cast: Sequence into: [ :sequence |
		^(sequence shift: myShift) plus: myTranslation].
	^ NULL "compiler fodder"!

{XnRegion} ofAll: reg {XnRegion}

	reg cast: SequenceRegion into: [ :seq |
		| edges {PtrArray of: SequenceEdge} newEdges {PtrArray of: SequenceEdge} |
		edges := seq secretTransitions.
		newEdges := PtrArray nulls: edges count.
		Int32Zero almostTo: edges count do: [ :i {Int32} |
			newEdges at: i store: (((edges fetch: i) cast: SequenceEdge) transformedBy: self)].
		^SequenceRegion usingx: seq startsInside with: newEdges].
	^NULL "fodder"! !

!SequenceMapping methodsFor: 'combining'!

{Dsp} compose: dsp {Dsp}
	"Return the composition of the two Dsps. Two Dsps of the same space are always composable.
	(a->compose(b) ->minus(b))->isEqual (a)
	(a->compose(b) ->of(pos))->isEqual (a->of (b->of (pos))"

	dsp cast: SequenceMapping into: [ :other {SequenceMapping} |
		^SequenceMapping make: myShift + other shift
			with: ((self of: other translation) cast: Sequence)].
	^ NULL "compiler fodder"!

{Mapping} inverse

	^SequenceMapping make: myShift negated
		with: ((Sequence zero minus: myTranslation) shift: myShift)!

{Dsp} inverseCompose: dsp {Dsp}

	dsp cast: SequenceMapping into: [ :other |
		^SequenceMapping make: myShift - other shift
			with: ((self inverseOf: other translation) cast: Sequence)].
	^ NULL "compiler fodder"!

{Dsp} minus: dsp {Dsp}

	dsp cast: SequenceMapping into: [ :other |
		^SequenceMapping make: myShift - other shift
			with: ((self inverseOf: other translation) cast: Sequence)].
	^ NULL "compiler fodder"! !

!SequenceMapping methodsFor: 'private: create'!

create: shift {IntegerVar} with: translation {Sequence}

	super create.
	myShift := shift.
	myTranslation := translation.! !

!SequenceMapping methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myShift _ receiver receiveIntegerVar.
	myTranslation _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendIntegerVar: myShift.
	xmtr sendHeaper: myTranslation.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SequenceMapping class
	instanceVariableNames: ''!

(SequenceMapping getOrMakeCxxClassDescription)
	friends:
'/* friends for class SequenceDsp */
friend class SequenceSpace;
';
	attributes: ((Set new) add: #CONCRETE; add: #ON.CLIENT; add: #COPY; yourself)!

!SequenceMapping class methodsFor: 'private: pseudo constructors'!

make: shift {IntegerVar} with: translation {Sequence}

	^self create: shift with: translation! !

!SequenceMapping class methodsFor: 'smalltalk: system'!

info.stProtocol
"{IntegerVar CLIENT} shift
{Sequence CLIENT} translation
"! !Mapping subclass: #EmptyMapping
	instanceVariableNames: '
		myCS {CoordinateSpace}
		myRS {CoordinateSpace}'
	classVariableNames: '
		LastEmptyMapping {Mapping} 
		LastEmptyMappingCoordinateSpace {CoordinateSpace} 
		LastEmptyMappingRangeSpace {CoordinateSpace} '
	poolDictionaries: ''
	category: 'Xanadu-Spaces'!

(EmptyMapping getOrMakeCxxClassDescription)
	friends:
'/* friends for class EmptyMapping */
friend SPTR(Mapping) emptyMapping (CoordinateSpace * cs, CoordinateSpace * rs);
';
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!EmptyMapping methodsFor: 'accessing'!

{CoordinateSpace} coordinateSpace

	^myCS!

{XnRegion} domain

	^ self coordinateSpace emptyRegion.!

{Dsp | NULL} fetchDsp
	^NULL!

{BooleanVar} isComplete

	^true!

{BooleanVar} isIdentity

	^false!

{XnRegion} range
	^ self rangeSpace emptyRegion.!

{CoordinateSpace} rangeSpace

	^myRS!

{ImmuSet of: Mapping} simpleMappings

	^ ImmuSet make!

{ImmuSet of: Mapping} simpleRegionMappings

	^ ImmuSet make with: self.! !

!EmptyMapping methodsFor: 'transforming'!

{Position} inverseOf: pos {Position unused}

	Heaper BLAST: #NotInRange.
	^ NULL!

{XnRegion} inverseOfAll: reg {XnRegion unused}

	^ self coordinateSpace emptyRegion.!

{Position} of: pos {Position unused}

	Heaper BLAST: #NotInDomain.
	^ NULL!

{XnRegion} ofAll: reg {XnRegion unused}

	^self rangeSpace emptyRegion.! !

!EmptyMapping methodsFor: 'private: private creation'!

create: cs {CoordinateSpace} with: rs {CoordinateSpace}
	super create.
	myCS _ cs.
	myRS _ rs.! !

!EmptyMapping methodsFor: 'printing'!

{void} printOn: stream {ostream reference}

	stream << self getCategory name.
	stream << '()'! !

!EmptyMapping methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^#cat.U.EmptyMapping hashForEqual!

{BooleanVar} isEqual: other {Heaper}
	"This, and the CompositeMapping version, don't check CoordinateSpaces.  Should they?"
	^(other isKindOf: EmptyMapping)! !

!EmptyMapping methodsFor: 'operations'!

{Mapping} appliedAfter: dsp {Dsp unused}

	^self!

{Mapping} inverse

	^Mapping make.CoordinateSpace: self rangeSpace
		with.CoordinateSpace: self domainSpace!

{Mapping} preCompose: dsp {Dsp unused}

	^ self!

{Mapping} restrict: region {XnRegion unused}

	^self!

{Mapping} restrictRange: region {XnRegion unused}

	^self!

{Mapping} transformedBy: dsp {Dsp unused}

	^ self! !

!EmptyMapping methodsFor: 'protected: protected'!

{Mapping} fetchCombine: mapping {Mapping}

	^ mapping! !

!EmptyMapping methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myCS _ receiver receiveHeaper.
	myRS _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myCS.
	xmtr sendHeaper: myRS.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

EmptyMapping class
	instanceVariableNames: ''!

(EmptyMapping getOrMakeCxxClassDescription)
	friends:
'/* friends for class EmptyMapping */
friend SPTR(Mapping) emptyMapping (CoordinateSpace * cs, CoordinateSpace * rs);
';
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!EmptyMapping class methodsFor: 'smalltalk: initialization'!

linkTimeNonInherited
	LastEmptyMapping _ NULL.
	LastEmptyMappingCoordinateSpace _ NULL.
	LastEmptyMappingRangeSpace _ NULL.! !

!EmptyMapping class methodsFor: 'pseudoconstructor'!

{Mapping} make: cs {CoordinateSpace} with: rs {CoordinateSpace}
	(LastEmptyMapping == NULL
	 or: [(cs isEqual: LastEmptyMappingCoordinateSpace) not
	 or: [(rs isEqual: LastEmptyMappingRangeSpace) not]])
		ifTrue:
			[LastEmptyMappingCoordinateSpace _ cs.
			LastEmptyMappingRangeSpace _ rs.
			LastEmptyMapping _ EmptyMapping create: cs with: rs].
	^ LastEmptyMapping! !Mapping subclass: #SimpleMapping
	instanceVariableNames: '
		myRegion {XnRegion}
		myMapping {Mapping}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Basic'!

(SimpleMapping getOrMakeCxxClassDescription)
	friends:
'/* friends for class SimpleMapping */
friend SPTR(Mapping) restrictTo (XnRegion*, Mapping*);
';
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!SimpleMapping methodsFor: 'accessing'!

{Mapping} appliedAfter: dsp {Dsp}

	^SimpleMapping restrictTo: (dsp inverseOfAll: myRegion)
		with: (myMapping appliedAfter: dsp)!

{CoordinateSpace} coordinateSpace

	^myRegion coordinateSpace!

{XnRegion} domain
	^ myRegion!

{Dsp | NULL} fetchDsp
	^ myMapping fetchDsp!

{BooleanVar} isComplete

	^myMapping isComplete!

{BooleanVar} isIdentity

	^false!

{Mapping} preCompose: dsp {Dsp}

	^SimpleMapping restrictTo: myRegion with: (myMapping preCompose: dsp)!

{XnRegion} range
	^ myMapping ofAll: myRegion!

{CoordinateSpace} rangeSpace
	
	^ myMapping rangeSpace!

{ImmuSet of: Mapping} simpleMappings

	^ ImmuSet make with: self!

{ImmuSet of: Mapping} simpleRegionMappings

	myMapping domain isSimple 
		ifTrue:
			[^ImmuSet make with: myMapping]
		ifFalse:
			[ | simpleMappings {MuSet} | 
			simpleMappings _ MuSet make.
			myMapping domain simpleRegions forEach: [:simpleRegion {XnRegion} |
				simpleMappings store: (myMapping restrict: simpleRegion)].
			^ImmuSet make.MuSet: simpleMappings]!

{Mapping} transformedBy: dsp {Dsp}

	^SimpleMapping restrictTo: myRegion
		with: (myMapping transformedBy: dsp)! !

!SimpleMapping methodsFor: 'transforming'!

{Position} inverseOf: pos {Position}

	| result {Position} |
	result _ myMapping inverseOf: pos.
	(myRegion hasMember: result)
		ifTrue: [^result]
		ifFalse: [Heaper BLAST: #NotInRange].
	^NULL "fodder"!

{XnRegion} inverseOfAll: reg {XnRegion}

	^(myMapping inverseOfAll: reg) intersect: myRegion!

{Position} of: pos {Position}

	(self domain hasMember: pos)
		ifTrue: [^ myMapping of: pos]
		ifFalse: [Heaper BLAST: #NotInDomain].
	^NULL "fodder"!

{XnRegion} ofAll: reg {XnRegion}

	^myMapping ofAll: (self domain intersect: reg)! !

!SimpleMapping methodsFor: 'operations'!

{Mapping} inverse

	^myMapping inverse restrictRange: myRegion!

{Mapping} restrict: region {XnRegion}
	
	^SimpleMapping restrictTo: (myRegion intersect: region) with: myMapping!

{Mapping} restrictRange: region {XnRegion}
	
	^SimpleMapping restrictTo: myRegion with: (myMapping restrictRange: region)! !

!SimpleMapping methodsFor: 'printing'!

{void} printOn: oo {ostream reference}

	oo << myMapping << ' on ' << myRegion! !

!SimpleMapping methodsFor: 'private: private creation'!

create: region {XnRegion} with: mapping {Mapping}
	super create.
	myRegion _ region.
	myMapping _ mapping.! !

!SimpleMapping methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^myRegion hashForEqual + myMapping hashForEqual!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: SimpleMapping into: [:sm |
			^(sm domain isEqual: myRegion)
			 and: [sm mapping isEqual: myMapping]]
		others: [^false].
	^false "fodder"! !

!SimpleMapping methodsFor: 'private: private'!

{Mapping} mapping
	^myMapping! !

!SimpleMapping methodsFor: 'protected'!

{Mapping} fetchCombine: mapping {Mapping}

	(mapping isEqual: myMapping) ifTrue: [^mapping].
	mapping
		cast: SimpleMapping into: [:other |
			| both {Mapping} |
			(other mapping isEqual: myMapping) ifTrue:
				[^SimpleMapping restrictTo: (other domain unionWith: myRegion) with: myMapping]
			ifFalse: [((other domain isEqual: myRegion)
					and: [(both _ myMapping fetchCombine: other mapping) ~~ NULL]) ifTrue:
				[^SimpleMapping restrictTo: myRegion with: both]]]
		others: [].
	^NULL! !

!SimpleMapping methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myRegion _ receiver receiveHeaper.
	myMapping _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myRegion.
	xmtr sendHeaper: myMapping.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SimpleMapping class
	instanceVariableNames: ''!

(SimpleMapping getOrMakeCxxClassDescription)
	friends:
'/* friends for class SimpleMapping */
friend SPTR(Mapping) restrictTo (XnRegion*, Mapping*);
';
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!SimpleMapping class methodsFor: 'pseudo constructors'!

{Mapping} restrictTo: region {XnRegion} with: mapping {Mapping}
	region isEmpty
		ifTrue: [^EmptyMapping make: mapping domainSpace
								 with: mapping rangeSpace]
		ifFalse: [^SimpleMapping create: region with: mapping]! !Stepper subclass: #MergeStepper
	instanceVariableNames: '
		myA {Stepper of: Position}
		myB {Stepper of: Position}
		myOrder {OrderSpec}
		myValue {Position | NULL}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Cross'!
MergeStepper comment:
'A Stepper for doing a merge-sort like ordered interleaving of two other steppers.  It is assumed that the other two steppers are constructed so that their values are also produced in order according to the same OrderSpec.  A tree of these operates much like a heap as found in heapsort.'!

(MergeStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!MergeStepper methodsFor: 'operations'!

{Stepper} copy

	myValue == NULL ifTrue:
		[^Stepper emptyStepper].
	^MergeStepper
		create: myA copy
		with: myB copy
		with: myOrder
		with: myValue!

{Heaper wimpy} fetch
	
	^myValue!

{BooleanVar} hasValue
	
	^myValue ~~ NULL!

{void} step
	
	| a {Position} b {Position} |
	a := myA fetch cast: Position.
	b := myB fetch cast: Position.
	a == NULL ifTrue:
		[b == NULL ifTrue:
			[myValue := NULL]
		ifFalse:
			[myValue := b.
			myB step]]
	ifFalse:
		[b == NULL ifTrue:
			[myValue := a.
			myA step]
		ifFalse:
			[(myOrder follows: a with: b) ifTrue:
				[myValue := b.
				myB step.
				(a isEqual: b) ifTrue:
					[myA step]]
			ifFalse:
				[myValue := a.
				myA step.
				(a isEqual: b) ifTrue:
					[myB step]]]]! !

!MergeStepper methodsFor: 'private: creation'!

create: a {Stepper of: Position} 
	with: b {Stepper of: Position} 
	with: order {OrderSpec} 
	with: value {Position | NULL}
	
	super create.
	myA := a.
	myB := b.
	myOrder := order.
	myValue := value.
	value == NULL ifTrue:
		[self step]! !

!MergeStepper methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myA _ receiver receiveHeaper.
	myB _ receiver receiveHeaper.
	myOrder _ receiver receiveHeaper.
	myValue _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myA.
	xmtr sendHeaper: myB.
	xmtr sendHeaper: myOrder.
	xmtr sendHeaper: myValue.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

MergeStepper class
	instanceVariableNames: ''!

(MergeStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!MergeStepper class methodsFor: 'pseudoconstructors'!

{Stepper} make: a {Stepper of: Position} 
	with: b {Stepper of: Position} 
	with: order {OrderSpec}
	
	^self create: a with: b with: order with: NULL! !Heaper subclass: #OrderSpec
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Basic'!
OrderSpec comment:
'[documentation note: we need to hide the documentation about partial orders, but still warn that the orders may become partial]. An OrderSpec for a given coordinate space represents a partial ordering of all the Positions of that coordinate space.  The fundamental ordering relationship is "follows".  The response of Positions to isGE defines the natural, "ascending" partial order among the positions.  Every coordinate space will have at least this ascending and the corresponding descending OrderSpecs.  OrderSpecs are useful to specify in what order a stepper produced for stepping over positions should do so.'!

(OrderSpec getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; add: #COPY; yourself)!

!OrderSpec methodsFor: 'smalltalk: defaults'!

isFullOrder

	^self isFullOrder: NULL! !

!OrderSpec methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^Heaper takeOop!

{OrderEnum} compare: x {Position} with: y {Position}
	"Say what the relative ordering relationship is between x and y"

	(self follows: x with: y)
		ifTrue: [(self follows: y with: x) ifTrue: [^#EQUAL] ifFalse: [^#GREATER.U.THAN]]
		ifFalse: [(self follows: y with: x) ifTrue: [^#LESS.U.THAN] ifFalse: [^#INCOMPARABLE]]!

{BooleanVar CLIENT} follows: x {Position} with: y {Position}
	"Essential.  Compare the two and return true if x is known to follow y in the ordering.  This message is the 'greater than or equal to' equivalent for this ordering.  It must have those properties a mathematician would demand of a '>=' on a partial order:
		os->follows(a, a)   (reflexivity)
		os->follows(a, b) && os->follows(b, c) implies os->follows(a, c)  (transitivity)
		os->follows(a, b) && os->follows(b, a) implies a->isEqual(b)  (what's the name for this?)"

	self subclassResponsibility!

{BooleanVar} followsInt: x {IntegerVar} with: y {IntegerVar}
	"See discussion in XuInteger class comment about boxed vs unboxed integers"

	^self follows: x integer with: y integer!

{BooleanVar} isEqual: other {Heaper}

	self subclassResponsibility!

{BooleanVar} isFullOrder: keys {XnRegion default: NULL}
	"Essential.  If this returns TRUE, then I define a full order over all positions in 'keys' (or all positions in the space if 'keys' is NULL).  However, if I return FALSE, that doesn't guarantee that I don't define a full ordering.  I may happen to define a full ordering without knowing it.
	
	A full ordering is one in which for each a, b in keys; either this->follows(a, b) or this->follows(b, a)."
	
	self subclassResponsibility!

{BooleanVar} preceeds: before {XnRegion} with: after {XnRegion}
	"Return true if some position in before is less than or equal to all positions in after."
	
	self subclassResponsibility! !

!OrderSpec methodsFor: 'accessing'!

{Arrangement} arrange: region {XnRegion}
	"Return an Arrangement of the positions in region according to the ordering of the receiver."
	
	^ExplicitArrangement make: ((region stepper: self) stepMany cast: PtrArray)!

{CoordinateSpace CLIENT} coordinateSpace
	"Essential.  Like Positions, Dsps, and XuRegions, an OrderSpec is specific to one coordinate space.  It is an error to use the generic protocol on objects from different coordinate spaces."

	self subclassResponsibility!

{OrderSpec CLIENT} reversed
	"Returns an OrderSpec representing the mirror image of my ordering.
	o->follows(a, b) iff o->reverse()->follows(b, a)"
	
	^ReverseOrder make: self! !

!OrderSpec methodsFor: 'smalltalk: passe'!

{PrimArray} export

	self passe! !

!OrderSpec methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

OrderSpec class
	instanceVariableNames: ''!

(OrderSpec getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; add: #COPY; yourself)!

!OrderSpec class methodsFor: 'smalltalk: passe'!

{OrderSpec} ascending: cs {CoordinateSpace} 
	"Use CoordinateSpace::fetch/getAscending"

	self passe!

{OrderSpec} descending: cs {CoordinateSpace}
	"Use CoordinateSpace::fetch/getDescending"
	
	self passe! !

!OrderSpec class methodsFor: 'smalltalk: system'!

info.stProtocol
"{CoordinateSpace CLIENT} coordinateSpace
{BooleanVar CLIENT} follows: x {Position} with: y {Position}
{OrderSpec CLIENT} reversed
"! !OrderSpec subclass: #CrossOrderSpec
	instanceVariableNames: '
		mySpace {CrossSpace}
		mySubOrders {PtrArray of: OrderSpec}
		myLexOrder {PrimIntArray}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-cross'!
CrossOrderSpec comment:
'myLexOrder lists the lexicographic order in which each dimension should be processed.  Every dimension should be listed exactly one, from most significant (at index 0) to least significant.

mySubOrders are indexed by *dimension*, not by lexicographic order.  In order to index by lex order, look up the dimension in myLexOrder, and then look up the resulting dimension number in mySubOrders.'!

(CrossOrderSpec getOrMakeCxxClassDescription)
	friends:
'friend class GenericCrossSpace;
';
	attributes: ((Set new) add: #CONCRETE; add: #ON.CLIENT; add: #COPY; yourself)!

!CrossOrderSpec methodsFor: 'private: creation'!

create: space {CrossSpace} with: subOrders {PtrArray of: OrderSpec} with: lexOrder {PrimIntArray}

	super create.
	mySpace := space.
	mySubOrders := subOrders.
	myLexOrder := lexOrder! !

!CrossOrderSpec methodsFor: 'accessing'!

{CoordinateSpace INLINE} coordinateSpace
	
	^mySpace!

{PrimIntArray CLIENT} lexOrder
	"Lists the lexicographic order in which each dimension should be processed.  Every dimension is listed exactly once, from most significant (at index 0) to least significant."

	^myLexOrder copy cast: PrimIntArray!

{OrderSpec CLIENT} subOrder: i {Int32}
	"The sub OrderSpec used for the given axis. Note that this is *not* in lex order."
	
	^(mySubOrders fetch: i) cast: OrderSpec!

{PtrArray CLIENT of: OrderSpec} subOrders
	"The sub OrderSpec used for each axis in the space. Note that this is *not* in lex order, but rather indexed by axis number."
	
	^mySubOrders copy cast: PtrArray! !

!CrossOrderSpec methodsFor: 'testing'!

{UInt32} actualHashForEqual

	
	^mySpace hashForEqual bitXor: (mySubOrders hashForEqual  bitXor: myLexOrder hashForEqual ).!

{BooleanVar} follows: x {Position unused} with: y {Position unused}
	
	MarkM shouldImplement.
	^false "fodder"!

{BooleanVar} isEqual: other {Heaper unused}

	Someone shouldImplement.
	^false "fodder"!

{BooleanVar} isFullOrder: keys {XnRegion unused default: NULL}
	"Essential.  If this returns TRUE, then I define a full order over all positions in 'keys' (or all positions in the space if 'keys' is NULL).  However, if I return FALSE, that doesn't guarantee that I don't define a full ordering.  I may happen to define a full ordering without knowing it.
	
	A full ordering is one in which for each a, b in keys; either this->follows(a, b) or this->follows(b, a)."
	^false. "any 2 d or greater space has no fullordering"
	"Someone shouldImplement."
	"fodder"!

{BooleanVar} preceeds: before {XnRegion} with: after {XnRegion}
	"Return true if some position in before is less than or equal to all positions in after."
	
	before cast: GenericCrossRegion into: [ :bc |
	after cast: GenericCrossRegion into: [ :ac |
			Int32Zero almostTo: myLexOrder count do: [ :i {Int32} |
				| dim {Int32} sub {OrderSpec} |
				dim := (myLexOrder integerAt: i) DOTasLong.
				sub := (mySubOrders get: dim) cast: OrderSpec.
				Int32Zero almostTo: bc boxCount do: [ :bi {Int32} | | bp {XnRegion} |
					bp := bc boxProjection: bi with: dim.
					Int32Zero almostTo: ac boxCount do: [ :ai {Int32} | | ap {XnRegion} |
					ap := ac boxProjection: ai with: dim.
					(sub preceeds: bp with: ap) ifTrue: [^true]]]].
				^false]
	others: [self unimplemented]]
	others: [self unimplemented].
	^false "fodder"! !

!CrossOrderSpec methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	mySpace _ receiver receiveHeaper.
	mySubOrders _ receiver receiveHeaper.
	myLexOrder _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: mySpace.
	xmtr sendHeaper: mySubOrders.
	xmtr sendHeaper: myLexOrder.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

CrossOrderSpec class
	instanceVariableNames: ''!

(CrossOrderSpec getOrMakeCxxClassDescription)
	friends:
'friend class GenericCrossSpace;
';
	attributes: ((Set new) add: #CONCRETE; add: #ON.CLIENT; add: #COPY; yourself)!

!CrossOrderSpec class methodsFor: 'pseudoconstructors'!

make: space {CrossSpace} 
	with: subOrderings {(PtrArray of: OrderSpec | NULL) default: NULL} 
	with: lexOrder {PrimIntArray default: NULL}

	| lexO {PrimIntArray} 
	  subOrders {PtrArray of: OrderSpec} |
	  
	subOrders := PtrArray nulls: space axisCount.
	Int32Zero almostTo: subOrders count do: [:i {Int32} |
		subOrders at: i store: (space axis: i) fetchAscending].
	
	subOrderings ~~ NULL ifTrue:
		[Int32Zero almostTo: subOrders count do: [:i {Int32} |
			| subOrder {OrderSpec | NULL} |
			subOrder := (subOrderings fetch: i) cast: OrderSpec.
			subOrder == NULL ifTrue:
				[(subOrders fetch: i) ~~ NULL assert: 'Must have an ordering from each space']
			ifFalse:
				[subOrders at: i store: subOrder]]].
	
	lexOrder == NULL ifTrue:
		[lexO := PrimIntArray zeros: 32 with: subOrders count.
		Int32Zero almostTo: subOrders count do: [:i {Int32} |
			lexO at: i storeInteger: i]]
	ifFalse:
		[lexO := lexOrder].
	^self create: space with: subOrders with: lexO! !

!CrossOrderSpec class methodsFor: 'smalltalk: defaults'!

make: space
	
	^self make space with: NULL with: NULL!

make: space with: subOrderings
	
	^self make space with: subOrderings with: NULL! !

!CrossOrderSpec class methodsFor: 'private: pseudo constructors'!

{CrossOrderSpec} fetchAscending: space {GenericCrossSpace}
	with: subSpaces {PtrArray of: CoordinateSpace}
	"Only used during construction; must pass the array in explicitly since the space isnt initialized yet"
	
	| result {PtrArray of: OrderSpec} lex {PrimIntArray} |
	result := PtrArray nulls: subSpaces count.
	lex := PrimIntArray zeros: 32 with: subSpaces count.
	Int32Zero almostTo: result count do: [ :dimension {Int32} | | sub {OrderSpec} |
		sub := ((subSpaces fetch: dimension) cast: CoordinateSpace) fetchAscending.
		sub == NULL ifTrue:
			[^NULL].
		result at: dimension store: sub.
		lex at: dimension storeInteger: dimension].
	^self create: space with: result with: lex!

{CrossOrderSpec} fetchDescending: space {GenericCrossSpace}
	with: subSpaces {PtrArray of: CoordinateSpace}
	"Only used during construction; must pass the array in explicitly since the space isnt initialized yet"
	
	| result {PtrArray of: OrderSpec} lex {PrimIntArray} |
	result := PtrArray nulls: subSpaces count.
	lex := PrimIntArray zeros: 32 with: subSpaces count.
	Int32Zero almostTo: result count do: [ :dimension {Int32} | | sub {OrderSpec} |
		sub := ((subSpaces fetch: dimension) cast: CoordinateSpace) fetchAscending.
		sub == NULL ifTrue:
			[^NULL].
		result at: dimension store: sub.
		lex at: dimension storeInteger: dimension].
	^self create: space with: result with: lex! !

!CrossOrderSpec class methodsFor: 'smalltalk: system'!

info.stProtocol
"{Int32Array CLIENT} lexOrder
{OrderSpec CLIENT} subOrder: i {Int32}
{PtrArray CLIENT of: OrderSpec} subOrders
"! !OrderSpec subclass: #IntegerUpOrder
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Basic'!

(IntegerUpOrder getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!IntegerUpOrder methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^#cat.U.IntegerUpOrder hashForEqual + 1!

{BooleanVar} follows: x {Position} with: y {Position}

	^(x cast: IntegerPos) asIntegerVar >= (y cast: IntegerPos) asIntegerVar!

{BooleanVar} followsInt: x {IntegerVar} with: y {IntegerVar}
	"See discussion in XuInteger class comment about boxed vs unboxed integers"

	^ x >= y!

{BooleanVar} isEqual: other {Heaper}

	^other isKindOf: IntegerUpOrder!

{BooleanVar} isFullOrder: keys {XnRegion unused default: NULL}
	
	^true!

{BooleanVar} preceeds: before {XnRegion} with: after {XnRegion}
	"Return true if some position in before is less than or equal to all positions in after."
	
	| first {IntegerRegion} second {IntegerRegion} |
	first _ before cast: IntegerRegion.
	second _ after cast: IntegerRegion.
	first isBoundedBelow ifFalse: [^true].
	second isBoundedBelow ifFalse: [^false].
	^first start <= second start! !

!IntegerUpOrder methodsFor: 'accessing'!

{Arrangement} arrange: region {XnRegion}
	^IntegerArrangement make: region with: self.!

{XnRegion} chooseMany: region {XnRegion} with: n {IntegerVar}
	"Return the first n positions in the region according to my ordering."
	
	^(self arrange: region) keysOf: Int32Zero with: n DOTasLong!

{Position} chooseOne: region {XnRegion}
	"Return the first position in the region according to my ordering."
	
	^IntegerPos make: (region cast: IntegerRegion) start!

{CoordinateSpace} coordinateSpace
	
	^IntegerSpace make! !

!IntegerUpOrder methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

IntegerUpOrder class
	instanceVariableNames: ''!

(IntegerUpOrder getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!IntegerUpOrder class methodsFor: 'pseudoconstructors'!

{OrderSpec} make

	^self create! !OrderSpec subclass: #RealUpOrder
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!

(RealUpOrder getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!RealUpOrder methodsFor: 'accessing'!

{Arrangement} arrange: region {XnRegion}

	| stepper {Stepper} array {PtrArray} |
	region isFinite ifFalse: [Heaper BLAST: #MustBeFinite].
	stepper := (region cast: RealRegion) stepper.
	array := stepper stepMany cast: PtrArray.
	stepper atEnd ifFalse: [self unimplemented].
	^ExplicitArrangement make: array!

{CoordinateSpace} coordinateSpace
	
	^RealSpace make! !

!RealUpOrder methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^#cat.U.RealUpOrder hashForEqual + 1!

{BooleanVar} follows: x {Position} with: y {Position}
	
	MarkM thingToDo. "128 bit values"
	^(x cast: RealPos) asIEEE64 >= (y cast: RealPos) asIEEE64!

{BooleanVar} isEqual: other {Heaper}

	^other isKindOf: RealUpOrder!

{BooleanVar} isFullOrder: keys {XnRegion default: NULL}
	
	^true!

{BooleanVar} preceeds: before {XnRegion} with: after {XnRegion}

	before cast: RealRegion into: [ :br |
		br isBoundedBelow ifFalse:
			[^true].
		after cast: RealRegion into: [ :ar |
			^ar isBoundedBelow not
				and: [self follows: ar lowerBound with: br lowerBound]]].
	^false "fodder"! !

!RealUpOrder methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

RealUpOrder class
	instanceVariableNames: ''!

(RealUpOrder getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!RealUpOrder class methodsFor: 'creation'!

{OrderSpec} make

	^self create! !OrderSpec subclass: #ReverseOrder
	instanceVariableNames: 'myOrder {OrderSpec}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Basic'!

(ReverseOrder getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!ReverseOrder methodsFor: 'accessing'!

{CoordinateSpace} coordinateSpace
	
	^myOrder coordinateSpace!

{OrderSpec} reversed
	
	^myOrder! !

!ReverseOrder methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^myOrder hashForEqual bitXor: -1!

{BooleanVar} follows: x {Position} with: y {Position}
	
	^myOrder follows: y with: x!

{BooleanVar} followsInt: x {IntegerVar} with: y {IntegerVar}

	^myOrder followsInt: y with: x!

{BooleanVar} isEqual: other{Heaper}

	other cast: OrderSpec into: [:os |
			^myOrder isEqual: os reversed]
		others: [^false].
	^false "fodder"!

{BooleanVar} isFullOrder: keys {XnRegion default: NULL}

	^myOrder isFullOrder: keys!

{BooleanVar} preceeds: before {XnRegion} with: after {XnRegion}
	"Return true if some position in before is less than or equal to all positions in after."
	
	self unimplemented.
	^false! !

!ReverseOrder methodsFor: 'private: creation'!

create: order {OrderSpec}

	super create.
	myOrder := order! !

!ReverseOrder methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myOrder _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myOrder.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ReverseOrder class
	instanceVariableNames: ''!

(ReverseOrder getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!ReverseOrder class methodsFor: 'pseudoconstructors'!

{OrderSpec} make: order {OrderSpec}

	^self create: order! !OrderSpec subclass: #SequenceUpOrder
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!

(SequenceUpOrder getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!SequenceUpOrder methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^self getCategory hashForEqual!

{BooleanVar} follows: x {Position} with: y {Position}

	^((x cast: Sequence) secretNumbers
		compare: (y cast: Sequence) secretNumbers) >= Int32Zero!

{BooleanVar} isEqual: other {Heaper}

	^other isKindOf: SequenceUpOrder!

{BooleanVar} isFullOrder: keys {XnRegion unused default: NULL}

	^true!

{BooleanVar} preceeds: before {XnRegion} with: after {XnRegion}
	
	| first {SequenceRegion} second {SequenceRegion} |
	first _ before cast: SequenceRegion.
	second _ after cast: SequenceRegion.
	first isBoundedBelow ifFalse: [^true].
	second isBoundedBelow ifFalse: [^false].
	^(((first secretTransitions fetch: Int32Zero) cast: SequenceEdge)
		isGE: ((second secretTransitions fetch: Int32Zero) cast: SequenceEdge)) not! !

!SequenceUpOrder methodsFor: 'accessing'!

{Arrangement} arrange: region {XnRegion}

	| stepper {Stepper} array {PtrArray} |
	region isFinite ifFalse: [Heaper BLAST: #MustBeFinite].
	stepper := (region cast: SequenceRegion) stepper.
	array := stepper stepMany cast: PtrArray.
	stepper atEnd ifFalse: [self unimplemented].
	^ExplicitArrangement make: array!

{CoordinateSpace} coordinateSpace

	^SequenceSpace make! !

!SequenceUpOrder methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SequenceUpOrder class
	instanceVariableNames: ''!

(SequenceUpOrder getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!SequenceUpOrder class methodsFor: 'pseudo constructors'!

{OrderSpec} make

	^self create! !Heaper subclass: #Position
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Basic'!
Position comment:
'This is the superclass of all positions of coordinate spaces.  Each individual position is specific to some one coordinate space.  Positions themselves don''t have much behavior, as most of the interesting aspects of coordinate spaces are defined in the other objects in terms of positions.  Positions do have their own native ordering messages, but for most purposes it''s probably better to compare them using an appropriate OrderSpec.'!

(Position getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; yourself)!

!Position methodsFor: 'testing'!

{UInt32} actualHashForEqual
	"since we redefine equal, subclasses had better redefine actualHashForEqual"

	^Heaper takeOop!

{BooleanVar} isEqual: other {Heaper} 

	self subclassResponsibility! !

!Position methodsFor: 'accessing'!

{XnRegion CLIENT} asRegion
	"Essential.  A region containing this position as its only element."
	self subclassResponsibility!

{CoordinateSpace CLIENT} coordinateSpace
	"Essential.  The coordinate space this is a position in. This implies that a position object is only a position in one particular coordinate space."

	self subclassResponsibility! !

!Position methodsFor: 'smalltalk: passe'!

{BooleanVar} isAfterOrEqual: other {Position}
	"OBSOLETE. Use OrderSpec instead, or non-polymorphic subclass methods.
	This must define a full ordering on all positions in the same coordinate space.
	As this isn''t possible for some coordinate spaces (e.g. HeaperSpace & FilterSpace), we may BLAST instead.  Therefore this message should eventually get retired -- don't use.
	See OrderSpec::follows for the properties a partial order must satisfy.  A full ordering must additionally satisfy: for all a, b; either a->isAfterOrEqual(b) or b->isAfterOrEqual(a)."

	self passe!

{BooleanVar} isGE: other {Position}
	"OBSOLETE. Use the OrderSpec, or non-polymorphic subclass methods.
	Defines a transitive partial order; return false if incompatible.  See OrderSpec::follows for the properties a partial order must satisfy.  The ordering according to isGE is the same as the ascending OrderSpec for this coordinate space.  It is probably better to use the OrderSpec than this message."

	self passe! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Position class
	instanceVariableNames: ''!

(Position getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; yourself)!

!Position class methodsFor: 'smalltalk: system'!

info.stProtocol
"{XuRegion CLIENT} asRegion
{CoordinateSpace CLIENT} coordinateSpace
"! !Position subclass: #FilterPosition
	instanceVariableNames: 'myRegion {XnRegion}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-filter'!
FilterPosition comment:
'Encapsulates a Region in the baseSpace into a Position so that it can be treated as one for polymorphism. See Filter.'!

(FilterPosition getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #ON.CLIENT; add: #COPY; yourself)!

!FilterPosition methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^myRegion hashForEqual + 1!

{BooleanVar} isEqual: other {Heaper} 

	other 
		cast: FilterPosition into: [:rap |
			^rap baseRegion isEqual: myRegion]
		others: [^false].
	^false "fodder"! !

!FilterPosition methodsFor: 'accessing'!

{XnRegion} asRegion

	^(Filter subsetFilter: self coordinateSpace
			with: myRegion)
		intersect: (Filter supersetFilter: self coordinateSpace
			with: myRegion)!

{XnRegion CLIENT INLINE} baseRegion
	"Essential. The region in the base space which I represent."
	
	^myRegion!

{CoordinateSpace} coordinateSpace
	^FilterSpace make: myRegion coordinateSpace! !

!FilterPosition methodsFor: 'instance creation'!

create: region {XnRegion}
	super create.
	myRegion _ region.! !

!FilterPosition methodsFor: 'smalltalk: passe'!

{XnRegion} region

	self passe! !

!FilterPosition methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myRegion _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myRegion.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

FilterPosition class
	instanceVariableNames: ''!

(FilterPosition getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #ON.CLIENT; add: #COPY; yourself)!

!FilterPosition class methodsFor: 'pseudo constructors'!

make: region {XnRegion}
	"A position containing the given region."
	
	^FilterPosition create: region! !

!FilterPosition class methodsFor: 'smalltalk: system'!

info.stProtocol
"{XnRegion CLIENT} baseRegion
"! !Position subclass: #IntegerPos
	instanceVariableNames: 'myValue {IntegerVar}'
	classVariableNames: 'TheZero {IntegerPos} '
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Integers'!
IntegerPos comment:
'Because of the constraints of C++, we have two very different types representing integers in our system.  
	
	XuInteger is the boxed representation which must be used in any context which only knows that it is dealing with a Position.  XuInteger is a Heaper with all that implies.  Specifically, one can take advantage of all the advantages of polymorphism (leading to uses by code that only knows it is dealing with a Position), but at the cost of representing each value by a heap allocated object to which pointers are passed.  Such a representation is referred to as "boxed" because the pointer combined with the storage structure overhead of maintaining a heap allocated object constitutes a "box" between the user of the data (the guy holding onto the pointer), and the actual data (which is inside the Heaper).
	
	In contrast, IntegerVar is the efficient, unboxed representation of an integer.  (actually, it is only unboxed so long as it fits within some size limit such as 32 bits.  Those IntegerVars that exceed this limit pay their own boxing cost to store their representation on the heap.  This need not concern us here.)  See "The Var vs Heaper distinction" and IntegerVar.  When we know that we are dealing specifically with an integer, we`d like to be able to stick with IntegerVars without having to convert them to XuIntegers.  However, we`d like to be able to do everything that we could normally do if we had an XuInteger.
	
	For this purpose, many messages (such as Position * Dsp::of(Position*)) have an additional overloading (IntegerVar Dsp::of(IntegerVar)) whose semantics is defined in terms of converting the argument to an XuInteger, applying the original operation, and converting the result (which is asserted to be an XuInteger) back to an IntegerVar.  Dsp even provides a default implementation to do exactly that.  However, if we actually rely on this default implementation then we are defeating the whole purpose of avoiding boxing overhead.  Instead, IntegerDsp overrides this to provide an efficient implementation.  
	
	Any particular case may at the moment simply be relying on the default.  The point is to get interfaces defined early which allow efficiency tuning to proceed in a modular fashion later.  Should any particular reliance on the default actually prove to be an efficiency issue, we will deal with it then.'!

(IntegerPos getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #ON.CLIENT; add: #COPY; yourself)!

!IntegerPos methodsFor: 'testing'!

{UInt32} actualHashForEqual
	"This must use an external function so other parts of the system can
	 compute the hash from an integerVar without boxing."
	 
	"Open-code in smalltalk because we don't have inlines."
	"NOTE:  Do NOT change this without also changing the implementation of integerHash!!!!!!."
	[^(((myValue DOTasLong * 99991) lo3bytes) bitXor: 98953) "bitShiftRight: 6"] smalltalkOnly.
	[^IntegerPos integerHash: myValue] translateOnly!

{BooleanVar} isEqual: other {Heaper} 

	other
		cast: IntegerPos into: [:xui |
			^xui asIntegerVar = myValue]
		others: [^false].
	^ false "compiler fodder"!

{BooleanVar} isGE: other {Position}
	"Just the full ordering you'd expect on integers"
	
	other 
		cast: IntegerPos into: [:xui |
			^myValue >= xui asIntegerVar]
		others: [Heaper BLAST: #CantMixCoordinateSpaces].
	^ false "compiler fodder"! !

!IntegerPos methodsFor: 'accessing'!

{Int32 INLINE} asInt32
	"Unboxed version as an integer.  See class comment"
	
	^myValue DOTasLong!

{IntegerVar INLINE} asIntegerVar
	"Essential.  Unboxed version.  See class comment"
	
	^myValue!

{XnRegion} asRegion

	^IntegerRegion make: self asIntegerVar!

{CoordinateSpace INLINE} coordinateSpace
	^ IntegerSpace make!

{IntegerVar CLIENT INLINE} value
	"Essential.  Unboxed version.  See class comment"
	
	^myValue! !

!IntegerPos methodsFor: 'smalltalk: private:'!

basicCast: someClass
	someClass == Character ifTrue: [^ Character value: myValue]
		ifFalse: [^self]! !

!IntegerPos methodsFor: 'printing'!

{void} printOn: oo {ostream reference}
	oo << 'I(' << myValue << ')'! !

!IntegerPos methodsFor: 'protected: creation'!

create: newValue {IntegerVar}
	super create.
	myValue _ newValue! !

!IntegerPos methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myValue _ receiver receiveIntegerVar.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendIntegerVar: myValue.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

IntegerPos class
	instanceVariableNames: ''!

(IntegerPos getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #ON.CLIENT; add: #COPY; yourself)!

!IntegerPos class methodsFor: 'pseudo constructors'!

{IntegerPos INLINE} make: newValue {IntegerVar} 
	"Box an integer. See XuInteger class comment. you can also create an 
	integer in smalltalk by sending the integer message to a Smalltalk integer"

	^IntegerPos create: newValue!

{IntegerPos INLINE} zero
	"Box an integer. See XuInteger class comment. you can also create an 
	integer in smalltalk by sending the integer message to a Smalltalk integer.
	This should return the canonical zero eventually."

	^IntegerPos make: IntegerVarZero! !

!IntegerPos class methodsFor: 'smalltalk: smalltalk pseudoconstructors'!

IntegerVar: number
	^ number! !

!IntegerPos class methodsFor: 'hash computing'!

{UInt32 INLINE} integerHash: value {IntegerVar}
	"NOTE:  Do NOT change this without also changing the implementation of hashForEqual in XuInteger!!!!!!."

	[^(((value * 99991) lo3bytes) bitXor: 98953) "bitShiftRight: 6"] smalltalkOnly.
	[^(((value * 99991) DOTasLong bitAnd: 16777215) bitXor: 98953) "bitShiftRight: 6"] translateOnly.! !

!IntegerPos class methodsFor: 'smalltalk: system'!

info.stProtocol
"{IntegerVar CLIENT INLINE} value
"! !

!IntegerPos class methodsFor: 'smalltalk: promise'!

exportName
	^'Integer'! !Position subclass: #RealPos
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!
RealPos comment:
'Represents some real number exactly.  Not all real numbers can be exactly represented.  See class comment in RealSpace.'!

(RealPos getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; add: #COPY; yourself)!

!RealPos methodsFor: 'accessing'!

{XnRegion} asRegion

	^RealRegion make: false
		with: (PrimSpec pointer
			arrayWithTwo: (BeforeReal make: self)
			with: (AfterReal make: self))!

{CoordinateSpace INLINE} coordinateSpace

	^RealSpace make!

{PrimFloatValue CLIENT} value
	"Essential. Return the number as a PrimFloat object from which you can get it in a variety of representations."
	
	self subclassResponsibility! !

!RealPos methodsFor: 'testing'!

{UInt32} actualHashForEqual
	
	[^self asIEEE64 basicCast: UInt32] translateOnly.
	
	[^self asIEEE64 truncated] smalltalkOnly!

{BooleanVar} isEqual: other {Heaper} 

	
	MarkM thingToDo. "128 bit values"
	other
		cast: RealPos into: [:r |
			^self asIEEE64 = r asIEEE64]
		others: [^false].
	^false "fodder"!

{BooleanVar} isGE: other {Position}

	^self asIEEE64 >= (other cast: RealPos) asIEEE64! !

!RealPos methodsFor: 'smalltalk: passe'!

{IntegerVar} exponent

	self passe!

{BooleanVar} isIEEE
	"Whether the real number that this object represents is exactly representable in an available IEEE precision.  Currently the answer is always TRUE, and the available precisions are 8 (stupid precision), 32 (single precision), and 64 (double precision).  If the answer is FALSE, the meaning of the messages 'precision' and 'asIEEE' remain to be defined."
	self passe.
	^true!

{IntegerVar} mantissa
	"This number represents exactly this->mantissa() * 2 ^ this->exponent().  Should we eventually support real numbers which cannot be expressed exactly with integral mantissa and exponent, then this message (and 'exponent') will BLAST for such numbers."

	self passe! !

!RealPos methodsFor: 'obsolete:'!

{IEEE64} asIEEE
	"Returns the value as IEEE basic data type is big enough to hold any value which can be put into an XuReal.  Currently this is an IEEE64 (double precision).  In future releases of this API, the return type of this method may be changed to IEEE128 (quad precision).  Once we support other ways of representing real numbers, there may not be an all-inclusive IEEE type, in which case this message will BLAST.
	
	The only IEEE values which this will return are those that represent real numbers.  I.e., no NANs, no inifinities, no negative zero."
	
	self subclassResponsibility!

{IEEE64} asIEEE64
	"Returns the value as IEEE64 (double precision).
	The only IEEE values which this will return are those that represent real numbers.  I.e., no NANs, no inifinities, no negative zero."
	
	self subclassResponsibility!

{Int32} precision
	"What precision is it, in terms of the number of bits used to represent it.  In the interests of efficiency, this may return a number larger than that *needed* to represent it.  However, the precision reported must be at least that needed to represent this number.  It is assumed that the format of the number satisfies the IEEE radix independent floating point spec.  Should we represent real numbers other that those representable in IEEE, the meaning of this message will be more fully specified.
	
	The fact that this message is allowed to overestimate precision doesn't interfere with equality: a->isEqual(b) exactly when they represent that same real number, even if one of them happens to overestimate precision more that the other."
	
	MarkM thingToDo. "retire this"
	self subclassResponsibility! !

!RealPos methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

RealPos class
	instanceVariableNames: ''!

(RealPos getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; add: #COPY; yourself)!

!RealPos class methodsFor: 'creation'!

{RealPos INLINE} make: value {IEEE64}
	"make an XuReal given an IEEE floating point number of whatever precision on this platform is able to hold all the real numbers currently representable by an XuReal.  Currently this is IEEE64 (double precision), but may be redeclared as a larger IEEE precision in the future.  See comment in XuReal::makeIEEE64"

	^self makeIEEE64: value!

{RealPos} makeIEEE32: value {IEEE32}
	"See comment in XuReal::makeIEEE64"

	self knownBug. "must ensure that it is a number, and convert -0 to +0"
	self thingToDo. "perhaps we should check to see if a lower precision can hold it exactly, and delegate to XuIEEE8.  Nahh."
	
	^IEEE32Pos create: value!

{RealPos} makeIEEE64: value {IEEE64}
	"Returns an XuReal which exactly represents the same real number that is represented by 'value'.  BLASTs if value doesn't represent a real (i.e., no NANs or inifinities).  Negative 0 will be silently converted to positive zero"

	self knownBug. "must ensure that it is a number, and convert -0 to +0"
	self thingToDo. "perhaps we should check to see if a lower precision can hold it exactly, and delegate to XuIEEE32 or XuIEEE8.  Nahh."
	
	^IEEE64Pos create: value!

{RealPos} makeIEEE8: value {IEEE8}
	"See comment in XuReal::makeIEEE64"

	self knownBug. "must ensure that it is a number, and convert -0 to +0"
	
	^IEEE8Pos create: value! !

!RealPos class methodsFor: 'smalltalk: system'!

info.stProtocol
"{PrimFloat CLIENT} value
"! !

!RealPos class methodsFor: 'smalltalk: promise'!

exportName
	^'Real'! !RealPos subclass: #IEEE32Pos
	instanceVariableNames: 'myValue {IEEE32}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!
IEEE32Pos comment:
'For representing exactly those real numbers that can be represented in IEEE single precision'!

(IEEE32Pos getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!IEEE32Pos methodsFor: 'creation'!

create: value {IEEE32}

	super create.
	myValue := value! !

!IEEE32Pos methodsFor: 'obsolete:'!

{IEEE64} asIEEE
	
	[^myValue basicCast: IEEE64] translateOnly.
	
	[^myValue asDouble] smalltalkOnly!

{IEEE64} asIEEE64
	
	[^myValue basicCast: IEEE64] translateOnly.
	
	[^myValue asDouble] smalltalkOnly!

{Int32} precision

	^32! !

!IEEE32Pos methodsFor: 'printing'!

{void} printOn: oo {ostream reference}

	oo << '<' << myValue << '>'! !

!IEEE32Pos methodsFor: 'accessing'!

{PrimFloatValue} value
	^ PrimIEEE32 make: myValue! !

!IEEE32Pos methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myValue _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myValue.! !RealPos subclass: #IEEE64Pos
	instanceVariableNames: 'myValue {IEEE64}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!
IEEE64Pos comment:
'For representing exactly those real numbers that can be represented in IEEE double precision'!

(IEEE64Pos getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!IEEE64Pos methodsFor: 'creation'!

create: value {IEEE64}

	super create.
	myValue := value! !

!IEEE64Pos methodsFor: 'obsolete:'!

{IEEE64} asIEEE

	^myValue!

{IEEE64} asIEEE64

	^myValue!

{Int32} precision

	^64! !

!IEEE64Pos methodsFor: 'printing'!

{void} printOn: oo {ostream reference}

	oo << '<' << myValue << '>'! !

!IEEE64Pos methodsFor: 'accessing'!

{PrimFloatValue} value
	^ PrimIEEE64 make: myValue! !

!IEEE64Pos methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myValue _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myValue.! !RealPos subclass: #IEEE8Pos
	instanceVariableNames: 'myValue {IEEE8}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!
IEEE8Pos comment:
'For representing exactly those real numbers that can be represented in IEEE stupid precision'!

(IEEE8Pos getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!IEEE8Pos methodsFor: 'creation'!

create: value {IEEE8}

	super create.
	myValue := value! !

!IEEE8Pos methodsFor: 'obsolete:'!

{IEEE64} asIEEE

	MarkM shouldImplement.
	^0.0 "fodder"!

{IEEE64} asIEEE64

	MarkM shouldImplement.
	^0.0 "fodder"!

{Int32} precision

	^8! !

!IEEE8Pos methodsFor: 'accessing'!

{PrimFloatValue} value
	MarkM shouldImplement.
	^NULL "fodder"! !

!IEEE8Pos methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myValue _ receiver receiveInt32.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendInt32: myValue.! !Position subclass: #Sequence
	instanceVariableNames: '
		myShift {IntegerVar}
		myNumbers {PrimIntegerArray}'
	classVariableNames: 'TheZero {Sequence} '
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!
Sequence comment:
'Represents an infinite sequence of integers (of which only a finite number can be non-zero). They are lexically ordered, and there is a "decimal point" between the numbers at -1 and 0.

Implementation note:
The array should have no zeros at either end, and noone else should have a pointer to it.'!

(Sequence getOrMakeCxxClassDescription)
	friends:
'/* friends for class Sequence */
friend class AfterSequence;
friend class BeforeSequence;
friend class BeforeSequencePrefix;
friend class SequenceUpOrder;
friend class SequenceSpace;';
	attributes: ((Set new) add: #CONCRETE; add: #ON.CLIENT; add: #COPY; yourself)!

!Sequence methodsFor: 'accessing'!

{XnRegion} asRegion

	^SequenceRegion usingx: false
		with: ((PrimSpec pointer
			arrayWithTwo: (BeforeSequence make: self)
			with: (AfterSequence make: self)) cast: PtrArray)!

{CoordinateSpace INLINE} coordinateSpace

	^SequenceSpace make!

{IntegerVar INLINE} count
	"How many numbers in the sequence, not counting leading or trailing zeros"
	
	^myNumbers count!

{IntegerVar CLIENT} firstIndex
	"The smallest index with a non-zero number. Blasts if it is all zeros."
	
	myNumbers count = Int32Zero ifTrue:
		[Heaper BLAST: #ZeroSequence].
	^myShift!

{IntegerVar CLIENT} integerAt: index {IntegerVar}
	"The number at the given index in the Sequence. Returns zeros beyond either end of the array."
	
	| i {IntegerVar} |
	i := index - myShift.
	(i >= IntegerVarZero and: [i < self count]) ifTrue:
		[^myNumbers integerAt: i DOTasLong]
	ifFalse:
		[^IntegerVarZero]!

{PrimIntegerArray CLIENT} integers
	"Essential. The numbers in this Sequence. This is a copy of the array, so you may modify it.
	Note that two Sequences which are isEqual, may actually have arrays of numbers which have different specs. Also, the array will not have any zeros at the beginning or end."
	
	^myNumbers copy cast: PrimIntegerArray!

{BooleanVar CLIENT} isZero
	"Whether all the numbers in the sequence are zero"
	
	^myNumbers count == Int32Zero!

{IntegerVar CLIENT} lastIndex
	"The largest index with a non-zero number. Blasts if it is all zeros."
	
	myNumbers count = Int32Zero ifTrue:
		[Heaper BLAST: #ZeroSequence].
	^myShift + myNumbers count - 1!

{IntegerVar INLINE} shift
	"The amount by which the numbers are shifted. Positive means less significant, negative means more significant. This is contrary to the usual arithmetic notions, but it is the right thing for arrays."
	
	^myShift! !

!Sequence methodsFor: 'private: comparing'!

{Int32} comparePrefix: other {Sequence} with: n {IntegerVar}
	"Compare my numbers up to and including index n with the corresponding numbers in the other Sequence. Return -1, 0 or 1 depending on whether they are <, =, or > the other."
	
	| diff {IntegerVar} |
	(self isZero or: [myShift > n]) ifTrue:
		[(other isZero or: [other shift > n]) ifTrue: [^Int32Zero].
		(other secretNumbers integerAt: Int32Zero) > IntegerVarZero
			ifTrue: [^-1]
			ifFalse: [^1]].
	(other isZero or: [other shift > n]) ifTrue:
		[(myNumbers integerAt: Int32Zero) > IntegerVarZero
			ifTrue: [^1]
			ifFalse: [^-1]].
	diff := myShift - other shift.
	diff < IntegerVarZero ifTrue:
		[(myNumbers integerAt: Int32Zero) > IntegerVarZero
			ifTrue: [^1]
			ifFalse: [^-1]].
	diff > IntegerVarZero ifTrue:
		[(other secretNumbers integerAt: Int32Zero) > IntegerVarZero
			ifTrue: [^-1]
			ifFalse: [^1]].
	^myNumbers compare: other secretNumbers
		with: (n - myShift + 1 min: (myNumbers count max: other secretNumbers count)) DOTasLong! !

!Sequence methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^myShift DOTasLong bitXor: myNumbers elementsHash!

{BooleanVar} isEqual: other {Heaper}

	other cast: Sequence into: [ :sequence |
		^myShift = sequence shift
			and: [myNumbers contentsEqual: sequence secretNumbers]]
	others:
		[^false].
	^ false "compiler fodder"!

{BooleanVar} isGE: other {Position}
	"Whether this sequence is greater than or equal to the other sequence, using a lexical comparison of their corresponding numbers."
	
	| o {Sequence} |
	o _ other cast: Sequence.
	(self isZero) ifTrue:
		[^o isZero
			or: [(o secretNumbers integerAt: Int32Zero) <= IntegerVarZero]].
	(o isZero or: [myShift < o shift]) ifTrue:
		[^self isZero
			or: [(myNumbers integerAt: Int32Zero) >= IntegerVarZero]].
	myShift > o shift ifTrue:
		[^(o secretNumbers integerAt: Int32Zero) <= IntegerVarZero].
	myShift < o shift ifTrue:
		[^(myNumbers integerAt: Int32Zero) >= IntegerVarZero].
	^(myNumbers compare: o secretNumbers) >= Int32Zero! !

!Sequence methodsFor: 'private:'!

{PrimIntegerArray INLINE} secretNumbers
	"The array itself, for internal use"
	
	^myNumbers! !

!Sequence methodsFor: 'printing'!

{void} printOn: oo {ostream reference}

	Sequence printOn: oo with: myShift with: myNumbers! !

!Sequence methodsFor: 'create'!

create: shift {IntegerVar} with: numbers {PrimIntegerArray}

	super create.
	myShift := shift.
	myNumbers := numbers.! !

!Sequence methodsFor: 'operations'!

{Sequence} first
	"The sequence consisting of all numbers in this one up to but not including the first zero, or the entire thing if there are no zeros"
	
	"| zero {Int32} |
	zero := myNumbers indexOfInteger: IntegerVarZero.
	zero < Int32Zero ifTrue:
		[^self]
	ifFalse:
		[^Sequence create: ((myNumbers copy: zero) cast: PrimIntegerArray)]"
	Someone shouldImplement.
	^NULL "fodder"!

{Sequence} minus: other {Sequence}
	"A sequence with the corresponding numbers subtracted from each other"
	
	| diff {Int32} result {PrimIntegerArray} |
	Ravi thingToDo. "Only increase representation size when necessary"
	Ravi knownBug. "large difference in shifts creates huge array"
	diff := (other shift - myShift) DOTasLong.
	diff > Int32Zero ifTrue:
		[result := (PrimSpec integerVar copyGrow: myNumbers
			with: (diff + other secretNumbers count - myNumbers count max: Int32Zero)) cast: PrimIntegerArray.
		result at: diff subtractElements: other secretNumbers.
		^Sequence usingx: myShift with: result]
	ifFalse:
		[result := (PrimSpec integerVar copy: myNumbers
			with: -1
			with: Int32Zero
			with: diff negated
			with: ((other shift + other count - (myShift + myNumbers count)) DOTasLong max: Int32Zero)) cast: PrimIntegerArray.
		result at: diff negated subtractElements: other secretNumbers.
		^Sequence usingx: other shift with: result]!

{Sequence} plus: other {Sequence}
	"A sequence with the corresponding numbers added to each other"
	
	| diff {Int32} result {PrimIntegerArray} |
	Ravi thingToDo. "Only increase representation size when necessary"
	Ravi knownBug. "large difference in shifts creates huge array"
	diff := (other shift - myShift) DOTasLong.
	diff > Int32Zero ifTrue:
		[result := (PrimSpec integerVar copyGrow: myNumbers
			with: (diff + other secretNumbers count - myNumbers count max: Int32Zero)) cast: PrimIntegerArray.
		result at: diff addElements: other secretNumbers.
		^Sequence usingx: myShift with: result]
	ifFalse:
		[result := (PrimSpec integerVar copy: myNumbers
			with: -1
			with: Int32Zero
			with: diff negated
			with: ((other shift + other count - (myShift + myNumbers count)) DOTasLong max: Int32Zero)) cast: PrimIntegerArray.
		result at: Int32Zero addElements: other secretNumbers.
		^Sequence usingx: other shift with: result]!

{Sequence} rest
	"The sequence consisting of all numbers in this one after but not including the first zero, or a null sequence if there are no zeros"
	
	"| zero {Int32} |
	zero := myNumbers indexOfInteger: IntegerVarZero.
	zero < Int32Zero ifTrue:
		[^Sequence zero]
	ifFalse:
		[^Sequence create: ((myNumbers
			copy: -1 with: 1 + zero) cast: PrimIntegerArray)]"
	Someone shouldImplement.
	^NULL "fodder"!

{Sequence} shift: offset {IntegerVar}
	"Shift the numbers by some number of places. Positive shifts make it less significant, negative shifts make it more significant."
	
	(offset == IntegerVarZero or: [myNumbers count == Int32Zero]) ifTrue: [^self].
	^Sequence create: myShift + offset
		with: myNumbers!

{Sequence CLIENT} with: index {IntegerVar} with: number {IntegerVar}
	"Change a single element of the sequence."
	
	(index >= myShift and: [index - myShift < myNumbers count]) ifTrue:
		[number = IntegerVarZero ifTrue:
			[index = myShift ifTrue:
				[^Sequence create: myShift + 1
					with: ((myNumbers copy: myNumbers count - 1 with: 1) cast: PrimIntegerArray)].
			index = (myShift + myNumbers count) ifTrue:
				[^Sequence create: myShift + 1
					with: ((myNumbers copy: myNumbers count - 1) cast: PrimIntegerArray)]].
		^Sequence create: myShift
			with: (myNumbers at: (index - myShift) DOTasLong hold: number)].
	number = IntegerVarZero ifTrue:
		[^self].
	index < myShift ifTrue:
		[ | result {PrimIntegerArray} |
		result := (((myNumbers spec cast: PrimIntegerSpec) combine: ((PrimSpec toHold: number) cast: PrimIntegerSpec))
			copy: myNumbers
			with: -1
			with: Int32Zero
			with: (myShift - index) DOTasLong) cast: PrimIntegerArray.
		result at: Int32Zero storeInteger: number.
		^Sequence create: index with: result].
	^Sequence create: myShift
		with: (myNumbers at: (index - myShift) DOTasLong hold: number)!

{Sequence} withFirst: number {IntegerVar}
	"A Sequence with all my numbers followed by the given one"
	
	Ravi shouldImplement.
	^NULL "fodder"!

{Sequence} withLast: number {IntegerVar}
	"A Sequence with all my numbers followed by the given one"
	
	^Sequence create: myShift
		with: (myNumbers at: myNumbers count hold: number)!

{Sequence} withRest: other {Sequence}
	"A sequence containing all the numbers in this one, followed by the other one, separated by a single zero."
	
	| spec {PrimIntegerSpec} result {PrimIntegerArray} |
	spec := (myNumbers spec cast: PrimIntegerSpec) combine: (other secretNumbers spec cast: PrimIntegerSpec).
	result := (spec copyGrow: myNumbers with: other count DOTasLong + 1) cast: PrimIntegerArray.
	result at: self count DOTasLong + 1 storeMany: other secretNumbers.
	^Sequence create: myShift with: result! !

!Sequence methodsFor: 'smalltalk: passe'!

{BooleanVar} isEmpty
	"Whether there are no non-zero numbers in the Sequence"
	self passe.
	^myNumbers count == Int32Zero!

{IntegerVar} numberAt: index {IntegerVar}

	self passe "integerAt"!

{PrimIntegerArray} numbers

	self passe. "integers"! !

!Sequence methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myShift _ receiver receiveIntegerVar.
	myNumbers _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendIntegerVar: myShift.
	xmtr sendHeaper: myNumbers.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Sequence class
	instanceVariableNames: ''!

(Sequence getOrMakeCxxClassDescription)
	friends:
'/* friends for class Sequence */
friend class AfterSequence;
friend class BeforeSequence;
friend class BeforeSequencePrefix;
friend class SequenceUpOrder;
friend class SequenceSpace;';
	attributes: ((Set new) add: #CONCRETE; add: #ON.CLIENT; add: #COPY; yourself)!

!Sequence class methodsFor: 'pseudo constructors'!

{Sequence} numbers: digits {PrimIntegerArray}
 
	|first {Int32} last {Int32} |
	first := digits indexPastInteger: IntegerVarZero.
	first = -1 ifTrue: [^ Sequence zero].
	last := digits indexPastInteger: IntegerVarZero with: -1 with: -1.
	^ self create: first with: ((digits copy: last - first + 1 with: first) cast: PrimIntegerArray)!

{Sequence} one: a {IntegerVar}
	"A single element Sequence"
	
	a = IntegerVarZero ifTrue:
		[^self zero].
	^self create: IntegerVarZero with: ((PrimSpec integerVar arrayWith: (PrimSpec integerVar value: a)) cast: PrimIntegerArray)!

{Sequence} string: string {Character star}

	^self create: IntegerVarZero with: (UInt8Array string: string)!

{Sequence} three: a {IntegerVar} with: b {IntegerVar} with: c {IntegerVar}
	"A three element Sequence"
	
	c = IntegerVarZero ifTrue:
		[^self two: a with: b].
	^self create: IntegerVarZero
		  with: ((PrimSpec integerVar arrayWithThree: (PrimSpec integerVar value: a)
		  										 with: (PrimSpec integerVar value: b) 
		  										 with: (PrimSpec integerVar value: c)) cast: PrimIntegerArray)!

{Sequence} two: a {IntegerVar} with: b {IntegerVar}
	"A two element Sequence"
	
	b = IntegerVarZero ifTrue:
		[^self one: a].
	^self create: IntegerVarZero
		    with: ((PrimSpec integerVar arrayWithTwo: (PrimSpec integerVar value: a)
		    										  with: (PrimSpec integerVar value: b)) cast: PrimIntegerArray)!

{Sequence INLINE} zero

	^TheZero! !

!Sequence class methodsFor: 'private:'!

{void} printArrayOn: oo {ostream reference} with: numbers {PrimIntegerArray}
	"Print a sequence of numbers separated by dots. Deal with strings specially."
	
	(numbers isKindOf: UInt8Array) ifTrue:
		[oo << '<' << numbers << '>']
	ifFalse:
		[Int32Zero almostTo: numbers count do: [ :i {Int32} |
			i > Int32Zero ifTrue:
				[oo << '.'].
			oo << (numbers integerAt: i)]]!

{void} printOn: oo {ostream reference}
	with: shift {IntegerVar}
	with: numbers {PrimIntegerArray}
	"Print a sequence of numbers separated by dots. Deal with strings specially."
	
	shift < numbers count negated ifTrue:
		[self printArrayOn: oo with: numbers.
		oo << '.'.
		self printZerosOn: oo with: shift negated - numbers count.
		oo << '!!0']
	ifFalse: [shift < IntegerVarZero ifTrue:
		[self printArrayOn: oo with: ((numbers copy: shift negated DOTasLong) cast: PrimIntegerArray).
		oo << '!!'.
		self printArrayOn: oo
			with: ((numbers copy: -1 with: shift negated DOTasLong) cast: PrimIntegerArray)]
	ifFalse:
		[oo << '0!!'.
		shift > IntegerVarZero ifTrue:
			[self printZerosOn: oo with: shift.
			oo << '.'].
		self printArrayOn: oo with: numbers]]!

{void} printZerosOn: oo {ostream reference}
	with: shift {IntegerVar}
	"Print a sequence of zeros separated by dots. Deal with large numbers specially."
	
	shift > 7 ifTrue:
		[oo << '...(' << shift << ')...']
	ifFalse:
		[IntegerVarZero almostTo: shift - 1 do: [ :i {IntegerVar} |
			oo << '0.'].
		oo << '0']!

{Sequence} usingx: shift {IntegerVar} with: numbers {PrimIntegerArray}
	"Don't need to make a copy of the array"
	
	| start {Int32} stop {Int32} |
	start := numbers indexPastInteger: IntegerVarZero.
	start < Int32Zero ifTrue:
		[^self zero].
	stop := numbers indexPastInteger: IntegerVarZero with: -1 with: -1.
	(start ~= Int32Zero or: [stop < (numbers count - 1)])
		ifTrue: [^self create: shift + start
			with: ((numbers copy: stop - start with: start) cast: PrimIntegerArray)]
		ifFalse: [^self create: shift with: numbers]! !

!Sequence class methodsFor: 'smalltalk: init'!

initTimeNonInherited

	self REQUIRES: IntegerVarArray.
	TheZero := self create: IntegerVarZero with: (IntegerVarArray zeros: Int32Zero).!

linkTimeNonInherited

	TheZero := NULL.! !

!Sequence class methodsFor: 'smalltalk: system'!

info.stProtocol
"{IntegerVar CLIENT} firstIndex
{IntegerVar CLIENT} integerAt: index {IntegerVar}
{PrimIntegerArray CLIENT} integers
{BooleanVar CLIENT} isZero
{IntegerVar CLIENT} lastIndex
{Sequence CLIENT} with: index {IntegerVar} with: number {IntegerVar}
"! !Position subclass: #Tuple
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Cross'!
Tuple comment:
'A tuple is a Position in a CrossSpace represented by a sequence of Positions in its subSpaces'!

(Tuple getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; add: #COPY; yourself)!

!Tuple methodsFor: 'printing'!

{void} printOn: oo {ostream reference} 

	self printOnWithSimpleSyntax: oo
		with: '<'
		with: ', '
		with: '>'!

{void} printOnWithSimpleSyntax: oo {ostream reference} 
	with: openString {char star} 
	with: sep {char star} 
	with: closeString {char star}

	| coords {PtrArray of: Position} |
	oo << openString.
	coords := self coordinates.
	Int32Zero almostTo: coords count do: [:i {Int32} |
		i > Int32Zero ifTrue:
			[oo << sep].
		(coords fetch: i) printOn: oo].
	oo << closeString! !

!Tuple methodsFor: 'accessing'!

{XnRegion} asRegion

	self subclassResponsibility!

{Position CLIENT} coordinate: index {Int32}
	"The position with in a subspace"
	
	^(self coordinates fetch: index) cast: Position!

{PtrArray CLIENT of: Position} coordinates
	"Essential. An array of the coordinates in each sub space"
	
	self subclassResponsibility!

{CoordinateSpace} coordinateSpace

	self subclassResponsibility! !

!Tuple methodsFor: 'testing'!

{UInt32} actualHashForEqual
	
	^Heaper takeOop!

{BooleanVar} isEqual: other {Heaper}

	self subclassResponsibility! !

!Tuple methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Tuple class
	instanceVariableNames: ''!

(Tuple getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; add: #COPY; yourself)!

!Tuple class methodsFor: 'pseudoconstructors'!

make: coordinates {PtrArray of: Position}

	^ActualTuple make: (coordinates copy cast: PtrArray)!

{Tuple} two: zero {Position} with: one {Position}

	^ActualTuple make: ((PrimSpec pointer arrayWithTwo: zero with: one) cast: PtrArray)! !

!Tuple class methodsFor: 'smalltalk: system'!

info.stProtocol
"{Position CLIENT} coordinate: index {Int32}
{PtrArray CLIENT of: Position} coordinates
"! !Tuple subclass: #ActualTuple
	instanceVariableNames: 'myCoordinates {PtrArray of: Position}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Cross'!
ActualTuple comment:
'Default implementation of position in a crossed coordinate space. NOT.A.TYPE'!

(ActualTuple getOrMakeCxxClassDescription)
	friends:
'friend class GenericCrossDsp;
';
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!ActualTuple methodsFor: 'accessing'!

{XnRegion} asRegion
	
	| result {PtrArray of: XnRegion} |
	result := PtrArray nulls: myCoordinates count.
	Int32Zero almostTo: result count do: [:i {Int32} |
		result at: i store: (self coordinate: i) asRegion].
	^GenericCrossRegion make: (self coordinateSpace cast: CrossSpace) with: 1 with: result!

{PtrArray of: Position} coordinates
	
	^myCoordinates copy cast: PtrArray!

{CoordinateSpace} coordinateSpace
	
	| result {PtrArray of: CoordinateSpace} |
	result := PtrArray nulls: myCoordinates count.
	Int32Zero almostTo: result count do: [:i {Int32} |
		result at: i store: (self coordinate: i) coordinateSpace].
	^CrossSpace make: result!

{Int32} count
	^ myCoordinates count!

{Position} positionAt: dimension {Int32}
	^ (myCoordinates fetch: dimension) cast: Position! !

!ActualTuple methodsFor: 'comparing'!

{UInt32} actualHashForEqual
	
	^myCoordinates contentsHash!

{BooleanVar} isEqual: other {Heaper}

	other cast: ActualTuple into: [ :actual |
		^myCoordinates contentsEqual: actual secretCoordinates]
	cast: Tuple into: [ :tuple |
		^myCoordinates contentsEqual: tuple coordinates]
	others:
		[^false].
	^ false "compiler fodder"! !

!ActualTuple methodsFor: 'private: creation'!

create: coordinates {PtrArray of: Position}

	super create.
	myCoordinates := coordinates! !

!ActualTuple methodsFor: 'private: accessing'!

{PtrArray of: Position} secretCoordinates
	"The internal array of coordinates. Do not modify this array!!"
	
	^myCoordinates! !

!ActualTuple methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myCoordinates _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myCoordinates.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ActualTuple class
	instanceVariableNames: ''!

(ActualTuple getOrMakeCxxClassDescription)
	friends:
'friend class GenericCrossDsp;
';
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!ActualTuple class methodsFor: 'pseudoconstructors'!

{Tuple} make: coordinates {PtrArray of: Position}

	^self create: coordinates! !Position subclass: #UnOrdered
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Basic'!
UnOrdered comment:
'A convenient superclass of all Positions which have no natural ordering.  See UnOrdered::isGE for the defining property of this class.  This class should probably go away and UnOrdered::isGE distributed to the subclasses.'!

(UnOrdered getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #NOT.A.TYPE; add: #DEFERRED; yourself)!

!UnOrdered methodsFor: 'accessing'!

{XnRegion} asRegion

	self subclassResponsibility!

{CoordinateSpace} coordinateSpace
	self subclassResponsibility! !

!UnOrdered methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^Heaper takeOop!

{BooleanVar} isEqual: other {Heaper} 
	"Up in position, isGE is deferred, and isEqual is defined in terms of isEqual.
	Here in UnOrdered, we define isGE in terms of isEqual, so we must redefine
	isEqual to be deferred."
	
	self subclassResponsibility! !UnOrdered subclass: #HeaperAsPosition
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Unordered'!
HeaperAsPosition comment:
'A position in a HeaperSpace that represents the identity of some particular Heaper.  See class comment in HeaperSpace.'!

(HeaperAsPosition getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #DEFERRED; yourself)!

!HeaperAsPosition methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^Heaper takeOop!

{BooleanVar} isEqual: other {Heaper} 
	self subclassResponsibility! !

!HeaperAsPosition methodsFor: 'accessing'!

{XnRegion INLINE} asRegion

	^HeaperRegion make.HeaperAsPosition: self!

{CoordinateSpace} coordinateSpace
	self subclassResponsibility!

{Heaper} heaper
	"Return the underlying Heaper whose identity (as a position) I 
	represent. 
	
	It is considered good form not to use this message. There is some 
	controversy as to whether it will go away in the future. If you 
	know of any good reason why it should stick around please let us 
	know."

	self subclassResponsibility! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HeaperAsPosition class
	instanceVariableNames: ''!

(HeaperAsPosition getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #DEFERRED; yourself)!

!HeaperAsPosition class methodsFor: 'pseudo constructors'!

{HeaperAsPosition} make: heaper {Heaper}
	"Return a HeaperAsPosition which represents the identity of this Heaper.  The resulting HeaperAsPosition will strongly retain the original Heaper against garbage collection (though not of course against manual deletion).  See wimpyAsPosition"
	
	^StrongAsPosition create: heaper! !HeaperAsPosition subclass: #StrongAsPosition
	instanceVariableNames: 'itsHeaper {Heaper}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Unordered'!

(StrongAsPosition getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!StrongAsPosition methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^itsHeaper hashForEqual!

{BooleanVar} isEqual: other {Heaper}

	other cast: HeaperAsPosition into: [:hap | 
			^itsHeaper == hap heaper 
				or: [itsHeaper isEqual: hap heaper]]
		others: [^false].
	^false "fodder"! !

!StrongAsPosition methodsFor: 'accessing'!

{CoordinateSpace} coordinateSpace
	^ HeaperSpace make!

{Heaper} heaper
	^ itsHeaper! !

!StrongAsPosition methodsFor: 'printing'!

{void} printOn: oo {ostream reference} 
	oo << 'position of (' << itsHeaper << ')'! !

!StrongAsPosition methodsFor: 'instance creation'!

create: aHeaper {Heaper}
	super create.
	aHeaper ~~ NULL assert: 'Heapers in StrongAsPosition must be real'.
	itsHeaper _ aHeaper! !

!StrongAsPosition methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	itsHeaper _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: itsHeaper.! !Stepper subclass: #RealStepper
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-id'!

(RealStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; yourself)!

!RealStepper methodsFor: 'operations'!

{Heaper wimpy} fetch
	"If I am exhausted (i.e., if (!! this->hasValue())), then return NULL. Else return 
	current element.  I return wimpily since most items returned are held by collections.
	If I create a new object, I should cache it."

	MarkM shouldImplement.
	^NULL "fodder"!

{BooleanVar} hasValue
	"Iff I have a current value (i.e. this message returns true), then I am not 
	exhasted. 'fetch' and 'get' will both return this value, and I can be 'step'ped to 
	my next state. As I am stepped, eventually I may become exhausted (the 
	reverse of all the above), which is a permanent condition. 
	
	Note that not all steppers have to be exhaustable. A Stepper which 
	enumerates all primes is perfectly reasonable. Assuming otherwise will create 
	infinite loops.  See class comment."

	MarkM shouldImplement.
	^false "fodder"!

{void} step
	"Essential.  If I am currently exhausted (see Stepper::hasValue()), then it is an error to step me. The result of doing so isn't currently specified (we probably should specify it to BLAST, but I know that the implementation doesn't currently live up to that spec). 
	
	If I am not exhausted, then this advances me to my next state. If my current value (see Stepper::get()) was my final value, then I am now exhausted, otherwise my new current value is the next value."

	MarkM shouldImplement! !

!RealStepper methodsFor: 'create'!

{Stepper} copy
	"Return a new stepper which steps independently of me, but whose current 
	value is the same as mine, and which must produce a future history of values 
	which satisfies the same obligation that my contract obligates me to produce 
	now. Typically, this will mean that he must produce the same future history 
	that I'm going to produce. However, let's say that I am enumerating the 
	elements of a partial order in some full order which is consistent with the 
	partial order. If a copy of me is made after I'm part way through, then me 
	and my copy may produce any future history compatable both with the partial 
	order and the elements I've already produced by the time of the copy. Of 
	course, a subclass or a Stepper creating message (like 
	IntegerRegion::stepper()) may specify the more stringent requirement (that a 
	copy must produce the same sequence). 
	
	To prevent aliasing, Steppers should typically be passed by copy. See class 
	comment."

	MarkM shouldImplement.
	^NULL "fodder"!

create: transitions {PtrArray}! !Heaper subclass: #RegionDelta
	instanceVariableNames: '
		myBefore {XnRegion}
		myAfter {XnRegion}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-filter'!
RegionDelta comment:
'A RegionDelta represents a change in the state of a Region, holding the state before and after some change. They are in some sense complementary to Joints: In the same way that you can use Filters to examine Joints, you can use RegionDeltas to examine Filters. See also Filter::isSwitchedBy(RegionDelta *) and related methods.'!

(RegionDelta getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!RegionDelta methodsFor: 'creation'!

create: before {XnRegion} with: after {XnRegion}
	super create.
	myBefore _ before.
	myAfter _ after! !

!RegionDelta methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^myBefore hashForEqual + myAfter hashForEqual!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: RegionDelta into: [:rd |
			^(rd before isEqual: myBefore)
			 and: [rd after isEqual: myAfter]]
		others: [^false].
	^false "fodder"!

{BooleanVar INLINE} isSame
	"if the before and after are the same"
	^myBefore isEqual: myAfter! !

!RegionDelta methodsFor: 'accessing'!

{XnRegion INLINE} after
	"The region after the change."
	
	^myAfter!

{XnRegion INLINE} before
	"The region before the change."
	
	^myBefore! !

!RegionDelta methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myBefore _ receiver receiveHeaper.
	myAfter _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myBefore.
	xmtr sendHeaper: myAfter.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

RegionDelta class
	instanceVariableNames: ''!

(RegionDelta getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!RegionDelta class methodsFor: 'pseudo constructors'!

make: before {XnRegion} with: after {XnRegion}
	^RegionDelta create: before with: after! !Tester subclass: #RegionTester
	instanceVariableNames: 'myExampleRegions {ImmuSet NOCOPY of: XnRegion}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Integers'!

(RegionTester getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #DEFERRED; yourself)!

!RegionTester methodsFor: 'deferred: init'!

{ImmuSet of: XnRegion} initExamples
	self subclassResponsibility! !

!RegionTester methodsFor: 'testing'!

{void} allTestsOn: oo {ostream reference}
	myExampleRegions _ self initExamples.
	self testExtraOn: oo.
	self testUnaryRegionOpsOn: oo.
	self testBinaryRegionOpsOn: oo.!

{void} binaryCheck: a {XnRegion} with: b {XnRegion}
	| anb {XnRegion} amb {XnRegion} aub {XnRegion} |
	anb _ a intersect: b.
	(anb isEqual: (b intersect: a)) assert: 'intersect test failed.'.
	(anb isSubsetOf: a) assert: 'intersect/subset test failed.'.
	(anb isSubsetOf: b) assert: 'intersect/subset test failed.'.

	(a intersects: b) == anb isEmpty not assert: 'intersects test failed.'.
	amb _ a minus: b.
	(amb intersects: b) not assert: 'minus/intersect test failed.'.
	(amb isSubsetOf: a) assert: 'minus/subset test failed.'.
	
	aub _ a unionWith: b.
	(aub isEqual: (b unionWith: a)) assert: 'unionWith test failed.'.
	(a isSubsetOf: aub) assert: 'union/subset test failed.'.
	(b isSubsetOf: aub) assert: 'union/subset test failed.'.
	
	(((a isSubsetOf: b) and: [b isSubsetOf: a]) == (a isEqual: b)) assert: 'subset/equals test failed.'.!

{void} testBinaryRegionOpsOn: oo {ostream reference}
	myExampleRegions stepper forEach: [:one {XnRegion} |
		myExampleRegions stepper forEach: [:two {XnRegion} |
			one hashForEqual <= two hashForEqual ifTrue: [
				Heaper problems.AllBlasts
					handle: [ :ex |
						| prob {Problem} |
						'prob = &PROBLEM(ex);' translateOnly.
						[prob _ Problem create: ex PROBLEM with: ex parameter
									with: ex initialContext sender printString with: 0] smalltalkOnly.
						[cerr <<prob] smalltalkOnly .
						'operator<<(cerr,prob);'translateOnly.
						cerr << '
'.
						oo << 'problem checking binary ops of ' << one << ' and ' << two << '
'.
						ex return]
					do: [self binaryCheck: one with: two]]]].
	oo << 'binary regions tests succeeded
'!

{void} testExtraOn: oo {ostream reference}!

{void} testUnaryRegionOpsOn: oo {ostream reference}
	myExampleRegions stepper forEach: [:one {XnRegion} |
		Heaper problems.AllBlasts
			handle: [ :ex |
				| prob {Problem} |
				'prob = &PROBLEM(ex);' translateOnly.
				[prob _ Problem create: ex PROBLEM with: ex parameter
							with: ex initialContext sender printString with: 0] smalltalkOnly.
					[cerr <<prob] smalltalkOnly .
						'operator<<(cerr,prob);'translateOnly.
						cerr << '
'.

				oo << 'problem checking unary ops of ' << one << '
'.
				ex return]
			do: [self unaryCheck: one]].
	oo << 'unary regions tests succeeded
'!

{void} unaryCheck: a {XnRegion}
	(a isEqual: a) assert: 'identity test failed.'.
	a isEmpty not == (a intersects: a) assert: 'intersects test failed.'.
	(a minus: a) isEmpty assert: 'self minus/isEmpty failed.'.
	(a isSubsetOf: a) assert: 'self subset test failed.'.
	((a intersect: a) isEqual: a) assert: 'intersect/isEqual test failed.'.
	a isFull == a complement isEmpty assert: 'infinity inverse test failed.'.
	(a intersect: a complement) isEmpty assert: 'intersect/complement test failed.'.
	((a minus: a complement) isEqual: a) assert: 'minus/complement test failed.'.
	(a complement complement isEqual: a) assert: 'double complement test failed.'.
	(a unionWith: a complement) isFull assert: 'union/complement test failed.'.! !

!RegionTester methodsFor: 'protected: accessing'!

{ImmuSet of: XnRegion} exampleRegions
	^myExampleRegions! !

!RegionTester methodsFor: 'protected: creation'!

create
	super create.
	myExampleRegions _ NULL.! !

!RegionTester methodsFor: 'hooks:'!

{void RECEIVE.HOOK} restartRegionTester: rcvr {Rcvr unused default: NULL}
	myExampleRegions _ NULL.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

RegionTester class
	instanceVariableNames: ''!

(RegionTester getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #DEFERRED; yourself)!

!RegionTester class methodsFor: 'smalltalk: initialization'!

suppressInitTimeInherited!

suppressLinkTimeInherited! !RegionTester subclass: #CrossTester
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-cross'!

(CrossTester getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #(COPY boot ); add: #NOT.A.TYPE; yourself)!

!CrossTester methodsFor: 'init'!

{ImmuSet of: XnRegion} initExamples

	| result {SetAccumulator} space {CrossSpace}
	  regions {PtrArray of: XnRegion} crosses {PtrArray of: XnRegion} |
	result := SetAccumulator make.
	space := CrossSpace make: ((PrimSpec pointer
		arrayWithThree: IntegerSpace make
		with: IntegerSpace make
		with: IntegerSpace make) cast: PtrArray).
	regions := PtrArray nulls: 3.
	regions at: Int32Zero store: (IntegerRegion make: Int32Zero with: 10).
	regions at: 1 store: (IntegerRegion make: 5 with: 15).
	regions at: 2 store: (IntegerRegion make: 10 with: 20).
	crosses := PtrArray nulls: 3.
	Int32Zero almostTo: 27 do: [ :i {Int32} |
		crosses at: Int32Zero store: (regions fetch: i \\ 3).
		crosses at: 1 store: (regions fetch: i // 3 \\ 3).
		crosses at: 2 store: (regions fetch: i // 9).
		result step: (space crossOfRegions: crosses)].
	^result value cast: ImmuSet! !

!CrossTester methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !RegionTester subclass: #FilterTester
	instanceVariableNames: 'myBaseRegions {ImmuSet NOCOPY of: XnRegion}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Basic'!

(FilterTester getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #(COPY boot ); yourself)!

!FilterTester methodsFor: 'creation'!

create
	super create.
	myBaseRegions _ NULL.! !

!FilterTester methodsFor: 'init'!

{ImmuSet of: XnRegion} initExamples
	| acc {SetAccumulator of: XnRegion} 
	  result {SetAccumulator of: Filter} 
	  space {FilterSpace} 
	  simple {ImmuSet} |
	acc _ SetAccumulator make.
	acc step: (IntegerRegion make).
	acc step: (IntegerRegion make: 3).
	acc step: (IntegerRegion make: 1 with: 7).
	acc step: (IntegerRegion make: 5 with: 7).
	acc step: (IntegerRegion make: 5 with: 9).
	(acc value cast: ImmuSet) stepper forEach: [ :each {XnRegion} |
		acc step: each complement].
	myBaseRegions _ (acc value cast: ImmuSet).
	result _ SetAccumulator make.
	space _ FilterSpace make: IntegerSpace make.
	myBaseRegions stepper forEach: [ :region {XnRegion} |
		result step: (Filter subsetFilter: space with: region).
		result step: (Filter notSubsetFilter: space with: region).
		result step: (Filter supersetFilter: space with: region).
		result step: (Filter notSupersetFilter: space with: region)].
	simple _ (result value cast: ImmuSet).
	simple stepper forEach: [ :one {Filter} |
		simple stepper forEach: [ :two {Filter} |
			one hashForEqual < two hashForEqual ifTrue:
				[result step: (one unionWith: two).
				result step: (one intersect: two)]]].
	^(result value cast: ImmuSet)! !

!FilterTester methodsFor: 'testing'!

{void} binaryCheck: a {XnRegion} with: b {XnRegion}
	| af {Filter} bf {Filter} |
	af _ a cast: Filter.
	bf _ b cast: Filter.
	super binaryCheck: af with: bf.

	(af isSubsetOf: bf) ifTrue:
		[myBaseRegions stepper forEach: [ :each {XnRegion} |
			((af match: each) not or: [bf match: each]) assert: 'subset/match test failed']]!

{void} unaryCheck: a {XnRegion}
	super unaryCheck: a.

	myBaseRegions stepper forEach: [ :each {XnRegion} |
		(((a cast: Filter) match: each) ~~ ((a complement cast: Filter) match: each)) assert: 'complement/match test failed']! !

!FilterTester methodsFor: 'hooks:'!

{void RECEIVE.HOOK} restartFilterTester: rcvr {Rcvr unused default: NULL}
	myBaseRegions _ NULL.! !

!FilterTester methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	self restartFilterTester: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !RegionTester subclass: #IntegerRegionTester
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Integers'!

(IntegerRegionTester getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #(COPY boot ); yourself)!

!IntegerRegionTester methodsFor: 'init'!

{ImmuSet of: XnRegion} initExamples
	"IntegerRegionTester runTest"
	| acc {SetAccumulator of: XnRegion} |
	acc _ SetAccumulator make.
	acc step: IntegerRegion make.
	acc step: IntegerRegion make complement.
	acc step: (IntegerRegion make: 3 with: 7).
	acc step: (IntegerRegion make: 3 with: 7) complement.
	acc step: (IntegerRegion after: 5).
	acc step: (IntegerRegion before: 5).
	^acc value cast: ImmuSet! !

!IntegerRegionTester methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !RegionTester subclass: #RealTester
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Basic'!

(RealTester getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #(COPY boot ); yourself)!

!RealTester methodsFor: 'deferred: init'!

{ImmuSet of: XnRegion} initExamples
	| reals {SetAccumulator} result {SetAccumulator} base {ImmuSet} |
	reals := SetAccumulator make.
	reals step: (RealPos make: 0.0).
	reals step: (RealPos make: 1.0).
	reals step: (RealPos make: 2.0).
	result := SetAccumulator make.
	(reals value cast: ScruSet) stepper forEach: [ :real {RealPos} |
		result step: (RealSpace make above: real with: true).
		result step: (RealSpace make above: real with: false).
		result step: (RealSpace make below: real with: true).
		result step: (RealSpace make below: real with: false)].
	base := result value cast: ImmuSet.
	base stepper forEach: [ :r {RealRegion} |
		base stepper forEach: [ :r2 {RealRegion} |
			r hashForEqual < r2 hashForEqual ifTrue:
				[result step: (r unionWith: r2).
				result step: (r intersect: r2)]]].
	^result value cast: ImmuSet! !

!RealTester methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !RegionTester subclass: #SequenceTester
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Basic'!

(SequenceTester getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #(COPY boot ); yourself)!

!SequenceTester methodsFor: 'init'!

{ImmuSet of: XnRegion} initExamples
	| sequences {SetAccumulator} result {SetAccumulator} base {ImmuSet} |
	sequences := SetAccumulator make.
	sequences step: (Sequence zero).
	sequences step: (Sequence one: 1).
	sequences step: (Sequence two: 1 with: 2).
	sequences step: (Sequence two: 1 with: -2).
	(sequences value cast: ImmuSet) stepper forEach: [ :tum {Sequence} |
		sequences step: (tum shift: 2).
		sequences step: (tum shift: -2)].
	result := SetAccumulator make.
	(sequences value cast: ScruSet) stepper forEach: [ :sequence {Sequence} |
		result step: (SequenceSpace make prefixedBy: sequence
			with: sequence shift + sequence count).
		result step: (SequenceSpace make prefixedBy: sequence
			with: sequence shift + sequence count) complement.
		result step: (SequenceSpace make above: sequence with: true).
		result step: (SequenceSpace make above: sequence with: false).
		result step: (SequenceSpace make below: sequence with: true).
		result step: (SequenceSpace make below: sequence with: false)].
	base := result value cast: ImmuSet.
	base stepper forEach: [ :r {SequenceRegion} |
		base stepper forEach: [ :r2 {SequenceRegion} |
			r hashForEqual < r2 hashForEqual ifTrue:
				[result step: (r unionWith: r2).
				result step: (r intersect: r2)]]].
	^result value cast: ImmuSet! !

!SequenceTester methodsFor: 'testing'!

{void} testExtraOn: oo {ostream reference}
	| withLeadingZeros {Sequence} withoutLeadingZeros {Sequence} withTrailingZeros {Sequence} withoutTrailingZeros {Sequence} |
	withLeadingZeros _ Sequence numbers: ((PrimSpec integerVar arrayWithThree: (PrimSpec integerVar value: IntegerVarZero)
		  										 with: (PrimSpec integerVar value: 2) 
		  										 with: (PrimSpec integerVar value: 5)) cast: PrimIntegerArray).  
	withoutLeadingZeros _ (Sequence numbers: ((PrimSpec integerVar arrayWithTwo: (PrimSpec integerVar value: 2) 
		  										 with: (PrimSpec integerVar value: 5)) cast: PrimIntegerArray)) shift: 1.
	(withLeadingZeros hashForEqual == withoutLeadingZeros hashForEqual)
		ifFalse: [oo << 'Sequence::numbers() misses leading zeros']
		ifTrue: [oo << 'Sequence::numbers() correctly counts leading zeros'].

	oo << '
'.

	withTrailingZeros _ Sequence numbers: ((PrimSpec integerVar arrayWithThree: (PrimSpec integerVar value: 5)
		  										 with: (PrimSpec integerVar value: 2) 
		  										 with: (PrimSpec integerVar value: IntegerVarZero)) cast: PrimIntegerArray).  
	withoutTrailingZeros _ (Sequence create: IntegerVarZero
		    with:  ((PrimSpec integerVar arrayWithTwo: (PrimSpec integerVar value: 5) 
		  										 with: (PrimSpec integerVar value: 2)) cast: PrimIntegerArray)).
	(withTrailingZeros hashForEqual == withoutTrailingZeros hashForEqual)
		ifFalse: [oo << 'Sequence::numbers() misses trailing zeros'.]
		ifTrue: [oo << 'Sequence::numbers() correctly counts trailing zeros'.].
	oo << '
'.! !

!SequenceTester methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SequenceTester class
	instanceVariableNames: ''!

(SequenceTester getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #(COPY boot ); yourself)!Stepper subclass: #SequenceStepper
	instanceVariableNames: '
		myIndex {Int32}
		myTransitions {PtrArray of: SequenceEdge}
		myTransitionsCount {Int32}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-id'!

(SequenceStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; yourself)!

!SequenceStepper methodsFor: 'operations'!

{Heaper wimpy} fetch

	myIndex < myTransitionsCount ifTrue:
		[^((myTransitions fetch: myIndex) cast: SequenceEdge) sequence]
	ifFalse:
		[^NULL]!

{BooleanVar} hasValue
	^myIndex < myTransitionsCount!

{void} step
	myIndex := myIndex + 2! !

!SequenceStepper methodsFor: 'create'!

{Stepper} copy
	
	^SequenceStepper create: myIndex with: myTransitions with: myTransitionsCount!

create: transitions {PtrArray of: IDEdge} with: count {Int32}

	super create.
	myIndex := Int32Zero.
	myTransitions := transitions.
	myTransitionsCount := count.!

create: index {Int32} with: transitions {PtrArray of: IDEdge} with: count {Int32}

	super create.
	myIndex := index.
	myTransitions := transitions.
	myTransitionsCount := count.! !Heaper subclass: #TransitionEdge
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-EdgeRegion'!
TransitionEdge comment:
'Clients of EdgeManager define concrete subclasses of this, which are then used by the EdgeManager code'!

(TransitionEdge getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #DEFERRED; add: #COPY; yourself)!

!TransitionEdge methodsFor: 'accessing'!

{TransitionEdge} ceiling: other {TransitionEdge}

	(other isGE: self)
		ifTrue: [^other]
		ifFalse: [^self]!

{TransitionEdge} floor: other {TransitionEdge}

	(self isGE: other)
		ifTrue: [^other]
		ifFalse: [^self]! !

!TransitionEdge methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^Heaper takeOop!

{BooleanVar} follows: pos {Position}
	"Whether the position is strictly less than this edge"
	
	self subclassResponsibility!

{BooleanVar} isEqual: other {Heaper}

	self subclassResponsibility!

{BooleanVar} isFollowedBy: next {TransitionEdge}
	"Whether there is precisely one position between this edge and the next one"
	
	self subclassResponsibility!

{BooleanVar} isGE: other {TransitionEdge}
	"Defines a full ordering among all edges in a given CoordinateSpace"
	
	self subclassResponsibility!

{BooleanVar} touches: other {TransitionEdge}
	"Whether this edge touches the same position the other does"
	
	self subclassResponsibility! !

!TransitionEdge methodsFor: 'printing'!

{void} printTransitionOn: oo {ostream reference}
	with: entering {BooleanVar}
	with: touchesPrevious {BooleanVar}
	"Print a description of this transition"
	
	self subclassResponsibility! !

!TransitionEdge methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !TransitionEdge subclass: #RealEdge
	instanceVariableNames: 'myPos {RealPos}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!

(RealEdge getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #DEFERRED; add: #COPY; yourself)!

!RealEdge methodsFor: 'accessing'!

{RealPos} position

	^myPos! !

!RealEdge methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^myPos hashForEqual bitXor: self getCategory hashForEqual!

{BooleanVar} follows: pos {Position}
	
	self subclassResponsibility!

{BooleanVar} isEqual: other {Heaper}

	self subclassResponsibility!

{BooleanVar} isFollowedBy: next {TransitionEdge}
	
	self subclassResponsibility!

{BooleanVar} isGE: other {TransitionEdge}
	
	self subclassResponsibility!

{BooleanVar} touches: other {TransitionEdge}
	
	^myPos isEqual: (other cast: RealEdge) position! !

!RealEdge methodsFor: 'printing'!

{void} printTransitionOn: oo {ostream reference}
	with: entering {BooleanVar}
	with: touchesPrevious {BooleanVar}
	
	self subclassResponsibility! !

!RealEdge methodsFor: 'creation'!

create: pos {RealPos}

	super create.
	myPos := pos.! !

!RealEdge methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myPos _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myPos.! !RealEdge subclass: #AfterReal
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!

(AfterReal getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!AfterReal methodsFor: 'comparing'!

{BooleanVar} follows: pos {Position}
	
	^self position isGE: (pos cast: RealPos)!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: AfterReal into: [:after |
			^self position isEqual: after position]
		others: [^false].
	^false "fodder"!

{BooleanVar} isFollowedBy: next {TransitionEdge}

	^false!

{BooleanVar} isGE: other {TransitionEdge}
	
	^self position isGE: (other cast: RealEdge) position! !

!AfterReal methodsFor: 'printing'!

{void} printTransitionOn: oo {ostream reference}
	with: entering {BooleanVar}
	with: touchesPrevious {BooleanVar}
	
	oo << ' '.
	entering ifTrue: [oo << '('].
	(touchesPrevious and: [entering not]) ifFalse:
		[oo << self position].
	entering ifFalse: [oo << ']']! !

!AfterReal methodsFor: 'creation'!

create: pos {RealPos}

	super create: pos.! !

!AfterReal methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AfterReal class
	instanceVariableNames: ''!

(AfterReal getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!AfterReal class methodsFor: 'create'!

{RealEdge} make: pos {RealPos}

	^self create: pos! !RealEdge subclass: #BeforeReal
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!

(BeforeReal getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!BeforeReal methodsFor: 'printing'!

{void} printTransitionOn: oo {ostream reference}
	with: entering {BooleanVar}
	with: touchesPrevious {BooleanVar}
	
	oo << ' '.
	entering ifTrue: [oo << '['].
	(touchesPrevious and: [entering not]) ifFalse:
		[oo << self position].
	entering ifFalse: [oo << ')']! !

!BeforeReal methodsFor: 'comparing'!

{BooleanVar} follows: pos {Position}
	
	^((pos cast: RealPos) isGE: self position) not!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: BeforeReal into: [:after |
			^self position isEqual: after position]
		others: [^false].
	^false "fodder"!

{BooleanVar} isFollowedBy: next {TransitionEdge}
	
	next 
		cast: AfterReal into: [:after |
			^self position isEqual: after position]
		others: [^false].
	^false "fodder"!

{BooleanVar} isGE: other {TransitionEdge}
	
	other 
		cast: BeforeReal into: [:before |
			^self position isGE: before position]
		cast: AfterReal into: [:after |
			^(after position isGE: self position) not].
	^false "fodder"! !

!BeforeReal methodsFor: 'creation'!

create: pos {RealPos}

	super create: pos.! !

!BeforeReal methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

BeforeReal class
	instanceVariableNames: ''!

(BeforeReal getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!BeforeReal class methodsFor: 'create'!

{RealEdge} make: pos {RealPos}

	^self create: pos! !TransitionEdge subclass: #SequenceEdge
	instanceVariableNames: 'mySequence {Sequence}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!

(SequenceEdge getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #DEFERRED; add: #COPY; yourself)!

!SequenceEdge methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^self sequence hashForEqual bitXor: self getCategory hashForEqual!

{BooleanVar} follows: pos {Position}
	"Whether the position is strictly less than this edge"
	
	self subclassResponsibility!

{BooleanVar} isEqual: other {Heaper}

	self subclassResponsibility!

{BooleanVar} isFollowedBy: next {TransitionEdge}
	"Whether there is precisely one position between this edge and the next one"
	
	self subclassResponsibility!

{BooleanVar} isGE: other {TransitionEdge}
	"Defines a full ordering among all edges in a given CoordinateSpace"
	
	self subclassResponsibility!

{BooleanVar} touches: other {TransitionEdge}
	"Whether this edge touches the same position the other does"
	
	self subclassResponsibility! !

!SequenceEdge methodsFor: 'accessing'!

{Sequence} sequence

	^mySequence!

{SequenceEdge} transformedBy: dsp {SequenceMapping}
	"Transform the edge by the given mapping"
	
	self subclassResponsibility! !

!SequenceEdge methodsFor: 'printing'!

{void} printOn: oo {ostream reference}

	oo << self getCategory name << '(' << mySequence << ')'!

{void} printTransitionOn: oo {ostream reference}
	with: entering {BooleanVar}
	with: touchesPrevious {BooleanVar}
	"Print a description of this transition"
	
	self subclassResponsibility! !

!SequenceEdge methodsFor: 'create'!

create: sequence {Sequence}

	super create.
	mySequence := sequence.! !

!SequenceEdge methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	mySequence _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: mySequence.! !SequenceEdge subclass: #AfterSequence
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!

(AfterSequence getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!AfterSequence methodsFor: 'accessing'!

{Position} position

	^self sequence!

{SequenceEdge} transformedBy: dsp {SequenceMapping}

	^AfterSequence make: ((dsp of: self sequence) cast: Sequence)! !

!AfterSequence methodsFor: 'create'!

create: sequence {Sequence}

	super create: sequence.! !

!AfterSequence methodsFor: 'printing'!

{void} printTransitionOn: oo {ostream reference}
	with: entering {BooleanVar}
	with: touchesPrevious {BooleanVar}

	
	oo << ' '.
	entering ifTrue: [oo << '('].
	(touchesPrevious and: [entering not]) ifFalse:
		[oo << self sequence].
	entering ifFalse: [oo << ']']! !

!AfterSequence methodsFor: 'comparing'!

{BooleanVar} follows: pos {Position}

	^self sequence isGE: (pos cast: Sequence)!

{BooleanVar} isEqual: other {Heaper}

	other cast: AfterSequence into: [ :after |
		^after sequence isEqual: self sequence]
	others:
		[^false].
	^ false "compiler fodder"!

{BooleanVar} isFollowedBy: next {TransitionEdge unused}

	^false!

{BooleanVar} isGE: other {TransitionEdge}

	other cast: BeforeSequencePrefix into: [ :prefix |
		^(self sequence comparePrefix: prefix sequence with: prefix limit) >= Int32Zero]
	cast: SequenceEdge into: [ :edge |
		^self sequence isGE: edge sequence].
	^ false "compiler fodder"!

{BooleanVar} touches: other {TransitionEdge}

	other cast: BeforeSequencePrefix into: [ :prefix |
		^false]
	cast: SequenceEdge into: [ :edge |
		^self sequence isEqual: edge sequence].
	^ false "compiler fodder"! !

!AfterSequence methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AfterSequence class
	instanceVariableNames: ''!

(AfterSequence getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!AfterSequence class methodsFor: 'pseudo constructors'!

{SequenceEdge} make: sequence {Sequence}

	^self create: sequence! !SequenceEdge subclass: #BeforeSequence
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!

(BeforeSequence getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!BeforeSequence methodsFor: 'comparing'!

{BooleanVar} follows: pos {Position}

	^((pos cast: Sequence) isGE: self sequence) not!

{BooleanVar} isEqual: other {Heaper}

	other cast: BeforeSequence into: [ :before |
		^before sequence isEqual: self sequence]
	others:
		[^false].
	^ false "compiler fodder"!

{BooleanVar} isFollowedBy: next {TransitionEdge}

	next cast: AfterSequence into: [ :after |
		^self sequence isEqual: after sequence]
	others:
		[^false].
	^ false "compiler fodder"!

{BooleanVar} isGE: other {TransitionEdge}

	other cast: BeforeSequencePrefix into: [ :prefix |
		^(self sequence comparePrefix: prefix sequence with: prefix limit) >= Int32Zero]
	cast: BeforeSequence into: [ :before |
		^self sequence isGE: before sequence]
	cast: AfterSequence into: [ :after |
		^(after sequence isGE: self sequence) not].
	^ false "compiler fodder"!

{BooleanVar} touches: other {TransitionEdge}

	other cast: BeforeSequencePrefix into: [ :prefix |
		^false]
	cast: SequenceEdge into: [ :edge |
		^self sequence isEqual: edge sequence].
	^ false "compiler fodder"! !

!BeforeSequence methodsFor: 'accessing'!

{Position} position

	^self sequence!

{SequenceEdge} transformedBy: dsp {SequenceMapping}

	^BeforeSequence make: ((dsp of: self sequence) cast: Sequence)! !

!BeforeSequence methodsFor: 'create'!

create: sequence {Sequence}

	super create: sequence.! !

!BeforeSequence methodsFor: 'printing'!

{void} printTransitionOn: oo {ostream reference}
	with: entering {BooleanVar}
	with: touchesPrevious {BooleanVar}

	oo << ' '.
	entering ifTrue: [oo << '['].
	(touchesPrevious and: [entering not]) ifFalse:
		[oo << self sequence].
	entering ifFalse: [oo << ')']! !

!BeforeSequence methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

BeforeSequence class
	instanceVariableNames: ''!

(BeforeSequence getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!BeforeSequence class methodsFor: 'pseudo constructors'!

{SequenceEdge} make: sequence {Sequence}

	^self create: sequence! !SequenceEdge subclass: #BeforeSequencePrefix
	instanceVariableNames: 'myLimit {IntegerVar}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!

(BeforeSequencePrefix getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!BeforeSequencePrefix methodsFor: 'comparing'!

{BooleanVar} follows: pos {Position}

	^ (self sequence isEqual: (pos cast: Sequence)) not and: [self sequence isGE: pos]!

{BooleanVar} isEqual: other {Heaper}

	other cast: BeforeSequencePrefix into: [ :prefix |
		^myLimit = prefix limit
			and: [prefix sequence isEqual: self sequence]]
	others:
		[^false].
	^ false "compiler fodder"!

{BooleanVar} isFollowedBy: next {TransitionEdge unused}

	^false!

{BooleanVar} isGE: other {TransitionEdge}

	| diff {Int32} |
	other cast: BeforeSequencePrefix into: [ :prefix |
		diff := self sequence comparePrefix: prefix sequence
			with: (myLimit min: prefix limit).
		diff ~= Int32Zero ifTrue:
			[^diff > Int32Zero].
		^myLimit >= prefix limit]
	cast: SequenceEdge into: [ :before |
		^(self sequence comparePrefix: before sequence with: myLimit) > Int32Zero].
	^ false "compiler fodder"!

{BooleanVar} touches: other {TransitionEdge}

	other cast: BeforeSequencePrefix into: [ :before |
		^myLimit = before limit
			and: [(self sequence comparePrefix: before sequence with: myLimit - 1) = Int32Zero
			and: [((self sequence integerAt: myLimit) - (before sequence integerAt: myLimit)) abs <= 1]]]
	others:
		[^false].
	^ false "compiler fodder"! !

!BeforeSequencePrefix methodsFor: 'accessing'!

{IntegerVar} limit

	^myLimit!

{Position} position

	Heaper BLAST: #NotInSpace.
	^NULL "fodder"!

{SequenceEdge} transformedBy: dsp {SequenceMapping}

	^BeforeSequencePrefix create: ((dsp of: self sequence) cast: Sequence)
		with: myLimit + dsp shift! !

!BeforeSequencePrefix methodsFor: 'create'!

create: sequence {Sequence} with: limit {IntegerVar}

	super create: sequence.
	myLimit := limit.! !

!BeforeSequencePrefix methodsFor: 'printing'!

{void} printOn: oo {ostream reference}

	oo << self getCategory name << '(' << myLimit << ', ' << self sequence << ')'!

{void} printTransitionOn: oo {ostream reference}
	with: entering {BooleanVar}
	with: touchesPrevious {BooleanVar}
	
	oo << ' '.
	entering ifTrue: [oo << '('].
	(touchesPrevious and: [entering not]) ifFalse:
		[Ravi thingToDo. "Eliminate strings of zeros / stars, print UInt8Arrays as strings"
		(IntegerVarZero min: self sequence shift) to: (myLimit + 1 max: IntegerVarZero) do:
			[ :i {IntegerVar} |
			i == IntegerVarZero ifTrue:
				[oo << '!!']
			ifFalse: [i ~= self sequence shift ifTrue:
				[oo << '.']].
			(i = myLimit and: [entering not]) ifTrue:
				[oo << ((self sequence integerAt: i) - 1)]
			ifFalse: [i <= myLimit ifTrue:
				[oo << (self sequence integerAt: i)]
			ifFalse:
				[oo << '*']]]].
	entering ifFalse: [oo << ')']! !

!BeforeSequencePrefix methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myLimit _ receiver receiveIntegerVar.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendIntegerVar: myLimit.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

BeforeSequencePrefix class
	instanceVariableNames: ''!

(BeforeSequencePrefix getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; add: #NOT.A.TYPE; yourself)!

!BeforeSequencePrefix class methodsFor: 'pseudo constructors'!

{TransitionEdge} above: sequence {Sequence} with: limit {IntegerVar}

	limit < sequence shift ifTrue:
		[^self create: (Sequence usingx: limit with: ((PrimSpec integerVar
				arrayWith: (PrimSpec integerVar value: 1)) cast: PrimIntegerArray)) with: limit].
	limit < (sequence shift + sequence count) ifTrue:
		[| newCount {Int32} hisCount {Int32} |
		newCount _ (limit - sequence shift + 1) DOTasLong.
		hisCount _ sequence secretNumbers count.
		^self create: (Sequence
			usingx: sequence shift
			with: (((sequence secretNumbers
							copy: (newCount min: hisCount)
							with: Int32Zero
							with: Int32Zero
							with: (newCount - hisCount max: Int32Zero)) cast: PrimIntegerArray)
				at: (limit - sequence shift) DOTasLong
				hold: (sequence integerAt: limit) + 1
				with: true))
			with: limit].
	"Ravi knownBug." "creates huge arrays if (limit - sequence shift) is too big"
	^self create: (Sequence
			usingx: sequence shift
			with: (sequence secretNumbers
				at: (limit - sequence shift) DOTasLong
				hold: (sequence integerAt: limit) + 1))
		with: limit!

{TransitionEdge} below: sequence {Sequence} with: limit {IntegerVar}

	limit < sequence shift ifTrue:
		[^self create: Sequence zero with: limit].
	limit < (sequence shift + sequence count) ifTrue:
		[| newCount {Int32} hisCount {Int32} |
		newCount _ (limit - sequence shift + 1) DOTasLong.
		hisCount _ sequence secretNumbers count.
		^self create: (Sequence
						usingx: sequence shift
						with: ((sequence secretNumbers
							copy: (newCount min: hisCount)
							with: Int32Zero
							with: Int32Zero
							with: (newCount - hisCount max: Int32Zero)) cast: PrimIntegerArray))
				with: limit].
	^self create: sequence with: limit! !Stepper subclass: #TupleStepper
	instanceVariableNames: '
		mySpace {CrossSpace}
		myVirginSteppers {PtrArray of: (Stepper of: Position)}
		mySteppers {PtrArray of: (Stepper of: Position)}
		myLexOrder {PrimIntArray}
		myValue {Tuple | NULL}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-cross'!
TupleStepper comment:
'A stepper for stepping through the positions in a simple cross region in order according to a lexicographic composition of OrderSpecs of each of the projections of the region.  See CrossOrderSpec.NOT.A.TYPE '!

(TupleStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!TupleStepper methodsFor: 'private: creation'!

create: space {CrossSpace} 
	with: virginSteppers {PtrArray of: (Stepper of: Position)}
	with: steppers {PtrArray of: (Stepper of: Position)}
	with: lexOrder {PrimIntArray} 
	
	super create.
	mySpace := space.
	myVirginSteppers := virginSteppers.
	mySteppers := steppers.
	myLexOrder := lexOrder.
	self setValueFromSteppers! !

!TupleStepper methodsFor: 'private:'!

{void} setValueFromSteppers

	| coords {PtrArray of: Position} |
	coords := PtrArray nulls: mySteppers count.
	Int32Zero almostTo: mySteppers count do: [:i {Int32} |
		coords at: i store: (((mySteppers fetch: i) cast: Stepper) get cast: Position)].
	myValue := mySpace crossOfPositions: coords! !

!TupleStepper methodsFor: 'operations'!

{Stepper} copy
	
	| newSteppers {PtrArray of: (Stepper of: Position)} |
	self hasValue ifFalse:
		[^Stepper emptyStepper].
	newSteppers := PtrArray nulls: mySteppers count.
	Int32Zero almostTo: mySteppers count do: [:i {Int32} |
		newSteppers at: i store: ((mySteppers fetch: i) cast: Stepper) copy].
	^TupleStepper create: mySpace with: myVirginSteppers with: newSteppers with: myLexOrder!

{Heaper wimpy} fetch

	^myValue!

{BooleanVar} hasValue

	^myValue ~~ NULL!

{void} step
	| stomp {Stepper of: Position} |
	myValue == NULL ifTrue: [^VOID].
	myLexOrder count -1 to: Int32Zero by: -1 do: [:i {Int32} |
		| dim {Int32} |
		dim := (myLexOrder integerAt: i) DOTasLong.
		stomp := (mySteppers fetch: dim) cast: Stepper.
		stomp step.
		stomp hasValue ifTrue:
			[self setValueFromSteppers.
			^VOID].
		mySteppers at: dim store: ((myVirginSteppers fetch: dim) cast: Stepper) copy].
	myValue := NULL! !

!TupleStepper methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	mySpace _ receiver receiveHeaper.
	myVirginSteppers _ receiver receiveHeaper.
	mySteppers _ receiver receiveHeaper.
	myLexOrder _ receiver receiveHeaper.
	myValue _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: mySpace.
	xmtr sendHeaper: myVirginSteppers.
	xmtr sendHeaper: mySteppers.
	xmtr sendHeaper: myLexOrder.
	xmtr sendHeaper: myValue.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

TupleStepper class
	instanceVariableNames: ''!

(TupleStepper getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!TupleStepper class methodsFor: 'pseudoconstructors'!

{Stepper} make: space {CrossSpace} 
	with: virginSteppers {PtrArray of: (Stepper of: Position)}
	with: lexOrder {PrimIntArray default: NULL} 
	
	| steppers {PtrArray of: (Stepper of: Position)} lexO {PrimIntArray} |
	virginSteppers count = Int32Zero ifTrue:
		[^Stepper itemStepper: (space crossOfPositions: (PtrArray nulls: Int32Zero))].
	steppers := PtrArray nulls: virginSteppers count.
	Int32Zero almostTo: virginSteppers count do: [:i {Int32} |
		| vs {Stepper of: Position} |
		vs := (virginSteppers fetch: i) cast: Stepper.
		vs hasValue ifFalse:
			[^Stepper emptyStepper].
		steppers at: i store: vs copy].
		
	lexOrder == NULL ifTrue:
		[lexO := Int32Array make: virginSteppers count.
		Int32Zero almostTo: virginSteppers count do: [:i {Int32} |
			lexO at: i storeInteger: i]]
	ifFalse:
		[lexO := lexOrder].
	^self create: space with: virginSteppers with: steppers with: lexO! !

!TupleStepper class methodsFor: 'smalltalk: defaults'!

make: space with: virginSteppers
	
	^self make: space with: virginSteppers with: NULL! !Heaper subclass: #XnRegion
	instanceVariableNames: ''
	classVariableNames: '
		CantMixCoordSpacesSignal {Signal smalltalk} 
		EmptyRegionSignal {Signal smalltalk} '
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Basic'!
XnRegion comment:
'The design of a new coordinate space consists mostly in the design of the XuRegions which can be used to describe (possibly infinite) sets of positions in that coordinate space.  It will generally not be the case (for a given coordinate space) that all mathematically describable sets of positions will be representable by an XuRegion in that space.  This should not be seen as a temporary deficiency of the current implementation of a space, but rather part of the design of what a given space *means*.  
	
	For example, in IntegerSpace, one cannot form the XuRegion whose members are exactly the even numbers.  If this were possible, other desirable properties which are part of the intent of IntegerSpaces would no longer be possible.  For example, any XuRegion should be able to break itself up into a finite number of simple XuRegions ("simple" is described below).  Were an even number region possible, this would have undesirable consequences for the definition of "simple" in this space.  If you want (for example) to be able to have a XuRegion which can represent all the even numbers, it probably makes more sense to define a whole new space in which these new XuRegions apply.
	
	XuRegions should be closed under a large set of operations, such as intersection, unionWith, complement and minus.  ("closed" means that the result of performing this operation on XuRegions of a given space is another valid XuRegion in the same space.)  Additional guarantees are documented with each operation.
	
	A XuRegion may be classified at one of three levels of "simplicity":
	
	1) The simplest are the *distinctions*.  Distinctions are those that answer with (at most) a single set containing themselves in response to the message "distinctions".  (The reason I say "at most" is that a full region (one that covers the entire coordinate space) may answer with the empty set.)  Distinctions are the simplest XuRegions of a given space out of which all other XuRegions of that space can be finitely composed.  There should probably be a message "isDistinction" for which exactly the distinctions answer "true".  The complement of a distinction is a distinction.  Three examples of distinctions in spaces are:
	
		a) in IntegerSpace, any simple inequality.  For example, all integers < 37.
		b) in one kind of 3-space, any half space (all the space on one side of some plane)
		c) in another kind of 3-space, any sphere or spherical hole.
		
	Note that "c" could not just have spheres as the distinction because distinctions must be closed under complement.  (We are here ignoring the quite substantial problems that arise in dealing with approximate (e.g., floating point) which would almost necessarily have to arise in doing any decent 3-space.  3-space is nevertheless a good intuition pump.)
	
	2) Next are the *simple regions*.  Simple regions are exactly those that say "true" to "isSimple".  All distinctions are also simple regions.  In response to the message "distinctions", and simple region must return a finite set of distinctions which, when intersected together, yield the original simple region.  Generally, one tries to define the simple regions for a space to correspond to some notion of locality in the space.  For example, it may be good for a simple region not to be able to have a hole in it.  Or perhaps a simple region is which must be connected (whatever that means in a given space).  Example non-distinction simple regions for the above example spaces would be:
	
		a) The interval from 3 inclusive to 17 exclusive (intersection of all integers >= 3 and all < 17)
		b) A convex hull (intersection of half spaces)
		c) Whatever you get by intersecting a bunch of spheres and sherical holes.
		
	The simple regions for both "a" and "b" would be connected, without holes, and even convex.  This follows directly from the definition of our distinctions.  None of these nice properties holds for "c", and this also follows directly from our decision to start with spheres.  "c" is still perfectly valid, just less preferable by some criteria.
	
	3) Finally, there are the regions of a space in general.  Any region must respond to the message "simpleRegions" with a stepper which will produce a finite number of simple regions that, when unioned together, yields the original region.  A simple region will return a stepper that will return at most itself ("at most" because an empty region (which covers no positions) may return an empty stepper).  Example non-simple regions are:
	
		a) all integers < 3 and all integers >= 17
		b) two convex hulls
		c) two disjoint spheres
		
	Note that "a" is the complement of the earlier "a" example, thereby showing why the complement of a simple region isn`t necessarily simple.  Even though the "c" space is so unconstrained in the properties of its simple regions, there is no way to interect a finite number of spheres and spherical holes to produce a pair of disjoint spheres.  Therefore the pair is non-simple.  Not all spaces must have non-simple regions (or even non-distinctions).  It is interesting to observe for "b" and "c" that even though there is a natural conversion between their respective positions, (except for the empty and full regions) there is no conversion at all between their respective regions.  The kinds of sets of positions representable in one space is completely different than those representable in the other space.
	
	We will use these three example spaces repeatedly in documenting the protocol.'!

(XnRegion getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; yourself)!

!XnRegion methodsFor: 'accessing'!

{XnRegion} asSimpleRegion
	"Return a simple region containing all positions contained by myself. 
	If I am simple, then the result must be me.  Otherwise,
	the resulting region will contain more positions than I do, but it 
	must contain all those that I do.  It would be good for the resulting 
	simple region to not contain many more points than it needs in order 
	to satisfy these constraints; but this is a preference, not a 
	specification. Particular spaces may specify stronger guarantees, 
	but as far as class XuRegion is concerned it is correct (though silly) 
	for this message to always return the full region for the space."

	^self simpleUnion: self!

{CoordinateSpace CLIENT} coordinateSpace
	"Essential.  The coordinate space in which this is a region"
	
	self subclassResponsibility! !

!XnRegion methodsFor: 'operations'!

{XnRegion CLIENT} complement
	"Essential.  Return a region of containing exactly those positions not in this region. The complement of a distinction must be a distinction."

	self subclassResponsibility!

{XnRegion} delta: region {XnRegion}
	"The region where they differ.  
	a->delta(b) ->isEqual (a->minus(b)->unionWith(b->minus(a)))"
	
	^(self minus: region) unionWith: (region minus: self)!

{XnRegion CLIENT} intersect: other {XnRegion unused} 
	"Essential.  The intersection of two simple regions must be simple. The intersection of two distinctions must therefore be a simple region. The result has exactly those members which both the original regions have."

	self subclassResponsibility!

{XnRegion CLIENT} minus: other {XnRegion}
	"The region containing all my position which aren't in other."
	
	other isEmpty
		ifTrue: [^self ]
		ifFalse: [ ^self intersect: other complement ]!

{XnRegion} simpleUnion: other {XnRegion unused} 
	"The result must contain all positions contained by either of the two 
	original regions, and the result must be simple. However, the result 
	may contain additional positions. See the comment on 
	'XuRegion::asSimpleRegion'.  a->simpleUnion(b) satisfies the same specification 
	as (a->unionWith(b))->asSimpleRegion(). However, the two results do 
	not have to be the same region."

	self subclassResponsibility!

{XnRegion CLIENT} unionWith: other {XnRegion unused} 
	"The result has as members exactly those positions which are members of either of the original two regions. No matter how simple the two original regions are, the result may be non-simple.
	
	The only reason this is called 'unionWith' instead of 'union' is that the latter is a C++ keyword."

	self subclassResponsibility!

{XnRegion CLIENT} with: pos {Position} 
	"the region with one more position. Actually, if I already contain pos, then the result is just me."

	^self unionWith: pos asRegion!

{XnRegion CLIENT} without: pos {Position} 
	"the region with one less position. Actually if I already don't contain pos, then the result is just me."

	^self minus: pos asRegion! !

!XnRegion methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^Heaper takeOop!

{BooleanVar CLIENT} hasMember: atPos {Position unused} 
	"Do I contain this position? More than anything else, the behavior of this message is the defining characteristic of an XuRegion. All other messages (except for the simplicity characterization) should be specifiable in terms of the behavior of this message. What an XuRegion *is* (mostly) is a finite decision procedure for accepting or rejecting any given position."

	self subclassResponsibility!

{BooleanVar CLIENT} intersects: other {XnRegion} 
	"Essential.  tell whether it has any points in common"
	
	self isEmpty
		ifTrue: [ ^ false ]
		ifFalse:
			[other isEmpty
				ifTrue: [^ false]
				ifFalse: [^(self intersect: other) isEmpty not]]!

{BooleanVar} isDistinction
	"Am I a distinction.  See XuRegion class comment for implications of being a distinction."
	
	^self isSimple and: [self distinctions count <= 1]!

{BooleanVar CLIENT} isEmpty
	"Every coordinate space has exactly one empty region. It is the one containing no positions. It and only it responds 'true' to this message."

	self subclassResponsibility!

{BooleanVar} isEqual: other {Heaper}
	"Two regions are equal iff they contain exactly the same set of positions"
	
	self subclassResponsibility!

{BooleanVar CLIENT} isFinite
	"Essential.  Do I contain a finite number of positions? If I do, then the 'count' message will say how many, and I will gladly provide a stepper which will step over all of them. I.e., isFinite implies isEnumerable."

	self subclassResponsibility!

{BooleanVar CLIENT} isFull
	"true if this is the largest possible region in this space -- the region that contains all positions in the space. Note that in a space which has no positions (which is perfectly valid), the one XuRegion would be both empty (since it has no positions) and full (since it has all the positions in the space)."

	^self complement isEmpty!

{BooleanVar} isSimple
	"Am I a simple region.  See XuRegion class comment for implications of being simple."
	
	self subclassResponsibility!

{BooleanVar CLIENT} isSubsetOf: other {XnRegion} 
	"I'm a subset of other if I don't have any positions that he doesn't. Note that if we are equal, then I am still a subset of him. If you want to know if I'm a strict subset, you can ask 
	a->isSubsetOf(b) && !! a->isEqual(b)"

	^(self minus: other) isEmpty! !

!XnRegion methodsFor: 'smalltalk: defaults'!

{XnRegion CLIENT} chooseMany: n {IntegerVar}

	^self chooseMany: n with: NULL!

{Position CLIENT} chooseOne

	^self chooseOne: NULL!

disjointSimpleRegions
	"emulate default argument of NULL"
	^self disjointSimpleRegions: NULL!

{BooleanVar} isEnumerable
	"emulate default argument of NULL"
	^self isEnumerable: NULL!

{Mapping} mapping: data {PrimArray}

	^self mapping: data with: NULL!

simpleRegions
	"emulate default argument of NULL"
	^self simpleRegions: NULL!

{Stepper CLIENT of: Position} stepper
	"emulate default argument of NULL"
	^self stepper: NULL! !

!XnRegion methodsFor: 'enumerating'!

{XnRegion CLIENT} chooseMany: n {IntegerVar} with: order {OrderSpec default: NULL}
	"If an OrderSpec is given, return the first n elements according to that OrderSpec. If no OrderSpec is given, then iff I contain at least n positions, return n of them; otherwise BLAST. This should be implemented even by regions that aren't enumerable.  Inspired by the axiom of choice."
	
	Someone shouldImplement.
	^NULL "fodder"!

{Position CLIENT} chooseOne: order {OrderSpec default: NULL}
	"Essential.  If an OrderSpec is given, return the first element according to that OrderSpec. If no OrderSpec is given, then iff I contain at least one position, return one of them; otherwise BLAST. This should be implemented even by regions that aren't enumerable.  Inspired by the axiom of choice."
	
	self isEmpty ifTrue:
		[Heaper BLAST: #EmptyRegion].
	self thingToDo.	"self isEnumerable assert: 'Must be overridden otherwise'."
	^(self stepper: order) get cast: Position!

{IntegerVar CLIENT} count
	"How many positions do I contain?  If I am not 'isFinite', then this message will BLAST."
	
	self subclassResponsibility!

{Stepper INLINE of: XnRegion} disjointSimpleRegions: order {OrderSpec default: NULL} 
	"break it up into a set of non-empty simple regions which don't 
	overlap. This message satisfies all the specs of 'simpleRegions', and 
	in addition provides for lack of overlap. It may be significantly more 
	expensive than 'simpleRegions' which is why they both exist."

	^DisjointRegionStepper make: self with: order!

{ScruSet of: XnRegion} distinctions
	"Break it up into a set of non-full distinctions. It is an error to send 
	this to a non-simple region. A full region will respond with the null 
	set. Other distinctions will respond with a singleton set containing 
	themselves, and simple regions will respond with a set of distinctions 
	which, when intersected together, yield the original region."

	self subclassResponsibility!

{Stepper} simpleRegions: order {OrderSpec default: NULL} 
	"Break myself up into a finite set of non-empty simple regions which, when 
	unionWith'ed together will yield me. May be sent to any region. If I 
	am isEmpty, I will respond with the empty stepper. Otherwise, if I am 
	simple I will respond with a stepper producing just myself. 
	
	Please only use NULL for the 'order' argument for now unless the 
	documentation for a particular region or coordinate space says that 
	it will deal with the 'order' argument meaningfully. When no order is 
	specified then I may return the simple regions in any order. When the 
	ordering functionality is implemented, then I am constrained to 
	produce the simple regions in an order consistent with the argument's 
	ordering of my positions. When the simple regions don't overlap, and 
	don't surround each other in the ordering, then the meaning is clear. 
	Otherwise, there are several plausible options for how we should 
	specify this message."

	self subclassResponsibility!

{Stepper CLIENT of: Position} stepper: order {OrderSpec default: NULL} 
	"Essential.  If my positions are enumerable in the order specified, then return a stepper which will so enumerate them. If 'order' is NULL, then I may treat this as a request to enumerate according to any order I choose, except that if I am enumerable in ascending order, then I must be enumerable given NULL. For example, if I choose to regard NULL as implying ascending order, and I am only enumerable in descending order, then given NULL, I may blast even though there is an order in which I am enumerable. 
	
	In fact, right now the ability to respond to an 'order' argument is in such a to-be-implemented state that it should only be considered safe to provide a NULL argument, unless the documentation on a particular space or region says otherwise. 
	
	The eventual specification of this message is clear, and is upwards compatible from the current behavior: If I can enumerate in an order consistent with 'order', do so. If 'order' is NULL, then if I can be enumerated at all (if there is any counting sequence), then I still do so. For example, I should be able to get an (infinite) stepper for stepping through all the integers, but not all the reals. As the above example shows, being enumerable doesn't imply being finite.  
	
	Also, being able to produce a stepper that continues to yield more positions in the specified order is not sufficient to imply being enumerable.  To be enumerable, it must be the case that any given position which is a member of the region will eventually be reached by the stepper.  Not all implementations currently succeed in guaranteeing this (See UnionCrossRegion::isEnumerable).
	
	See ScruTable::stepper."

	| ord {OrderSpec | NULL} |
	ord := order.
	ord == NULL ifTrue:
		[ord := self coordinateSpace fetchAscending].
	ord == NULL ifTrue:
		[Heaper BLAST: #NotEnumerable].
	^self actualStepper: ord!

{Position CLIENT} theOne
	"Iff I contain exactly one position, return it.  Otherwise BLAST. The idea for this message is taken from the THE function of ONTIC (reference McAllester)"
	
	| stepper {Stepper} result {Position} |
	(self isFinite and: [self count == 1]) ifFalse:
		[ Heaper BLAST: #NotOneElement ].
	stepper _ self stepper.
	result _ stepper fetch cast: Position.
	stepper destroy.
	^ result! !

!XnRegion methodsFor: 'smalltalk: special'!

{void} do: aBlock {BlockClosure of: Position}

	self stepper forEach: aBlock! !

!XnRegion methodsFor: 'protected: enumerating'!

{Stepper of: Position} actualStepper: order {OrderSpec} 
	"Only called if I've already said I'm enumerable in the originally stated order.  Also, if the originally stated order was NULL, I get a guaranteed non-null order.  Subclasses which override 'stepper' to a method which doesn't send 'actualStepper' may override 'actualStepper' to a stub method which always BLASTs."

	self subclassResponsibility! !

!XnRegion methodsFor: 'smalltalk: passe'!

{PtrArray of: Position} asArray: order {OrderSpec default: NULL}
	"Returns all the Positions in the region in order according to 'order'.  If the region isn't finite, then this BLASTs."
	self passe
	"| result {PtrArray of: Position} i {Int32} |
	self isFinite not ifTrue:
		[Heaper BLAST: #NotFinite].
	result := PtrArray make: self count DOTasLong.
	i := Int32Zero.
	(self stepper: order) forEach: [:pos {Position} |
		result at: i store: pos.
		i := i + 1].
	(self count == i) assert: 'My stepper must yield same count of positions that I report'.
	^result"!

{BooleanVar} isEnumerable: order {OrderSpec default: NULL}
	"See comment in XuRegion::stepper.  
	a->stepper(os) won't BLAST iff a->isEnumerable(os)"
	
	self subclassResponsibility! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

XnRegion class
	instanceVariableNames: ''!

(XnRegion getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; yourself)!

!XnRegion class methodsFor: 'pseudo constructors'!

{ImmuSet} immuSet.make: region {XnRegion}
	"Make a set containing all the positions in the region"
	
	region isFinite ifFalse:
		[Heaper BLAST: #MustBeFinite].
	^(MuSet fromStepper: region stepper) asImmuSet! !

!XnRegion class methodsFor: 'smalltalk: system'!

info.stProtocol
"{Position CLIENT} chooseOne: order {OrderSpec default: NULL}
{XuRegion CLIENT} complement
{CoordinateSpace CLIENT} coordinateSpace
{IntegerVar CLIENT} count
{BooleanVar CLIENT} hasMember: atPos {Position unused}
{XuRegion CLIENT} intersect: other {XuRegion unused}
{BooleanVar CLIENT} intersects: other {XuRegion}
{BooleanVar CLIENT} isEmpty
{BooleanVar CLIENT} isFinite
{BooleanVar CLIENT} isFull
{BooleanVar CLIENT} isSubsetOf: other {XuRegion}
{XuRegion CLIENT} minus: other {XuRegion}
{Stepper CLIENT of: Position} stepper: order {OrderSpec default: NULL}
{Position CLIENT} theOne
{XuRegion CLIENT} unionWith: other {XuRegion unused}
{XuRegion CLIENT} with: pos {Position}
{XuRegion CLIENT} without: pos {Position}
"! !XnRegion subclass: #CrossRegion
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Cross'!
CrossRegion comment:
'A cross region is a distinction if 1) it is empty, 2) it is full, or 3) it is the rectangular cross of full regions and one distinction. Note that case 3 actually subsumes 1 and 2.  Since the simple regions of a space are the intersections of a finite number of distinctions of a space, this implies that A cross region is simple if it is the rectangular cross of simple regions.  In other words, a simple region is identical to the cross of its projections.'!

(CrossRegion getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; yourself)!

!CrossRegion methodsFor: 'testing'!

{UInt32} actualHashForEqual
	"To avoid overly burdensome canonicalization rules, my hash is calculated from the hash of my projections"
	
	^#cat.U.CrossRegion hashForEqual bitXor: self projections contentsHash.!

{BooleanVar} hasMember: atPos {Position unused} 

	self subclassResponsibility!

{BooleanVar} isEmpty

	self subclassResponsibility!

{BooleanVar} isEnumerable: order {OrderSpec unused default: NULL}
	
	self subclassResponsibility!

{BooleanVar} isEqual: other {Heaper}
	
	self subclassResponsibility!

{BooleanVar} isFinite

	self subclassResponsibility!

{BooleanVar} isSimple
	
	self subclassResponsibility! !

!CrossRegion methodsFor: 'enumerating'!

{Stepper CLIENT of: CrossRegion} boxes
	"Essential. Divide this Region up into a disjoint sequence of boxes. A box is a region which is the cross of its projections."
	
	self subclassResponsibility!

{IntegerVar} count
	
	self subclassResponsibility!

{ScruSet of: XnRegion} distinctions

	self subclassResponsibility!

{BooleanVar CLIENT} isBox
	"Whether this Region is a box, i.e. is equal to the cross of its projections."
	
	self subclassResponsibility!

{Stepper} simpleRegions: order {OrderSpec default: NULL} 

	self subclassResponsibility! !

!CrossRegion methodsFor: 'operations'!

{XnRegion} asSimpleRegion

	self subclassResponsibility!

{XnRegion} complement

	self subclassResponsibility!

{XnRegion} intersect: other {XnRegion unused} 

	self subclassResponsibility!

{XnRegion} simpleUnion: other {XnRegion} 
	
	^(self unionWith: other) asSimpleRegion!

{XnRegion} unionWith: other {XnRegion unused} 

	self subclassResponsibility! !

!CrossRegion methodsFor: 'accessing'!

{CoordinateSpace} coordinateSpace
	
	self subclassResponsibility!

{XnRegion CLIENT} projection: index {Int32}
	"The answer is the projection of this region into the specified dimension of the cross space"
	
	^(self projections fetch: index) cast: XnRegion!

{PtrArray CLIENT of: XnRegion} projections
	"Essential.  The answer is the projection of this region into each dimension of the cross space. Note that two regions which are different can have the same projections."
	
	self subclassResponsibility! !

!CrossRegion methodsFor: 'protected: enumerating'!

{Stepper of: Position} actualStepper: order {OrderSpec} 

	self subclassResponsibility! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

CrossRegion class
	instanceVariableNames: ''!

(CrossRegion getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; yourself)!

!CrossRegion class methodsFor: 'smalltalk: system'!

info.stProtocol
"{Stepper CLIENT of: CrossRegion} boxes
{BooleanVar CLIENT} isBox
{XuRegion CLIENT} projection: index {Int32}
{PtrArray CLIENT of: XuRegion} projections
"! !CrossRegion subclass: #GenericCrossRegion
	instanceVariableNames: '
		mySpace {CrossSpace}
		myCount {Int32}
		myRegions {PtrArray of: XnRegion}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Cross'!
GenericCrossRegion comment:
'Represents a region as a two-dimensional array of crosses of subregions.
 Was NOT.A.TYPE but that obstructed compilation.
I think this might work better if the array is lexically sorted, but I am not sure there is any meaningful way to do so. Thus there is no sorting assumed in the algorithms, although the protocol may occasionally suggest that there might be.

Eventually this implementation may save space by using NULL to represent repetitions of a sub region such that
	fetchBoxProjection (box, dim) == NULL
only if
	box > 0
	&& boxProjection (box, dim)->isEqual (boxProjection (box - 1, dim))
	&& (dim == 0
		|| fetchBoxProjection (box, dim - 1) == NULL)'!

(GenericCrossRegion getOrMakeCxxClassDescription)
	friends:
'friend class BoxAccumulator;
friend class BoxProjectionStepper;
friend class BoxStepper;
friend class GenericCrossDsp;
friend class GenericCrossSpace;
friend class CrossOrderSpec;
';
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!GenericCrossRegion methodsFor: 'accessing'!

{CoordinateSpace} coordinateSpace

	^mySpace!

{IntegerVar} count

	| result {IntegerVar} boxes {BoxStepper} |
	result := IntegerVarZero.
	boxes := self boxStepper.
	[boxes hasValue] whileTrue:
		[ | sub {IntegerVar} |
		sub := 1.
		boxes projectionStepper forEach: [ :proj {XnRegion} |
			sub := sub * proj count].
		result := result + sub.
		boxes step].
	boxes destroy.
	^result!

{XnRegion} projection: index {Int32}

	| result {XnRegion} boxes {BoxStepper} |
	myCount = 1 ifTrue: [^self boxProjection: Int32Zero with: index].
	result := (mySpace axis: index) emptyRegion.
	boxes := self boxStepper.
	[boxes hasValue] whileTrue:
		[result := result unionWith: (boxes projection: index).
		boxes step].
	boxes destroy.
	^result!

{PtrArray of: XnRegion} projections

	| result {PtrArray of: XnRegion} boxes {BoxStepper} |
	result := PtrArray nulls: mySpace axisCount.
	UInt32Zero almostTo: result count do: [ :i {UInt32} |
		result at: i store: (mySpace axis: i) emptyRegion].
	boxes := self boxStepper.
	[boxes hasValue] whileTrue:
		[boxes unionBoxInto: result with: Int32Zero.
		boxes step].
	boxes destroy.
	^result!

{Position} theOne

	| result {PtrArray of: Position} |
	myCount = 1 ifFalse: [Heaper BLAST: #MustHaveSingleElement].
	result := PtrArray nulls: mySpace axisCount.
	Int32Zero almostTo: result count do: [ :i {Int32} |
		result at: i store: (self boxProjection: Int32Zero with: i) theOne].
	^mySpace crossOfPositions: result! !

!GenericCrossRegion methodsFor: 'protected:'!

{CrossSpace} crossSpace

	^mySpace! !

!GenericCrossRegion methodsFor: 'private:'!

{Int32} boxCount

	^myCount!

{XnRegion} boxProjection: box {Int32} with: dimension {Int32}
	"A region is at a given 2D place in the array"
	
	^(myRegions fetch: box * self crossSpace axisCount + dimension) cast: XnRegion!

{BoxProjectionStepper} boxProjectionStepper
	"A stepper over all projections of all boxes in the region"
	
	^BoxProjectionStepper make: self!

{BoxStepper} boxStepper
	"A stepper over all boxes"
	
	^BoxStepper make: self!

{BooleanVar} hasBoxProjection: other {XnRegion}
	with: box {Int32} with: dimension {Int32}
	"Whether a region is at a given 2D place in the array. Searches forward and backward through adjacent boxes which have the same hash value"
	
	| index {Int32} hash {UInt32} sub {XnRegion} |
	index := box.
	hash := other hashForEqual.
	[index >= Int32Zero and: [(sub := self boxProjection: index with: dimension) hashForEqual = hash]] whileTrue:
		[(sub isEqual: other) ifTrue:
			[^true].
		index := index - 1].
	index := box + 1.
	[index < myCount and: [(sub := self boxProjection: index with: dimension) hashForEqual = hash]] whileTrue:
		[(sub isEqual: other) ifTrue:
			[^true].
		index := index + 1].
	^false!

{PtrArray of: XnRegion} secretRegions
	"The array holding the regions. DO NOT MODIFY"
	
	^myRegions! !

!GenericCrossRegion methodsFor: 'testing'!

{UInt32} actualHashForEqual

	| result {UInt32} boxes {BoxStepper} |
	result := self getCategory hashForEqual.
	boxes := self boxStepper.
	[boxes hasValue] whileTrue:
		[result := result bitXor: boxes boxHash.
		boxes step].
	boxes destroy.
	^result!

{BooleanVar} hasMember: position {Position}

	| boxes {BoxStepper} |
	boxes := self boxStepper.
	[boxes hasValue] whileTrue:
		[(boxes boxHasMember: (position cast: ActualTuple)) ifTrue:
			[^true].
		boxes step].
	^false!

{BooleanVar} intersects: other {XnRegion}

	| mine {BoxStepper} others {BoxStepper} |
	mine := self boxStepper.
	[mine hasValue] whileTrue:
		[others := (other cast: GenericCrossRegion) boxStepper.
		[others hasValue] whileTrue:
			[(mine boxIntersects: others) ifTrue:
				[^true].
			others step].
		mine step].
	mine destroy.
	others destroy.
	^false!

{BooleanVar} isDistinction

	myCount > 1 ifTrue: [^false].
	myCount == Int32Zero ifTrue: [^true].
	self boxProjectionStepper forEach: [ :proj {XnRegion} |
		proj isDistinction ifFalse:
			[^false]].
	^true!

{BooleanVar} isEmpty

	^myCount == Int32Zero!

{BooleanVar} isEnumerable: order {OrderSpec unused default: NULL}
	
	Someone shouldImplement.
	^false "fodder"!

{BooleanVar} isEqual: other {Heaper}

	other cast: GenericCrossRegion into: [ :cross | | boxes {BoxStepper} |
		(cross boxCount = myCount and: [cross crossSpace isEqual: self crossSpace])
			ifFalse: [^false].
		boxes := self boxStepper.
		[boxes hasValue] whileTrue:
			[(boxes isBoxOf: cross) ifFalse:
				[^false].
			boxes step].
		boxes destroy.
		^true]
	others:
		[^false].
	^ false "compiler fodder"!

{BooleanVar} isFinite

	self boxProjectionStepper forEach: [ :sub {XnRegion} |
		sub isFinite ifFalse:
			[^false]].
	^true!

{BooleanVar} isFull

	myCount = 1 ifFalse: [^false].
	self boxProjectionStepper forEach: [ :sub {XnRegion} |
		sub isFull ifFalse: [^false]].
	^true!

{BooleanVar} isSimple

	myCount > 1 ifTrue: [^false].
	myCount == Int32Zero ifTrue: [^true].
	self boxProjectionStepper forEach: [ :proj {XnRegion} |
		proj isSimple ifFalse: [^false]].
	^true!

{BooleanVar} isSubsetOf: other {XnRegion}

	Ravi thingToDo. "figure out a more efficient algorithm - the one commented out below doesn't work"
	^super isSubsetOf: other
	"| others {BoxStepper} mine {BoxStepper} |
	others := other boxStepper.
	[others hasValue] whileTrue:
		[mine := self boxStepper.
		[mine hasValue] whileTrue:
			[(others boxIsSubsetOf: mine) ifFalse:
				[^false].
			mine step].
		others step].
	^true"! !

!GenericCrossRegion methodsFor: 'operations'!

{XnRegion} asSimpleRegion

	| result {PtrArray} projections {BoxProjectionStepper} |
	self isEmpty ifTrue: [^self].
	result := PtrArray nulls: mySpace axisCount.
	projections := self boxProjectionStepper.
	[projections hasValue] whileTrue:
		[(result fetch: projections dimension) == NULL ifTrue:
			[result at: projections dimension store: projections projection asSimpleRegion]
		ifFalse:
			[result at: projections dimension
				store: (((result fetch: projections dimension) cast: XnRegion) simpleUnion: projections projection)].
		projections step].
	projections destroy.
	^mySpace crossOfRegions: result!

{XnRegion} complement

	| result {XnRegion} boxes {BoxStepper} |
	self isEmpty ifTrue:
		[^mySpace fullRegion].
	boxes := self boxStepper.
	result := boxes boxComplement.
	boxes step.
	[boxes hasValue] whileTrue:
		[result := result intersect: boxes boxComplement.
		boxes step].
	boxes destroy.
	^result!

{XnRegion} intersect: region {XnRegion}

	region cast: GenericCrossRegion into: [ :other |
		| result {BoxAccumulator} smaller {GenericCrossRegion} larger {GenericCrossRegion}
		  bits {BoxStepper} piece {BoxAccumulator} |
		self boxCount < other boxCount
			ifTrue: [smaller := self. larger := other]
			ifFalse: [smaller := other. larger := self].
		smaller isEmpty
			ifTrue: [^smaller].
		bits := smaller boxStepper.
		result := NULL.
		piece := BoxAccumulator make: larger.
		[bits hasValue] whileTrue:
			[piece intersectWithBox: bits.
			result == NULL
				ifTrue: [result := piece]
				ifFalse: [result addAccumulatedBoxes: piece].
			bits step.
			bits hasValue
				ifTrue: [piece := BoxAccumulator make: larger]].
		bits destroy.
		result mergeBoxes.
		result removeDeleted.
		^result region].
	^ NULL "compiler fodder"!

{XnRegion} unionWith: region {XnRegion}

	| result {BoxAccumulator} |
	region cast: GenericCrossRegion into: [ :other |
		| stepper {BoxStepper} |
		result := BoxAccumulator make: self.
		stepper := other boxStepper.
		result unionWithBoxes: stepper.
		stepper destroy.
		result mergeBoxes.
		result removeDeleted.
		^result region].
	^ NULL "compiler fodder"! !

!GenericCrossRegion methodsFor: 'printing'!

{void} printOn: oo {ostream reference}

	| boxes {BoxStepper} between {char star} |
	oo << '{'.
	boxes := self boxStepper.
	[boxes hasValue] whileTrue:
		[between := ''.
		boxes projectionStepper forEach: [ :proj {XnRegion} |
			oo << between.
			proj isFull
				ifTrue: [oo << '*']
				ifFalse: [oo << proj].
			between := ' x '].
		boxes step.
		boxes hasValue ifTrue:
			[oo << ', ']].
	boxes destroy.
	oo << '}'! !

!GenericCrossRegion methodsFor: 'enumerating'!

{Stepper of: CrossRegion} boxes

	^self boxStepper!

{ScruSet of: XnRegion} distinctions

	| result {Accumulator} ps {BoxProjectionStepper} |
	self isSimple ifFalse:
		[Heaper BLAST: #MustBeSimple].
	result := SetAccumulator make.
	ps := self boxProjectionStepper.
	ps forEach: [ :sub {XnRegion} |
		sub distinctions stepper forEach: [ :dist {XnRegion} |
			result step: (mySpace extrusion: ps dimension with: dist)]].
	^result value cast: ScruSet!

{BooleanVar} isBox

	^self isSimple!

{Stepper} simpleRegions: order {OrderSpec default: NULL} 

	order ~~ NULL ifTrue: [self unimplemented].
	^GenericCrossSimpleRegionStepper make: mySpace with: self boxStepper! !

!GenericCrossRegion methodsFor: 'protected: enumerating'!

{Stepper of: Position} actualStepper: order {OrderSpec unused} 

	self isEmpty ifTrue: [^Stepper emptyStepper].
	Ravi thingToDo. "do a real stepper"
	self hack.
	^Stepper itemStepper: self theOne! !

!GenericCrossRegion methodsFor: 'protected: create'!

create: space {CrossSpace} with: count {Int32} with: regions {PtrArray of: XnRegion}

	super create.
	mySpace := space.
	myCount := count.
	myRegions := regions.! !

!GenericCrossRegion methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	mySpace _ receiver receiveHeaper.
	myCount _ receiver receiveInt32.
	myRegions _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: mySpace.
	xmtr sendInt32: myCount.
	xmtr sendHeaper: myRegions.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

GenericCrossRegion class
	instanceVariableNames: ''!

(GenericCrossRegion getOrMakeCxxClassDescription)
	friends:
'friend class BoxAccumulator;
friend class BoxProjectionStepper;
friend class BoxStepper;
friend class GenericCrossDsp;
friend class GenericCrossSpace;
friend class CrossOrderSpec;
';
	attributes: ((Set new) add: #CONCRETE; add: #COPY; yourself)!

!GenericCrossRegion class methodsFor: 'private: pseudo constructors'!

{CrossRegion} empty: space {GenericCrossSpace}

	^self create: space with: Int32Zero with: PtrArray empty!

{CrossRegion} full: space {GenericCrossSpace}
	with: subSpaces {PtrArray of: CoordinateSpace}
	"Only used during construction; must pass the array in explicitly since the space isnt initialized yet"

	| result {PtrArray of: XnRegion} |
	result := PtrArray nulls: subSpaces count.
	Int32Zero almostTo: result count do: [ :dimension {Int32} |
		result at: dimension store: ((subSpaces fetch: dimension) cast: CoordinateSpace) fullRegion].
	^self create: space with: 1 with: result! !

!GenericCrossRegion class methodsFor: 'create'!

make: space {CrossSpace} with: count {Int32} with: regions {PtrArray of: XnRegion}
	^ self create: space with: count with: regions! !XnRegion subclass: #Filter
	instanceVariableNames: 'myCS {FilterSpace}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Filter'!
Filter comment:
'A position in a FilterSpace is a region in the baseSpace, and a filter is a set of regions in the baseSpace. It is often more useful to think of a Filter as a Boolean function whose input is a region in the baseSpace, and of unions, intersections, and complements of filters as ORs, ANDs, and NOTs of functions. Not all possible such functions can be represented as Filters, since there is an uncountable infinity of them for any non-finite CoordinateSpace. There are representations for some basic filters, and any filters resulting from a finite sequence of unions, intersections, and complements among them. The basic filters are:
	subsetFilter(cs,R) -- all subsets of R (i.e. all R1 such that R1->isSubsetOf(R))
	supersetFilter(cs,R) -- all supersets of R (i.e. all R1 such that R->isSubsetOf(R1))
Mathematically, this is all that is necessary, since other useful filters like intersection filters can be generated from these. (e.g. intersectionFilter(R) is subsetFilter(R->complement())->complement()). However, there are several more pseudo constructors provided as shortcuts, including intersectionFilters, closedFilters, emptyFilters, and intersections and unions of sets of filters.'!

(Filter getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; add: #COPY; yourself)!

!Filter methodsFor: 'operations'!

{XnRegion} complement
	
	self subclassResponsibility!

{XnRegion} intersect: other {XnRegion}

	| result {XnRegion} |
	result := self fetchIntersect: other.
	result ~~ NULL ifTrue: [^result].
	^self complexIntersect: other!

{XnRegion INLINE} simpleUnion: other {XnRegion}

	^self unionWith: other!

{XnRegion} unionWith: other {XnRegion}

	| result {XnRegion} |
	result := self fetchUnion: other.
	result ~~ NULL ifTrue: [^result].
	^self complexUnion: other! !

!Filter methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^Heaper takeOop!

{BooleanVar} hasMember: pos {Position}

	^self match: (pos cast: FilterPosition) baseRegion!

{BooleanVar CLIENT} isAllFilter
	"Essential. Whether this is an 'all' Filter, i.e. it only matches Regions which contain everything in the baseRegion"
	
	self subclassResponsibility!

{BooleanVar CLIENT} isAnyFilter
	"Essential. Whether this is an 'any' Filter, i.e. it matches Regions which contain anything in the baseRegion"
	
	self subclassResponsibility!

{BooleanVar} isEmpty

	self subclassResponsibility!

{BooleanVar} isEnumerable: order {OrderSpec default: NULL}
	
	self knownBug. "The singleton region should act enumerably"
	^false!

{BooleanVar} isEqual: other {Heaper}

	self subclassResponsibility!

{BooleanVar INLINE} isFinite

	^false!

{BooleanVar} isFull	

	self subclassResponsibility!

{BooleanVar INLINE} isSimple
	^true!

{BooleanVar} isSubsetOf: other {XnRegion}
	| o {Filter} |
	o _ other cast: Filter.
	(self fetchSpecialSubset: o) == self ifTrue: [^true].
	(o fetchSpecialSubset: self) == self ifTrue: [^true].
	^(self intersects: (o complement)) not! !

!Filter methodsFor: 'enumerating'!

{IntegerVar} count
	self unimplemented.
	^IntegerVar0!

{Stepper CLIENT of: Filter} intersectedFilters
	"Essential. Break this up into a bunch of Filters which when intersected (anded) together give this one. If there is only one sub Filter it will be the receiver; otherwise, the sub Filters will be simple enough that either they or their complements will return true from at least one of isAndFilter or isOrFilter. If this is full (i.e. an open filter) then the stepper will have no elements."
	
	self subclassResponsibility!

{Stepper CLIENT of: Filter} unionedFilters
	"Essential. Break this up into a bunch of Filters which when unioned (ored) together give this one. If there is only one sub Filter it will be the receiver; otherwise, the sub Filters will be simple enough that either they or their complements will return true from at least one of isAndFilter or isOrFilter. The sub Filters might not be disjoint Regions. If this is empty (i.e. a closed filter) then the stepper will have no elements."
	
	self subclassResponsibility! !

!Filter methodsFor: 'accessing'!

{XnRegion INLINE} asSimpleRegion

	^self!

{XnRegion CLIENT} baseRegion
	"Essential. A region in the base space identifying what kind of filter this is. Succeeds only if this isAnyFilter or isAllFilter."
	
	self subclassResponsibility!

{CoordinateSpace INLINE} coordinateSpace

	^myCS!

{XnRegion} relevantRegion
	"The region which is relevant to this filter, i.e. whose presence or absence in a region can change whether it passes the filter"
	
	self subclassResponsibility! !

!Filter methodsFor: 'filtering'!

{BooleanVar} doesPass: joint {Joint}
	"Whether there might be anything in the tree beneath the Joint that would pass the filter."

	^(self pass: joint) isEmpty not!

{BooleanVar} isSwitchedBy: delta {RegionDelta}
	"Whether the change causes a change in the state of the filter. (I.E. Whether the old region was in and the new out, or vice versa.)"
	
	^(self match: delta before) ~~ (self match: delta after)!

{BooleanVar} isSwitchedOffBy: delta {RegionDelta}
	"Whether the change switches the state of the filter from on to off. (I.E. Whether the old region was inside the filter and the new region outside.)"
	
	^(self match: delta before) and: [(self match: delta after) not]!

{BooleanVar} isSwitchedOnBy: delta {RegionDelta}
	"Whether the change switches the state of the filter from off to on. (I.E. Whether the old region was outside the filter and the new region inside.)"
	
	^(self match: delta before) not and: [self match: delta after]!

{BooleanVar CLIENT} match: region {XnRegion}
	"Whether a region is inside this filter."
	
	self subclassResponsibility!

{Filter} pass: parent {Joint}
	"The simplest filter for looking at the tree beneath the node.
	The Joint keeps the intersection and union of all the nodes beneath it, so the result of this message can be used to prune a search. If the result is full, then everything beneath the node is in the filter (e.g. if this filter contained all subsets of S and the union was a superset of S). If the result is empty, then nothing beneath the node is in the filter (e.g. if this filter contained all subsets of S and the intersection was not a subset of S). In less extreme cases, this operation may at least simplify the filter by throwing out irrelevant search criteria."
	
	self subclassResponsibility! !

!Filter methodsFor: 'creation'!

create: cs {FilterSpace}
	super create.
	myCS _ cs! !

!Filter methodsFor: 'components'!

{ScruSet of: XnRegion} distinctions

	self isFull
		ifTrue: [^ImmuSet make]
		ifFalse: [^ImmuSet make with: self]!

{Stepper} simpleRegions: order {OrderSpec unused default: NULL}

	self isEmpty
		ifTrue: [^ImmuSet make stepper]
		ifFalse: [^(ImmuSet make with: self) stepper]! !

!Filter methodsFor: 'vulnerable: internal'!

{XnRegion} complexIntersect: other {XnRegion}
	| a {Filter} b {Filter} canon {Pair of: Filter} |
	(self isKindOf: OrFilter)
		ifTrue: [a _ self. b _ other cast: Filter]
		ifFalse: [b _ self. a _ other cast: Filter].
	(a isKindOf: OrFilter) ifTrue:
		[(b isKindOf: OrFilter)
			ifTrue: [^Filter orFilterPrivate: myCS
				with: (Filter distributeIntersect: self coordinateSpace
					with: (a cast: OrFilter) subFilters
					with.ImmuSet: (b cast: OrFilter) subFilters)]
			ifFalse: [^Filter orFilterPrivate: myCS
				with: (Filter distributeIntersect: self coordinateSpace
					with: (a cast: OrFilter) subFilters
					with.Filter: b)]].
	(a isKindOf: AndFilter)
		ifFalse: [ | t {Filter} | t _ a. a _ b. b _ t].
	(a isKindOf: AndFilter) ifTrue:
		[(b isKindOf: AndFilter)
			ifTrue: [^Filter andFilterPrivate: myCS
				with: (Filter combineIntersect: (a cast: AndFilter) subFilters
					with.ImmuSet:  (b cast: AndFilter) subFilters)].
		^Filter andFilterPrivate: myCS
				with: (Filter combineIntersect: (a cast: AndFilter) subFilters
					with.Filter:  b)].
	canon _ self getPairIntersect: (other cast: Filter).
	^Filter andFilterPrivate: myCS
			with: ((ImmuSet make with: canon left) with: canon right)!

{XnRegion} complexUnion: other {XnRegion}
	| a {Filter} b {Filter} canon {Pair of: Filter} |
	(self isKindOf: OrFilter)
		ifTrue: [a _ self. b _ other cast: Filter]
		ifFalse: [b _ self. a _ other cast: Filter].
	(a isKindOf: OrFilter) ifTrue:
		[(b isKindOf: OrFilter)
			ifTrue: [^Filter orFilterPrivate: myCS
				with: (Filter combineUnion: (a cast: OrFilter) subFilters
					with.ImmuSet:  (b cast: OrFilter) subFilters)].
		(b isKindOf: AndFilter)
			ifTrue: [^Filter orFilterPrivate: myCS
				with: (Filter distributeUnion: self coordinateSpace
					with: (b cast: AndFilter) subFilters
					with.ImmuSet:  (a cast: OrFilter) subFilters)].
		^Filter orFilterPrivate: myCS
				with: (Filter combineUnion: (a cast: OrFilter) subFilters
					with.Filter:  b)].
	(a isKindOf: AndFilter) ifFalse:
		[ | t {Filter} | t _ a. a _ b. b _ t].
	(a isKindOf: AndFilter) ifTrue:
		[^Filter orFilterPrivate: myCS
			with: (Filter distributeUnion: self coordinateSpace
				with: (a cast: AndFilter) subFilters
				with.Filter: b)].
	canon _ self getPairUnion: (other cast: Filter).
	^Filter orFilterPrivate: myCS
		with: ((ImmuSet make with: canon left) with: canon right)!

{Pair of: Filter} fetchCanonicalIntersect: other {Filter unused}
	"return NULL, or the pair of canonical filters (left == new1 | self, right == new2 | other)"
	^NULL!

{Pair of: Filter} fetchCanonicalUnion: other {Filter unused}
	"return NULL, or the pair of canonical filters (left == new1 | self, right == new2 | other)"
	^NULL!

{XnRegion} fetchIntersect: other {XnRegion}
	| temp {XnRegion} |
	temp _ self fetchSpecialSubset: other.
	temp == NULL ifTrue:
		[temp _ (other cast: Filter) fetchSpecialSubset: self].
	temp == self ifTrue: [^self].
	(temp basicCast: Heaper star) == other ifTrue: [^other].
	temp _ self fetchSpecialIntersect: other.
	temp ~~ NULL ifTrue: [^temp].
	^(other cast: Filter) fetchSpecialIntersect: self!

{Pair of: Filter} fetchPairIntersect: other {Filter}
	"return the pair of canonical filters (left == new1 | self, right == new2 | other)"
	| result {Pair of: Filter} |
	result _ self fetchCanonicalIntersect: other.
	result ~~ NULL ifTrue: [^result].
	result _ other fetchCanonicalIntersect: self.
	result ~~ NULL ifTrue: [^result reversed].
	^NULL!

{Pair of: Filter} fetchPairUnion: other {Filter}
	"return the pair of canonical filters (left == new1 | self, right == new2 | other)"
	| result {Pair of: Filter} |
	result _ self fetchCanonicalUnion: other.
	result ~~ NULL ifTrue: [^result].
	result _ other fetchCanonicalUnion: self.
	result ~~ NULL ifTrue: [^result reversed].
	^NULL!

{XnRegion} fetchSpecialIntersect: other {XnRegion unused}
	^NULL!

{XnRegion} fetchSpecialSubset: other {XnRegion}
	"return self or other if one is clearly a subset of the other, else NULL"
	self subclassResponsibility!

{XnRegion} fetchSpecialUnion: other {XnRegion unused}
	^NULL!

{XnRegion} fetchUnion: other {XnRegion}
	| temp {XnRegion} |
	temp _ self fetchSpecialSubset: other.
	temp == NULL ifTrue:
		[temp _ (other cast: Filter) fetchSpecialSubset: self].
	temp == self ifTrue: [^other].
	(temp basicCast: Heaper star) == other ifTrue: [^self].
	temp _ self fetchSpecialUnion: other.
	temp ~~ NULL ifTrue: [^temp].
	^(other cast: Filter) fetchSpecialUnion: self!

{Pair of: Filter} getPairIntersect: other {Filter}
	"return the pair of canonical filters (left == new1 | self, right == new2 | other)"
	| result {Pair of: Filter} |
	result _ self fetchCanonicalIntersect: other.
	result ~~ NULL ifTrue: [^result].
	result _ other fetchCanonicalIntersect: self.
	result ~~ NULL ifTrue: [^result reversed].
	^Pair make: self with: other!

{Pair of: Filter} getPairUnion: other {Filter}
	"return the pair of canonical filters (left == new1 | self, right == new2 | other)"
	| result {Pair of: Filter} |
	result _ self fetchCanonicalUnion: other.
	result ~~ NULL ifTrue: [^result].
	result _ other fetchCanonicalUnion: self.
	result ~~ NULL ifTrue: [^result reversed].
	^Pair make: self with: other! !

!Filter methodsFor: 'protected: enumerating'!

{Stepper of: Position} actualStepper: order {OrderSpec} 
	
	Ravi shouldImplement.
	^NULL "fodder"! !

!Filter methodsFor: 'protected:'!

{FilterSpace INLINE} filterSpace

	^myCS! !

!Filter methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myCS _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myCS.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Filter class
	instanceVariableNames: ''!

(Filter getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #ON.CLIENT; add: #DEFERRED; add: #COPY; yourself)!

!Filter class methodsFor: 'pseudo constructors'!

{Filter} andFilter: cs {CoordinateSpace} with: subs {ScruSet of: Filter}
	"A filter that matches only regions that all of the filters in the set would have matched."
	
	| result {ImmuSet} |
	result _ ImmuSet make.
	subs stepper forEach: [ :sub {Filter} |
		sub
			cast: ClosedFilter into: [:cSub |
				^Filter closedFilter: cs]
			cast: AndFilter into: [:aSub |
				result _ self combineIntersect: result
					with.ImmuSet: aSub subFilters]
			cast: OpenFilter into: [:oSub | ]
			others:
				[result _ self combineIntersect: result
					with.Filter: sub]].
	^Filter andFilterPrivate: (cs cast: FilterSpace) with: result!

{Filter} closedFilter: cs {CoordinateSpace}
	"An filter that does match any region."
	
	^ClosedFilter create: (cs cast: FilterSpace)!

{Filter} intersectionFilter: cs {CoordinateSpace} with: region {XnRegion}
	"A filter that matches any region that intersects the given region."
	
	^NotSubsetFilter create: (cs cast: FilterSpace) with: region complement!

{Filter} notSubsetFilter: cs {CoordinateSpace} with: region {XnRegion}
	"A filter matching any regions that is not a subset of the given region."
	
	region isFull ifTrue: [^Filter closedFilter: cs].
	^NotSubsetFilter create: (cs cast: FilterSpace) with: region!

{Filter} notSupersetFilter: cs {CoordinateSpace} with: region {XnRegion}
	"A filter that matches any region that is not a superset of the given region."
	
	region isEmpty ifTrue: [^Filter closedFilter: cs].
	^NotSupersetFilter create: (cs cast: FilterSpace) with: region!

{Filter} openFilter: cs {CoordinateSpace}
	"A filter that matches any region."
	
	^OpenFilter create: (cs cast: FilterSpace)!

{Filter} orFilter: cs {CoordinateSpace} with: subs {ScruSet of: Filter}
	"A filter that matches any region that any of the filters in the set would have matched."
	
	| result {ImmuSet of: Filter} |
	result _ ImmuSet make.
	subs stepper forEach: [ :sub {Filter} |
		sub
			cast: OpenFilter into: [:oSub |
				^Filter openFilter: cs]
			cast: OrFilter into: [:orSub |
				result _ self combineUnion: result
					with.ImmuSet: orSub subFilters]
			cast: ClosedFilter into: [:cSub | ]
			others:
				[result _ self combineUnion: result
					with.Filter: sub]].
	^Filter orFilterPrivate: (cs cast: FilterSpace) with: result!

{Filter} subsetFilter: cs {CoordinateSpace} with: region {XnRegion}
	"A filter that matches any region that is a subset of the given region."
	
	region isFull ifTrue: [^Filter openFilter: cs].
	^SubsetFilter create: (cs cast: FilterSpace) with: region!

{Filter} supersetFilter: cs {CoordinateSpace} with: region {XnRegion}
	"A region that matches any region that is a superset of the given region."
	
	region isEmpty ifTrue: [^Filter openFilter: cs].
	^SupersetFilter create: (cs cast: FilterSpace) with: region! !

!Filter class methodsFor: 'private: functions'!

{Filter} andFilterPrivate: cs {FilterSpace} with: subs {ImmuSet of: Filter}
	"assumes that the interactions between elements have already been removed"
	subs isEmpty ifTrue: [^Filter openFilter: cs].
	subs count = 1 ifTrue: [^subs theOne cast: Filter].
	^AndFilter create: cs with: subs!

{ImmuSet of: Filter} combineIntersect: set {ImmuSet of: Filter} with.Filter: filter {Filter}
	"keep going around doing intersections until there are no more special intersects"
	| subs {Stepper} nonspecial {MuSet of: Filter} result {SetAccumulator} test {Filter} |
	result _ SetAccumulator make.
	test _ filter.
	subs _ set stepper.
	nonspecial _ set asMuSet.
	[subs hasValue] whileTrue:
		[ | special {Filter} sub {Filter} |
		sub _ (subs fetch cast: Filter).
		subs step.
		special _ (sub fetchIntersect: test) cast: Filter.
		special ~~ NULL ifTrue:
			[test _ special.
			result _ SetAccumulator make.
			nonspecial remove: sub.
			subs _ nonspecial stepper]
		ifFalse:
			[ | canon {Pair of: Filter} |
			canon _ sub fetchPairIntersect: test.
			canon == NULL ifTrue:
				[result step: sub]
			ifFalse:
				[test _ canon right cast: Filter.
				nonspecial remove: sub.
				result _ SetAccumulator make.
				nonspecial _ (Filter combineIntersect: nonspecial asImmuSet
					with.Filter: (canon left cast: Filter)) asMuSet.
				subs _ nonspecial stepper]]].
	^(result value cast: ImmuSet) with: test!

{ImmuSet of: Filter} combineIntersect: a {ImmuSet of: Filter} with.ImmuSet: b {ImmuSet of: Filter}
	| result {ImmuSet of: Filter} |
	result _ a.
	b stepper forEach: [ :sub {Filter} |
		result _ self combineIntersect: result with.Filter: sub].
	^result!

{ImmuSet of: Filter} combineUnion: set {ImmuSet of: Filter} with.Filter: filter {Filter}
	"keep going around doing unions until there are no more special unions"
	| subs {Stepper} nonspecial {MuSet of: Filter} result {SetAccumulator} test {Filter} |
	result _ SetAccumulator make.
	test _ filter.
	subs _ set stepper.
	nonspecial _ set asMuSet.
	[subs hasValue] whileTrue:
		[ | special {Filter} sub {Filter} |
		sub _ (subs fetch cast: Filter).
		subs step.
		special _ (sub fetchUnion: test) cast: Filter.
		special ~~ NULL ifTrue:
			[test _ special.
			result _ SetAccumulator make.
			nonspecial remove: sub.
			subs _ nonspecial stepper]
		ifFalse:
			[ | canon {Pair of: Filter} |
			canon _ sub fetchPairUnion: test.
			canon == NULL ifTrue:
				[result step: sub]
			ifFalse:
				[test _ canon right cast: Filter.
				nonspecial remove: sub.
				result _ SetAccumulator make.
				nonspecial _ (Filter combineUnion: nonspecial asImmuSet
					with.Filter: (canon left cast: Filter)) asMuSet.
				subs _ nonspecial stepper]]].
	^(result value cast: ImmuSet) with: test!

{ImmuSet of: Filter} combineUnion: a {ImmuSet of: Filter} with.ImmuSet: b {ImmuSet of: Filter}
	| result {ImmuSet of: Filter} |
	result _ a.
	b stepper forEach: [ :sub {Filter} |
		result _ self combineUnion: result with.Filter: sub].
	^result!

{ImmuSet of: Filter} distributeIntersect: cs {CoordinateSpace} with: set {ImmuSet of: Filter} with.Filter: filter {Filter}
	"distribute the intersection of a filter with the union of a set of filters"
	| special {Filter} nonspecial {SetAccumulator of: Filter} |
	special _ Filter closedFilter: cs.
	nonspecial _ SetAccumulator make.
	set stepper forEach: [ :sub {Filter} | | quick {XnRegion} |
		quick _ sub fetchIntersect: filter.
		quick == NULL
			ifTrue: [nonspecial step: (sub complexIntersect: filter)]
			ifFalse: [special _ (special unionWith: quick) cast: Filter]].
	(nonspecial value cast: ImmuSet) isEmpty
		ifTrue: [^ImmuSet make with: special]
		ifFalse: [^(nonspecial value cast: ImmuSet) with: special]!

{ImmuSet of: Filter} distributeIntersect: cs {CoordinateSpace} 
	with: a {ImmuSet of: Filter} 
	with.ImmuSet: b {ImmuSet of: Filter}
	"distribute the intersection of two unions of sets of filters"
	| special {Filter} nonspecial {ImmuSet of: Filter} |
	special _ Filter closedFilter: cs.
	nonspecial _ ImmuSet make.
	a stepper forEach: [ :other {Filter} |
		b stepper forEach: [ :sub {Filter} | | intersection {XnRegion} |
			intersection _ sub fetchIntersect: other.
			intersection == NULL
				ifTrue: [nonspecial _ Filter combineUnion: nonspecial
					with.Filter: ((sub complexIntersect: other) cast: Filter)]
				ifFalse: [special _ (special unionWith: intersection) cast: Filter]]].
	^Filter combineUnion: nonspecial with.Filter: special!

{ImmuSet of: Filter} distributeUnion: cs {CoordinateSpace} with: set {ImmuSet of: Filter} with.Filter: filter {Filter}
	"distribute the union of a filter with the intersection of a set of filters"
	| special {Filter} nonspecial {ImmuSet of: Filter} |
	special _ Filter openFilter: cs.
	nonspecial _ ImmuSet make.
	set stepper forEach: [ :sub {Filter} | | quick {XnRegion} |
		quick _ sub fetchUnion: filter.
		quick == NULL
			ifTrue: [nonspecial _ Filter combineIntersect: nonspecial with.Filter: sub]
			ifFalse: [special _ (special intersect: quick) cast: Filter]].
	nonspecial isEmpty
		ifTrue: [^ImmuSet make with: special]
		ifFalse: [^(ImmuSet make
			with: (Filter andFilterPrivate: (cs cast: FilterSpace)
				with: (Filter combineIntersect: nonspecial with.Filter: special)))
			with: filter]!

{ImmuSet of: Filter} distributeUnion: cs {CoordinateSpace} with: anded {ImmuSet of: Filter} with.ImmuSet: ored {ImmuSet of: Filter}
	"distribute the union of an intersection and a union of sets of filters"
	| distributed {Filter} |
	distributed _ ored theOne cast: Filter.
	^self combineUnion: (self distributeUnion: cs with: anded with.Filter: distributed)
		with.ImmuSet: (ored without: distributed)!

{Filter} orFilterPrivate: cs {FilterSpace} with: subs {ImmuSet of: Filter}
	"assumes that the interactions between elements have already been removed"
	subs isEmpty ifTrue: [^Filter closedFilter: cs].
	subs count = 1 ifTrue: [^subs theOne cast: Filter].
	^OrFilter create: cs with: subs! !

!Filter class methodsFor: 'smalltalk: system'!

info.stProtocol
"{XnRegion CLIENT} baseRegion
{Stepper CLIENT of: Filter} intersectedFilters
{BooleanVar CLIENT} isAllFilter
{BooleanVar CLIENT} isAnyFilter
{BooleanVar CLIENT} match: region {XnRegion}
{Stepper CLIENT of: Filter} unionedFilters
"! !Filter subclass: #AndFilter
	instanceVariableNames: 'mySubFilters {ImmuSet of: Filter}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Filter'!

(AndFilter getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!AndFilter methodsFor: 'creation'!

create: cs {FilterSpace} with: subs {ImmuSet of: Filter}
	super create: cs.
	mySubFilters _ subs! !

!AndFilter methodsFor: 'filtering'!

{BooleanVar} match: region {XnRegion}
	"tell whether a region passes this filter"
	self subFilters stepper forEach: [ :sub {Filter} |
		(sub match: region)
			ifFalse: [^false]].
	^true!

{Filter} pass: parent {Joint}
	"return the simplest filter for looking at the children"
	| result {XnRegion} |
	result _ Filter openFilter: self coordinateSpace.
	self subFilters stepper forEach: [ :sub {Filter} |
		result _ result intersect: (sub pass: parent)].
	^result cast: Filter!

{ImmuSet of: Filter} subFilters
	^mySubFilters! !

!AndFilter methodsFor: 'printing'!

{void} printOn: oo {ostream reference}
	oo << self getCategory name.
	self subFilters printOnWithSimpleSyntax: oo with: '(' with: ' && ' with: ')'! !

!AndFilter methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^(self coordinateSpace hashForEqual bitXor: mySubFilters hashForEqual)
		bitXor: #cat.U.AndFilter hashForEqual!

{BooleanVar} isAllFilter

	^false!

{BooleanVar} isAnyFilter
	
	^false!

{BooleanVar} isEmpty
	^false!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: AndFilter into: [:af |
			^af subFilters isEqual: self subFilters]
		others: [^false].
	^false "fodder"!

{BooleanVar} isFull	

	^false! !

!AndFilter methodsFor: 'operations'!

{XnRegion} complement

	| result {XnRegion} |
	result _ Filter closedFilter: self coordinateSpace.
	self subFilters stepper forEach: [ :sub {XnRegion} |
		result _ result unionWith: sub complement].
	^result! !

!AndFilter methodsFor: 'protected operations'!

{XnRegion} fetchSpecialSubset: other {XnRegion}
	"return self or other if one is clearly a subset of the other, else NULL"
	| filter {Filter} defaultRegion {XnRegion} |
	filter _ other cast: Filter.
	defaultRegion _ other.
	self subFilters stepper forEach: [ :subfilter {Filter} | | a {XnRegion} b {XnRegion} |
		(a _ subfilter fetchSpecialSubset: filter) == subfilter ifTrue: [^self].
		(b _ filter fetchSpecialSubset: subfilter) == subfilter ifTrue: [^self].
		((a basicCast: Heaper star) == other or: [(b basicCast: Heaper star) == other]) ifFalse: [defaultRegion _ NULL]].
	^defaultRegion! !

!AndFilter methodsFor: 'enumerating'!

{Stepper of: Filter} intersectedFilters

	^mySubFilters stepper!

{Stepper of: Filter} unionedFilters

	^Stepper itemStepper: self! !

!AndFilter methodsFor: 'accessing'!

{XnRegion} baseRegion

	Heaper BLAST: #NotSimpleEnough.
	^NULL!

{XnRegion} relevantRegion

	| result {XnRegion} |
	result := self filterSpace baseSpace emptyRegion.
	mySubFilters stepper forEach: [ :sub {Filter} |
		result := result unionWith: sub relevantRegion].
	^result! !

!AndFilter methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	mySubFilters _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: mySubFilters.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AndFilter class
	instanceVariableNames: ''!

(AndFilter getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!AndFilter class methodsFor: 'pseudo constructors'!

{Filter} make: cs {FilterSpace} with: subs {ImmuSet of: Filter}
	"assumes that the interactions between elements have already been removed"
	
	subs isEmpty ifTrue: [^cs fullRegion cast: Filter].
	subs count = 1 ifTrue: [^subs theOne cast: Filter].
	^self create: cs with: subs! !Filter subclass: #ClosedFilter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Filter'!

(ClosedFilter getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!ClosedFilter methodsFor: 'creation'!

create: cs {FilterSpace}
	super create: cs! !

!ClosedFilter methodsFor: 'operations'!

{XnRegion} complement

	^Filter openFilter: self coordinateSpace!

{XnRegion} intersect: other {XnRegion unused}
	^self!

{XnRegion} minus: other {XnRegion unused}
	^self!

{XnRegion} unionWith: other {XnRegion}
	^other! !

!ClosedFilter methodsFor: 'filtering'!

{BooleanVar} match: region {XnRegion unused}
	"tell whether a region passes this filter"
	^false!

{Filter} pass: parent {Joint unused}
	"return the simplest filter for looking at the children"
	^self! !

!ClosedFilter methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^self coordinateSpace hashForEqual bitXor: #cat.U.ClosedFilter hashForEqual!

{BooleanVar} isAllFilter

	^false!

{BooleanVar} isAnyFilter
	
	^true!

{BooleanVar} isEmpty
	^true!

{BooleanVar} isEnumerable: order {OrderSpec default: NULL}
	
	^true!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: ClosedFilter into: [:cf |
			^cf coordinateSpace isEqual: self coordinateSpace]
		others: [^false].
	^false "fodder"!

{BooleanVar} isFull	

	^false! !

!ClosedFilter methodsFor: 'printing'!

{void} printOn: oo {ostream reference}
	oo << self getCategory name << '(' << self coordinateSpace << ')'! !

!ClosedFilter methodsFor: 'protected: protected operations'!

{XnRegion} fetchSpecialSubset: other {XnRegion unused}
	^self! !

!ClosedFilter methodsFor: 'protected: enumerating'!

{Stepper of: Position} actualStepper: order {OrderSpec} 
	
	^Stepper emptyStepper! !

!ClosedFilter methodsFor: 'enumerating'!

{Stepper of: Filter} intersectedFilters

	^Stepper itemStepper: self!

{Stepper of: Filter} unionedFilters

	^Stepper emptyStepper! !

!ClosedFilter methodsFor: 'accessing'!

{XnRegion} baseRegion

	^(self coordinateSpace cast: FilterSpace) emptyRegion!

{XnRegion} relevantRegion

	^self filterSpace baseSpace emptyRegion! !

!ClosedFilter methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ClosedFilter class
	instanceVariableNames: ''!

(ClosedFilter getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!ClosedFilter class methodsFor: 'pseudo constructors'!

{Filter} make: space {CoordinateSpace}

	^self create: (space cast: FilterSpace)! !Filter subclass: #NotSubsetFilter
	instanceVariableNames: 'myRegion {XnRegion}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Filter'!

(NotSubsetFilter getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!NotSubsetFilter methodsFor: 'filtering'!

{BooleanVar} match: region {XnRegion}
	"tell whether a region passes this filter"
	^(region isSubsetOf: myRegion) not!

{Filter} pass: parent {Joint}
	"return the simplest filter for looking at the children"
	(parent intersected isSubsetOf: myRegion)
		ifFalse: [^Filter openFilter: self coordinateSpace].
	(parent unioned isSubsetOf: myRegion)
		ifTrue: [^Filter closedFilter: self coordinateSpace].
	^self!

{XnRegion} region
	^myRegion! !

!NotSubsetFilter methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^(self coordinateSpace hashForEqual bitXor: myRegion hashForEqual)
		bitXor: #cat.U.NotSubsetFilter hashForEqual!

{BooleanVar} isAllFilter

	^false!

{BooleanVar} isAnyFilter
	
	^true!

{BooleanVar} isEmpty
	^false!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: NotSubsetFilter into: [:nsf |
			^nsf region isEqual: myRegion]
		others: [^false].
	^false "fodder"!

{BooleanVar} isFull	

	^false! !

!NotSubsetFilter methodsFor: 'operations'!

{XnRegion} complement

	^Filter subsetFilter: self coordinateSpace with: myRegion! !

!NotSubsetFilter methodsFor: 'creation'!

create: cs {FilterSpace} with: region {XnRegion}
	super create: cs.
	myRegion _ region! !

!NotSubsetFilter methodsFor: 'printing'!

{void} printOn: oo {ostream reference}
	oo << 'IntersectionFilter(' << myRegion complement << ')'! !

!NotSubsetFilter methodsFor: 'protected operations'!

{XnRegion} fetchSpecialIntersect: other {XnRegion}

	other
		cast: SubsetFilter into: [:sf |
			(sf region isSubsetOf: myRegion)
				ifTrue: [^Filter closedFilter: self coordinateSpace]
				ifFalse: [^NULL]]
		others: [^NULL].
	^NULL "fodder"!

{XnRegion} fetchSpecialSubset: other {XnRegion}

	other
		cast: NotSubsetFilter into: [:nsf |
			| others {XnRegion} |
			others _ nsf region.
			(others isSubsetOf: myRegion) ifTrue: [^self].
			(myRegion isSubsetOf: others) ifTrue: [^other]]
		others: [].
	^NULL!

{XnRegion} fetchSpecialUnion: other {XnRegion}

	other
		cast: SubsetFilter into: [:sf |
			(myRegion isSubsetOf: sf region)
				ifTrue: [^Filter openFilter: self coordinateSpace]
				ifFalse: [^NULL]]
		cast: NotSubsetFilter into: [:nsf |
			^Filter notSubsetFilter: self coordinateSpace
				with: (myRegion intersect: nsf region)]
		others: [^NULL].
	^NULL "fodder"! !

!NotSubsetFilter methodsFor: 'enumerating'!

{Stepper of: Filter} intersectedFilters

	^Stepper itemStepper: self!

{Stepper of: Filter} unionedFilters

	^Stepper itemStepper: self! !

!NotSubsetFilter methodsFor: 'accessing'!

{XnRegion} baseRegion

	^myRegion complement!

{XnRegion} relevantRegion

	^myRegion complement! !

!NotSubsetFilter methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myRegion _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myRegion.! !Filter subclass: #NotSupersetFilter
	instanceVariableNames: 'myRegion {XnRegion}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Filter'!

(NotSupersetFilter getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!NotSupersetFilter methodsFor: 'filtering'!

{BooleanVar} match: region {XnRegion}
	"tell whether a region passes this filter"
	^(myRegion isSubsetOf: region) not!

{Filter} pass: parent {Joint}
	"return the simplest filter for looking at the children"
	(myRegion isSubsetOf: parent unioned) ifFalse:
		[^Filter openFilter: self coordinateSpace].
	(myRegion isSubsetOf: parent intersected) ifTrue:
		[^Filter closedFilter: self coordinateSpace].
	^self!

{XnRegion} region
	^myRegion! !

!NotSupersetFilter methodsFor: 'operations'!

{XnRegion} complement

	^Filter supersetFilter: self coordinateSpace with: myRegion! !

!NotSupersetFilter methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^(self coordinateSpace hashForEqual bitXor: myRegion hashForEqual)
		bitXor: #cat.U.NotSupersetFilter hashForEqual!

{BooleanVar} isAllFilter

	^false!

{BooleanVar} isAnyFilter
	
	^false!

{BooleanVar} isEmpty
	^false!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: NotSupersetFilter into: [:nsf |
			^nsf region isEqual: myRegion]
		others: [^false].
	^false "fodder"!

{BooleanVar} isFull	

	^false! !

!NotSupersetFilter methodsFor: 'creation'!

create: cs {FilterSpace} with: region {XnRegion}
	super create: cs.
	myRegion _ region! !

!NotSupersetFilter methodsFor: 'printing'!

{void} printOn: oo {ostream reference}
	oo << self getCategory name << '(' << myRegion << ')'! !

!NotSupersetFilter methodsFor: 'protected operations'!

{Pair of: Filter} fetchCanonicalIntersect: other {Filter}
	"return NULL, or the pair of canonical filters (left == new1 | self, right == new2 | other)"
	
	other
		cast: SubsetFilter into: [:subF |
			| others {XnRegion} |
			others _ subF region.
			(myRegion isSubsetOf: others)
				ifTrue: [^NULL]
				ifFalse: [^Pair make: (Filter notSupersetFilter: self coordinateSpace
						with: (myRegion intersect: others))
					with: other]]
		cast: SupersetFilter into: [:superF |
			| others {XnRegion} |
			others _ superF region.
			(myRegion intersects: others)
				ifTrue: [^Pair make: (Filter notSupersetFilter: self coordinateSpace
						with: (myRegion minus: superF region))
					with: other]
				ifFalse: [^NULL]]
		others: [^NULL].
	^NULL "fodder"!

{Pair of: Filter} fetchCanonicalUnion: other {Filter}
	"return NULL, or the pair of canonical filters (left == new1 | self, right == new2 | other)"
	
	other
		cast: SupersetFilter into: [:sf |
			| others {XnRegion} |
			others _ sf region.
			(myRegion intersects: others)
				ifTrue: [^Pair make: self
					with: (Filter supersetFilter: self coordinateSpace
						with: (sf region minus: myRegion))]
				ifFalse: [^NULL]]
		others: [^NULL].
	^NULL "fodder"!

{XnRegion} fetchSpecialIntersect: other {XnRegion}

	other
		cast: SupersetFilter into: [:sf |
			(myRegion isSubsetOf: sf region)
				ifTrue: [^Filter closedFilter: self coordinateSpace]
				ifFalse: [^NULL]]
		others: [^NULL].
	^NULL "fodder"!

{XnRegion} fetchSpecialSubset: other {XnRegion}

	other
		cast: SubsetFilter into: [:subF |
			(myRegion isSubsetOf: subF region)
				ifFalse: [^other]]
		cast: NotSupersetFilter into: [:nSuperF |
			| others {XnRegion} |
			others _ nSuperF region.
			(myRegion isSubsetOf: others) ifTrue: [^self].
			(others isSubsetOf: myRegion) ifTrue: [^other]]
		others: [].
	^NULL!

{XnRegion} fetchSpecialUnion: other {XnRegion}

	other
		cast: NotSubsetFilter into: [:nSubF |
			(myRegion isSubsetOf: nSubF region)
				ifFalse: [^Filter openFilter: self coordinateSpace]]
		cast: SupersetFilter into: [:superF |
			(superF region isSubsetOf: myRegion)
				ifTrue: [^Filter openFilter: self coordinateSpace]]
		cast: NotSupersetFilter into: [:nSuperF |
			^Filter notSupersetFilter: self coordinateSpace
				with: (myRegion unionWith: nSuperF region)]
		others: [].
	^NULL! !

!NotSupersetFilter methodsFor: 'enumerating'!

{Stepper of: Filter} intersectedFilters

	^Stepper itemStepper: self!

{Stepper of: Filter} unionedFilters

	^Stepper itemStepper: self! !

!NotSupersetFilter methodsFor: 'accessing'!

{XnRegion} baseRegion

	Heaper BLAST: #NotSimpleEnough.
	^NULL!

{XnRegion} relevantRegion

	^myRegion! !

!NotSupersetFilter methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myRegion _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myRegion.! !Filter subclass: #OpenFilter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Filter'!

(OpenFilter getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!OpenFilter methodsFor: 'operations'!

{XnRegion} complement

	^Filter closedFilter: self coordinateSpace!

{XnRegion} intersect: other {XnRegion}
	^other!

{XnRegion} minus: other {XnRegion}
	^other complement!

{XnRegion} unionWith: other {XnRegion unused}
	^self! !

!OpenFilter methodsFor: 'filtering'!

{BooleanVar} match: region {XnRegion unused}
	"tell whether a region passes this filter"
	^true!

{Filter} pass: parent {Joint unused}
	"return the simplest filter for looking at the children"
	^self! !

!OpenFilter methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^self coordinateSpace hashForEqual bitXor: #cat.U.OpenFilter hashForEqual!

{BooleanVar} isAllFilter

	^true!

{BooleanVar} isAnyFilter
	
	^false!

{BooleanVar} isEmpty
	^false!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: OpenFilter into: [:of |
			^of coordinateSpace isEqual: self coordinateSpace]
		others: [^false].
	^false "fodder"!

{BooleanVar} isFull	

	^true! !

!OpenFilter methodsFor: 'creation'!

create: cs {FilterSpace}
	super create: cs! !

!OpenFilter methodsFor: 'printing'!

{void} printOn: oo {ostream reference}
	oo << self getCategory name << '(' << self coordinateSpace << ')'! !

!OpenFilter methodsFor: 'protected: protected operations'!

{XnRegion} fetchSpecialSubset: other {XnRegion}
	^other! !

!OpenFilter methodsFor: 'enumerating'!

{Stepper of: Filter} intersectedFilters

	^Stepper emptyStepper!

{Stepper of: Filter} unionedFilters

	^Stepper itemStepper: self! !

!OpenFilter methodsFor: 'accessing'!

{XnRegion} baseRegion

	^(self coordinateSpace cast: FilterSpace) emptyRegion!

{XnRegion} relevantRegion

	^self filterSpace baseSpace emptyRegion! !

!OpenFilter methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

OpenFilter class
	instanceVariableNames: ''!

(OpenFilter getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!OpenFilter class methodsFor: 'pseudo constructors'!

{Filter} make: space {CoordinateSpace}

	^self create: (space cast: FilterSpace)! !Filter subclass: #OrFilter
	instanceVariableNames: 'mySubFilters {ImmuSet of: Filter}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Filter'!

(OrFilter getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!OrFilter methodsFor: 'creation'!

create: cs {FilterSpace} with: subs {ImmuSet of: Filter}
	super create: cs.
	mySubFilters _ subs! !

!OrFilter methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^(self coordinateSpace hashForEqual bitXor: mySubFilters hashForEqual)
		bitXor: #cat.U.OrFilter hashForEqual!

{BooleanVar} isAllFilter

	^false!

{BooleanVar} isAnyFilter
	
	^false!

{BooleanVar} isEmpty
	^false!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: OrFilter into: [:of |
			^of subFilters isEqual: self subFilters]
		others: [^false].
	^false "fodder"!

{BooleanVar} isFull	

	^false! !

!OrFilter methodsFor: 'printing'!

{void} printOn: oo {ostream reference}
	oo << self getCategory name.
	self subFilters printOnWithSimpleSyntax: oo with: '(' with: ' || ' with: ')'! !

!OrFilter methodsFor: 'operations'!

{XnRegion} complement

	| result {XnRegion} |
	result _ Filter openFilter: self coordinateSpace.
	self subFilters stepper forEach: [ :sub {XnRegion} |
		result _ result intersect: sub complement].
	^result! !

!OrFilter methodsFor: 'filtering'!

{BooleanVar} match: region {XnRegion}
	"tell whether a region passes this filter"
	self subFilters stepper forEach: [ :sub {Filter} |
		(sub match: region)
			ifTrue: [^true]].
	^false!

{Filter} pass: parent {Joint}
	"return the simplest filter for looking at the children"
	| result {XnRegion} |
	result _ Filter closedFilter: self coordinateSpace.
	self subFilters stepper forEach: [ :sub {Filter} |
		result _ result unionWith: (sub pass: parent)].
	^result cast: Filter!

{ImmuSet of: Filter} subFilters
	^mySubFilters! !

!OrFilter methodsFor: 'protected: protected operations'!

{XnRegion} fetchSpecialSubset: other {XnRegion}
	"return self or other if one is clearly a subset of the other, else NULL"
	| filter {Filter} defaultRegion {XnRegion} |
	filter _ other cast: Filter.
	defaultRegion _ self.
	self subFilters stepper forEach: [ :subfilter {Filter} | 
		| a {XnRegion} b {XnRegion} |
		((a _ subfilter fetchSpecialSubset: filter) basicCast: Heaper star) == other ifTrue: [^other].
		((b _ filter fetchSpecialSubset: subfilter) basicCast: Heaper star) == other ifTrue: [^other].
		((a basicCast: Heaper star) == other or: [(b basicCast: Heaper star) == other]) ifFalse: [defaultRegion _ NULL]].
	^defaultRegion! !

!OrFilter methodsFor: 'enumerating'!

{Stepper of: Filter} intersectedFilters

	^Stepper itemStepper: self!

{Stepper of: Filter} unionedFilters

	^mySubFilters stepper! !

!OrFilter methodsFor: 'accessing'!

{XnRegion} baseRegion

	Heaper BLAST: #NotSimpleEnough.
	^NULL!

{XnRegion} relevantRegion

	| result {XnRegion} |
	result := self filterSpace baseSpace emptyRegion.
	mySubFilters stepper forEach: [ :sub {Filter} |
		result := result unionWith: sub relevantRegion].
	^result! !

!OrFilter methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	mySubFilters _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: mySubFilters.! !Filter subclass: #SubsetFilter
	instanceVariableNames: 'myRegion {XnRegion}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Filter'!

(SubsetFilter getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!SubsetFilter methodsFor: 'creation'!

create: cs {FilterSpace} with: region {XnRegion}
	super create: cs.
	myRegion _ region! !

!SubsetFilter methodsFor: 'operations'!

{XnRegion} complement

	^Filter notSubsetFilter: self coordinateSpace with: myRegion! !

!SubsetFilter methodsFor: 'filtering'!

{BooleanVar} match: region {XnRegion}
	"tell whether a region passes this filter"
	^region isSubsetOf: myRegion!

{Filter} pass: parent {Joint}
	"return the simplest filter for looking at the children"
	(parent unioned isSubsetOf: myRegion) ifTrue:
		[^Filter openFilter: self coordinateSpace].
	(parent intersected isSubsetOf: myRegion) ifFalse:
		[^Filter closedFilter: self coordinateSpace].
	^self!

{XnRegion} region
	^myRegion! !

!SubsetFilter methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^(self coordinateSpace hashForEqual bitXor: myRegion hashForEqual)
		bitXor: #cat.U.SubsetFilter hashForEqual!

{BooleanVar} isAllFilter

	^false!

{BooleanVar} isAnyFilter
	
	^false!

{BooleanVar} isEmpty
	^false!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: SubsetFilter into: [:ssf |
			^ssf region isEqual: myRegion]
		others: [^false].
	^false "fodder"!

{BooleanVar} isFull	

	^false! !

!SubsetFilter methodsFor: 'printing'!

{void} printOn: oo {ostream reference}
	oo << self getCategory name << '(' << myRegion << ')'! !

!SubsetFilter methodsFor: 'protected: protected operations'!

{XnRegion} fetchSpecialUnion: other {XnRegion unused}
	^NULL! !

!SubsetFilter methodsFor: 'protected operations'!

{XnRegion} fetchSpecialIntersect: other {XnRegion}

	other
		cast: SubsetFilter into: [:sf |
			^Filter subsetFilter: self coordinateSpace
				with: (sf region intersect: myRegion)]
		others: [^NULL].
	^NULL "fodder"!

{XnRegion} fetchSpecialSubset: other {XnRegion}

	other
		cast: SubsetFilter into: [:sf |
			| others {XnRegion} |
			others _ sf region.
			(others isSubsetOf: myRegion) ifTrue: [^other].
			(myRegion isSubsetOf: others) ifTrue: [^self]]
		others: [].
	^NULL! !

!SubsetFilter methodsFor: 'enumerating'!

{Stepper of: Filter} intersectedFilters

	^Stepper itemStepper: self!

{Stepper of: Filter} unionedFilters

	^Stepper itemStepper: self! !

!SubsetFilter methodsFor: 'accessing'!

{XnRegion} baseRegion

	Heaper BLAST: #NotSimpleEnough.
	^NULL!

{XnRegion} relevantRegion

	^myRegion complement! !

!SubsetFilter methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myRegion _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myRegion.! !Filter subclass: #SupersetFilter
	instanceVariableNames: 'myRegion {XnRegion}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Filter'!

(SupersetFilter getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!SupersetFilter methodsFor: 'filtering'!

{BooleanVar} match: region {XnRegion}
	"tell whether a region passes this filter"
	^myRegion isSubsetOf: region!

{Filter} pass: parent {Joint}
	"return the simplest filter for looking at the children"
	(myRegion isSubsetOf: parent intersected) ifTrue:
		[^Filter openFilter: self coordinateSpace].
	(myRegion isSubsetOf: parent unioned) ifFalse:
		[^Filter closedFilter: self coordinateSpace].
	^self!

{XnRegion} region
	^myRegion! !

!SupersetFilter methodsFor: 'operations'!

{XnRegion} complement

	^Filter notSupersetFilter: self coordinateSpace with: myRegion! !

!SupersetFilter methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^(self coordinateSpace hashForEqual bitXor: myRegion hashForEqual)
		bitXor: #cat.U.SupersetFilter hashForEqual!

{BooleanVar} isAllFilter

	^true!

{BooleanVar} isAnyFilter
	
	^false!

{BooleanVar} isEmpty
	^false!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: SupersetFilter into: [:ssf |
			^ssf region isEqual: myRegion]
		others: [^false].
	^false "fodder"!

{BooleanVar} isFull	

	^false! !

!SupersetFilter methodsFor: 'protected: protected operations'!

{XnRegion} fetchSpecialUnion: other {XnRegion unused}
	^NULL! !

!SupersetFilter methodsFor: 'creation'!

create: cs {FilterSpace} with: region {XnRegion}
	super create: cs.
	myRegion _ region! !

!SupersetFilter methodsFor: 'printing'!

{void} printOn: oo {ostream reference}
	oo << self getCategory name << '(' << myRegion << ')'! !

!SupersetFilter methodsFor: 'protected operations'!

{Pair of: Filter} fetchCanonicalUnion: other {Filter}
	"return NULL, or the pair of canonical filters (left == new1 | self, right == new2 | other)"
	
	other
		cast: NotSubsetFilter into: [:nsf |
			| others {XnRegion} |
			others _ nsf region.
			(myRegion isSubsetOf: others)
				ifFalse: [^Pair make: (Filter supersetFilter: self coordinateSpace
						with: (myRegion intersect: nsf region))
					with: other]]
		others: [].
	^NULL!

{XnRegion} fetchSpecialIntersect: other {XnRegion}

	other
		cast: SubsetFilter into: [:subF |
			(myRegion isSubsetOf: subF region)
				ifFalse: [^Filter closedFilter: self coordinateSpace]]
		cast: SupersetFilter into: [:superF |
			^Filter supersetFilter: self coordinateSpace
				with: (myRegion unionWith: superF region)]
		others: [].
	^NULL!

{XnRegion} fetchSpecialSubset: other {XnRegion}

	other
		cast: NotSubsetFilter  into: [:nSubF |
			(myRegion isSubsetOf: nSubF region)
				ifFalse: [^self]]
		cast: SupersetFilter into: [:superF |
			| others {XnRegion} |
			others _ superF region.
			(myRegion isSubsetOf: others) ifTrue: [^other].
			(others isSubsetOf: myRegion) ifTrue: [^self]]
		others: [].
	^NULL! !

!SupersetFilter methodsFor: 'enumerating'!

{Stepper of: Filter} intersectedFilters

	^Stepper itemStepper: self!

{Stepper of: Filter} unionedFilters

	^Stepper itemStepper: self! !

!SupersetFilter methodsFor: 'accessing'!

{XnRegion} baseRegion

	^myRegion!

{XnRegion} relevantRegion

	^myRegion! !

!SupersetFilter methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myRegion _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myRegion.! !XnRegion subclass: #IntegerRegion
	instanceVariableNames: '
		myStartsInside {BooleanVar}
		myTransitionCount {UInt32}
		myTransitions {IntegerVarArray}'
	classVariableNames: '
		AllIntegers {IntegerRegion} 
		EmptyIntegerRegion {IntegerRegion} 
		LastAfterRegion {IntegerRegion} 
		LastAfterStart {IntegerVar} 
		LastBeforeEnd {IntegerVar} 
		LastBeforeRegion {IntegerRegion} 
		LastInterval {IntegerRegion} 
		LastLeft {IntegerVar} 
		LastRight {IntegerVar} 
		LastSingleton {IntegerVar} 
		LastSingletonRegion {IntegerRegion} '
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Integers'!
IntegerRegion comment:
'An IntegerRegion can be thought of as the disjoint union of intervals and inequalities.  The interesting cases to look at are:
	
	The distinctions:
		1) The empty region
		2) The full region
		3) A "left" inequality -- e.g., everything less that 3.
		4) A "right" inequality -- e.g., everything greater than or equal to 7
		
	The non-distinction simple regions:
		5) An interval -- e.g., from 3 inclusive to 7 exclusive
		
	The non-simple regions:
		6) A disjoint union of (in order) an optional left inequality, a set of 
			intervals, and an optional right inequality.  
		
	If a non-empty region has a least element, then it "isBoundedLeft".  Otherwise it extends leftwards indefinitely.  Similarly, if a non-empty region has a greatest element, then it "isBoundedRight".  Otherwise it extends rightwards indefinitely.  (We may figuratively speak of the region extending towards + or - infinity, but we have purposely avoided introducing any value which represents an infinity.)
	
	Looking at cases again:
		1) "isBoundedLeft" and "isBoundedRight" since it doesn''t extent 
			indenfinitely in either direction.  (A danger to watch out for is that 
			this still has niether a greatest nor a least element).
		2) niether.
		3) "isBoundedRight"
		4) "isBoundedLeft"
		5) "isBoundedLeft" and "isBoundedRight"
		6) "isBoundedLeft" iff doesn''t include a left inequality,
			"isBoundedRight" iff doesn''t include a right inequality.
			
	An efficiency note:  Currently many of the method which could be doing an O(log) binary search (such as hasMember) are instead doing a linear search.  This will be fixed if it turns out to be a problem in practice.
	
	See OrderedRegion.'!

(IntegerRegion getOrMakeCxxClassDescription)
	friends:
'friend class ID;
friend class IntegerMapping;
friend class IntegerSpace;
friend class PointRegion;
friend class SlicePointRegion;
';
	attributes: ((Set new) add: #CONCRETE; add: #ON.CLIENT; add: #COPY; yourself)!

!IntegerRegion methodsFor: 'accessing'!

{XnRegion} asSimpleRegion
	"Will always return the smallest simple region which contains all my positions"

	self isSimple ifTrue: [^self].
	self isBoundedBelow
		ifTrue: [self isBoundedAbove
			ifTrue: [^IntegerRegion make: self start with: self stop]
			ifFalse: [^IntegerRegion after: self start]]
		ifFalse: [self isBoundedAbove
			ifTrue: [^IntegerRegion before: self stop]
			ifFalse: [^IntegerRegion allIntegers]]!

{XnRegion} beforeLast
	"the region before the last element of the set.  
	What on earth is this for? (Yes, I've looked at senders)"

	myTransitionCount == Int32Zero ifTrue:
		[^self].
	self isBoundedAbove
		ifTrue: [^IntegerRegion before: self stop]
		ifFalse: [^IntegerRegion allIntegers]!

{XnRegion} compacted
	"transform the region into a simple region with left bound 0 
	(or -inf if unbounded).
	What on earth is this for? (Yes, I've looked at senders)"

	"((IntegerRegion make: 3 with: 7) unionWith: (IntegerRegion before: -10)) compacted"
	self isBoundedBelow
		ifTrue: [self isBoundedAbove
			ifTrue: [^IntegerRegion make: IntegerVar0 with: self count]
			ifFalse: [^IntegerRegion after: IntegerVar0]]
		ifFalse: [self isBoundedAbove
			ifTrue: [^IntegerRegion before: ((myTransitions integerVarAt: Int32Zero)
				+ (self intersect: (IntegerRegion after: (myTransitions integerVarAt: Int32Zero))) count)]
			ifFalse: [^IntegerRegion allIntegers]]!

{Mapping} compactor
	"A mapping to transform the region into a simple region with left bound 0 (or -inf if unbounded). The domain of the mapping is precisely this region.
	This is primarily used in XuText Waldos, which only deal with contiguous zero-based regions of data."

	"((IntegerRegion make: 3 with: 7) unionWith: (IntegerRegion after: 10)) compactor"
	| result {Mapping} end {IntegerVar} index {UInt32} simple {IntegerRegion} sub {Mapping} |
	myTransitionCount == Int32Zero ifTrue: [^IntegerMapping make restrict: self].
	result _ NULL.
	myStartsInside ifTrue:
		[end _ myTransitions integerVarAt: Int32Zero.
		index _ 1]
	ifFalse:
		[end _ IntegerVar0.
		index _ Int32Zero].
	[index < myTransitionCount] whileTrue:
		[simple _ self simpleRegionAtIndex: index.
		sub _ (IntegerMapping make: end - simple start) restrict: simple.
		result == NULL
			ifTrue: [result _ sub]
			ifFalse: [result _ result combine: sub].
		simple isBoundedAbove ifTrue:
			[end _ end + simple count].
		index _ index + 2].
	result ~~ NULL
		ifTrue: [^result restrict: self]
		ifFalse: [^IntegerMapping make restrict: self]!

{CoordinateSpace INLINE} coordinateSpace
	^IntegerSpace make!

{BooleanVar} isCompacted
	"True if this is either empty or a simple region with lower bound of either 0 or -infinity. Equivalent to
		this->compacted()->isEqual (this)"
	
	myStartsInside
		ifTrue: [^myTransitionCount = 1]
		ifFalse: [^myTransitionCount = Int32Zero
			or: [myTransitionCount = 2
				and: [(myTransitions integerVarAt: Int32Zero) = IntegerVar0]]]!

{IntegerVar} nearestIntHole: index {IntegerVar}
	"This is a hack for finding the smallest available index to allocate that is not in a particular region (a table domain, for example)."
	
	| edges {IntegerEdgeStepper} test {BooleanVar} |
	edges _ self edgeStepper.
	[edges hasValue] whileTrue:
		[index < edges edge ifTrue:
			[edges isEntering
				ifTrue: [edges destroy. ^index]
				ifFalse:
					[| result {IntegerVar}|
					result := edges edge.
					edges destroy.
					^ result]].
		edges step].
	test := edges isEntering.
	edges destroy.
	test
		ifTrue: [^index]
		ifFalse: [Heaper BLAST: #NoHole].
	^IntegerVarZero "fodder"!

{IntegerRegion} runAt: pos {IntegerVar} 
	"The region starting from pos (inclusive) and going until the next transition. If I contain pos, then I return the longest contiguous region starting at pos of positions I contain. If I don't contain pos, then I return the longest contiguous region starting at pos of positions I do not contain."

	Int32Zero almostTo: myTransitionCount do: [:i {UInt32} | (myTransitions integerVarAt: i)
			> pos ifTrue: [^IntegerRegion make: pos with: (myTransitions integerVarAt: i)]].
	^IntegerRegion after: pos!

{IntegerVar CLIENT} start
	"I have a start only if I'm not empty and I am isBoundedBelow. I report as my start the smallest position I *do* contain, which is one greater than the largest position I do not contain. The lower bound of the interval from 3 inclusive to 7 exclusive is 3. 
	See 'stop', you may be surprised."

	(myStartsInside or: [myTransitionCount == Int32Zero])
		ifTrue: [Heaper BLAST: #InvalidRequest].
	^myTransitions integerVarAt: Int32Zero!

{IntegerVar CLIENT} stop
	"I have a stop only if I'm not empty and I am isBoundedAbove. I report as my stop the smallest position I *do not* contain, which is one greater than the largest position I do contain.  The ustop of the interval from 3 inclusive to 7 exclusive is 7.
	See 'start', you may be surprised."

	(self isBoundedAbove not or: [myTransitionCount == Int32Zero])
		ifTrue: [Heaper BLAST: #InvalidRequest]. 
	^myTransitions integerVarAt: myTransitionCount - 1! !

!IntegerRegion methodsFor: 'unprotected creation'!

create: startsInside {BooleanVar} with: count {UInt32} with: transitions {IntegerVarArray}
	super create.
	myStartsInside _ startsInside.
	myTransitionCount _ count.
	myTransitions _ transitions.! !

!IntegerRegion methodsFor: 'destroy'!

{void} destroy! !

!IntegerRegion methodsFor: 'printing'!

{void} printOn: oo {ostream reference}
	self isEmpty ifTrue:
		[oo << '{}']
	ifFalse:
		[ | edges {IntegerEdgeStepper} between {char star} |
		edges _ self edgeStepper.
		self isSimple ifFalse: [oo << '{'].
		edges isEntering ifFalse: [oo << '(-inf'].
		between _ '['.
		[edges hasValue] whileTrue:
			[edges isEntering ifTrue: [oo << between] ifFalse: [oo << ', '].
			oo << edges edge.
			between _ '), ['.
			edges step].
		edges isEntering ifTrue: [oo << ')'] ifFalse: [oo << ', +inf)'].
		self isSimple ifFalse: [oo << '}'].
		edges destroy]! !

!IntegerRegion methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^(myTransitions elementsHash: myTransitionCount)
		bitXor: ((myStartsInside ifTrue: [9617] ifFalse: [518293])
		bitXor: myTransitionCount * 17)!

{BooleanVar} hasIntMember: key {IntegerVar}
	"Unboxed version.  See class comment for XuInteger"
	
	| edges {IntegerEdgeStepper} result {BooleanVar} |
	edges _ self edgeStepper.
	[edges hasValue] whileTrue:
		[key < edges edge ifTrue:
			[result := edges isEntering not.
			edges destroy.
			^ result].
		edges step].
	result := edges isEntering not.
	edges destroy.
	^ result!

{BooleanVar} hasMember: pos {Position}
	^self hasIntMember: (pos cast: IntegerPos) asIntegerVar!

{BooleanVar} intersects: region {XnRegion}
	| other {IntegerRegion wimpy} |
	other _ region cast: IntegerRegion.
	Int32Zero == myTransitionCount
		ifTrue: [myStartsInside ifTrue: [^other isEmpty not] ifFalse: [^self isEmpty not]]
		ifFalse:
			[Int32Zero == other transitionCount
				ifTrue: [other isBoundedBelow ifTrue: [^other isEmpty not] ifFalse: [^self isEmpty not]]
				ifFalse:
					[| mine {IntegerEdgeStepper} others {IntegerEdgeStepper} pending {IntegerVar} havePending {BooleanVar} index {Int32}
					    startsInside {BooleanVar} |
					mine _ self edgeStepper.
					others _ other edgeStepper.
					havePending _ false.
					index _ Int32Zero.
					[mine hasValue and: [others hasValue]] whileTrue:
						[ | me {IntegerVar} it {IntegerVar} |
						me _ mine edge.
						it _ others edge.
						me < it
							ifTrue:
								[others isEntering not ifTrue:
									[havePending ifTrue:
										[pending = me ifTrue: [havePending _ false]
													    ifFalse: [
													    		mine destroy.
													    		others destroy.
													    		^ true]]
									ifFalse:
										[havePending _ true.
										pending _ me.
										index _ 1]].
								mine step]
							ifFalse:
								[mine isEntering not ifTrue:
									[havePending ifTrue:
										[pending = it ifTrue: [havePending _ false]
													  ifFalse: [
													  	mine destroy.
													  	others destroy.
													  	^ true]]
									ifFalse:
										[havePending _ true.
										pending _ it.
										index _ 1]].
								others step]].

					startsInside _ myStartsInside and: [other isBoundedBelow not].

					(mine hasValue and: [others isEntering not]) ifTrue:
						[havePending ifTrue:
							[pending = mine edge ifTrue: [havePending _ false]
												   ifFalse: [
												   	mine destroy.
												   	others destroy.
												   	^ true]]
						ifFalse:
							[havePending _ true.
							index _ 1].
						havePending ifTrue: [
							mine destroy.
							others destroy.
							^ true].
						mine step.
						mine hasValue ifTrue:
							[mine destroy.
							others destroy.
							^ (index = Int32Zero and: [startsInside]) or: [index ~= Int32Zero]]].

					(others hasValue and: [mine isEntering not]) ifTrue:
						[havePending ifTrue:
							[pending = others edge ifTrue: [havePending _ false]
												     ifFalse: [
												     	mine destroy.
												     	others destroy.
												      ^ true]]
						ifFalse:
							[havePending _ true.
							index _ 1].
						havePending ifTrue: [
							mine destroy.
							others destroy.
							^ true].
						others step.
						others hasValue ifTrue:
							[mine destroy.
							others destroy.
							^ (index = Int32Zero and: [startsInside]) or: [index ~= Int32Zero]]].
					mine destroy.
					others destroy.
					^havePending]]!

{BooleanVar CLIENT} isBoundedAbove
	"Either I extend indefinitely to plus infinity, or I am bounded above, not both. 
	The empty region is bounded above despite the fact that it has no upper edge."

	^((myTransitionCount bitAnd: 1) == Int32Zero) ~~ myStartsInside!

{BooleanVar CLIENT INLINE} isBoundedBelow
	"Either I extend indefinitely to minus infinity, or I am bounded below, not both. 
	The empty region is bounded below despite the fact that it has no lower bound."

	^myStartsInside not!

{BooleanVar} isEmpty

	^myStartsInside not and: [myTransitionCount == Int32Zero]!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: IntegerRegion into: [:ir |
			^ir isBoundedBelow ~~ myStartsInside
			 and: [ir transitionCount = myTransitionCount
			 and: [ir secretTransitions elementsEqual: Int32Zero
			 	with: myTransitions
			 	with: Int32Zero
			 	with: myTransitionCount]]]
		others: [^false].
	^ false "compiler fodder"!

{BooleanVar} isFinite

	^self isBoundedBelow and: [self isBoundedAbove]!

{BooleanVar} isFull	

	^myStartsInside and: [myTransitionCount == Int32Zero]!

{BooleanVar} isSimple
	"Inequalities and intervals are both simple.  See class comment"
	
	myStartsInside ifTrue:
		[^myTransitionCount <= 1]
	ifFalse:
		[^myTransitionCount <= 2]!

{BooleanVar} isSubsetOf: other {XnRegion} 
	other isEmpty
		ifTrue: [ ^ self isEmpty ]
		ifFalse:
			[| mine {IntegerEdgeStepper} others {IntegerEdgeStepper} result {BooleanVar} |
			mine _ self edgeStepper.
			others _ (other cast: IntegerRegion) edgeStepper.
			(mine hasValue or: [others hasValue])
				ifFalse: [
					result := mine isEntering or: [others isEntering not].
					mine destroy.
					others destroy.
					^ result].
			(mine isEntering not and: [others isEntering]) ifTrue: [mine destroy. others destroy. ^false].
			[mine hasValue and: [others hasValue]]
				whileTrue: 
					[others edge < mine edge
						ifTrue: 
							[(others isEntering not and: [mine isEntering not]) ifTrue: [mine destroy. others destroy. ^false].
							others step]
						ifFalse: 
							[others edge > mine edge
								ifTrue: 
									[(others isEntering and: [mine isEntering]) ifTrue: [mine destroy. others destroy. ^false].
									mine step]
								ifFalse: 
									[others isEntering ~~ mine isEntering ifTrue: [mine destroy. others destroy. ^false].
									others step.
									mine step]]].
			result := ((mine hasValue and: [others isEntering])
				or: [others hasValue and: [mine isEntering not]]) not.
			mine destroy.
			others destroy.
			^ result]! !

!IntegerRegion methodsFor: 'operations'!

{XnRegion} complement

	^IntegerRegion create: myStartsInside not with: myTransitionCount with: myTransitions!

{XnRegion} intersect: region {XnRegion}
	| other {IntegerRegion wimpy} |
	other _ region cast: IntegerRegion.
	Int32Zero == myTransitionCount
		ifTrue: [myStartsInside ifTrue: [^other] ifFalse: [^self]]
		ifFalse:
			[Int32Zero == other transitionCount
				ifTrue: [other isBoundedBelow ifTrue: [^other] ifFalse: [^self]]
				ifFalse:
					[ | mine {IntegerEdgeStepper} others {IntegerEdgeStepper} result {IntegerEdgeAccumulator} resultReg {XnRegion} |
					mine _ self edgeStepper.
					others _ other edgeStepper.
					result _ IntegerEdgeAccumulator
						make: (myStartsInside and: [other isBoundedBelow not])
						with: (myTransitionCount + other transitionCount).
					[mine hasValue and: [others hasValue]] whileTrue:
						[ | me {IntegerVar} it {IntegerVar} |
						me _ mine edge.
						it _ others edge.
						me < it
							ifTrue:
								[others isEntering not ifTrue: [result edge: me].
								mine step]
							ifFalse:
								[mine isEntering not ifTrue: [result edge: it].
								others step]].
					(mine hasValue and: [others isEntering not]) ifTrue: [result edges: mine].
					(others hasValue and: [mine isEntering not]) ifTrue: [result edges: others].
					mine destroy.
					others destroy.
					resultReg _ result region.
					result destroy.
					^resultReg]]!

{XnRegion} simpleUnion: otherRegion {XnRegion}
	"The result is the smallest simple region which satisfies the spec in XuRegion::simpleUnion"
	
	| other {IntegerRegion wimpy} |
	other _ otherRegion cast: IntegerRegion.
	self isEmpty ifTrue: [^other asSimpleRegion].
	other isEmpty ifTrue: [^self asSimpleRegion].
	(self isBoundedBelow and: [other isBoundedBelow])
		ifTrue: [(self isBoundedAbove and: [other isBoundedAbove])
			ifTrue: [^IntegerRegion make: (self start min: other start)
				with: (self stop max: other stop)]
			ifFalse: [^IntegerRegion after: (self start min: other start)]]
		ifFalse: [(self isBoundedAbove and: [other isBoundedAbove])
			ifTrue: [^IntegerRegion before: (self stop max: other stop)]
			ifFalse: [^IntegerRegion make complement]]!

{XnRegion} unionWith: region {XnRegion}

	region isEmpty
		ifTrue: [ ^ self ]
		ifFalse:
			[| other {IntegerRegion} 
			   mine {IntegerEdgeStepper} 
			   others {IntegerEdgeStepper} 
			   result {IntegerEdgeAccumulator}
			   resultReg {XnRegion} |
			   
			other _ region cast: IntegerRegion.
			mine _ self edgeStepper.
			others _ other edgeStepper.
			result _ IntegerEdgeAccumulator
				make: (myStartsInside or: [other isBoundedBelow not])
				with: myTransitionCount + other transitionCount.
			[mine hasValue and: [others hasValue]] whileTrue:
				[ | me {IntegerVar} him {IntegerVar} |
				me _ mine edge.
				him _ others edge.
				me < him
					ifTrue:
						[others isEntering ifTrue: [result edge: me].
						mine step]
					ifFalse:
						[mine isEntering ifTrue: [result edge: him].
						others step]].
			(mine hasValue and: [others isEntering]) ifTrue: [result edges: mine].
			(others hasValue and: [mine isEntering]) ifTrue: [result edges: others].
			mine destroy.
			others destroy.
			resultReg _ result region.
			result destroy.
			^ resultReg]!

{XnRegion} with: position {Position}

	^ self withInt: (position cast: IntegerPos) asIntegerVar!

{XnRegion} withInt: pos {IntegerVar}

	| mine {IntegerEdgeStepper} me {IntegerVar} result {IntegerEdgeAccumulator} resultReg {XnRegion} |
	self isEmpty ifTrue: [^IntegerRegion make: pos].
	(self isBoundedAbove and: [pos == self stop])
		ifTrue: [
			| newTransitions {IntegerVarArray} |
			newTransitions := myTransitions copy cast: IntegerVarArray.
			newTransitions at: myTransitionCount -1 storeIntegerVar: pos + 1.
			^ IntegerRegion create: myStartsInside with: myTransitionCount with: newTransitions].
	mine _ self edgeStepper.
	result _ IntegerEdgeAccumulator
		make: myStartsInside
		with: myTransitionCount + 2.
	[mine hasValue and: [(me _ mine edge) < pos]] whileTrue:
		[result edge: me.
		mine step].
	mine isEntering 
		ifTrue: 
			[result edge: pos.
			me == pos 
				ifTrue: [mine step]
				ifFalse: [result edge: pos+1]]
		ifFalse:
			[me == pos ifTrue: 
				[mine step.
				result edge: pos+1]].
	mine hasValue ifTrue: [result edges: mine].
	mine destroy.
	resultReg _ result region.
	result destroy.
	^ resultReg! !

!IntegerRegion methodsFor: 'smalltalk: defaults'!

{Stepper CLIENT of: IntegerRegion} intervals
	^self intervals: NULL! !

!IntegerRegion methodsFor: 'enumerating'!

{IntegerVar} count

	| result {IntegerVar} |
	self isFinite ifFalse:
		[Heaper BLAST: #InvalidRequest].
	result _ IntegerVarZero.
	Int32Zero almostTo: myTransitionCount by: 2 do: [ :i {UInt32} |
		result _ result + (myTransitions integerVarAt: i + 1) - (myTransitions integerVarAt: i)].
	^result!

{Stepper INLINE CLIENT of: IntegerRegion} intervals: order {OrderSpec unused default: NULL}
	"Essential. Break this into an ascending sequence of disjoint intervals (which may be unbounded)."
	
	^self simpleRegions!

{BooleanVar} isEnumerable: order {OrderSpec default: NULL}
	"Actually uses the 'order' argument correctly to enumerate the 
	positions. Treats NULL the same as ascending. Iff I am bounded left 
	am I enumerable in ascending order. Similarly, only if I am bounded 
	right am I enumerable in descending order."

	(order == NULL or: [order followsInt: 1 with: IntegerVar0])
		ifTrue: [^self isBoundedBelow]
		ifFalse: [^self isBoundedAbove]!

{BooleanVar CLIENT INLINE} isInterval
	"Whether this Region is a non-empty interval, i.e. if A, B in the Region and A <= C <= B then C is in the Region. This includes inequalities (e.g. {x | x > 5}) and the fullRegion in addition to ordinary two-ended intervals."
	
	^self isSimple! !

!IntegerRegion methodsFor: 'breaking up'!

{ScruSet of: XnRegion} distinctions

	| intReg {IntegerRegion} |
	self isSimple ifFalse:
		[Heaper BLAST: #InvalidRequest].
	self isFull ifTrue:
		[^ImmuSet make].
	(self isEmpty or: [myTransitionCount = 1]) ifTrue:
		[^ImmuSet make with: self].
	intReg _ IntegerRegion create: myStartsInside with: 1 with: myTransitions.
	^(ImmuSet make with: intReg)
		with: (IntegerRegion before: self stop)!

{Stepper} simpleRegions: order {OrderSpec default: NULL} 
	"Treats NULL the same as ascending. For the moment, will only work 
	with an ascending OrderSpec. If a descending OrderSpec is provided, 
	it will currently BLAST, but later will work correctly.
	
	Returns a stepper on a disjoint set of simple regions in ascending 
	order.  No difference with disjointSimpleRegions"

	(order == NULL or: [order followsInt: 1 with: Int32Zero])
		ifFalse: [self unimplemented].
	myTransitionCount == Int32Zero ifTrue: [myStartsInside
			ifTrue: [^Stepper itemStepper: self]
			ifFalse: [^Stepper emptyStepper]].
	^IntegerSimpleRegionStepper
		create: myTransitions
		with: myTransitionCount
		with: myStartsInside not! !

!IntegerRegion methodsFor: 'private:'!

{IntegerVarArray INLINE} secretTransitions
	"The actuall array. DO NOT MODIFY"
	
	^myTransitions!

{IntegerRegion} simpleRegionAtIndex: i {UInt32}
	"the simple region at the given index in the transition array"
	(i < myTransitionCount) assert.
	((i bitAnd: 1) = Int32Zero) == myStartsInside ifTrue:
		[^IntegerRegion before: (myTransitions integerVarAt: i)]
	ifFalse: [i + 1 < myTransitionCount ifTrue:
		[^IntegerRegion make: (myTransitions integerVarAt: i) with: (myTransitions integerVarAt: i + 1)]
	ifFalse:
		[^IntegerRegion after: (myTransitions integerVarAt: i)]]! !

!IntegerRegion methodsFor: 'private: has friends'!

{IntegerEdgeStepper} edgeStepper
	"Do not send from outside the module. This should not be exported 
	outside the module, but to not export it in this case is some trouble."

	^IntegerEdgeStepper
		make: myStartsInside not
		with: myTransitionCount
		with: myTransitions!

{UInt32 INLINE} transitionCount
	"Do not send from outside the module. This should not be exported 
	outside the module, but to not export it in this case is some trouble. 
	It is used for an efficiency hack in PointRegion."

	^myTransitionCount! !

!IntegerRegion methodsFor: 'smalltalk: passe'!

{Position} chooseOne: order {OrderSpec | NULL}

	^((order == NULL or: [order followsInt: 1 with: 0]) ifTrue: [self start]
		ifFalse: [self stop-1]) integer!

{BooleanVar} startsInside
	self passe! !

!IntegerRegion methodsFor: 'protected: enumerating'!

{Stepper} actualStepper: order {OrderSpec default: NULL} 
	"Iff I am bounded left am I enumerable in ascending order. Similarly, only if I am bounded right am I enumerable in descending order."

	(order followsInt: 1 with: IntegerVar0) ifTrue: 
		[^AscendingIntegerStepper make: myTransitions with: myTransitionCount]
	ifFalse: 
		[^DescendingIntegerStepper make: myTransitions with: myTransitionCount]! !

!IntegerRegion methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myStartsInside _ receiver receiveBooleanVar.
	myTransitionCount _ receiver receiveUInt32.
	myTransitions _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendBooleanVar: myStartsInside.
	xmtr sendUInt32: myTransitionCount.
	xmtr sendHeaper: myTransitions.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

IntegerRegion class
	instanceVariableNames: ''!

(IntegerRegion getOrMakeCxxClassDescription)
	friends:
'friend class ID;
friend class IntegerMapping;
friend class IntegerSpace;
friend class PointRegion;
friend class SlicePointRegion;
';
	attributes: ((Set new) add: #CONCRETE; add: #ON.CLIENT; add: #COPY; yourself)!

!IntegerRegion class methodsFor: 'pseudo constructors'!

{IntegerRegion} above: start {IntegerVar} with: inclusive {BooleanVar}
	"Essential. Make a region that contains all integers greater than (or equal if inclusive is true) to start."
	| after {IntegerVar} |
	after _ start.
	inclusive ifFalse: [after _ after + 1].
	^IntegerRegion after: after!

{IntegerRegion} after: start {IntegerVar}
	"The region containing all position greater than or equal to start"

	| table {IntegerVarArray} tir {IntegerRegion} |
	LastAfterStart = start ifTrue:
		[^LastAfterRegion].
	LastAfterStart _ start.
	table _ IntegerVarArray zeros: 1.
	table at: Int32Zero storeIntegerVar: start.
	"temp used to get around static member problem in INIT macro - heh 10 January 1992"
	tir _ IntegerRegion create: false with: 1 with: table.
	LastAfterRegion _ tir.
	^LastAfterRegion.!

{IntegerRegion INLINE} allIntegers
	"The full region of this space"
	
	^AllIntegers!

{IntegerRegion} before: end {IntegerVar}
	"The region of all integers less than end.  Does not include end."
	
	| table {IntegerVarArray} tir {IntegerRegion} |
	LastBeforeEnd = end ifTrue:
		[^LastBeforeRegion].
	LastBeforeEnd _ end.
	table _ IntegerVarArray zeros: 1.
	table at: Int32Zero storeIntegerVar: end.
	"temp used to get around problem with static members & INIT macro - heh 10 January 1992"
	tir _ IntegerRegion create: true with: 1 with: table.
	LastBeforeRegion _ tir.
	^LastBeforeRegion!

{IntegerRegion} below: stop {IntegerVar} with: inclusive {BooleanVar}
	"Make a region that contains all integers less than (or equal if inclusive is true) to stop."
	| after {IntegerVar} |
	after _ stop.
	inclusive ifTrue: [after _ after + 1].
	^IntegerRegion after: after!

{IntegerRegion} integerExtent: start {IntegerVar} with: n {IntegerVar}
	"The region of all integers which are >= start and < start + n"
	
	^self make: start with: start + n!

{IntegerRegion} interval: left {IntegerVar} with: right {IntegerVar}
	"The region of all integers which are >= left and < right"
	
	| ivArray {IntegerVarArray} |
	left >= right ifTrue: [^EmptyIntegerRegion].
	ivArray _ IntegerVarArray zeros: 2.
	ivArray at: Int32Zero storeIntegerVar: left.
	ivArray at: 1 storeIntegerVar: right.
	^IntegerRegion create: false with: 2 with: ivArray!

{IntegerRegion INLINE} make
	"No integers, the empty region"
	
	^EmptyIntegerRegion!

make: singleton {IntegerVar}
	"The region with just this one position.  Equivalent to using a converter 
	to convert this position to a region."
	
	| table {IntegerVarArray} tir {IntegerRegion} |
	singleton = LastSingleton ifTrue:
		[^LastSingletonRegion].
	LastSingleton _ singleton.
	table _ IntegerVarArray zeros: 2.
	table at: Int32Zero storeIntegerVar: singleton.
	table at: 1 storeIntegerVar: singleton + 1.
	"temp used to get around problem with static members and INIT macro - heh 10 January 1992"
	tir _ IntegerRegion create: false with: 2 with: table.
	LastSingletonRegion _ tir.
	^LastSingletonRegion!

make: left {IntegerVar} with: right {IntegerVar}
	"The region of all integers which are >= left and < right"
	
	| ivArray {IntegerVarArray} |
	left >= right ifTrue: [^EmptyIntegerRegion].
	ivArray _ IntegerVarArray zeros: 2.
	ivArray at: Int32Zero storeIntegerVar: left.
	ivArray at: 1 storeIntegerVar: right.
	^IntegerRegion create: false with: 2 with: ivArray! !

!IntegerRegion class methodsFor: 'smalltalk: initialization'!

initTimeNonInherited
	| empty {IntegerVarArray} tir {IntegerRegion} |
	self REQUIRES: IntegerVarArray.
	empty _ IntegerVarArray zeros: 1.
	
	"temp used to get around problem with static members and INIT macro - heh 10 January 1992"
	tir _ IntegerRegion create: true with: Int32Zero with: empty.
	AllIntegers _ tir.
	tir _ IntegerRegion create: false with: Int32Zero with: empty.
	EmptyIntegerRegion _ tir.
	"call the pseudo constructors with arguments that are known to flush the caches"
	IntegerRegion after: IntegerVar0.
	IntegerRegion before: IntegerVar0.
	IntegerRegion make: IntegerVar0.
	IntegerRegion make: IntegerVar0 with: 2!

linkTimeNonInherited
	AllIntegers _ NULL.
	EmptyIntegerRegion _ NULL.
	LastAfterRegion _ NULL.
	LastAfterStart _ 13.
	LastBeforeEnd _ 13.
	LastBeforeRegion _ NULL.
	LastInterval _ NULL.
	LastLeft _ 13.
	LastRight _ 13.
	LastSingleton _ 13.
	LastSingletonRegion _ NULL.! !

!IntegerRegion class methodsFor: 'privacy violator'!

{IntegerVarArray INLINE} badlyViolatePrivacyOfIntegerRegionTransitions: reg {IntegerRegion} 
	"used for an efficiency hack in PointRegion.  Don't use."
	^reg secretTransitions! !

!IntegerRegion class methodsFor: 'private: pseudo constructors'!

{IntegerRegion} usingx: startsInside {BooleanVar}
	with: transitionCount {Int32}
	with: transitions {IntegerVarArray}

	^self create: startsInside with: transitionCount with: transitions! !

!IntegerRegion class methodsFor: 'smalltalk: system'!

info.stProtocol
"{Stepper CLIENT of: RealRegion} intervals: order {OrderSpec default: NULL}
{BooleanVar CLIENT} isBoundedAbove
{BooleanVar CLIENT} isBoundedBelow
{BooleanVar CLIENT} isInterval
{IntegerVar CLIENT} start
{IntegerVar CLIENT} stop
"! !XnRegion subclass: #RealRegion
	instanceVariableNames: '
		myStartsInside {BooleanVar}
		myTransitionVals {PrimFloatArray}
		myTransitionFlags {PrimIntegerArray}'
	classVariableNames: 'TheManager {RealManager} '
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!

(RealRegion getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #ON.CLIENT; add: #COPY; yourself)!

!RealRegion methodsFor: 'enumerating'!

{IntegerVar INLINE} count

	^TheManager count: self!

{ScruSet INLINE of: XnRegion} distinctions

	^TheManager distinctions: self!

{Stepper CLIENT INLINE of: RealRegion} intervals: order {OrderSpec default: NULL}
	"Essential. Break this up into disjoint intervals"
	
	^ self simpleRegions: order!

{BooleanVar CLIENT INLINE} isInterval
	"Whether this Region is a non-empty interval, i.e. if A, B in the Region and A <= C <= B then C is in the Region. This includes inequalities (e.g. {x | x > 5}) and the fullRegion in addition to ordinary two-ended intervals."
	
	^self isSimple!

{Stepper} simpleRegions: order {OrderSpec default: NULL} 

	^TheManager simpleRegions: self with: order!

{Stepper of: Position} stepper: order {OrderSpec default: NULL} 

	self isFinite ifFalse:
		[Heaper BLAST: #NotEnumerable].
	^RealStepper create: self secretTransitions! !

!RealRegion methodsFor: 'protected: enumerating'!

{Stepper of: Position} actualStepper: order {OrderSpec} 

	self shouldNotImplement.
	^NULL "fodder"! !

!RealRegion methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^((self getCategory hashForEqual
		bitXor: (myTransitionVals contentsHash))
		bitXor: (myTransitionFlags contentsHash))
		bitXor: (myStartsInside ifTrue: [255] ifFalse: [UInt32Zero])!

{BooleanVar INLINE} hasMember: position {Position} 

	^TheManager hasMember: self with: position!

{BooleanVar CLIENT INLINE} isBoundedAbove
	"Same meaning as IntegerRegion::isBoundedAbove"
	
	^TheManager isBoundedRight: self!

{BooleanVar CLIENT INLINE} isBoundedBelow
	"Same meaning as IntegerRegion::isBoundedBelow"
	
	^TheManager isBoundedLeft: self!

{BooleanVar INLINE} isEmpty

	^TheManager isEmpty: self!

{BooleanVar INLINE} isEnumerable: order {OrderSpec default: NULL}
	"Any representable infinite set of real numbers is also not enumerable"

	^self isFinite!

{BooleanVar} isEqual: other {Heaper}

	other cast: RealRegion into: [ :region |
		^myStartsInside == region startsInside
			and: [self secretTransitions contentsEqual: region secretTransitions]]
	others:
		[^false].
	^false "fodder"!

{BooleanVar} isFinite

	^TheManager isFinite: self!

{BooleanVar} isFull

	^TheManager isFull: self!

{BooleanVar} isSimple

	^TheManager isSimple: self!

{BooleanVar} isSubsetOf: other {XnRegion}
	
	^TheManager isSubsetOf: self with: other! !

!RealRegion methodsFor: 'operations'!

{XnRegion INLINE} complement

	^TheManager complement: self!

{XnRegion INLINE} intersect: other {XnRegion} 

	^TheManager intersect: self with: other!

{XnRegion} simpleUnion: other {XnRegion} 

	^TheManager simpleUnion: self with: other!

{XnRegion} unionWith: other {XnRegion} 

	^TheManager unionWith: self with: other! !

!RealRegion methodsFor: 'secret'!

{PtrArray of: RealEdge} secretTransitions

	| result {PtrArray of: RealEdge} |
	result := (PrimSpec pointer array: myTransitionVals count) cast: PtrArray.
	Int32Zero almostTo: result count do: [: i {Int32} |
		| pos {RealPos} edge {RealEdge} |
		pos := RealPos make: (myTransitionVals floatAt: i).
		(myTransitionFlags integerAt: i) = IntegerVar0 ifTrue:
			[edge := BeforeReal make: pos]
		ifFalse:
			[edge := AfterReal make: pos].
		result at: i store: edge].
	^result!

{BooleanVar INLINE} startsInside

	^myStartsInside! !

!RealRegion methodsFor: 'printing'!

{void} printOn: oo {ostream reference}

	TheManager printRegionOn: self with: oo! !

!RealRegion methodsFor: 'accessing'!

{XnRegion INLINE} asSimpleRegion

	^TheManager asSimpleRegion: self!

{CoordinateSpace INLINE} coordinateSpace
	
	^RealSpace make!

{RealPos CLIENT} lowerBound
	"The largest real number such that all the positions in the region are >= it.  Does not necessarily lie in the region.  For example, the region of all numbers > 2 has a lowerBound of 2."

	^(TheManager greatestLowerBound: self) cast: RealPos!

{RealPos CLIENT} upperBound
	"The smallest real number such that all the positions in the region are <= it.  Does not necessarily lie in the region.  For example, the region of all numbers < 2 has an upperBound of 2."

	^(TheManager leastUpperBound: self) cast: RealPos! !

!RealRegion methodsFor: 'creation'!

create: startsInside {BooleanVar} with: vals {PrimFloatArray} with: flags {PrimIntegerArray}

	super create.
	myStartsInside := startsInside.
	myTransitionVals := vals.
	myTransitionFlags := flags! !

!RealRegion methodsFor: 'smalltalk: defaults'!

{Stepper CLIENT of: RealRegion} intervals
	^self intervals: NULL! !

!RealRegion methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myStartsInside _ receiver receiveBooleanVar.
	myTransitionVals _ receiver receiveHeaper.
	myTransitionFlags _ receiver receiveHeaper.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendBooleanVar: myStartsInside.
	xmtr sendHeaper: myTransitionVals.
	xmtr sendHeaper: myTransitionFlags.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

RealRegion class
	instanceVariableNames: ''!

(RealRegion getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #ON.CLIENT; add: #COPY; yourself)!

!RealRegion class methodsFor: 'smalltalk: initialization'!

initTimeNonInherited
	
	self REQUIRES: EdgeManager.
	TheManager := RealManager create.!

linkTimeNonInherited
	
	TheManager := NULL.! !

!RealRegion class methodsFor: 'creation'!

{RealRegion} make: startsInside {BooleanVar}
	with: transitions {PrimArray of: RealEdge}
	"Make a new region, reusing the given array. Noone else should ever modify it!!"

	| precision {Int32} spec {PrimSpec} transVals {PrimFloatArray} transFlags {PrimIntegerArray} tr {PtrArray} |
	tr := transitions cast: PtrArray.
	precision := Int32Zero.
	Int32Zero almostTo: transitions count do: [:i {Int32} |
		precision := precision max: ((tr get: i) cast: RealEdge) position precision].
	precision = 64 ifTrue:
		[spec := PrimSpec iEEE64]
	ifFalse: [precision = 32 ifTrue:
		[spec := PrimSpec iEEE32]
	ifFalse: [precision = 8 ifTrue:
		[spec := PrimSpec iEEE32.
		self thingToDo. "add an iEEE8 spec to the system and use it here"]
	ifFalse: [transitions count = Int32Zero ifTrue:
		[spec := PrimSpec iEEE64]
	ifFalse:
		[Heaper BLAST: #UnrecognizedPrecision]]]].
	transVals := (spec array: transitions count) cast: PrimFloatArray.
	transFlags := (PrimSpec uInt8 array: tr count) cast: PrimIntegerArray.
	self thingToDo. "add 'PrimSpec uInt1' to the system and use it here"
	
	Int32Zero almostTo: transitions count do: [:i {Int32} |
		| edge {RealEdge} flag {UInt1} |
		edge := ((tr get: i) cast: RealEdge).
		transVals at: i storeFloat: edge position asIEEE64.
		edge
			cast: BeforeReal into: [:after | flag := UInt32Zero]
			cast: AfterReal into: [:before | flag := 1].
		transFlags at: i storeInteger: flag].
		
	^self usingx: startsInside with: transVals with: transFlags!

{RealRegion} usingx: startsInside {BooleanVar} with: vals {PrimFloatArray} with: flags {PrimIntegerArray}

	^self create: startsInside with: vals with: flags! !

!RealRegion class methodsFor: 'smalltalk: system'!

info.stProtocol
"{Stepper CLIENT of: RealRegion} intervals: order {OrderSpec default: NULL}
{BooleanVar CLIENT} isBoundedAbove
{BooleanVar CLIENT} isBoundedBelow
{BooleanVar CLIENT} isInterval
{XuReal CLIENT} lowerBound
{XuReal CLIENT} upperBound
"! !XnRegion subclass: #SequenceRegion
	instanceVariableNames: '
		myStartsInside {BooleanVar}
		myTransitions {PtrArray NOCOPY of: SequenceEdge}
		myTransitionsCount {Int32}'
	classVariableNames: '
		TheEmptySequenceRegion {SequenceRegion} 
		TheFullSequenceRegion {SequenceRegion} 
		TheManager {SequenceManager} '
	poolDictionaries: ''
	category: 'Xanadu-tumbler'!
SequenceRegion comment:
'Represents a Region of Sequences. We can efficiently represent unions of intervals, delimited either by individual sequences or by a match with all sequences prefixed by some sequence up to some index.'!

(SequenceRegion getOrMakeCxxClassDescription)
	friends:
'/* friends for class SequenceRegion */

friend class Sequence;
friend class SequenceSpace;
friend class SequenceMapping;
friend class SequenceManager;
';
	attributes: ((Set new) add: #CONCRETE; add: #ON.CLIENT; add: #COPY; yourself)!

!SequenceRegion methodsFor: 'create'!

create: startsInside {BooleanVar} with: transitions {PtrArray of: TransitionEdge}

	super create.
	myStartsInside := startsInside.
	myTransitions := transitions.
	myTransitionsCount := transitions count.!

create: startsInside {BooleanVar} with: transitions {PtrArray of: TransitionEdge} with: count {Int32}

	super create.
	myStartsInside := startsInside.
	myTransitions := transitions.
	myTransitionsCount := count! !

!SequenceRegion methodsFor: 'accessing'!

{XnRegion} asSimpleRegion

	^TheManager asSimpleRegion: self!

{CoordinateSpace} coordinateSpace

	^SequenceSpace make!

{Sequence} lowerBound
	"The largest sequence such that all the positions in the region are >= it.  Does not necessarily lie in the region.  For example, the region of all numbers > 2.3 has a lowerBound of 2.3. Mathematically, this is called the 'greatest lower bound'."

	^(TheManager greatestLowerBound: self) cast: Sequence!

{Sequence CLIENT} lowerEdge
	"Essential. The Sequence associated with the lower edge of the Region. To find out where the boundary is in relation to this sequence, check lowerEdgeType. BLASTS if unbounded below."
	
	myTransitionsCount = Int32Zero ifTrue:
		[Heaper BLAST: #InvalidRequest].
	^((myTransitions fetch: Int32Zero) cast: SequenceEdge) sequence!

{IntegerVar CLIENT} lowerEdgePrefixLimit
	"Essential. If lowerEdgeType is prefix, then it includes an Sequence matching each integer in the lowerEdge up to and including lowerEdgePrefixLimit."
	
	myTransitionsCount = Int32Zero ifTrue:
		[Heaper BLAST: #InvalidRequest].
	(myTransitions fetch: Int32Zero) cast: BeforeSequencePrefix into:
		[ :prefix | prefix limit].
	^ -1 "compiler fodder"!

{Int32 CLIENT} lowerEdgeType
	"Essential. The kind of Sequence associated with the lower edge of the Region. If SequenceRegion::inclusive then it includes the lowerEdge; if exclusive, then it does not; if prefix, then it includes any Sequence matching each integer in the lowerEdge up to and including lowerEdgePrefixLimit."
	
	myTransitionsCount = Int32Zero ifTrue:
		[Heaper BLAST: #InvalidRequest].
	(myTransitions fetch: Int32Zero) cast: BeforeSequence into:
		[ :before | ^SequenceRegion INCLUSIVE]
	cast: AfterSequence into:
		[ :after | ^SequenceRegion EXCLUSIVE]
	cast: BeforeSequencePrefix into:
		[ :prefix | ^SequenceRegion PREFIX].
	^ -1 "compiler fodder"!

{Sequence} upperBound
	"The smallest Sequence such that all the positions in the region are <= it.  Does not necessarily lie in the region.  For example, the region of all numbers < 2.3 has an upperBound of 2.3. Mathematically, this is called the 'least upper bound'."

	^(TheManager leastUpperBound: self) cast: Sequence!

{Sequence CLIENT} upperEdge
	"Essential. The Sequence associated with the upper edge of the Region. To find out where the boundary is in relation to this sequence, check upperEdgeType. BLASTS if unbounded below."
	
	myTransitionsCount = Int32Zero ifTrue:
		[Heaper BLAST: #InvalidRequest].
	^((myTransitions fetch: myTransitionsCount - 1) cast: SequenceEdge) sequence!

{IntegerVar CLIENT} upperEdgePrefixLimit
	"Essential. If upperEdgeType is prefix, then it includes a Sequence matching each integer in the upperEdge up to and including upperEdgePrefixLimit."
	
	myTransitionsCount = Int32Zero ifTrue:
		[Heaper BLAST: #InvalidRequest].
	(myTransitions fetch: myTransitionsCount - 1) cast: BeforeSequencePrefix into:
		[ :prefix | prefix limit].
	^IntegerVarZero "fodder"!

{Int32 CLIENT} upperEdgeType
	"Essential. The kind of Sequence associated with the upper edge of the Region. If SequenceRegion::inclusive then it includes the upperEdge; if exclusive, then it does not; if prefix, then it includes any Sequence matching each integer in the upperEdge up to and including upperEdgePrefixLimit."
	
	myTransitionsCount = Int32Zero ifTrue:
		[Heaper BLAST: #InvalidRequest].
	(myTransitions fetch: Int32Zero) cast: BeforeSequence into:
		[ :before | ^SequenceRegion EXCLUSIVE]
	cast: AfterSequence into:
		[ :after | ^SequenceRegion INCLUSIVE]
	cast: BeforeSequencePrefix into:
		[ :prefix | ^SequenceRegion PREFIX].
	^ -1 "compiler fodder"! !

!SequenceRegion methodsFor: 'testing'!

{UInt32} actualHashForEqual

	^(self getCategory hashForEqual
		bitXor: (myTransitions elementsHash: myTransitionsCount))
		bitXor: (myStartsInside ifTrue: [255] ifFalse: [UInt32Zero])!

{BooleanVar} hasMember: position {Position} 

	^TheManager hasMember: self with: position!

{BooleanVar CLIENT INLINE} isBoundedAbove
	"Same meaning as IntegerRegion::isBoundedAbove"
	
	^TheManager isBoundedRight: self!

{BooleanVar CLIENT INLINE} isBoundedBelow
	"Same meaning as IntegerRegion::isBoundedBelow"
	
	^TheManager isBoundedLeft: self!

{BooleanVar} isEmpty

	^TheManager isEmpty: self!

{BooleanVar} isEnumerable: order {OrderSpec unused default: NULL}

	^self isFinite!

{BooleanVar} isEqual: other {Heaper}

	other cast: SequenceRegion into: [ :region |
		^myStartsInside == region startsInside
			and: [myTransitionsCount == region secretTransitionsCount
			and: [myTransitions elementsEqual: Int32Zero with: region secretTransitions with: Int32Zero with: myTransitionsCount]]]
	others:
		[^false].
	^ false "compiler fodder"!

{BooleanVar} isFinite

	^TheManager isFinite: self!

{BooleanVar} isFull

	^TheManager isFull: self!

{BooleanVar} isSimple

	^TheManager isSimple: self!

{BooleanVar} isSubsetOf: other {XnRegion}
	
	^TheManager isSubsetOf: self with: other! !

!SequenceRegion methodsFor: 'protected: enumerating'!

{Stepper of: Position} actualStepper: order {OrderSpec} 

	self shouldNotImplement.
	^NULL "fodder"! !

!SequenceRegion methodsFor: 'enumerating'!

{IntegerVar} count

	^TheManager count: self!

{ScruSet of: XnRegion} distinctions

	^TheManager distinctions: self!

{Stepper CLIENT INLINE of: SequenceRegion} intervals: order {OrderSpec default: NULL}
	"Essential. Break this up into disjoint intervals"
	
	^ self simpleRegions: order!

{BooleanVar CLIENT INLINE} isInterval
	"Whether this Region is a non-empty interval, i.e. if A, B in the Region and A <= C <= B then C is in the Region. This includes inequalities (e.g. {x | x > 5.3}) and the fullRegion in addition to ordinary two-ended intervals."
	
	^self isSimple!

{Stepper} simpleRegions: order {OrderSpec default: NULL} 

	^TheManager simpleRegions: self with: order!

{Stepper of: Position} stepper: order {OrderSpec default: NULL} 

	self isFinite ifFalse:
		[Heaper BLAST: #NotEnumerable].
	^SequenceStepper create: myTransitions with: myTransitionsCount.! !

!SequenceRegion methodsFor: 'operations'!

{XnRegion} complement

	^TheManager complement: self!

{XnRegion} intersect: other {XnRegion} 

	^TheManager intersect: self with: other!

{XnRegion} simpleUnion: other {XnRegion} 

	^TheManager simpleUnion: self with: other!

{XnRegion} unionWith: other {XnRegion} 

	^TheManager unionWith: self with: other!

{XnRegion} with: pos {Position} 

	^TheManager with: self with: pos! !

!SequenceRegion methodsFor: 'printing'!

{void} printOn: oo {ostream reference}

	TheManager printRegionOn: self with: oo! !

!SequenceRegion methodsFor: 'secret'!

{PtrArray INLINE of: SequenceEdge} secretTransitions

	^myTransitions!

{Int32 INLINE} secretTransitionsCount

	^myTransitionsCount!

{BooleanVar INLINE} startsInside

	^myStartsInside! !

!SequenceRegion methodsFor: 'smalltalk: defaults'!

{Stepper CLIENT of: SequenceRegion} intervals
	^self intervals: NULL! !

!SequenceRegion methodsFor: 'hooks:'!

{void RECEIVE.HOOK} receiveSequenceRegion: rcvr {Rcvr}
	myTransitions := PtrArray nulls: myTransitionsCount.
	Int32Zero almostTo: myTransitionsCount do: [:i {Int32} |
		myTransitions at: i store: rcvr receiveHeaper]!

{void SEND.HOOK} sendSequenceRegion: xmtr {Xmtr}
	Int32Zero almostTo: myTransitionsCount do: [:i {Int32} |
		xmtr sendHeaper: (myTransitions fetch: i)]! !

!SequenceRegion methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myStartsInside _ receiver receiveBooleanVar.
	myTransitionsCount _ receiver receiveInt32.
	self receiveSequenceRegion: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendBooleanVar: myStartsInside.
	xmtr sendInt32: myTransitionsCount.
	self sendSequenceRegion: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

SequenceRegion class
	instanceVariableNames: ''!

(SequenceRegion getOrMakeCxxClassDescription)
	friends:
'/* friends for class SequenceRegion */

friend class Sequence;
friend class SequenceSpace;
friend class SequenceMapping;
friend class SequenceManager;
';
	attributes: ((Set new) add: #CONCRETE; add: #ON.CLIENT; add: #COPY; yourself)!

!SequenceRegion class methodsFor: 'smalltalk: passe'!

{SequenceRegion} with: sequence {Sequence}
	self passe.
	^self create: false
		with: (PrimSpec pointer arrayWithTwo: (BeforeSequence make: sequence)
			with: (AfterSequence make: sequence))! !

!SequenceRegion class methodsFor: 'pseudo constructors'!

{SequenceRegion} above: sequence {Sequence}

	^self create: false
		with: ((PrimSpec pointer arrayWith: (BeforeSequence make: sequence)) cast: PtrArray)!

{SequenceRegion} below: sequence {Sequence}

	^self create: true
		with: ((PrimSpec pointer arrayWith: (AfterSequence make: sequence)) cast: PtrArray)!

{SequenceRegion INLINE} empty
	
	^TheEmptySequenceRegion!

{SequenceRegion INLINE} full
	
	^TheFullSequenceRegion!

{SequenceRegion} prefixedBy: sequence {Sequence} with: limit {IntegerVar}
	"All sequences matching the given up to and including the number at limit"
	
	^self create: false
		     with: ((PrimSpec pointer
					arrayWithTwo: (BeforeSequencePrefix below: sequence with: limit)
						       with: (BeforeSequencePrefix above: sequence with: limit)) cast: PtrArray)!

{SequenceRegion} strictlyAbove: sequence {Sequence}

	^self create: false
		with: ((PrimSpec pointer arrayWith: (AfterSequence make: sequence)) cast: PtrArray)!

{SequenceRegion} strictlyBelow: sequence {Sequence}

	^self create: true
		with: ((PrimSpec pointer arrayWith: (BeforeSequence make: sequence)) cast: PtrArray)! !

!SequenceRegion class methodsFor: 'smalltalk: initialization'!

initTimeNonInherited
	
	self REQUIRES: EdgeManager.
	TheManager := SequenceManager create.
	self REQUIRES: Sequence.
	self REQUIRES: SequenceSpace.
	self REQUIRES: PtrArray.
	TheEmptySequenceRegion := self create: false with: PtrArray empty.
	TheFullSequenceRegion := self create: true with: PtrArray empty.!

linkTimeNonInherited
	
	TheManager := NULL.
	TheEmptySequenceRegion := NULL.
	TheFullSequenceRegion := NULL.! !

!SequenceRegion class methodsFor: 'private:'!

{SequenceRegion} usingx: startsInside {BooleanVar}
	with: transitions {PtrArray of: TransitionEdge}
	"Make a new region, reusing the given array. No one else should ever modify it!!"

	^self create: startsInside with: transitions! !

!SequenceRegion class methodsFor: 'constants'!

{Int32 constFn CLIENT INLINE} EXCLUSIVE
	^2!

{Int32 constFn CLIENT INLINE} INCLUSIVE
	^1!

{Int32 constFn CLIENT INLINE} PREFIX
	^3! !

!SequenceRegion class methodsFor: 'smalltalk: system'!

info.stProtocol
"{Int32 constFn CLIENT INLINE} EXCLUSIVE
{Int32 constFn CLIENT INLINE} INCLUSIVE
{Int32 constFn CLIENT INLINE} PREFIX
{Stepper CLIENT of: SequenceRegion} intervals: order {OrderSpec default: NULL}
{BooleanVar CLIENT} isBoundedAbove
{BooleanVar CLIENT} isBoundedBelow
{BooleanVar CLIENT} isInterval
{Sequence CLIENT} lowerEdge
{IntegerVar CLIENT} lowerEdgePrefixLimit
{Int32 CLIENT} lowerEdgeType
{Sequence CLIENT} upperEdge
{IntegerVar CLIENT} upperEdgePrefixLimit
{Int32 CLIENT} upperEdgeType
"! !XnRegion subclass: #SetRegion
	instanceVariableNames: '
		myPositions {(ImmuSet of: Position) copy}
		myIsComplement {BooleanVar copy}'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-Spaces-Unordered'!
SetRegion comment:
'How do you make regions for spaces whose positions
		a) have no orderring (i.e., either no ordering can be imposed (as 
			in HeaperSpace) or it is undesirable to impose one (as curently 
			in IDSpace)); and
		b) there is an inifinte supply of new positions, and you can only 
			name the positions you''ve encountered?
			
	SetRegion is our answer to that.  To start with, a set region can simply be an enumeration of the positions which are its members.  However, because the complement of an XuRegion must be a valid XuRegion, and we have no other representation of the infinite set of positions left over, we must also be able to represent the region consisting of all positions except those explicitly enumerated.  Every SetRegion must either have a finite number of positions, or it must cover all the space except for a finite number of positions.
	
	With regard to degrees of simplicity (see class comment in XuRegion), we currently only have distinctions.  There are no non-distinctions, and therefore no non-simple SetRegions.  Interesting cases are:
	
		1) empty region
		2) full region
		3) singleton set (single member)
		4) singleton hole (single non-member)
		5) region with more than 1, but a finite number, of members
		6) region with more than 1, but a finite number, of non-members
	
	Cases 1, 3, and 5 can be considered the "positive" regions, and cases 2, 4, and 6 the "negative" ones.
	
	Because we only have distinctions (which we are currently doing for an internal reason which will probably go away), we forego the ability to use the generic XuRegion protocol to decompose complex regions into simpler ones.  Instead we provide SetRegion specific protocol ("positions" and "isComplement").  
	
	At a later time, we will probably have cases 1 thru 4 above be the only distinctions, case 6 be a simple region but not a distinction, and have case 5 be a non-simple region.  (These choices are all consistent with the letter and spirit of the simplicity framework documented in XuRegion.  Simple regions must be the *intersection* of distinctions, therefore case 5 cannot be a simple non-distinction.)  Please try to write your software so that it''ll be insensitive to this change.  Thanks.
	
	SetRegion is an abstract superclass useful for defining regions for spaces which have the constraints listed above.'!

(SetRegion getOrMakeCxxClassDescription)
	friends:
'/* friends for class SetRegion */
SPTR(SetRegion) setRegion (CoordinateSpace * cs, ImmuSet * aSet);
friend class SetRegionStepper;
';
	attributes: ((Set new) add: #DEFERRED; add: #COPY; yourself)!

!SetRegion methodsFor: 'accessing'!

{XnRegion} asSimpleRegion

	^ self!

{ScruSet of: XnRegion} distinctions

	^ImmuSet make with: self!

{BooleanVar INLINE} isComplement
	"FALSE means that I'm a 'positive' region (see class comment).  
	TRUE means I'm a negative region."
	
	^myIsComplement!

{ImmuSet wimpy INLINE of: Position} positions
	"If I'm a positive region (see class comment and isComplement), then 
	this is a list of those positions I contain. If I'm negative, then it's 
	those positions I don't contain."

	^myPositions!

{Stepper} simpleRegions: order {OrderSpec unused default: NULL}
	"Make up a singleton set containing the whole region"

	^Stepper itemStepper: self! !

!SetRegion methodsFor: 'enumerating'!

{IntegerVar} count
	myIsComplement
		ifTrue: [Heaper BLAST: #NotEnumerable].
	^myPositions count!

{BooleanVar} isEnumerable: order {OrderSpec default: NULL}
	
	^myIsComplement not!

{Position} theOne
	self count ~~ 1 ifTrue:
		[ Heaper BLAST: #NotOneElement ].
	^ myPositions theOne cast: Position! !

!SetRegion methodsFor: 'operations'!

{XnRegion} complement

	^self makeNew: myIsComplement not with: myPositions!

{XnRegion} intersect: region {XnRegion}
	region isEmpty
		ifTrue: [ ^ region ]
		ifFalse:
			[| other {SetRegion wimpy} |
			other _ region cast: SetRegion.
			myIsComplement
				ifTrue: [other isComplement
					ifTrue: [^self makeNew: true with: (myPositions unionWith: other positions)]
					ifFalse: [^self makeNew: false with: (other positions minus: myPositions)]]
				ifFalse: [other isComplement
					ifTrue: [^self makeNew: false with: (myPositions minus: other positions)]
					ifFalse: [^self makeNew: false with: (myPositions intersect: other positions)]]]!

{XnRegion} minus: other {XnRegion}
	other isEmpty
		ifTrue: [ ^ self ]
		ifFalse:
			[| set {SetRegion wimpy} |
			set _ other cast: SetRegion.
			myIsComplement
				ifTrue: [set isComplement
					ifTrue: [^self makeNew: false with: (set positions minus: myPositions)]
					ifFalse: [^self makeNew: true with: (set positions unionWith: myPositions)]]
				ifFalse: [set isComplement
					ifTrue: [^self makeNew: false with: (set positions intersect: myPositions)]
					ifFalse: [^self makeNew: false with: (myPositions minus: set positions)]]]!

{XnRegion} simpleUnion: other {XnRegion}
	^self unionWith: other!

{XnRegion} unionWith: region {XnRegion}
	region isEmpty
		ifTrue: [ ^ self ]
		ifFalse:
			[| other {SetRegion wimpy} |
			other _ region cast: SetRegion.
			myIsComplement
				ifTrue: [other isComplement
					ifTrue: [^self makeNew: true with: (myPositions intersect: other positions)]
					ifFalse: [^self makeNew: true with: (myPositions minus: other positions)]]
				ifFalse: [other isComplement
					ifTrue: [^self makeNew: true with: (other positions minus: myPositions)]
					ifFalse: [^self makeNew: false with: (myPositions unionWith: other positions)]]]!

{XnRegion} with: pos {Position}

	myIsComplement
		ifTrue: [^self makeNew: myIsComplement with: (myPositions without: pos)]
		ifFalse: [^self makeNew: myIsComplement with: (myPositions with: pos)]!

{XnRegion} without: pos {Position}

	myIsComplement
		ifTrue: [^self makeNew: myIsComplement with: (myPositions with: pos)]
		ifFalse: [^self makeNew: myIsComplement with: (myPositions without: pos)]! !

!SetRegion methodsFor: 'testing'!

{UInt32} actualHashForEqual
	^(self getCategory hashForEqual
		bitXor: myPositions hashForEqual)
		bitXor: (myIsComplement ifTrue: [15732] ifFalse: [Int32Zero])!

{BooleanVar} hasMember: atPos {Position}
	^(myPositions hasMember: atPos) ~~ myIsComplement!

{BooleanVar} intersects: region {XnRegion}
	region isEmpty
		ifTrue: [ ^ false ]
		ifFalse:
			[| other {SetRegion wimpy} |
			other _ region cast: SetRegion.
			myIsComplement
				ifTrue: [other isComplement
					ifTrue: [^true]
					ifFalse: [^(other positions isSubsetOf: myPositions) not]]
				ifFalse: [other isComplement
					ifTrue: [^(myPositions isSubsetOf: other positions) not]
					ifFalse: [^other positions intersects: myPositions]]]!

{BooleanVar} isEmpty
	^myIsComplement not and: [myPositions isEmpty]!

{BooleanVar} isEqual: other {Heaper}

	other
		cast: SetRegion into: [:sr |
			self hack.
			^(other isKindOf: self getCategory)
			 and: [sr isComplement == myIsComplement
			 and: [sr positions isEqual: myPositions]]]
		others: [^false].
	^false "fodder"!

{BooleanVar} isFinite
	^myIsComplement not!

{BooleanVar} isFull	

	^myIsComplement and: [myPositions isEmpty]!

{BooleanVar} isSimple
	^true!

{BooleanVar} isSubsetOf: other {XnRegion}
	other isEmpty
		ifTrue: [ ^ self isEmpty ]
		ifFalse:
			[| set {SetRegion wimpy} |
			set _ other cast: SetRegion.
			myIsComplement
				ifTrue: [^set isComplement and: [set positions isSubsetOf: myPositions]]
				ifFalse: [set isComplement
					ifTrue: [^(set positions intersects: myPositions) not]
					ifFalse: [^myPositions isSubsetOf: set positions]]]! !

!SetRegion methodsFor: 'protected: creation'!

create: cmp {BooleanVar} with: set {ImmuSet of: Position}
	"the set should be for my use alone"
	super create.
	myIsComplement _ cmp.
	myPositions _ set! !

!SetRegion methodsFor: 'printing'!

{void} printOn: oo {ostream reference} 
	oo << self getCategory name.
	myIsComplement ifTrue: [oo << '~'].
	myPositions printOnWithSimpleSyntax: oo with: '{' with: ', ' with: '}'! !

!SetRegion methodsFor: 'protected: protected deferred'!

{XnRegion} makeNew: isComplement {BooleanVar} with: positions {ImmuSet of: Position}
	self subclassResponsibility! !

!SetRegion methodsFor: 'deferred accessing'!

{CoordinateSpace} coordinateSpace
	self subclassResponsibility! !

!SetRegion methodsFor: 'protected: enumerating'!

{Stepper} actualStepper: order {OrderSpec unused}

	^myPositions stepper! !

!SetRegion methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.
	myPositions _ receiver receiveHeaper.
	myIsComplement _ receiver receiveBooleanVar.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.
	xmtr sendHeaper: myPositions.
	xmtr sendBooleanVar: myIsComplement.! !SetRegion subclass: #HeaperRegion
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xanadu-hspace'!

(HeaperRegion getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!HeaperRegion methodsFor: 'accessing'!

{CoordinateSpace} coordinateSpace
	^HeaperSpace make! !

!HeaperRegion methodsFor: 'protected: protected'!

{XnRegion} makeNew: isComplement {BooleanVar} with: positions {ImmuSet of: Position}
	^HeaperRegion create: isComplement with: positions! !

!HeaperRegion methodsFor: 'testing'!

{BooleanVar} isEnumerable: order {OrderSpec default: NULL}

	^false! !

!HeaperRegion methodsFor: 'creation'!

create: isComplement {BooleanVar} with: positions {ImmuSet of: HeaperAsPosition}
	super create: isComplement with: positions! !

!HeaperRegion methodsFor: 'generated:'!

create.Rcvr: receiver {Rcvr}
	super create.Rcvr: receiver.!

{void} sendSelfTo: xmtr {Xmtr}
	super sendSelfTo: xmtr.! !
"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HeaperRegion class
	instanceVariableNames: ''!

(HeaperRegion getOrMakeCxxClassDescription)
	attributes: ((Set new) add: #CONCRETE; add: #NOT.A.TYPE; add: #COPY; yourself)!

!HeaperRegion class methodsFor: 'pseudo constructors'!

{SetRegion} allHeaperAsPositions
	^HeaperRegion create: true with: ImmuSet make!

{SetRegion} make
	^HeaperRegion create: false with: ImmuSet make!

{SetRegion} make.HeaperAsPosition: heaper {HeaperAsPosition}
	^HeaperRegion create: false with: (ImmuSet make with: heaper)!

{SetRegion} make.ScruSet: heapers {ScruSet of: HeaperAsPosition}
	^HeaperRegion create: false with: heapers asImmuSet! !
(CxxSystemOrganization fileNamed: 'cross')
	comment: ''!

(CxxSystemOrganization getOrMakeFileNamed: 'cross')
	hxxHeader: '/* xpp class */
' in: #public!

(CxxSystemOrganization getOrMakeFileNamed: 'cross')
	addClass: CrossSpace
getOrMakeCxxClassDescription in: #public;
	addClass: CrossRegion
getOrMakeCxxClassDescription in: #public;
	addClass: CrossOrderSpec
getOrMakeCxxClassDescription in: #public;
	addClass: CrossMapping
getOrMakeCxxClassDescription in: #public;
	addClass: Tuple
getOrMakeCxxClassDescription in: #public!


(CxxSystemOrganization getOrMakeFileNamed: 'cross')
	addClass: ActualTuple
getOrMakeCxxClassDescription in: #private;
	addClass: GenericCrossSimpleRegionStepper
getOrMakeCxxClassDescription in: #private;
	addClass: GenericCrossRegion
getOrMakeCxxClassDescription in: #private;
	addClass: GenericCrossSpace
getOrMakeCxxClassDescription in: #private;
	addClass: BoxAccumulator
getOrMakeCxxClassDescription in: #private;
	addClass: BoxStepper
getOrMakeCxxClassDescription in: #private;
	addClass: TupleStepper
getOrMakeCxxClassDescription in: #private;
	addClass: BoxProjectionStepper
getOrMakeCxxClassDescription in: #private;
	addClass: GenericCrossDsp
getOrMakeCxxClassDescription in: #private!


(CxxSystemOrganization getOrMakeFileNamed: 'cross')
	addClass: CrossTester
getOrMakeCxxClassDescription in: #test!

(CxxSystemOrganization fileNamed: 'edge')
	comment: ''!


(CxxSystemOrganization getOrMakeFileNamed: 'edge')
	addClass: EdgeManager
getOrMakeCxxClassDescription in: #protected;
	addClass: TransitionEdge
getOrMakeCxxClassDescription in: #protected!


(CxxSystemOrganization getOrMakeFileNamed: 'edge')
	addClass: EdgeSimpleRegionStepper
getOrMakeCxxClassDescription in: #private;
	addClass: EdgeStepper
getOrMakeCxxClassDescription in: #private;
	addClass: EdgeAccumulator
getOrMakeCxxClassDescription in: #private!

(CxxSystemOrganization fileNamed: 'filter')
	comment: ''!

(CxxSystemOrganization getOrMakeFileNamed: 'filter')
	hxxHeader: '/* xpp class */' in: #public!

(CxxSystemOrganization getOrMakeFileNamed: 'filter')
	addClass: Filter
getOrMakeCxxClassDescription in: #public;
	addClass: Joint
getOrMakeCxxClassDescription in: #public;
	addClass: FilterPosition
getOrMakeCxxClassDescription in: #public;
	addClass: FilterSpace
getOrMakeCxxClassDescription in: #public;
	addClass: RegionDelta
getOrMakeCxxClassDescription in: #public!


(CxxSystemOrganization getOrMakeFileNamed: 'filter')
	addClass: AndFilter
getOrMakeCxxClassDescription in: #private;
	addClass: SubsetFilter
getOrMakeCxxClassDescription in: #private;
	addClass: OpenFilter
getOrMakeCxxClassDescription in: #private;
	addClass: OrFilter
getOrMakeCxxClassDescription in: #private;
	addClass: FilterDsp
getOrMakeCxxClassDescription in: #private;
	addClass: NotSupersetFilter
getOrMakeCxxClassDescription in: #private;
	addClass: SupersetFilter
getOrMakeCxxClassDescription in: #private;
	addClass: ClosedFilter
getOrMakeCxxClassDescription in: #private;
	addClass: NotSubsetFilter
getOrMakeCxxClassDescription in: #private!


(CxxSystemOrganization getOrMakeFileNamed: 'filter')
	addClass: FilterTester
getOrMakeCxxClassDescription in: #test!

(CxxSystemOrganization fileNamed: 'hspace')
	comment: ''!


(CxxSystemOrganization getOrMakeFileNamed: 'hspace')
	addClass: UnOrdered
getOrMakeCxxClassDescription in: #public;
	addClass: HeaperSpace
getOrMakeCxxClassDescription in: #public;
	addClass: HeaperAsPosition
getOrMakeCxxClassDescription in: #public!

(CxxSystemOrganization getOrMakeFileNamed: 'hspace')
	cxxHeader: '#include "choosex.hxx"' in: #private!

(CxxSystemOrganization getOrMakeFileNamed: 'hspace')
	addClass: HeaperDsp
getOrMakeCxxClassDescription in: #private;
	addClass: SetRegion
getOrMakeCxxClassDescription in: #private;
	addClass: HeaperRegion
getOrMakeCxxClassDescription in: #private;
	addClass: StrongAsPosition
getOrMakeCxxClassDescription in: #private!

(CxxSystemOrganization fileNamed: 'integer')
	comment: ''!

(CxxSystemOrganization getOrMakeFileNamed: 'integer')
	hxxHeader: '#define Integer0 IntegerPos::make(0)
' in: #public!

(CxxSystemOrganization getOrMakeFileNamed: 'integer')
	addClass: IntegerRegion
getOrMakeCxxClassDescription in: #public;
	addClass: IntegerSpace
getOrMakeCxxClassDescription in: #public;
	addClass: IntegerMapping
getOrMakeCxxClassDescription in: #public;
	addClass: IntegerPos
getOrMakeCxxClassDescription in: #public!

(CxxSystemOrganization getOrMakeFileNamed: 'integer')
	hxxHeader: '' in: #private!

(CxxSystemOrganization getOrMakeFileNamed: 'integer')
	addClass: IntegerArrangement
getOrMakeCxxClassDescription in: #private;
	addClass: DescendingIntegerStepper
getOrMakeCxxClassDescription in: #private;
	addClass: IntegerUpOrder
getOrMakeCxxClassDescription in: #private;
	addClass: IntegerEdgeStepper
getOrMakeCxxClassDescription in: #private;
	addClass: IntegerEdgeAccumulator
getOrMakeCxxClassDescription in: #private;
	addClass: IntegerSimpleRegionStepper
getOrMakeCxxClassDescription in: #private;
	addClass: AscendingIntegerStepper
getOrMakeCxxClassDescription in: #private!


(CxxSystemOrganization getOrMakeFileNamed: 'integer')
	addClass: IntegerRegionTester
getOrMakeCxxClassDescription in: #test!

(CxxSystemOrganization fileNamed: 'real')
	comment: ''!

(CxxSystemOrganization getOrMakeFileNamed: 'real')
	hxxHeader: '#define IEEE8 Int8
' in: #public!

(CxxSystemOrganization getOrMakeFileNamed: 'real')
	addClass: RealRegion
getOrMakeCxxClassDescription in: #public;
	addClass: RealSpace
getOrMakeCxxClassDescription in: #public;
	addClass: RealPos
getOrMakeCxxClassDescription in: #public!


(CxxSystemOrganization getOrMakeFileNamed: 'real')
	addClass: RealDsp
getOrMakeCxxClassDescription in: #private;
	addClass: RealUpOrder
getOrMakeCxxClassDescription in: #private;
	addClass: RealManager
getOrMakeCxxClassDescription in: #private;
	addClass: RealEdge
getOrMakeCxxClassDescription in: #private;
	addClass: RealStepper
getOrMakeCxxClassDescription in: #private;
	addClass: IEEE32Pos
getOrMakeCxxClassDescription in: #private;
	addClass: BeforeReal
getOrMakeCxxClassDescription in: #private;
	addClass: IEEE64Pos
getOrMakeCxxClassDescription in: #private;
	addClass: AfterReal
getOrMakeCxxClassDescription in: #private;
	addClass: IEEE8Pos
getOrMakeCxxClassDescription in: #private!


(CxxSystemOrganization getOrMakeFileNamed: 'real')
	addClass: RealTester
getOrMakeCxxClassDescription in: #test!

(CxxSystemOrganization fileNamed: 'sequenc')
	comment: ''!

(CxxSystemOrganization getOrMakeFileNamed: 'sequenc')
	cxxHeader: '#include <sys/types.h>
#ifndef WIN32
#	include <sys/time.h>
#else
#	include <sys/timeb.h>
#endif /* WIN32 */
' in: #public!

(CxxSystemOrganization getOrMakeFileNamed: 'sequenc')
	addClass: SequenceMapping
getOrMakeCxxClassDescription in: #public;
	addClass: SequenceRegion
getOrMakeCxxClassDescription in: #public;
	addClass: Sequence
getOrMakeCxxClassDescription in: #public;
	addClass: SequenceSpace
getOrMakeCxxClassDescription in: #public!


(CxxSystemOrganization getOrMakeFileNamed: 'sequenc')
	addClass: SequenceEdge
getOrMakeCxxClassDescription in: #private;
	addClass: SequenceManager
getOrMakeCxxClassDescription in: #private;
	addClass: BeforeSequencePrefix
getOrMakeCxxClassDescription in: #private;
	addClass: SequenceStepper
getOrMakeCxxClassDescription in: #private;
	addClass: SequenceUpOrder
getOrMakeCxxClassDescription in: #private;
	addClass: AfterSequence
getOrMakeCxxClassDescription in: #private;
	addClass: BeforeSequence
getOrMakeCxxClassDescription in: #private!


(CxxSystemOrganization getOrMakeFileNamed: 'sequenc')
	addClass: SequenceTester
getOrMakeCxxClassDescription in: #test!

(CxxSystemOrganization fileNamed: 'space')
	comment: ''!

(CxxSystemOrganization getOrMakeFileNamed: 'space')
	hxxHeader: '/* xpp class */

typedef enum { LESS_THAN, EQUAL, GREATER_THAN, INCOMPARABLE }
	OrderEnum;' in: #public!

(CxxSystemOrganization getOrMakeFileNamed: 'space')
	addClass: Mapping
getOrMakeCxxClassDescription in: #public;
	addClass: Arrangement
getOrMakeCxxClassDescription in: #public;
	addClass: CoordinateSpace
getOrMakeCxxClassDescription in: #public;
	addClass: OrderSpec
getOrMakeCxxClassDescription in: #public;
	addClass: XnRegion
getOrMakeCxxClassDescription in: #public;
	addClass: Dsp
getOrMakeCxxClassDescription in: #public;
	addClass: Position
getOrMakeCxxClassDescription in: #public!


(CxxSystemOrganization getOrMakeFileNamed: 'space')
	addClass: MergeStepper
getOrMakeCxxClassDescription in: #protected;
	addClass: ExplicitArrangement
getOrMakeCxxClassDescription in: #protected;
	addClass: IdentityDsp
getOrMakeCxxClassDescription in: #protected;
	addClass: BasicSpace
getOrMakeCxxClassDescription in: #protected!


(CxxSystemOrganization getOrMakeFileNamed: 'space')
	addClass: DisjointRegionStepper
getOrMakeCxxClassDescription in: #private;
	addClass: ConstantMapping
getOrMakeCxxClassDescription in: #private;
	addClass: SimpleMapping
getOrMakeCxxClassDescription in: #private;
	addClass: ReverseOrder
getOrMakeCxxClassDescription in: #private;
	addClass: EmptyMapping
getOrMakeCxxClassDescription in: #private;
	addClass: CompositeMapping
getOrMakeCxxClassDescription in: #private!


(CxxSystemOrganization getOrMakeFileNamed: 'space')
	addClass: RegionTester
getOrMakeCxxClassDescription in: #test!

CxxSystemOrganization tree: (CxxSystemOrganization tree addChild:
	((CxxTreeAssociation key: 'spaces' value: nil)
 addChild: ((CxxTreeAssociation key: #cross value: #file) yourself);
 addChild: ((CxxTreeAssociation key: #edge value: #file) yourself);
 addChild: ((CxxTreeAssociation key: 'filter' value: #file) yourself);
 addChild: ((CxxTreeAssociation key: 'hspace' value: #file) yourself);
 addChild: ((CxxTreeAssociation key: 'integer' value: #file) yourself);
 addChild: ((CxxTreeAssociation key: #real value: #file) yourself);
 addChild: ((CxxTreeAssociation key: #sequenc value: #file) yourself);
 addChild: ((CxxTreeAssociation key: 'space' value: #file) yourself); yourself))!