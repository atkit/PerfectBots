import PackageDescription

let package = Package(
	name: "SwiftBot",
	targets: [
        Target(
            name:"Messenger",
            dependencies:[]),
	Target(
	    name:"Storage",
	    dependencies:[]),
        Target(
            name:"SwiftBot",
            dependencies:["Messenger","Storage"])
    ],
	dependencies: [
		.Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 2),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-MySQL.git", majorVersion: 2)
    ]
)
