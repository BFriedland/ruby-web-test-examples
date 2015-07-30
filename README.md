
# Ruby web test examples, with selenium-webdriver
These tests were made in response to a set of example specifications. They're intended to demonstrate web testing in Ruby with a basic object-oriented programming approach.

# Caveats
These tests don't perfectly compensate for slow or overtaxed computers and connections. Some of the time-related code may be related to this issue, as it was occasionally a problem during development. StaleElementReferenceError, for example, only happens for one query in `test_wikipedia_with_chrome` (the "Overview[edit]" one) when I have a second browser running with 20+ research tabs loaded.

# Requirements
In addition to the gems in the Gemfile, these test scenarios have some non-Ruby requirements.
- The FirefoxDriver and ChromeDriver for Selenium
