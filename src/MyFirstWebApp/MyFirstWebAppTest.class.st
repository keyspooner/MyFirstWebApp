"
A MyFirstWebAppTest is a test class for testing the behavior of MyFirstWebApp
"
Class {
	#name : #MyFirstWebAppTest,
	#superclass : #TestCase,
	#category : #'MyFirstWebApp-Tests'
}

{ #category : #'test support' }
MyFirstWebAppTest >> image [
	^ ZnClient new 
	beOneShot;
	get: 'http://zn.stfx.eu/zn/Hot-Air-Balloon.gif';
	entity
]

{ #category : #tests }
MyFirstWebAppTest >> testDefaultImage [
	self withServerDo: [ :server |
		| client |
		client := ZnClient new.
		client url: server localUrl; addPath: #image; queryAt: #raw put: #true.
		client get.
		self assert: client isSuccess.
		self assert: (client entity contentType matches: 'image/*' asZnMimeType).
		self assert: client entity equals: server delegate image.
		client close 
		 ]
]

{ #category : #tests }
MyFirstWebAppTest >> testMainPage [
	self withServerDo: [ :server |
		| client |
		client := ZnClient new.
		client url: server localUrl; addPath: #image.
		client get.
		self assert: client isSuccess.
		self assert: (client entity contentType matches: ZnMimeType textHtml).
		self assert: (client contents includesSubstring: 'Image').
		client close
		 ]
]

{ #category : #tests }
MyFirstWebAppTest >> testUpload [
	self withServerDo: [ :server |
		| image client |
		image := self image.
		client := ZnClient new.
		client url: server localUrl; addPath: #image.
		client addPart: (ZnMimePart fieldName: #file entity: image).
		client post.
		self assert: client isSuccess.
		client resetEntity; queryAt: #raw put: #true.
		client get.
		self assert: client isSuccess.
		self assert: client entity equals: image.
		client close.
		 ]
]

{ #category : #'test support' }
MyFirstWebAppTest >> withServerDo: block [
	| server |
	server := ZnServer on: 1700 + 10 atRandom.
	[ 
		server start.
		self assert: server isRunning & server isListening.
		server delegate: MyFirstWebApp new.
		block cull: server 
	] ensure: [ server stop ]
]
