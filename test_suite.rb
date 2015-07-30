
require 'selenium-webdriver'
require 'test/unit'

require './utils.rb'


# Creating a separate TestCase for each browser
# allows us to modularize and reuse the test
# logic while still keeping distinct test
# sequences separated. This separation gives
# us good feedback in the traceback and test
# report when a specific part of a test fails.

# I considered using mixins to avoid violating
# the D.R.Y. principle (by having it run the
# tests once per browser), but I thought that
# for a small test suite like this one, that
# would make the code harder to read, which
# in turn would make it harder to maintain.

# There is also at least one critical
# difference in what Selenium needs
# to be told to do between Firefox
# and Chrome, so perhaps reusing the
# Selenium instructions wouldn't be
# a good idea after all. Chrome
# COULD use the Firefox solution
# (search all <a>nchors for text rather
# than all <li>s) but I'll leave it in
# to illustrate the difference, with
# this comment to explain it.

class TestWithChrome < Test::Unit::TestCase

    include SeleniumUtilities
    include IniFileUtilities

    def setup

        load_and_flatten_ini_file

        # Note that this will open a browser window.
        @driver = Selenium::WebDriver.for :chrome

        # Implicit and explicit waits shouldn't be mixed.
        # See: http://docs.seleniumhq.org/docs/04_webdriver_advanced.jsp
        @driver.manage.timeouts.implicit_wait = 10

    end

    def teardown
        @driver.quit
    end

    def test_saucelabs_with_chrome

        @driver.navigate.to 'https://docs.saucelabs.com/reference/platforms-configurator/?_ga=1.5883444.608313.1428365147#/'

        # I use this "foo = find_sublements_with_text(...); foo.click" pattern
        # extensively, as I feel it makes the code easier to read at a glance.
        api_button =
            find_subelements_with_text("class", "api-button", @ini_file["api"])
        api_button.click

        # For this relatively small test, we can check all of
        # the "button" elements for one with unique text.
        device_select_dropdown =
            find_subelements_with_text("tag_name", "button", "Select a device")
        device_select_dropdown.click

        # Now we have to verify that we're on the correct
        # tab by clicking it. All of the class names are
        # lowercase, but we do have to maintain proper
        # case for the text itself.
        device_select_tab =
            find_subelements_with_text("class",
                                       @ini_file["device_category"].downcase,
                                       @ini_file["device_category"])
        device_select_tab.click

        # There are some minor animations that we need to wait
        # for; the implicit wait does not cover these.
        sleep(1)

        device_selection =
            find_subelements_with_text("tag_name", "span", @ini_file["device"])
        device_selection.click

        os_select_dropdown =
            find_subelements_with_text("tag_name", "button", "Select an operating system")
        os_select_dropdown.click

        os_selection =
            find_subelements_with_text("tag_name", "span", @ini_file["operating_system"])
        os_selection.click

        sleep(1)

        browser_select_dropdown =
            find_subelements_with_text("tag_name", "button", "Select a browser")
        browser_select_dropdown.click

        browser_select_tab =
            find_subelements_with_text("class",
                                       @ini_file["browser"].downcase,
                                       @ini_file["browser"])
        browser_select_tab.click

        version_number =
            find_subelements_with_text("tag_name", "span", @ini_file["browser_version"].to_s)
        version_number.click

        advanced_config_button =
            find_subelements_with_text("tag_name", "h4", "Show Advanced Configuration")
        advanced_config_button.click

        sleep(1)

        if @ini_file["record_video"] == false
            record_video_toggle =
                find_subelements_with_text("tag_name", "label", "Record Video")
            record_video_toggle.click
        end

        if @ini_file["capture_screenshot"] == false
            capture_screenshot_toggle =
                find_subelements_with_text("tag_name", "label", "Capture Screenshot")
            capture_screenshot_toggle.click
        end

        # Verification Step.
        # First we need to switch the code panel to Ruby.
        # Note that trying find_subelements_with_text
        # with these parameters in both Chrome and
        # Firefox yields the correct li element, but
        # Selenium considers the Firefox version to
        # have an empty string for text, so it uses
        # anchors instead.
        # I left it in to point out the difference.
        ruby_tab =
            find_subelements_with_text("tag_name", "li", @ini_file["output_language"])
        ruby_tab.click

        sleep(1)

        code_panel = @driver.find_element(:class, @ini_file["output_language"].downcase)
        assert_equal(@ini_file["expected_output"], code_panel.text)

        # This is almost, but not quite, enough
        # of a reason for me to want to make the
        # driver's browser name a class attribute.
        screenshot_save_path =
            @ini_file["screenshot_save_path"] + "chrome_screen.png"
        @driver.save_screenshot(screenshot_save_path)

    end

    def test_wikipedia_with_chrome

        # Brings us to the global Wikipedia gateway page.
        @driver.navigate.to "http://www.wikipedia.org"

        # The global gateway conveniently defaults to using the English wiki.
        search_box = @driver.find_element(:name, 'search')
        search_box.send_keys "continuous delivery"
        search_box.submit

        # We can't use find_subelements_with_text here,
        # since this image has no text attribute.
        images = @driver.find_elements(:class, 'image')

        images.each do |each_image|
            if each_image.attribute("href").include? "diagram"
                each_image.click
            end
        end

        # Unlike previous steps, for this specific function
        # of closing an opened viewer, the page needs some
        # script to be executed. For that it has to wait.
        # Note that explicit and implicit waits can't be mixed.
        sleep(4)

        # Now that the exit button has loaded, we can click it.
        # Pseudonymization for readability:
        exit_button = @driver.find_element(:class, 'mw-mmv-close')

        exit_button.click

        automated_testing_link =
            find_subelements_with_text("class", "mw-redirect", "automated testing")
        automated_testing_link.click

        overview_header =
            find_subelements_with_text("tag_name", "h2", "Overview[edit]")
        assert(overview_header.displayed?)

        cdt_header =
            find_subelements_with_text("tag_name", "h2", "Code-driven testing[edit]")
        assert(cdt_header.displayed?)

    end

