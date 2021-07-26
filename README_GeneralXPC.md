#  General XPC Design


https://medium.com/dwarves-foundation/xpc-services-on-macos-app-using-swift-657922d425cd

Because communication over XPC is asynchronous, all methods in the protocol must have a return type of void. If you need to return data, you can define a reply block


Important: If a method (or its reply block) has parameters that are Objective-C collection classes (NSDictionary, NSArray, and so on), and if you need to pass your own custom objects within a collection, you must explicitly tell XPC to allow that class as a member of that collection parameter.


Each method must have a return type of void, and all parameters to methods or reply blocks must be either:
Arithmetic types (int, char, float, double, uint64_t, NSUInteger, and so on)
BOOL
C strings
C structures and arrays containing only the types listed above
Objective-C objects that implement the NSSecureCoding protocol.


