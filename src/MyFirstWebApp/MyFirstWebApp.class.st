Class {
	#name : #MyFirstWebApp,
	#superclass : #Object,
	#instVars : [
		'image'
	],
	#category : #'MyFirstWebApp-Main'
}

{ #category : #public }
MyFirstWebApp >> downloadPharoLogo [
	^ ZnClient new
	beOneShot;
	get: 'http://pharo.org/files/pharo.png';
	entity
]

{ #category : #public }
MyFirstWebApp >> form [
	^ self formForImageEntity: self image
]

{ #category : #public }
MyFirstWebApp >> formForImageEntity: imageEntity [
	| imageType parserClassName parserClass parser |
	imageType := imageEntity contentType sub.
	parserClassName := imageType asUppercase, #ReadWriter.
	parserClass := Smalltalk globals at: parserClassName asSymbol.
	parser := parserClass on: imageEntity readStream.
	^ parser nextImage 
]

{ #category : #public }
MyFirstWebApp >> handleGetRequest: request [
	^ (request uri queryAt: #raw ifAbsent: [nil])
		ifNil: [ ZnResponse ok: (ZnEntity html: self html) ]
		ifNotNil: [ ZnResponse ok: self image ]
]

{ #category : #public }
MyFirstWebApp >> handlePostRequest: request [
	| part newImage badRequest |
	badRequest := [ ^ ZnResponse badRequest: request ].
	request hasEntity
		ifFalse: badRequest.
	(request contentType matches: ZnMimeType multiPartFormData)
		ifFalse: badRequest.
	part := request entity partNamed: #file ifNone: badRequest.
	newImage := part entity.
	(newImage notNil and: [ newImage contentType matches: 'image/*' asZnMimeType ])
		ifFalse: badRequest.
	[ self formForImageEntity: newImage ]
	on: Error
	do: badRequest.
	image := newImage.
	^ ZnResponse redirect: #image
]

{ #category : #public }
MyFirstWebApp >> handleRequest: request [
	request uri path = #image 
		ifTrue: [ 
			request method = #GET 
				ifTrue: [ 
					^ self handleGetRequest: request ].
			request method = #POST
				ifTrue: [ 
					^ self handlePostRequest: request ].
		 ].
	^ ZnResponse notFound: request uri 
]

{ #category : #public }
MyFirstWebApp >> html [
	^ '<html><head><title>Image</title>
		<body>
		<h1>Image</h1>
		<img src="image?raw=true"/>
		<form enctype="multipart/form-data" action="image" method="POST">
		<h3> change the image:</h3>
		<input type="file" name="file"/>
		<input type="submit" value="Upload"/>
		</form>
		</body>
		</html>'
]

{ #category : #public }
MyFirstWebApp >> image [
	^ image ifNil: [ image := self downloadPharoLogo ]
]

{ #category : #public }
MyFirstWebApp >> value: request [
	^ self handleRequest: request
]