end


class TestWithFirefox < Test::Unit::TestCase

    include SeleniumUtilities
    include IniFileUtilities

    def setup

        load_and_flatten_ini_file

        # Note that this will open a browser window.
        @driver = Selenium::WebDriver.for :firefox

        # Implicit and explicit waits shouldn't be mixed.
        # See: http://docs.seleniumhq.org/docs/04_webdriver_advanced.jsp
        @driver.manage.timeouts.implicit_wait = 10

    end

    def teardown
        @driver.quit
    end

    def test_saucelabs_with_firefox

        @driver.navigate.to 'https://docs.saucelabs.com/reference/platforms-configurator/?_ga=1.5883444.608313.1428365147#/'

        # I use this "foo = find_sublements_with_text(...); foo.click" pattern
        # extensively, as I feel it makes the code easier to read at a glance.
        api_button =
            find_subelements_with_text("class", "api-button", @ini_file["api"])
        api_button.click

        # For this relatively small test, we can check all of
        # the "button" elements for one with unique text.
        device_select_dropdown =
            find_subelements_with_text("tag_name", "button", "Select a device")
        device_select_dropdown.click

        # Now we have to verify that we're on the correct
        # tab by clicking it. All of the class names are
        # lowercase, but we do have to maintain proper
        # case for the text itself.
        device_select_tab =
            find_subelements_with_text("class",
                                       @ini_file["device_category"].downcase,
                                       @ini_file["device_category"])
        device_select_tab.click

        # There are some minor animations that we need to wait
        # for; the implicit wait does not cover these.
        sleep(1)

        device_selection =
            find_subelements_with_text("tag_name", "span", @ini_file["device"])
        device_selection.click

        os_select_dropdown =
            find_subelements_with_text("tag_name", "button", "Select an operating system")
        os_select_dropdown.click

        os_selection =
            find_subelements_with_text("tag_name", "span", @ini_file["operating_system"])
        os_selection.click

        sleep(1)

        browser_select_dropdown =
            find_subelements_with_text("tag_name", "button", "Select a browser")
        browser_select_dropdown.click

        browser_select_tab =
            find_subelements_with_text("class",
                                       @ini_file["browser"].downcase,
                                       @ini_file["browser"])
        browser_select_tab.click

        version_number =
            find_subelements_with_text("tag_name", "span", @ini_file["browser_version"].to_s)
        version_number.click

        advanced_config_button =
            find_subelements_with_text("tag_name", "h4", "Show Advanced Configuration")
        advanced_config_button.click

        sleep(1)

        if @ini_file["record_video"] == false
            record_video_toggle =
                find_subelements_with_text("tag_name", "label", "Record Video")
            record_video_toggle.click
        end

        if @ini_file["capture_screenshot"] == false
            capture_screenshot_toggle =
                find_subelements_with_text("tag_name", "label", "Capture Screenshot")
            capture_screenshot_toggle.click
        end

        # Verification Step.
        # First we need to switch the code panel to Ruby.
        # Note that trying find_subelements_with_text
        # with these parameters in both Chrome and
        # Firefox yields the correct li element, but
        # Selenium considers the Firefox version to
        # have an empty string for text, so it uses
        # anchors instead.
        # I left it in to point out the difference.
        ruby_tab =
            find_subelements_with_text("tag_name", "a", @ini_file["output_language"])
        ruby_tab.click

        sleep(1)

        code_panel_id = "code-result-" + @ini_file['output_language']
        code_panel = @driver.find_element(:id, code_panel_id)

        assert_equal(@ini_file["expected_output"], code_panel.text)

        screenshot_save_path =
            @ini_file["screenshot_save_path"] + "firefox_screen.png"
        @driver.save_screenshot(screenshot_save_path)

    end

    def test_wikipedia_with_firefox

        # Brings us to the global Wikipedia gateway page.
        @driver.navigate.to "http://www.wikipedia.org"

        # The global gateway conveniently defaults to using the English wiki.
        search_box = @driver.find_element(:name, 'search')
        search_box.send_keys "continuous delivery"
        search_box.submit

        # We can't use find_subelements_with_text here,
        # since this image has no text attribute.
        images = @driver.find_elements(:class, 'image')

        images.each do |each_image|
            if each_image.attribute("href").include? "diagram"
                each_image.click
            end
        end

        # Unlike previous steps, for this specific function
        # of closing an opened viewer, the page needs some
        # script to be executed. For that it has to wait.
        # Note that explicit and implicit waits can't be mixed.
        sleep(4)

        # Now that the exit button has loaded, we can click it.
        # Pseudonymization for readability:
        exit_button = @driver.find_element(:class, 'mw-mmv-close')

        exit_button.click

        automated_testing_link =
            find_subelements_with_text("class", "mw-redirect", "automated testing")
        automated_testing_link.click

        # Keeping the [edit] both ensures this remains
        # compatible with find_subelements_with_text,
        # and demonstrates that it is in fact the section
        # header that is displayed.
        overview_header =
            find_subelements_with_text("tag_name", "h2", "Overview[edit]")
        assert(overview_header.displayed?)

        cdt_header =
            find_subelements_with_text("tag_name", "h2", "Code-driven testing[edit]")
        assert(cdt_header.displayed?)

    end

end
