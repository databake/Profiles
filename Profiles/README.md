Who's Who
=========
[![Build Status](https://travis-ci.org/databake/Profiles.svg?branch=Develop)](https://travis-ci.org/databake/Profiles)

A simple mobile app that provides easy access to biographies and pictures of employees. 

NB As there is NO design at all. NSAssert has been used in place of complete error handling, however all the places that would normally have error handling, has an NSAssert.

The TAB ios test pdf states that 3rd Party libraries should be avoided. I would normally use Kiwi as the testing framework, however in an attempt to comply I have used XCTest. Mocking and Stubs are not supported, at least in the usual sense, therefore, the tests are really an after-thought. 

Example using Kiwi we can:

            id protocolMock = [KWMock nullMockForProtocol:@protocol(GBSpecificWebPageParserDelegate)];
            sut.delegate = protocolMock;
            [[protocolMock shouldEventually] receive:@selector(parser:didParseBatch:)];
            [sut startParsing];
