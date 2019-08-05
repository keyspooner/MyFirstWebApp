Class {
	#name : #BaselineOfMyFirstWebApp,
	#superclass : #BaselineOf,
	#category : #BaselineOfMyFirstWebApp
}

{ #category : #baselines }
BaselineOfMyFirstWebApp >> baseline: spec [
    <baseline>
    spec for: #common do: [	
				
        "Packages"
        spec
            package: 'MyFirstWebApp';
            package: 'MyFirstWebApp-Tests' with: [ spec requires: #('MyFirstWebApp') ] ].
]
